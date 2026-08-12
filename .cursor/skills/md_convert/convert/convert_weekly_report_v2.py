#!/usr/bin/env python3
"""Convert weekly_report_v2/v3.md to platform-compliant *_converted.md.

Extends md_convert/convert.py with weekly-report-specific rules:
  - 订阅毛利 as revenue alias
  - default 出处：知识库 + 事件描述/关联度 for knowledge events
  - knowledge line shape: {事件}，出处：…，命中原因：…，事件描述：…，关联度：…
  - split merged blockquotes (下钻总结 + 知识库 + 逻辑链)
  - 现象： prefix on section-two metric headlines
  - strip misplaced !tree_str!/!tree_end! and convert ASCII trees (incl. formula root)
  - tree contrib from （占比XX%） or trailing （XX%）
  - strip *拖累* / *反向提拉* from node labels
"""
from __future__ import annotations

import argparse
import os
import re
import sys

CONVERT_DIR = os.path.dirname(os.path.abspath(__file__))
MD_CONVERT_DIR = os.path.dirname(CONVERT_DIR)
sys.path.insert(0, MD_CONVERT_DIR)

import convert as C  # noqa: E402

# --- Extensions ---
C.REVENUE_ALIASES = list(C.REVENUE_ALIASES) + ['订阅毛利']
DEFAULT_KNOWLEDGE_SOURCE = '知识库'
# 关联度不得默认「强」；缺省时按命中文案启发式评 强/中/弱（见 infer_relevance）
RELEVANCE_LEVELS = ('强', '中', '弱')
RELEVANCE_WEAK_HINTS = (
    '方向矛盾', '方向相反', '反向大跌', '反向', '未受明显', '未受影响',
    '影响可忽略', '关联弱', '解释力弱', '不宜外推', '不可直接',
)
RELEVANCE_MID_HINTS = (
    '影响面有限', '历史同期', '去年同期', '辅助', '佐证', '间接', '非主导',
    '可能提升', '部分一致',
)
RELEVANCE_STRONG_HINTS = (
    '时间段重合', '国家一致', '完全对应', '完全重合', '主要拖累', '主要拉动',
    '高度相关', '主因', '最大拖累', '窗口结束', '节后首周', '脉冲回调',
    '滞后转化', '结构抬升', '投放收缩',
)
TREE_MARKER_LINES = frozenset({'!tree_str!', '!tree_end!'})
FORMULA_ROOT_RE = re.compile(r'^(.+?)\s*=')
HEADLINE_XIANXIANG_RE = re.compile(r'^\*{0,2}(整体|日均)')
TREE_TAG_RE = re.compile(r'\*(?:反向提拉|拖累)\*')
# Prefer （占比52.88%）；else bare trailing （42.36%）
C.TREE_CONTRIB_RE = re.compile(
    r'(?:[（(](?:贡献)?占比\s*(-?[\d,.]+%)\s*[）)]|[（(](-?[\d,.]+%)[）)]\s*$)'
)


_orig_parse_tree_node = C.parse_tree_node


def parse_tree_node(raw):
    is_reverse = '*反向提拉*' in raw
    clean = TREE_TAG_RE.sub('', raw).strip()
    name = clean.split(C.TREE_NAME_SEP, 1)[0].strip()
    contrib = C.TREE_CONTRIB_RE.search(clean)
    if contrib:
        pct = contrib.group(1) or contrib.group(2)
        label = C.TREE_NODE_LABEL_FMT.format(name=name, contrib=pct)
    else:
        label = name
    return label, is_reverse


C.parse_tree_node = parse_tree_node


def _strip_field_edges(value: str) -> str:
    return value.strip().strip('，,').strip().rstrip('。').strip()


def _parse_knowledge_fields(text: str) -> tuple[str, dict[str, str]]:
    """Split leading 事件名 and labeled fields (出处/命中原因/事件描述/关联度)."""
    matches = list(C.KNOWLEDGE_FIELD_RE.finditer(text))
    fields: dict[str, str] = {}
    if not matches:
        return _strip_field_edges(text), fields

    event = _strip_field_edges(text[: matches[0].start()])
    for i, m in enumerate(matches):
        key = m.group(1)
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        fields[key] = _strip_field_edges(text[start:end])
    return event, fields


def _normalize_relevance(rel: str) -> str:
    """Keep 强/中/弱（可带括号说明）；无法识别则返回空串。"""
    rel = (rel or '').strip()
    if not rel:
        return ''
    for level in RELEVANCE_LEVELS:
        if rel == level or rel.startswith(level):
            return rel
    return ''


def infer_relevance(event: str, reason: str, desc: str) -> str:
    """按命中文案启发式评关联度：强 / 中 / 弱。

    优先级：弱信号 > 强信号 > 中信号；皆无则「中」（不默认强）。
    Agent 在 v2/v3 正文写出的关联度优先，本函数仅作缺省补全。
    """
    blob = f'{event}，{reason}，{desc}'
    if any(h in blob for h in RELEVANCE_WEAK_HINTS):
        return '弱'
    if any(h in blob for h in RELEVANCE_STRONG_HINTS):
        return '强'
    if any(h in blob for h in RELEVANCE_MID_HINTS):
        return '中'
    return '中'


def normalize_knowledge_event(text):
    """Normalize to: {事件}，出处：…，命中原因：…，事件描述：…，关联度：…

    - 事件：行首名称（无标签）
    - 缺出处时默认「知识库」（插在事件名之后，不吞掉事件名）
    - 缺事件描述时回退为事件名
    - 关联度：保留原文 强/中/弱（可带说明）；缺省时按 infer_relevance 评级，不默认强
    """
    if '-->' in text or (C.LOGIC_CHAIN_ARROW.search(text) and C.LOGIC_CHAIN_LABEL_RE.search(text)):
        return text

    event, fields = _parse_knowledge_fields(text)

    # Recover from legacy bug: "出处：知识库，{事件}，命中原因：…"
    src = fields.get('出处', '')
    src_prefix = DEFAULT_KNOWLEDGE_SOURCE + '，'
    if not event and src.startswith(src_prefix):
        event = _strip_field_edges(src[len(src_prefix) :])
        fields['出处'] = DEFAULT_KNOWLEDGE_SOURCE
    elif src.startswith(src_prefix) and '，' in src:
        # 出处值里误含事件名
        maybe_event = _strip_field_edges(src[len(src_prefix) :])
        if maybe_event and (not event or event == DEFAULT_KNOWLEDGE_SOURCE):
            event = maybe_event
            fields['出处'] = DEFAULT_KNOWLEDGE_SOURCE

    src = fields.get('出处') or DEFAULT_KNOWLEDGE_SOURCE
    reason = fields.get('命中原因', '')
    desc = fields.get('事件描述', '')
    rel = _normalize_relevance(fields.get('关联度', ''))

    if not event:
        # Fallback: first clause before 命中原因-like free text
        event = _strip_field_edges(text.split('，')[0]) if '，' in text else _strip_field_edges(text)
    if not desc:
        desc = event
    if not rel:
        rel = infer_relevance(event, reason, desc)

    return (
        f'{event}，'
        f'{C.KNOWLEDGE_LABEL_SRC}{src}，'
        f'{C.KNOWLEDGE_LABEL_REASON}{reason}，'
        f'{C.KNOWLEDGE_LABEL_DESC}{desc}，'
        f'{C.KNOWLEDGE_LABEL_REL}{rel}'
    )


def ensure_xianxiang(line):
    """Add 现象： prefix to section-two metric headline lines."""
    stripped = line.strip()
    if (
        not stripped
        or stripped.startswith('#')
        or C.is_blockquote(line)
        or C.is_table_line(line)
        or C.S2_SUMMARY_MARKER in stripped
    ):
        return line
    if '环比' in stripped and HEADLINE_XIANXIANG_RE.match(stripped):
        indent = line[: len(line) - len(line.lstrip())]
        return indent + '现象：' + stripped
    return line


def split_merged_blockquote(lines_slice):
    """Split one blockquote block into drilldown / knowledge / logic sub-blocks."""
    drilldown, knowledge, logic = [], [], []
    section = 'drilldown'

    for line in lines_slice:
        if C.KNOWLEDGE_BLOCK_MARKER in line and C.is_blockquote(line):
            section = 'knowledge'
            knowledge.append(line)
            continue
        if C.LOGIC_CHAIN_LABEL_RE.search(line) and C.is_blockquote(line):
            section = 'logic'
            logic.append(line)
            continue
        if section == 'drilldown':
            drilldown.append(line)
        elif section == 'knowledge':
            knowledge.append(line)
        else:
            logic.append(line)

    return drilldown, knowledge, logic


def _collect_tree_block(lines, start):
    """Collect ASCII tree rows after a tree section marker; return (root, rows, next_idx)."""
    n = len(lines)
    j = start
    while j < n and (not lines[j].strip() or lines[j].strip() in TREE_MARKER_LINES):
        j += 1

    root_label = None
    if j < n:
        candidate = lines[j].rstrip('\n').strip()
        if FORMULA_ROOT_RE.match(candidate) and not C.TREE_LINE_RE.match(candidate):
            root_label = FORMULA_ROOT_RE.match(candidate).group(1).strip()
            j += 1

    tree_rows = []
    while j < n:
        tline = lines[j].rstrip('\n')
        if tline.strip() in TREE_MARKER_LINES:
            j += 1
            continue
        tm = C.TREE_LINE_RE.match(tline)
        if not tm:
            break
        depth = len(tm.group(1)) // C.TREE_INDENT_WIDTH
        tree_rows.append((depth, tm.group(3)))
        j += 1

    return root_label, tree_rows, j


def pass1(lines):
    """Content transformation with weekly_report-specific rules."""
    out = []
    top_section = None
    current_metric = None
    in_knowledge = False
    title_done = False
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i].rstrip('\n')
        stripped = line.strip()

        if stripped in TREE_MARKER_LINES:
            i += 1
            continue

        if in_knowledge and not C.is_blockquote(line):
            in_knowledge = False

        if not title_done and line.startswith('# ') and C.extract_date_from_title(line):
            out.append(C.transform_title(line))
            title_done = True
            i += 1
            continue

        m_sec = C.TOP_SECTION_RE.match(line)
        if m_sec:
            num, text = m_sec.group(1), m_sec.group(2)
            out.append(C.transform_top_section(num, text))
            top_section = num
            current_metric = None
            in_knowledge = False
            i += 1
            continue

        m_metric = C.METRIC_HEADING_RE.match(line)
        if m_metric and top_section == '二':
            current_metric = m_metric.group(1).strip()
            out.append(C.METRIC_HEADING_FMT.format(name=current_metric))
            i += 1
            continue

        m_h2 = re.match(r'^##\s+(.+?)\s*$', line)
        if m_h2 and top_section == '二':
            current_metric = m_h2.group(1).strip()

        if top_section == '二' and not C.is_blockquote(line) and not C.is_table_line(line):
            line = ensure_xianxiang(line)
            stripped = line.strip()

        if C.KNOWLEDGE_BLOCK_MARKER in line and C.is_blockquote(line):
            in_knowledge = True
            out.append(line)
            i += 1
            continue
        if C.is_blockquote(line) and C.LOGIC_CHAIN_LABEL_RE.search(line):
            in_knowledge = False
        if in_knowledge:
            m_evt = C.KNOWLEDGE_EVENT_LINE_RE.match(line)
            if m_evt and '-->' in m_evt.group(1):
                in_knowledge = False
                out.append(line)
                i += 1
                continue
            if m_evt:
                fixed = normalize_knowledge_event(m_evt.group(1))
                out.append('> - ' + fixed)
                i += 1
                continue

        is_tree_marker = bool(C.TREE_SECTION_RE.match(stripped))
        if is_tree_marker:
            formula_root, tree_rows, j = _collect_tree_block(lines, i + 1)
            if tree_rows:
                out.append(stripped)
                out.append('')
                root_label = formula_root or current_metric or ''
                m_assoc = C.ASSO_DRILL_ROOT_RE.search(stripped)
                if m_assoc:
                    root_label = m_assoc.group(1).strip()
                out.extend(C.build_mermaid(root_label, tree_rows))
                i = j
                continue

        if C.is_table_line(line):
            if C.TABLE_SEP_RE.match(line.strip()):
                ncol = len(C.split_table_cells(line))
                cells = [C.TABLE_SEP_FIRST if k == 0 else C.TABLE_SEP_OTHER for k in range(ncol)]
                out.append('|' + '|'.join(cells) + '|')
            elif any(k in line for k in C.TABLE_COLUMN_RENAMES):
                cells = C.split_table_cells(line)
                cells = [C.TABLE_COLUMN_RENAMES.get(c, c) for c in cells]
                out.append('|' + '|'.join(cells) + '|')
            else:
                out.append(line)
            i += 1
            continue

        out.append(line)
        i += 1

    return out


def _scan_metric_section(lines_slice):
    """Scan one ## metric subsection; split merged blockquotes; match convert.py trends API."""
    result = {
        'pre': [],
        'summary2': None,
        'knowledge': None,
        'logic': None,
        'trends': [],
        'trees': [],
        'post': [],
    }
    i = 0
    n = len(lines_slice)

    while i < n:
        line = lines_slice[i]
        if C.is_mermaid_start(line) or C.is_blockquote(line) or C.is_table_line(line):
            break
        result['pre'].append(line)
        i += 1

    while i < n:
        line = lines_slice[i]
        if C.is_mermaid_start(line):
            s, e = C._find_mermaid_range(lines_slice, i)
            result['trees'].append((None, lines_slice[s:e]))
            i = e
            continue
        if C.is_blockquote(line):
            s, e = C._find_blockquote_range(lines_slice, i)
            dd, kn, lg = split_merged_blockquote(lines_slice[s:e])
            if dd:
                if result['summary2'] is None:
                    result['summary2'] = list(dd)
                else:
                    result['summary2'].extend(dd)
            if kn:
                result['knowledge'] = kn
            if lg:
                result['logic'] = lg
            i = e
            continue
        if C.is_table_line(line):
            s, e = C._find_table_range(lines_slice, i)
            header = C.split_table_cells(lines_slice[s])
            week_count = sum(1 for h in header[1:] if C.WEEK_COL_RE.search(h))
            has_desc = any('异常说明' in h or '异常详情' in h for h in header)
            if (
                week_count >= 3
                and not has_desc
                and not C._is_feature_compare_table(header)
            ):
                category = C._classify_trend_table(lines_slice[s:e])
                result['trends'].append((category, lines_slice[s:e]))
            else:
                result['post'].extend(lines_slice[s:e])
            i = e
            continue
        stripped = line.strip()
        if C.TREE_SECTION_RE.match(stripped):
            marker_line = line
            i += 1
            while i < n and not lines_slice[i].strip():
                i += 1
            if i < n and C.is_mermaid_start(lines_slice[i]):
                s, e = C._find_mermaid_range(lines_slice, i)
                result['trees'].append((marker_line, lines_slice[s:e]))
                i = e
            else:
                result['post'].append(marker_line)
            continue
        result['post'].append(line)
        i += 1

    pre, s2_from_pre = C._extract_summary2_from_pre(result['pre'])
    result['pre'] = pre
    if s2_from_pre:
        if result['summary2'] is None:
            result['summary2'] = s2_from_pre
        else:
            result['summary2'] = s2_from_pre + [''] + result['summary2']
    return result


def _find_summary_sentence_safe(aliases, lines, exclude=None):
    """Like C._find_summary_sentence but skip lines containing exclude keywords."""
    exclude = exclude or []
    for li, line in enumerate(lines):
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        if any(x in stripped for x in exclude):
            continue
        if not C.contains_any(stripped, aliases):
            continue
        m = C.SUMMARY_SENTENCE_END.search(stripped)
        if m:
            end = m.end()
            sentence = stripped[:end]
            if C.contains_any(sentence, aliases) and not any(x in sentence for x in exclude):
                start = len(line) - len(line.lstrip())
                return li, start, start + end
    return None


def _wrap_summary_section(lines, start, end):
    """Wrap section 一; keep trailing --- outside summary1_end."""
    out = list(lines)
    dau_info = _find_summary_sentence_safe(
        C.DAU_ALIASES, lines[start:end], exclude=['次留', '保存量', '保存率']
    )
    if dau_info:
        li, sp, ep = dau_info
        actual_li = start + li
        line = out[actual_li]
        out[actual_li] = (
            line[:sp] + C.M['dau_sum_s'] + line[sp:ep] + C.M['dau_sum_e'] + line[ep:]
        )
    rev_info = _find_summary_sentence_safe(C.REVENUE_ALIASES, lines[start:end])
    if rev_info:
        li, sp, ep = rev_info
        actual_li = start + li
        line = out[actual_li]
        if C.M['dau_sum_s'] in line:
            idx = line.find(C.M['dau_sum_e'])
            if idx != -1:
                after = idx + len(C.M['dau_sum_e'])
                if sp >= after:
                    out[actual_li] = (
                        line[:sp]
                        + C.M['rev_sum_s']
                        + line[sp:ep]
                        + C.M['rev_sum_e']
                        + line[ep:]
                    )
        else:
            out[actual_li] = (
                line[:sp] + C.M['rev_sum_s'] + line[sp:ep] + C.M['rev_sum_e'] + line[ep:]
            )

    inner = out[start + 1 : end]
    trailing = []
    while inner and not inner[-1].strip():
        inner.pop()
    while inner and inner[-1].strip() == '---':
        trailing.insert(0, inner.pop())

    result = [out[start], '', C.M['summary1_s']]
    result.extend(inner)
    result.append(C.M['summary1_e'])
    result.extend(trailing)
    return result


def convert(text):
    lines = text.split('\n')
    lines = pass1(lines)
    lines = C.pass2(lines)
    lines = pass_anomaly_table(lines)
    return '\n'.join(lines)


# --- 三章异常表：标识符 + 毛利取整 ---
ANOMALY_SECTION_RE = re.compile(r'^#{1,6}\s*三、\s*异常指标检测')
ANOMALY_MARGIN_NAMES = (
    '日均订阅毛利（剔除退款，$）',
    '新增毛利',
    '续订毛利',
)


def _round_margin_cell(cell: str) -> str:
    s = cell.strip()
    if '.' not in s:
        return cell
    try:
        return f"{int(round(float(s.replace(',', '')))):,}"
    except ValueError:
        return cell


def _decorate_anomaly_metric_cell(cell: str) -> tuple[str, str]:
    """Return (decorated_cell, name_core). Idempotent for existing markers."""
    raw = cell.strip()
    raw = re.sub(r'!dau_data_(?:str|end)!', '', raw)
    raw = re.sub(r'!revenue_data_(?:str|end)!', '', raw)
    raw = raw.strip()
    name_core = raw.replace('**', '').strip()
    if name_core == '整体DAU':
        return '!dau_data_str!**整体DAU**!dau_data_end!', name_core
    if name_core == '日均订阅毛利（剔除退款，$）':
        return (
            '!revenue_data_str!**日均订阅毛利（剔除退款，$）**!revenue_data_end!',
            name_core,
        )
    return cell, name_core


def pass_anomaly_table(lines):
    """Insert dau/revenue_data markers and round three margin rows in 三、异常指标检测."""
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        if not ANOMALY_SECTION_RE.match(line.strip()):
            out.append(line)
            i += 1
            continue

        out.append(line)
        i += 1
        while i < n and not (C.is_table_line(lines[i]) and '指标' in lines[i]):
            out.append(lines[i])
            i += 1
        if i >= n:
            break

        while i < n and C.is_table_line(lines[i]):
            cells = C.split_table_cells(lines[i])
            if cells and not C.TABLE_SEP_RE.match(lines[i].strip()):
                metric = cells[0].strip()
                is_header = metric.replace('*', '').replace('!', '') == '指标' or metric == '指标'
                if not is_header and metric:
                    decorated, name_core = _decorate_anomaly_metric_cell(cells[0])
                    cells[0] = decorated
                    if name_core in ANOMALY_MARGIN_NAMES:
                        cells = [cells[0]] + [_round_margin_cell(c) for c in cells[1:]]
                    out.append('| ' + ' | '.join(cells) + ' |')
                else:
                    out.append(lines[i])
            else:
                out.append(lines[i])
            i += 1
            if i < n and not C.is_table_line(lines[i]):
                break
        continue

    return out


def main():
    parser = argparse.ArgumentParser(
        description='Convert weekly_report_v2/v3.md → *_converted.md',
    )
    parser.add_argument('-i', '--input', required=True, help='Source weekly_report_v2/v3.md')
    parser.add_argument('-o', '--output', required=True, help='Output *_converted.md path')
    args = parser.parse_args()

    input_file = args.input
    output_file = args.output

    if not os.path.exists(input_file):
        print('Input file not found: {}'.format(input_file))
        sys.exit(1)

    C.pass1 = pass1
    C._scan_metric_section = _scan_metric_section
    C._wrap_summary_section = _wrap_summary_section
    C.normalize_knowledge_event = normalize_knowledge_event
    C.parse_tree_node = parse_tree_node

    with open(input_file, 'r', encoding='utf-8') as f:
        src = f.read()
    result = convert(src)
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(result)
    print('converted: {} -> {}'.format(os.path.basename(input_file), os.path.basename(output_file)))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Convert monthly_report_v2.md to platform-compliant monthly_report_v2_converted.md.

Based on convert_weekly_report_v2.py with monthly-specific rules:
  - Title: # 月报（YYYY年MM月） → # 月报（YYYY-MM-01 至 YYYY-MM-DD）
  - MAU as DAU-side aliases / markers (dau_summary / dau_trend / dau_data)
  - 订阅毛利 as revenue; anomaly row may be 订阅毛利（剔除退款，$）
  - Month columns YYYY-MM recognized as trend columns
  - 现象： also matches 订阅毛利 headlines
  - Strip pre-existing !trend_*! wrappers so pass2 can re-assign
  - Keep 业务举措 / 业务重要举措 content (preserve principle)
"""
from __future__ import annotations

import argparse
import calendar
import os
import re
import sys

CONVERT_DIR = os.path.dirname(os.path.abspath(__file__))
MD_CONVERT_DIR = os.path.dirname(CONVERT_DIR)
sys.path.insert(0, MD_CONVERT_DIR)

import convert as C  # noqa: E402

# --- Monthly extensions ---
C.DAU_ALIASES = list(C.DAU_ALIASES) + ['MAU']
C.REVENUE_ALIASES = list(C.REVENUE_ALIASES) + ['订阅毛利']
C.WEEK_COL_RE = re.compile(
    r'(wk\d+|w\d+|^\d+周前|前\d+周|本周|上周|本月|上月|20\d{2}[-/]\d{1,2})',
    re.I,
)
C.TITLE_OUTPUT_FMT = '# 月报（{s} 至 {e}）'

TITLE_MONTH_CN_RE = re.compile(
    r'[（(]\s*(20\d{2})\s*年\s*(\d{1,2})\s*月\s*[）)]'
)
TITLE_MONTH_ISO_RE = re.compile(
    r'[（(]\s*(20\d{2})[-/.](\d{1,2})(?:[-/.](\d{1,2}))?\s*[至到~\-—_]+\s*'
    r'(20\d{2})?[-/.]?(\d{1,2})?(?:[-/.](\d{1,2}))?\s*[）)]'
)

DEFAULT_KNOWLEDGE_SOURCE = '知识库'
TREE_MARKER_LINES = frozenset({'!tree_str!', '!tree_end!'})
TREND_MARKER_LINES = frozenset(
    {
        '!trend_str!',
        '!trend_end!',
        '!dau_trend_str!',
        '!dau_trend_end!',
        '!revenue_trend_str!',
        '!revenue_trend_end!',
    }
)
FORMULA_ROOT_RE = re.compile(r'^(.+?)\s*=')
HEADLINE_XIANXIANG_RE = re.compile(r'^\*{0,2}(整体|日均|订阅毛利)')
TREE_TAG_RE = re.compile(r'\*(?:反向提拉|拖累)\*')
# 月报树常见「（占比62.06%，数值 --> 数值）」：占比后不必立即闭括号
C.TREE_CONTRIB_RE = re.compile(
    r'(?:[（(](?:贡献)?占比\s*(-?[\d,.]+%)|(?:贡献)?占比\s*(-?[\d,.]+%)|[（(](-?[\d,.]+%)[）)]\s*$)'
)


def extract_monthly_date_from_title(line: str):
    """Return (start, end) as YYYY-MM-DD for monthly titles."""
    m = TITLE_MONTH_CN_RE.search(line)
    if m:
        year, month = int(m.group(1)), int(m.group(2))
        last = calendar.monthrange(year, month)[1]
        return (
            f'{year}-{month:02d}-01',
            f'{year}-{month:02d}-{last:02d}',
        )
    m = TITLE_MONTH_ISO_RE.search(line)
    if m:
        y1, m1, d1, y2, m2, d2 = m.groups()
        y2 = y2 or y1
        m2 = m2 or m1
        d1 = d1 or '01'
        if not d2:
            d2 = str(calendar.monthrange(int(y2), int(m2))[1])
        return (
            f'{int(y1):04d}-{int(m1):02d}-{int(d1):02d}',
            f'{int(y2):04d}-{int(m2):02d}-{int(d2):02d}',
        )
    return C.extract_date_from_title(line)


def transform_monthly_title(line: str) -> str:
    dates = extract_monthly_date_from_title(line)
    if not dates or dates[1] is None:
        return line
    return C.TITLE_OUTPUT_FMT.format(s=dates[0], e=dates[1])


def parse_tree_node(raw):
    is_reverse = '*反向提拉*' in raw
    clean = TREE_TAG_RE.sub('', raw).strip()
    name = clean.split(C.TREE_NAME_SEP, 1)[0].strip()
    contrib = C.TREE_CONTRIB_RE.search(clean)
    if contrib:
        pct = next(g for g in contrib.groups() if g)
        label = C.TREE_NODE_LABEL_FMT.format(name=name, contrib=pct)
    else:
        label = name
    return label, is_reverse


C.parse_tree_node = parse_tree_node


def normalize_knowledge_event(text):
    if '-->' in text or (
        C.LOGIC_CHAIN_ARROW.search(text) and C.LOGIC_CHAIN_LABEL_RE.search(text)
    ):
        return text

    has_src = C.KNOWLEDGE_LABEL_SRC in text
    has_reason = C.KNOWLEDGE_LABEL_REASON in text
    has_desc = C.KNOWLEDGE_LABEL_DESC in text

    fixed = text
    if not has_src:
        fixed = C.KNOWLEDGE_LABEL_SRC + DEFAULT_KNOWLEDGE_SOURCE + '，' + fixed

    if not has_reason:
        fixed = fixed + C.KNOWLEDGE_LABEL_REASON + C.KNOWLEDGE_SENTENCE_END
    if not has_desc:
        if C.KNOWLEDGE_LABEL_DESC not in fixed:
            if not fixed.rstrip().endswith('。'):
                fixed = fixed + '。'
            fixed = fixed + C.KNOWLEDGE_LABEL_DESC

    return fixed


def ensure_xianxiang(line):
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
    n = len(lines)
    j = start
    while j < n and (
        not lines[j].strip() or lines[j].strip() in TREE_MARKER_LINES | TREND_MARKER_LINES
    ):
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
        if tline.strip() in TREE_MARKER_LINES | TREND_MARKER_LINES:
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

        if stripped in TREE_MARKER_LINES or stripped in TREND_MARKER_LINES:
            i += 1
            continue

        if in_knowledge and not C.is_blockquote(line):
            in_knowledge = False

        if not title_done and line.startswith('# '):
            dates = extract_monthly_date_from_title(line)
            if dates and dates[1] is not None:
                out.append(transform_monthly_title(line))
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
        if m_metric and top_section == '三':
            current_metric = m_metric.group(1).strip()
            out.append(C.METRIC_HEADING_FMT.format(name=current_metric))
            i += 1
            continue

        m_h2 = re.match(r'^##\s+(.+?)\s*$', line)
        if m_h2 and top_section == '三':
            current_metric = m_h2.group(1).strip()

        if top_section == '三' and not C.is_blockquote(line) and not C.is_table_line(line):
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
                cells = [
                    C.TABLE_SEP_FIRST if k == 0 else C.TABLE_SEP_OTHER for k in range(ncol)
                ]
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
    result = {
        'pre': [],
        'summary2': None,
        'knowledge': None,
        'logic': None,
        'trends': [],
        'trees': [],
        'post': [],
    }
    # 业务举措 / 业务重要举措：整节原文保留（含路径 A/B Markdown 表格），
    # 不套 summary2/趋势/树标识符；不得把表格改回 blockquote 列举
    heading = lines_slice[0].strip() if lines_slice else ''
    if re.match(r'^##\s*业务', heading):
        result['pre'] = list(lines_slice)
        return result

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
            if C.contains_any(sentence, aliases) and not any(
                x in sentence for x in exclude
            ):
                start = len(line) - len(line.lstrip())
                return li, start, start + end
    return None


def _wrap_summary_section(lines, start, end):
    out = list(lines)
    # Prefer MAU over generic「活跃」in bullets
    dau_info = _find_summary_sentence_safe(
        ['MAU'] + [a for a in C.DAU_ALIASES if a != '活跃'],
        lines[start:end],
        exclude=['次留', '保存量', '保存率', '业务举措'],
    )
    if not dau_info:
        dau_info = _find_summary_sentence_safe(
            C.DAU_ALIASES,
            lines[start:end],
            exclude=['次留', '保存量', '保存率', '业务举措'],
        )
    if dau_info:
        li, sp, ep = dau_info
        actual_li = start + li
        line = out[actual_li]
        out[actual_li] = (
            line[:sp] + C.M['dau_sum_s'] + line[sp:ep] + C.M['dau_sum_e'] + line[ep:]
        )
    rev_info = _find_summary_sentence_safe(
        C.REVENUE_ALIASES,
        lines[start:end],
        exclude=['业务举措'],
    )
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


def _wrap_okr_section(lines, start, end):
    """Wrap OKR numbered summary (lines before OKR table) with summary1 markers."""
    heading = lines[start]
    i = start + 1
    preamble = []
    while i < end and not C.is_table_line(lines[i]):
        preamble.append(lines[i])
        i += 1
    rest = lines[i:end]

    trailing = []
    while rest and not rest[-1].strip():
        trailing.insert(0, rest.pop())
    while rest and rest[-1].strip() == '---':
        trailing.insert(0, rest.pop())

    while preamble and not preamble[-1].strip():
        preamble.pop()
    while preamble and not preamble[0].strip():
        preamble.pop(0)

    if not preamble:
        return lines[start:end]

    if any(C.M['summary1_s'] in ln or C.M['summary1_e'] in ln for ln in preamble):
        return lines[start:end]

    result = [heading, '', C.M['summary1_s']]
    result.extend(preamble)
    result.append(C.M['summary1_e'])
    result.append('')
    result.extend(rest)
    result.extend(trailing)
    return result


ANOMALY_SECTION_RE = re.compile(r'^#{1,6}\s*四、\s*异常指标检测')
ANOMALY_MARGIN_NAMES = (
    '日均订阅毛利（剔除退款，$）',
    '订阅毛利（剔除退款，$）',
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
    raw = cell.strip()
    raw = re.sub(r'!dau_data_(?:str|end)!', '', raw)
    raw = re.sub(r'!revenue_data_(?:str|end)!', '', raw)
    raw = raw.strip()
    name_core = raw.replace('**', '').strip()
    if name_core in ('整体DAU', '整体 MAU', '整体MAU'):
        display = raw if raw.startswith('**') else f'**{name_core}**'
        return f'!dau_data_str!{display}!dau_data_end!', name_core
    if name_core in (
        '日均订阅毛利（剔除退款，$）',
        '订阅毛利（剔除退款，$）',
    ):
        display = raw if raw.startswith('**') else f'**{name_core}**'
        return f'!revenue_data_str!{display}!revenue_data_end!', name_core
    return cell, name_core


def pass_anomaly_table(lines):
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
                is_header = (
                    metric.replace('*', '').replace('!', '') == '指标' or metric == '指标'
                )
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


def pass2_monthly(lines):
    """月报：一 OKR(summary1 包裹编号说明) / 二 总结(summary1) / 三 下钻 / 四 异常。"""
    n = len(lines)
    sections = []
    i = 0
    while i < n:
        sec = C.section_of_heading(lines[i])
        if sec:
            start = i
            j = i + 1
            while j < n and not C.section_of_heading(lines[j]):
                j += 1
            sections.append((sec, start, j))
            i = j
        else:
            i += 1

    replacements = {}
    for sec_num, sec_start, sec_end in sections:
        if sec_num == '一':
            replacements[sec_start] = (
                sec_end,
                _wrap_okr_section(lines, sec_start, sec_end),
            )
        elif sec_num == '二':
            replacements[sec_start] = (
                sec_end,
                _wrap_summary_section(lines, sec_start, sec_end),
            )
        elif sec_num == '三':
            replacements[sec_start] = (
                sec_end,
                C._process_section_two(lines, sec_start, sec_end),
            )

    result = []
    i = 0
    while i < n:
        if i in replacements:
            end, repl_lines = replacements[i]
            result.extend(repl_lines)
            i = end
        else:
            result.append(lines[i])
            i += 1
    return result


def convert(text):
    lines = text.split('\n')
    lines = pass1(lines)
    lines = pass2_monthly(lines)
    lines = pass_anomaly_table(lines)
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(
        description='Convert monthly_report_v2.md → monthly_report_v2_converted.md',
    )
    parser.add_argument('-i', '--input', required=True, help='Source monthly_report_v2.md')
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
    print(
        'converted: {} -> {}'.format(
            os.path.basename(input_file), os.path.basename(output_file)
        )
    )


if __name__ == '__main__':
    main()

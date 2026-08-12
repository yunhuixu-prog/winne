#!/usr/bin/env python3
"""Convert case Markdown files to match format_require.md specifications.

Two-pass converter:
  Pass1: content transformation (title, sections, knowledge fields, tree->mermaid, table sep)
  Pass2: identifier marker insertion + section-two reordering

Design: constants configurable at top; no hardcoded business text.
"""
import re
import os

# ============================================================
# Configurable constants
# ============================================================

# --- Title & Date ---
TITLE_DATE_8DIGIT = re.compile(r'(20\d{2})(\d{2})(\d{2})_(20\d{2})(\d{2})(\d{2})')
TITLE_DATE_BRACKET = re.compile(
    r'[\(（]\s*(20\d{2})[-/.]?(\d{2})[-/.]?(\d{2})\s*[至到~\-—_]+\s*(20\d{2})?[-/.]?(\d{2})[-/.]?(\d{2})\s*[\)）]')
TITLE_DATE_ISO = re.compile(r'(20\d{2})\s*[-_]?\s*w(\d{1,2})', re.I)
TITLE_OUTPUT_FMT = '# 周报（{s} 至 {e}）'
DATE_OUTPUT_FMT = '{y}-{m}-{d}'

# --- Section headings ---
TOP_SECTION_RE = re.compile(r'^#{1,6}\s*([一二三四五六七八九十])、\s*(.+?)\s*$')
SECTION_LEVEL = {'一': '#', '二': '#', '三': '#'}
SECTION_HEADING_FMT = '{level} {num}、{text}'

# --- Metric sub-headings (### N. xxx -> ## xxx, only in section 二) ---
METRIC_HEADING_RE = re.compile(r'^###\s+\d+\s*[\.、]\s*(.+?)\s*$')
METRIC_HEADING_FMT = '## {name}'

# --- Knowledge base event fields ---
KNOWLEDGE_BLOCK_MARKER = '知识库命中事件'
KNOWLEDGE_EVENT_LINE_RE = re.compile(r'^>\s*-\s+(.+?)\s*$')
KNOWLEDGE_LABEL_SRC = '出处：'
KNOWLEDGE_LABEL_REASON = '命中原因：'
KNOWLEDGE_LABEL_DESC = '事件描述：'
KNOWLEDGE_LABEL_REL = '关联度：'
KNOWLEDGE_SENTENCE_END = '。'
KNOWLEDGE_FIELD_RE = re.compile(r'(出处|命中原因|事件描述|关联度)\s*[：:]\s*')
KNOWLEDGE_FIELD_KEYS = ('出处', '命中原因', '事件描述', '关联度')

# --- ASCII tree -> mermaid ---
TREE_SECTION_RE = re.compile(r'^\*{0,2}\s*(维度下钻|关联下钻)')
TREE_LINE_RE = re.compile(r'^([│|\s]*)([├└])──\s+(.+?)\s*$')
TREE_INDENT_WIDTH = 4
TREE_REVERSE_MARK = '*反向提拉*'
TREE_NAME_SEP = '，'
TREE_HUANBI_RE = re.compile(r'环比\s*(-?[\d,.]+%)')
TREE_CONTRIB_RE = re.compile(r'[（(](?:贡献)?占比\s*(-?[\d,.]+%)\s*[）)]')
HTML_SPAN_RE = re.compile(r'\s*<span[^>]*>.*?</span>')
ASSO_DRILL_ROOT_RE = re.compile(r'关联下钻[：:]\s*(.+?)\s*=')
TREE_NODE_LABEL_FMT = '{name} {contrib}'
MERMAID_DIRECTION = 'LR'
MERMAID_NODE_FMT = '    N{idx}["{label}"]'
MERMAID_EDGE_FMT = '    N{a} --> N{b}'

# --- Tables ---
TABLE_LINE_PREFIX = '|'
TABLE_SEP_RE = re.compile(r'^\|[\s:|\-]+\|$')
TABLE_COLUMN_RENAMES = {'预警': '异常说明'}
TABLE_SEP_FIRST = '-------'
TABLE_SEP_OTHER = '-------'
WEEK_COL_RE = re.compile(r'(wk\d+|w\d+|^\d+周前|前\d+周|本周|上周|本月|上月)', re.I)

# --- Logic chain ---
LOGIC_CHAIN_ARROW = re.compile(r'-->|—>|->|→|➔|➡️')
LOGIC_CHAIN_LABEL_RE = re.compile(r'(逻辑链|因果链|因果链路|归因逻辑链|归因链|核心逻辑)')

# --- Summary2 marker detection ---
S2_SUMMARY_MARKER = '现象'

# --- Summary sentence (for 一) ---
SUMMARY_SENTENCE_END = re.compile(r'[。！？!?；;](?:[""\'』）)]+)?')
DAU_ALIASES = ['DAU', '日活', '活跃用户', '活跃']
REVENUE_ALIASES = ['订阅收入', '订阅营收', 'subscription revenue', '收入', '营收',
                   '整体收入', '总收入', '订阅&单购']
# --- Markers ---
M = {
    'summary1_s':     '!summary1_str!',
    'summary1_e':     '!summary1_end!',
    'summary2_s':     '!summary2_str!',
    'summary2_e':     '!summary2_end!',
    'logic_lib_s':     '!logic_lib_str!',
    'logic_lib_e':     '!logic_lib_end!',
    'logic_train_s':   '!logic_train_str!',
    'logic_train_e':   '!logic_train_end!',
    'tree_s':          '!tree_str!',
    'tree_e':          '!tree_end!',
    'trend_s':         '!trend_str!',
    'trend_e':         '!trend_end!',
    'dau_trend_s':     '!dau_trend_str!',
    'dau_trend_e':     '!dau_trend_end!',
    'revenue_trend_s': '!revenue_trend_str!',
    'revenue_trend_e': '!revenue_trend_end!',
    'dau_sum_s':       '!dau_summary_str!',
    'dau_sum_e':       '!dau_summary_end!',
    'rev_sum_s':       '!revenue_summary_str!',
    'rev_sum_e':       '!revenue_summary_end!',
}

# --- IO ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = os.path.join(SCRIPT_DIR, 'case1.md')
OUTPUT_FILE = os.path.join(SCRIPT_DIR, 'case1_converted.md')


# ============================================================
# Helpers
# ============================================================
def split_table_cells(line):
    parts = line.strip().split('|')
    if parts and parts[0] == '':
        parts = parts[1:]
    if parts and parts[-1] == '':
        parts = parts[:-1]
    return [c.strip() for c in parts]


def is_table_line(line):
    return line.lstrip().startswith(TABLE_LINE_PREFIX)


def is_blockquote(line):
    return line.lstrip().startswith('>')


def contains_any(text, aliases):
    return any(a in text for a in aliases)


def section_of_heading(line):
    m = TOP_SECTION_RE.match(line)
    return m.group(1) if m else None


def metric_of_heading(line):
    m = re.match(r'^##\s+(.+?)\s*$', line)
    return m.group(1).strip() if m else None


def is_section_two_metric(line):
    return metric_of_heading(line) is not None


def is_mermaid_start(line):
    return line.strip() == '```mermaid'


def is_mermaid_end(line):
    return line.strip() == '```'


def is_mermaid_block(lines, i):
    """Check if lines[i] is start of a mermaid fenced block."""
    return is_mermaid_start(lines[i])


# ============================================================
# Pass 1: content transformation
# ============================================================
def extract_date_from_title(line):
    """Try to extract a date range from a title line, return (start_str, end_str) or None."""
    m = TITLE_DATE_8DIGIT.search(line)
    if m:
        y1, m1, d1, y2, m2, d2 = m.groups()
        return DATE_OUTPUT_FMT.format(y=y1, m=m1, d=d1), DATE_OUTPUT_FMT.format(y=y2, m=m2, d=d2)
    m = TITLE_DATE_BRACKET.search(line)
    if m:
        y1, m1, d1, y2_maybe, m2, d2 = m.groups()
        y2 = y2_maybe or y1
        return DATE_OUTPUT_FMT.format(y=y1, m=m1, d=d1), DATE_OUTPUT_FMT.format(y=y2, m=m2, d=d2)
    m = TITLE_DATE_ISO.search(line)
    if m:
        year, wk = m.groups()
        return '{}-W{}'.format(year, wk.zfill(2)), None
    return None


def transform_title(line):
    dates = extract_date_from_title(line)
    if not dates:
        return line
    s, e = dates
    if e is None:
        return line
    return TITLE_OUTPUT_FMT.format(s=s, e=e)


def transform_top_section(num, text):
    level = SECTION_LEVEL.get(num, '#')
    return SECTION_HEADING_FMT.format(level=level, num=num, text=text)


def normalize_knowledge_event(text):
    """Ensure event line has 事件 + 出处/命中原因/事件描述/关联度.

    Preferred shape (leading 事件名 has no label):
      {事件}，出处：…，命中原因：…，事件描述：…，关联度：…
    """
    has_src = KNOWLEDGE_LABEL_SRC in text
    has_reason = KNOWLEDGE_LABEL_REASON in text
    has_desc = KNOWLEDGE_LABEL_DESC in text
    has_rel = KNOWLEDGE_LABEL_REL in text

    if has_reason and not has_desc:
        idx = text.index(KNOWLEDGE_LABEL_REASON)
        dot = text.find(KNOWLEDGE_SENTENCE_END, idx)
        if dot != -1:
            text = text[:dot + 1] + KNOWLEDGE_LABEL_DESC + text[dot + 1:]
        else:
            text = text + KNOWLEDGE_LABEL_DESC
        has_desc = True

    if not has_reason:
        suffix = ''
        if not has_src:
            suffix += KNOWLEDGE_LABEL_SRC + KNOWLEDGE_SENTENCE_END
        suffix += KNOWLEDGE_LABEL_REASON + KNOWLEDGE_SENTENCE_END + KNOWLEDGE_LABEL_DESC
        text = text + suffix
        has_desc = True

    if not has_rel and KNOWLEDGE_LABEL_REL not in text:
        text = text.rstrip('，,') + '，' + KNOWLEDGE_LABEL_REL

    return text


def parse_tree_node(raw):
    is_reverse = TREE_REVERSE_MARK in raw
    clean = raw.replace(TREE_REVERSE_MARK, '').strip()
    name = clean.split(TREE_NAME_SEP, 1)[0].strip()
    contrib = TREE_CONTRIB_RE.search(clean)
    if contrib:
        label = TREE_NODE_LABEL_FMT.format(name=name, contrib=contrib.group(1))
    else:
        label = name
    return label, is_reverse


def build_mermaid(root_label, tree_rows):
    """tree_rows: [(depth, raw_text)], root_label is root node name."""
    clean_root = HTML_SPAN_RE.sub('', root_label).strip()
    nodes = [clean_root]
    edges = []
    last_at_depth = {-1: 0}

    for depth, raw in tree_rows:
        label, is_reverse = parse_tree_node(raw)
        idx = len(nodes)
        nodes.append(label)
        parent_idx = last_at_depth.get(depth - 1, 0)
        edges.append((parent_idx, idx, is_reverse))
        last_at_depth[depth] = idx
        for d in [k for k in last_at_depth if k > depth]:
            del last_at_depth[d]

    out = ['```mermaid', 'flowchart {}'.format(MERMAID_DIRECTION)]
    for i, label in enumerate(nodes):
        out.append(MERMAID_NODE_FMT.format(idx=i, label=label))
    out.append('')
    for a, b, rev in edges:
        out.append(MERMAID_EDGE_FMT.format(a=a, b=b))
    out.append('```')
    return out


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

        if in_knowledge and not is_blockquote(line):
            in_knowledge = False

        # 1) Title
        if not title_done and line.startswith('# ') and extract_date_from_title(line):
            out.append(transform_title(line))
            title_done = True
            i += 1
            continue

        # 2) Top section
        m_sec = TOP_SECTION_RE.match(line)
        if m_sec:
            num, text = m_sec.group(1), m_sec.group(2)
            out.append(transform_top_section(num, text))
            top_section = num
            current_metric = None
            in_knowledge = False
            i += 1
            continue

        # 3) Metric sub-heading (### N. xxx -> ## xxx, only in 二)
        m_metric = METRIC_HEADING_RE.match(line)
        if m_metric and top_section == '二':
            current_metric = m_metric.group(1).strip()
            out.append(METRIC_HEADING_FMT.format(name=current_metric))
            i += 1
            continue

        # Also catch ## xxx headings to track current metric
        m_h2 = re.match(r'^##\s+(.+?)\s*$', line)
        if m_h2 and top_section == '二':
            current_metric = m_h2.group(1).strip()

        # 4) Knowledge base event block (field normalization only)
        if KNOWLEDGE_BLOCK_MARKER in line and is_blockquote(line):
            in_knowledge = True
            out.append(line)
            i += 1
            continue
        if in_knowledge:
            m_evt = KNOWLEDGE_EVENT_LINE_RE.match(line)
            if m_evt:
                fixed = normalize_knowledge_event(m_evt.group(1))
                out.append('> - ' + fixed)
                i += 1
                continue

        # 5) ASCII tree -> mermaid
        # Check if current line or upcoming line is a tree section marker
        is_tree_marker = bool(TREE_SECTION_RE.match(stripped))
        if is_tree_marker:
            tree_rows = []
            j = i + 1
            while j < n:
                tline = lines[j].rstrip('\n')
                tm = TREE_LINE_RE.match(tline)
                if not tm:
                    break
                depth = len(tm.group(1)) // TREE_INDENT_WIDTH
                tree_rows.append((depth, tm.group(3)))
                j += 1
            if tree_rows:
                out.append(stripped)
                out.append('')
                root_label = current_metric or ''
                m_assoc = ASSO_DRILL_ROOT_RE.search(stripped)
                if m_assoc:
                    root_label = m_assoc.group(1).strip()
                out.extend(build_mermaid(root_label, tree_rows))
                i = j
                continue

        # 6) Table separator alignment / header column rename
        if is_table_line(line):
            if TABLE_SEP_RE.match(line.strip()):
                ncol = len(split_table_cells(line))
                cells = [TABLE_SEP_FIRST if k == 0 else TABLE_SEP_OTHER for k in range(ncol)]
                out.append('|' + '|'.join(cells) + '|')
            elif any(k in line for k in TABLE_COLUMN_RENAMES):
                cells = split_table_cells(line)
                cells = [TABLE_COLUMN_RENAMES.get(c, c) for c in cells]
                out.append('|' + '|'.join(cells) + '|')
            else:
                out.append(line)
            i += 1
            continue

        out.append(line)
        i += 1

    return out


# ============================================================
# Pass 2: marker insertion + section-two reordering
# ============================================================

def _find_summary_sentence(aliases, lines):
    """Find first sentence containing any alias in a list of lines, return (line_idx, start_pos, end_pos)."""
    for li, line in enumerate(lines):
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        if not contains_any(stripped, aliases):
            continue
        m = SUMMARY_SENTENCE_END.search(stripped)
        if m:
            end = m.end()
            sentence = stripped[:end]
            if contains_any(sentence, aliases):
                start = len(line) - len(line.lstrip())
                return li, start, start + end
    return None


def _latest_col_max(table_lines):
    """Return max numeric value in the rightmost data column of a trend table.

    Parses table cells, finds the rightmost column with data in any row,
    extracts numeric values from data rows in that column, returns the max.
    Used to compare multiple trend tables and pick the one with the largest
    latest-period indicator value.
    """
    if len(table_lines) < 3:
        return 0.0
    rows = []
    for i, ln in enumerate(table_lines):
        cells = split_table_cells(ln)
        if i == 0 or (i == 1 and TABLE_SEP_RE.match(ln.strip())):
            rows.append(cells)
            continue
        rows.append(cells)
    if len(rows) < 2:
        return 0.0

    col_count = max(len(r) for r in rows) if rows else 0
    if col_count < 2:
        return 0.0

    best = 0.0
    for row in rows[1:]:
        if len(row) <= 1:
            continue
        for ci in range(len(row) - 1, 0, -1):
            val = row[ci].strip().replace(',', '')
            try:
                num = float(val)
            except (ValueError, TypeError):
                continue
            if num > best:
                best = num
            break
    return best


def _is_feature_compare_table(header_cells):
    """Tables like §2.9 功能进入 UV / 功能保存率 Top5 — keep in post, do not compete as trends.

    Their first column is「功能」and they often also contain week columns; if treated as
    trends, `_pick_best_trends` drops them when a core metric table shares category None.
    """
    if not header_cells:
        return False
    first = header_cells[0].replace('**', '').strip()
    if first in ('功能', '功能名'):
        return True
    # explicit absolute-delta column from weekly 2.9 feature enter-UV tables
    if any('绝对值波动' in (h or '') for h in header_cells):
        return True
    return False


def _classify_trend_table(lines_slice):
    """Classify a trend table as 'dau', 'revenue', or None based on content."""
    text = '\n'.join(lines_slice)
    is_dau = any(a in text for a in DAU_ALIASES)
    is_rev = any(a in text for a in REVENUE_ALIASES)
    if is_dau and not is_rev:
        return 'dau'
    if is_rev and not is_dau:
        return 'revenue'
    if is_dau and is_rev:
        return 'dau'
    return None


TREND_CLASS_MAP = {
    'dau': ('dau_trend_s', 'dau_trend_e'),
    'revenue': ('revenue_trend_s', 'revenue_trend_e'),
    None: ('trend_s', 'trend_e'),
}


def _pick_best_trends(trends):
    """From a list of (category, table_lines) tuples, pick the best for each category.

    'Best' is the table with the largest max value in the latest (rightmost) data column.
    Returns dict: {category: table_lines} with at most one entry per category.
    """
    groups = {}
    for category, lines_slice in trends:
        groups.setdefault(category, []).append(lines_slice)
    result = {}
    for category, candidates in groups.items():
        best_lines = None
        best_val = -1.0
        for lines_slice in candidates:
            val = _latest_col_max(lines_slice)
            if val > best_val:
                best_val = val
                best_lines = lines_slice
        result[category] = best_lines
    return result


def _find_blockquote_range(lines, start):
    """Return (start, end) of a consecutive blockquote block starting at `start`."""
    j = start
    while j < len(lines) and is_blockquote(lines[j]):
        j += 1
    return start, j


def _find_table_range(lines, start):
    """Return (start, end) of a consecutive table block starting at `start`."""
    j = start
    while j < len(lines) and is_table_line(lines[j]):
        j += 1
    return start, j


def _find_mermaid_range(lines, start):
    """Return (start, end) of a mermaid fenced block starting at `start`. end is exclusive."""
    if not is_mermaid_start(lines[start]):
        return start, start
    j = start + 1
    while j < len(lines):
        if is_mermaid_end(lines[j]):
            return start, j + 1
        j += 1
    return start, start


def _classify_blockquote(lines_slice):
    """Classify a blockquote block: 'knowledge', 'logic', 'drilldown', or 'normal'."""
    text = '\n'.join(lines_slice)
    if KNOWLEDGE_BLOCK_MARKER in text:
        return 'knowledge'
    if LOGIC_CHAIN_LABEL_RE.search(text) and LOGIC_CHAIN_ARROW.search(text):
        return 'logic'
    if '下钻总结' in text:
        return 'drilldown'
    return 'normal'


def _extract_summary2_from_pre(pre_lines):
    """Extract summary2 content (现象+analysis) from pre lines."""
    for i, line in enumerate(pre_lines):
        if S2_SUMMARY_MARKER in line:
            return pre_lines[:i], pre_lines[i:]
    return pre_lines, None


def _scan_metric_section(lines_slice):
    """
    Scan lines of one ## metric subsection in section 二.
    Returns dict with keys: 'pre' (lines before any block), 'summary2', 'knowledge', 'logic', 'trends', 'trees', 'post'.
    trends is a list of (category, lines_slice) tuples from _classify_trend_table.
    trees is a list of (marker_line_or_None, [mermaid_lines]). Each tree gets its own !tree_str!/!tree_end! pair.
    """
    result = {'pre': [], 'summary2': None, 'knowledge': None, 'logic': None, 'trends': [], 'trees': [], 'post': []}
    i = 0
    n = len(lines_slice)

    # Phase 1: collect pre-content (up to first blockquote/table/mermaid)
    while i < n:
        line = lines_slice[i]
        if is_mermaid_start(line):
            break
        if is_blockquote(line):
            break
        if is_table_line(line):
            break
        result['pre'].append(line)
        i += 1

    # Phase 2: process remaining blocks
    while i < n:
        line = lines_slice[i]
        if is_mermaid_start(line):
            s, e = _find_mermaid_range(lines_slice, i)
            result['trees'].append((None, lines_slice[s:e]))
            i = e
            continue
        if is_blockquote(line):
            s, e = _find_blockquote_range(lines_slice, i)
            btype = _classify_blockquote(lines_slice[s:e])
            if btype == 'knowledge':
                result['knowledge'] = lines_slice[s:e]
            elif btype == 'logic':
                result['logic'] = lines_slice[s:e]
            elif btype == 'drilldown':
                result['summary2' if not result['summary2'] else 'post'].extend(lines_slice[s:e])
            else:
                result['pre'].extend(lines_slice[s:e])
            i = e
            continue
        if is_table_line(line):
            s, e = _find_table_range(lines_slice, i)
            header = split_table_cells(lines_slice[s])
            week_count = sum(1 for h in header[1:] if WEEK_COL_RE.search(h))
            has_desc = any('异常说明' in h or '异常详情' in h for h in header)
            if week_count >= 3 and not has_desc and not _is_feature_compare_table(header):
                category = _classify_trend_table(lines_slice[s:e])
                result['trends'].append((category, lines_slice[s:e]))
            else:
                result['post'].extend(lines_slice[s:e])
            i = e
            continue
        # Check for **维度下钻** or **关联下钻** tree markers (already converted to mermaid in pass1)
        stripped = line.strip()
        if TREE_SECTION_RE.match(stripped):
            marker_line = line
            i += 1
            if i < n and is_mermaid_start(lines_slice[i]):
                s, e = _find_mermaid_range(lines_slice, i)
                result['trees'].append((marker_line, lines_slice[s:e]))
                i = e
            else:
                result['post'].append(marker_line)
            continue
        result['post'].append(line)
        i += 1

    result['pre'], result['summary2'] = _extract_summary2_from_pre(result['pre'])
    return result


def _reorder_metric_section(scanned, winning_categories=None):
    """
    Reassemble lines in canonical order: pre -> summary2 -> knowledge -> logic -> trend -> tree -> post.
    Wraps each recognized block with its marker pair.

    winning_categories: set of categories ('dau', 'revenue') that won the document-level
    competition. Only winning trend tables get category-specific markers; others get
    generic !trend_str!/!trend_end!.
    """
    if winning_categories is None:
        winning_categories = set()
    out = []
    out.extend(scanned['pre'])

    if scanned['summary2']:
        out.append(M['summary2_s'])
        out.extend(scanned['summary2'])
        out.append(M['summary2_e'])

    if scanned['knowledge']:
        out.append(M['logic_lib_s'])
        out.extend(scanned['knowledge'])
        out.append(M['logic_lib_e'])

    if scanned['logic']:
        out.append(M['logic_train_s'])
        out.extend(scanned['logic'])
        out.append(M['logic_train_e'])

    if scanned.get('trends'):
        best = _pick_best_trends(scanned['trends'])
        for category in ['dau', 'revenue', None]:
            if category in best:
                effective = category if category in winning_categories else None
                s_key, e_key = TREND_CLASS_MAP[effective]
                out.append(M[s_key])
                out.extend(best[category])
                out.append(M[e_key])

    if scanned['trees']:
        for marker_line, mermaid_lines in scanned['trees']:
            if marker_line is not None:
                out.append(marker_line)
            out.append(M['tree_s'])
            out.extend(mermaid_lines)
            out.append(M['tree_e'])

    out.extend(scanned['post'])
    return out


def _process_section_two(lines, start, end):
    """
    Process section 二 (lines[start:end]).

    Two-phase approach for dau_trend / revenue_trend (document-level, at most 1 each):
      Phase 1: scan all ## subsections to find which one holds the globally best
               DAU trend table and which holds the globally best revenue trend table.
      Phase 2: reorder each subsection; only the winning subsection may use
               !dau_trend_str!/!dau_trend_end! or !revenue_trend_str!/!revenue_trend_end!;
               non-winning DAU/revenue trend tables and other trend tables use
               generic !trend_str!/!trend_end!.
    Returns list of output lines.
    """
    subsections = []
    i = start
    n = end
    while i < n:
        line = lines[i]
        if metric_of_heading(line):
            sub_start = i
            j = i + 1
            while j < n and not metric_of_heading(lines[j]) and not section_of_heading(lines[j]):
                j += 1
            sub_end = j
            subsections.append((sub_start, sub_end))
            i = sub_end
        else:
            i += 1

    # Phase 1: gather all DAU/revenue trend candidates across subsections
    global_dau_best = (-1.0, -1)
    global_rev_best = (-1.0, -1)
    for idx, (sub_start, sub_end) in enumerate(subsections):
        scanned = _scan_metric_section(lines[sub_start:sub_end])
        for category, table_lines in scanned.get('trends', []):
            if category == 'dau':
                val = _latest_col_max(table_lines)
                if val > global_dau_best[0]:
                    global_dau_best = (val, idx)
            elif category == 'revenue':
                val = _latest_col_max(table_lines)
                if val > global_rev_best[0]:
                    global_rev_best = (val, idx)

    winning_sub_indices = set()
    winning_categories_by_sub = {}
    for cat, info in [('dau', global_dau_best), ('revenue', global_rev_best)]:
        sub_idx = info[1]
        if sub_idx >= 0:
            winning_sub_indices.add(sub_idx)
            winning_categories_by_sub.setdefault(sub_idx, set()).add(cat)

    # Phase 2: reorder each subsection
    out = []
    i = start
    sub_idx = 0
    while i < n:
        line = lines[i]
        if metric_of_heading(line):
            sub_start, sub_end = subsections[sub_idx]
            scanned = _scan_metric_section(lines[sub_start:sub_end])
            wc = winning_categories_by_sub.get(sub_idx, set())
            out.extend(_reorder_metric_section(scanned, winning_categories=wc))
            i = sub_end
            sub_idx += 1
            continue
        out.append(line)
        i += 1

    return out


def _wrap_summary_section(lines, start, end):
    """Wrap DAU and Revenue summary sentences in section 一, entire section with summary1."""
    out = list(lines)
    # DAU summary
    dau_info = _find_summary_sentence(DAU_ALIASES, lines[start:end])
    if dau_info:
        li, sp, ep = dau_info
        actual_li = start + li
        line = out[actual_li]
        out[actual_li] = (line[:sp] + M['dau_sum_s'] + line[sp:ep] + M['dau_sum_e'] + line[ep:])
    # Revenue summary
    rev_info = _find_summary_sentence(REVENUE_ALIASES, lines[start:end])
    if rev_info:
        li, sp, ep = rev_info
        actual_li = start + li
        line = out[actual_li]
        # Avoid double-wrapping if same line
        if M['dau_sum_s'] in line:
            # Find position after dau_sum_e
            idx = line.find(M['dau_sum_e'])
            if idx != -1:
                after = idx + len(M['dau_sum_e'])
                if sp >= after:
                    out[actual_li] = (line[:sp] + M['rev_sum_s'] + line[sp:ep] + M['rev_sum_e'] + line[ep:])
        else:
            out[actual_li] = (line[:sp] + M['rev_sum_s'] + line[sp:ep] + M['rev_sum_e'] + line[ep:])
    # Insert summary1 markers around section content (after heading line, before end)
    result = [out[start]]
    result.append('')
    result.append(M['summary1_s'])
    result.extend(out[start + 1:end])
    result.append(M['summary1_e'])
    return result


def pass2(lines):
    """Insert marker pairs; reorder section 二 blocks to canonical order."""
    n = len(lines)
    # First pass: identify section boundaries
    sections = []  # [(num, start, end)] end exclusive
    i = 0
    while i < n:
        sec = section_of_heading(lines[i])
        if sec:
            start = i
            j = i + 1
            while j < n and not section_of_heading(lines[j]):
                j += 1
            sections.append((sec, start, j))
            i = j
        else:
            i += 1

    # Process each section
    out = list(lines)
    # We'll build output by processing sections and replacing their ranges
    replacements = {}  # start -> list of replacement lines

    for sec_num, sec_start, sec_end in sections:
        if sec_num == '一':
            replacements[sec_start] = (sec_end, _wrap_summary_section(lines, sec_start, sec_end))
        elif sec_num == '二':
            replacements[sec_start] = (sec_end, _process_section_two(lines, sec_start, sec_end))

    # Assemble final output in order
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


# ============================================================
# Main
# ============================================================
def convert(text):
    lines = text.split('\n')
    lines = pass1(lines)
    lines = pass2(lines)
    return '\n'.join(lines)


def main():
    if not os.path.exists(INPUT_FILE):
        print('Input file not found: {}'.format(INPUT_FILE))
        print('Usage: set INPUT_FILE to the source markdown, then run.')
        return
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        src = f.read()
    result = convert(src)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(result)
    print('converted: {} -> {}'.format(
        os.path.basename(INPUT_FILE), os.path.basename(OUTPUT_FILE)))


if __name__ == '__main__':
    main()

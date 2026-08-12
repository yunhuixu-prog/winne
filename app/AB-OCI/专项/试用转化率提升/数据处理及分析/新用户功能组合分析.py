"""
3天内新用户功能分析

输入: 试用用户分析.csv
输出:
  - 新用户_单功能使用占比及付费率.csv
  - 新用户_双功能使用占比及付费率.csv
  - 新用户_三功能使用占比及付费率.csv
  - 新用户_功能漏斗_付费未付费.csv
  - 新用户_双功能漏斗_付费未付费.csv

功能组合计数规则:
  - 用户使用了 N 个功能，则单功能下 N 个功能各计 1 次
  - 双功能下计 C(N,2) 个组合，三功能下计 C(N,3) 个组合
  - 仅保留使用占比 > 5% 的项，按使用占比从高到低排序

功能漏斗规则（单功能/双功能，最终付费与最终未付费分列展示）:
  - 用户进入/打勾/保存了 N 个功能，双功能下各阶段均计 C(N,2) 个组合
  - 进入人数占比 = 进入该（组合）人数 / 该群组总人数
  - 进入到打勾转化率 = 进入且打勾人数 / 进入人数
  - 打勾到保存转化率 = 打勾且保存人数 / 打勾人数
  - 双功能漏斗仅保留任一侧进入人数占比 > 5%
"""

import pandas as pd
import numpy as np
from itertools import combinations
from collections import defaultdict
from pathlib import Path

# ---------------------------------------------------------------------------
# 配置
# ---------------------------------------------------------------------------
INPUT_CSV = '试用用户分析.csv'
USER_TYPE = '3天内新用户'
MIN_PCT = 0.05

OUTPUT_SINGLE = '新用户_单功能使用占比及付费率.csv'
OUTPUT_PAIR = '新用户_双功能使用占比及付费率.csv'
OUTPUT_TRIPLE = '新用户_三功能使用占比及付费率.csv'
OUTPUT_FUNNEL = '新用户_功能漏斗_付费未付费.csv'
OUTPUT_PAIR_FUNNEL = '新用户_双功能漏斗_付费未付费.csv'

FUNNEL_STATUS = [('最终付费', 1), ('最终未付费', 0)]
FUNNEL_METRICS = ['进入人数', '进入人数占比', '进入到打勾转化率', '打勾到保存转化率']


# ---------------------------------------------------------------------------
# 工具函数
# ---------------------------------------------------------------------------
def parse_funcs(val):
    if pd.isna(val) or str(val).strip() in ('', '\\N', 'nan'):
        return set()
    return {f.strip() for f in str(val).split(',') if f.strip() and f.strip() != '\\N'}


def load_new_users(csv_path):
    df = pd.read_csv(csv_path)
    users = df[df['user_type'].str.contains(USER_TYPE, na=False)].copy()
    users['enter_funcs'] = users['enter_func_list'].apply(parse_funcs)
    users['use_funcs'] = users['use_func_list'].apply(parse_funcs)
    users['save_funcs'] = users['save_func_list'].apply(parse_funcs)
    return users


def build_stats(users):
    """统计单/双/三功能的使用人数与付费人数。"""
    total = len(users)
    single = defaultdict(lambda: {'n': 0, 'paid': 0})
    pair = defaultdict(lambda: {'n': 0, 'paid': 0})
    triple = defaultdict(lambda: {'n': 0, 'paid': 0})

    for _, row in users.iterrows():
        funcs = sorted(row['use_funcs'])
        is_paid = row['is_paid']

        for f in funcs:
            single[f]['n'] += 1
            single[f]['paid'] += is_paid

        if len(funcs) >= 2:
            for combo in combinations(funcs, 2):
                key = f'{combo[0]} + {combo[1]}'
                pair[key]['n'] += 1
                pair[key]['paid'] += is_paid

        if len(funcs) >= 3:
            for combo in combinations(funcs, 3):
                key = f'{combo[0]} + {combo[1]} + {combo[2]}'
                triple[key]['n'] += 1
                triple[key]['paid'] += is_paid

    return total, single, pair, triple


def to_dataframe(stats_dict, total, label_col='功能'):
    rows = []
    for name, d in stats_dict.items():
        pct = d['n'] / total
        if pct <= MIN_PCT:
            continue
        rows.append({
            label_col: name,
            '使用人数': d['n'],
            '使用占比': pct,
            '付费人数': int(d['paid']),
            '付费率': d['paid'] / d['n'] if d['n'] > 0 else 0,
        })
    out = pd.DataFrame(rows)
    if out.empty:
        return out
    return out.sort_values('使用占比', ascending=False).reset_index(drop=True)


def export_csv(df, path, pct_cols=None):
    out = df.copy()
    if pct_cols is None:
        pct_cols = ['使用占比', '付费率']
    for c in pct_cols:
        if c in out.columns:
            out[c] = out[c].map('{:.2%}'.format)
    out.to_csv(path, index=False, encoding='utf-8-sig')
    print(f'  已输出: {path} ({len(df)} 行)')


def _build_funnel_long(users, mode='single'):
    """长表：按最终付费/最终未付费分别统计漏斗指标。"""
    label_col = '功能' if mode == 'single' else '功能组合'
    rows = []

    for paid_label, paid_val in FUNNEL_STATUS:
        grp = users[users['is_paid'] == paid_val]
        if len(grp) == 0:
            continue

        if mode == 'single':
            total, stats = _count_funnel_single(grp)
        else:
            total, stats = _count_funnel_pairs(grp)

        for name, d in stats.items():
            enter_n, use_n = d['enter'], d['use']
            if enter_n == 0 and use_n == 0:
                continue
            rows.append({
                '付费状态': paid_label,
                label_col: name,
                '进入人数': enter_n,
                '进入人数占比': enter_n / total,
                '进入到打勾转化率': d['enter_use'] / enter_n if enter_n > 0 else float('nan'),
                '打勾到保存转化率': d['use_save'] / use_n if use_n > 0 else float('nan'),
            })

    return pd.DataFrame(rows)


def pivot_funnel_wide(long_df, label_col, min_enter_pct=0):
    """宽表：最终付费 / 最终未付费 指标分列展示。"""
    if long_df.empty:
        return long_df

    wide = long_df.pivot(index=label_col, columns='付费状态', values=FUNNEL_METRICS)
    wide.columns = [f'{status}_{metric}' for metric, status in wide.columns]
    wide = wide.reset_index()

    col_order = [label_col]
    for status, _ in FUNNEL_STATUS:
        for metric in FUNNEL_METRICS:
            col = f'{status}_{metric}'
            if col in wide.columns:
                col_order.append(col)
    wide = wide[col_order]

    if min_enter_pct > 0:
        pct_cols = [c for c in wide.columns if c.endswith('_进入人数占比')]
        mask = pd.Series(False, index=wide.index)
        for c in pct_cols:
            mask |= wide[c].fillna(0) > min_enter_pct
        wide = wide[mask]

    sort_col = (
        '最终付费_进入人数占比'
        if '最终付费_进入人数占比' in wide.columns
        else wide.columns[1]
    )
    return wide.sort_values(sort_col, ascending=False, na_position='last').reset_index(drop=True)


def build_funnel(users, mode='single', min_enter_pct=0):
    label_col = '功能' if mode == 'single' else '功能组合'
    long_df = _build_funnel_long(users, mode=mode)
    return pivot_funnel_wide(long_df, label_col, min_enter_pct=min_enter_pct)


def _count_funnel_single(grp):
    total = len(grp)
    stats = defaultdict(lambda: {'enter': 0, 'enter_use': 0, 'use': 0, 'use_save': 0})
    for enter, use, save in zip(grp['enter_funcs'], grp['use_funcs'], grp['save_funcs']):
        all_funcs = enter | use | save
        for func in all_funcs:
            entered, used, saved = func in enter, func in use, func in save
            if entered:
                stats[func]['enter'] += 1
                if used:
                    stats[func]['enter_use'] += 1
            if used:
                stats[func]['use'] += 1
                if saved:
                    stats[func]['use_save'] += 1
    return total, stats


def _count_funnel_pairs(grp):
    total = len(grp)
    stats = defaultdict(lambda: {'enter': 0, 'enter_use': 0, 'use': 0, 'use_save': 0})
    for enter, use, save in zip(grp['enter_funcs'], grp['use_funcs'], grp['save_funcs']):
        for a, b in combinations(sorted(enter), 2):
            key = f'{a} + {b}'
            stats[key]['enter'] += 1
            if a in use and b in use:
                stats[key]['enter_use'] += 1
        for a, b in combinations(sorted(use), 2):
            key = f'{a} + {b}'
            stats[key]['use'] += 1
            if a in save and b in save:
                stats[key]['use_save'] += 1
    return total, stats


def _print_funnel_top(df, label_col, n=5):
    if df.empty:
        return
    sort_col = '最终付费_进入人数占比' if '最终付费_进入人数占比' in df.columns else df.columns[1]
    for _, r in df.sort_values(sort_col, ascending=False).head(n).iterrows():
        paid_pct = r.get('最终付费_进入人数占比', np.nan)
        unpaid_pct = r.get('最终未付费_进入人数占比', np.nan)
        paid_txt = f'{paid_pct:.1%}' if pd.notna(paid_pct) else '-'
        unpaid_txt = f'{unpaid_pct:.1%}' if pd.notna(unpaid_pct) else '-'
        print(f"  {str(r[label_col]):30s} 付费进入={paid_txt} 未付费进入={unpaid_txt}")


# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------
def main():
    base_dir = Path(__file__).parent
    csv_path = base_dir / INPUT_CSV
    print(f'读取: {csv_path}')

    users = load_new_users(csv_path)
    total = len(users)
    base_paid = users['is_paid'].mean()
    print(f'{USER_TYPE}: {total} 人, 基准付费率 {base_paid:.2%}')
    print(f'筛选条件: 使用占比 > {MIN_PCT:.0%}\n')

    total, single, pair, triple = build_stats(users)

    single_df = to_dataframe(single, total, '功能')
    pair_df = to_dataframe(pair, total, '功能组合')
    triple_df = to_dataframe(triple, total, '功能组合')

    export_csv(single_df, base_dir / OUTPUT_SINGLE)
    export_csv(pair_df, base_dir / OUTPUT_PAIR)
    export_csv(triple_df, base_dir / OUTPUT_TRIPLE)

    funnel_pct_cols = [
        c for c in FUNNEL_METRICS if c != '进入人数'
    ]
    funnel_export_pct_cols = [
        f'{status}_{metric}'
        for status, _ in FUNNEL_STATUS
        for metric in funnel_pct_cols
    ]

    # 单功能漏斗
    print('\n--- 单功能漏斗（宽表）---')
    funnel_df = build_funnel(users, mode='single')
    export_csv(funnel_df, base_dir / OUTPUT_FUNNEL, funnel_export_pct_cols)
    _print_funnel_top(funnel_df, '功能')

    # 双功能漏斗
    print('\n--- 双功能漏斗（宽表，任一侧进入占比>5%）---')
    pair_funnel_df = build_funnel(users, mode='pair', min_enter_pct=MIN_PCT)
    export_csv(pair_funnel_df, base_dir / OUTPUT_PAIR_FUNNEL, funnel_export_pct_cols)
    _print_funnel_top(pair_funnel_df, '功能组合')

    for title, df in [('单功能', single_df), ('双功能', pair_df), ('三功能', triple_df)]:
        print(f'\n{title} Top5:')
        if df.empty:
            print('  (无满足条件的项)')
            continue
        for _, r in df.head(5).iterrows():
            name = r.get('功能') or r.get('功能组合')
            print(f'  {name}: 占比={r["使用占比"]:.1%}, 付费率={r["付费率"]:.1%}')

    print('\n处理完成。')


if __name__ == '__main__':
    main()

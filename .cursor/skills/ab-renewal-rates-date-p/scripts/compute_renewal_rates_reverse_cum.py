#!/usr/bin/env python3
"""
从神舟宽表按「最新可观测 cohort 起、逐日向更早累积」计算最新续费率。

规则（分 country × os × period_type × 续费期 k）：
  1) 截至日 date_p（与 SQL 分区一致，通常为系统日前一天）。
  2) 首期锚点 pay_date = date_p 向前推 k 个订阅周期（月=整月、周=7天、年=整年）。
     例：date_p=5.17、月订、k=1 → 从 4.17 起算。
  3) 从锚点日起按日历逐日向更早遍历；若该 pay_date 有明细行且第 k 期可观测，则累加 num_k、num_0。
  4) 当累计 num_k > min_orders（默认 1000）且纳入 pay_date 天数 > min_days（默认 365）时停止。
  5) 若任一条件未满足：从锚点日起纳入该分组内全部可观测 cohort，直至最早 pay_date。
  6) 续费率 = sum(num_k) / sum(num_0)。

输出长表含：累积订单量、是否达到门槛、纳入计算的 pay_date 范围与天数。
"""

from __future__ import annotations

import argparse
import calendar
import csv
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Dict, FrozenSet, List, Optional, Sequence, Tuple

from compute_renewal_rates import (
    NUM_COLS,
    Row,
    invocation_folder_name,
    parse_date_arg,
    parse_pay_date,
    read_rows,
    renewal_opportunities,
)

_SKILL_ROOT = Path(__file__).resolve().parent.parent
SummaryKey = Tuple[str, str, str]


def subtract_subscription_periods(as_of: date, period_type: str, n_periods: int) -> date:
    """从 as_of 向前推 n 个订阅周期（与可观测期数口径一致）。"""
    pt = (period_type or "").strip()
    if n_periods <= 0:
        return as_of
    if pt == "月":
        y, m = as_of.year, as_of.month - n_periods
        while m <= 0:
            m += 12
            y -= 1
        last_day = calendar.monthrange(y, m)[1]
        return date(y, m, min(as_of.day, last_day))
    if pt == "季":
        return subtract_subscription_periods(as_of, "月", n_periods * 3)
    if pt == "年":
        y = as_of.year - n_periods
        last_day = calendar.monthrange(y, as_of.month)[1]
        return date(y, as_of.month, min(as_of.day, last_day))
    if pt == "周":
        return as_of - timedelta(days=7 * n_periods)
    return subtract_subscription_periods(as_of, "月", n_periods)


@dataclass
class CumResult:
    renewal_k: int
    sum_num_k: int
    sum_num_0: int
    n_pay_dates: int
    pay_date_end: Optional[date]
    pay_date_start: Optional[date]
    threshold_met: bool
    anchor_pay_date: date
    cumulation_mode: str


def observable_candidates(
    by_pay: Dict[date, Row],
    date_p: date,
    period_type: str,
    renewal_k: int,
    anchor: date,
) -> List[Tuple[date, Row]]:
    """锚点及更早、且第 k 期可观测的 pay_date，按日期从新到旧。"""
    out: List[Tuple[date, Row]] = []
    for pay_d, row in by_pay.items():
        if pay_d > anchor:
            continue
        if renewal_opportunities(pay_d, date_p, period_type) < renewal_k:
            continue
        out.append((pay_d, row))
    out.sort(key=lambda x: x[0], reverse=True)
    return out


def criteria_met(sum_k: int, n_dates: int, min_orders: int, min_days: int) -> bool:
    return sum_k > min_orders and n_dates > min_days


def accumulate_reverse_until_threshold(
    by_pay: Dict[date, Row],
    date_p: date,
    period_type: str,
    renewal_k: int,
    min_orders: int,
    min_days: int,
) -> CumResult:
    anchor = subtract_subscription_periods(date_p, period_type, renewal_k)
    candidates = observable_candidates(by_pay, date_p, period_type, renewal_k, anchor)

    sum_k = 0
    sum_n0 = 0
    pay_start: Optional[date] = None
    pay_end: Optional[date] = None
    included: List[date] = []

    for pay_d, row in candidates:
        nk = row.nums[renewal_k] if renewal_k < len(row.nums) else 0
        n0 = row.nums[0]
        sum_k += nk
        sum_n0 += n0
        included.append(pay_d)
        if criteria_met(sum_k, len(included), min_orders, min_days):
            break

    threshold_met = criteria_met(sum_k, len(included), min_orders, min_days)
    if included:
        pay_end = included[0]
        pay_start = included[-1]

    if threshold_met:
        mode = "反向累积至超阈且超天数"
    elif included:
        mode = "锚点至最早全量"
    else:
        mode = "无可用cohort"

    return CumResult(
        renewal_k=renewal_k,
        sum_num_k=sum_k,
        sum_num_0=sum_n0,
        n_pay_dates=len(included),
        pay_date_end=pay_end,
        pay_date_start=pay_start,
        threshold_met=threshold_met,
        anchor_pay_date=anchor,
        cumulation_mode=mode,
    )


def build_group_index(
    rows: Sequence[Row],
    date_p: date,
    period_types: FrozenSet[str],
) -> Dict[SummaryKey, Dict[date, Row]]:
    groups: Dict[SummaryKey, Dict[date, Row]] = defaultdict(dict)
    for r in rows:
        if r.pay_date > date_p or r.period_type not in period_types:
            continue
        key: SummaryKey = (r.country_name, r.os_type, r.period_type)
        groups[key][r.pay_date] = r
    return groups


def fmt_pay_date(d: Optional[date]) -> str:
    return d.strftime("%Y%m%d") if d else ""


def write_output(path: Path, records: List[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "country_name",
        "os_type",
        "period_type",
        "renewal_k",
        "renewal_rate",
        "period_k_renewed_orders",
        "first_period_paid_orders",
        "n_pay_dates_included",
        "pay_date_range_end",
        "pay_date_range_start",
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(records)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--invocation-date", type=str, default=None)
    ap.add_argument("--input", type=Path, default=None)
    ap.add_argument("--date-p", type=str, default=None, help="截至日 YYYYMMDD 或 YYYY-MM-DD")
    ap.add_argument("--min-orders", type=int, default=1000, help="累计 num_k 须严格大于该值")
    ap.add_argument("--min-days", type=int, default=365, help="纳入 pay_date 天数须严格大于该值")
    ap.add_argument("--max-period", type=int, default=52)
    ap.add_argument(
        "--summary-period-types",
        type=str,
        default="月,周,年",
    )
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--out-dir", type=Path, default=None)
    args = ap.parse_args()

    inv_name = invocation_folder_name(args.invocation_date)
    run_dir = Path(args.out_dir) if args.out_dir else _SKILL_ROOT / "out" / inv_name
    input_path = args.input or (run_dir / "上传预测平台-历次续费率.csv")
    date_p = parse_date_arg(args.date_p or "2026-05-17")

    rows = read_rows(input_path)
    ptypes = frozenset(s.strip() for s in args.summary_period_types.split(",") if s.strip())
    groups = build_group_index(rows, date_p, ptypes)
    max_k = max(1, min(args.max_period, len(NUM_COLS) - 1))

    records: List[dict] = []
    for key in sorted(groups.keys()):
        cty, os_t, pt = key
        by_pay = groups[key]
        for k in range(1, max_k + 1):
            res = accumulate_reverse_until_threshold(
                by_pay, date_p, pt, k, args.min_orders, args.min_days
            )
            if res.n_pay_dates == 0:
                continue
            rate = "" if res.sum_num_0 == 0 else f"{(res.sum_num_k / res.sum_num_0):.8f}"
            records.append(
                {
                    "country_name": cty,
                    "os_type": os_t,
                    "period_type": pt,
                    "renewal_k": k,
                    "renewal_rate": rate,
                    "period_k_renewed_orders": res.sum_num_k,
                    "first_period_paid_orders": res.sum_num_0,
                    "n_pay_dates_included": res.n_pay_dates,
                    "pay_date_range_end": fmt_pay_date(res.pay_date_end),
                    "pay_date_range_start": fmt_pay_date(res.pay_date_start),
                }
            )

    out_path = args.out or (run_dir / "最新续费率_真实.csv")
    write_output(out_path, records)

    print(
        f"invocation_dir={inv_name} date_p={date_p.isoformat()} "
        f"groups={len(groups)} rows_out={len(records)} "
        f"min_orders>{args.min_orders} min_days>{args.min_days}"
    )
    print(f"wrote -> {out_path}")


if __name__ == "__main__":
    main()

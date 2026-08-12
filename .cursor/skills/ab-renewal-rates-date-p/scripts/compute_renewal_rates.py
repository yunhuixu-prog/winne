#!/usr/bin/env python3
"""
从「上传预测平台-历次续费率」神舟导出的宽表 CSV 计算历史续费率（全 cohort 汇总）。

本文件位于 skill 的 scripts/ 下：默认读写 **out/<调用日期YYYYMMDD>/**（调用日 = 执行当天系统日期，与 date_p 昨天区分）。
也可通过 --input / --out-dir / --invocation-date 指到其它路径或固定目录名。

口径（与 SQL 一致）：
  num_0 为 1 期（首期）付费订单数；num_j 表示曾达到代扣期数 order_by_pay = j+1 的去重订单数。
  第 k 期续费率 = k 期续费订单数 / 1 期付费订单数 = num_k / num_0（相对首期的留存比例）。

时间截断（必须与分区 date_p / 业务「截至日」一致）：
  1) **cohort 上界**：只汇总 **pay_date <= date_p** 的明细行。神舟 SQL 里常写
     `pay_date between ... and 20260430`，而分区 `date_p=20260410` 时，4.11～4.30 的 cohort
     不应进入汇总（否则 1 期续费率会混入未到快照日的订单）。
  2) **可观测期数**：对满足 1) 的行，用同一 **date_p** 作为观测截断日，判断从 pay_date 到
     date_p 是否已满 k 个「续订机会」；未满则不把该行的 num_0、num_k 计入第 k 期。
     月/季/年按**账单纪念日**计整段周期：例如 pay=4.11、date_p=5.10 时未满 1 个整月，
     **不能**算 1 期（避免「4.10 之后首购」在快照日尚未到 1 期续费观察点却仍进分母）。

  period_type 映射：
    月 — 已满整月数（自然月差，且未到「同日」纪念日则少 1 个月）
    季 — 已满整月数 // 3
    周 — 满周 floor((date_p - pay_date).days / 7)
    年 — 已满整年数（按月日是否过纪念日）

输出（默认路径）：
  out/<调用日期YYYYMMDD>/上传预测平台-历次续费率.csv（神舟下载目标需与此一致）
  out/<调用日期YYYYMMDD>/历史续费率_真实.csv
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path
from typing import Dict, FrozenSet, List, Optional, Sequence, Tuple

# skill 根目录 = scripts/ 的上一级
_SKILL_ROOT = Path(__file__).resolve().parent.parent

NUM_COLS = [f"num_{i}" for i in range(60)]


def parse_pay_date(v: str) -> date:
    s = str(v).strip()
    if not s:
        raise ValueError("empty pay_date")
    if len(s) == 8 and s.isdigit():
        return datetime.strptime(s, "%Y%m%d").date()
    return datetime.strptime(s[:10], "%Y-%m-%d").date()


def parse_date_arg(s: str) -> date:
    """CLI：YYYYMMDD 或 YYYY-MM-DD。"""
    t = str(s).strip()
    if len(t) == 8 and t.isdigit():
        return datetime.strptime(t, "%Y%m%d").date()
    return datetime.strptime(t[:10], "%Y-%m-%d").date()


def invocation_folder_name(invocation_date: Optional[str]) -> str:
    """目录名：调用日 YYYYMMDD，默认今天（系统日期）。"""
    if invocation_date:
        return parse_date_arg(invocation_date).strftime("%Y%m%d")
    return date.today().strftime("%Y%m%d")


def full_calendar_months_elapsed(pay: date, as_of: date) -> int:
    """
    从 pay 到 as_of，已满的「整月」个数（按账单日对齐）：
    先算 (年,月) 索引差，若 as_of 的「日」尚未达到 pay 的「日」，则未满当月，减 1。
    例：pay=4.11、asof=5.10 → 月差为 1 但 10<11 → 0（未到第 1 期续费可观察窗口）。
    """
    if as_of < pay:
        return 0
    months = (as_of.year - pay.year) * 12 + (as_of.month - pay.month)
    if as_of.day < pay.day:
        months -= 1
    return max(0, months)


def full_calendar_years_elapsed(pay: date, as_of: date) -> int:
    if as_of < pay:
        return 0
    y = as_of.year - pay.year
    if (as_of.month, as_of.day) < (pay.month, pay.day):
        y -= 1
    return max(0, y)


def renewal_opportunities(pay: date, as_of: date, period_type: str) -> int:
    """
    从首购日 pay 到 as_of（通常为 date_p），该订阅周期类型下最多可观测的「续订期数」上限 M：
    仅当 M >= k 时，第 k 期续费率才计入本行。
    """
    pt = (period_type or "").strip()
    fm = full_calendar_months_elapsed(pay, as_of)
    if pt == "月":
        return fm
    if pt == "季":
        return fm // 3
    if pt == "年":
        return full_calendar_years_elapsed(pay, as_of)
    if pt == "周":
        days = (as_of - pay).days
        return max(0, days // 7)
    return fm


@dataclass
class Row:
    pay_date: date
    os_type: str
    country_name: str
    period_type: str
    nums: List[int]

    def max_k_observable(self, as_of: date) -> int:
        return renewal_opportunities(self.pay_date, as_of, self.period_type)


def read_rows(path: Path, encoding: str = "utf-8-sig") -> List[Row]:
    rows: List[Row] = []
    with path.open(newline="", encoding=encoding) as f:
        reader = csv.DictReader(f)
        for raw in reader:
            pay = parse_pay_date(raw["pay_date"])
            nums = [int(float(raw[c])) for c in NUM_COLS]
            rows.append(
                Row(
                    pay_date=pay,
                    os_type=(raw.get("os_type") or "").strip(),
                    country_name=(raw.get("country_name") or "").strip(),
                    period_type=(raw.get("period_type") or "").strip(),
                    nums=nums,
                )
            )
    return rows


SummaryKey = Tuple[str, str, str]  # country, os, period_type


def aggregate_all_cohorts_by_country_os_period(
    rows: Sequence[Row],
    date_p: date,
    max_period: int,
    period_types: FrozenSet[str],
) -> Dict[SummaryKey, Dict[int, Tuple[int, int, int]]]:
    """
    对所有 pay_date 明细行，在 (country, os, period_type) 上
    对可观测的 k 期做 sum(num_k)、sum(num_0)。

    仅处理 pay_date <= date_p（与 SQL 分区 date_p 对齐，避免 pay_date 上界写死大于分区日）。
    可观测期数用同一 date_p 作为观测截断。
    """
    acc: Dict[SummaryKey, Dict[int, List[int]]] = defaultdict(lambda: defaultdict(lambda: [0, 0, 0]))
    for r in rows:
        if r.pay_date > date_p:
            continue
        if r.period_type not in period_types:
            continue
        mk = min(r.max_k_observable(date_p), max_period)
        key: SummaryKey = (r.country_name, r.os_type, r.period_type)
        n0 = r.nums[0]
        for k in range(1, mk + 1):
            if k >= len(r.nums):
                break
            curr_n = r.nums[k]
            cell = acc[key][k]
            cell[0] += curr_n
            cell[1] += n0
            cell[2] += 1

    return {key: {kk: (v[0], v[1], v[2]) for kk, v in sorted(periods.items())} for key, periods in acc.items()}


def write_summary_long_csv(
    path: Path,
    aggregated: Dict[SummaryKey, Dict[int, Tuple[int, int, int]]],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "country_name",
                "os_type",
                "period_type",
                "renewal_k",
                "renewal_rate",
                "period_k_renewed_orders",
                "first_period_paid_orders",
                "n_source_pay_date_rows",
            ]
        )
        for (cty, os_t, pt), periods in sorted(aggregated.items(), key=lambda x: (x[0][0], x[0][1], x[0][2])):
            for k, (sum_k, sum_n0, nrows) in sorted(periods.items()):
                rate = "" if sum_n0 == 0 else f"{(sum_k / sum_n0):.8f}"
                w.writerow([cty, os_t, pt, k, rate, sum_k, sum_n0, nrows])


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--invocation-date",
        type=str,
        default=None,
        help="调用日 YYYYMMDD 或 YYYY-MM-DD，默认今天；用作 out/<该日>/ 子目录名（与 date_p 无关）",
    )
    ap.add_argument(
        "--input",
        type=Path,
        default=None,
        help="宽表 CSV；默认 out/<调用日>/上传预测平台-历次续费率.csv",
    )
    ap.add_argument(
        "--date-p",
        type=str,
        default=None,
        help="与 SQL 中 where date_p= 一致，YYYYMMDD 或 YYYY-MM-DD；"
        "只汇总 pay_date<=该日 的 cohort，并用该日做续订机会截断",
    )
    ap.add_argument(
        "--as-of",
        type=str,
        default=None,
        help="与 --date-p 同义；未传 --date-p 时用本参数（兼容旧用法）",
    )
    ap.add_argument(
        "--summary-periods",
        type=int,
        default=52,
        help="输出 1～N 期，默认 52（且不超过源表 num 列）",
    )
    ap.add_argument(
        "--summary-period-types",
        type=str,
        default="月,周,年",
        help="逗号分隔，仅这些 period_type 参与汇总",
    )
    ap.add_argument(
        "--out",
        type=Path,
        default=None,
        help="输出长表路径；默认 out/<调用日>/历史续费率_真实.csv",
    )
    ap.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="输出目录；默认 skill/out/<调用日YYYYMMDD>/",
    )
    args = ap.parse_args()

    inv_name = invocation_folder_name(args.invocation_date)
    if args.out_dir is None:
        run_dir = _SKILL_ROOT / "out" / inv_name
    else:
        run_dir = Path(args.out_dir)

    if args.input is None:
        input_path = run_dir / "上传预测平台-历次续费率.csv"
    else:
        input_path = Path(args.input)

    date_p_raw = args.date_p or args.as_of or "2026-05-10"
    date_p = parse_date_arg(date_p_raw)

    rows = read_rows(input_path)
    sp = max(1, min(args.summary_periods, 59))
    ptypes = frozenset(s.strip() for s in args.summary_period_types.split(",") if s.strip())
    summary = aggregate_all_cohorts_by_country_os_period(rows, date_p, sp, ptypes)

    out_path = args.out
    if out_path is None:
        run_dir.mkdir(parents=True, exist_ok=True)
        out_path = run_dir / "历史续费率_真实.csv"
    write_summary_long_csv(out_path, summary)

    n_in = len(rows)
    n_use = sum(1 for r in rows if r.pay_date <= date_p)
    print(
        f"invocation_dir={inv_name} date_p={date_p.isoformat()} "
        f"rows_in_csv={n_in} rows_pay_date_le_date_p={n_use}"
    )
    print(f"wrote -> {out_path}")


if __name__ == "__main__":
    main()

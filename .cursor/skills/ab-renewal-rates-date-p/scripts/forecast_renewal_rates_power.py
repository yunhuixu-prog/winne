#!/usr/bin/env python3
"""
在历次续费率长表上，用幂律 y = a * k^b 拟合续费率，并外推至第 max_period 期。

拟合锚点：默认 period_k_renewed_orders > min_orders 且 renewal_rate > 0。
月/年/周：单期累积不到 min_orders 时，仅前 N 期保留真实并参与拟合，之后用幂律预估（月 N=14，年 N=3，周 N=5）；>min_orders 的期数仍为真实。
输出 1..max_period 每期一行；真实期标「真实」，其余标「预估」。
预估期保留原字段结构，订单数/源行数留空（首期付费订单数沿用该分组首期真实行）。
"""

from __future__ import annotations

import argparse
import csv
import math
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

RowKey = Tuple[str, str, str]  # country, os, period_type
ObsRow = Tuple[int, float, int, int, int]  # k, rate, renewed, first_paid, n_source

# 单期累积 num_k 未超 min_orders 时，仅前 N 期标真实并参与幂律拟合
LOW_VOLUME_MAX_REAL_K: Dict[str, int] = {"月": 14, "年": 3, "周": 5}


def parse_float(s: str) -> Optional[float]:
    s = (s or "").strip()
    if not s:
        return None
    return float(s)


def parse_int(s: str) -> Optional[int]:
    s = (s or "").strip()
    if not s:
        return None
    return int(float(s))


def fit_power_law(points: List[Tuple[int, float]]) -> Tuple[float, float]:
    """最小二乘 log(y)=log(a)+b*log(k)。不足 2 点时退化为常数 a（b=0）。"""
    if not points:
        return 0.0, 0.0
    if len(points) == 1:
        k, y = points[0]
        return y / (k**0), 0.0
    log_k = [math.log(k) for k, _ in points]
    log_y = [math.log(y) for _, y in points]
    n = len(points)
    sx = sum(log_k)
    sy = sum(log_y)
    sxx = sum(x * x for x in log_k)
    sxy = sum(x * y for x, y in zip(log_k, log_y))
    denom = n * sxx - sx * sx
    if abs(denom) < 1e-15:
        return math.exp(sy / n), 0.0
    b = (n * sxy - sx * sy) / denom
    log_a = (sy - b * sx) / n
    return math.exp(log_a), b


def predict_rate(a: float, b: float, k: int) -> float:
    return max(0.0, min(1.0, a * (k**b)))


def read_groups(path: Path) -> Dict[RowKey, Dict[int, ObsRow]]:
    groups: Dict[RowKey, Dict[int, ObsRow]] = defaultdict(dict)
    with path.open(newline="", encoding="utf-8") as f:
        for raw in csv.DictReader(f):
            key: RowKey = (
                (raw.get("country_name") or "").strip(),
                (raw.get("os_type") or "").strip(),
                (raw.get("period_type") or "").strip(),
            )
            k = int(float(raw["renewal_k"]))
            rate = parse_float(raw.get("renewal_rate", ""))
            if rate is None:
                continue
            renewed = parse_int(raw.get("period_k_renewed_orders", "")) or 0
            first_paid = parse_int(raw.get("first_period_paid_orders", "")) or 0
            n_source = parse_int(raw.get("n_source_pay_date_rows", "")) or 0
            groups[key][k] = (k, rate, renewed, first_paid, n_source)
    return groups


def low_volume_max_real_k(period_type: str) -> Optional[int]:
    return LOW_VOLUME_MAX_REAL_K.get((period_type or "").strip())


def is_observed_anchor(
    row: ObsRow,
    min_orders: int,
    *,
    period_type: str,
    renewal_k: int,
) -> bool:
    if row[1] <= 0:
        return False
    max_real_k = low_volume_max_real_k(period_type)
    if max_real_k is not None:
        if row[2] > min_orders:
            return True
        return renewal_k <= max_real_k
    return row[2] > min_orders


def fit_points_for_group(
    by_k: Dict[int, ObsRow],
    period_type: str,
    min_orders: int,
) -> List[Tuple[int, float]]:
    points: List[Tuple[int, float]] = []
    for k, row in sorted(by_k.items()):
        if not is_observed_anchor(row, min_orders, period_type=period_type, renewal_k=k):
            continue
        points.append((k, row[1]))
    return points


def build_forecast_rows(
    groups: Dict[RowKey, Dict[int, ObsRow]],
    min_orders: int,
    max_period: int,
    *,
    pure_power_law: bool = False,
) -> List[dict]:
    out: List[dict] = []
    for key in sorted(groups.keys()):
        by_k = groups[key]
        period_type = key[2]
        anchor = fit_points_for_group(by_k, period_type, min_orders)
        a, b = fit_power_law(anchor)

        first_paid_ref = ""
        for k in sorted(by_k):
            if by_k[k][3]:
                first_paid_ref = by_k[k][3]
                break

        for k in range(1, max_period + 1):
            row = by_k.get(k)
            is_anchor = row is not None and is_observed_anchor(
                row, min_orders, period_type=period_type, renewal_k=k
            )
            if pure_power_law:
                rate = predict_rate(a, b, k)
                renewed = ""
                first_paid = first_paid_ref
                n_source = ""
                source = "幂律"
            elif is_anchor:
                rate = row[1]
                renewed = row[2]
                first_paid = row[3]
                n_source = row[4]
                source = "真实"
            else:
                rate = predict_rate(a, b, k)
                renewed = ""
                first_paid = first_paid_ref
                n_source = ""
                source = "预估"

            out.append(
                {
                    "country_name": key[0],
                    "os_type": key[1],
                    "period_type": key[2],
                    "renewal_k": k,
                    "renewal_rate": f"{rate:.8f}",
                    "period_k_renewed_orders": renewed,
                    "first_period_paid_orders": first_paid,
                    "n_source_pay_date_rows": n_source,
                    "renewal_rate_source": source,
                }
            )
    return out


def infer_rate_kind(input_path: Path) -> str:
    name = input_path.name
    if "最新" in name:
        return "latest"
    return "historical"


def default_forecast_out_path(input_path: Path, *, pure_power_law: bool, rate_kind: str) -> Path:
    prefix = "最新续费率" if rate_kind == "latest" else "历史续费率"
    suffix = "纯预估" if pure_power_law else "真实和预估"
    return input_path.parent / f"{prefix}_{suffix}.csv"


def main() -> None:
    skill_root = Path(__file__).resolve().parent.parent
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--input",
        type=Path,
        default=skill_root / "out" / "历史续费率_真实.csv",
        help="历史/最新续费率_真实.csv",
    )
    ap.add_argument(
        "--kind",
        choices=("historical", "latest", "auto"),
        default="auto",
        help="历史续费率或最新续费率；auto 时根据输入文件名推断",
    )
    ap.add_argument(
        "--out",
        type=Path,
        default=None,
        help="输出 CSV；默认与输入同目录",
    )
    ap.add_argument("--min-orders", type=int, default=1000, help="拟合锚点：续费订单数下限")
    ap.add_argument("--max-period", type=int, default=100, help="输出至第几期")
    ap.add_argument(
        "--pure-power-law",
        action="store_true",
        help="全部期数续费率均用拟合幂律 y=a*k^b 计算（不保留真实观测值）",
    )
    args = ap.parse_args()

    input_path = Path(args.input)
    rate_kind = (
        infer_rate_kind(input_path) if args.kind == "auto" else args.kind
    )

    groups = read_groups(input_path)
    rows = build_forecast_rows(
        groups, args.min_orders, args.max_period, pure_power_law=args.pure_power_law
    )

    out_path = args.out
    if out_path is None:
        out_path = default_forecast_out_path(
            input_path, pure_power_law=args.pure_power_law, rate_kind=rate_kind
        )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "country_name",
        "os_type",
        "period_type",
        "renewal_k",
        "renewal_rate",
        "period_k_renewed_orders",
        "first_period_paid_orders",
        "n_source_pay_date_rows",
        "renewal_rate_source",
    ]
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)

    n_anchor = sum(1 for r in rows if r["renewal_rate_source"] == "真实")
    mode = "pure_power_law" if args.pure_power_law else "mixed"
    print(
        f"groups={len(groups)} rows={len(rows)} anchor_rows={n_anchor} "
        f"min_orders={args.min_orders} mode={mode}"
    )
    print(f"wrote -> {out_path}")


if __name__ == "__main__":
    main()

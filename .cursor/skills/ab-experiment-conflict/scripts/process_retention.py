#!/usr/bin/env python3
"""神舟 step1 CSV → 幂律预估-长表.csv / LT汇总.csv / 拟合曲线.png"""

from __future__ import annotations

import argparse
import csv
import math
from collections import defaultdict
from pathlib import Path
from statistics import mean
from typing import Dict, List, Tuple

MAX_OBS = 14
MAX_PERIOD = 365
LT_HORIZONS = (7, 14, 365)


def fit_power_law(points: List[Tuple[int, float]]) -> Tuple[float, float]:
    if not points:
        return 0.0, 0.0
    if len(points) == 1:
        return points[0][1], 0.0
    log_k = [math.log(k) for k, _ in points]
    log_y = [math.log(y) for _, y in points]
    n = len(points)
    sx, sy = sum(log_k), sum(log_y)
    sxx = sum(x * x for x in log_k)
    sxy = sum(x * y for x, y in zip(log_k, log_y))
    denom = n * sxx - sx * sx
    if abs(denom) < 1e-15:
        return math.exp(sy / n), 0.0
    b = (n * sxy - sx * sy) / denom
    return math.exp((sy - b * sx) / n), b


def predict(a: float, b: float, k: int) -> float:
    return max(0.0, min(1.0, a * (k**b)))


def load_step1(path: Path) -> list[dict]:
    rows = []
    with path.open(newline="", encoding="utf-8") as f:
        for r in csv.DictReader(f):
            rows.append({
                "abcode": r["abcode"],
                "lcx": int(r["lcx"]),
                "week_day": int(r["week_day"]),
                "retention_rate": float(r["retention_rate"]),
            })
    return rows


def aggregate_raw(rows: list[dict]) -> Dict[str, Dict[int, float]]:
    buckets: Dict[str, Dict[int, list]] = defaultdict(lambda: defaultdict(list))
    for r in rows:
        buckets[r["abcode"]][r["lcx"]].append(r["retention_rate"])
    return {ab: {k: mean(v) for k, v in sorted(by_lcx.items())} for ab, by_lcx in buckets.items()}


def weekday_coefs(rows: list[dict]) -> Dict[int, float]:
    by_week: Dict[int, list] = defaultdict(list)
    for r in rows:
        by_week[r["week_day"]].append(r["retention_rate"])
    week_mean = {w: mean(v) for w, v in by_week.items()}
    mon = week_mean[1]
    return {w: (week_mean[w] / mon if w != 1 else 1.0) for w in week_mean}


def apply_weekday_adj(rows: list[dict], coef: Dict[int, float]) -> Dict[str, Dict[int, float]]:
    buckets: Dict[str, Dict[int, list]] = defaultdict(lambda: defaultdict(list))
    for r in rows:
        adj = r["retention_rate"] / coef[r["week_day"]]
        buckets[r["abcode"]][r["lcx"]].append(adj)
    return {ab: {k: mean(v) for k, v in sorted(by_lcx.items())} for ab, by_lcx in buckets.items()}


def build_forecast(obs: Dict[str, Dict[str, Dict[int, float]]]) -> Tuple[list[dict], list[dict]]:
    long_rows: list[dict] = []
    plot_series: list[dict] = []
    for ab in sorted(obs):
        for rate_type in ("raw", "adj"):
            by_k = obs[ab][rate_type]
            points = sorted((k, by_k[k]) for k in range(1, MAX_OBS + 1) if k in by_k)
            a, b = fit_power_law(points)
            for k in range(1, MAX_PERIOD + 1):
                if k in by_k and k <= MAX_OBS:
                    rate, source = by_k[k], "真实"
                else:
                    rate, source = predict(a, b, k), "预估"
                long_rows.append({
                    "abcode": ab,
                    "rate_type": rate_type,
                    "lcx": k,
                    "retention_rate": f"{rate:.8f}",
                    "retention_rate_source": source,
                    "power_a": f"{a:.8f}",
                    "power_b": f"{b:.6f}",
                })
                plot_series.append({
                    "abcode": ab,
                    "rate_type": rate_type,
                    "lcx": k,
                    "fitted": predict(a, b, k),
                    "observed": by_k[k] if k in by_k and k <= MAX_OBS else None,
                })
    return long_rows, plot_series


def build_lt(long_rows: list[dict]) -> list[dict]:
    rates: Dict[Tuple[str, str], Dict[int, float]] = defaultdict(dict)
    for r in long_rows:
        rates[(r["abcode"], r["rate_type"])][int(r["lcx"])] = float(r["retention_rate"])
    out = []
    for (ab, rt) in sorted(rates.keys()):
        s = rates[(ab, rt)]
        row = {"abcode": ab, "rate_type": rt, "rate_type_cn": "调整前" if rt == "raw" else "调整后"}
        for n in LT_HORIZONS:
            row[f"LT{n}"] = round(sum(s[k] for k in range(1, n + 1) if k in s), 4)
        out.append(row)
    return out


def save_plot(plot_series: list[dict], out_png: Path, abcodes: list[str]) -> None:
    import matplotlib.pyplot as plt

    colors = {"raw": "#2563eb", "adj": "#dc2626"}
    labels = {"raw": "raw", "adj": "adj"}
    n = len(abcodes)
    fig, axes = plt.subplots(1, n, figsize=(max(5 * n, 6), 4), squeeze=False)
    axes = axes[0]
    for i, ab in enumerate(abcodes):
        ax = axes[i]
        for rate_type in ("raw", "adj"):
            sub = [p for p in plot_series if p["abcode"] == ab and p["rate_type"] == rate_type]
            ax.plot([p["lcx"] for p in sub], [p["fitted"] for p in sub], color=colors[rate_type], lw=1.2, label=labels[rate_type])
            ox = [p["lcx"] for p in sub if p["observed"] is not None]
            oy = [p["observed"] for p in sub if p["observed"] is not None]
            ax.scatter(ox, oy, color=colors[rate_type], s=20, zorder=3)
        ax.axvline(MAX_OBS, color="gray", ls="--", lw=0.8, alpha=0.6)
        ax.set_title(f"abcode {ab}")
        ax.set_xlim(1, 365)
        ax.set_xlabel("lcx (day)")
        ax.set_ylabel("retention rate")
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    fig.suptitle("Power-law fit: obs d1-14, forecast d15-365", fontsize=11)
    fig.tight_layout()
    fig.savefig(out_png, dpi=120)
    plt.close(fig)


def run(input_csv: Path, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    rows = load_step1(input_csv)
    coef = weekday_coefs(rows)
    raw_by_ab = aggregate_raw(rows)
    adj_by_ab = apply_weekday_adj(rows, coef)
    obs: Dict[str, Dict[str, Dict[int, float]]] = {}
    for ab in sorted(set(raw_by_ab) | set(adj_by_ab)):
        obs[ab] = {"raw": raw_by_ab.get(ab, {}), "adj": adj_by_ab.get(ab, {})}
    long_rows, plot_series = build_forecast(obs)
    lt_rows = build_lt(long_rows)

    out_long = out_dir / "幂律预估-长表.csv"
    out_lt = out_dir / "LT汇总.csv"
    out_png = out_dir / "拟合曲线.png"

    with out_long.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["abcode", "rate_type", "lcx", "retention_rate", "retention_rate_source", "power_a", "power_b"],
        )
        w.writeheader()
        w.writerows(long_rows)
    with out_lt.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["abcode", "rate_type", "rate_type_cn", "LT7", "LT14", "LT365"])
        w.writeheader()
        w.writerows(lt_rows)
    save_plot(plot_series, out_png, sorted(obs.keys()))

    print(f"output: {out_long}\n        {out_lt}\n        {out_png}")
    for r in lt_rows:
        print(f"  {r['abcode']} {r['rate_type_cn']:4s}  LT7={r['LT7']:.4f}  LT14={r['LT14']:.4f}  LT365={r['LT365']:.4f}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", type=Path, required=True)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    run(args.input, args.out_dir)


if __name__ == "__main__":
    main()

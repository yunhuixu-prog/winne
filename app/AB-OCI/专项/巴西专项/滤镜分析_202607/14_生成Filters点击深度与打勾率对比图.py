#!/usr/bin/env python3
"""Create Brazil vs Overall Filters click-depth distribution and check-rate chart."""

from __future__ import annotations

import csv
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch


ROOT = Path("/Users/xuyunhui/Documents/项目")
DATA = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06D_Filters每次进入点击不同素材数分布与打勾率_分层.csv"
CORE_DATA = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06C_Filters单次进入核心指标_分层.csv"
OUTPUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06_Filters点击素材数占比与打勾率_巴西vs整体.png"

BG = "#F3F6FA"
CARD = "#FFFFFF"
INK = "#182235"
MUTED = "#7F8CA1"
GRID = "#E5EAF1"
BRAZIL = "#E6483E"
OVERALL = "#9AA6B6"


def load_data():
    rows = []
    with DATA.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row["segment_dimension"] != "overall":
                continue
            rows.append(row)
    source_order = [str(i) for i in range(10)] + ["10+"]
    groups = [
        ("0", ["0"]),
        ("1", ["1"]),
        ("2", ["2"]),
        ("3", ["3"]),
        ("4", ["4"]),
        ("5–9", ["5", "6", "7", "8", "9"]),
        ("10+", ["10+"]),
    ]
    lookup = {(r["country_group"], r["distinct_click_material_bucket"]): r for r in rows}
    result = {}
    for market in ("Brazil", "Overall"):
        total_entries = sum(int(lookup[(market, b)]["filter_entry_count"]) for b in source_order)
        counts = np.array(
            [sum(int(lookup[(market, b)]["filter_entry_count"]) for b in members) for _, members in groups]
        )
        checked = np.array(
            [sum(int(lookup[(market, b)]["checked_entry_count"]) for b in members) for _, members in groups]
        )
        result[market] = {
            "share": counts / total_entries * 100,
            "check": np.divide(checked, counts, out=np.zeros_like(checked, dtype=float), where=counts != 0) * 100,
            "count": counts,
            "checked": checked,
        }
    return [label for label, _ in groups], result


def load_kpis():
    result = {}
    with CORE_DATA.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row["segment_dimension"] != "overall" or row["segment_value"] != "ALL":
                continue
            result[row["country_group"]] = {
                "avg_exposure": float(row["avg_distinct_exposure_materials_per_entry"]),
                "avg_click": float(row["avg_distinct_click_materials_per_entry"]),
            }
    return result


def style_axis(ax):
    ax.set_facecolor(CARD)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(axis="both", colors=MUTED, labelsize=12, length=0)
    ax.grid(axis="y", color=GRID, linewidth=1.0)
    ax.set_axisbelow(True)


def main():
    plt.rcParams.update(
        {
            "font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "figure.facecolor": BG,
            "savefig.facecolor": BG,
        }
    )
    buckets, data = load_data()
    kpis = load_kpis()
    x = np.arange(len(buckets))
    width = 0.34

    fig = plt.figure(figsize=(16, 10), dpi=180, facecolor=BG)
    fig.text(0.055, 0.955, "每次进入 Filters 的素材点击深度与打勾率", fontsize=25, weight="semibold", color=INK)
    fig.text(
        0.055,
        0.918,
        "巴西 vs 整体｜2026/7/29–8/4｜点击素材数按每次进入内的不同素材去重",
        fontsize=12.5,
        color=MUTED,
    )

    fig.text(0.785, 0.951, "●", color=BRAZIL, fontsize=15)
    fig.text(0.802, 0.951, "巴西", color=INK, fontsize=12)
    fig.text(0.858, 0.951, "●", color=OVERALL, fontsize=15)
    fig.text(0.875, 0.951, "整体", color=INK, fontsize=12)

    # KPI cards above the distribution charts.
    for x0, title, brazil_value, overall_value in (
        (0.055, "单次进入平均点击不同素材数", kpis["Brazil"]["avg_click"], kpis["Overall"]["avg_click"]),
        (0.310, "单次进入平均曝光不同素材数", kpis["Brazil"]["avg_exposure"], kpis["Overall"]["avg_exposure"]),
    ):
        kpi = FancyBboxPatch(
            (x0, 0.805), 0.235, 0.075,
            boxstyle="round,pad=0.010,rounding_size=0.012",
            transform=fig.transFigure,
            facecolor=CARD,
            edgecolor=GRID,
            linewidth=0.8,
            zorder=-5,
        )
        fig.patches.append(kpi)
        fig.text(x0 + 0.014, 0.853, title, fontsize=11.2, color=MUTED)
        fig.text(x0 + 0.014, 0.821, f"巴西  {brazil_value:.2f}", fontsize=17, color=BRAZIL, weight="semibold")
        fig.text(x0 + 0.145, 0.823, f"整体  {overall_value:.2f}", fontsize=13.5, color=OVERALL)

    card = FancyBboxPatch(
        (0.04, 0.060), 0.92, 0.715,
        boxstyle="round,pad=0.012,rounding_size=0.018",
        transform=fig.transFigure,
        facecolor=CARD,
        edgecolor="none",
        zorder=-10,
    )
    fig.patches.append(card)

    ax_share = fig.add_axes([0.075, 0.465, 0.85, 0.245])
    style_axis(ax_share)
    ax_share.set_title("点击素材数占比", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    bars_o = ax_share.bar(x - width / 2, data["Overall"]["share"], width, color=OVERALL, alpha=0.72)
    bars_b = ax_share.bar(x + width / 2, data["Brazil"]["share"], width, color=BRAZIL, alpha=0.95)
    ax_share.set_ylim(0, 34)
    ax_share.set_yticks([0, 10, 20, 30])
    ax_share.set_yticklabels(["0%", "10%", "20%", "30%"])
    ax_share.set_xticks(x)
    ax_share.set_xticklabels([])
    for bars, values, color in ((bars_o, data["Overall"]["share"], OVERALL), (bars_b, data["Brazil"]["share"], BRAZIL)):
        for bar, value in zip(bars, values):
            ax_share.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height() + 0.65,
                f"{value:.1f}%",
                ha="center",
                va="bottom",
                fontsize=9.5,
                color=color,
                weight="semibold" if color == BRAZIL else "normal",
            )

    ax_check = fig.add_axes([0.075, 0.135, 0.85, 0.245])
    style_axis(ax_check)
    ax_check.set_title("对应进入打勾率", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    ax_check.plot(x, data["Overall"]["check"], color=OVERALL, linewidth=2.4, marker="o", markersize=6, label="整体")
    ax_check.plot(x, data["Brazil"]["check"], color=BRAZIL, linewidth=2.8, marker="o", markersize=6.5, label="巴西")
    ax_check.set_ylim(0, 90)
    ax_check.set_yticks([0, 20, 40, 60, 80])
    ax_check.set_yticklabels(["0%", "20%", "40%", "60%", "80%"])
    ax_check.set_xticks(x)
    ax_check.set_xticklabels(buckets, fontsize=12.5, color=INK)
    ax_check.set_xlabel("每次进入点击的不同素材数", color=MUTED, fontsize=11.5, labelpad=12)

    for market, color, dy in (("Overall", OVERALL, -4.7), ("Brazil", BRAZIL, 3.0)):
        for xi, value in zip(x, data[market]["check"]):
            if xi == 0:
                continue
            ax_check.text(
                xi,
                value + dy,
                f"{value:.1f}%",
                ha="center",
                va="center",
                fontsize=9.2,
                color=color,
                weight="semibold" if market == "Brazil" else "normal",
            )

    ax_check.annotate(
        "单击 1 个素材时\n打勾率最高 78.4%",
        xy=(1, data["Brazil"]["check"][1]),
        xytext=(1.75, 86),
        color=BRAZIL,
        fontsize=10.5,
        ha="center",
        arrowprops=dict(arrowstyle="-", color=BRAZIL, lw=1.2),
    )
    ax_check.annotate(
        "点击 10+ 个素材占 20.6%\n打勾率降至 58.4%",
        xy=(6, data["Brazil"]["check"][6]),
        xytext=(5.25, 76),
        color=BRAZIL,
        fontsize=10.5,
        ha="center",
        arrowprops=dict(arrowstyle="-", color=BRAZIL, lw=1.2),
    )

    fig.text(
        0.055,
        0.025,
        "口径：轮次占比 = 该点击素材数的 Filters 进入次数 / 全部 Filters 进入次数；打勾率 = 该点击素材数下的打勾进入次数 / 进入次数；平均曝光/点击数均按进入轮次内不同素材去重。整体包含巴西。",
        fontsize=10.5,
        color=MUTED,
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.18)
    plt.close(fig)
    print(OUTPUT)


if __name__ == "__main__":
    main()

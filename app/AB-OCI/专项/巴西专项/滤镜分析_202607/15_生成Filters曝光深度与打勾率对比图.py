#!/usr/bin/env python3
"""Create Brazil vs Overall Filters exposure-depth distribution and check-rate chart."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch


ROOT = Path("/Users/xuyunhui/Documents/项目")
DATA = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06H_Filters曝光不同素材数分布与打勾率_分层.csv"
OUTPUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06_Filters曝光素材数占比与打勾率_巴西vs整体.png"

BG = "#F3F6FA"
CARD = "#FFFFFF"
INK = "#182235"
MUTED = "#7F8CA1"
GRID = "#E5EAF1"
BRAZIL = "#E6483E"
OVERALL = "#9AA6B6"
BANDS = ["0", "1-5", "6-10", "11-15", "16-20", "21-25", "26-30", "31-35", "36-40", "41-49", "50+"]


def band(value: str) -> str:
    if value == "50+":
        return "50+"
    n = int(value)
    if n == 0:
        return "0"
    if n <= 5:
        return "1-5"
    if n <= 10:
        return "6-10"
    if n <= 15:
        return "11-15"
    if n <= 20:
        return "16-20"
    if n <= 25:
        return "21-25"
    if n <= 30:
        return "26-30"
    if n <= 35:
        return "31-35"
    if n <= 40:
        return "36-40"
    if n <= 49:
        return "41-49"
    return "50+"


def load_data():
    agg = defaultdict(lambda: [0, 0])
    with DATA.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row["segment_dimension"] != "overall":
                continue
            key = (row["country_group"], band(row["distinct_exposure_material_bucket"]))
            agg[key][0] += int(row["filter_entry_count"])
            agg[key][1] += int(row["checked_entry_count"])
    result = {}
    for market in ("Brazil", "Overall"):
        total = sum(agg[(market, b)][0] for b in BANDS)
        result[market] = {
            "share": np.array([agg[(market, b)][0] / total * 100 for b in BANDS]),
            "check": np.array([
                agg[(market, b)][1] / agg[(market, b)][0] * 100 if agg[(market, b)][0] else 0
                for b in BANDS
            ]),
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
    data = load_data()
    x = np.arange(len(BANDS))
    width = 0.34

    fig = plt.figure(figsize=(16, 10), dpi=180, facecolor=BG)
    fig.text(0.055, 0.955, "每次进入 Filters 的素材曝光深度与打勾率", fontsize=25, weight="semibold", color=INK)
    fig.text(
        0.055, 0.918,
        "巴西 vs 整体｜2026/7/29–8/4｜曝光素材数按每次进入内的不同素材去重",
        fontsize=12.5, color=MUTED,
    )
    fig.text(0.785, 0.951, "●", color=BRAZIL, fontsize=15)
    fig.text(0.802, 0.951, "巴西", color=INK, fontsize=12)
    fig.text(0.858, 0.951, "●", color=OVERALL, fontsize=15)
    fig.text(0.875, 0.951, "整体", color=INK, fontsize=12)

    kpi = FancyBboxPatch(
        (0.055, 0.805), 0.31, 0.075,
        boxstyle="round,pad=0.010,rounding_size=0.012",
        transform=fig.transFigure, facecolor=CARD, edgecolor=GRID, linewidth=0.8, zorder=-5,
    )
    fig.patches.append(kpi)
    fig.text(0.069, 0.853, "单次进入平均曝光不同素材数", fontsize=11.2, color=MUTED)
    fig.text(0.069, 0.821, "巴西  17.90", fontsize=17, color=BRAZIL, weight="semibold")
    fig.text(0.185, 0.823, "整体  18.26", fontsize=13.5, color=OVERALL)

    card = FancyBboxPatch(
        (0.04, 0.060), 0.92, 0.715,
        boxstyle="round,pad=0.012,rounding_size=0.018",
        transform=fig.transFigure, facecolor=CARD, edgecolor="none", zorder=-10,
    )
    fig.patches.append(card)

    ax_share = fig.add_axes([0.075, 0.465, 0.85, 0.245])
    style_axis(ax_share)
    ax_share.set_title("曝光素材数占比", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    bars_o = ax_share.bar(x - width / 2, data["Overall"]["share"], width, color=OVERALL, alpha=0.72)
    bars_b = ax_share.bar(x + width / 2, data["Brazil"]["share"], width, color=BRAZIL, alpha=0.95)
    ax_share.set_ylim(0, 41)
    ax_share.set_yticks([0, 10, 20, 30, 40])
    ax_share.set_yticklabels(["0%", "10%", "20%", "30%", "40%"])
    ax_share.set_xticks(x)
    ax_share.set_xticklabels([])
    for bars, values, color in ((bars_o, data["Overall"]["share"], OVERALL), (bars_b, data["Brazil"]["share"], BRAZIL)):
        for bar_obj, value in zip(bars, values):
            ax_share.text(
                bar_obj.get_x() + bar_obj.get_width() / 2, bar_obj.get_height() + 0.65,
                f"{value:.1f}%", ha="center", va="bottom", fontsize=9.5, color=color,
                weight="semibold" if color == BRAZIL else "normal",
            )

    ax_check = fig.add_axes([0.075, 0.135, 0.85, 0.245])
    style_axis(ax_check)
    ax_check.set_title("对应进入打勾率", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    ax_check.plot(x, data["Overall"]["check"], color=OVERALL, linewidth=2.4, marker="o", markersize=6)
    ax_check.plot(x, data["Brazil"]["check"], color=BRAZIL, linewidth=2.8, marker="o", markersize=6.5)
    ax_check.set_ylim(0, 80)
    ax_check.set_yticks([0, 20, 40, 60, 80])
    ax_check.set_yticklabels(["0%", "20%", "40%", "60%", "80%"])
    ax_check.set_xticks(x)
    ax_check.set_xticklabels(BANDS, fontsize=12.5, color=INK)
    ax_check.set_xlabel("每次进入曝光的不同素材数", color=MUTED, fontsize=11.5, labelpad=12)
    for market, color, dy in (("Overall", OVERALL, -4.2), ("Brazil", BRAZIL, 2.5)):
        for xi, value in zip(x, data[market]["check"]):
            if xi == 0:
                continue
            ax_check.text(
                xi, value + dy, f"{value:.1f}%", ha="center", va="center", fontsize=9.2,
                color=color, weight="semibold" if market == "Brazil" else "normal",
            )
    ax_check.annotate(
        "曝光 11–15 个素材时\n巴西打勾率最高 67.1%",
        xy=(3, data["Brazil"]["check"][3]), xytext=(3.9, 77),
        color=BRAZIL, fontsize=10.5, ha="center",
        arrowprops=dict(arrowstyle="-", color=BRAZIL, lw=1.2),
    )

    fig.text(
        0.055, 0.025,
        "口径：轮次占比 = 该曝光素材数的 Filters 进入次数 / 全部 Filters 进入次数；打勾率 = 该曝光素材数下的打勾进入次数 / 进入次数。整体包含巴西。",
        fontsize=10.5, color=MUTED,
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.18)
    plt.close(fig)
    print(OUTPUT)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Plot exposure depth before first Filters material click, Brazil vs Overall."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch


ROOT = Path("/Users/xuyunhui/Documents/项目")
DATA = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06J_Filters首次点击前曝光不同素材数分布_分层.csv"
OUTPUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607/06_Filters首次点击前曝光素材数分布_巴西vs整体.png"

BG = "#F3F6FA"
CARD = "#FFFFFF"
INK = "#182235"
MUTED = "#7F8CA1"
GRID = "#E5EAF1"
BRAZIL = "#E6483E"
OVERALL = "#9AA6B6"
BANDS = ["0", "1-5", "6-10", "11-15", "16-20", "21-30", "31-40", "41-49", "50+"]


def band(value: str) -> str:
    if value in {"NO_CLICK", "50+"}:
        return value
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
    if n <= 30:
        return "21-30"
    if n <= 40:
        return "31-40"
    if n <= 49:
        return "41-49"
    return "50+"


def load_data():
    agg = defaultdict(lambda: [0, 0, 0])
    no_click = defaultdict(int)
    all_entry = defaultdict(int)
    with DATA.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row["segment_dimension"] != "overall":
                continue
            market = row["country_group"]
            bucket = band(row["pre_click_exposure_bucket"])
            entries = int(row["filter_entry_count"])
            all_entry[market] += entries
            if bucket == "NO_CLICK":
                no_click[market] += entries
                continue
            agg[(market, bucket)][0] += int(row["clicked_entry_count"])
            agg[(market, bucket)][1] += int(row["checked_entry_count"])
            agg[(market, bucket)][2] += int(row["clicked_entry_with_same_second_exposure_count"])
    result = {}
    for market in ("Brazil", "Overall"):
        clicked = sum(agg[(market, b)][0] for b in BANDS)
        result[market] = {
            "share": np.array([agg[(market, b)][0] / clicked * 100 for b in BANDS]),
            "check": np.array([
                agg[(market, b)][1] / agg[(market, b)][0] * 100 if agg[(market, b)][0] else 0
                for b in BANDS
            ]),
            "no_click": no_click[market] / all_entry[market] * 100,
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
    fig.text(0.055, 0.955, "首次点击前曝光不同素材数分布", fontsize=25, weight="semibold", color=INK)
    fig.text(
        0.055, 0.918,
        "巴西 vs 整体｜2026/7/29–8/4｜仅统计发生点击的 Filters 进入轮次",
        fontsize=12.5, color=MUTED,
    )
    fig.text(0.785, 0.951, "●", color=BRAZIL, fontsize=15)
    fig.text(0.802, 0.951, "巴西", color=INK, fontsize=12)
    fig.text(0.858, 0.951, "●", color=OVERALL, fontsize=15)
    fig.text(0.875, 0.951, "整体", color=INK, fontsize=12)

    cards = [
        (0.055, "首次点击前平均曝光不同素材数", "巴西  7.16", "整体  7.52"),
        (0.315, "中位数 / P75", "巴西  6 / 6", "整体  6 / 7"),
        (0.575, "无点击轮次占比", f"巴西  {data['Brazil']['no_click']:.1f}%", f"整体  {data['Overall']['no_click']:.1f}%"),
    ]
    for x0, title, brazil_text, overall_text in cards:
        patch = FancyBboxPatch(
            (x0, 0.805), 0.235, 0.075,
            boxstyle="round,pad=0.010,rounding_size=0.012",
            transform=fig.transFigure, facecolor=CARD, edgecolor=GRID, linewidth=0.8, zorder=-5,
        )
        fig.patches.append(patch)
        fig.text(x0 + 0.014, 0.853, title, fontsize=11.2, color=MUTED)
        fig.text(x0 + 0.014, 0.821, brazil_text, fontsize=16, color=BRAZIL, weight="semibold")
        fig.text(x0 + 0.126, 0.823, overall_text, fontsize=12.8, color=OVERALL)

    card = FancyBboxPatch(
        (0.04, 0.060), 0.92, 0.715,
        boxstyle="round,pad=0.012,rounding_size=0.018",
        transform=fig.transFigure, facecolor=CARD, edgecolor="none", zorder=-10,
    )
    fig.patches.append(card)

    ax_share = fig.add_axes([0.075, 0.465, 0.85, 0.245])
    style_axis(ax_share)
    ax_share.set_title("首次点击前曝光素材数占比", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    bars_o = ax_share.bar(x - width / 2, data["Overall"]["share"], width, color=OVERALL, alpha=0.72)
    bars_b = ax_share.bar(x + width / 2, data["Brazil"]["share"], width, color=BRAZIL, alpha=0.95)
    ax_share.set_ylim(0, 50)
    ax_share.set_yticks([0, 10, 20, 30, 40, 50])
    ax_share.set_yticklabels(["0%", "10%", "20%", "30%", "40%", "50%"])
    ax_share.set_xticks(x)
    ax_share.set_xticklabels([])
    for bars, values, color in ((bars_o, data["Overall"]["share"], OVERALL), (bars_b, data["Brazil"]["share"], BRAZIL)):
        for bar_obj, value in zip(bars, values):
            ax_share.text(
                bar_obj.get_x() + bar_obj.get_width() / 2, bar_obj.get_height() + 0.7,
                f"{value:.1f}%", ha="center", va="bottom", fontsize=9.5, color=color,
                weight="semibold" if color == BRAZIL else "normal",
            )

    ax_check = fig.add_axes([0.075, 0.135, 0.85, 0.245])
    style_axis(ax_check)
    ax_check.set_title("对应进入打勾率", loc="left", pad=18, fontsize=16, color=INK, weight="semibold")
    ax_check.plot(x, data["Overall"]["check"], color=OVERALL, linewidth=2.4, marker="o", markersize=6)
    ax_check.plot(x, data["Brazil"]["check"], color=BRAZIL, linewidth=2.8, marker="o", markersize=6.5)
    ax_check.set_ylim(45, 80)
    ax_check.set_yticks([50, 60, 70, 80])
    ax_check.set_yticklabels(["50%", "60%", "70%", "80%"])
    ax_check.set_xticks(x)
    ax_check.set_xticklabels(BANDS, fontsize=12.5, color=INK)
    ax_check.set_xlabel("首次点击前曝光的不同素材数", color=MUTED, fontsize=11.5, labelpad=12)
    for market, color, dy in (("Overall", OVERALL, -1.8), ("Brazil", BRAZIL, 1.5)):
        for xi, value in zip(x, data[market]["check"]):
            ax_check.text(
                xi, value + dy, f"{value:.1f}%", ha="center", va="center", fontsize=9.2,
                color=color, weight="semibold" if market == "Brazil" else "normal",
            )

    fig.text(
        0.055, 0.025,
        "口径：分布分母为发生点击的 Filters 进入轮次；仅计事件时间严格早于首次点击的不同曝光素材。同秒曝光无法判序，巴西32.1%、整体34.1%的有点击轮次受到影响，因此均值为保守下限。",
        fontsize=10.3, color=MUTED,
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.18)
    plt.close(fig)
    print(OUTPUT)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""将 Filters 选择效率结论拆成两张独立高清 PNG。"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib import font_manager
from matplotlib.patches import FancyBboxPatch
from matplotlib.ticker import PercentFormatter


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"

BG = "#F3F6FA"
CARD = "#FFFFFF"
INK = "#182235"
MUTED = "#7F8DA3"
GRID = "#E2E8F0"
BRAZIL = "#EC4D43"
ORANGE = "#ED8A17"
TEAL = "#22A087"
BLUE = "#4777D8"
PALE = "#E8EDF4"


def configure_font():
    names = ["PingFang SC", "PingFang HK", "Heiti SC", "Arial Unicode MS", "DejaVu Sans"]
    available = {f.name for f in font_manager.fontManager.ttflist}
    for name in names:
        if name in available:
            plt.rcParams["font.sans-serif"] = [name]
            break
    plt.rcParams["axes.unicode_minus"] = False


def add_card(fig, x, y, w, h):
    fig.add_artist(FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.008,rounding_size=0.018",
        transform=fig.transFigure, facecolor=CARD, edgecolor=GRID,
        linewidth=0.9, zorder=0,
    ))


def base(title, subtitle):
    fig = plt.figure(figsize=(16, 9), facecolor=BG)
    fig.text(0.05, 0.935, title, color=INK, fontsize=30, fontweight="bold", va="center")
    fig.text(0.05, 0.885, subtitle, color=MUTED, fontsize=13, va="center")
    return fig


def clean_axis(ax):
    for side in ["top", "right"]:
        ax.spines[side].set_visible(False)
    ax.spines["left"].set_color(GRID)
    ax.spines["bottom"].set_color(GRID)
    ax.grid(axis="y", color=GRID, linewidth=1)
    ax.set_axisbelow(True)
    ax.tick_params(length=0, colors=MUTED, labelsize=11)


def chart_click_depth():
    src = pd.read_csv(OUT / "06D_Filters每次进入点击不同素材数分布与打勾率_分层.csv")
    d = src[
        (src["country_group"] == "Brazil")
        & (src["segment_dimension"] == "overall")
        & (src["segment_value"] == "ALL")
    ].copy()
    d["bucket"] = d["distinct_click_material_bucket"].astype(str)

    rows = []
    for bucket in ["1", "2", "3", "4"]:
        r = d[d["bucket"] == bucket].iloc[0]
        rows.append((f"点击 {bucket} 个", float(r["entry_check_rate"]) * 100, float(r["entry_share"]) * 100))
    ge5 = d[d["bucket"].isin(["5", "6", "7", "8", "9", "10+"])]
    ge5_count = ge5["filter_entry_count"].sum()
    rows.append((
        "点击 ≥5 个",
        ge5["checked_entry_count"].sum() / ge5_count * 100,
        ge5_count / d["filter_entry_count"].sum() * 100,
    ))

    labels = [r[0] for r in rows]
    check_rates = [r[1] for r in rows]
    shares = [r[2] for r in rows]

    fig = base(
        "点击素材越多，打勾率越低",
        "巴西｜2026/7/29–8/4｜每次进入 Filters 内点击的不同素材数；轮次占比的分母为全部 Filters 进入轮次",
    )
    fig.text(0.05, 0.835, "超过 1/3 的进入轮次会点击至少 5 个素材",
             color=BRAZIL, fontsize=16, fontweight="bold")
    add_card(fig, 0.045, 0.12, 0.91, 0.69)
    ax = fig.add_axes([0.11, 0.23, 0.81, 0.49])
    x = np.arange(len(labels))
    colors = ["#76B6A8", "#93BCAF", "#EAB368", "#E69A70", BRAZIL]
    ax.axvspan(3.48, 4.52, color="#FFF0EE", zorder=0)
    bars = ax.bar(x, check_rates, width=[0.58, 0.58, 0.58, 0.58, 0.72], color=colors, zorder=3)
    bars[-1].set_edgecolor("#B92D2D")
    bars[-1].set_linewidth(3.5)
    clean_axis(ax)
    ax.set_ylim(0, 90)
    ax.set_xticks(x, labels, color=INK, fontsize=13)
    ax.yaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))
    ax.set_ylabel("打勾率", color=INK, fontsize=13, labelpad=15, fontweight="bold")

    # 打勾率置于柱顶；轮次占比保留在柱体内部。
    for idx, (bar, rate, share) in enumerate(zip(bars, check_rates, shares)):
        cx = bar.get_x() + bar.get_width() / 2
        ax.text(cx, rate + 1.8, f"打勾率 {rate:.1f}%", ha="center", va="bottom",
                color=BRAZIL if idx == 4 else INK, fontsize=13.5, fontweight="bold")
        share_text = f"轮次占比\n{share:.1f}%"
        ax.text(cx, rate * (0.48 if idx < 4 else 0.45), share_text, ha="center", va="center",
                color="white", fontsize=12.5 if idx < 4 else 15,
                fontweight="normal" if idx < 4 else "bold", linespacing=1.25)

    # 进一步强化最后一档的类别标签。
    last_tick = ax.get_xticklabels()[-1]
    last_tick.set_color(BRAZIL)
    last_tick.set_fontweight("bold")

    fig.text(0.05, 0.065,
             "说明：未点击素材的进入轮次占 27.8%，未在柱图中展示；“点击 ≥5 个”合并 5、6、7、8、9、10+。",
             color=MUTED, fontsize=11.5)

    path = OUT / "12A_点击素材越多打勾率越低.png"
    fig.savefig(path, dpi=180, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    print(path)


def aggregate_preclick(d, low, high=None):
    nums = pd.to_numeric(d["pre_click_exposure_bucket"], errors="coerce")
    mask = nums >= low
    if high is not None:
        mask &= nums <= high
    s = d[mask]
    return {
        "count": float(s["clicked_entry_count"].sum()),
        "checked": float(s["checked_entry_count"].sum()),
        "entry": float(s["filter_entry_count"].sum()),
        "exposure_sum": float(s["pre_click_exposure_material_sum"].sum()),
    }


def chart_first_click():
    src = pd.read_csv(OUT / "06J_Filters首次点击前曝光不同素材数分布_分层.csv")
    data = {}
    averages = {}
    for market in ["Brazil", "Overall"]:
        d = src[
            (src["country_group"] == market)
            & (src["segment_dimension"] == "overall")
            & (src["segment_value"] == "ALL")
        ].copy()
        total_clicked = float(d["clicked_entry_count"].sum())
        averages[market] = float(d["pre_click_exposure_material_sum"].sum()) / total_clicked
        groups = [aggregate_preclick(d, 1, 5), aggregate_preclick(d, 6, 10), aggregate_preclick(d, 11)]
        data[market] = [
            (g["count"] / total_clicked * 100, g["checked"] / g["entry"] * 100)
            for g in groups
        ]

    labels = [
        "曝光1–5个素材（首屏）后首次点击",
        "曝光6–10个素材（次屏）后首次点击",
        "曝光11个及以上素材后首次点击",
    ]
    shares = [v[0] for v in data["Brazil"]]
    rates = [v[1] for v in data["Brazil"]]

    fig = base(
        "首次选择主要发生在前两屏",
        "巴西｜2026/7/29–8/4｜仅统计发生素材点击的 Filters 进入轮次；曝光素材按首次点击前不同素材去重",
    )

    # KPI 卡
    add_card(fig, 0.05, 0.73, 0.27, 0.105)
    fig.text(0.07, 0.795, "首次点击前平均曝光", fontsize=11.5, color=MUTED)
    fig.text(0.07, 0.755, f"巴西 {averages['Brazil']:.2f} 个", fontsize=20, color=BRAZIL, fontweight="bold")
    fig.text(0.20, 0.755, f"整体 {averages['Overall']:.2f} 个", fontsize=14, color=MUTED)

    add_card(fig, 0.34, 0.73, 0.22, 0.105)
    fig.text(0.36, 0.795, "前两屏完成首次点击", fontsize=11.5, color=MUTED)
    fig.text(0.36, 0.753, f"{shares[0] + shares[1]:.1f}%", fontsize=22, color=BRAZIL, fontweight="bold")

    add_card(fig, 0.58, 0.73, 0.37, 0.105)
    fig.text(0.60, 0.795, "解读", fontsize=11.5, color=MUTED)
    fig.text(0.60, 0.755, "重点提升前两屏的整体匹配质量", fontsize=16, color=INK, fontweight="bold")

    # 左：首次点击轮次占比
    add_card(fig, 0.045, 0.13, 0.53, 0.55)
    fig.text(0.07, 0.635, "首次点击轮次占比", fontsize=17, color=INK, fontweight="bold")
    ax1 = fig.add_axes([0.22, 0.22, 0.31, 0.35])
    y = np.arange(len(labels))
    bars1 = ax1.barh(y, shares, color=[BRAZIL, ORANGE, BLUE], height=0.52)
    ax1.set_xlim(0, 48)
    ax1.set_yticks(y, labels, color=INK, fontsize=11.5)
    ax1.invert_yaxis()
    ax1.xaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))
    ax1.grid(axis="x", color=GRID, linewidth=1)
    ax1.set_axisbelow(True)
    for s in ax1.spines.values():
        s.set_visible(False)
    ax1.tick_params(length=0, colors=MUTED)
    for bar, v in zip(bars1, shares):
        ax1.text(v - 0.8 if v > 8 else v + 0.7, bar.get_y() + bar.get_height()/2,
                 f"{v:.1f}%", va="center", ha="right" if v > 8 else "left",
                 color="white" if v > 8 else MUTED, fontsize=12, fontweight="bold")

    # 右：对应打勾率
    add_card(fig, 0.595, 0.13, 0.36, 0.55)
    fig.text(0.62, 0.635, "对应进入打勾率", fontsize=17, color=INK, fontweight="bold")
    ax2 = fig.add_axes([0.64, 0.22, 0.27, 0.35])
    bars2 = ax2.barh(y, rates, color=[BRAZIL, ORANGE, BLUE], height=0.52)
    ax2.set_xlim(0, 80)
    ax2.set_yticks([])
    ax2.invert_yaxis()
    ax2.xaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))
    ax2.grid(axis="x", color=GRID, linewidth=1)
    ax2.set_axisbelow(True)
    for s in ax2.spines.values():
        s.set_visible(False)
    ax2.tick_params(length=0, colors=MUTED)
    for bar, v in zip(bars2, rates):
        ax2.text(v - 1.2, bar.get_y() + bar.get_height()/2, f"{v:.1f}%",
                 va="center", ha="right", color="white", fontsize=12, fontweight="bold")

    path = OUT / "12B_首次选择主要发生在前两屏.png"
    fig.savefig(path, dpi=180, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    print(path)


def main():
    configure_font()
    chart_click_depth()
    chart_first_click()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""生成巴西滤镜专项的 5 张结论型汇报图。"""

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
GRID = "#E3E9F1"
BRAZIL = "#E94E42"
OVERALL = "#A6B1C1"
ORANGE = "#E78A20"
ORANGE_BG = "#FFF4E5"
BLUE = "#3A70D8"
TEAL = "#1FA187"
GREEN = "#278B68"


def configure_font():
    candidates = [
        "PingFang SC", "PingFang HK", "Heiti SC", "Microsoft YaHei",
        "Arial Unicode MS", "Noto Sans CJK SC", "DejaVu Sans",
    ]
    available = {f.name for f in font_manager.fontManager.ttflist}
    for name in candidates:
        if name in available:
            plt.rcParams["font.sans-serif"] = [name]
            break
    plt.rcParams["axes.unicode_minus"] = False


def add_card(fig, x, y, w, h, radius=0.018, face=CARD, edge=GRID, lw=0.8):
    patch = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0.008,rounding_size={radius}",
        linewidth=lw, edgecolor=edge, facecolor=face,
        transform=fig.transFigure, zorder=0,
    )
    fig.add_artist(patch)
    return patch


def base_figure(no, title, subtitle):
    fig = plt.figure(figsize=(16, 9), facecolor=BG)
    fig.text(
        0.045, 0.948, f"结论 {no}", ha="left", va="center", fontsize=13,
        color="white", fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.42", facecolor=BRAZIL, edgecolor="none"),
    )
    fig.text(0.13, 0.95, title, ha="left", va="center", fontsize=27,
             color=INK, fontweight="bold")
    fig.text(0.045, 0.902, subtitle, ha="left", va="center", fontsize=12.5, color=MUTED)
    return fig


def add_recommendation(fig, text):
    add_card(fig, 0.045, 0.035, 0.91, 0.075, face=ORANGE_BG, edge="#F2D5A7")
    fig.text(0.065, 0.073, "建议", fontsize=14, color=ORANGE, fontweight="bold", va="center")
    fig.text(0.115, 0.073, text, fontsize=13, color=INK, va="center")


def style_axis(ax, ymax=None, percent=True):
    ax.set_facecolor("none")
    for s in ax.spines.values():
        s.set_visible(False)
    ax.grid(axis="y", color=GRID, linewidth=1)
    ax.set_axisbelow(True)
    ax.tick_params(axis="x", length=0, labelcolor=INK, labelsize=11)
    ax.tick_params(axis="y", length=0, labelcolor=MUTED, labelsize=10)
    if ymax is not None:
        ax.set_ylim(0, ymax)
    if percent:
        ax.yaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))


def label_bars(ax, bars, suffix="%", color=INK, decimals=1, dy=0.8):
    for b in bars:
        val = b.get_height()
        ax.text(
            b.get_x() + b.get_width() / 2, val + dy,
            f"{val:.{decimals}f}{suffix}", ha="center", va="bottom",
            fontsize=11, color=color, fontweight="bold",
        )


def save(fig, filename):
    path = OUT / filename
    fig.savefig(path, dpi=180, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    print(path)


def chart_1():
    fig = base_figure(
        1,
        "巴西更愿意尝试滤镜，“甜美”偏好突出，但收入更依赖头部素材",
        "2026年7月｜巴西 vs 整体｜行为漏斗、分类偏好与订阅收入结构",
    )

    # 卡片 1：整体漏斗
    add_card(fig, 0.045, 0.20, 0.285, 0.64)
    fig.text(0.065, 0.805, "滤镜素材尝试意愿", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.065, 0.773, "两段转化均略高于整体", fontsize=11.5, color=GREEN)
    ax = fig.add_axes([0.075, 0.34, 0.23, 0.38])
    labels = ["曝光→点击", "点击→打勾"]
    br = [48.3, 6.4]
    ov = [47.3, 6.0]
    x = np.arange(2)
    width = 0.28
    b1 = ax.bar(x - width / 2, br, width, color=BRAZIL, zorder=3, label="巴西")
    b2 = ax.bar(x + width / 2, ov, width, color=OVERALL, zorder=3, label="整体")
    style_axis(ax, 56)
    ax.set_xticks(x, labels)
    label_bars(ax, b1, color=BRAZIL, dy=1.1)
    label_bars(ax, b2, color=MUTED, dy=1.1)
    ax.legend(frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.14), fontsize=10)
    fig.text(0.187, 0.265, "巴西用户愿意点、也愿意试", ha="center", fontsize=13,
             color=INK, fontweight="bold")

    # 卡片 2：甜美偏好
    add_card(fig, 0.35, 0.20, 0.285, 0.64)
    fig.text(0.37, 0.805, "“分类-甜美”偏好", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.37, 0.773, "占比和转化同时领先", fontsize=11.5, color=GREEN)
    ax = fig.add_axes([0.38, 0.34, 0.23, 0.38])
    labels = ["打勾占比", "点击→打勾"]
    br = [18.3, 11.0]
    ov = [16.8, 9.1]
    x = np.arange(2)
    b1 = ax.bar(x - width / 2, br, width, color=BRAZIL, zorder=3)
    b2 = ax.bar(x + width / 2, ov, width, color=OVERALL, zorder=3)
    style_axis(ax, 23)
    ax.set_xticks(x, labels)
    label_bars(ax, b1, color=BRAZIL, dy=0.45)
    label_bars(ax, b2, color=MUTED, dy=0.45)
    fig.text(0.492, 0.265, "“甜美”是更明确的本地化方向", ha="center", fontsize=13,
             color=INK, fontweight="bold")

    # 卡片 3：收入集中
    add_card(fig, 0.655, 0.20, 0.30, 0.64)
    fig.text(0.675, 0.805, "订阅收入集中度", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.675, 0.773, "Glow-4、FJ-1、iP 8 合计", fontsize=11.5, color=MUTED)
    ax = fig.add_axes([0.69, 0.38, 0.23, 0.29])
    y = [1, 0]
    top3 = [69, 60]
    other = [31, 40]
    ax.barh(y, top3, color=[BRAZIL, OVERALL], height=0.34)
    ax.barh(y, other, left=top3, color="#E9EDF3", height=0.34)
    ax.set_xlim(0, 100)
    ax.set_yticks(y, ["巴西", "整体"])
    ax.set_xticks([])
    ax.tick_params(axis="y", length=0, labelsize=12, colors=INK)
    for s in ax.spines.values():
        s.set_visible(False)
    for yi, v in zip(y, top3):
        ax.text(v / 2, yi, f"Top3  {v}%", ha="center", va="center",
                color="white" if yi == 1 else INK, fontsize=13, fontweight="bold")
        ax.text(v + (100 - v) / 2, yi, f"其他 {100-v}%", ha="center", va="center",
                color=MUTED, fontsize=10.5)
    fig.text(0.805, 0.695, "巴西比整体高 9pp", ha="center", fontsize=15,
             color=BRAZIL, fontweight="bold")
    fig.text(0.805, 0.295, "收入增长更依赖少数爆款", ha="center", fontsize=13,
             color=INK, fontweight="bold")

    add_recommendation(
        fig,
        "围绕“甜美”及 FJ-1、iP 8 的视觉特征扩充相似素材，并增加可验证的付费供给，降低收入对 Top3 的依赖。",
    )
    save(fig, "11A_结论1_巴西素材偏好与收入集中.png")


def chart_2():
    fig = base_figure(
        2,
        "前两屏决定主要选择效率；点击越深，越可能是“还没找到喜欢的”",
        "2026/7/29–8/4｜按单次进入 Filters 统计｜点击/曝光素材数均按不同素材去重",
    )

    add_card(fig, 0.045, 0.20, 0.43, 0.64)
    fig.text(0.065, 0.805, "连续尝试越多，打勾率越低", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.065, 0.772, "34.5% 的进入轮次会点击至少 5 个素材", fontsize=11.5, color=BRAZIL)
    ax = fig.add_axes([0.08, 0.33, 0.36, 0.37])
    labels = ["点击 1 个", "点击 2 个", "点击 ≥5 个"]
    vals = [78.4, 65.8, 59.7]
    colors = [TEAL, ORANGE, BRAZIL]
    bars = ax.bar(np.arange(3), vals, width=0.54, color=colors, zorder=3)
    style_axis(ax, 90)
    ax.set_xticks(np.arange(3), labels)
    label_bars(ax, bars, color=INK, dy=1.5, decimals=1)
    ax.text(2, 49, "仍有 34.5% 的轮次落在这里", ha="center", va="center", fontsize=11,
            color=BRAZIL, bbox=dict(boxstyle="round,pad=0.35", facecolor="#FFF0EE", edgecolor="none"))
    fig.text(0.26, 0.265, "从 1 个到 ≥5 个，打勾率下降 18.7pp", ha="center",
             fontsize=13, color=INK, fontweight="bold")

    add_card(fig, 0.495, 0.20, 0.46, 0.64)
    fig.text(0.515, 0.805, "首次选择主要发生在前两屏", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.515, 0.772, "首次点击前平均曝光：巴西 7.16 个｜整体 7.52 个", fontsize=11.5, color=MUTED)

    # 82% 的首次点击发生在前两屏
    ax = fig.add_axes([0.54, 0.59, 0.37, 0.10])
    shares = [38.9, 42.6, 18.5]
    starts = np.cumsum([0] + shares[:-1])
    cols = [BRAZIL, ORANGE, "#DDE3EC"]
    for s, v, c in zip(starts, shares, cols):
        ax.barh([0], [v], left=[s], color=c, height=0.42)
    ax.set_xlim(0, 100)
    ax.axis("off")
    for s, v, lab in zip(starts, shares, ["首屏 1–5", "次屏 6–10", "11+"]):
        ax.text(s + v/2, 0, f"{lab}\n{v:.1f}%", ha="center", va="center",
                color="white" if lab != "11+" else INK, fontsize=11, fontweight="bold")
    fig.text(0.725, 0.715, "82%", ha="center", fontsize=21, color=BRAZIL, fontweight="bold")
    fig.text(0.725, 0.69, "的首次点击发生在前两屏", ha="center", fontsize=11.5, color=INK)

    ax = fig.add_axes([0.56, 0.34, 0.33, 0.18])
    groups = ["首屏后首次点击", "次屏后首次点击"]
    check = [62.6, 67.3]
    bars = ax.bar(np.arange(2), check, color=[BRAZIL, ORANGE], width=0.48)
    style_axis(ax, 78)
    ax.set_xticks(np.arange(2), groups)
    label_bars(ax, bars, color=INK, dy=1.2)
    ax.set_title("对应进入打勾率", color=MUTED, fontsize=11, pad=8)
    fig.text(0.725, 0.265, "不必只追求首屏点击，更应优化前两屏整体匹配", ha="center",
             fontsize=13, color=INK, fontweight="bold")

    add_recommendation(
        fig,
        "前两屏优先布置高匹配素材；当用户已连续点击 5 个仍未打勾时，触发分类快捷入口、相似推荐或轻量原因反馈。",
    )
    save(fig, "11B_结论2_前两屏与选择成本.png")


def chart_3():
    df = pd.read_csv(OUT / "09_巴西与整体D1滤镜复用_曝光Top30.csv")
    x = df["巴西曝光UV日均"].astype(float).to_numpy()
    y = df["巴西D1打勾的相同滤镜占比"].astype(float).to_numpy() * 100
    names = df["素材名称"].astype(str).to_numpy()

    # 图 1：先说明整体复用水平，以及回访用户中的同素材复用。
    fig = plt.figure(figsize=(16, 9), facecolor=BG)

    add_card(fig, 0.045, 0.05, 0.43, 0.90)
    fig.text(0.070, 0.900, "D1再次打勾任一滤镜", fontsize=20, color=INK, fontweight="bold")
    fig.text(0.070, 0.855, "分母：首日打勾滤镜的用户", fontsize=13, color=MUTED)
    ax = fig.add_axes([0.10, 0.365, 0.32, 0.39])
    bars = ax.bar([0, 1], [27.4, 27.7], color=[BRAZIL, OVERALL], width=0.5)
    style_axis(ax, 34)
    ax.set_xticks([0, 1], ["巴西", "整体"])
    label_bars(ax, bars, color=INK, dy=0.7)
    ax.axhline(27.7, color=OVERALL, lw=1, ls="--", alpha=0.7)
    fig.text(0.260, 0.245, "差异仅 -0.3pp，巴西与整体基本持平", ha="center",
             fontsize=14, color=GREEN, fontweight="bold")

    add_card(fig, 0.495, 0.05, 0.46, 0.90)
    fig.text(0.520, 0.900, "D1回访用户继续选择同一素材", fontsize=20,
             color=INK, fontweight="bold")
    fig.text(0.520, 0.855, "分母：D1再次打勾任一滤镜的回访用户", fontsize=13, color=MUTED)
    fig.text(0.725, 0.690, "38.0%", ha="center", fontsize=48,
             color=BRAZIL, fontweight="bold")
    fig.text(0.725, 0.625, "继续选择同一素材", ha="center", fontsize=18,
             color=INK, fontweight="bold")
    ax = fig.add_axes([0.56, 0.445, 0.33, 0.085])
    ax.barh([0], [38.0], color=BRAZIL, height=0.55)
    ax.barh([0], [62.0], left=[38.0], color="#E8EDF3", height=0.55)
    ax.set_xlim(0, 100)
    ax.axis("off")
    ax.text(19, 0, "同一素材 38%", ha="center", va="center", color="white",
            fontsize=13, fontweight="bold")
    ax.text(69, 0, "其他素材 62%", ha="center", va="center", color=MUTED,
            fontsize=12, fontweight="bold")
    fig.text(0.725, 0.325, "每100名D1滤镜回访用户中，约38名延续原有素材偏好",
             ha="center", fontsize=14, color=INK, fontweight="bold")
    save(fig, "11C1_结论3_D1复用与固定偏好.png")

    # 图 2：展示曝光与同素材复用的关系，并突出低曝光高复用素材。
    fig = plt.figure(figsize=(16, 9), facecolor=BG)
    add_card(fig, 0.045, 0.05, 0.91, 0.90)
    fig.text(0.070, 0.900, "曝光与同素材复用率", fontsize=20, color=INK, fontweight="bold")
    fig.text(0.070, 0.855, "高曝光素材通常具有较高的复用率，但部分中腰部曝光素材也有较高的复用率", fontsize=13,
             color=GREEN, fontweight="bold")
    ax = fig.add_axes([0.11, 0.255, 0.80, 0.50])
    ax.scatter(x, y, s=42, color="#B9C3D1", alpha=0.85, zorder=2)
    # 趋势线仅用于辅助展示整体相关方向。
    coef = np.polyfit(x, y, 1)
    trend_x = np.linspace(x.min(), x.max(), 100)
    ax.plot(trend_x, coef[0] * trend_x + coef[1], color="#66758B", lw=1.5,
            ls="--", alpha=0.8, zorder=1)
    # 高曝光、高复用的头部素材。
    head_offsets = {"Glow-4": (7, 9), "FJ-1": (7, -17), "Bora": (7, 8)}
    for target in ["Glow-4", "FJ-1", "Bora"]:
        m = names == target
        if m.any():
            ax.scatter(x[m], y[m], s=90, color=BRAZIL, zorder=4)
            ax.annotate(target, (x[m][0], y[m][0]), xytext=head_offsets[target], textcoords="offset points",
                        fontsize=10, color=BRAZIL, fontweight="bold")
    # 低曝光高复用
    potential_offsets = {"Rosy": (10, 10), "Iceland": (10, -16)}
    for target in ["Rosy", "Iceland"]:
        m = names == target
        if m.any():
            ax.scatter(x[m], y[m], s=110, color=ORANGE, edgecolor="white", linewidth=1.2, zorder=5)
            ax.annotate(
                f"{target}  {y[m][0]:.1f}%", (x[m][0], y[m][0]), xytext=potential_offsets[target],
                textcoords="offset points", fontsize=11, color=ORANGE, fontweight="bold",
                arrowprops=dict(arrowstyle="-", color=ORANGE, lw=1),
            )
    ax.axhline(40, color=ORANGE, lw=1, ls="--", alpha=0.7)
    ax.axvline(np.median(x), color=GRID, lw=1, ls="--", alpha=0.9)
    ax.text(x.min(), 40.8, "同素材复用 40%", color=ORANGE, fontsize=10)
    ax.text(np.median(x) - 800, 60.2, "曝光中位数", color=MUTED, fontsize=9,
            ha="right")
    ax.set_xlabel("巴西日均曝光 UV", color=MUTED, fontsize=11)
    ax.set_ylabel("D1回访者继续选择同素材", color=MUTED, fontsize=11)
    style_axis(ax, percent=True)
    ax.set_ylim(15, max(62, y.max() + 4))
    ax.yaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))
    fig.text(0.510, 0.155, "Rosy、Iceland 日均曝光仅约1.5万，但同素材复用率分别为45.9%、45.5%",
             ha="center",
             fontsize=13, color=INK, fontweight="bold")
    save(fig, "11C2_结论3_低曝光高复用素材.png")


def chart_4():
    fig = base_figure(
        4,
        "平台与生命周期差异明显：iOS强化头部，Android和新用户降低选择成本",
        "2026年7月｜巴西平台与用户生命周期对比｜复用指标按打勾用户计算",
    )

    add_card(fig, 0.045, 0.20, 0.44, 0.64)
    fig.text(0.065, 0.805, "平台策略：iOS更集中，Android探索更深", fontsize=17, color=INK, fontweight="bold")
    ax = fig.add_axes([0.08, 0.42, 0.36, 0.28])
    metrics = ["Top5打勾占比", "D1任一滤镜", "D1同素材"]
    ios = [49.7, 28.3, 40.2]
    android = [39.6, 25.7, 34.0]
    x = np.arange(3)
    w = 0.28
    b1 = ax.bar(x - w/2, ios, w, color=BLUE, label="iOS", zorder=3)
    b2 = ax.bar(x + w/2, android, w, color=TEAL, label="Android", zorder=3)
    style_axis(ax, 58)
    ax.set_xticks(x, metrics)
    label_bars(ax, b1, color=BLUE, dy=0.9)
    label_bars(ax, b2, color=TEAL, dy=0.9)
    ax.legend(frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.16))

    fig.text(0.12, 0.337, "单次平均点击", fontsize=11.5, color=MUTED)
    fig.text(0.12, 0.292, "6.9 个", fontsize=22, color=BLUE, fontweight="bold")
    fig.text(0.31, 0.337, "单次平均点击", fontsize=11.5, color=MUTED)
    fig.text(0.31, 0.292, "8.3 个", fontsize=22, color=TEAL, fontweight="bold")
    fig.text(0.265, 0.245, "Android 浏览更深；iOS 更容易锁定头部与固定偏好", ha="center",
             fontsize=12.5, color=INK, fontweight="bold")

    add_card(fig, 0.505, 0.20, 0.45, 0.64)
    fig.text(0.525, 0.805, "生命周期策略：新用户探索多，但偏好沉淀弱", fontsize=17, color=INK, fontweight="bold")
    ax = fig.add_axes([0.55, 0.42, 0.36, 0.28])
    groups = ["渠道新用户", "自然新用户", "老用户"]
    d1_any = [10.8, 13.6, 27.9]
    d1_same = [23.9, 29.7, 38.2]
    x = np.arange(3)
    b1 = ax.bar(x - w/2, d1_any, w, color=ORANGE, label="D1任一滤镜", zorder=3)
    b2 = ax.bar(x + w/2, d1_same, w, color=BRAZIL, label="D1同素材", zorder=3)
    style_axis(ax, 46)
    ax.set_xticks(x, groups)
    label_bars(ax, b1, color=ORANGE, dy=0.8)
    label_bars(ax, b2, color=BRAZIL, dy=0.8)
    ax.legend(frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.16))
    fig.text(0.73, 0.347, "素材偏好", ha="center", fontsize=12, color=MUTED)
    fig.text(0.73, 0.307, "渠道新：iP 8 / Ibiza　｜　自然新：Glow-4 / FJ-1",
             ha="center", fontsize=12.5, color=INK, fontweight="bold")
    fig.text(0.73, 0.265, "自然新用户 Top3 占 37.0%；老用户仅 31.5%，偏好更分散",
             ha="center", fontsize=11.5, color=MUTED)

    add_recommendation(
        fig,
        "iOS强化头部排序；Android保留中腰部并加强分类/快速筛选。自然新用户先展示高认知头部，渠道新用户按投放风格承接。",
    )
    save(fig, "11D_结论4_平台与生命周期差异.png")


def chart_5():
    slider = pd.read_csv(OUT / "05_巴西Top20滤镜滑杆值分布.csv")
    targets = ["Sour", "Clean", "Iceland", "Rosy", "Classic"]
    rows = []
    for name in targets:
        sub = slider[(slider["市场"] == "巴西") & (slider["素材名称"] == name)].copy()
        sub = sub[sub["有效滑杆PV"] > 0]
        top = sub.sort_values("档位占比", ascending=False).iloc[0]
        rows.append((name, float(top["档位占比"]) * 100, int(top["滑杆档位"])))

    fig = base_figure(
        5,
        "默认强度体系整体可用；5款素材需要单独校准",
        "2026年7月｜按 material_check 打勾事件统计｜展示众数（与默认值重合）的事件占比，不使用默认来源字段",
    )

    add_card(fig, 0.045, 0.20, 0.30, 0.64)
    fig.text(0.065, 0.805, "整体判断", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.19, 0.665, "20%–40%", ha="center", fontsize=34, color=GREEN, fontweight="bold")
    fig.text(0.19, 0.62, "多数素材打勾集中在默认强度", ha="center", fontsize=13, color=INK)
    ax = fig.add_axes([0.09, 0.45, 0.20, 0.08])
    ax.barh([0], [20], left=[0], color="#E9EDF3", height=0.42)
    ax.barh([0], [20], left=[20], color="#B9E1D4", height=0.42)
    ax.barh([0], [30], left=[40], color="#E9EDF3", height=0.42)
    ax.set_xlim(0, 70)
    ax.axis("off")
    ax.text(30, 0, "常见区间", ha="center", va="center", color=GREEN, fontsize=11, fontweight="bold")
    fig.text(0.19, 0.37, "说明默认效果总体符合预期，\n或用户主动调节强度的意愿有限。",
             ha="center", fontsize=13, color=MUTED, linespacing=1.6)
    fig.text(0.19, 0.275, "维持整体体系，避免全量改动", ha="center", fontsize=13,
             color=INK, fontweight="bold")

    add_card(fig, 0.375, 0.20, 0.58, 0.64)
    fig.text(0.395, 0.805, "需要单独测试的素材", fontsize=17, color=INK, fontweight="bold")
    fig.text(0.395, 0.772, "众数占比过低 = 默认匹配弱；过高且在100 = 可能强度不足", fontsize=11.5, color=MUTED)
    ax = fig.add_axes([0.44, 0.32, 0.46, 0.38])
    names = [r[0] for r in rows]
    vals = [r[1] for r in rows]
    modes = [r[2] for r in rows]
    yy = np.arange(len(names))
    colors = [ORANGE if n != "Classic" else BRAZIL for n in names]
    bars = ax.barh(yy, vals, color=colors, height=0.53, zorder=3)
    ax.axvspan(20, 40, color="#DFF1EB", alpha=0.8, zorder=0)
    ax.set_xlim(0, 74)
    ax.set_yticks(yy, names)
    ax.invert_yaxis()
    for s in ax.spines.values():
        s.set_visible(False)
    ax.grid(axis="x", color=GRID, linewidth=1)
    ax.set_axisbelow(True)
    ax.tick_params(axis="x", length=0, colors=MUTED)
    ax.tick_params(axis="y", length=0, colors=INK, labelsize=12)
    ax.xaxis.set_major_formatter(PercentFormatter(xmax=100, decimals=0))
    for b, v, mode, name in zip(bars, vals, modes, names):
        ax.text(v + 1.0, b.get_y() + b.get_height()/2, f"{v:.1f}%  ｜ 众数 {mode}",
                va="center", fontsize=11, color=BRAZIL if name == "Classic" else ORANGE,
                fontweight="bold")
    fig.text(0.665, 0.255,
             "Sour / Clean / Iceland / Rosy：默认附近占比 <20%　｜　Classic：65.9% 集中在强度100",
             ha="center", fontsize=12.5, color=INK, fontweight="bold")

    add_recommendation(
        fig,
        "保持整体默认强度不变；对 Sour、Clean、Iceland、Rosy 测试更匹配的默认值，对 Classic 测试更强效果或扩展强度上限。",
    )
    save(fig, "11E_结论5_滑杆默认强度机会.png")


def main():
    configure_font()
    OUT.mkdir(parents=True, exist_ok=True)
    chart_1()
    chart_2()
    chart_3()
    chart_4()
    chart_5()


if __name__ == "__main__":
    main()

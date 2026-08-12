#!/usr/bin/env python3
"""生成巴西 vs 整体的全素材平均漏斗与各自打勾 Top20 素材表。"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
INPUT = OUT / "素材市场对比_巴西vs整体.csv"
OUTPUT = OUT / "04_巴西与整体滤镜全素材及Top20指标.png"
TOP20_OUTPUT = OUT / "04_巴西与整体各自打勾Top20素材.csv"

BG = "#F4F6FA"
CARD = "#FFFFFF"
TEXT = "#182235"
MUTED = "#8794A8"
LINE = "#E1E6EE"
BRAZIL = "#E14B3F"
OVERALL = "#65748A"
GREEN = "#169B62"
HEADER = "#F7F9FC"
BRAZIL_BAR = "#F5A49D"
OVERALL_BAR = "#CBD3DF"

RATES = [
    ("曝光点击率", "曝光uv", "点击uv"),
    ("点击打勾率", "点击uv", "打勾uv"),
    ("打勾保存率", "打勾uv", "保存uv"),
]


def setup_style() -> None:
    plt.rcParams.update(
        {
            "font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "figure.facecolor": BG,
            "savefig.facecolor": BG,
        }
    )


def load_data() -> pd.DataFrame:
    df = pd.read_csv(INPUT, encoding="utf-8-sig")
    for market in ["巴西", "整体"]:
        for key in ["曝光uv", "点击uv", "打勾uv", "保存uv", "订阅收入"]:
            col = f"{key}_{market}"
            df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    df["素材名称"] = df["素材名称"].fillna(df["素材id"])
    df["分类名称"] = df["分类名称"].fillna("未分类")
    return df


def material_rates(df: pd.DataFrame, market: str) -> pd.DataFrame:
    out = df.copy()
    for label, denominator, numerator in RATES:
        den = out[f"{denominator}_{market}"]
        out[f"{label}_{market}"] = (out[f"{numerator}_{market}"] / den).where(den > 0)
    total_check = out[f"打勾uv_{market}"].sum()
    out[f"打勾uv占比_{market}"] = out[f"打勾uv_{market}"] / total_check if total_check > 0 else float("nan")
    total_revenue = out[f"订阅收入_{market}"].sum()
    out[f"订阅收入占比_{market}"] = out[f"订阅收入_{market}"] / total_revenue if total_revenue > 0 else 0
    return out


def mean_rates(df: pd.DataFrame, market: str) -> dict[str, float]:
    """按各环节分母加权：分子总和 / 分母总和。"""
    result = {}
    for label, denominator, numerator in RATES:
        den = float(df[f"{denominator}_{market}"].sum())
        result[label] = float(df[f"{numerator}_{market}"].sum()) / den if den > 0 else float("nan")
    return result


def top20(df: pd.DataFrame, market: str) -> pd.DataFrame:
    top = df.sort_values(f"打勾uv_{market}", ascending=False).head(20).copy()
    top.insert(0, "市场", market)
    top.insert(1, "排名", range(1, len(top) + 1))
    return top


def category_summary(df: pd.DataFrame) -> pd.DataFrame:
    """按分类聚合两市场指标，并计算分类漏斗与保存占比。"""
    metrics = ["曝光uv", "点击uv", "打勾uv", "保存uv", "订阅收入"]
    columns = [f"{metric}_{market}" for market in ["巴西", "整体"] for metric in metrics]
    out = df.groupby("分类名称", as_index=False)[columns].sum()
    for market in ["巴西", "整体"]:
        out[f"打勾uv占比_{market}"] = out[f"打勾uv_{market}"] / out[f"打勾uv_{market}"].sum()
        revenue_total = out[f"订阅收入_{market}"].sum()
        out[f"订阅收入占比_{market}"] = out[f"订阅收入_{market}"] / revenue_total if revenue_total > 0 else 0
        for label, denominator, numerator in RATES:
            den = out[f"{denominator}_{market}"]
            out[f"{label}_{market}"] = (out[f"{numerator}_{market}"] / den).where(den > 0)
    return out


def draw_dual_bar_cell(ax, x_left: float, x_right: float, y: float, row_h: float,
                       br_value: float, overall_value: float, max_value: float,
                       formatter) -> None:
    """单元格内绘制上巴西、下整体的双数据条及数值。"""
    usable = max(x_right - x_left, 0.001) * 0.62
    scale = max(max_value, 1e-12)
    bar_h = min(row_h * 0.13, 0.0032)
    br_y, overall_y = y + row_h * 0.15, y - row_h * 0.18
    br_w = usable * max(br_value, 0) / scale
    overall_w = usable * max(overall_value, 0) / scale
    if br_w > 0:
        ax.add_patch(FancyBboxPatch((x_left, br_y - bar_h / 2), br_w, bar_h, boxstyle=f"round,pad=0,rounding_size={bar_h / 2}", fc=BRAZIL_BAR, ec="none", alpha=0.78))
    if overall_w > 0:
        ax.add_patch(FancyBboxPatch((x_left, overall_y - bar_h / 2), overall_w, bar_h, boxstyle=f"round,pad=0,rounding_size={bar_h / 2}", fc=OVERALL_BAR, ec="none", alpha=0.85))
    ax.text(x_right, br_y, formatter(br_value), fontsize=6.9, color=BRAZIL, weight="bold", ha="right", va="center")
    ax.text(x_right, overall_y, formatter(overall_value), fontsize=5.8, color=OVERALL, ha="right", va="center")


def draw_dual_text_cell(ax, x_center: float, y: float, row_h: float,
                        br_value: float, overall_value: float, formatter) -> None:
    """无数据条：上方巴西红字，下方整体灰字。"""
    ax.text(x_center, y + row_h * 0.15, formatter(br_value), fontsize=6.9, color=BRAZIL, weight="bold", ha="center", va="center")
    ax.text(x_center, y - row_h * 0.18, formatter(overall_value), fontsize=5.8, color=OVERALL, ha="center", va="center")


def export_top20(br: pd.DataFrame, overall: pd.DataFrame) -> None:
    pieces = []
    for market, table in [("巴西", br), ("整体", overall)]:
        selected = table[
            [
                "市场", "排名", "素材id", "素材名称", "分类名称",
                f"打勾uv_{market}", f"打勾uv占比_{market}", f"曝光点击率_{market}",
                f"点击打勾率_{market}", f"打勾保存率_{market}", f"订阅收入_{market}",
            ]
        ].copy()
        selected.columns = [
            "市场", "排名", "素材id", "素材名称", "分类名称", "打勾UV日均", "打勾UV占比",
            "曝光点击率", "点击打勾率", "打勾保存率", "订阅收入日均",
        ]
        pieces.append(selected)
    pd.concat(pieces, ignore_index=True).to_csv(TOP20_OUTPUT, index=False, encoding="utf-8-sig")


def draw_rate_cards(ax, df: pd.DataFrame) -> None:
    br, overall = mean_rates(df, "巴西"), mean_rates(df, "整体")
    left, gap, width = 0.035, 0.018, 0.298
    y, h = 0.835, 0.085
    for idx, (label, _, _) in enumerate(RATES):
        x = left + idx * (width + gap)
        ax.add_patch(FancyBboxPatch((x, y), width, h, boxstyle="round,pad=0.006,rounding_size=0.010", fc=CARD, ec=LINE, lw=0.9))
        ax.text(x + 0.018, y + h - 0.026, label, fontsize=13, weight="bold", color=TEXT, va="center")
        ax.text(x + 0.018, y + 0.030, f"巴西  {br[label]:.1%}", fontsize=17, color=BRAZIL, va="center", weight="bold")
        ax.text(x + width - 0.018, y + 0.030, f"整体  {overall[label]:.1%}", fontsize=13, color=OVERALL, va="center", ha="right")
        gap_pp = (br[label] - overall[label]) * 100
        ax.text(x + width - 0.018, y + h - 0.026, f"Gap {gap_pp:+.1f}pp", fontsize=9.5, color=BRAZIL if gap_pp >= 0 else GREEN, va="center", ha="right", weight="bold")


def draw_category_module(ax, categories: pd.DataFrame, x: float, y: float, w: float, h: float) -> None:
    """整体分类 Top5 色块 + 巴西分类 Top5 同分类对比表。"""
    categories = categories.copy()
    categories["打勾排名_整体"] = categories["打勾uv_整体"].rank(method="min", ascending=False)
    br_top = categories.nlargest(5, "打勾uv_巴西")
    left_w, gap = 0.215, 0.015
    right_x, right_w = x + left_w + gap, w - left_w - gap

    ax.add_patch(FancyBboxPatch((x, y), left_w, h, boxstyle="round,pad=0.006,rounding_size=0.010", fc="#E9EEF6", ec=LINE, lw=0.9))
    ax.text(x + 0.014, y + h - 0.022, "整体排名｜按巴西 Top5 对齐", fontsize=11.5, weight="bold", color=OVERALL, va="center")
    row_top, row_h = y + h - 0.052, (h - 0.070) / 5
    for i, (_, row) in enumerate(br_top.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        if i % 2 == 0:
            ax.add_patch(Rectangle((x + 0.007, ry - row_h / 2), left_w - 0.014, row_h, fc="#F2F5FA", ec="none"))
        ax.text(x + 0.016, ry, f"{i:02d}", fontsize=7.7, color=MUTED, va="center")
        ax.text(x + 0.052, ry, str(row["分类名称"]), fontsize=8.8, color=TEXT, weight="bold" if i <= 3 else "normal", va="center")
        ax.text(x + left_w - 0.014, ry, f"整体 #{int(row['打勾排名_整体']):02d}", fontsize=7.8, color=OVERALL, ha="right", va="center")

    ax.add_patch(FancyBboxPatch((right_x, y), right_w, h, boxstyle="round,pad=0.006,rounding_size=0.010", fc=CARD, ec=LINE, lw=0.9))
    ax.text(right_x + 0.014, y + h - 0.019, "巴西｜打勾 Top5 分类与整体同分类对比", fontsize=11.5, weight="bold", color=BRAZIL, va="center")
    ax.text(right_x + right_w - 0.014, y + h - 0.019, "上：巴西（红）｜下：整体（灰）", fontsize=7.7, color=MUTED, ha="right", va="center")
    header_y = y + h - 0.045
    ax.add_patch(Rectangle((right_x + 0.006, header_y - 0.012), right_w - 0.012, 0.024, fc=HEADER, ec="none"))
    rel_x = [0.012, 0.036, 0.180, 0.260, 0.340, 0.490, 0.640, 0.790, 0.880, 0.975]
    headers = ["#", "分类", "曝光UV", "打勾UV", "打勾UV占比", "曝光→点击", "点击→打勾", "打勾→保存", "订阅收入", "订阅收入占比"]
    ax.text(right_x + right_w * rel_x[0], header_y, headers[0], fontsize=6.8, weight="bold", color=TEXT, ha="left", va="center")
    ax.text(right_x + right_w * rel_x[1], header_y, headers[1], fontsize=6.8, weight="bold", color=TEXT, ha="left", va="center")
    for j, label in enumerate(headers[2:]):
        previous = rel_x[1] if j == 0 else rel_x[j + 1]
        center = (previous + 0.012 + rel_x[j + 2]) / 2
        ax.text(right_x + right_w * center, header_y, label, fontsize=6.8, weight="bold", color=TEXT, ha="center", va="center")
    specs = [
        ("曝光uv", lambda v: f"{v:,.0f}"), ("打勾uv", lambda v: f"{v:,.0f}"),
        ("打勾uv占比", lambda v: f"{v:.1%}"), ("曝光点击率", lambda v: f"{v:.1%}"),
        ("点击打勾率", lambda v: f"{v:.1%}"), ("打勾保存率", lambda v: f"{v:.1%}"),
        ("订阅收入", lambda v: f"${v:,.1f}"), ("订阅收入占比", lambda v: f"{v:.1%}"),
    ]
    maxima = {key: max(br_top[f"{key}_巴西"].max(), br_top[f"{key}_整体"].max(), 1e-12) for key, _ in specs}
    row_top, row_h = header_y - 0.022, (h - 0.085) / 5
    for i, (_, row) in enumerate(br_top.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        if i % 2 == 0:
            ax.add_patch(Rectangle((right_x + 0.006, ry - row_h / 2), right_w - 0.012, row_h, fc="#FAFBFD", ec="none"))
        ax.text(right_x + right_w * rel_x[0], ry, f"{i:02d}", fontsize=7.0, color=MUTED, va="center")
        ax.text(right_x + right_w * rel_x[1], ry, str(row["分类名称"]), fontsize=7.7, color=TEXT, weight="bold", va="center")
        for j, ((key, formatter), rx) in enumerate(zip(specs, rel_x[2:])):
            previous = rel_x[1] if j == 0 else rel_x[j + 1]
            cell_left = right_x + right_w * (previous + 0.012)
            cell_right = right_x + right_w * rx
            if key in {"曝光uv", "打勾uv", "打勾uv占比", "订阅收入", "订阅收入占比"}:
                draw_dual_text_cell(ax, (cell_left + cell_right) / 2, ry, row_h,
                                    float(row[f"{key}_巴西"]), float(row[f"{key}_整体"]), formatter)
            else:
                draw_dual_bar_cell(ax, cell_left, cell_right, ry, row_h,
                                   float(row[f"{key}_巴西"]), float(row[f"{key}_整体"]),
                                   maxima[key], formatter)


def draw_overall_list(ax, table: pd.DataFrame, x: float, y: float, w: float, h: float) -> None:
    """按巴西 Top20 行序展示对应素材在整体中的排名。"""
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.010", fc="#E9EEF6", ec=LINE, lw=0.9))
    ax.text(x + 0.014, y + h - 0.024, "整体排名｜按巴西 Top20 对齐", fontsize=12.3, weight="bold", color=OVERALL, va="center")
    ax.text(x + 0.014, y + h - 0.047, "右侧为整体打勾UV排名", fontsize=8.3, color=MUTED, va="center")
    row_top = y + h - 0.079
    row_h = (h - 0.105) / 20
    for i, (_, row) in enumerate(table.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        if i % 2 == 0:
            ax.add_patch(Rectangle((x + 0.007, ry - row_h / 2), w - 0.014, row_h, fc="#F2F5FA", ec="none"))
        name = str(row["素材名称"])
        if len(name) > 18:
            name = name[:17] + "…"
        ax.text(x + 0.016, ry, f"{i:02d}", fontsize=7.7, color=MUTED, ha="left", va="center")
        ax.text(x + 0.052, ry, name, fontsize=8.5, color=TEXT, weight="bold" if i <= 5 else "normal", ha="left", va="center")
        ax.text(x + w - 0.014, ry, f"整体 #{int(row['打勾排名_整体']):02d}", fontsize=7.1, color=OVERALL, ha="right", va="center")


def draw_brazil_table(ax, table: pd.DataFrame, x: float, y: float, w: float, h: float) -> None:
    """巴西 Top20 主值为巴西，括号内为整体同素材值。"""
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.010", fc=CARD, ec=LINE, lw=0.9))
    ax.text(x + 0.014, y + h - 0.022, "巴西｜打勾 Top20 与整体同素材对比", fontsize=13.5, weight="bold", color=BRAZIL, va="center")
    ax.text(x + w - 0.014, y + h - 0.022, "上：巴西（红）｜下：整体（灰）", fontsize=8.5, color=MUTED, va="center", ha="right")
    header_y = y + h - 0.058
    ax.add_patch(Rectangle((x + 0.006, header_y - 0.017), w - 0.012, 0.034, fc=HEADER, ec="none"))
    rel_x = [0.012, 0.034, 0.180, 0.260, 0.340, 0.490, 0.640, 0.790, 0.880, 0.975]
    headers = ["#", "素材（分类）", "曝光UV", "打勾UV", "打勾UV占比", "曝光→点击", "点击→打勾", "打勾→保存", "订阅收入", "订阅收入占比"]
    aligns = ["left", "left"] + ["right"] * 8
    ax.text(x + w * rel_x[0], header_y, headers[0], fontsize=6.8, weight="bold", color=TEXT, ha="left", va="center")
    ax.text(x + w * rel_x[1], header_y, headers[1], fontsize=6.8, weight="bold", color=TEXT, ha="left", va="center")
    for j, label in enumerate(headers[2:]):
        previous = rel_x[1] if j == 0 else rel_x[j + 1]
        center = (previous + 0.012 + rel_x[j + 2]) / 2
        ax.text(x + w * center, header_y, label, fontsize=6.8, weight="bold", color=TEXT, ha="center", va="center")

    row_top = header_y - 0.030
    row_h = (h - 0.112) / 20
    for i, (_, row) in enumerate(table.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        if i % 2 == 0:
            ax.add_patch(Rectangle((x + 0.006, ry - row_h / 2), w - 0.012, row_h, fc="#FAFBFD", ec="none"))
        if i <= 3:
            ax.add_patch(Rectangle((x + 0.006, ry - row_h / 2), 0.003, row_h, fc=BRAZIL, ec="none"))
        name = str(row["素材名称"])
        if len(name) > 18:
            name = name[:17] + "…"
        ax.text(x + w * rel_x[0], ry, f"{i:02d}", fontsize=7.4, color=MUTED, ha="left", va="center")
        ax.text(x + w * rel_x[1], ry + 0.004, name, fontsize=7.7, color=TEXT, weight="bold" if i <= 5 else "normal", ha="left", va="center")
        ax.text(x + w * rel_x[1], ry - 0.005, str(row["分类名称"]), fontsize=6.5, color=MUTED, ha="left", va="center")
        specs = [
            ("曝光uv", lambda v: f"{v:,.0f}"), ("打勾uv", lambda v: f"{v:,.0f}"),
            ("打勾uv占比", lambda v: f"{v:.1%}"), ("曝光点击率", lambda v: f"{v:.1%}"),
            ("点击打勾率", lambda v: f"{v:.1%}"), ("打勾保存率", lambda v: f"{v:.1%}"),
            ("订阅收入", lambda v: f"${v:,.1f}"), ("订阅收入占比", lambda v: f"{v:.1%}"),
        ]
        for j, ((key, formatter), rx) in enumerate(zip(specs, rel_x[2:])):
            previous = rel_x[1] if j == 0 else rel_x[j + 1]
            max_value = max(table[f"{key}_巴西"].max(), table[f"{key}_整体"].max(), 1e-12)
            cell_right = x + w * rx
            if key in {"曝光uv", "打勾uv", "打勾uv占比", "订阅收入", "订阅收入占比"}:
                cell_left = x + w * (previous + 0.012)
                draw_dual_text_cell(ax, (cell_left + cell_right) / 2, ry, row_h,
                                    float(row[f"{key}_巴西"]), float(row[f"{key}_整体"]), formatter)
            else:
                draw_dual_bar_cell(ax, x + w * (previous + 0.012), cell_right, ry, row_h,
                                   float(row[f"{key}_巴西"]), float(row[f"{key}_整体"]),
                                   max_value, formatter)


def main() -> None:
    setup_style()
    OUT.mkdir(parents=True, exist_ok=True)
    df = load_data()
    for market in ["巴西", "整体"]:
        df = material_rates(df, market)
    df["打勾排名_整体"] = df["打勾uv_整体"].rank(method="min", ascending=False)
    br_top, overall_top = top20(df, "巴西"), top20(df, "整体")
    categories = category_summary(df)
    export_top20(br_top, overall_top)

    fig = plt.figure(figsize=(22, 20), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    ax.text(0.035, 0.966, "巴西 vs 整体｜滤镜素材倾向与满意度", fontsize=25, weight="bold", color=TEXT, va="center")
    ax.text(0.035, 0.944, "2026年7月日均｜顶部：全素材加权转化率；中部：打勾Top5分类；下方：打勾Top20素材。", fontsize=11.5, color=MUTED, va="center")
    draw_rate_cards(ax, df)

    draw_category_module(ax, categories, 0.025, 0.645, 0.950, 0.155)
    draw_overall_list(ax, br_top, 0.025, 0.055, 0.215, 0.555)
    draw_brazil_table(ax, br_top, 0.255, 0.055, 0.720, 0.555)
    ax.text(0.035, 0.025, "口径：曝光点击率=总点击/总曝光，点击打勾率=总打勾/总点击，打勾保存率=总保存/总打勾；分类及素材均按打勾UV日均排序。数据源：北斗素材看板 10015925 / 90069。", fontsize=8.4, color=MUTED)
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.08)
    plt.close(fig)
    print(OUTPUT)
    print(TOP20_OUTPUT)


if __name__ == "__main__":
    main()

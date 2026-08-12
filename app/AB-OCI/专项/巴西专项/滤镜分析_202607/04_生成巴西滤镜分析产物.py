#!/usr/bin/env python3
"""生成巴西滤镜专项的对比表、图和可复核中间数据。"""

from __future__ import annotations

import json
import math
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"

FILES = {
    "巴西": "01_素材看板日均_巴西_202607.json",
    "整体": "01_素材看板日均_整体_202607.json",
    "iOS": "01_素材看板日均_巴西_iOS_202607.json",
    "Android": "01_素材看板日均_巴西_Android_202607.json",
    "新用户": "01_素材看板日均_巴西_新用户_202607.json",
    "老用户": "01_素材看板日均_巴西_老用户_202607.json",
    "自然新用户": "01_素材看板日均_巴西_自然新用户_202607.json",
    "渠道新用户": "01_素材看板日均_巴西_渠道新用户_202607.json",
}

COLORS = {
    "bg": "#F4F6FA",
    "card": "#FFFFFF",
    "text": "#172033",
    "muted": "#8290A7",
    "line": "#DDE3EC",
    "red": "#D9433F",
    "green": "#21906B",
    "blue": "#3972D9",
    "orange": "#E17A18",
    "purple": "#7657C8",
}


def setup_style() -> None:
    plt.rcParams.update(
        {
            "font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "figure.facecolor": COLORS["bg"],
            "savefig.facecolor": COLORS["bg"],
        }
    )


def load_beidou(path: Path) -> pd.DataFrame:
    payload = json.loads(path.read_text())
    if "request" in payload:
        payload = payload["response"]
    response = payload.get("response", payload)
    if isinstance(response, dict) and "response" in response:
        response = response["response"]
    charts = response.get("data", [])
    if not charts:
        raise ValueError(f"北斗文件没有图表数据: {path}")
    rows = charts[0].get("data", [])
    if not rows:
        raise ValueError(f"北斗图表没有数据行: {path}")
    return pd.DataFrame(rows)


def aggregate_material(df: pd.DataFrame) -> pd.DataFrame:
    measures = [
        "曝光uv",
        "点击uv",
        "打勾uv",
        "保存uv",
        "订阅uv",
        "订阅转付费uv",
        "订阅收入",
    ]
    for col in measures:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    dims = df.groupby("素材id", as_index=False)[["素材名称", "分类名称"]].first()
    values = df.groupby("素材id", as_index=False)[measures].sum()
    return values.merge(dims, on="素材id", how="left")


def material_comparison(br: pd.DataFrame, overall: pd.DataFrame) -> pd.DataFrame:
    merged = br.merge(overall, on="素材id", how="outer", suffixes=("_巴西", "_整体")).fillna(0)
    for market in ("巴西", "整体"):
        merged[f"打勾占比_{market}"] = merged[f"打勾uv_{market}"] / merged[f"打勾uv_{market}"].sum()
        merged[f"曝光点击率_{market}"] = merged[f"点击uv_{market}"] / merged[f"曝光uv_{market}"].replace(0, np.nan)
        merged[f"点击打勾率_{market}"] = merged[f"打勾uv_{market}"] / merged[f"点击uv_{market}"].replace(0, np.nan)
        merged[f"打勾保存率_{market}"] = merged[f"保存uv_{market}"] / merged[f"打勾uv_{market}"].replace(0, np.nan)
    merged["偏好指数"] = merged["打勾占比_巴西"] / merged["打勾占比_整体"].replace(0, np.nan)
    for metric in ("曝光点击率", "点击打勾率", "打勾保存率"):
        merged[f"{metric}gap_pp"] = (merged[f"{metric}_巴西"] - merged[f"{metric}_整体"]) * 100
    merged["素材名称"] = merged["素材名称_巴西"].where(merged["素材名称_巴西"] != 0, merged["素材名称_整体"])
    merged["分类名称"] = merged["分类名称_巴西"].where(merged["分类名称_巴西"] != 0, merged["分类名称_整体"])
    return merged.sort_values("打勾uv_巴西", ascending=False)


def market_summary(name: str, df: pd.DataFrame) -> dict:
    totals = df[["曝光uv", "点击uv", "打勾uv", "保存uv", "订阅uv", "订阅转付费uv", "订阅收入"]].sum()
    material = df.copy()
    material["打勾占比"] = material["打勾uv"] / material["打勾uv"].sum()
    top = material.sort_values("打勾uv", ascending=False).head(3)
    return {
        "用户分层": name,
        "素材打勾日均UV累计": totals["打勾uv"],
        "曝光点击率": totals["点击uv"] / totals["曝光uv"],
        "点击打勾率": totals["打勾uv"] / totals["点击uv"],
        "打勾保存率": totals["保存uv"] / totals["打勾uv"],
        "订阅转付费率": totals["订阅转付费uv"] / totals["订阅uv"] if totals["订阅uv"] else np.nan,
        "订阅收入日均": totals["订阅收入"],
        "Top素材": " / ".join(f"{row['素材名称']} {row['打勾占比']:.1%}" for _, row in top.iterrows()),
    }


def draw_gap_bar(ax, x0: float, y: float, w: float, gap: float, scale: float = 12.0) -> None:
    ax.plot([x0, x0 + w], [y, y], color=COLORS["line"], lw=6, solid_capstyle="round", zorder=1)
    center = x0 + w / 2
    ax.plot([center, center], [y - 0.008, y + 0.008], color="#AAB4C3", lw=1)
    length = min(abs(gap) / scale, 1.0) * w / 2
    color = COLORS["green"] if gap >= 0 else COLORS["red"]
    ax.plot([center, center + math.copysign(length, gap)], [y, y], color=color, lw=6, solid_capstyle="round", zorder=2)


def plot_material_table(comp: pd.DataFrame) -> None:
    top = comp.head(15).copy()
    fig = plt.figure(figsize=(20, 12), dpi=160)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(0.035, 0.95, "巴西滤镜素材偏好与漏斗｜Top 15", fontsize=26, weight="bold", color=COLORS["text"])
    ax.text(
        0.035,
        0.915,
        "2026年7月日均；按巴西素材打勾UV降序。占比=该素材打勾UV / 全部滤镜素材打勾UV之和。gap=巴西−整体。",
        fontsize=12,
        color=COLORS["muted"],
    )
    card = FancyBboxPatch((0.025, 0.05), 0.95, 0.82, boxstyle="round,pad=0.008,rounding_size=0.015", fc=COLORS["card"], ec="none")
    ax.add_patch(card)
    headers = ["素材", "分类", "巴西打勾占比\n（整体）", "偏好指数", "曝光→点击\ngap", "点击→打勾\ngap", "打勾→保存\ngap", "订阅收入\n日均"]
    xs = [0.045, 0.19, 0.29, 0.43, 0.54, 0.66, 0.78, 0.91]
    aligns = ["left", "left", "center", "center", "center", "center", "center", "right"]
    for x, h, align in zip(xs, headers, aligns):
        ax.text(x, 0.825, h, ha=align, va="center", fontsize=12, weight="bold", color=COLORS["text"])
    row_top, row_h = 0.785, 0.047
    for i, (_, row) in enumerate(top.iterrows()):
        y = row_top - i * row_h
        if i % 2:
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.934, row_h, fc="#FAFBFD", ec="none"))
        if row["打勾保存率gap_pp"] <= -5:
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.006, row_h, fc=COLORS["red"], ec="none"))
        ax.text(xs[0], y, str(row["素材名称"]), ha="left", va="center", fontsize=11.5, color=COLORS["text"], weight="bold" if i < 5 else "normal")
        ax.text(xs[1], y, str(row["分类名称"]), ha="left", va="center", fontsize=10.5, color=COLORS["muted"])
        ax.text(xs[2], y, f"{row['打勾占比_巴西']:.1%}  ({row['打勾占比_整体']:.1%})", ha="center", va="center", fontsize=10.8, color=COLORS["text"])
        pref_color = COLORS["orange"] if row["偏好指数"] >= 1.10 else (COLORS["blue"] if row["偏好指数"] <= 0.90 else COLORS["text"])
        ax.text(xs[3], y, f"{row['偏好指数']:.2f}", ha="center", va="center", fontsize=11, color=pref_color, weight="bold")
        for x, metric in zip(xs[4:7], ["曝光点击率gap_pp", "点击打勾率gap_pp", "打勾保存率gap_pp"]):
            gap = float(row[metric])
            draw_gap_bar(ax, x - 0.042, y - 0.008, 0.084, gap)
            ax.text(x, y + 0.013, f"{gap:+.1f}pp", ha="center", va="center", fontsize=10, color=COLORS["green"] if gap >= 0 else COLORS["red"])
        revenue = float(row["订阅收入_巴西"])
        ax.text(xs[7], y, f"${revenue:,.1f}", ha="right", va="center", fontsize=10.8, color=COLORS["purple"] if revenue > 0 else COLORS["muted"], weight="bold" if revenue > 10 else "normal")
    ax.text(0.04, 0.07, "红色左标：打勾→保存率低于整体至少5pp；偏好指数>1.10为巴西相对偏好，<0.90为相对弱偏好。", fontsize=10, color=COLORS["muted"])
    fig.savefig(OUT / "01_巴西滤镜素材偏好与漏斗.png", bbox_inches="tight")
    plt.close(fig)


def plot_segment_table(summary: pd.DataFrame) -> None:
    order = ["巴西", "整体", "iOS", "Android", "新用户", "老用户", "自然新用户", "渠道新用户"]
    data = summary.set_index("用户分层").loc[order].reset_index()
    fig = plt.figure(figsize=(20, 10.8), dpi=160)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(0.035, 0.94, "巴西滤镜用户分层｜素材漏斗与Top素材", fontsize=26, weight="bold", color=COLORS["text"])
    ax.text(0.035, 0.902, "2026年7月日均；各环节以素材UV累计计算，同一用户使用多个素材会在多个素材中分别计数。", fontsize=12, color=COLORS["muted"])
    card = FancyBboxPatch((0.025, 0.08), 0.95, 0.75, boxstyle="round,pad=0.008,rounding_size=0.015", fc=COLORS["card"], ec="none")
    ax.add_patch(card)
    headers = ["用户分层", "打勾UV\n日均累计", "曝光→点击", "点击→打勾", "打勾→保存", "订阅→付费", "订阅收入\n日均", "Top 3素材（打勾占比）"]
    xs = [0.045, 0.19, 0.31, 0.43, 0.55, 0.66, 0.76, 0.82]
    aligns = ["left", "right", "center", "center", "center", "center", "right", "left"]
    for x, h, a in zip(xs, headers, aligns):
        ax.text(x, 0.785, h, ha=a, va="center", fontsize=12, weight="bold", color=COLORS["text"])
    row_top, row_h = 0.72, 0.078
    for i, (_, row) in enumerate(data.iterrows()):
        y = row_top - i * row_h
        if i % 2:
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.934, row_h, fc="#FAFBFD", ec="none"))
        if row["用户分层"] in ("Android", "新用户", "渠道新用户"):
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.006, row_h, fc=COLORS["orange"], ec="none"))
        ax.text(xs[0], y, row["用户分层"], ha="left", va="center", fontsize=12, color=COLORS["text"], weight="bold")
        ax.text(xs[1], y, f"{row['素材打勾日均UV累计']:,.0f}", ha="right", va="center", fontsize=11, color=COLORS["text"])
        for x, metric in zip(xs[2:6], ["曝光点击率", "点击打勾率", "打勾保存率", "订阅转付费率"]):
            value = row[metric]
            ax.text(x, y, "—" if pd.isna(value) else f"{value:.1%}", ha="center", va="center", fontsize=11, color=COLORS["text"])
        ax.text(xs[6], y, f"${row['订阅收入日均']:,.1f}", ha="right", va="center", fontsize=11, color=COLORS["purple"])
        ax.text(xs[7], y, row["Top素材"], ha="left", va="center", fontsize=10.2, color=COLORS["text"])
    ax.text(0.04, 0.095, "橙色左标：需要优先关注的分层；新用户分层仅用于同类横向比较，不能与老用户简单解释为同一用户的生命周期变化。", fontsize=10, color=COLORS["muted"])
    fig.savefig(OUT / "02_巴西滤镜用户分层对比.png", bbox_inches="tight")
    plt.close(fig)


def plot_category_mix(datasets: dict[str, pd.DataFrame]) -> None:
    rows = []
    for market in ["巴西", "整体", "iOS", "Android", "新用户", "老用户"]:
        grouped = datasets[market].groupby("分类名称", as_index=False)["打勾uv"].sum()
        grouped["占比"] = grouped["打勾uv"] / grouped["打勾uv"].sum()
        grouped["市场"] = market
        rows.append(grouped)
    mix = pd.concat(rows, ignore_index=True)
    top_categories = (
        mix[mix["市场"] == "巴西"].nlargest(10, "打勾uv")["分类名称"].tolist()
    )
    fig, axes = plt.subplots(1, 3, figsize=(20, 8.5), dpi=160)
    fig.subplots_adjust(left=0.07, right=0.97, top=0.82, bottom=0.12, wspace=0.25)
    fig.text(0.035, 0.94, "巴西滤镜品类偏好｜整体、双端与新老", fontsize=26, weight="bold", color=COLORS["text"])
    fig.text(0.035, 0.895, "品类占比=该品类素材打勾UV / 全部滤镜素材打勾UV之和；仅展示巴西Top 10品类。", fontsize=12, color=COLORS["muted"])
    pairs = [("巴西", "整体"), ("iOS", "Android"), ("新用户", "老用户")]
    for ax, (a, b) in zip(axes, pairs):
        table = mix[mix["市场"].isin([a, b]) & mix["分类名称"].isin(top_categories)].pivot(index="分类名称", columns="市场", values="占比").fillna(0)
        table = table.reindex(top_categories[::-1])
        y = np.arange(len(table))
        ax.barh(y - 0.18, table[a], height=0.34, color=COLORS["red"], label=a)
        ax.barh(y + 0.18, table[b], height=0.34, color="#B7C0CF", label=b)
        ax.set_yticks(y, table.index, fontsize=10)
        ax.xaxis.set_major_formatter(lambda v, pos: f"{v:.0%}")
        ax.grid(axis="x", color=COLORS["line"], lw=0.8)
        ax.set_axisbelow(True)
        ax.spines[:].set_visible(False)
        ax.set_title(f"{a} vs {b}", fontsize=15, weight="bold", color=COLORS["text"], pad=12)
        ax.legend(frameon=False, loc="lower right")
    fig.savefig(OUT / "03_巴西滤镜品类偏好分层.png", bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    setup_style()
    OUT.mkdir(parents=True, exist_ok=True)
    datasets = {name: aggregate_material(load_beidou(OUT / file)) for name, file in FILES.items()}
    comp = material_comparison(datasets["巴西"], datasets["整体"])
    summary = pd.DataFrame(market_summary(name, df) for name, df in datasets.items())
    category_rows = []
    for name, df in datasets.items():
        grouped = df.groupby("分类名称", as_index=False)[["曝光uv", "点击uv", "打勾uv", "保存uv", "订阅收入"]].sum()
        grouped["市场/分层"] = name
        grouped["打勾占比"] = grouped["打勾uv"] / grouped["打勾uv"].sum()
        category_rows.append(grouped)
    category = pd.concat(category_rows, ignore_index=True)
    comp.to_csv(OUT / "素材市场对比_巴西vs整体.csv", index=False, encoding="utf-8-sig")
    summary.to_csv(OUT / "素材用户分层汇总_巴西.csv", index=False, encoding="utf-8-sig")
    category.to_csv(OUT / "素材品类分层汇总_巴西.csv", index=False, encoding="utf-8-sig")
    plot_material_table(comp)
    plot_segment_table(summary)
    plot_category_mix(datasets)
    print(f"Generated dashboard artifacts in {OUT}")


if __name__ == "__main__":
    main()

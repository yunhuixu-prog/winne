#!/usr/bin/env python3
"""生成巴西打勾UV Top20滤镜素材的默认来源及滑杆值分布图。"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
MARKET_FILE = OUT / "素材市场对比_巴西vs整体.csv"
SLIDER_FILE = OUT / "02B_巴西滤镜滑杆分布_202607_每次打勾.csv"

COLORS = {
    "bg": "#F4F6FA",
    "card": "#FFFFFF",
    "text": "#172033",
    "muted": "#8290A7",
    "line": "#DDE3EC",
    "red": "#D9433F",
    "red_light": "#F8D8D6",
    "blue": "#3972D9",
}


def normalize_id(series: pd.Series) -> pd.Series:
    return series.astype(str).str.strip().str.replace(r"\.0$", "", regex=True)


def draw_rate_bar(ax, x: float, y: float, width: float, value: float, scale_max: float, color: str) -> None:
    """绘制固定刻度的左到右数据条，并在上方标注精确值。"""
    left = x - width / 2
    bar_y = y - 0.006
    ax.plot([left, left + width], [bar_y, bar_y], color="#E3E8F0", lw=5.0, solid_capstyle="round", zorder=1)
    fill_width = width * min(max(float(value) / scale_max, 0), 1)
    ax.plot([left, left + fill_width], [bar_y, bar_y], color=color, lw=5.0, solid_capstyle="round", zorder=2)
    ax.text(x, y + 0.006, f"{value:.1%}", ha="center", va="center", fontsize=8.8, color=COLORS["text"], weight="bold")


def prepare() -> tuple[pd.DataFrame, pd.DataFrame]:
    market = pd.read_csv(MARKET_FILE)
    slider = pd.read_csv(SLIDER_FILE, low_memory=False)
    market["素材id_key"] = normalize_id(market["素材id"])
    slider["素材id_key"] = normalize_id(slider["check_event.material_id"])
    slider["material_check_pv"] = pd.to_numeric(slider["material_check_pv"], errors="coerce").fillna(0)

    top = (
        market.sort_values("打勾uv_巴西", ascending=False)
        .head(20)[["素材id_key", "素材名称", "曝光uv_巴西", "点击uv_巴西", "打勾uv_巴西", "打勾占比_巴西"]]
        .reset_index(drop=True)
    )
    top["排名"] = np.arange(1, len(top) + 1)
    top["曝光点击率_巴西"] = top["点击uv_巴西"] / top["曝光uv_巴西"].replace(0, np.nan)
    top["点击打勾率_巴西"] = top["打勾uv_巴西"] / top["点击uv_巴西"].replace(0, np.nan)

    # “整体”使用全部国家（Brazil + Other），不是仅Other。
    slider_br = slider[slider["country_group"].eq("Brazil")].copy()
    market_frames = []
    for market_name, frame in [("巴西", slider_br), ("整体", slider)]:
        part = frame.copy()
        part["市场"] = market_name
        market_frames.append(part)
    slider_market = pd.concat(market_frames, ignore_index=True)

    # 增加“所有素材”汇总标识，并与Top20素材同时计算默认来源和数值分布。
    selected_ids = top["素材id_key"].tolist()
    detail = slider_market[slider_market["素材id_key"].isin(selected_ids)].copy()
    all_material = slider_market.copy()
    all_material["素材id_key"] = "__ALL__"
    analysis_rows = pd.concat([detail, all_material], ignore_index=True)

    source = (
        analysis_rows.groupby(["市场", "素材id_key", "default_value_source"], as_index=False)["material_check_pv"]
        .sum()
        .pivot(index=["市场", "素材id_key"], columns="default_value_source", values="material_check_pv")
        .fillna(0)
    )
    for col in ["server_default", "user_memory", "Missing"]:
        if col not in source.columns:
            source[col] = 0
    source["打勾PV"] = source[["server_default", "user_memory", "Missing"]].sum(axis=1)
    source["默认下发比例"] = source["server_default"] / source["打勾PV"].replace(0, np.nan)
    source["本地记忆比例"] = source["user_memory"] / source["打勾PV"].replace(0, np.nan)
    source["默认或记忆比例"] = source["默认下发比例"] + source["本地记忆比例"]
    source["手动滑动比例"] = source["Missing"] / source["打勾PV"].replace(0, np.nan)
    source_wide = source.reset_index().pivot(index="素材id_key", columns="市场", values=[
        "打勾PV", "默认下发比例", "本地记忆比例", "默认或记忆比例", "手动滑动比例"
    ])
    source_wide.columns = [f"{metric}_{market_name}" for metric, market_name in source_wide.columns]
    source_wide = source_wide.reset_index()
    top = top.merge(source_wide, on="素材id_key", how="left")

    # 默认值：default_value_source=server_default事件中的filters_value；若存在多个值，取PV最高者。
    default_values = analysis_rows[analysis_rows["default_value_source"].eq("server_default")].copy()
    default_values["默认值"] = pd.to_numeric(default_values["filters_value_raw"], errors="coerce")
    default_values = default_values[default_values["默认值"].between(0, 100, inclusive="both")]
    default_values = (
        default_values.groupby(["市场", "素材id_key", "默认值"], as_index=False)["material_check_pv"].sum()
        .sort_values(["市场", "素材id_key", "material_check_pv", "默认值"], ascending=[True, True, False, True])
        .drop_duplicates(["市场", "素材id_key"])
        .pivot(index="素材id_key", columns="市场", values="默认值")
        .rename(columns={"巴西": "默认值_巴西", "整体": "默认值_整体"})
        .reset_index()
    )
    top = top.merge(default_values, on="素材id_key", how="left")

    all_row = pd.DataFrame([{
        "素材id_key": "__ALL__", "素材名称": "所有素材", "曝光uv_巴西": np.nan,
        "点击uv_巴西": np.nan, "打勾uv_巴西": market["打勾uv_巴西"].sum(), "打勾占比_巴西": 1.0,
        "排名": 0, "曝光点击率_巴西": np.nan, "点击打勾率_巴西": np.nan,
    }]).merge(source_wide, on="素材id_key", how="left").merge(default_values, on="素材id_key", how="left")
    top = pd.concat([all_row, top], ignore_index=True).fillna({
        c: 0 for c in top.columns if c not in ["曝光uv_巴西", "曝光打勾率_巴西"]
    })

    dist = analysis_rows.copy()
    dist["滑杆值"] = pd.to_numeric(dist["filters_value_raw"], errors="coerce")
    dist = dist[dist["滑杆值"].between(0, 100, inclusive="both")].copy()
    # 5点为一档；0和100保留为独立端点，便于观察默认档位和拉满行为。
    dist["滑杆档位"] = (np.round(dist["滑杆值"] / 5) * 5).clip(0, 100).astype(int)
    dist = dist.groupby(["市场", "素材id_key", "滑杆档位"], as_index=False)["material_check_pv"].sum()
    dist["有效滑杆PV"] = dist.groupby(["市场", "素材id_key"])["material_check_pv"].transform("sum")
    dist["档位占比"] = dist["material_check_pv"] / dist["有效滑杆PV"].replace(0, np.nan)

    bins = pd.MultiIndex.from_product(
        [["巴西", "整体"], top["素材id_key"], np.arange(0, 101, 5)], names=["市场", "素材id_key", "滑杆档位"]
    ).to_frame(index=False)
    dist = bins.merge(dist, on=["市场", "素材id_key", "滑杆档位"], how="left")
    dist["material_check_pv"] = dist["material_check_pv"].fillna(0)
    dist["档位占比"] = dist["档位占比"].fillna(0)
    dist = dist.merge(top[["素材id_key", "素材名称", "排名"]], on="素材id_key", how="left")

    top_out = top[[
        "排名", "素材id_key", "素材名称", "曝光uv_巴西", "点击uv_巴西", "打勾uv_巴西",
        "曝光点击率_巴西", "点击打勾率_巴西", "打勾占比_巴西", "默认值_巴西", "默认值_整体",
    ]].rename(columns={"素材id_key": "素材id"})
    top_out.to_csv(OUT / "05_巴西Top20滤镜漏斗汇总.csv", index=False, encoding="utf-8-sig")
    dist.rename(columns={"素材id_key": "素材id"}).to_csv(
        OUT / "05_巴西Top20滤镜滑杆值分布.csv", index=False, encoding="utf-8-sig"
    )
    return top, dist


def plot(top: pd.DataFrame, dist: pd.DataFrame) -> Path:
    plt.rcParams.update(
        {
            "font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "figure.facecolor": COLORS["bg"],
            "savefig.facecolor": COLORS["bg"],
        }
    )

    fig = plt.figure(figsize=(24, 18), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(0.035, 0.965, "巴西打勾UV Top 20滤镜｜滑杆值分布", fontsize=25, weight="bold", color=COLORS["text"])
    ax.text(0.035, 0.938, "2026年7月；Top20按巴西打勾UV降序。最上方为所有滤镜素材汇总；滑杆值按5点分档。", fontsize=11.5, color=COLORS["muted"])
    ax.text(0.83, 0.965, "—  巴西", fontsize=10.5, color=COLORS["red"], weight="bold")
    ax.text(0.91, 0.965, "—  整体", fontsize=10.5, color="#6F7A8E", weight="bold")

    card = FancyBboxPatch((0.025, 0.055), 0.95, 0.845, boxstyle="round,pad=0.008,rounding_size=0.013", fc=COLORS["card"], ec="none")
    ax.add_patch(card)
    xs = {"rank": 0.045, "name": 0.068, "exp": 0.18, "exp_click": 0.285, "click_check": 0.39, "share": 0.495, "plot0": 0.60, "plot1": 0.95}
    ax.text(xs["rank"], 0.872, "排名", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text(xs["name"], 0.872, "素材", fontsize=10.5, weight="bold", color=COLORS["text"], ha="left")
    ax.text(xs["exp"], 0.872, "巴西曝光UV/日", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text(xs["exp_click"], 0.879, "巴西曝光→点击", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text(xs["exp_click"], 0.862, "数据条刻度 0–70%", fontsize=8.5, color=COLORS["muted"], ha="center")
    ax.text(xs["click_check"], 0.879, "巴西点击→打勾", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text(xs["click_check"], 0.862, "数据条刻度 0–25%", fontsize=8.5, color=COLORS["muted"], ha="center")
    ax.text(xs["share"], 0.872, "巴西打勾UV占比", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text((xs["plot0"] + xs["plot1"]) / 2, 0.879, "滑杆值分布｜巴西 vs 整体", fontsize=10.5, weight="bold", color=COLORS["text"], ha="center")
    ax.text((xs["plot0"] + xs["plot1"]) / 2, 0.862, "纵轴为该素材有效滑杆打勾PV占比", fontsize=8.8, color=COLORS["muted"], ha="center")
    for v in [0, 25, 50, 75, 100]:
        x = xs["plot0"] + (xs["plot1"] - xs["plot0"]) * v / 100
        ax.text(x, 0.847, str(v), fontsize=7.7, color=COLORS["muted"], ha="center")

    row_top, row_h = 0.822, 0.0355
    for i, row in top.iterrows():
        y = row_top - i * row_h
        is_all = row["素材id_key"] == "__ALL__"
        if is_all:
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.934, row_h, fc="#EEF4FF", ec="none"))
        elif i % 2 == 0:
            ax.add_patch(Rectangle((0.033, y - row_h / 2), 0.934, row_h, fc="#FAFBFD", ec="none"))
        ax.plot([0.04, 0.96], [y - row_h / 2, y - row_h / 2], color="#EEF1F5", lw=0.7)
        ax.text(xs["rank"], y, "—" if is_all else f"{int(row['排名']):02d}", ha="center", va="center", fontsize=9.2, color=COLORS["muted"])
        ax.text(xs["name"], y, row["素材名称"], ha="left", va="center", fontsize=10.2, color=COLORS["text"], weight="bold" if is_all or i <= 5 else "normal")
        ax.text(xs["exp"], y, "" if is_all else f"{row['曝光uv_巴西']:,.0f}", ha="center", va="center", fontsize=9.5, color=COLORS["text"])
        if not is_all:
            draw_rate_bar(ax, xs["exp_click"], y, 0.066, row["曝光点击率_巴西"], 0.70, COLORS["blue"])
            draw_rate_bar(ax, xs["click_check"], y, 0.066, row["点击打勾率_巴西"], 0.25, "#E17A18")
        ax.text(xs["share"], y, "" if is_all else f"{row['打勾占比_巴西']:.1%}", ha="center", va="center", fontsize=9.5, color=COLORS["text"], weight="bold")
        d_all = dist[dist["素材id_key"].eq(row["素材id_key"])]
        ymax = max(0.01, float(d_all["档位占比"].max()) * 1.10)
        baseline = y - row_h * 0.29
        height = row_h * 0.42
        for v in [0, 50, 100]:
            x = xs["plot0"] + (xs["plot1"] - xs["plot0"]) * v / 100
            ax.plot([x, x], [baseline, baseline + height], color="#E5EAF1", lw=0.6, zorder=1)
        ax.plot([xs["plot0"], xs["plot1"]], [baseline, baseline], color=COLORS["line"], lw=0.7)
        for market_name, color, width in [("整体", "#6F7A8E", 1.15), ("巴西", COLORS["red"], 1.45)]:
            d = d_all[d_all["市场"].eq(market_name)].sort_values("滑杆档位")
            px = xs["plot0"] + (xs["plot1"] - xs["plot0"]) * d["滑杆档位"].to_numpy() / 100
            py = baseline + height * d["档位占比"].to_numpy() / ymax
            ax.plot(px, py, color=color, lw=width, solid_capstyle="round", zorder=3)
        br_dist = d_all[d_all["市场"].eq("巴西")]
        overall_dist = d_all[d_all["市场"].eq("整体")]
        if not br_dist.empty:
            br_mode = br_dist.loc[br_dist["档位占比"].idxmax()]
            ax.text(
                xs["plot1"], y + row_h * 0.31,
                f"巴西众数 {int(br_mode['滑杆档位'])}（{br_mode['档位占比']:.1%}）",
                ha="right", va="center", fontsize=7.4, color=COLORS["red"], weight="bold"
            )
        if not overall_dist.empty:
            overall_mode = overall_dist.loc[overall_dist["档位占比"].idxmax()]
            ax.text(
                xs["plot1"], y + row_h * 0.12,
                f"整体众数 {int(overall_mode['滑杆档位'])}（{overall_mode['档位占比']:.1%}）",
                ha="right", va="center", fontsize=7.2, color=COLORS["muted"]
            )
        ax.text(xs["plot0"] - 0.008, baseline + height, f"{ymax:.0%}", ha="right", va="center", fontsize=7.2, color=COLORS["muted"])

    ax.text(0.04, 0.073, "口径：曝光UV、曝光→点击率、点击→打勾率及打勾占比来自素材看板；两列数据条分别使用0–70%、0–25%固定刻度。滑杆分布按每次material_check事件PV。", fontsize=9.2, color=COLORS["muted"])
    ax.text(0.04, 0.058, "整体为全部国家（包含巴西）；众数及占比基于图中5点分档；各行纵轴独立缩放，仅用于同一素材的市场比较。所有素材曝光UV不可跨素材求和，因此汇总行不展示。", fontsize=9.0, color=COLORS["muted"])

    path = OUT / "05_巴西Top20滤镜滑杆值分布.png"
    fig.savefig(path, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return path


if __name__ == "__main__":
    top20, distribution = prepare()
    output = plot(top20, distribution)
    print(output)

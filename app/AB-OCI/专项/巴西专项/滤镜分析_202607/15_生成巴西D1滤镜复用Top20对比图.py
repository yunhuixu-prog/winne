#!/usr/bin/env python3
"""生成巴西曝光 Top30 素材的 D1 复用表现，并与整体对应素材对比。"""

from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
INPUT = OUT / "03_巴西滤镜素材复用_D1_D7_素材汇总_202607.csv"
EXPOSURE_INPUT = OUT / "素材市场对比_巴西vs整体.csv"
NAME_SOURCE = OUT / "01_素材看板日均_巴西_202607.json"
NAME_SOURCE_OVERALL = OUT / "01_素材看板日均_整体_202607.json"
OUTPUT = OUT / "09_巴西与整体D1滤镜复用_曝光Top30.png"
CSV_OUTPUT = OUT / "09_巴西与整体D1滤镜复用_曝光Top30.csv"

BG = "#F4F6FA"
CARD = "#FFFFFF"
TEXT = "#192337"
MUTED = "#8290A5"
LINE = "#DFE5ED"
BRAZIL = "#E34E43"
BRAZIL_BAR = "#F4A39C"
OVERALL = "#69788E"
OVERALL_BAR = "#CBD3DE"
HEADER = "#F7F9FC"


def setup_style() -> None:
    plt.rcParams.update({
        "font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"],
        "axes.unicode_minus": False,
        "figure.facecolor": BG,
        "savefig.facecolor": BG,
    })


def load_beidou_names(path: Path) -> pd.DataFrame:
    payload = json.loads(path.read_text())
    if "request" in payload:
        payload = payload["response"]
    response = payload.get("response", payload)
    if isinstance(response, dict) and "response" in response:
        response = response["response"]
    rows = response.get("data", [])[0].get("data", [])
    frame = pd.DataFrame(rows)
    return frame[["素材id", "素材名称", "分类名称"]].drop_duplicates("素材id")


def prepare() -> tuple[pd.DataFrame, dict[str, dict[str, float]]]:
    data = pd.read_csv(INPUT, encoding="utf-8-sig")
    exposure = pd.read_csv(EXPOSURE_INPUT, encoding="utf-8-sig").rename(
        columns={"素材id": "material_id"}
    )
    exposure["material_id"] = exposure["material_id"].astype(str)
    for column in ("曝光uv_巴西", "曝光uv_整体"):
        exposure[column] = pd.to_numeric(exposure[column], errors="coerce").fillna(0)
    names = pd.concat(
        [load_beidou_names(NAME_SOURCE), load_beidou_names(NAME_SOURCE_OVERALL)],
        ignore_index=True,
    ).drop_duplicates("素材id")
    names["素材id"] = names["素材id"].astype(str)
    data["material_id"] = data["material_id"].astype(str)
    data = data.merge(names, left_on="material_id", right_on="素材id", how="left")
    data = data.merge(
        exposure[["material_id", "曝光uv_巴西", "曝光uv_整体"]],
        on="material_id", how="left",
    )
    data[["曝光uv_巴西", "曝光uv_整体"]] = data[["曝光uv_巴西", "曝光uv_整体"]].fillna(0)
    data["素材名称"] = data["素材名称"].fillna(data["material_id"])
    data["分类名称"] = data["分类名称"].fillna("未分类")

    data["D1又打勾滤镜率"] = (
        data["d1_any_filter_user_days"] / data["d1_mature_cohort_user_days"].replace(0, np.nan)
    )
    data["D1同素材占D1滤镜"] = (
        data["d1_same_material_user_days"] / data["d1_any_filter_user_days"].replace(0, np.nan)
    )
    data["D7又打勾滤镜率"] = (
        data["d7_exact_any_filter_user_days"] / data["d7_mature_cohort_user_days"].replace(0, np.nan)
    )
    data["D7同素材占D7滤镜"] = (
        data["d7_exact_same_material_user_days"] / data["d7_exact_any_filter_user_days"].replace(0, np.nan)
    )

    overall = {}
    for market in ("Brazil", "Overall"):
        part = data.loc[data["market"] == market]
        cohort = float(part["d1_mature_cohort_user_days"].sum())
        any_d1 = float(part["d1_any_filter_user_days"].sum())
        same_d1 = float(part["d1_same_material_user_days"].sum())
        cohort_d7 = float(part["d7_mature_cohort_user_days"].sum())
        any_d7 = float(part["d7_exact_any_filter_user_days"].sum())
        same_d7 = float(part["d7_exact_same_material_user_days"].sum())
        overall[market] = {
            "cohort": cohort,
            "any_d1": any_d1,
            "same_d1": same_d1,
            "any_rate": any_d1 / cohort,
            "same_share": same_d1 / any_d1,
            "cohort_d7": cohort_d7,
            "any_d7": any_d7,
            "same_d7": same_d7,
            "any_rate_d7": any_d7 / cohort_d7,
            "same_share_d7": same_d7 / any_d7,
        }

    br = data.loc[data["market"] == "Brazil"].sort_values(
        "曝光uv_巴西", ascending=False
    ).head(30).copy()
    ov = data.loc[data["market"] == "Overall", [
        "material_id", "d1_mature_cohort_user_days", "d1_any_filter_user_days",
        "d1_same_material_user_days", "D1又打勾滤镜率", "D1同素材占D1滤镜",
        "d7_mature_cohort_user_days", "d7_exact_any_filter_user_days",
        "d7_exact_same_material_user_days", "D7又打勾滤镜率", "D7同素材占D7滤镜",
    ]].copy()
    ov = ov.rename(columns={c: f"{c}_整体" for c in ov.columns if c != "material_id"})
    top = br.merge(ov, on="material_id", how="left")
    top.insert(0, "排名", range(1, len(top) + 1))

    export = top[[
        "排名", "material_id", "素材名称", "分类名称",
        "曝光uv_巴西", "曝光uv_整体",
        "d1_mature_cohort_user_days", "d1_any_filter_user_days", "d1_same_material_user_days",
        "D1又打勾滤镜率", "D1同素材占D1滤镜",
        "d1_mature_cohort_user_days_整体", "d1_any_filter_user_days_整体",
        "d1_same_material_user_days_整体", "D1又打勾滤镜率_整体", "D1同素材占D1滤镜_整体",
    ]].copy()
    export.columns = [
        "排名", "素材ID", "素材名称", "分类名称",
        "巴西曝光UV日均", "整体对应素材曝光UV日均",
        "巴西首日打勾素材用户日", "巴西D1又打勾任意滤镜用户日", "巴西D1打勾同素材用户日",
        "巴西D1又打勾任一滤镜占比", "巴西D1打勾的相同滤镜占比",
        "整体首日打勾素材用户日", "整体D1又打勾任意滤镜用户日", "整体D1打勾同素材用户日",
        "整体D1又打勾任一滤镜占比", "整体D1打勾的相同滤镜占比",
    ]
    export.to_csv(CSV_OUTPUT, index=False, encoding="utf-8-sig")
    return top, overall


def add_card(ax, x: float, y: float, w: float, h: float) -> None:
    ax.add_patch(FancyBboxPatch(
        (x, y), w, h, boxstyle="round,pad=0.005,rounding_size=0.010",
        fc=CARD, ec=LINE, lw=0.8,
    ))


def metric_card(ax, x: float, y: float, w: float, h: float, title: str,
                br: float, ov: float, note: str) -> None:
    add_card(ax, x, y, w, h)
    ax.text(x + 0.018, y + h - 0.016, title, fontsize=10.8, weight="bold", color=TEXT, va="top")
    ax.text(x + w - 0.025, y + h - 0.017, f"Gap {(br - ov) * 100:+.1f}pp",
            fontsize=9.2, color=BRAZIL if br >= ov else "#189568", ha="right", va="top")
    ax.text(x + 0.018, y + 0.043, "巴西", fontsize=9.2, color=BRAZIL, va="center")
    ax.text(x + 0.058, y + 0.043, f"{br:.1%}", fontsize=17, weight="bold", color=BRAZIL, va="center")
    ax.text(x + w - 0.085, y + 0.043, "整体", fontsize=8.2, color=OVERALL, va="center")
    ax.text(x + w - 0.018, y + 0.043, f"{ov:.1%}", fontsize=12.5, color=OVERALL, ha="right", va="center")
    ax.text(x + 0.018, y + 0.014, note, fontsize=6.8, color=MUTED, va="center")


def dual_bar(ax, left: float, right: float, y: float, br: float, ov: float,
             max_value: float, row_h: float) -> None:
    text_w = 0.060
    bar_right = right - text_w
    usable = bar_right - left
    bar_h = 0.0042
    by, oy = y + row_h * 0.16, y - row_h * 0.18
    for yy, val, color in ((by, br, BRAZIL_BAR), (oy, ov, OVERALL_BAR)):
        width = usable * max(val, 0) / max(max_value, 1e-9)
        if width > 0:
            ax.add_patch(FancyBboxPatch(
                (left, yy - bar_h / 2), width, bar_h,
                boxstyle=f"round,pad=0,rounding_size={bar_h / 2}", fc=color, ec="none",
            ))
    ax.text(right, by, f"{br:.1%}", fontsize=8.5, color=BRAZIL, weight="bold", ha="right", va="center")
    ax.text(right, oy, f"{ov:.1%}", fontsize=7.1, color=OVERALL, ha="right", va="center")


def draw(top: pd.DataFrame, summary: dict[str, dict[str, float]]) -> None:
    setup_style()
    fig = plt.figure(figsize=(16, 25), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")

    ax.text(0.045, 0.966, "巴西 vs 整体｜滤镜素材 D1 复用", fontsize=24, weight="bold", color=TEXT, va="top")
    ax.text(0.045, 0.937,
            "2026年7月｜严格次日复用｜成熟样本截至7月30日｜下方按巴西素材曝光UV日均排序 Top30",
            fontsize=10.2, color=MUTED, va="top")
    ax.text(0.045, 0.920,
            "口径｜D1又打勾任一滤镜＝严格次日又打勾任一滤镜用户日 ÷ 首日打勾该素材用户日；D1打勾的相同滤镜＝严格次日打勾首日相同素材用户日 ÷ 次日又打勾任一滤镜用户日",
            fontsize=7.6, color=BRAZIL, weight="bold", va="top")

    br, ov = summary["Brazil"], summary["Overall"]
    metric_card(ax, 0.045, 0.815, 0.438, 0.090, "D1又打勾任一滤镜",
                br["any_rate"], ov["any_rate"], "分母：D1成熟首日打勾素材用户日")
    metric_card(ax, 0.517, 0.815, 0.438, 0.090, "D1打勾的相同滤镜",
                br["same_share"], ov["same_share"], "分母：D1又打勾任意滤镜用户日")

    add_card(ax, 0.045, 0.065, 0.910, 0.730)
    ax.text(0.065, 0.770, "巴西曝光 Top30 素材｜D1 表现与整体对应素材对比",
            fontsize=14.0, weight="bold", color=TEXT, va="center")
    ax.text(0.935, 0.770, "上：巴西  ·  下：整体", fontsize=8.7, color=MUTED, ha="right", va="center")

    table_left, table_right = 0.065, 0.935
    x_rank, x_name, x_n = 0.072, 0.105, 0.405
    m1_l, m1_r = 0.535, 0.700
    m2_l, m2_r = 0.775, 0.935
    header_y, header_h = 0.738, 0.027
    ax.add_patch(Rectangle((table_left, header_y), table_right - table_left, header_h, fc=HEADER, ec="none"))
    ax.text(x_rank, header_y + header_h / 2, "#", fontsize=8.5, color=OVERALL, va="center")
    ax.text(x_name, header_y + header_h / 2, "素材", fontsize=8.5, color=OVERALL, va="center")
    ax.text(x_n, header_y + header_h / 2, "曝光UV（日均）", fontsize=8.5, color=OVERALL, ha="center", va="center")
    ax.text((m1_l + m1_r) / 2, header_y + header_h / 2, "D1又打勾任一滤镜", fontsize=8.5, color=OVERALL, ha="center", va="center")
    ax.text((m2_l + m2_r) / 2, header_y + header_h / 2, "D1打勾的相同滤镜", fontsize=8.5, color=OVERALL, ha="center", va="center")

    start_y, bottom = header_y, 0.085
    row_h = (start_y - bottom) / 30
    max_m1 = max(float(top["D1又打勾滤镜率"].max()), float(top["D1又打勾滤镜率_整体"].max())) * 1.06
    max_m2 = max(float(top["D1同素材占D1滤镜"].max()), float(top["D1同素材占D1滤镜_整体"].max())) * 1.06

    for i, row in top.reset_index(drop=True).iterrows():
        top_y = start_y - i * row_h
        y = top_y - row_h / 2
        if i % 2:
            ax.add_patch(Rectangle((table_left, top_y - row_h), table_right - table_left, row_h, fc="#FAFBFD", ec="none"))
        if i < 3:
            ax.add_patch(Rectangle((table_left, top_y - row_h), 0.004, row_h, fc=BRAZIL, ec="none"))
        ax.text(x_rank, y, f"{i + 1:02d}", fontsize=8.0, color=MUTED, va="center")
        name = str(row["素材名称"])
        if len(name) > 24:
            name = name[:23] + "…"
        ax.text(x_name, y + row_h * 0.12, name, fontsize=9.5, color=TEXT,
                weight="bold" if i < 5 else "normal", va="center")
        ax.text(x_name, y - row_h * 0.20, str(row["分类名称"]), fontsize=6.8, color=MUTED, va="center")
        ax.text(x_n, y + row_h * 0.12, f"{int(round(row['曝光uv_巴西'])):,}",
                fontsize=8.2, color=BRAZIL, weight="bold", ha="center", va="center")
        ax.text(x_n, y - row_h * 0.20, f"{int(round(row['曝光uv_整体'])):,}",
                fontsize=7.0, color=OVERALL, ha="center", va="center")
        dual_bar(ax, m1_l, m1_r, y, float(row["D1又打勾滤镜率"]),
                 float(row["D1又打勾滤镜率_整体"]), max_m1, row_h)
        dual_bar(ax, m2_l, m2_r, y, float(row["D1同素材占D1滤镜"]),
                 float(row["D1同素材占D1滤镜_整体"]), max_m2, row_h)

    ax.text(0.045, 0.035,
            "口径：曝光UV为素材看板2026年7月日均；用户×日期×素材去重；D1为严格次日。整体包含巴西。首日同一用户打勾多个素材时，每个素材各形成一条 cohort。",
            fontsize=8.0, color=MUTED, va="center")
    fig.savefig(OUTPUT, dpi=170, bbox_inches="tight", pad_inches=0.10)
    plt.close(fig)


def main() -> None:
    top, summary = prepare()
    draw(top, summary)
    print(f"图表：{OUTPUT}")
    print(f"明细：{CSV_OUTPUT}")
    for market in ("Brazil", "Overall"):
        s = summary[market]
        print(market, f"D1任意={s['any_rate']:.2%}", f"D1其中同素材={s['same_share']:.2%}")


if __name__ == "__main__":
    main()

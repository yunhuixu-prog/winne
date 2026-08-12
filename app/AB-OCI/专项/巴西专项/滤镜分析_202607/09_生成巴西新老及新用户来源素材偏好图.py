#!/usr/bin/env python3
"""生成巴西新老用户、新用户渠道/自然的整体漏斗与素材 Top20 对比图。"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
SOURCE_SCRIPT = Path(__file__).with_name("04_生成巴西滤镜分析产物.py")
ENTRY_METRICS_INPUT = OUT / "06C_Filters单次进入核心指标_分层.csv"
FIRST_CLICK_INPUT = OUT / "06J_Filters首次点击前曝光不同素材数分布_分层.csv"
D1_REUSE_INPUT = OUT / "03_巴西滤镜素材复用_D1_D7_202607.csv"
BG, CARD, TEXT, MUTED, LINE, HEADER = "#F4F6FA", "#FFFFFF", "#182235", "#8794A8", "#E1E6EE", "#F7F9FC"
PRIMARY, SECONDARY = "#E14B3F", "#65748A"
RATES = [("曝光点击率", "曝光uv", "点击uv"), ("点击打勾率", "点击uv", "打勾uv"), ("打勾保存率", "打勾uv", "保存uv")]
EXTENDED_METRIC_LABELS = [
    "进入Filters后\n有点击素材的占比", "曝光素材数\n（次均）", "点击素材数\n（次均）",
    "首次点击前\n曝光素材数", "D1又打勾\n任一滤镜", "D1打勾的\n相同滤镜",
]
SEGMENT_METRIC_SPECS = {
    "新用户": ("is_new", "New", lambda d: d["is_new"] == "New"),
    "老用户": ("is_new", "Old", lambda d: d["is_new"] == "Old"),
    "渠道新用户": ("is_ua_new_only", "non-Organic", lambda d: (d["is_new"] == "New") & (d["is_ua"] == "non-Organic")),
    "自然新用户": ("is_ua_new_only", "Organic", lambda d: (d["is_new"] == "New") & (d["is_ua"] == "Organic")),
}

COMPARISONS = [
    {
        "left": "新用户", "right": "老用户",
        "left_file": "01_素材看板日均_巴西_新用户_202607.json",
        "right_file": "01_素材看板日均_巴西_老用户_202607.json",
        "title": "巴西新老用户｜滤镜素材偏好",
        "output": "06_巴西新老用户滤镜整体及素材Top20.png",
        "csv": "06_巴西新老用户打勾Top20素材.csv",
    },
    {
        "left": "渠道新用户", "right": "自然新用户",
        "left_file": "01_素材看板日均_巴西_渠道新用户_202607.json",
        "right_file": "01_素材看板日均_巴西_自然新用户_202607.json",
        "title": "巴西新用户来源｜渠道 vs 自然滤镜素材偏好",
        "output": "07_巴西渠道与自然新用户滤镜整体及素材Top20.png",
        "csv": "07_巴西渠道与自然新用户打勾Top20素材.csv",
    },
]


def source_module():
    spec = importlib.util.spec_from_file_location("brazil_material_source", SOURCE_SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def setup_style() -> None:
    plt.rcParams.update({"font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"], "axes.unicode_minus": False, "figure.facecolor": BG, "savefig.facecolor": BG})


def add_metrics(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy(); out["打勾占比"] = out["打勾uv"] / out["打勾uv"].sum(); return out


def weighted_rates(df: pd.DataFrame) -> dict[str, float]:
    return {label: df[numerator].sum() / df[denominator].sum() for label, denominator, numerator in RATES}


def load_extended_sources() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    return pd.read_csv(ENTRY_METRICS_INPUT), pd.read_csv(FIRST_CLICK_INPUT), pd.read_csv(D1_REUSE_INPUT)


def extended_metrics(
    sources: tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame],
    dimension: str,
    value: str,
    d1_mask,
) -> list[tuple[str, float, str]]:
    """返回单次进入4项与D1复用2项；D1相同滤镜以D1又打勾用户为分母。"""
    entry, first_click, reuse = sources
    row = entry[
        (entry["country_group"] == "Brazil")
        & (entry["segment_dimension"] == dimension)
        & (entry["segment_value"] == value)
    ]
    if len(row) != 1:
        raise ValueError(f"单次进入指标未唯一匹配：{dimension}={value}, rows={len(row)}")
    row = row.iloc[0]
    first = first_click[
        (first_click["country_group"] == "Brazil")
        & (first_click["segment_dimension"] == dimension)
        & (first_click["segment_value"] == value)
        & (first_click["pre_click_exposure_bucket"] != "NO_CLICK")
    ]
    clicked = first["clicked_entry_count"].sum()
    before_first_click = first["pre_click_exposure_material_sum"].sum() / clicked
    d1 = reuse[(reuse["country_group"] == "Brazil") & d1_mask(reuse)]
    mature = d1["d1_mature_cohort_user_days"].sum()
    any_filter = d1["d1_any_filter_user_days"].sum()
    values = [
        (EXTENDED_METRIC_LABELS[0], row["entry_click_rate"], "pct"),
        (EXTENDED_METRIC_LABELS[1], row["avg_distinct_exposure_materials_per_entry"], "num"),
        (EXTENDED_METRIC_LABELS[2], row["avg_distinct_click_materials_per_entry"], "num"),
        (EXTENDED_METRIC_LABELS[3], before_first_click, "num"),
        (EXTENDED_METRIC_LABELS[4], any_filter / mature, "pct"),
        (EXTENDED_METRIC_LABELS[5], d1["d1_same_material_user_days"].sum() / any_filter, "pct"),
    ]
    return values


def top20(df: pd.DataFrame) -> pd.DataFrame:
    return df.sort_values("打勾uv", ascending=False).head(20).copy()


def draw_overall_card(ax, df: pd.DataFrame, extra: list[tuple[str, float, str]], label: str, accent: str, bg: str, x: float, y: float, w: float, h: float) -> None:
    rates = weighted_rates(df)
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.012", fc=CARD, ec=LINE, lw=0.9))
    ax.add_patch(FancyBboxPatch((x + 0.006, y + h - 0.045), w - 0.012, 0.036, boxstyle="round,pad=0,rounding_size=0.008", fc=bg, ec="none"))
    ax.text(x + 0.018, y + h - 0.027, f"{label}｜全部素材", fontsize=14, weight="bold", color=accent, va="center")
    metrics = [(label_, rates[label_], "pct") for label_, _, _ in RATES] + extra
    left, right = x + 0.014, x + w - 0.014
    top, bottom = y + h - 0.055, y + 0.012
    cell_w, cell_h = (right - left) / 3, (top - bottom) / 3
    for col in (1, 2):
        cx = left + col * cell_w
        ax.plot([cx, cx], [bottom, top], color=LINE, lw=0.7)
    for row_i in (1, 2):
        cy = top - row_i * cell_h
        ax.plot([left, right], [cy, cy], color=LINE, lw=0.7)
    for i, (metric, value, fmt) in enumerate(metrics):
        row_i, col_i = divmod(i, 3)
        cx, cy_top = left + col_i * cell_w, top - row_i * cell_h
        shown = f"{value:.1%}" if fmt == "pct" else f"{value:.1f}"
        ax.text(cx + 0.010, cy_top - cell_h * 0.28, metric, fontsize=10.0, color=MUTED, va="center", linespacing=1.35)
        ax.text(cx + 0.010, cy_top - cell_h * 0.73, shown, fontsize=17.2, color=accent, weight="bold", va="center")


def draw_material_card(ax, table: pd.DataFrame, label: str, accent: str, bg: str, x: float, y: float, w: float, h: float, highlight_names: set[str] | None = None) -> None:
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.012", fc=CARD, ec=LINE, lw=0.9))
    ax.add_patch(FancyBboxPatch((x + 0.006, y + h - 0.050), w - 0.012, 0.041, boxstyle="round,pad=0,rounding_size=0.008", fc=bg, ec="none"))
    ax.text(x + 0.018, y + h - 0.029, f"{label}｜打勾 Top20 素材", fontsize=14, weight="bold", color=accent, va="center")
    ax.text(x + w - 0.018, y + h - 0.029, "按打勾UV日均降序", fontsize=8.2, color=MUTED, ha="right", va="center")
    ax.text(x + 0.018, y + h - 0.072, "素材名下方：曝光UV＝看到该素材的人数｜打勾占比＝该素材打勾UV / 本分层全部素材打勾UV", fontsize=9.0, color=MUTED, va="center")
    header_y = y + h - 0.104
    ax.add_patch(Rectangle((x + 0.008, header_y - 0.015), w - 0.016, 0.030, fc=HEADER, ec="none"))
    ax.text(x + 0.020, header_y, "排名", fontsize=10, weight="bold", color=TEXT, va="center")
    ax.text(x + 0.085, header_y, "素材及指标", fontsize=10, weight="bold", color=TEXT, va="center")
    ax.text(x + w - 0.020, header_y, "分类", fontsize=10, weight="bold", color=TEXT, ha="right", va="center")
    row_top, row_h = header_y - 0.034, (h - 0.155) / 20
    for i, (_, row) in enumerate(table.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        name = str(row["素材名称"]); name = name[:22] + ("…" if len(name) > 22 else "")
        is_highlight = str(row["素材名称"]) in highlight_names if highlight_names is not None else i <= 3
        if is_highlight:
            ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), w - 0.016, row_h, fc=bg, ec="none"))
        elif i % 2 == 0:
            ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), w - 0.016, row_h, fc="#FAFBFD", ec="none"))
        if is_highlight: ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), 0.004, row_h, fc=accent, ec="none"))
        ax.text(x + 0.022, ry, f"{i:02d}", fontsize=9.0, color=MUTED, va="center")
        ax.text(x + 0.085, ry + row_h * 0.17, name, fontsize=10.8, color=TEXT, weight="bold" if is_highlight else "normal", va="center")
        ax.text(x + 0.085, ry - row_h * 0.21, f"曝光UV {row['曝光uv']:,.0f}   ·   打勾占比 {row['打勾占比']:.1%}", fontsize=8.9, color=accent, va="center")
        ax.text(x + w - 0.020, ry, str(row["分类名称"]), fontsize=9.0, color=MUTED, ha="right", va="center")


def export_csv(left: pd.DataFrame, right: pd.DataFrame, left_label: str, right_label: str, path: Path) -> None:
    pieces = []
    for label, table in [(left_label, left), (right_label, right)]:
        out = table[["素材id", "素材名称", "分类名称", "曝光uv", "打勾uv", "打勾占比"]].copy()
        out.insert(0, "排名", range(1, len(out) + 1)); out.insert(0, "分层", label)
        out.columns = ["分层", "排名", "素材id", "素材名称", "分类名称", "曝光UV", "打勾UV", "打勾占比"]
        pieces.append(out)
    pd.concat(pieces, ignore_index=True).to_csv(path, index=False, encoding="utf-8-sig")


def generate(src, config: dict) -> None:
    left = add_metrics(src.aggregate_material(src.load_beidou(OUT / config["left_file"])))
    right = add_metrics(src.aggregate_material(src.load_beidou(OUT / config["right_file"])))
    left_top, right_top = top20(left), top20(right)
    export_csv(left_top, right_top, config["left"], config["right"], OUT / config["csv"])
    sources = load_extended_sources()
    left_extra = extended_metrics(sources, *SEGMENT_METRIC_SPECS[config["left"]])
    right_extra = extended_metrics(sources, *SEGMENT_METRIC_SPECS[config["right"]])
    fig = plt.figure(figsize=(22, 28), dpi=170); ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    ax.text(0.035, 0.965, config["title"], fontsize=25, weight="bold", color=TEXT, va="center")
    ax.text(0.035, 0.941, "顶部：7月日均漏斗 + 7月29日–8月4日单次进入行为 + 7月成熟cohort D1复用｜下方：各自打勾Top20素材。", fontsize=11.5, color=MUTED, va="center")
    draw_overall_card(ax, left, left_extra, config["left"], PRIMARY, "#FFF4F2", 0.025, 0.730, 0.466, 0.180)
    draw_overall_card(ax, right, right_extra, config["right"], SECONDARY, "#E9EEF6", 0.509, 0.730, 0.466, 0.180)
    draw_material_card(ax, left_top, config["left"], PRIMARY, "#FFF4F2", 0.025, 0.040, 0.466, 0.655)
    draw_material_card(ax, right_top, config["right"], SECONDARY, "#E9EEF6", 0.509, 0.040, 0.466, 0.655)
    ax.text(0.035, 0.018, "口径：曝光点击率=总点击/总曝光，点击打勾率=总打勾/总点击，打勾保存率=总保存/总打勾；Top20按各分层素材打勾UV日均排序。数据源：北斗素材看板 10015925 / 90069。", fontsize=8.4, color=MUTED)
    fig.savefig(OUT / config["output"], bbox_inches="tight", pad_inches=0.08); plt.close(fig)
    print(OUT / config["output"]); print(OUT / config["csv"])


def main() -> None:
    setup_style(); src = source_module(); OUT.mkdir(parents=True, exist_ok=True)
    for config in COMPARISONS: generate(src, config)


if __name__ == "__main__": main()

#!/usr/bin/env python3
"""生成巴西 iOS vs Android：整体漏斗与两列素材 Top20。"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
SOURCE_SCRIPT = Path(__file__).with_name("04_生成巴西滤镜分析产物.py")
BASE_SCRIPT = Path(__file__).with_name("09_生成巴西新老及新用户来源素材偏好图.py")
IOS_INPUT = OUT / "01_素材看板日均_巴西_iOS_202607.json"
ANDROID_INPUT = OUT / "01_素材看板日均_巴西_Android_202607.json"
OUTPUT = OUT / "05_巴西iOS与Android滤镜整体及素材Top20.png"
CSV_OUTPUT = OUT / "05_巴西iOS与Android打勾Top20素材.csv"

BG, CARD, TEXT, MUTED, LINE, HEADER = "#F4F6FA", "#FFFFFF", "#182235", "#8794A8", "#E1E6EE", "#F7F9FC"
IOS, ANDROID = "#E14B3F", "#65748A"
RATES = [("曝光点击率", "曝光uv", "点击uv"), ("点击打勾率", "点击uv", "打勾uv"), ("打勾保存率", "打勾uv", "保存uv")]


def source_module():
    spec = importlib.util.spec_from_file_location("brazil_material_source", SOURCE_SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def base_module():
    spec = importlib.util.spec_from_file_location("segment_chart_base", BASE_SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def setup_style() -> None:
    plt.rcParams.update({"font.family": ["PingFang HK", "Heiti TC", "Arial Unicode MS", "DejaVu Sans"], "axes.unicode_minus": False, "figure.facecolor": BG, "savefig.facecolor": BG})


def add_metrics(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    out["打勾占比"] = out["打勾uv"] / out["打勾uv"].sum()
    return out


def weighted_rates(df: pd.DataFrame) -> dict[str, float]:
    result = {}
    for label, denominator, numerator in RATES:
        den = df[denominator].sum()
        result[label] = df[numerator].sum() / den if den else float("nan")
    return result


def top20(df: pd.DataFrame) -> pd.DataFrame:
    return df.sort_values("打勾uv", ascending=False).head(20).copy()


def export_csv(ios_top: pd.DataFrame, android_top: pd.DataFrame) -> None:
    pieces = []
    for platform, table in [("iOS", ios_top), ("Android", android_top)]:
        out = table[["素材id", "素材名称", "分类名称", "曝光uv", "打勾uv", "打勾占比"]].copy()
        out.insert(0, "排名", range(1, len(out) + 1)); out.insert(0, "平台", platform)
        out.columns = ["平台", "排名", "素材id", "素材名称", "分类名称", "曝光UV", "打勾UV", "打勾占比"]
        pieces.append(out)
    pd.concat(pieces, ignore_index=True).to_csv(CSV_OUTPUT, index=False, encoding="utf-8-sig")


def draw_overall_card(ax, df: pd.DataFrame, extra: list[tuple[str, float, str]], platform: str, x: float, y: float, w: float, h: float) -> None:
    accent = IOS if platform == "iOS" else ANDROID
    title_bg = "#FFF4F2" if platform == "iOS" else "#E9EEF6"
    rates = weighted_rates(df)
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.012", fc=CARD, ec=LINE, lw=0.9))
    ax.add_patch(FancyBboxPatch((x + 0.006, y + h - 0.045), w - 0.012, 0.036, boxstyle="round,pad=0,rounding_size=0.008", fc=title_bg, ec="none"))
    ax.text(x + 0.018, y + h - 0.027, f"{platform}｜全部素材", fontsize=14, weight="bold", color=accent, va="center")
    metrics = [(label, rates[label], "pct") for label, _, _ in RATES] + extra
    left, right = x + 0.014, x + w - 0.014
    top, bottom = y + h - 0.055, y + 0.012
    cell_w, cell_h = (right - left) / 3, (top - bottom) / 3
    for col in (1, 2):
        cx = left + col * cell_w
        ax.plot([cx, cx], [bottom, top], color=LINE, lw=0.7)
    for row_i in (1, 2):
        cy = top - row_i * cell_h
        ax.plot([left, right], [cy, cy], color=LINE, lw=0.7)
    for i, (label, value, fmt) in enumerate(metrics):
        row_i, col_i = divmod(i, 3)
        cx, cy_top = left + col_i * cell_w, top - row_i * cell_h
        shown = f"{value:.1%}" if fmt == "pct" else f"{value:.1f}"
        ax.text(cx + 0.010, cy_top - cell_h * 0.28, label, fontsize=10.2, color=MUTED, va="center", linespacing=1.35)
        ax.text(cx + 0.010, cy_top - cell_h * 0.73, shown, fontsize=17.5, color=accent, weight="bold", va="center")


def draw_material_card(ax, table: pd.DataFrame, platform: str, x: float, y: float, w: float, h: float) -> None:
    accent = IOS if platform == "iOS" else ANDROID
    title_bg = "#FFF4F2" if platform == "iOS" else "#E9EEF6"
    highlight_names = {"Glow-4", "FJ-1", "Bora"} if platform == "iOS" else {"Classic", "Bright White"}
    highlight_bg = "#FFF1EE" if platform == "iOS" else "#EEF2F7"
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.012", fc=CARD, ec=LINE, lw=0.9))
    ax.add_patch(FancyBboxPatch((x + 0.006, y + h - 0.050), w - 0.012, 0.041, boxstyle="round,pad=0,rounding_size=0.008", fc=title_bg, ec="none"))
    ax.text(x + 0.018, y + h - 0.029, f"{platform}｜打勾 Top20 素材", fontsize=14, weight="bold", color=accent, va="center")
    ax.text(x + w - 0.018, y + h - 0.029, "按打勾UV日均降序", fontsize=8.2, color=MUTED, ha="right", va="center")
    ax.text(x + 0.018, y + h - 0.072, "素材名下方：曝光UV＝看到该素材的人数｜打勾占比＝该素材打勾UV / 本端全部素材打勾UV", fontsize=9.2, color=MUTED, va="center")

    header_y = y + h - 0.104
    ax.add_patch(Rectangle((x + 0.008, header_y - 0.015), w - 0.016, 0.030, fc=HEADER, ec="none"))
    ax.text(x + 0.020, header_y, "排名", fontsize=10, weight="bold", color=TEXT, va="center")
    ax.text(x + 0.085, header_y, "素材及指标", fontsize=10, weight="bold", color=TEXT, va="center")
    ax.text(x + w - 0.020, header_y, "分类", fontsize=10, weight="bold", color=TEXT, ha="right", va="center")

    row_top = header_y - 0.034
    row_h = (h - 0.155) / 20
    for i, (_, row) in enumerate(table.iterrows(), start=1):
        ry = row_top - (i - 1) * row_h
        is_highlight = str(row["素材名称"]) in highlight_names
        if is_highlight:
            ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), w - 0.016, row_h, fc=highlight_bg, ec="none"))
        elif i % 2 == 0:
            ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), w - 0.016, row_h, fc="#FAFBFD", ec="none"))
        if is_highlight:
            ax.add_patch(Rectangle((x + 0.008, ry - row_h / 2), 0.004, row_h, fc=accent, ec="none"))
        name = str(row["素材名称"]); name = name[:22] + ("…" if len(name) > 22 else "")
        ax.text(x + 0.022, ry, f"{i:02d}", fontsize=9.0, color=MUTED, va="center")
        ax.text(x + 0.085, ry + row_h * 0.17, name, fontsize=10.8, color=TEXT, weight="bold" if is_highlight else "normal", va="center")
        ax.text(x + 0.085, ry - row_h * 0.21, f"曝光UV {row['曝光uv']:,.0f}   ·   打勾占比 {row['打勾占比']:.1%}", fontsize=8.9, color=accent, va="center")
        ax.text(x + w - 0.020, ry, str(row["分类名称"]), fontsize=9.0, color=MUTED, ha="right", va="center")


def main() -> None:
    setup_style(); src = source_module(); base = base_module(); OUT.mkdir(parents=True, exist_ok=True)
    ios = add_metrics(src.aggregate_material(src.load_beidou(IOS_INPUT)))
    android = add_metrics(src.aggregate_material(src.load_beidou(ANDROID_INPUT)))
    ios_top, android_top = top20(ios), top20(android)
    export_csv(ios_top, android_top)

    extended_sources = base.load_extended_sources()
    ios_extra = base.extended_metrics(extended_sources, "os_type", "ios", lambda d: d["os_type"] == "ios")
    android_extra = base.extended_metrics(extended_sources, "os_type", "android", lambda d: d["os_type"] == "android")

    fig = plt.figure(figsize=(22, 28), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    ax.text(0.035, 0.965, "巴西分端｜iOS vs Android 滤镜素材偏好", fontsize=25, weight="bold", color=TEXT, va="center")
    ax.text(0.035, 0.941, "顶部：7月日均漏斗 + 7月29日–8月4日单次进入行为 + 7月成熟cohort D1复用｜下方：两端各自打勾Top20素材。", fontsize=11.5, color=MUTED, va="center")
    draw_overall_card(ax, ios, ios_extra, "iOS", 0.025, 0.730, 0.466, 0.180)
    draw_overall_card(ax, android, android_extra, "Android", 0.509, 0.730, 0.466, 0.180)
    draw_material_card(ax, ios_top, "iOS", 0.025, 0.040, 0.466, 0.655)
    draw_material_card(ax, android_top, "Android", 0.509, 0.040, 0.466, 0.655)
    ax.text(0.035, 0.017, "口径：次均指标按单次进入Filters计算；首次点击前曝光素材数仅统计有点击的进入；D1又打勾任一滤镜=次日任一滤镜打勾用户/首日打勾用户；D1相同滤镜=次日打勾首日同素材用户/D1又打勾用户。", fontsize=8.2, color="#E14B3F")
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.08); plt.close(fig)
    print(OUTPUT); print(CSV_OUTPUT)


if __name__ == "__main__":
    main()

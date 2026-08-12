#!/usr/bin/env python3
"""生成巴西付费用户 vs 免费用户的整体指标与素材打勾 Top20。"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
BASE_SCRIPT = Path(__file__).with_name("09_生成巴西新老及新用户来源素材偏好图.py")
INPUT = OUT / "10_巴西付费与免费滤镜素材表现_202607.csv"
MAPPING_INPUT = OUT / "01_素材看板日均_巴西_202607.json"
OUTPUT = OUT / "10_巴西付费与免费用户滤镜整体及素材Top20.png"
CSV_OUTPUT = OUT / "10_巴西付费与免费用户打勾Top20素材.csv"

PAID, FREE = "#E14B3F", "#3972A8"
SEGMENTS = [
    ("付费用户", "Paying", PAID, "#FFF4F2"),
    ("免费用户", "Un-Paying", FREE, "#EDF4FB"),
]


def base_module():
    spec = importlib.util.spec_from_file_location("paid_free_chart_base", BASE_SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def load_material_data(base) -> pd.DataFrame:
    raw = pd.read_csv(INPUT)
    raw.columns = [column.rsplit(".", 1)[-1] for column in raw.columns]
    src = base.source_module()
    mapping = src.aggregate_material(src.load_beidou(MAPPING_INPUT))[
        ["素材id", "素材名称", "分类名称"]
    ].drop_duplicates("素材id")
    mapping["素材id"] = mapping["素材id"].astype(str)
    raw["material_id"] = raw["material_id"].astype(str)
    out = raw.merge(mapping, left_on="material_id", right_on="素材id", how="left")
    out["素材id"] = out["material_id"]
    out["素材名称"] = out["素材名称"].fillna(out["material_id"])
    out["分类名称"] = out["分类名称"].fillna(out["category_id"].fillna("未知"))
    out["曝光uv"] = out["exposure_uv_daily"]
    out["打勾uv"] = out["check_uv_daily"]
    out["打勾占比"] = out["check_share"]
    return out


def overall_metrics(table: pd.DataFrame, extra: list[tuple[str, float, str]]) -> list[tuple[str, float, str]]:
    exposure = table["exposure_user_days"].sum()
    click = table["click_user_days"].sum()
    check = table["check_user_days"].sum()
    return [
        ("曝光点击率", click / exposure, "pct"),
        ("点击打勾率", check / click, "pct"),
        *extra,
    ]


def draw_overall_card(base, ax, metrics, label, accent, bg, x, y, w, h) -> None:
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.006,rounding_size=0.012", fc=base.CARD, ec=base.LINE, lw=0.9))
    ax.add_patch(FancyBboxPatch((x + 0.006, y + h - 0.045), w - 0.012, 0.036, boxstyle="round,pad=0,rounding_size=0.008", fc=bg, ec="none"))
    ax.text(x + 0.018, y + h - 0.027, f"{label}｜全部素材", fontsize=14, weight="bold", color=accent, va="center")
    left, right = x + 0.014, x + w - 0.014
    top, bottom = y + h - 0.055, y + 0.012
    cell_w, cell_h = (right - left) / 4, (top - bottom) / 2
    for col in (1, 2, 3):
        cx = left + col * cell_w
        ax.plot([cx, cx], [bottom, top], color=base.LINE, lw=0.7)
    ax.plot([left, right], [bottom + cell_h, bottom + cell_h], color=base.LINE, lw=0.7)
    for i, (metric, value, fmt) in enumerate(metrics):
        row_i, col_i = divmod(i, 4)
        cx, cy_top = left + col_i * cell_w, top - row_i * cell_h
        shown = f"{value:.1%}" if fmt == "pct" else f"{value:.1f}"
        ax.text(cx + 0.008, cy_top - cell_h * 0.28, metric, fontsize=9.6, color=base.MUTED, va="center", linespacing=1.35)
        ax.text(cx + 0.008, cy_top - cell_h * 0.73, shown, fontsize=17.0, color=accent, weight="bold", va="center")


def export_top20(datasets) -> None:
    pieces = []
    for label, table in datasets:
        out = table[["素材id", "素材名称", "分类名称", "曝光uv", "打勾uv", "打勾占比"]].copy()
        out.insert(0, "排名", range(1, len(out) + 1))
        out.insert(0, "用户类型", label)
        out.columns = ["用户类型", "排名", "素材id", "素材名称", "分类名称", "曝光UV", "打勾UV", "打勾占比"]
        pieces.append(out)
    pd.concat(pieces, ignore_index=True).to_csv(CSV_OUTPUT, index=False, encoding="utf-8-sig")


def main() -> None:
    base = base_module(); base.setup_style(); OUT.mkdir(parents=True, exist_ok=True)
    material = load_material_data(base)
    sources = base.load_extended_sources()
    loaded = []
    for label, status, accent, bg in SEGMENTS:
        table = material[material["pay_status"] == status].copy()
        top = table.sort_values("打勾uv", ascending=False).head(20).copy()
        extra = base.extended_metrics(sources, "pay_status", status, lambda d, value=status: d["pay_status"] == value)
        loaded.append((label, table, top, overall_metrics(table, extra), accent, bg))
    export_top20([(label, top) for label, _, top, _, _, _ in loaded])

    fig = plt.figure(figsize=(22, 28), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    ax.text(0.035, 0.965, "巴西付费状态｜付费用户 vs 免费用户滤镜素材偏好", fontsize=25, weight="bold", color=base.TEXT, va="center")
    ax.text(0.035, 0.941, "顶部：7月素材漏斗 + 7月29日–8月4日单次进入行为 + 7月成熟cohort D1复用｜下方：各自打勾Top20素材。", fontsize=11.5, color=base.MUTED, va="center")
    xs = [0.025, 0.509]
    for x, (label, table, top, metrics, accent, bg) in zip(xs, loaded):
        draw_overall_card(base, ax, metrics, label, accent, bg, x, 0.730, 0.466, 0.180)
        base.draw_material_card(ax, top, label, accent, bg, x, 0.040, 0.466, 0.655)
    ax.text(0.035, 0.017, "口径：付费状态取行为发生当天；免费用户=当天未订阅。素材UV按日期×用户×素材去重后除以31；无保存事件，因此不展示打勾保存率。D1相同滤镜以D1又打勾任一滤镜用户为分母。", fontsize=8.2, color="#E14B3F")
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.08); plt.close(fig)
    print(OUTPUT); print(CSV_OUTPUT)


if __name__ == "__main__":
    main()

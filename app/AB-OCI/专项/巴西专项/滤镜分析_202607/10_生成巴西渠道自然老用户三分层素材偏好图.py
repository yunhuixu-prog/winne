#!/usr/bin/env python3
"""生成巴西渠道新用户、自然新用户、老用户三列素材偏好图。"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
BASE_SCRIPT = Path(__file__).with_name("09_生成巴西新老及新用户来源素材偏好图.py")
OUTPUT = OUT / "08_巴西渠道自然老用户三分层滤镜整体及素材Top20.png"
CSV_OUTPUT = OUT / "08_巴西渠道自然老用户三分层打勾Top20素材.csv"

SEGMENTS = [
    ("渠道新用户", "01_素材看板日均_巴西_渠道新用户_202607.json", "#E14B3F", "#FFF4F2", "is_ua_new_only", "non-Organic", lambda d: (d["is_new"] == "New") & (d["is_ua"] == "non-Organic"), {"iP 8", "Ibiza"}),
    ("自然新用户", "01_素材看板日均_巴西_自然新用户_202607.json", "#3972A8", "#EDF4FB", "is_ua_new_only", "Organic", lambda d: (d["is_new"] == "New") & (d["is_ua"] == "Organic"), {"Glow-4", "FJ-1"}),
    ("老用户", "01_素材看板日均_巴西_老用户_202607.json", "#65748A", "#E9EEF6", "is_new", "Old", lambda d: d["is_new"] == "Old", {"Brighten"}),
]


def base_module():
    spec = importlib.util.spec_from_file_location("segment_chart_base", BASE_SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def export_csv(datasets: list[tuple[str, pd.DataFrame]]) -> None:
    pieces = []
    for label, table in datasets:
        out = table[["素材id", "素材名称", "分类名称", "曝光uv", "打勾uv", "打勾占比"]].copy()
        out.insert(0, "排名", range(1, len(out) + 1)); out.insert(0, "分层", label)
        out.columns = ["分层", "排名", "素材id", "素材名称", "分类名称", "曝光UV", "打勾UV", "打勾占比"]
        pieces.append(out)
    pd.concat(pieces, ignore_index=True).to_csv(CSV_OUTPUT, index=False, encoding="utf-8-sig")


def main() -> None:
    base = base_module(); base.setup_style(); src = base.source_module(); OUT.mkdir(parents=True, exist_ok=True)
    loaded = []
    extended_sources = base.load_extended_sources()
    for label, filename, accent, bg, dimension, value, d1_mask, highlights in SEGMENTS:
        df = base.add_metrics(src.aggregate_material(src.load_beidou(OUT / filename)))
        extra = base.extended_metrics(extended_sources, dimension, value, d1_mask)
        loaded.append((label, df, base.top20(df), accent, bg, extra, highlights))
    export_csv([(label, top) for label, _, top, _, _, _, _ in loaded])

    fig = plt.figure(figsize=(30, 28), dpi=170)
    ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    ax.text(0.025, 0.965, "巴西用户分层｜渠道新用户 vs 自然新用户 vs 老用户滤镜素材偏好", fontsize=25, weight="bold", color=base.TEXT, va="center")
    ax.text(0.025, 0.941, "顶部：7月日均漏斗 + 7月29日–8月4日单次进入行为 + 7月成熟cohort D1复用｜下方：各自打勾Top20素材。", fontsize=11.5, color=base.MUTED, va="center")
    xs, width = [0.018, 0.344, 0.670], 0.312
    for x, (label, df, top, accent, bg, extra, highlights) in zip(xs, loaded):
        base.draw_overall_card(ax, df, extra, label, accent, bg, x, 0.730, width, 0.180)
        base.draw_material_card(ax, top, label, accent, bg, x, 0.040, width, 0.655, highlights)
    ax.text(0.025, 0.017, "口径：次均指标按单次进入Filters计算；首次点击前曝光素材数仅统计有点击的进入；D1又打勾任一滤镜=次日任一滤镜打勾用户/首日打勾用户；D1相同滤镜=次日打勾首日同素材用户/D1又打勾用户。", fontsize=8.2, color="#E14B3F")
    fig.savefig(OUTPUT, bbox_inches="tight", pad_inches=0.08); plt.close(fig)
    print(OUTPUT); print(CSV_OUTPUT)


if __name__ == "__main__": main()

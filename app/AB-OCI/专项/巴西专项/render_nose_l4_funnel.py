#!/usr/bin/env python3
import csv
import importlib.util
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
BASE_RENDER = ROOT / "app/AB-OCI/专项/巴西专项/render_face_subfeature_funnel.py"
SOURCE = (
    ROOT
    / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/"
    "巴西专项_Face_Nose四级功能漏斗_202606.csv"
)
FACE_SOURCE = (
    ROOT
    / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/"
    "巴西专项_Face_Adjust子项漏斗_202606.csv"
)
OUTPUT = (
    ROOT
    / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/"
    "巴西专项_Face_Nose四级功能漏斗对比.png"
)


spec = importlib.util.spec_from_file_location("face_renderer", BASE_RENDER)
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


def read_data():
    with SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        raw_rows = list(csv.DictReader(handle))
    index = {
        (row["国家维度"], row["四级功能"]): row
        for row in raw_rows
        if row["国家维度"] in {"巴西", "整体"}
    }
    features = sorted(
        {
            row["四级功能"]
            for row in raw_rows
            if row["国家维度"] == "巴西"
            and ("整体", row["四级功能"]) in index
        },
        key=lambda feature: -float(index[("巴西", feature)]["进入人数"]),
    )
    rows = [
        {
            "feature": feature,
            "br": index[("巴西", feature)],
            "overall": index[("整体", feature)],
        }
        for feature in features
    ]

    with FACE_SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        face_rows = list(csv.DictReader(handle))
    denominators = {
        row["国家维度"]: float(row["进入人数"])
        for row in face_rows
        if row["二级功能"] == "Face"
        and row["三级功能"] == "Nose"
        and row["国家维度"] in {"巴西", "整体"}
    }
    return rows, denominators


def metric_pair(row, denominators, metric):
    if metric == "进入占 Nose":
        return (
            float(row["br"]["进入人数"]) / denominators["巴西"],
            float(row["overall"]["进入人数"]) / denominators["整体"],
        )
    if metric == "进入打勾率":
        return (
            float(row["br"]["进入打勾率"]),
            float(row["overall"]["进入打勾率"]),
        )
    if metric == "进入保存率":
        return (
            float(row["br"]["进入保存率"]),
            float(row["overall"]["进入保存率"]),
        )
    raise ValueError(metric)


def footnote_text(denominators):
    return (
        f"Face-Nose 进入：巴西 {denominators['巴西']:,.0f} 人/日，"
        f"整体 {denominators['整体']:,.0f} 人/日；明细按2026年6月有效日期取日均。"
        "四级功能通过行级三级字段限定为 Nose，避免同名四级项被其他三级功能混入。"
    )


def main():
    renderer.OUTPUT = OUTPUT
    renderer.TITLE = "Face－Nose 四级功能｜进入与效果确认漏斗"
    renderer.SUBTITLE = (
        "按巴西四级功能进入人数降序；每列展示 gap（巴西－整体）及巴西/整体具体值。"
    )
    renderer.FEATURE_HEADER = "Nose 四级功能"
    renderer.FEATURE_SUBHEADER = "巴西四级功能进入人数（日均 UV）"
    renderer.METRICS = ["进入占 Nose", "进入打勾率", "进入保存率"]
    renderer.HEADER_SUBTITLES = {
        "进入占 Nose": "四级功能进入 / Face-Nose 进入",
        "进入打勾率": "四级功能打勾 / 四级功能进入",
        "进入保存率": "四级功能保存 / 四级功能进入",
    }
    renderer.read_data = read_data
    renderer.metric_pair = metric_pair
    renderer.footnote_text = footnote_text
    renderer.main()


if __name__ == "__main__":
    main()

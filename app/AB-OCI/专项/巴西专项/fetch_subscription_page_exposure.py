#!/usr/bin/env python3
import importlib.util
import json
import sys
from collections import defaultdict
from pathlib import Path


SKILL_SCRIPT = Path("/Users/xuyunhui/.codex/skills/beidou-dashboard-data/scripts/beidou_tool_api.py")
spec = importlib.util.spec_from_file_location("beidou_tool_api", SKILL_SCRIPT)
beidou = importlib.util.module_from_spec(spec)
spec.loader.exec_module(beidou)

COUNTRIES = ["整体", "巴西"]
L3_FEATURES = [
    "Face", "AI Retouch", "Eraser", "Filters", "Relight", "Body", "Makeup",
    "Magic", "AI Repair", "Hair", "Reshape", "Adjust", "Teeth", "AI Replace",
    "AI Expand", "Glowup", "Background", "Resize", "Crop", "Effects",
]
SKIN_FEATURES = [
    "Smooth", "Contour", "Concealer", "Wrinkle", "Skin Tone", "Detail",
    "Brighten", "Matte", "Texture", "Acne", "Clean Skin",
]


def call(params):
    result = beidou.call_api("dashboard_data", params=params, env="oci")
    response = result["response"]
    if response.get("code") not in (0, 200):
        raise RuntimeError(response.get("message") or str(response))
    return response["response"]["data"]


def metric_value(row):
    for key in ("订阅页进入人数", "订阅页曝光人数", "指标值", "value"):
        if key in row and isinstance(row[key], (int, float)):
            return float(row[key])
    numeric = [
        float(value) for key, value in row.items()
        if isinstance(value, (int, float)) and key not in {"chartID", "chartId"}
    ]
    if len(numeric) == 1:
        return numeric[0]
    raise KeyError(f"无法识别订阅页进入人数: {row}")


def base_filters(country):
    return [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "平台", "value": ["整体"]},
        {"name": "自然/渠道投放", "value": ["整体"]},
        {"name": "新老用户", "value": ["整体"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "版本", "value": ["整体"]},
        {"name": "分类", "value": ["Edit"]},
    ]


def fetch_level(country, level):
    if level == 3:
        dashboard_id, chart_id = 10015763, 88547
        features = L3_FEATURES
        dim_candidates = ["三级归因", "三级分类"]
        filters = base_filters(country) + [
            {"name": "二级归因", "value": ["Retouch", "Edit", "Material"]},
            {"name": "三级归因", "value": features},
        ]
    else:
        dashboard_id, chart_id = 10015764, 88559
        features = SKIN_FEATURES
        dim_candidates = ["四级归因", "四级分类"]
        filters = base_filters(country) + [
            {"name": "二级归因", "value": ["Retouch"]},
            {"name": "三级归因", "value": ["Skin"]},
            {"name": "四级分类", "value": features},
        ]
    charts = call({"dashboard_id": dashboard_id, "chart_id": [chart_id], "filters": filters})
    values = defaultdict(float)
    for chart in charts:
        for row in chart.get("data", []):
            feature = next((row[name] for name in dim_candidates if name in row), None)
            if feature in features:
                values[feature] += metric_value(row)
    return {feature: values[feature] for feature in features}


def main():
    rows = []
    for country in COUNTRIES:
        print(f"正在查询订阅页进入人数：{country} / L3", file=sys.stderr, flush=True)
        l3 = fetch_level(country, 3)
        print(f"正在查询订阅页进入人数：{country} / Skin L4", file=sys.stderr, flush=True)
        l4 = fetch_level(country, 4)
        for feature in L3_FEATURES + SKIN_FEATURES:
            value = l3.get(feature, l4.get(feature, 0.0))
            rows.append({"国家维度": country, "功能": feature, "订阅页曝光人数": value})
    output = Path(__file__).with_name("巴西专项_订阅页曝光人数_202606.json")
    output.write_text(json.dumps({
        "period": "2026-06-01 至 2026-06-30",
        "metric_source": "订阅页进入人数",
        "rows": rows,
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"output": str(output), "rows": len(rows)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

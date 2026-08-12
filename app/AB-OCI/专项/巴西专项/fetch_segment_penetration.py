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

COUNTRIES = ["整体", "巴西", "美国", "英国", "墨西哥"]
SEGMENTS = {"New": "新用户", "Old": "老用户"}
L3_FEATURES = [
    "Face", "AI Retouch", "Eraser", "Filters", "Relight", "Body", "Makeup",
    "Magic", "AI Repair", "Hair", "Reshape", "Adjust", "Teeth", "AI Replace",
    "AI Expand", "Glowup", "Background", "Resize", "Crop", "Effects",
]
SKIN_FEATURES = [
    "Smooth", "Contour", "Concealer", "Wrinkle", "Skin Tone", "Detail",
    "Brighten", "Matte", "Texture", "Acne", "Clean Skin",
]
FEATURES = L3_FEATURES + SKIN_FEATURES
FILTER_FEATURES = L3_FEATURES + ["Details" if x == "Detail" else x for x in SKIN_FEATURES]


def call(params):
    result = beidou.call_api("dashboard_data", params=params, env="oci")
    response = result["response"]
    if response.get("code") not in (0, 200):
        raise RuntimeError(response.get("message") or str(response))
    return response["response"]["data"]


def metric_value(row):
    for key in ("进入渗透率", "指标值", "value"):
        if key in row and isinstance(row[key], (int, float)):
            return float(row[key])
    numeric = [
        float(value) for key, value in row.items()
        if isinstance(value, (int, float)) and key not in {"chartID", "chartId"}
    ]
    if len(numeric) == 1:
        return numeric[0]
    raise KeyError(f"无法识别进入渗透率: {row}")


def fetch(country, segment):
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "平台", "value": ["整体"]},
        {"name": "新老", "value": [segment]},
        {"name": "版本", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
        {"name": "一级功能", "value": ["图片编辑"]},
        {"name": "二级功能", "value": FILTER_FEATURES},
    ]
    charts = call({"dashboard_id": 10015706, "chart_id": [90774], "filters": filters})
    totals, counts = defaultdict(float), defaultdict(int)
    for chart in charts:
        for row in chart.get("data", []):
            feature = row.get("二级功能名", row.get("二级功能"))
            if feature == "Details":
                feature = "Detail"
            if feature not in FEATURES:
                continue
            returned_segment = row.get("新老")
            if returned_segment is not None and returned_segment != segment:
                raise ValueError(f"新老筛选未生效：请求 {segment}，返回 {returned_segment}")
            returned_country = row.get("国家/地区")
            if country != "整体" and returned_country is not None and returned_country != country:
                raise ValueError(f"国家筛选未生效：请求 {country}，返回 {returned_country}")
            totals[feature] += metric_value(row)
            counts[feature] += 1
    missing = [feature for feature in FEATURES if counts[feature] == 0]
    if missing:
        print(f"警告：{SEGMENTS[segment]}-{country} 无数据功能: {', '.join(missing)}", file=sys.stderr)
    return {feature: totals[feature] / counts[feature] if counts[feature] else 0.0 for feature in FEATURES}


def main():
    rows = []
    for segment, segment_cn in SEGMENTS.items():
        for country in COUNTRIES:
            print(f"正在查询：{segment_cn} / {country}", file=sys.stderr, flush=True)
            values = fetch(country, segment)
            rows.extend(
                {"用户类型": segment_cn, "新老筛选值": segment, "国家维度": country,
                 "功能": feature, "进入渗透率": values[feature]}
                for feature in FEATURES
            )
    payload = {
        "period": "2026-06-01 至 2026-06-30",
        "dashboard_id": 10015706,
        "chart_id": 90774,
        "rows": rows,
    }
    output = Path(__file__).with_name("巴西专项_功能渗透率_新老用户_202606.json")
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"output": str(output), "rows": len(rows)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

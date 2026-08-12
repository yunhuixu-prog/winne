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
CHANNEL_SEGMENTS = {"Organic": "自然新用户", "non-Organic": "渠道新用户"}
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


def fetch(country, channel_segment):
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "平台", "value": ["整体"]},
        {"name": "新老", "value": ["New"]},
        {"name": "版本", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "渠道/自然", "value": [channel_segment]},
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
            returned_new_old = row.get("新老")
            if returned_new_old is not None and returned_new_old not in {"New", "新用户"}:
                raise ValueError(f"新老筛选未生效：请求 New，返回 {returned_new_old}")
            returned_channel = row.get("渠道/自然")
            if returned_channel is not None and returned_channel != channel_segment:
                raise ValueError(
                    f"渠道/自然筛选未生效：请求 {channel_segment}，返回 {returned_channel}"
                )
            returned_country = row.get("国家/地区")
            if country != "整体" and returned_country is not None and returned_country != country:
                raise ValueError(f"国家筛选未生效：请求 {country}，返回 {returned_country}")
            totals[feature] += metric_value(row)
            counts[feature] += 1
    missing = [feature for feature in FEATURES if counts[feature] == 0]
    if missing:
        label = CHANNEL_SEGMENTS[channel_segment]
        print(f"警告：{label}-{country} 无数据功能: {', '.join(missing)}", file=sys.stderr)
    return {
        feature: totals[feature] / counts[feature] if counts[feature] else 0.0
        for feature in FEATURES
    }


def main():
    rows = []
    for channel_segment, segment_cn in CHANNEL_SEGMENTS.items():
        for country in COUNTRIES:
            print(f"正在查询：{segment_cn} / {country}", file=sys.stderr, flush=True)
            values = fetch(country, channel_segment)
            rows.extend(
                {
                    "用户类型": segment_cn,
                    "新老筛选值": "New",
                    "渠道自然筛选值": channel_segment,
                    "国家维度": country,
                    "功能": feature,
                    "进入渗透率": values[feature],
                }
                for feature in FEATURES
            )
    payload = {
        "period": "2026-06-01 至 2026-06-30",
        "dashboard_id": 10015706,
        "chart_id": 90774,
        "rows": rows,
    }
    output = Path(__file__).with_name("巴西专项_功能渗透率_自然渠道新用户_202606.json")
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"output": str(output), "rows": len(rows)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

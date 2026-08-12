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

PLATFORMS = ["iOS", "Android"]
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
FEATURES = L3_FEATURES + SKIN_FEATURES
FILTER_FEATURES = L3_FEATURES + ["Details" if x == "Detail" else x for x in SKIN_FEATURES]
BEHAVIOR_CHARTS = {
    88513: "曝光人数",
    88192: "进入人数",
    88217: "打勾人数",
    88193: "保存人数",
}


def call(params, dashboard_id):
    result = beidou.call_api(
        "dashboard_data",
        params={"dashboard_id": dashboard_id, **params},
        env="oci",
    )
    response = result["response"]
    if response.get("code") not in (0, 200):
        raise RuntimeError(response.get("message") or str(response))
    return response["response"]["data"]


def chart_id(chart):
    return chart.get("chartID", chart.get("chartId"))


def metric_value(row, metric):
    if metric in row and isinstance(row[metric], (int, float)):
        return float(row[metric])
    numeric = [
        float(value) for key, value in row.items()
        if isinstance(value, (int, float)) and key not in {"chartID", "chartId"}
    ]
    if len(numeric) == 1:
        return numeric[0]
    raise KeyError(f"无法识别指标 {metric}: {row}")


def validate_dims(row, platform, country):
    returned_platform = row.get("平台")
    if returned_platform is not None and returned_platform != platform:
        raise ValueError(f"平台筛选未生效：请求 {platform}，返回 {returned_platform}")
    returned_country = row.get("国家/地区")
    if country != "整体" and returned_country is not None and returned_country != country:
        raise ValueError(f"国家筛选未生效：请求 {country}，返回 {returned_country}")


def fetch_behavior(platform, country):
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "平台", "value": [platform]},
        {"name": "新老", "value": ["整体"]},
        {"name": "版本", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
        {"name": "一级功能", "value": ["图片编辑"]},
        {"name": "二级功能", "value": FILTER_FEATURES},
    ]
    charts = call(
        {"chart_id": list(BEHAVIOR_CHARTS), "filters": filters},
        dashboard_id=10015706,
    )
    output = {
        feature: {metric: 0.0 for metric in BEHAVIOR_CHARTS.values()}
        for feature in FEATURES
    }
    valid_days = {
        feature: {metric: 0 for metric in BEHAVIOR_CHARTS.values()}
        for feature in FEATURES
    }
    for chart in charts:
        metric = BEHAVIOR_CHARTS.get(chart_id(chart))
        if not metric:
            continue
        totals, counts = defaultdict(float), defaultdict(int)
        for row in chart.get("data", []):
            validate_dims(row, platform, country)
            feature = row.get("二级功能名", row.get("二级功能"))
            if feature == "Details":
                feature = "Detail"
            if feature not in output:
                continue
            totals[feature] += metric_value(row, metric)
            counts[feature] += 1
        for feature, total in totals.items():
            output[feature][metric] = total / counts[feature]
            valid_days[feature][metric] = counts[feature]
    return output, valid_days


def fetch_dau(platform, country):
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "平台", "value": [platform]},
        {"name": "国家/地区", "value": [country]},
        {"name": "新老", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
    ]
    charts = call({"chart_id": [89122], "filters": filters}, dashboard_id=10015816)
    values = []
    for chart in charts:
        if chart_id(chart) != 89122:
            continue
        for row in chart.get("data", []):
            validate_dims(row, platform, country)
            values.append(metric_value(row, "DAU"))
    if not values:
        raise ValueError(f"DAU 无数据：{platform} / {country}")
    return sum(values) / len(values), len(values)


def main():
    rows = []
    dau_rows = []
    for platform in PLATFORMS:
        for country in COUNTRIES:
            print(f"正在查询：{platform} / {country} / 行为漏斗", file=sys.stderr, flush=True)
            behavior, valid_days = fetch_behavior(platform, country)
            print(f"正在查询：{platform} / {country} / DAU", file=sys.stderr, flush=True)
            dau, dau_days = fetch_dau(platform, country)
            dau_rows.append({
                "平台": platform,
                "国家维度": country,
                "DAU": dau,
                "有效日期数": dau_days,
            })
            for feature in FEATURES:
                row = {
                    "平台": platform,
                    "国家维度": country,
                    "功能": feature,
                    "有效日期数": valid_days[feature],
                }
                row.update(behavior[feature])
                rows.append(row)
    payload = {
        "period": "2026-06-01 至 2026-06-30",
        "dashboard_ids": [10015706, 10015816],
        "chart_ids": list(BEHAVIOR_CHARTS) + [89122],
        "dau": dau_rows,
        "rows": rows,
    }
    output = Path(__file__).with_name("巴西专项_分端行为漏斗_202606.json")
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"output": str(output), "rows": len(rows)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

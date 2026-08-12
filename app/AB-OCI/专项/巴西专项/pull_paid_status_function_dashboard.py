#!/usr/bin/env python3
import csv
import json
import subprocess
import sys
from collections import defaultdict
from pathlib import Path


DASHBOARD_ID = 10015706
CHART_IDS = [88513, 88192, 88217, 88193]
TOOL = Path("/Users/xuyunhui/.codex/skills/beidou-dashboard-data/scripts/beidou_tool_api.py")
OUTPUT_DIR = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302")
RAW_OUTPUT = OUTPUT_DIR / "巴西专项_功能行为_当前付费状态_看板原始_202606.json"
CSV_OUTPUT = OUTPUT_DIR / "巴西专项_功能行为_当前付费状态_202606.csv"

FEATURES = [
    "Reshape", "Magic", "Filters", "Face", "Smooth", "Makeup", "Acne", "Adjust",
    "AI Retouch", "Body", "Relight", "Crop", "Eraser", "Hair", "Resize", "Teeth",
    "Skin Tone", "AI Repair", "Wrinkle", "Concealer", "Glowup", "Effects",
    "Brighten", "Background", "AI Expand",
]

CHART_META = {
    88513: ("曝光人数", "曝光 UV"),
    88192: ("进入人数", "进入 UV"),
    88217: ("打勾人数", "打勾 UV"),
    88193: ("保存人数", "保存 UV"),
}


MARKETS = ["巴西", "整体"]


def request_params(market, pay_status):
    return {
        "dashboard_id": DASHBOARD_ID,
        "chart_id": CHART_IDS,
        "filters": [
            {"name": "日期", "value": ["20260601", "20260630"]},
            {"name": "国家/地区", "value": [market]},
            {"name": "平台", "value": ["整体"]},
            {"name": "新老", "value": ["整体"]},
            {"name": "版本", "value": ["整体"]},
            {"name": "付费状态", "value": [pay_status]},
            {"name": "渠道/自然", "value": ["整体"]},
            {"name": "一级功能", "value": ["图片编辑"]},
            {"name": "二级功能", "value": FEATURES},
        ],
    }


def pull(market, pay_status):
    command = [
        sys.executable,
        str(TOOL),
        "--env",
        "oci",
        "--api",
        "dashboard_data",
        "--params",
        json.dumps(request_params(market, pay_status), ensure_ascii=False),
    ]
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    payload = json.loads(result.stdout)
    response = payload["response"]
    if response.get("code") != 0:
        raise RuntimeError(f"{market}/{pay_status}: {response.get('message')}")
    return payload


def normalize_feature(value):
    value = (value or "").strip()
    if value.lower() == "eraser":
        return "Eraser"
    if value == "Details":
        return "Detail"
    return value


def aggregate(payload, market, pay_status):
    charts = payload["response"]["response"]["data"]
    daily_values = defaultdict(lambda: defaultdict(list))
    chart_row_counts = {}
    for chart in charts:
        chart_id = int(chart["chartID"])
        if chart_id not in CHART_META:
            continue
        metric_name, value_field = CHART_META[chart_id]
        chart_row_counts[str(chart_id)] = len(chart.get("data", []))
        for row in chart.get("data", []):
            feature = normalize_feature(row.get("二级功能名") or row.get("二级功能"))
            if feature not in FEATURES:
                continue
            value = row.get(value_field)
            if value is not None:
                daily_values[feature][metric_name].append(float(value))

    rows = []
    for feature in FEATURES:
        counts = {
            metric: (sum(daily_values[feature][metric]) / len(daily_values[feature][metric]))
            if daily_values[feature][metric] else 0.0
            for metric, _ in CHART_META.values()
        }
        exposure = counts["曝光人数"]
        entered = counts["进入人数"]
        checked = counts["打勾人数"]
        saved = counts["保存人数"]
        rows.append({
            "国家维度": market,
            "付费状态": pay_status,
            "功能": feature,
            **counts,
            "曝光进入率": entered / exposure if exposure else None,
            "进入打勾率": checked / entered if entered else None,
            "打勾保存率": saved / checked if checked else None,
            "进入保存率": saved / entered if entered else None,
            "曝光有效天数": len(daily_values[feature]["曝光人数"]),
            "进入有效天数": len(daily_values[feature]["进入人数"]),
            "打勾有效天数": len(daily_values[feature]["打勾人数"]),
            "保存有效天数": len(daily_values[feature]["保存人数"]),
        })
    return rows, chart_row_counts


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    raw = {
        "source": {
            "dashboard_id": DASHBOARD_ID,
            "chart_ids": CHART_IDS,
            "environment": "oci",
            "period": ["20260601", "20260630"],
            "markets": MARKETS,
            "definition": {
                "Paying": "当前订阅有效期内",
                "Un-Paying": "当前非订阅有效期内",
            },
        },
        "queries": {},
    }
    all_rows = []
    for market in MARKETS:
        raw["queries"][market] = {}
        for pay_status in ["Paying", "Un-Paying"]:
            payload = pull(market, pay_status)
            rows, chart_row_counts = aggregate(payload, market, pay_status)
            all_rows.extend(rows)
            raw["queries"][market][pay_status] = {
                "request": request_params(market, pay_status),
                "chart_row_counts": chart_row_counts,
                "dashboard_data": payload["response"]["response"]["data"],
            }

    RAW_OUTPUT.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    fields = [
        "国家维度", "付费状态", "功能", "曝光人数", "进入人数", "打勾人数", "保存人数",
        "曝光进入率", "进入打勾率", "打勾保存率", "进入保存率",
        "曝光有效天数", "进入有效天数", "打勾有效天数", "保存有效天数",
    ]
    with CSV_OUTPUT.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(all_rows)
    print(json.dumps({
        "raw_output": str(RAW_OUTPUT),
        "csv_output": str(CSV_OUTPUT),
        "rows": len(all_rows),
        "features": len(FEATURES),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()

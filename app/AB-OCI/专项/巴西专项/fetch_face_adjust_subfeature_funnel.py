#!/usr/bin/env python3
import csv
import importlib.util
import json
import time
from collections import defaultdict
from pathlib import Path


SKILL_SCRIPT = Path("/Users/xuyunhui/.codex/skills/beidou-dashboard-data/scripts/beidou_tool_api.py")
OUTPUT_DIR = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302")
RAW_OUTPUT = OUTPUT_DIR / "巴西专项_Face_Adjust子项漏斗_看板原始_202606.json"
CSV_OUTPUT = OUTPUT_DIR / "巴西专项_Face_Adjust子项漏斗_202606.csv"

DASHBOARD_ID = 10015880
CHART_META = {
    90038: ("进入人数", "进入 UV"),
    89558: ("打勾人数", "打勾 UV"),
    89553: ("保存人数", "保存 UV"),
}
MARKETS = ["巴西", "整体"]
SECOND_FEATURES = ["Face", "Adjust"]


spec = importlib.util.spec_from_file_location("beidou_tool_api", SKILL_SCRIPT)
beidou = importlib.util.module_from_spec(spec)
spec.loader.exec_module(beidou)


def request_params(market, second_feature, third_options):
    return {
        "dashboard_id": DASHBOARD_ID,
        "chart_id": list(CHART_META),
        "filters": [
            {"name": "日期", "value": ["20260601", "20260630"]},
            {"name": "国家/地区", "value": [market]},
            {"name": "平台", "value": ["整体"]},
            {"name": "新老", "value": ["整体"]},
            {"name": "版本", "value": ["整体"]},
            {"name": "付费状态", "value": ["整体"]},
            {"name": "渠道/自然", "value": ["整体"]},
            {"name": "一级功能", "value": ["图片编辑"]},
            {"name": "二级功能", "value": [second_feature]},
            {"name": "三级功能", "value": third_options},
        ],
    }


def call(params):
    body = beidou._build_dashboard_body(params)
    client = beidou.BeidouToolClient(
        base_url=beidou._resolve_base_url(env="oci"),
        timeout=300,
    )
    last_error = None
    for attempt in range(1, 4):
        try:
            response = client.dashboard_data(body=body)
            if response.get("code") not in (0, 200):
                raise RuntimeError(response.get("message") or str(response))
            return response["response"]["data"]
        except Exception as exc:
            last_error = exc
            print(f"请求失败，第 {attempt}/3 次：{exc}", flush=True)
            if attempt < 3:
                time.sleep(attempt * 2)
    raise last_error


def get_third_options():
    body = beidou._build_dashboard_body({
        "dashboard_id": DASHBOARD_ID,
        "include_response": False,
    })
    client = beidou.BeidouToolClient(
        base_url=beidou._resolve_base_url(env="oci"),
        timeout=300,
    )
    response = client.dashboard_data(body=body)
    filters = response["response"]["linkageConfig"]["filters"]
    for item in filters:
        if item.get("name") == "三级功能":
            return [
                value
                for value in item.get("options", [])
                if value != "整体"
            ]
    raise KeyError("未找到三级功能筛选器")


def metric_value(row, preferred):
    if isinstance(row.get(preferred), (int, float)):
        return float(row[preferred])
    candidates = [
        float(value)
        for key, value in row.items()
        if isinstance(value, (int, float)) and key not in {"chartID", "chartId"}
    ]
    if len(candidates) == 1:
        return candidates[0]
    raise KeyError(f"无法识别指标 {preferred}: {row}")


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    raw = {
        "source": {
            "dashboard_id": DASHBOARD_ID,
            "chart_ids": list(CHART_META),
            "period": ["20260601", "20260630"],
            "markets": MARKETS,
            "second_features": SECOND_FEATURES,
        },
        "queries": {},
    }
    output_rows = []
    third_options = get_third_options()
    for market in MARKETS:
        raw["queries"][market] = {}
        for second_feature in SECOND_FEATURES:
            print(f"拉取 {market} / {second_feature}", flush=True)
            charts = call(request_params(market, second_feature, third_options))
            raw["queries"][market][second_feature] = charts
            RAW_OUTPUT.write_text(
                json.dumps(raw, ensure_ascii=False),
                encoding="utf-8",
            )
            daily_values = defaultdict(lambda: defaultdict(list))
            for chart in charts:
                chart_id = int(chart.get("chartID", chart.get("chartId")))
                if chart_id not in CHART_META:
                    continue
                metric_name, preferred_field = CHART_META[chart_id]
                for row in chart.get("data", []):
                    third_feature = (
                        row.get("三级功能名")
                        or row.get("三级功能名字")
                        or row.get("三级功能")
                        or row.get("sub_func_level3_name")
                        or row.get("功能名称")
                    )
                    if not third_feature or third_feature == "整体":
                        continue
                    daily_values[str(third_feature)][metric_name].append(
                        metric_value(row, preferred_field)
                    )
            for third_feature, metrics in daily_values.items():
                averages = {
                    metric_name: (
                        sum(metrics[metric_name]) / len(metrics[metric_name])
                        if metrics[metric_name]
                        else 0.0
                    )
                    for metric_name, _ in CHART_META.values()
                }
                entered = averages["进入人数"]
                checked = averages["打勾人数"]
                saved = averages["保存人数"]
                output_rows.append({
                    "国家维度": market,
                    "二级功能": second_feature,
                    "三级功能": third_feature,
                    **averages,
                    "进入打勾率": checked / entered if entered else None,
                    "打勾保存率": saved / checked if checked else None,
                    "进入保存率": saved / entered if entered else None,
                    "进入有效天数": len(metrics["进入人数"]),
                    "打勾有效天数": len(metrics["打勾人数"]),
                    "保存有效天数": len(metrics["保存人数"]),
                })

    RAW_OUTPUT.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    fields = [
        "国家维度", "二级功能", "三级功能", "进入人数", "打勾人数", "保存人数",
        "进入打勾率", "打勾保存率", "进入保存率",
        "进入有效天数", "打勾有效天数", "保存有效天数",
    ]
    with CSV_OUTPUT.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(output_rows)
    print(json.dumps({
        "raw_output": str(RAW_OUTPUT),
        "csv_output": str(CSV_OUTPUT),
        "rows": len(output_rows),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()

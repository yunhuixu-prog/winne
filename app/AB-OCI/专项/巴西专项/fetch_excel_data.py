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
L3_FEATURES = [
    "Face", "AI Retouch", "Eraser", "Filters", "Relight", "Body", "Makeup",
    "Magic", "AI Repair", "Hair", "Reshape", "Adjust", "Teeth", "AI Replace",
    "AI Expand", "Glowup", "Background", "Resize", "Crop", "Effects",
]
SKIN_FEATURES = [
    "Smooth", "Contour", "Concealer", "Wrinkle", "Skin Tone", "Detail",
    "Brighten", "Matte", "Texture", "Acne", "Clean Skin",
]
BEHAVIOR_FEATURES = L3_FEATURES + ["Details" if x == "Detail" else x for x in SKIN_FEATURES]
BEHAVIOR_CHARTS = {
    88513: "曝光人数",
    88192: "进入人数",
    88217: "打勾人数",
    88193: "保存人数",
    90774: "进入渗透率",
}
SUB_L3_CHARTS = {
    88544: "订阅成功人数",
    88545: "付费人数",
    88546: "订阅收入（分成后）",
}
SUB_L4_CHARTS = {
    88556: "订阅成功人数",
    88557: "付费人数",
    88558: "订阅收入（分成后）",
}


def call(params):
    result = beidou.call_api("dashboard_data", params=params, env="oci")
    response = result["response"]
    if response.get("code") not in (0, 200):
        raise RuntimeError(response.get("message") or str(response))
    return response["response"]["data"]


def chart_id(chart):
    return chart.get("chartID", chart.get("chartId"))


def dimension_value(row, candidates):
    for name in candidates:
        if name in row:
            return row[name]
    return None


def metric_value(row, metric):
    if metric in row and isinstance(row[metric], (int, float)):
        return float(row[metric])
    numeric = [
        float(v) for k, v in row.items()
        if isinstance(v, (int, float)) and k not in {"chartID", "chartId"}
    ]
    if len(numeric) == 1:
        return numeric[0]
    raise KeyError(f"无法识别指标 {metric}: {row}")


def fetch_behavior(country):
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "平台", "value": ["整体"]},
        {"name": "新老", "value": ["整体"]},
        {"name": "版本", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
        {"name": "一级功能", "value": ["图片编辑"]},
        {"name": "二级功能", "value": BEHAVIOR_FEATURES},
    ]
    charts = call({
        "dashboard_id": 10015706,
        "chart_id": list(BEHAVIOR_CHARTS),
        "filters": filters,
    })
    output = {name: {metric: 0.0 for metric in BEHAVIOR_CHARTS.values()} for name in L3_FEATURES + SKIN_FEATURES}
    for chart in charts:
        cid = chart_id(chart)
        metric = BEHAVIOR_CHARTS.get(cid)
        if not metric:
            continue
        totals = defaultdict(float)
        counts = defaultdict(int)
        for row in chart.get("data", []):
            feature = dimension_value(row, ["二级功能名", "二级功能"])
            if feature == "Details":
                feature = "Detail"
            if feature in output:
                totals[feature] += metric_value(row, metric)
                counts[feature] += 1
        # 行为看板返回逐日值；按实际返回的日值求平均，与北斗日均口径一致。
        for feature, total in totals.items():
            output[feature][metric] = total / counts[feature]
    return output


def subscription_filters(country, level):
    base = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "平台", "value": ["整体"]},
        {"name": "自然/渠道投放", "value": ["整体"]},
        {"name": "新老用户", "value": ["整体"]},
        {"name": "国家/地区", "value": [country]},
        {"name": "版本", "value": ["整体"]},
        {"name": "分类", "value": ["Edit"]},
    ]
    if level == 3:
        base += [
            {"name": "二级归因", "value": ["Retouch", "Edit", "Material"]},
            {"name": "三级分类", "value": L3_FEATURES},
        ]
    else:
        base += [
            {"name": "二级归因", "value": ["Retouch"]},
            {"name": "三级归因", "value": ["Skin"]},
            {"name": "四级分类", "value": SKIN_FEATURES},
        ]
    return base


def fetch_subscription(country, level):
    chart_map = SUB_L3_CHARTS if level == 3 else SUB_L4_CHARTS
    dashboard_id = 10015763 if level == 3 else 10015764
    features = L3_FEATURES if level == 3 else SKIN_FEATURES
    dim_candidates = ["三级归因", "三级分类"] if level == 3 else ["四级归因", "四级分类"]
    charts = call({
        "dashboard_id": dashboard_id,
        "chart_id": list(chart_map),
        "filters": subscription_filters(country, level),
    })
    output = {name: {metric: 0.0 for metric in chart_map.values()} for name in features}
    for chart in charts:
        cid = chart_id(chart)
        metric = chart_map.get(cid)
        if not metric:
            continue
        for row in chart.get("data", []):
            feature = dimension_value(row, dim_candidates)
            if feature in output:
                output[feature][metric] += metric_value(row, metric)
    return output


def main():
    rows = []
    for country in COUNTRIES:
        print(f"正在查询行为数据：{country}", file=sys.stderr, flush=True)
        behavior = fetch_behavior(country)
        print(f"正在查询订阅 L3：{country}", file=sys.stderr, flush=True)
        sub_l3 = fetch_subscription(country, 3)
        print(f"正在查询 Skin 订阅 L4：{country}", file=sys.stderr, flush=True)
        sub_l4 = fetch_subscription(country, 4)
        for feature in L3_FEATURES + SKIN_FEATURES:
            sub = sub_l3.get(feature, sub_l4.get(feature, {}))
            row = {"国家维度": country, "功能": feature}
            row.update(behavior[feature])
            row.update(sub)
            rows.append(row)
    payload = {
        "period": "2026-06-01 至 2026-06-30",
        "countries": COUNTRIES,
        "rows": rows,
    }
    output_path = Path(__file__).with_name("巴西专项_功能数据_202606.json")
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"output": str(output_path), "rows": len(rows)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

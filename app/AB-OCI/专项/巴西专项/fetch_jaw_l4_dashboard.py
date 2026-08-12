#!/usr/bin/env python3
import argparse
import csv
import importlib.util
import json
from collections import defaultdict
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
API_PATH = Path(
    "/Users/xuyunhui/.codex/skills/beidou-dashboard-data/"
    "scripts/beidou_tool_api.py"
)
OUTPUT_DIR = (
    ROOT
    / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
)
FOURTH_FEATURES = [
    "unkonw",
    "Distance",
    "Root",
    "Double_chin",
    "Stretch",
    "Bridge",
    "Top",
    "Angle",
    "Lower_face",
    "Lift",
    "Width",
    "Lower",
    "3d_lift",
    "Position",
    "Darkcircles",
    "Sculpt",
    "Shape",
    "Length",
    "Jaw_angle",
    "Volume",
    "Vertical",
    "Hairline",
    "Jaw_line",
    "Chin",
    "Tip",
    "Jaw",
    "Redeye",
    "Pupil",
    "Forehead",
    "Philtrum",
    "Size",
    "Lift Pro",
    "Midface",
    "Tilt",
    "Jaw_shape",
    "Upper",
    "Short",
    "Brighten",
    "Double_chin_pro",
    "Temple",
    "Cheekbone",
    "Smile",
    "Horizontal",
    "Muscular",
    "Slender",
    "Hot",
    "Hourglass",
]


def load_api():
    spec = importlib.util.spec_from_file_location("beidou_tool_api", API_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def find_value(row, meta, name):
    for item in meta:
        if item.get("name") == name or item.get("displayName") == name:
            for key in (
                item.get("id"),
                item.get("name"),
                item.get("displayName"),
                item.get("alias"),
            ):
                if key in row:
                    return row[key]
    if name in row:
        return row[name]
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--third", default="Jaw")
    parser.add_argument(
        "--no-fourth-filter",
        action="store_true",
        help="Do not pass the dashboard's fourth-level filter.",
    )
    parser.add_argument(
        "--no-third-filter",
        action="store_true",
        help="Do not pass the dashboard's third-level filter.",
    )
    parser.add_argument(
        "--fourth",
        help="Comma-separated fourth-level values; defaults to all dashboard options.",
    )
    args = parser.parse_args()
    third_feature = args.third
    raw_output = OUTPUT_DIR / f"北斗_Face_{third_feature}四级功能_202606_raw.json"
    csv_output = OUTPUT_DIR / f"巴西专项_Face_{third_feature}四级功能漏斗_202606.csv"

    api = load_api()
    filters = [
        {"name": "日期", "value": ["20260601", "20260630"]},
        {"name": "国家/地区", "value": ["整体", "巴西"]},
        {"name": "平台", "value": ["整体"]},
        {"name": "新老", "value": ["整体"]},
        {"name": "版本", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
        {"name": "一级功能", "value": ["图片编辑"]},
        {"name": "二级功能", "value": ["Face"]},
    ]
    if not args.no_third_filter:
        filters.append({"name": "三级功能", "value": [third_feature]})
    if not args.no_fourth_filter:
        fourth_values = (
            [value.strip() for value in args.fourth.split(",") if value.strip()]
            if args.fourth
            else FOURTH_FEATURES
        )
        filters.append({"name": "四级功能", "value": fourth_values})
    result = api.call_api(
        "dashboard_data",
        params={
            "dashboard_id": 10015982,
            "chart_id": [90318, 90314, 90311],
            "filters": filters,
            "aggr": "DAY",
        },
        env="oci",
    )
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    raw_output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    response = result["response"]["response"]["data"]
    chart_metric = {
        90318: "进入人数",
        90314: "打勾人数",
        90311: "保存人数",
    }
    daily = defaultdict(dict)
    for chart in response:
        chart_id = int(chart["chartID"])
        metric = chart_metric[chart_id]
        group_meta = chart.get("groupByMeta", [])
        aggregate_meta = chart.get("aggregateMeta", [])
        for row in chart.get("data", []):
            country = find_value(row, group_meta, "country")
            date_value = find_value(row, group_meta, "date_p")
            row_third_feature = find_value(row, group_meta, "sub_func_level3_name")
            feature = find_value(row, group_meta, "sub_func_level4_name")
            value = find_value(row, aggregate_meta, "uv")
            if (
                country not in {"整体", "巴西"}
                or row_third_feature != third_feature
                or not feature
                or value is None
            ):
                continue
            daily[(country, str(feature), str(date_value))][metric] = float(value)

    summary = defaultdict(lambda: defaultdict(list))
    for (country, feature, _date), values in daily.items():
        for metric, value in values.items():
            summary[(country, feature)][metric].append(value)

    rows = []
    for (country, feature), metrics in summary.items():
        enters = metrics["进入人数"]
        checks = metrics["打勾人数"]
        saves = metrics["保存人数"]
        enter_avg = sum(enters) / len(enters) if enters else 0
        check_avg = sum(checks) / len(checks) if checks else 0
        save_avg = sum(saves) / len(saves) if saves else 0
        rows.append(
            {
                "国家维度": country,
                "四级功能": feature,
                "进入人数": enter_avg,
                "打勾人数": check_avg,
                "保存人数": save_avg,
                "进入打勾率": check_avg / enter_avg if enter_avg else 0,
                "进入保存率": save_avg / enter_avg if enter_avg else 0,
                "进入有效天数": len(enters),
                "打勾有效天数": len(checks),
                "保存有效天数": len(saves),
            }
        )
    rows.sort(key=lambda row: (row["国家维度"] != "巴西", -row["进入人数"], row["四级功能"]))

    columns = [
        "国家维度",
        "四级功能",
        "进入人数",
        "打勾人数",
        "保存人数",
        "进入打勾率",
        "进入保存率",
        "进入有效天数",
        "打勾有效天数",
        "保存有效天数",
    ]
    with csv_output.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)

    print(f"raw={raw_output}")
    print(f"csv={csv_output}")
    print(f"rows={len(rows)}")
    for row in rows:
        print(
            row["国家维度"],
            row["四级功能"],
            f"enter={row['进入人数']:.1f}",
            f"check_rate={row['进入打勾率']:.4f}",
            f"save_rate={row['进入保存率']:.4f}",
            sep="\t",
        )


if __name__ == "__main__":
    main()

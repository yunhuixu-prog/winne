#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
提取北斗看板图表 marks（标注/标记线）。

配置来源:
    token: 环境变量 OMNIBUS_ACCESS_TOKEN
    图表列表: 计算脚本/北斗mark提取/知识库地址.csv
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

SCRIPT_DIR = Path(__file__).resolve().parent
# scripts → 北斗标识提取skill → 北斗mark提取 → 计算脚本（skill_paths.py）
MARK_EXTRACT_DIR = SCRIPT_DIR.parents[1]
SCRIPTS_DIR = SCRIPT_DIR.parents[2]
sys.path.insert(0, str(SCRIPTS_DIR))
from skill_paths import kb_raw_dir

DEFAULT_CSV = MARK_EXTRACT_DIR / "知识库地址.csv"
DEFAULT_OUTPUT_DIR = kb_raw_dir("北斗标注")

GATEWAY_BASE = os.environ.get("MEITU_CONNECTORS_BASE_URL", "https://connectors.meitu-int.com").rstrip("/")

BEIDOU_GATEWAYS = {
    "default": "beidou.tatstm.com",
    "tatstm": "beidou.tatstm.com",
    "oci": "beidou-voyager.pix-int.com",
    "voyager": "beidou-voyager.pix-int.com",
    "pix": "beidou-voyager.pix-int.com",
}
DEFAULT_GATEWAY = BEIDOU_GATEWAYS["default"]
CHART_CONF_PATH = "/api/web-face-server/v2/charts/conf"


def build_session() -> requests.Session:
    session = requests.Session()
    retry = Retry(
        total=3,
        backoff_factor=0.5,
        status_forcelist=(502, 503, 504),
        allowed_methods=("POST",),
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session


SESSION = build_session()


def load_token() -> str:
    token = os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip()
    if token:
        return token
    raise RuntimeError("未读取到 OMNIBUS_ACCESS_TOKEN，请先配置环境变量")


def load_charts_from_csv(csv_path: Path) -> list[dict[str, str]]:
    if not csv_path.exists():
        raise FileNotFoundError(f"配置文件不存在: {csv_path}")

    charts: list[dict[str, str]] = []
    with csv_path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames:
            raise ValueError(f"{csv_path} 为空或缺少表头")

        fields = {name.strip(): name for name in reader.fieldnames if name}
        dashboard_key = fields.get("dashboardId") or fields.get("dashboard_id")
        chart_key = fields.get("chartId") or fields.get("chart_id")
        if not dashboard_key or not chart_key:
            raise ValueError(f"{csv_path} 需包含表头 dashboardId, chartId")

        name_key = fields.get("名称") or fields.get("name")
        gateway_key = (
            fields.get("网关")
            or fields.get("gateway")
            or fields.get("环境")
            or fields.get("env")
        )

        for row_no, row in enumerate(reader, start=2):
            dashboard_id = (row.get(dashboard_key) or "").strip()
            chart_id = (row.get(chart_key) or "").strip()
            if not dashboard_id and not chart_id:
                continue
            if not dashboard_id or not chart_id:
                raise ValueError(f"{csv_path} 第 {row_no} 行 dashboardId/chartId 不能为空")
            item = {"dashboardId": dashboard_id, "chartId": chart_id}
            if name_key:
                item["name"] = (row.get(name_key) or "").strip()
            raw_gateway = (row.get(gateway_key) or "").strip().lower() if gateway_key else ""
            item["gateway"] = resolve_gateway(raw_gateway)
            charts.append(item)

    if not charts:
        raise ValueError(f"{csv_path} 未读取到有效图表配置")
    return charts


def resolve_gateway(raw: str) -> str:
    if not raw:
        return DEFAULT_GATEWAY
    return BEIDOU_GATEWAYS.get(raw.lower(), raw)


def chart_conf_url(gateway_host: str) -> str:
    host = resolve_gateway(gateway_host)
    return f"{GATEWAY_BASE}/gateway/{host}{CHART_CONF_PATH}"


def call_chart_conf(dashboard_id: str, chart_id: str, token: str, gateway_host: str = DEFAULT_GATEWAY) -> dict:
    url = chart_conf_url(gateway_host)
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    payload = {
        "dashboardId": dashboard_id,
        "chartId": chart_id,
        "filters": None,
    }
    try:
        resp = SESSION.post(url, headers=headers, json=payload, timeout=30)
        if resp.status_code >= 400:
            return {"_error": f"HTTP {resp.status_code}: {resp.text}"}
        data = resp.json()
        if not isinstance(data, dict):
            return {"_error": f"返回格式异常: {data!r}"}
        code = data.get("code")
        if code not in (0, 200, "0", "200"):
            msg = data.get("message") or data.get("msg") or "未知错误"
            return {"_error": f"接口错误 code={code}: {msg}"}
        return data
    except requests.RequestException as e:
        return {"_error": f"RequestException: {e}"}


def extract_marks(response: dict, dashboard_id: str, chart_id: str, chart_name: str = "") -> list[dict]:
    if "_error" in response:
        item = {
            "dashboardId": dashboard_id,
            "chartId": chart_id,
            "error": response["_error"],
        }
        if chart_name:
            item["name"] = chart_name
        return [item]

    marks = response.get("content", {}).get("configuration", {}).get("marks", [])
    results: list[dict] = []
    for mark in marks:
        raw_key = mark.get("key", 0)
        ts_ms = 0
        if raw_key is not None:
            try:
                ts_ms = int(raw_key)
            except (ValueError, TypeError):
                ts_ms = 0
        if ts_ms:
            dt = datetime.fromtimestamp(ts_ms / 1000, tz=timezone.utc)
            date_str = dt.strftime("%Y%m%d")
        else:
            date_str = None
        item = {
            "dashboardId": dashboard_id,
            "chartId": chart_id,
            "date": date_str,
            "content": mark.get("content", ""),
            "userName": mark.get("userName", ""),
            "type": mark.get("type", ""),
            "id": mark.get("id", ""),
            "createTime": mark.get("createTime"),
            "updateTime": mark.get("updateTime"),
        }
        if chart_name:
            item["name"] = chart_name
        results.append(item)
    return results


def build_output(all_marks: list[dict]) -> dict:
    output: dict = {}
    for mark in all_marks:
        db_id = mark["dashboardId"]
        ch_id = mark["chartId"]
        output.setdefault(db_id, {}).setdefault(ch_id, []).append(mark)
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description="从知识库地址.csv 提取北斗 marks 标注数据")
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"图表配置 CSV，默认 {DEFAULT_CSV}",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"输出目录，默认 {DEFAULT_OUTPUT_DIR}",
    )
    args = parser.parse_args()

    token = load_token()
    charts = load_charts_from_csv(args.csv)
    args.output.mkdir(parents=True, exist_ok=True)

    all_marks: list[dict] = []
    for chart in charts:
        db_id = chart["dashboardId"]
        ch_id = chart["chartId"]
        chart_name = chart.get("name", "")
        gateway = chart.get("gateway", DEFAULT_GATEWAY)
        label = f"{chart_name} " if chart_name else ""
        print(f"提取 {label}dashboard={db_id}, chart={ch_id}, gateway={gateway} ...")
        resp = call_chart_conf(db_id, ch_id, token, gateway)
        all_marks.extend(extract_marks(resp, db_id, ch_id, chart_name))

    output = build_output(all_marks)
    output_path = args.output / "marks_merged.json"

    errors = [m for m in all_marks if m.get("error")]
    if errors:
        print(f"警告: {len(errors)} 个图表请求失败", file=sys.stderr)
        for item in errors:
            print(
                f"  - {item.get('name', '')} {item['dashboardId']}/{item['chartId']}: {item['error']}",
                file=sys.stderr,
            )
        sys.exit(1)

    output_path.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8")
    total = sum(len(v) for db in output.values() for v in db.values())
    print(f"已提取 {total} 条 marks 记录")
    print(f"包含 {len(output)} 个 dashboard，图表数: {sum(len(v) for v in output.values())}")
    print(f"保存到: {output_path}")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, FileNotFoundError, ValueError) as exc:
        print(f"错误: {exc}", file=sys.stderr)
        sys.exit(1)

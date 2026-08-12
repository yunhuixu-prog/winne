#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""AI 月报北斗取数。

输出：raw_data/{mau,bookings,valid_vip}.csv
聚合：MAU/新增续订/月有效会员数 → aggr=MONTH, aggrType=SUM
      订阅毛利（剔除退款）→ ≤2025 Chart 89046 MONTH+SUM；2026 Chart 89060 日粒度累积月末差分
"""
from __future__ import annotations

import calendar
import os
import sys
from datetime import date, timedelta
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import FETCH_MONTHS, memory_dir, raw_data_dir, skill_root

BASE_DIR = str(skill_root())
RAW_DATA_DIR = raw_data_dir()
MEMORY_DIR = memory_dir()

BEIDOU_TOOL_CANDIDATES = [
    str(
        Path(BASE_DIR).resolve().parents[3]
        / "参考文档"
        / "分析下钻报告实现过程"
        / ".agents"
        / "skills"
        / "beidou-dashboard-data"
        / "scripts"
    ),
    os.path.expanduser("~/.agents/skills/beidou-dashboard-data/scripts"),
]

COUNTRY_BATCH_SIZE = 30
_FILTER_OPTIONS_CACHE: dict[tuple[str, int, str, bool], list[str]] = {}

BOOKING_BASE_FILTERS = [
    {"name": "产品", "value": ["AirBrush"]},
    {"name": "平台", "value": ["整体"]},
    {"name": "内地/海外", "value": ["整体"]},
    {"name": "大洲", "value": ["整体"]},
    {"name": "订阅类型", "value": ["整体"]},
    {"name": "支付渠道", "value": ["整体"]},
]

PROFIT_SPLIT_BASE_FILTERS = [
    {"name": "平台", "value": ["整体"]},
    {"name": "大洲", "value": ["整体"]},
    {"name": "订阅类型", "value": ["整体"]},
    {"name": "支付渠道", "value": ["整体"]},
]

# 流动指标看板 10016073：国家/地区走 all_countries 全量枚举；地区固定整体
VALID_VIP_BASE_FILTERS = [
    {"name": "产品线", "value": ["AirBrush"]},
    {"name": "SKU类型", "value": ["整体"]},
    {"name": "地区", "value": ["整体"]},
]

METRICS: list[dict[str, Any]] = [
    {
        "name": "MAU",
        "output": "mau.csv",
        "env": "oci",
        "dashboard_id": 10015823,
        "queries": [
            {
                "label": "整体 MAU",
                "chart_id": 89215,
                # OCI 看板筛选项已由「国家」更名为「国家/地区」
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体", "iOS", "Android"]},
                    {"name": "渠道/自然", "value": ["整体", "Organic", "non-Organic"]},
                ],
                "default_dims": {"新老": "整体"},
            },
            {
                "label": "新用户 MAU",
                "chart_id": 89254,
                "metric": "MNU",
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体", "iOS", "Android"]},
                    {"name": "渠道/自然", "value": ["整体", "Organic", "non-Organic"]},
                ],
                "default_dims": {"新老": "New"},
            },
        ],
    },
    {
        "name": "Bookings",
        "output": "bookings.csv",
        "env": "oci",
        "queries": [
            {
                "label": "订阅毛利（≤2025）",
                "metric": "订阅毛利（剔除退款，$）",
                "dashboard_id": 10015810,
                "chart_id": 89046,
                "all_countries": "国家地区",
                "include_country_overall": True,
                "filters": BOOKING_BASE_FILTERS,
                "fetch_mode": "month_sum",
                "year_scope_max": 2025,
                "value_column": "每日毛利（剔除退款，$美元）",
            },
            {
                "label": "订阅毛利（2026）",
                "metric": "订阅毛利（剔除退款，$）",
                "dashboard_id": 10015810,
                "chart_id": 89060,
                "all_countries": "国家地区",
                "include_country_overall": True,
                "filters": BOOKING_BASE_FILTERS,
                "fetch_mode": "cumulative_monthly_diff",
                "year_scope": 2026,
                "usd_only": True,
            },
            {
                "label": "新增毛利",
                "metric": "新增毛利",
                "dashboard_id": 10015839,
                "chart_id": 89280,
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": PROFIT_SPLIT_BASE_FILTERS,
            },
            {
                "label": "续订毛利",
                "metric": "续订毛利",
                "dashboard_id": 10015839,
                "chart_id": 89281,
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": PROFIT_SPLIT_BASE_FILTERS,
            },
        ],
    },
    {
        "name": "月有效会员数",
        "output": "valid_vip.csv",
        "queries": [
            {
                "label": "月有效会员数",
                "metric": "月有效会员数",
                "env": "oci",
                "dashboard_id": 10015810,
                "chart_id": 89058,
                "all_countries": "国家地区",
                "include_country_overall": True,
                "filters": BOOKING_BASE_FILTERS,
            },
            # 10016073 图表按筛选项聚合且响应无国家字段；多国同批会相加（含整体时重复计算），必须逐国拉取
            {
                "label": "本月新增有效会员数",
                "metric": "本月新增有效会员数",
                "env": "oci",
                "dashboard_id": 10016073,
                "chart_id": 91006,
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "country_batch_size": 1,
                "filters": VALID_VIP_BASE_FILTERS,
                "default_dims": {"订阅类型": "整体"},
            },
            {
                "label": "本月流失会员数",
                "metric": "本月流失会员数",
                "env": "oci",
                "dashboard_id": 10016073,
                "chart_id": 91009,
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "country_batch_size": 1,
                "filters": VALID_VIP_BASE_FILTERS,
                "default_dims": {"订阅类型": "整体"},
            },
            {
                "label": "本月留存会员数",
                "metric": "本月留存会员数",
                "env": "oci",
                "dashboard_id": 10016073,
                "chart_id": 91010,
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "country_batch_size": 1,
                "filters": VALID_VIP_BASE_FILTERS,
                "default_dims": {"订阅类型": "整体"},
            },
        ],
    },
]

METRIC_VALUE_COLUMNS = {
    "订阅毛利（剔除退款，$）": "每日毛利（剔除退款，$美元）",
    "新增毛利": "新增付费毛利",
    "续订毛利": "续费毛利",
}

CUMULATIVE_USD_COLUMN = "年累计毛利（剔除退款，$美元）"

COUNTRY_COLUMN_ALIASES = [
    "国家",
    "国家地区",
    "国家/地区",
    "国家编码",
    "country_code",
    "国家名称",
    "geographic_subdivision_v2",
]

# 月报固定 MONTH + SUM；禁止误用周报口径 WEEK + AVG
MONTH_SUM_AGGR = {"aggr": "MONTH", "aggrType": "SUM"}


def resolve_beidou_tool_dir() -> str:
    for path in BEIDOU_TOOL_CANDIDATES:
        if os.path.isfile(os.path.join(path, "beidou_tool_api.py")):
            return path
    raise FileNotFoundError("未找到 beidou_tool_api.py，请确认已安装 beidou-dashboard-data skill")


def ensure_token() -> None:
    if os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip():
        return
    token_file = MEMORY_DIR / "token.txt"
    if token_file.is_file():
        content = token_file.read_text(encoding="utf-8").strip()
        token = content.split("=", 1)[1].strip() if content.startswith("token=") else content
        if token:
            os.environ["OMNIBUS_ACCESS_TOKEN"] = token
            return
    raise RuntimeError("未读取到 OMNIBUS_ACCESS_TOKEN，请先配置环境变量或在 memory/token.txt 写入 token")


def call_dashboard_data(params: dict[str, Any], env: str) -> dict[str, Any]:
    ensure_token()
    tool_dir = resolve_beidou_tool_dir()
    if tool_dir not in sys.path:
        sys.path.insert(0, tool_dir)
    from beidou_tool_api import BeidouToolClient, _build_dashboard_body, _resolve_base_url

    body = _build_dashboard_body(params)
    # 旧版 beidou_tool_api 可能未透传 aggrType；月报必须显式 SUM
    for key in ("aggrType", "aggr_type"):
        raw = params.get(key)
        if raw is not None and str(raw).strip():
            body["aggrType"] = str(raw).strip().upper()
            break

    client = BeidouToolClient(base_url=_resolve_base_url(env=env))
    response = client.dashboard_data(body=body)
    if isinstance(response, dict) and response.get("code") not in (0, 200, None):
        raise RuntimeError(f"北斗接口错误: {response.get('message')}")
    return {"request": body, "response": response}


def get_filter_options(env: str, dashboard_id: int, filter_name: str, include_overall: bool) -> list[str]:
    cache_key = (env, dashboard_id, filter_name, include_overall)
    if cache_key in _FILTER_OPTIONS_CACHE:
        return _FILTER_OPTIONS_CACHE[cache_key]

    result = call_dashboard_data({"dashboard_id": dashboard_id, "include_response": False}, env)
    linkage = result.get("response", {}).get("response", {}).get("linkageConfig", {})
    for item in linkage.get("filters", []):
        if item.get("name") == filter_name:
            options = item.get("options") or item.get("value") or []
            values = [str(x) for x in options if include_overall or str(x) != "整体"]
            _FILTER_OPTIONS_CACHE[cache_key] = values
            print(f"  已加载 {filter_name} options: {len(values)} 项 (dashboard={dashboard_id})")
            return values
    raise RuntimeError(f"dashboard {dashboard_id} 未找到筛选项 {filter_name}")


def month_end(d: date) -> date:
    return date(d.year, d.month, calendar.monthrange(d.year, d.month)[1])


def parse_yyyymmdd(value: str) -> date:
    return date(int(value[:4]), int(value[4:6]), int(value[6:8]))


def cumulative_daily_range(start: str, end: str) -> tuple[str, str]:
    """累积毛利日粒度取数：向前多取 1 个月，用于首月与跨月差分。"""
    start_d = parse_yyyymmdd(start)
    prev_month_end = start_d.replace(day=1) - timedelta(days=1)
    fetch_start = prev_month_end.replace(day=1)
    return fetch_start.strftime("%Y%m%d"), end


def target_month_periods(start: str, end: str) -> list[pd.Period]:
    start_d = parse_yyyymmdd(start)
    end_d = parse_yyyymmdd(end)
    periods: list[pd.Period] = []
    cursor = date(start_d.year, start_d.month, 1)
    while cursor <= end_d:
        periods.append(pd.Period(cursor, freq="M"))
        if cursor.month == 12:
            cursor = date(cursor.year + 1, 1, 1)
        else:
            cursor = date(cursor.year, cursor.month + 1, 1)
    return periods


def month_range(period: str | None = None, months: int = FETCH_MONTHS) -> tuple[str, str]:
    if period:
        year, month = int(period[:4]), int(period[4:6])
    else:
        today = date.today()
        year, month = today.year, today.month - 1
        if month == 0:
            year -= 1
            month = 12

    end_day = calendar.monthrange(year, month)[1]
    end = date(year, month, end_day)
    start_month_index = year * 12 + month - months
    start_year = start_month_index // 12
    start_month = start_month_index % 12 + 1
    start = date(start_year, start_month, 1)
    return start.strftime("%Y%m%d"), end.strftime("%Y%m%d")


def extract_charts(result: dict[str, Any]) -> list[dict[str, Any]]:
    response = result.get("response", {})
    inner = response.get("response", response) if isinstance(response, dict) else response
    if isinstance(inner, dict):
        if isinstance(inner.get("data"), list):
            return inner["data"]
        if isinstance(inner.get("response"), list):
            return inner["response"]
        return []
    return inner if isinstance(inner, list) else []


def resolve_filters(env: str, dashboard_id: int, query: dict[str, Any], countries: list[str] | None = None) -> list[dict[str, Any]]:
    filters = [dict(x) for x in query["filters"]]
    country_filter = query.get("all_countries")
    if country_filter:
        values = countries if countries is not None else get_filter_options(
            env, dashboard_id, country_filter, bool(query.get("include_country_overall"))
        )
        filters.append({"name": country_filter, "value": values})
    return filters


def country_filter_values(filters: list[dict[str, Any]]) -> list[str]:
    for name in ("国家", "国家/地区", "国家地区"):
        for item in filters:
            if item.get("name") == name:
                return [str(value) for value in item.get("value", [])]
    return []


def resolve_row_country(item: dict[str, Any], filter_countries: list[str]) -> str | None:
    if len(filter_countries) == 1:
        return filter_countries[0]
    # 必须先读「国家/地区」「国家地区」，避免误用「内地/海外=整体」覆盖真实国家
    for col in (
        "国家",
        "国家/地区",
        "国家地区",
        "国家名称",
        "country_code",
        "geographic_subdivision_v2",
    ):
        raw = item.get(col)
        if raw not in (None, ""):
            return str(raw)
    return None


def iter_filter_batches(env: str, dashboard_id: int, query: dict[str, Any]) -> list[list[dict[str, Any]]]:
    country_filter = query.get("all_countries")
    if not country_filter:
        return [resolve_filters(env, dashboard_id, query)]
    countries = get_filter_options(env, dashboard_id, country_filter, bool(query.get("include_country_overall")))
    batch_size = int(query.get("country_batch_size", COUNTRY_BATCH_SIZE))
    batches = []
    total_batches = (len(countries) + batch_size - 1) // batch_size
    for idx in range(0, len(countries), batch_size):
        chunk = countries[idx : idx + batch_size]
        print(f"  国家分批 {idx // batch_size + 1}/{total_batches}")
        batches.append(resolve_filters(env, dashboard_id, query, countries=chunk))
    return batches


def fetch_one_daily(
    env: str,
    dashboard_id: int,
    chart_id: int,
    filters: list[dict[str, Any]],
    start: str,
    end: str,
    query: dict[str, Any],
) -> list[dict[str, Any]]:
    params = {
        "dashboard_id": int(dashboard_id),
        "chart_id": [int(chart_id)],
        "filters": [{"name": "日期", "value": [start, end]}, *filters],
    }
    print(f"    [{query['label']}] {start} ~ {end} (日粒度，累积毛利)")
    result = call_dashboard_data(params, env)
    rows: list[dict[str, Any]] = []
    for chart in extract_charts(result):
        for row in chart.get("data", []):
            item = dict(row)
            item["_query"] = query["label"]
            if query.get("metric"):
                metric_name = query["metric"]
                item["_metric"] = metric_name
                value_col = query.get("value_column") or METRIC_VALUE_COLUMNS.get(metric_name)
                if value_col and value_col in item:
                    item["_value"] = item[value_col]
                elif query.get("usd_only"):
                    item["_value"] = item.get(CUMULATIVE_USD_COLUMN)
                else:
                    item["_value"] = coalesce_value(item, preferred=[metric_name])
            for dim, value in (query.get("default_dims") or {}).items():
                item[dim] = item.get(dim) or value
            rows.append(item)
    print(f"    [{query['label']}] 获取 {len(rows)} 行（日粒度）")
    return rows


def cumulative_rows_to_monthly(
    rows: list[dict[str, Any]],
    query: dict[str, Any],
    month_periods: list[pd.Period],
) -> list[dict[str, Any]]:
    if not rows:
        return []

    work = pd.DataFrame(rows)
    work["平台"] = coalesce_columns(work, ["平台", "os_type"])
    work["国家"] = coalesce_columns(work, COUNTRY_COLUMN_ALIASES)
    work["订阅类型"] = coalesce_columns(work, ["订阅类型", "period_type", "周期类型"])
    work["_value"] = pd.to_numeric(work["_value"], errors="coerce")
    work["day"] = pd.to_datetime(coalesce_columns(work, ["日期"]), errors="coerce")
    work = work.dropna(subset=["day", "_value"])
    work["month"] = work["day"].dt.to_period("M")

    dim_cols = ["平台", "国家", "订阅类型"]
    month_end_snapshots = (
        work.sort_values("day")
        .groupby(dim_cols + ["month"], as_index=False)
        .last()
    )

    monthly_rows: list[dict[str, Any]] = []
    for _, group in month_end_snapshots.groupby(dim_cols, sort=False):
        cum_by_month = {
            row["month"]: float(row["_value"])
            for _, row in group.iterrows()
            if pd.notna(row["_value"])
        }
        for period in month_periods:
            cum_end = cum_by_month.get(period)
            if cum_end is None:
                continue
            if period.month == 1:
                monthly_val = cum_end
            else:
                cum_prev = cum_by_month.get(period - 1)
                if cum_prev is None:
                    continue
                monthly_val = cum_end - cum_prev
            monthly_rows.append(
                {
                    "日期": period.to_timestamp(),
                    "平台": group.iloc[0]["平台"],
                    "国家": group.iloc[0]["国家"],
                    "订阅类型": group.iloc[0]["订阅类型"],
                    "_query": query["label"],
                    "_metric": query.get("metric"),
                    "_value": monthly_val,
                }
            )
    print(f"    [{query['label']}] 累积差分 → {len(monthly_rows)} 行（月度）")
    return monthly_rows


def periods_in_scope(
    start: str,
    end: str,
    year_scope: int | None = None,
    year_scope_max: int | None = None,
) -> list[pd.Period]:
    periods = target_month_periods(start, end)
    if year_scope is not None:
        periods = [period for period in periods if period.year == year_scope]
    if year_scope_max is not None:
        periods = [period for period in periods if period.year <= year_scope_max]
    return periods


def fetch_month_sum_scoped(
    env: str,
    query: dict[str, Any],
    start: str,
    end: str,
) -> list[dict[str, Any]]:
    month_periods = periods_in_scope(start, end, year_scope_max=query.get("year_scope_max"))
    if not month_periods:
        print(f"    [{query['label']}] 日期范围内无 ≤{query.get('year_scope_max')} 年月份，跳过")
        return []

    scope_start, scope_end = bounds_for_periods(month_periods)
    dashboard_id = int(query["dashboard_id"])
    chart_id = int(query["chart_id"])
    print(
        f"    [{query['label']}] chart={chart_id}, "
        f"月度 {month_periods[0]} ~ {month_periods[-1]} ({len(month_periods)} 月), MONTH+SUM"
    )
    rows: list[dict[str, Any]] = []
    for filters in iter_filter_batches(env, dashboard_id, query):
        rows.extend(fetch_one(env, dashboard_id, chart_id, filters, scope_start, scope_end, query))
    return rows


def bounds_for_periods(periods: list[pd.Period]) -> tuple[str, str]:
    if not periods:
        return "", ""
    first = periods[0]
    last = periods[-1]
    range_start = date(first.year, first.month, 1)
    range_end = month_end(date(last.year, last.month, 1))
    return range_start.strftime("%Y%m%d"), range_end.strftime("%Y%m%d")


def fetch_cumulative_monthly(
    env: str,
    query: dict[str, Any],
    start: str,
    end: str,
) -> list[dict[str, Any]]:
    year_scope = query.get("year_scope")
    month_periods = periods_in_scope(start, end, year_scope=year_scope)
    if not month_periods:
        print(f"    [{query['label']}] 日期范围内无 {year_scope or '全部'} 年月份，跳过")
        return []

    scope_start, scope_end = bounds_for_periods(month_periods)
    daily_start, daily_end = cumulative_daily_range(scope_start, scope_end)
    dashboard_id = int(query["dashboard_id"])
    chart_id = int(query["chart_id"])
    print(
        f"    [{query['label']}] chart={chart_id}, "
        f"月度 {month_periods[0]} ~ {month_periods[-1]} ({len(month_periods)} 月)"
    )
    rows: list[dict[str, Any]] = []
    for filters in iter_filter_batches(env, dashboard_id, query):
        daily_rows = fetch_one_daily(env, dashboard_id, chart_id, filters, daily_start, daily_end, query)
        rows.extend(cumulative_rows_to_monthly(daily_rows, query, month_periods))
    return rows


def fetch_one(env: str, dashboard_id: int, chart_id: int, filters: list[dict[str, Any]], start: str, end: str, query: dict[str, Any]) -> list[dict[str, Any]]:
    params = {
        "dashboard_id": int(dashboard_id),
        "chart_id": [int(chart_id)],
        "filters": [{"name": "日期", "value": [start, end]}, *filters],
        **MONTH_SUM_AGGR,
    }
    print(f"    [{query['label']}] {start} ~ {end} (aggr={MONTH_SUM_AGGR['aggr']}, aggrType={MONTH_SUM_AGGR['aggrType']})")
    result = call_dashboard_data(params, env)
    rows: list[dict[str, Any]] = []
    filter_countries = country_filter_values(filters)
    for chart in extract_charts(result):
        for row in chart.get("data", []):
            item = dict(row)
            item["_query"] = query["label"]
            item["_country"] = resolve_row_country(item, filter_countries)
            multi_metrics = query.get("multi_metrics") or {}
            if multi_metrics:
                for metric_name, value_col in multi_metrics.items():
                    metric_item = dict(item)
                    metric_item["_metric"] = metric_name
                    metric_item["_value"] = metric_item.get(value_col)
                    for dim, value in (query.get("default_dims") or {}).items():
                        metric_item[dim] = metric_item.get(dim) or value
                    rows.append(metric_item)
                continue
            if query.get("metric"):
                metric_name = query["metric"]
                item["_metric"] = metric_name
                value_col = query.get("value_column") or METRIC_VALUE_COLUMNS.get(metric_name)
                if value_col and value_col in item:
                    item["_value"] = item[value_col]
                else:
                    item["_value"] = coalesce_value(item, preferred=[metric_name])
            for dim, value in (query.get("default_dims") or {}).items():
                item[dim] = item.get(dim) or value
            rows.append(item)
    print(f"    [{query['label']}] 获取 {len(rows)} 行")
    return rows


def query_env(metric: dict[str, Any], query: dict[str, Any]) -> str:
    env = query.get("env") or metric.get("env")
    if not env:
        raise RuntimeError(f"query [{query.get('label')}] 未配置 env")
    return str(env)


def fetch_metric(metric: dict[str, Any], start: str, end: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for query in metric["queries"]:
        env = query_env(metric, query)
        fetch_mode = query.get("fetch_mode")
        if fetch_mode == "cumulative_monthly_diff":
            rows.extend(fetch_cumulative_monthly(env, query, start, end))
            continue
        if fetch_mode == "month_sum":
            rows.extend(fetch_month_sum_scoped(env, query, start, end))
            continue
        dashboard_id = int(query.get("dashboard_id", metric.get("dashboard_id")))
        chart_id = int(query.get("chart_id", metric.get("chart_id")))
        for filters in iter_filter_batches(env, dashboard_id, query):
            rows.extend(fetch_one(env, dashboard_id, chart_id, filters, start, end, query))
    return rows


def coalesce_value(row: dict[str, Any], preferred: list[str] | None = None) -> Any:
    candidates = (preferred or []) + [
        "MAU",
        "MNU",
        "月活跃用户数",
        "活跃用户数",
        "月有效会员数",
        "订阅毛利（剔除退款，$）",
        "每日毛利（剔除退款，$美元）",
        "年累计毛利（剔除退款，$美元）",
        "日均订阅毛利（剔除退款，$）",
        "新增毛利",
        "新增付费毛利",
        "续订毛利",
        "续费毛利",
        "value",
        "指标值",
    ]
    for col in candidates:
        if col in row and row[col] not in (None, ""):
            return row[col]
    return None


def normalize_date(work: pd.DataFrame) -> pd.Series:
    candidates = [
        "日期",
        "日期(按月)",
        "yyyymmdd(按日)",
        "yyyyMMdd(按日)",
        "yyyyMM(按日)",
        "date_p(按日)",
        "日期(按日)",
        "月份",
        "month",
    ]
    parts = [work[col] for col in candidates if col in work.columns]
    if not parts:
        return pd.Series(pd.NaT, index=work.index)
    result = parts[0]
    for part in parts[1:]:
        result = result.fillna(part)
    return pd.to_datetime(result, errors="coerce").dt.to_period("M").dt.to_timestamp()


def coalesce_columns(work: pd.DataFrame, columns: list[str]) -> pd.Series:
    parts = [work[col] for col in columns if col in work.columns]
    if not parts:
        return pd.Series([None] * len(work), index=work.index)
    result = parts[0]
    for part in parts[1:]:
        result = result.fillna(part)
    return result


def normalize_mau(rows: list[dict[str, Any]]) -> pd.DataFrame:
    work = pd.DataFrame(rows)
    work["日期"] = normalize_date(work)
    work["渠道自然"] = coalesce_columns(work, ["渠道自然", "渠道/自然"])
    work["国家"] = coalesce_columns(work, COUNTRY_COLUMN_ALIASES)
    work["平台"] = coalesce_columns(work, ["平台", "os_type"])
    work["新老"] = coalesce_columns(work, ["新老"])
    def _mau_value(row: dict[str, Any]) -> Any:
        value = row.get("_value")
        if value is not None and value != "" and not (isinstance(value, float) and pd.isna(value)):
            return value
        metric = row.get("_metric")
        preferred = [metric] if metric is not None and metric != "" and not (isinstance(metric, float) and pd.isna(metric)) else None
        return coalesce_value(row, preferred=preferred)

    work["MAU"] = [_mau_value(row) for row in work.to_dict("records")]
    work["MAU"] = pd.to_numeric(work["MAU"], errors="coerce")
    return work[["渠道自然", "国家", "日期", "平台", "新老", "MAU"]]


def normalize_bookings(rows: list[dict[str, Any]]) -> pd.DataFrame:
    work = pd.DataFrame(rows)
    work["日期"] = normalize_date(work)
    work["平台"] = coalesce_columns(work, ["平台", "os_type"])
    work["国家"] = coalesce_columns(work, COUNTRY_COLUMN_ALIASES)
    work["订阅类型"] = coalesce_columns(work, ["订阅类型", "period_type", "周期类型"])
    if "_metric" in work.columns and "_value" in work.columns:
        pivot = (
            work[["日期", "平台", "国家", "订阅类型", "_metric", "_value"]]
            .pivot_table(
                index=["日期", "平台", "国家", "订阅类型"],
                columns="_metric",
                values="_value",
                aggfunc="first",
            )
            .reset_index()
        )
        pivot.columns.name = None
        work = pivot
  # 月报为 MONTH+SUM，勿回落到「日均」列（周报 WEEK+AVG 口径）
    aliases = {
        "订阅毛利（剔除退款，$）": [
            "订阅毛利（剔除退款，$）",
            "年累计毛利（剔除退款，$美元）",
            "每日毛利（剔除退款，$美元）",
            "每月毛利（剔除退款，$）",
        ],
        "新增毛利": ["新增毛利", "新增付费毛利"],
        "续订毛利": ["续订毛利", "续费毛利"],
    }
    for target, sources in aliases.items():
        work[target] = pd.to_numeric(coalesce_columns(work, sources), errors="coerce")
    return work[["日期", "平台", "国家", "订阅类型", "订阅毛利（剔除退款，$）", "新增毛利", "续订毛利"]]


def normalize_valid_vip(rows: list[dict[str, Any]]) -> pd.DataFrame:
    work = pd.DataFrame(rows)
    work["日期"] = normalize_date(work)
    work["国家"] = coalesce_columns(work, ["_country", *COUNTRY_COLUMN_ALIASES, "内地/海外"])
    work["订阅类型"] = coalesce_columns(work, ["订阅类型", "period_type", "SKU", "SKU类型"])
    if "_metric" in work.columns and "_value" in work.columns:
        pivot = (
            work[["日期", "国家", "订阅类型", "_metric", "_value"]]
            .pivot_table(
                index=["日期", "国家", "订阅类型"],
                columns="_metric",
                values="_value",
                aggfunc="first",
            )
            .reset_index()
        )
        pivot.columns.name = None
        work = pivot
    aliases = {
        "月有效会员数": ["月有效会员数", "本月有效会员数"],
        "本月新增有效会员数": ["本月新增有效会员数"],
        "本月流失会员数": ["本月流失会员数", "本月流失会员数(求和)"],
        "本月留存会员数": ["本月留存会员数", "本月留存会员数(求和)"],
    }
    for target, sources in aliases.items():
        work[target] = pd.to_numeric(coalesce_columns(work, sources), errors="coerce")
    return work[
        [
            "日期",
            "国家",
            "订阅类型",
            "月有效会员数",
            "本月新增有效会员数",
            "本月流失会员数",
            "本月留存会员数",
        ]
    ]


def save_csv(rows: list[dict[str, Any]], filename: str) -> bool:
    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not rows:
        print(f"  无数据，跳过 {filename}")
        return False
    if filename == "mau.csv":
        df = normalize_mau(rows)
    elif filename == "bookings.csv":
        df = normalize_bookings(rows)
    elif filename == "valid_vip.csv":
        df = normalize_valid_vip(rows)
    else:
        df = pd.DataFrame(rows)
    output_path = RAW_DATA_DIR / filename
    df.to_csv(output_path, index=False, encoding="utf-8-sig")
    print(f"  已保存 {output_path} ({len(df)} 行)")
    return True


def parse_args() -> argparse.Namespace:
    import argparse

    parser = argparse.ArgumentParser(description="AI 月报北斗取数（MONTH + SUM）")
    parser.add_argument(
        "--only",
        choices=["mau", "bookings", "valid_vip"],
        action="append",
        help="仅拉取指定指标（可重复）；默认拉取全部",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    period = os.environ.get("AI_MONTHLY_PERIOD", "").strip() or None
    start, end = month_range(period)
    print("=" * 60)
    print("AI 月报北斗取数（MONTH SUM）")
    print("=" * 60)
    print(f"日期范围: {start} ~ {end}（近 {FETCH_MONTHS} 个完整月）")
    print(f"聚合口径: {MONTH_SUM_AGGR}")
    print(f"输出目录: {RAW_DATA_DIR}")

    output_to_metric = {m["output"].replace(".csv", ""): m for m in METRICS}
    if args.only:
        selected = []
        for name in args.only:
            key = "valid_vip" if name == "valid_vip" else name
            metric = output_to_metric.get(key)
            if metric is None:
                raise ValueError(f"未知指标: {name}")
            if metric not in selected:
                selected.append(metric)
        metrics_to_run = selected
        print(f"仅拉取: {', '.join(m['name'] for m in metrics_to_run)}")
    else:
        metrics_to_run = METRICS

    ok, fail = 0, 0
    for metric in metrics_to_run:
        print(f"\n{'-' * 60}")
        print(f"拉取 {metric['name']} → {metric['output']}")
        try:
            rows = fetch_metric(metric, start, end)
            if save_csv(rows, metric["output"]):
                ok += 1
            else:
                fail += 1
        except Exception as exc:
            fail += 1
            print(f"  [FAIL] {exc}")
            import traceback

            traceback.print_exc()

    print(f"\n完成：成功 {ok}，失败 {fail}")
    if fail:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

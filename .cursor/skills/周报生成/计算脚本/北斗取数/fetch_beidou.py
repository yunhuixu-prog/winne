# -*- coding: utf-8 -*-
"""
AI 周报北斗取数（严格对齐 biweekly-data-sop「看板与指标配置」）。

时间窗口：近 8 周（以最近完整自然周周一～周日为终点，向前推 8 周）

聚合：aggr=WEEK, aggrType=AVG
输出：../../raw_data/{dau,dnu,retention,new_retention,bookings,save}.csv
      bookings 含：日均订阅毛利（剔除退款，$）、新增毛利、续订毛利
      save 含：保存 UV（10015697/88125 一级功能；10015706/90628 图片编辑全部二级功能）

注意：SOP 中部分配置（新老用户拆分、全国家异常检测等）筛选项互斥，
      无法合并为单次请求，需分 query 拉取后合并到同一 CSV。
"""
from __future__ import annotations

import os
import sys
from datetime import date, timedelta
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import memory_dir, raw_data_dir, skill_root

BASE_DIR = str(skill_root())
RAW_DATA_DIR = str(raw_data_dir())
MEMORY_DIR = str(memory_dir())

BEIDOU_TOOL_CANDIDATES = [
    os.path.expanduser("~/.agents/skills/beidou-dashboard-data/scripts"),
    os.path.join(
        os.path.dirname(BASE_DIR),
        "参考文档",
        "分析下钻报告实现过程",
        ".agents",
        "skills",
        "beidou-dashboard-data",
        "scripts",
    ),
]

CORE_COUNTRIES_CN = ["美国", "英国", "巴西", "西班牙", "墨西哥", "加拿大", "澳大利亚"]

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

SAVE_BASE_FILTERS = [
    {"name": "平台", "value": ["整体"]},
    {"name": "国家/地区", "value": ["整体", "美国", "英国", "巴西"]},
    {"name": "新老", "value": ["整体"]},
    {"name": "渠道/自然", "value": ["整体"]},
    {"name": "付费状态", "value": ["整体"]},
    {"name": "版本", "value": ["整体"]},
    {"name": "一级功能", "value": ["整体", "图片编辑", "视频编辑"]},
]

SAVE_L2_BASE_FILTERS = [
    {"name": "平台", "value": ["整体"]},
    {"name": "国家/地区", "value": ["整体", "美国", "英国", "巴西"]},
    {"name": "新老", "value": ["整体"]},
    {"name": "渠道/自然", "value": ["整体"]},
    {"name": "付费状态", "value": ["整体"]},
    {"name": "版本", "value": ["整体"]},
    {"name": "一级功能", "value": ["图片编辑"]},
]

# 收入指标 → API 返回值列名
METRIC_VALUE_COLUMNS = {
    "日均订阅毛利（剔除退款，$）": "每日毛利（剔除退款，$美元）",
    "新增毛利": "新增付费毛利",
    "续订毛利": "续费毛利",
}

# 每个 output 对应多组 query，逐条对齐 SOP §2.1 / §2.2
# all_countries：OCI 看板「不传国家」只会返回「整体」，异常检测需显式传入全部国家 options
METRICS: list[dict[str, Any]] = [
    {
        "name": "DAU",
        "output": "dau.csv",
        "env": "oci",
        "dashboard_id": 10015816,
        "chart_id": 89122,
        "queries": [
            {
                "label": "全量维度",
                # OCI 看板筛选项已由「国家」更名为「国家/地区」（见 app/AB-OCI/说明/看板.csv）
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体", "iOS", "Android"]},
                    {"name": "新老", "value": ["整体", "New", "Old"]},
                    {"name": "渠道/自然", "value": ["整体"]},
                ],
            },
        ],
    },
    {
        "name": "DNU",
        "output": "dnu.csv",
        "env": "oci",
        "dashboard_id": 10015834,
        "chart_id": 89255,
        "queries": [
            {
                "label": "全量维度",
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体", "iOS", "Android"]},
                    {"name": "渠道/自然", "value": ["整体", "Organic", "non-Organic"]},
                ],
            },
        ],
    },
    {
        "name": "活跃次留",
        "output": "retention.csv",
        "env": "oci",
        "dashboard_id": 10015816,
        "chart_id": 90629,
        "queries": [
            {
                "label": "全量维度",
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体", "iOS", "Android"]},
                    {"name": "新老", "value": ["整体", "New", "Old"]},
                    {"name": "渠道/自然", "value": ["整体"]},
                ],
            },
        ],
    },
    {
        "name": "新增次留",
        "output": "new_retention.csv",
        "env": "oci",
        "dashboard_id": 10015834,
        "chart_id": 90267,
        "queries": [
            {
                "label": "全量维度",
                "all_countries": "国家/地区",
                "include_country_overall": True,
                "filters": [
                    {"name": "平台", "value": ["整体"]},
                    {"name": "渠道/自然", "value": ["整体", "Organic", "non-Organic"]},
                ],
            },
        ],
    },
    {
        "name": "收入",
        "output": "bookings.csv",
        "env": "oci",
        "queries": [
            {
                "label": "日均订阅毛利",
                "metric": "日均订阅毛利（剔除退款，$）",
                "dashboard_id": 10015810,
                "chart_id": 89046,
                "all_countries": "国家地区",
                "include_country_overall": True,
                "filters": BOOKING_BASE_FILTERS,
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
        "name": "保存量",
        "output": "save.csv",
        "env": "oci",
        "queries": [
            {
                "label": "周报维度",
                "dashboard_id": 10015697,
                "chart_id": 88125,
                "filters": SAVE_BASE_FILTERS,
                "default_dims": {"二级功能": "整体"},
            },
            {
                "label": "图片编辑二级功能",
                "dashboard_id": 10015706,
                "chart_id": 90628,
                "filters": SAVE_L2_BASE_FILTERS,
                "expand_filters": {
                    "二级功能": {"include_overall": True},
                },
                "default_dims": {
                    "一级功能": "图片编辑",
                    "渠道自然": "整体",
                    "付费状态": "整体",
                    "版本": "整体",
                },
            },
        ],
    },
]


_FILTER_OPTIONS_CACHE: dict[tuple[str, int, str, bool], list[str]] = {}
COUNTRY_BATCH_SIZE = 30


def get_filter_options(
    env: str,
    dashboard_id: int,
    filter_name: str,
    include_overall: bool = False,
) -> list[str]:
    cache_key = (env, dashboard_id, filter_name, include_overall)
    if cache_key in _FILTER_OPTIONS_CACHE:
        return _FILTER_OPTIONS_CACHE[cache_key]

    ensure_token()
    tool_dir = resolve_beidou_tool_dir()
    if tool_dir not in sys.path:
        sys.path.insert(0, tool_dir)
    from beidou_tool_api import call_api

    result = call_api(
        "dashboard_data",
        {"dashboard_id": dashboard_id, "include_response": False},
        env=env,
    )
    linkage = result.get("response", {}).get("response", {}).get("linkageConfig", {})
    for item in linkage.get("filters", []):
        if item.get("name") == filter_name:
            options = item.get("options") or item.get("value") or []
            opts = [str(x) for x in options if include_overall or str(x) != "整体"]
            _FILTER_OPTIONS_CACHE[cache_key] = opts
            print(f"  已加载 {filter_name} options: {len(opts)} 项 (dashboard={dashboard_id})")
            return opts
    raise RuntimeError(f"dashboard {dashboard_id} 未找到筛选项 {filter_name}")


def resolve_query_filters(
    env: str,
    dashboard_id: int,
    query: dict[str, Any],
    country_values: list[str] | None = None,
    expanded_filter_values: dict[str, list[str]] | None = None,
) -> list[dict[str, Any]]:
    did = query.get("dashboard_id", dashboard_id)
    filters = [dict(x) for x in query["filters"]]
    country_filter = query.get("all_countries")
    if country_filter:
        values = country_values if country_values is not None else get_filter_options(
            env,
            did,
            country_filter,
            include_overall=bool(query.get("include_country_overall")),
        )
        filters.append({"name": country_filter, "value": values})
    for filter_name, cfg in query.get("expand_filters", {}).items():
        include_overall = bool(cfg.get("include_overall"))
        if expanded_filter_values and filter_name in expanded_filter_values:
            values = expanded_filter_values[filter_name]
        else:
            values = get_filter_options(env, did, filter_name, include_overall=include_overall)
        filters.append({"name": filter_name, "value": values})
    return filters


def iter_query_filter_batches(
    env: str,
    dashboard_id: int,
    query: dict[str, Any],
    batch_size: int = COUNTRY_BATCH_SIZE,
) -> list[list[dict[str, Any]]]:
    country_filter = query.get("all_countries")
    if not country_filter:
        return [resolve_query_filters(env, dashboard_id, query)]

    did = query.get("dashboard_id", dashboard_id)
    countries = get_filter_options(
        env,
        did,
        country_filter,
        include_overall=bool(query.get("include_country_overall")),
    )
    batches: list[list[dict[str, Any]]] = []
    total = (len(countries) + batch_size - 1) // batch_size
    for idx in range(0, len(countries), batch_size):
        chunk = countries[idx : idx + batch_size]
        batch_no = idx // batch_size + 1
        print(f"  国家分批 {batch_no}/{total}（{len(chunk)} 国）")
        batches.append(resolve_query_filters(env, dashboard_id, query, country_values=chunk))
    return batches


def resolve_beidou_tool_dir() -> str:
    for path in BEIDOU_TOOL_CANDIDATES:
        if os.path.isfile(os.path.join(path, "beidou_tool_api.py")):
            return path
    raise FileNotFoundError(
        "未找到 beidou_tool_api.py，请确认已安装 beidou-dashboard-data skill"
    )


def ensure_token() -> None:
    token = os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip()
    if token:
        return
    token_file = os.path.join(MEMORY_DIR, "token.txt")
    if os.path.isfile(token_file):
        with open(token_file, "r", encoding="utf-8") as f:
            content = f.read().strip()
        token = content.split("=", 1)[1].strip() if content.startswith("token=") else content
        if token:
            os.environ["OMNIBUS_ACCESS_TOKEN"] = token
            return
    raise RuntimeError(
        "未读取到 OMNIBUS_ACCESS_TOKEN，请先配置环境变量或在 memory/token.txt 写入 token"
    )


def last_complete_week_sunday(ref: date | None = None) -> date:
    today = ref or date.today()
    days_back = (today.weekday() + 1) % 7
    if days_back == 0:
        days_back = 7
    return today - timedelta(days=days_back)


def week_monday(sunday: date) -> date:
    return sunday - timedelta(days=6)


def fmt_ymd(d: date) -> str:
    return d.strftime("%Y%m%d")


def build_date_windows(ref: date | None = None) -> dict[str, tuple[str, str]]:
    end_sunday = last_complete_week_sunday(ref)
    recent_8w_start = week_monday(end_sunday - timedelta(weeks=8) + timedelta(days=7))
    return {
        "recent_8w": (fmt_ymd(recent_8w_start), fmt_ymd(end_sunday)),
    }


def extract_charts(result: dict[str, Any]) -> list[dict[str, Any]]:
    response = result.get("response", {})
    if not isinstance(response, dict):
        return []
    inner = response.get("response", response)
    if isinstance(inner, dict):
        if isinstance(inner.get("data"), list):
            return inner["data"]
        if isinstance(inner.get("response"), list):
            return inner["response"]
        return []
    if isinstance(inner, list):
        return inner
    return []


def fetch_one_window(
    env: str,
    dashboard_id: int,
    chart_id: int,
    filters: list[dict[str, Any]],
    start: str,
    end: str,
    window_label: str,
    query_label: str,
    metric_name: str | None = None,
) -> list[dict[str, Any]]:
    ensure_token()
    tool_dir = resolve_beidou_tool_dir()
    if tool_dir not in sys.path:
        sys.path.insert(0, tool_dir)
    from beidou_tool_api import call_api

    all_filters = [{"name": "日期", "value": [start, end]}]
    all_filters.extend(filters)
    params = {
        "dashboard_id": int(dashboard_id),
        "chart_id": [int(chart_id)],
        "filters": all_filters,
        "aggr": "WEEK",
        "aggrType": "AVG",
    }

    print(f"    [{window_label}|{query_label}] {start} ~ {end}")
    result = call_api("dashboard_data", params=params, env=env)
    response = result.get("response", {})
    if isinstance(response, dict) and response.get("code") not in (0, 200, None):
        raise RuntimeError(f"北斗接口错误: {response.get('message')}")

    charts = extract_charts(result)
    rows: list[dict[str, Any]] = []
    for chart in charts:
        for row in chart.get("data", []):
            item = dict(row)
            item["_window"] = window_label
            item["_query"] = query_label
            if metric_name:
                item["_metric"] = metric_name
                value_col = METRIC_VALUE_COLUMNS.get(metric_name)
                if value_col and value_col in item:
                    item["_value"] = item[value_col]
            rows.append(item)
    print(f"    [{window_label}|{query_label}] 获取 {len(rows)} 行")
    return rows


def fetch_metric(metric: dict[str, Any], windows: dict[str, tuple[str, str]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    default_did = metric.get("dashboard_id")
    default_cid = metric.get("chart_id")
    for query in metric["queries"]:
        did = query.get("dashboard_id", default_did)
        cid = query.get("chart_id", default_cid)
        if did is None or cid is None:
            raise ValueError(f"query「{query['label']}」缺少 dashboard_id 或 chart_id")
        filter_batches = iter_query_filter_batches(metric["env"], did, query)
        metric_name = query.get("metric")
        for label, (start, end) in windows.items():
            for resolved_filters in filter_batches:
                batch_rows = fetch_one_window(
                    env=metric["env"],
                    dashboard_id=did,
                    chart_id=cid,
                    filters=resolved_filters,
                    start=start,
                    end=end,
                    window_label=label,
                    query_label=query["label"],
                    metric_name=metric_name,
                )
                for row in batch_rows:
                    for dim, value in (query.get("default_dims") or {}).items():
                        if dim not in row or row[dim] in (None, ""):
                            row[dim] = value
                rows.extend(batch_rows)
    return rows


BOOKINGS_DATE_COLS = ["日期", "yyyymmdd(按日)", "日期(按日)"]
BOOKINGS_DIM_SOURCE_MAP = {
    "平台": ["os_type", "平台"],
    "国家": ["country_code", "国家编码", "国家地区", "国家/地区"],
    "订阅类型": ["period_type", "周期类型"],
}
BOOKINGS_DIM_COLS = ["日期", "平台", "国家", "订阅类型", "_window"]
BOOKINGS_METRIC_COLS = [
    "日均订阅毛利（剔除退款，$）",
    "新增毛利",
    "续订毛利",
]

# 看板维度列可能叫「国家」或「国家/地区」，统一落到「国家」供 s1～s5 使用
COUNTRY_SOURCE_COLS = ["国家", "国家/地区", "国家地区", "country_code", "国家编码"]


def ensure_country_column(work: pd.DataFrame) -> pd.DataFrame:
    work = work.copy()
    work["国家"] = _coalesce_columns(work, COUNTRY_SOURCE_COLS)
    return work


def _coalesce_columns(df: pd.DataFrame, columns: list[str]) -> pd.Series:
    parts: list[pd.Series] = []
    for col in columns:
        if col in df.columns:
            parts.append(df[col])
    if not parts:
        return pd.Series([None] * len(df), index=df.index)
    result = parts[0]
    for part in parts[1:]:
        result = result.fillna(part)
    return result


def normalize_bookings_df(df: pd.DataFrame) -> pd.DataFrame:
    """统一为 平台/国家/订阅类型 三维度，合并三个收入指标为宽表。"""
    work = df.copy()

    date_parts = [work[col] for col in BOOKINGS_DATE_COLS if col in work.columns]
    if date_parts:
        date_series = date_parts[0]
        for part in date_parts[1:]:
            date_series = date_series.fillna(part)
        work["日期"] = pd.to_datetime(date_series, errors="coerce").dt.normalize()
    else:
        work["日期"] = pd.NaT

    for target, sources in BOOKINGS_DIM_SOURCE_MAP.items():
        work[target] = _coalesce_columns(work, [target, *sources])

    if "_metric" in work.columns and "_value" in work.columns:
        pivot_src = work[BOOKINGS_DIM_COLS + ["_metric", "_value"]].copy()
        work = (
            pivot_src.pivot_table(
                index=BOOKINGS_DIM_COLS,
                columns="_metric",
                values="_value",
                aggfunc="first",
            )
            .reset_index()
        )
        work.columns.name = None

    for col in BOOKINGS_METRIC_COLS:
        if col not in work.columns:
            work[col] = None

    return work[BOOKINGS_DIM_COLS + BOOKINGS_METRIC_COLS]


RETENTION_DIM_COLS = ["渠道自然", "国家", "日期", "平台", "新老", "_window", "_query"]
RETENTION_METRIC_COLS = ["活跃用户数", "次日留存人数"]
RETENTION_DATE_COLS = ["日期", "yyyymmdd(按日)", "yyyyMMdd(按日)", "日期(按日)"]


def normalize_retention_df(df: pd.DataFrame) -> pd.DataFrame:
    """保留活跃用户数、次日留存人数，统一日期列。"""
    work = ensure_country_column(df)

    date_parts = [work[col] for col in RETENTION_DATE_COLS if col in work.columns]
    if date_parts:
        date_series = date_parts[0]
        for part in date_parts[1:]:
            date_series = date_series.fillna(part)
        work["日期"] = pd.to_datetime(date_series, errors="coerce").dt.normalize()
    else:
        work["日期"] = pd.NaT

    for col in RETENTION_METRIC_COLS:
        if col in work.columns:
            work[col] = pd.to_numeric(work[col], errors="coerce")

    for col in RETENTION_DIM_COLS + RETENTION_METRIC_COLS:
        if col not in work.columns:
            work[col] = None

    return work[RETENTION_DIM_COLS + RETENTION_METRIC_COLS]


NEW_RETENTION_DIM_COLS = ["渠道自然", "国家", "日期", "平台", "_window", "_query"]
NEW_RETENTION_METRIC_COLS = ["DNU", "新增次日留存人数"]


def normalize_new_retention_df(df: pd.DataFrame) -> pd.DataFrame:
    """保留 DNU、新增次日留存人数，统一日期列。"""
    work = ensure_country_column(df)

    date_parts = [work[col] for col in RETENTION_DATE_COLS if col in work.columns]
    if date_parts:
        date_series = date_parts[0]
        for part in date_parts[1:]:
            date_series = date_series.fillna(part)
        work["日期"] = pd.to_datetime(date_series, errors="coerce").dt.normalize()
    else:
        work["日期"] = pd.NaT

    for col in NEW_RETENTION_METRIC_COLS:
        if col in work.columns:
            work[col] = pd.to_numeric(work[col], errors="coerce")

    for col in NEW_RETENTION_DIM_COLS + NEW_RETENTION_METRIC_COLS:
        if col not in work.columns:
            work[col] = None

    return work[NEW_RETENTION_DIM_COLS + NEW_RETENTION_METRIC_COLS]


SAVE_DIM_COLS = [
    "渠道自然",
    "国家",
    "日期",
    "平台",
    "新老",
    "付费状态",
    "版本",
    "一级功能",
    "二级功能",
    "_window",
    "_query",
]
SAVE_METRIC_COLS = ["保存 UV"]
SAVE_DIM_RENAME = {
    "是否渠道": "渠道自然",
    "是否新的用户,0:否，1:是": "新老",
    '"是否新的用户,0:否，1:是"': "新老",
    "主功能名称,相机,视频美容,视频剪辑,美容,美化,拼图": "一级功能",
    '"主功能名称,相机,视频美容,视频剪辑,美容,美化,拼图"': "一级功能",
    "是否会员": "付费状态",
    "付费/免费": "付费状态",
    "操作系统类型": "平台",
    "应用名称版本号": "版本",
}
SAVE_DIM_DEFAULTS = {
    "渠道自然": "整体",
    "付费状态": "整体",
    "版本": "整体",
    "二级功能": "整体",
}


def normalize_save_df(df: pd.DataFrame) -> pd.DataFrame:
    """统一保存量维度列名，对齐看板筛选项口径。"""
    work = ensure_country_column(df)
    if "保存uv" in work.columns:
        if "保存 UV" in work.columns:
            work["保存 UV"] = work["保存 UV"].fillna(work["保存uv"])
            work = work.drop(columns=["保存uv"])
        else:
            work = work.rename(columns={"保存uv": "保存 UV"})
    for src, dst in SAVE_DIM_RENAME.items():
        if src not in work.columns:
            continue
        if dst in work.columns:
            work[dst] = _coalesce_columns(work, [dst, src])
            work = work.drop(columns=[src])
        else:
            work = work.rename(columns={src: dst})

    date_parts = [work[col] for col in RETENTION_DATE_COLS if col in work.columns]
    if date_parts:
        for col in RETENTION_DATE_COLS:
            if col in work.columns:
                work[col] = work[col].replace(r"^\s*$", pd.NA, regex=True)
        date_series = date_parts[0]
        for part in date_parts[1:]:
            date_series = date_series.fillna(part)
        work["日期"] = pd.to_datetime(date_series, errors="coerce").dt.normalize()
    else:
        work["日期"] = pd.NaT

    for col in SAVE_METRIC_COLS:
        if col in work.columns:
            work[col] = pd.to_numeric(work[col], errors="coerce")

    for col, default in SAVE_DIM_DEFAULTS.items():
        if col not in work.columns:
            work[col] = default
        else:
            work[col] = work[col].fillna(default)
            blank = work[col].astype(str).str.strip().isin(["", "nan", "None"])
            work.loc[blank, col] = default

    for col in SAVE_DIM_COLS + SAVE_METRIC_COLS:
        if col not in work.columns:
            work[col] = None

    return work[SAVE_DIM_COLS + SAVE_METRIC_COLS]


def save_csv(rows: list[dict[str, Any]], filename: str) -> bool:
    os.makedirs(RAW_DATA_DIR, exist_ok=True)
    output_path = os.path.join(RAW_DATA_DIR, filename)
    if not rows:
        print(f"  无数据，跳过 {filename}")
        return False
    df = pd.DataFrame(rows)
    if filename in ("dau.csv", "dnu.csv"):
        df = ensure_country_column(df)
    if filename == "bookings.csv":
        before = len(df)
        df = normalize_bookings_df(df)
        print(f"  收入维度合并: {before} 行 → {len(df)} 行")
    elif filename == "retention.csv":
        before = len(df)
        df = normalize_retention_df(df)
        print(f"  留存列整理: {before} 行 → {len(df)} 行")
    elif filename == "new_retention.csv":
        before = len(df)
        df = normalize_new_retention_df(df)
        print(f"  新增留存列整理: {before} 行 → {len(df)} 行")
    elif filename == "save.csv":
        before = len(df)
        df = normalize_save_df(df)
        print(f"  保存量列整理: {before} 行 → {len(df)} 行")
    df.to_csv(output_path, index=False, encoding="utf-8-sig")
    print(f"  已保存 {output_path} ({len(df)} 行)")
    return True


def main() -> None:
    windows = build_date_windows()
    recent_start, recent_end = windows["recent_8w"]

    print("=" * 60)
    print("AI 周报北斗取数（WEEK AVG）")
    print("=" * 60)
    print(f"最近完整周终点: {recent_end}")
    print(f"近 8 周: {recent_start} ~ {recent_end}")
    print(f"输出目录: {RAW_DATA_DIR}")

    ok, fail = 0, 0
    for metric in METRICS:
        print(f"\n{'-' * 60}")
        print(f"拉取 {metric['name']} → {metric['output']}")
        if metric.get("dashboard_id"):
            print(
                f"  dashboard={metric['dashboard_id']}, chart={metric.get('chart_id')}, "
                f"env={metric['env']}, queries={len(metric['queries'])}"
            )
        else:
            print(f"  env={metric['env']}, queries={len(metric['queries'])}")
        for q in metric["queries"]:
            extra = ""
            if q.get("metric"):
                extra = f" [{q['metric']}]"
            if q.get("dashboard_id"):
                extra += f" (dashboard={q['dashboard_id']}, chart={q['chart_id']})"
            print(f"    - {q['label']}{extra}")
        try:
            rows = fetch_metric(metric, windows)
            if save_csv(rows, metric["output"]):
                ok += 1
            else:
                fail += 1
        except Exception as exc:
            fail += 1
            print(f"  [FAIL] {exc}")
            import traceback

            traceback.print_exc()

    print(f"\n{'=' * 60}")
    print(f"完成：成功 {ok}，失败 {fail}")
    print("=" * 60)


if __name__ == "__main__":
    main()

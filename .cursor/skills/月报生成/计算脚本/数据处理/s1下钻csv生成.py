#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 月报下钻 CSV（MAU / Bookings / 月有效会员数）。

按 memory/{MAU,Bookings,月有效会员数}指标库.csv 驱动：
  - raw_data 行：按「取数口径」筛选后按月聚合
  - 本表行：按指标库公式（如 1.x - 1.x.1）在已生成行上计算
  - x（非整体）维度：按源数据国家列表展开
  - MAU 新用户下钻：1.x.1.1（non-Organic）/ 1.x.1.2（Organic）按渠道自然筛选
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import FETCH_MONTHS

BASE_DIR = Path(__file__).resolve().parents[2]
MEMORY_DIR = BASE_DIR / "memory"
RAW_DATA_DIR = BASE_DIR / "raw_data"

MONTH_COLUMNS = ["本月", "上月"] + [f"{i}月前" for i in range(2, FETCH_MONTHS)]

METRIC_CONFIGS: dict[str, dict[str, Any]] = {
    "mau": {
        "name": "MAU",
        "template_file": MEMORY_DIR / "MAU指标库.csv",
        "data_file": RAW_DATA_DIR / "mau.csv",
        "required_cols": {"渠道自然", "国家", "日期", "平台", "新老", "MAU"},
    },
    "bookings": {
        "name": "Bookings",
        "template_file": MEMORY_DIR / "Bookings指标库.csv",
        "data_file": RAW_DATA_DIR / "bookings.csv",
        "required_cols": {"日期", "平台", "国家", "订阅类型"},
        "value_columns": ["订阅毛利（剔除退款，$）", "新增毛利", "续订毛利"],
    },
    "valid_vip": {
        "name": "月有效会员数",
        "template_file": MEMORY_DIR / "月有效会员数指标库.csv",
        "data_file": RAW_DATA_DIR / "valid_vip.csv",
        "required_cols": {
            "日期",
            "国家",
            "订阅类型",
            "月有效会员数",
            "本月新增有效会员数",
            "本月流失会员数",
            "本月留存会员数",
        },
        # 指标库「指标对应值」→ raw_data 实际列名
        "value_column_aliases": {
            "本月新增订阅会员数": "本月新增有效会员数",
            "月流失订阅会员数": "本月流失会员数",
        },
    },
}

LAG_PREFIX = "lag:"


def resolve_output_dir() -> Path:
    env = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output" / "_staging"


def parse_dimension(rule_text: str) -> dict[str, str]:
    dims: dict[str, str] = {}
    for part in str(rule_text).split("，"):
        part = part.strip()
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        dims[key.strip()] = value.strip()
    return dims


def sort_level_key(level: str) -> tuple[Any, ...]:
    tokens: list[tuple[int, Any]] = []
    for part in str(level).split("."):
        tokens.append((0, int(part)) if part.isdigit() else (1, part))
    return tuple(tokens)


def load_template(path: Path) -> pd.DataFrame:
    try:
        df = pd.read_csv(path, encoding="utf-8-sig", dtype=str).fillna("")
    except UnicodeDecodeError:
        df = pd.read_csv(path, encoding="gbk", dtype=str).fillna("")
    if "指标" not in df.columns and "指标1" in df.columns:
        df["指标"] = df["指标1"]
    return df


def load_source(config: dict[str, Any]) -> pd.DataFrame:
    df = pd.read_csv(config["data_file"], encoding="utf-8-sig")
    missing = config["required_cols"] - set(df.columns)
    if missing:
        raise ValueError(f"{config['data_file']} 缺少必要字段: {sorted(missing)}")
    df = df.copy()
    df["__日期__"] = pd.to_datetime(df["日期"], errors="coerce").dt.to_period("M").dt.to_timestamp()
    return df[df["__日期__"].notna()]


def month_sequence(df: pd.DataFrame) -> list[pd.Timestamp]:
    dates = sorted(pd.Timestamp(x) for x in df["__日期__"].dropna().unique())
    period = os.environ.get("AI_MONTHLY_PERIOD", "").strip()
    if period:
        target = pd.Timestamp(f"{period[:4]}-{period[4:6]}-01")
        dates = [d for d in dates if d <= target]
    return dates[-FETCH_MONTHS:]


def is_expand_value(value: str) -> bool:
    text = str(value)
    return "x" in text and "非整体" in text


def get_expand_dimension(filters: dict[str, str]) -> str | None:
    for dim, value in filters.items():
        if is_expand_value(value):
            return dim
    return None


def expand_countries(source: pd.DataFrame, dim: str) -> list[str]:
    if dim != "国家":
        return []
    return sorted(c for c in source["国家"].dropna().astype(str).unique() if c != "整体")


def apply_filters(
    df: pd.DataFrame,
    filters: dict[str, str],
    expand_dim: str | None = None,
    expand_value: str | None = None,
) -> pd.DataFrame:
    result = df
    for dim, value in filters.items():
        if dim not in result.columns:
            continue
        if is_expand_value(value):
            if expand_dim == dim and expand_value is not None:
                result = result[result[dim].astype(str) == expand_value]
            continue
        result = result[result[dim].astype(str) == value]
    return result


def parse_value_column(config: dict[str, Any], value_col: str) -> tuple[str, int]:
    """返回 (raw_data 列名, 滞后月数)。指标库可用 lag:列名 表示取上月同期值。"""
    text = str(value_col).strip()
    if text.startswith(LAG_PREFIX):
        actual = text[len(LAG_PREFIX):]
    else:
        actual = text
    aliases = config.get("value_column_aliases") or {}
    actual = str(aliases.get(actual, actual))
    lag_months = 1 if text.startswith(LAG_PREFIX) else 0
    return actual, lag_months


def metric_value(
    df: pd.DataFrame,
    month: pd.Timestamp,
    value_col: str,
    filters: dict[str, str],
    expand_dim: str | None = None,
    expand_value: str | None = None,
) -> float | None:
    rows = apply_filters(df, filters, expand_dim=expand_dim, expand_value=expand_value)
    rows = rows[rows["__日期__"] == month]
    if rows.empty or value_col not in rows.columns:
        return None
    values = pd.to_numeric(rows[value_col], errors="coerce")
    if values.notna().sum() == 0:
        return None
    return float(values.sum())


def replace_expand_placeholder(text: str, value: str) -> str:
    return (
        str(text)
        .replace("x（某 国家 值）", value)
        .replace("x（非整体）", value)
        .replace("x", value)
    )


def expand_level(level: str, country: str) -> str:
    return replace_expand_placeholder(level, country)


def is_self_table_row(row: pd.Series) -> bool:
    return str(row.get("数据来源", "")).strip() == "本表"


def parse_subtraction_levels(expr: str) -> tuple[str, str] | None:
    match = re.search(r"（(.+?)-(.+?)）", str(expr))
    if not match:
        return None
    return match.group(1).strip(), match.group(2).strip()


def calc_change(cur: float | None, prev: float | None) -> tuple[float | None, float | None]:
    if cur is None or prev is None:
        return None, None
    delta = cur - prev
    if prev == 0:
        return delta, None
    return delta, delta / prev * 100


def monthly_values(
    source: pd.DataFrame,
    value_col: str,
    months: list[pd.Timestamp],
    filters: dict[str, str],
    expand_dim: str | None = None,
    expand_value: str | None = None,
    lag_months: int = 0,
) -> list[float | None]:
    latest_first = list(reversed(months))
    values: list[float | None] = []
    for idx, month in enumerate(latest_first):
        if lag_months > 0:
            lag_idx = idx + lag_months
            if lag_idx >= len(latest_first):
                values.append(None)
                continue
            month = latest_first[lag_idx]
        values.append(
            metric_value(
                source, month, value_col, filters,
                expand_dim=expand_dim, expand_value=expand_value,
            )
        )
    return values


def build_output_row(
    level: str,
    metric: str,
    data_source: str,
    value_col: str,
    rule: str,
    values: list[float | None],
) -> dict[str, Any]:
    cur, prev = values[0], values[1] if len(values) > 1 else None
    mom, mom_pct = calc_change(cur, prev)
    out: dict[str, Any] = {
        "层级": level,
        "指标": metric,
        "数据来源": data_source,
        "指标对应值": value_col,
        "取数口径": rule,
    }
    for idx, col in enumerate(MONTH_COLUMNS):
        out[col] = values[idx] if idx < len(values) else pd.NA
    out["mom"] = mom
    out["mom%"] = mom_pct
    return out


def build_self_table_subtract_row(
    template_row: pd.Series,
    country: str,
    values_by_level: dict[str, dict[str, Any]],
) -> dict[str, Any] | None:
    levels = parse_subtraction_levels(template_row.get("指标对应值", ""))
    if not levels:
        return None

    parent_level = expand_level(levels[0], country)
    child_level = expand_level(levels[1], country)
    parent = values_by_level.get(parent_level)
    child = values_by_level.get(child_level)
    if not parent or not child:
        return None

    month_values: list[float | None] = []
    for col in MONTH_COLUMNS:
        parent_val = parent.get(col)
        child_val = child.get(col)
        if pd.isna(parent_val) or pd.isna(child_val):
            month_values.append(None)
        else:
            month_values.append(float(parent_val) - float(child_val))

    return build_output_row(
        expand_level(str(template_row["层级"]), country),
        str(template_row["指标"]),
        str(template_row.get("数据来源", "")),
        str(template_row.get("指标对应值", "")),
        str(template_row.get("取数口径", "")),
        month_values,
    )


def build_metric(config: dict[str, Any]) -> pd.DataFrame:
    template = load_template(config["template_file"])
    source = load_source(config)
    months = month_sequence(source)
    if len(months) < 2:
        raise ValueError(f"{config['name']} 可用月份不足 2 个，无法计算环比")

    rows: list[dict[str, Any]] = []
    values_by_level: dict[str, dict[str, Any]] = {}
    self_table_rows: list[pd.Series] = []

    print(f"\n=== {config['name']} 下钻 ===")
    print(f"  模板: {config['template_file'].name}")
    print(f"  源数据: {config['data_file'].name}，可用月份 {len(months)} 个")

    for _, template_row in template.iterrows():
        if is_self_table_row(template_row):
            self_table_rows.append(template_row)
            continue

        level = str(template_row["层级"])
        metric = str(template_row["指标"])
        data_source = str(template_row.get("数据来源", "")).strip()
        raw_value_col = str(template_row.get("指标对应值", "")).strip()
        value_col, lag_months = parse_value_column(config, raw_value_col)
        rule = str(template_row.get("取数口径", "")).strip()
        filters = parse_dimension(rule)
        expand_dim = get_expand_dimension(filters)

        if expand_dim:
            for expand_value in expand_countries(source, expand_dim):
                values = monthly_values(
                    source,
                    value_col,
                    months,
                    filters,
                    expand_dim=expand_dim,
                    expand_value=expand_value,
                    lag_months=lag_months,
                )
                out = build_output_row(
                    expand_level(level, expand_value),
                    replace_expand_placeholder(metric, expand_value),
                    data_source,
                    raw_value_col,
                    rule,
                    values,
                )
                rows.append(out)
                values_by_level[str(out["层级"])] = out
        else:
            values = monthly_values(
                source, value_col, months, filters, lag_months=lag_months,
            )
            out = build_output_row(level, metric, data_source, raw_value_col, rule, values)
            rows.append(out)
            values_by_level[str(out["层级"])] = out

    for template_row in self_table_rows:
        for country in expand_countries(source, "国家"):
            rec = build_self_table_subtract_row(template_row, country, values_by_level)
            if rec:
                rows.append(rec)
                values_by_level[str(rec["层级"])] = rec

    result = pd.DataFrame(rows)
    numeric_cols = MONTH_COLUMNS + ["mom", "mom%"]
    for col in numeric_cols:
        if col in result.columns:
            result[col] = pd.to_numeric(result[col], errors="coerce").round(6)
    return result.sort_values("层级", key=lambda s: s.map(sort_level_key)).reset_index(drop=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 月报下钻 CSV")
    parser.add_argument(
        "--metric",
        choices=list(METRIC_CONFIGS.keys()),
        action="append",
        help="仅处理指定指标，可重复指定",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_dir = resolve_output_dir()
    s1_dir = output_dir / "下钻"
    s1_dir.mkdir(parents=True, exist_ok=True)

    keys = args.metric or list(METRIC_CONFIGS.keys())
    for key in keys:
        config = dict(METRIC_CONFIGS[key])
        config["output_file"] = s1_dir / f"s1_{key}下钻.csv"
        df = build_metric(config)
        df.to_csv(config["output_file"], index=False, encoding="utf-8-sig")
        print(f"已生成 {key}: {config['output_file']} ({len(df)} 行)")


if __name__ == "__main__":
    main()

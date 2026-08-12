#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 周报下钻 CSV（DAU / DNU / Bookings / Retention / New Retention / Save）。

输入：
  - memory/{DAU,DNU,Bookings,Retention,New_Retention,Save}指标库.csv
  - raw_data/{dau,dnu,bookings,retention,new_retention,save}.csv

输出：
  - output/下钻/s1_{dau,dnu,bookings,retention,new_retention,save}下钻.csv

说明：
  raw_data 中的数据已经是 WEEK AVG 后的数据，日期字段表示每周第 1 天。
  例如当前数据中 2026-06-08 是本周，2026-06-01 是上周。
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
from typing import Any

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]
MEMORY_DIR = BASE_DIR / "memory"
RAW_DATA_DIR = BASE_DIR / "raw_data"


def resolve_output_dir() -> Path:
    env = os.environ.get("ZHOUBAO_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output"


OUTPUT_DIR = resolve_output_dir()
S1_OUTPUT_DIR = OUTPUT_DIR / "下钻"

MAX_WEEKS = 8
BASE_WEEK_LABELS = ["本周", "上周"] + [f"{i}周前" for i in range(2, MAX_WEEKS)]

SAVE_REQUIRED_COLS = {
    "渠道自然",
    "国家",
    "日期",
    "平台",
    "新老",
    "付费状态",
    "版本",
    "一级功能",
    "二级功能",
    "保存 UV",
}
DAU_REQUIRED_COLS = {"渠道自然", "国家", "日期", "平台", "DAU", "新老"}

METRIC_CONFIGS: dict[str, dict[str, Any]] = {
    "dau": {
        "name": "DAU",
        "template_file": MEMORY_DIR / "DAU指标库.csv",
        "data_file": RAW_DATA_DIR / "dau.csv",
        "output_file": S1_OUTPUT_DIR / "s1_dau下钻.csv",
        "value_column": "DAU",
        "required_cols": DAU_REQUIRED_COLS,
    },
    "dnu": {
        "name": "DNU",
        "template_file": MEMORY_DIR / "DNU指标库.csv",
        "data_file": RAW_DATA_DIR / "dnu.csv",
        "output_file": S1_OUTPUT_DIR / "s1_dnu下钻.csv",
        "value_column": "DNU",
        "required_cols": {"渠道自然", "国家", "日期", "平台", "DNU"},
    },
    "bookings": {
        "name": "Bookings",
        "template_file": MEMORY_DIR / "Bookings指标库.csv",
        "data_file": RAW_DATA_DIR / "bookings.csv",
        "output_file": S1_OUTPUT_DIR / "s1_bookings下钻.csv",
        "value_columns": [
            "日均订阅毛利（剔除退款，$）",
            "新增毛利",
            "续订毛利",
        ],
        "required_cols": {"日期", "平台", "国家", "订阅类型"},
    },
    "retention": {
        "name": "Retention",
        "template_file": MEMORY_DIR / "Retention指标库.csv",
        "data_file": RAW_DATA_DIR / "retention.csv",
        "output_file": S1_OUTPUT_DIR / "s1_retention下钻.csv",
        "value_columns": ["活跃用户数", "次日留存人数"],
        "required_cols": {"渠道自然", "国家", "日期", "平台", "新老", "活跃用户数", "次日留存人数"},
    },
    "new_retention": {
        "name": "New Retention",
        "template_file": MEMORY_DIR / "New_Retention指标库.csv",
        "data_file": RAW_DATA_DIR / "new_retention.csv",
        "output_file": S1_OUTPUT_DIR / "s1_new_retention下钻.csv",
        "value_columns": ["DNU", "新增次日留存人数"],
        "required_cols": {"渠道自然", "国家", "日期", "平台", "DNU", "新增次日留存人数"},
    },
    "save": {
        "name": "Save",
        "template_file": MEMORY_DIR / "Save指标库.csv",
        "data_file": RAW_DATA_DIR / "save.csv",
        "output_file": S1_OUTPUT_DIR / "s1_save下钻.csv",
        "value_column": "保存 UV",
        "value_aliases": {"保存": "保存 UV"},
        "required_cols": SAVE_REQUIRED_COLS,
        "sources": {
            "raw_data/save.csv": {
                "path": RAW_DATA_DIR / "save.csv",
                "required_cols": SAVE_REQUIRED_COLS,
                "value_column": "保存 UV",
            },
            "raw_data/dau.csv": {
                "path": RAW_DATA_DIR / "dau.csv",
                "required_cols": DAU_REQUIRED_COLS,
                "value_column": "DAU",
            },
        },
        "self_table_metric_map": {"保存": "保存量", "DAU": "DAU"},
        "sub_feature_source_query": "图片编辑二级功能",
        "denominator_source_key": "raw_data/dau.csv",
        "denominator_filters": {
            "渠道自然": "整体",
            "国家": "整体",
            "平台": "整体",
            "新老": "整体",
        },
    },
}


def parse_dimension(rule_text: str, sep: str = "，") -> dict[str, str]:
    dims: dict[str, str] = {}
    for part in str(rule_text).split(sep):
        part = part.strip()
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        dims[key.strip()] = value.strip()
    return dims


def sort_level_key(level: str) -> tuple[Any, ...]:
    tokens: list[tuple[int, Any]] = []
    for part in str(level).split("."):
        if part.isdigit():
            tokens.append((0, int(part)))
        else:
            tokens.append((1, part))
    return tuple(tokens)


def load_template(template_file: Path) -> pd.DataFrame:
    try:
        df = pd.read_csv(template_file, encoding="utf-8-sig", dtype=str).fillna("")
    except UnicodeDecodeError:
        df = pd.read_csv(template_file, encoding="gbk", dtype=str).fillna("")
    if "指标" not in df.columns and "指标1" in df.columns:
        df["指标"] = df["指标1"]
    return df


def load_source_file(
    data_file: Path,
    required_cols: set[str],
    value_column: str | None = None,
    value_columns: list[str] | None = None,
) -> pd.DataFrame:
    df = pd.read_csv(data_file, encoding="utf-8-sig")
    missing = required_cols - set(df.columns)
    if missing:
        raise ValueError(f"{data_file} 缺少必要字段: {sorted(missing)}")

    df["__日期__"] = pd.to_datetime(df["日期"]).dt.normalize()

    if value_columns:
        for col in value_columns:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors="coerce")
    elif value_column:
        df[value_column] = pd.to_numeric(df[value_column], errors="coerce").fillna(0)
    return df


def load_source(config: dict[str, Any]) -> pd.DataFrame:
    return load_source_file(
        config["data_file"],
        config["required_cols"],
        value_column=config.get("value_column"),
        value_columns=config.get("value_columns"),
    )


def load_sources(config: dict[str, Any]) -> dict[str, pd.DataFrame]:
    source_map = config.get("sources")
    if not source_map:
        key = config["data_file"].name
        return {
            key: load_source_file(
                config["data_file"],
                config["required_cols"],
                value_column=config.get("value_column"),
                value_columns=config.get("value_columns"),
            )
        }

    loaded: dict[str, pd.DataFrame] = {}
    for key, spec in source_map.items():
        if isinstance(spec, dict):
            loaded[key] = load_source_file(
                spec["path"],
                spec["required_cols"],
                value_column=spec.get("value_column"),
                value_columns=spec.get("value_columns"),
            )
        else:
            loaded[key] = load_source_file(
                spec,
                config["required_cols"],
                value_column=config.get("value_column"),
                value_columns=config.get("value_columns"),
            )
    return loaded


def build_week_context(source: pd.DataFrame) -> tuple[list[pd.Timestamp], list[str], dict[pd.Timestamp, str]]:
    """构建周上下文。若设置 ZHOUBAO_TARGET_WEEK，则「本周」锚定为该周一起点（及此前最多 MAX_WEEKS-1 周）。"""
    import sys

    _scripts = Path(__file__).resolve().parents[1]
    if str(_scripts) not in sys.path:
        sys.path.insert(0, str(_scripts))
    from skill_paths import target_week_start

    all_starts = sorted(
        {pd.Timestamp(d).normalize() for d in source["__日期__"].dropna().unique()},
        reverse=True,
    )
    target = target_week_start()
    if target is not None:
        target = pd.Timestamp(target).normalize()
        eligible = [d for d in all_starts if d <= target]
        if not eligible:
            raise ValueError(
                f"ZHOUBAO_TARGET_WEEK={target.date()} 在 raw_data 中无可用周（有 {all_starts[:3]}…）"
            )
        week_starts = eligible[:MAX_WEEKS]
    else:
        week_starts = all_starts[:MAX_WEEKS]
    week_labels = BASE_WEEK_LABELS[: len(week_starts)]
    label_by_date = dict(zip(week_starts, week_labels))
    return week_starts, week_labels, label_by_date


def is_expand_value(value: str) -> bool:
    return "x" in value and "非整体" in value


def is_expand_country(value: str) -> bool:
    return is_expand_value(value)


def get_expand_dimension(filters: dict[str, str]) -> str | None:
    for dim, value in filters.items():
        if is_expand_value(value):
            return dim
    return None


def effective_filters(filters: dict[str, str], config: dict[str, Any]) -> dict[str, str]:
    expand_dim = get_expand_dimension(filters)
    if (
        expand_dim == "二级功能"
        and config.get("sub_feature_source_query")
    ):
        return {
            key: value
            for key, value in filters.items()
            if not (key == "一级功能" and value == "整体")
        }
    return filters


def get_expand_values(dim: str, source: pd.DataFrame, config: dict[str, Any]) -> list[str]:
    if dim == "国家":
        return sorted(c for c in source["国家"].dropna().unique() if c != "整体")

    if dim == "二级功能":
        work = source
        query_label = config.get("sub_feature_source_query")
        if query_label and "_query" in work.columns:
            work = work[work["_query"] == query_label]
        return sorted(v for v in work["二级功能"].dropna().unique() if v != "整体")

    return []


def replace_expand_placeholder(metric: str, value: str) -> str:
    return (
        metric.replace("x（某 国家 值）", value)
        .replace("x（某country）", value)
        .replace("x（某 功能 值）", value)
        .replace("xx", value)
    )


def replace_country_placeholder(metric: str, country: str) -> str:
    return replace_expand_placeholder(metric, country)


def apply_filters(
    df: pd.DataFrame,
    filters: dict[str, str],
    country: str | None = None,
    expand_dim: str | None = None,
    expand_value: str | None = None,
) -> pd.DataFrame:
    result = df
    for dim, value in filters.items():
        if dim not in result.columns:
            continue

        if dim == "国家" and country is not None:
            result = result[result[dim] == country]
            continue

        if is_expand_value(value):
            if expand_dim == dim and expand_value is not None:
                result = result[result[dim] == expand_value]
            continue

        result = result[result[dim] == value]

    return result


def _extract_week_value(week_rows: pd.DataFrame, value_column: str) -> float:
    if week_rows.empty:
        return 0.0
    raw = week_rows[value_column].sum() if len(week_rows) > 1 else week_rows[value_column].iloc[0]
    return float(raw) if pd.notna(raw) else 0.0


def weekly_values(
    source: pd.DataFrame,
    value_column: str,
    week_starts: list[pd.Timestamp],
    week_labels: list[str],
    filters: dict[str, str],
    country: str | None = None,
    expand_dim: str | None = None,
    expand_value: str | None = None,
    denominator_column: str | None = None,
    denominator_source: pd.DataFrame | None = None,
    denominator_filters: dict[str, str] | None = None,
) -> dict[str, float | pd.NA]:
    values: dict[str, float | pd.NA] = {}
    filtered = apply_filters(
        source,
        filters,
        country=country,
        expand_dim=expand_dim,
        expand_value=expand_value,
    )
    available_dates = set(source["__日期__"])

    use_cross_denominator = (
        denominator_column is not None
        and denominator_column not in source.columns
        and denominator_source is not None
    )
    if use_cross_denominator:
        denom_filtered = apply_filters(denominator_source, denominator_filters or {})

    for week_start, label in zip(week_starts, week_labels):
        if week_start not in available_dates:
            values[label] = pd.NA
            continue
        week_rows = filtered[filtered["__日期__"] == week_start]
        if denominator_column:
            numerator = _extract_week_value(week_rows, value_column)
            if use_cross_denominator:
                denom_rows = denom_filtered[denom_filtered["__日期__"] == week_start]
                denominator = _extract_week_value(denom_rows, denominator_column)
            else:
                denominator = _extract_week_value(week_rows, denominator_column)
            values[label] = (
                numerator / denominator if denominator not in (0.0, 0) else pd.NA
            )
        else:
            values[label] = _extract_week_value(week_rows, value_column)
    return values


def add_wow_columns(df: pd.DataFrame, week_labels: list[str]) -> pd.DataFrame:
    if len(week_labels) < 2:
        df["wow"] = pd.NA
        df["wow%"] = pd.NA
        return df

    cur, prev = week_labels[0], week_labels[1]
    df["wow"] = pd.to_numeric(df[cur], errors="coerce") - pd.to_numeric(df[prev], errors="coerce")
    denom = pd.to_numeric(df[prev], errors="coerce").replace(0, pd.NA)
    df["wow%"] = ((pd.to_numeric(df[cur], errors="coerce") / denom) - 1) * 100
    return df


def resolve_source_key(row: pd.Series, config: dict[str, Any]) -> str:
    data_source = str(row.get("数据来源", "")).strip()
    if data_source:
        if " & " in data_source:
            return data_source.split(" & ")[0].strip()
        return data_source
    return config["data_file"].name


def resolve_value_column(expr: str, config: dict[str, Any], source_columns: set[str]) -> str | None:
    aliases = config.get("value_aliases", {})
    mapped = aliases.get(expr, expr)
    if mapped in source_columns:
        return mapped
    return None


def build_self_table_record(
    records: list[dict[str, Any]],
    row: pd.Series,
    week_labels: list[str],
    config: dict[str, Any],
) -> dict[str, Any] | None:
    expr = str(row.get("指标对应值", "")).strip()
    if "/" not in expr:
        return None

    numerator_key, denominator_key = parse_metric_expression(expr)
    metric_map = config.get("self_table_metric_map", {})
    numerator_metric = metric_map.get(numerator_key, numerator_key)
    denominator_metric = metric_map.get(denominator_key, denominator_key)

    numerator_rec = next((r for r in records if r.get("指标") == numerator_metric), None)
    denominator_rec = next((r for r in records if r.get("指标") == denominator_metric), None)
    if not numerator_rec or not denominator_rec:
        return None

    rec: dict[str, Any] = {"层级": row["层级"], "指标": row["指标"]}
    for label in week_labels:
        num = pd.to_numeric(numerator_rec.get(label), errors="coerce")
        den = pd.to_numeric(denominator_rec.get(label), errors="coerce")
        if pd.notna(num) and pd.notna(den) and den != 0:
            rec[label] = float(num) / float(den)
        else:
            rec[label] = pd.NA
    return rec


def parse_metric_expression(expr: str) -> tuple[str, str | None]:
    text = str(expr).strip()
    if "/" in text:
        numerator, denominator = text.split("/", 1)
        return numerator.strip(), denominator.strip()
    return text, None


def resolve_metric_columns(
    config: dict[str, Any],
    row: pd.Series,
    source_columns: set[str],
) -> tuple[str, str | None] | None:
    expr = str(row.get("指标对应值", "")).strip()
    if not expr:
        return None

    if "/" not in expr:
        direct_col = resolve_value_column(expr, config, source_columns) or expr
        if direct_col in source_columns:
            return direct_col, None
        fixed_value_col = config.get("value_column")
        if fixed_value_col:
            aliases = config.get("value_aliases", {})
            expected_exprs = {fixed_value_col, *aliases.keys(), *aliases.values()}
            if expr not in expected_exprs:
                return None
            value_col = resolve_value_column(expr, config, source_columns) or fixed_value_col
            if value_col not in source_columns:
                return None
            return value_col, None
        return None

    fixed_value_col = config.get("value_column")
    if fixed_value_col and "/" not in expr:
        return None

    numerator, denominator = parse_metric_expression(expr)
    numerator_col = resolve_value_column(numerator, config, source_columns) or numerator
    if numerator_col not in source_columns:
        return None

    if denominator:
        denominator_col = resolve_value_column(denominator, config, source_columns) or denominator
        if denominator_col in source_columns:
            return numerator_col, denominator_col
        if config.get("denominator_source_key") and denominator in config.get(
            "self_table_metric_map", {denominator: denominator}
        ):
            return numerator_col, denominator_col
        return None

    return numerator_col, None


def finalize_drill_result(
    records: list[dict[str, Any]],
    week_labels: list[str],
    output_file: Path,
    metric_name: str,
) -> None:
    result = pd.DataFrame(records)
    result = add_wow_columns(result, week_labels)
    ordered_cols = ["层级", "指标"] + week_labels + ["wow", "wow%"]
    result = result[ordered_cols]

    numeric_cols = week_labels + ["wow", "wow%"]
    for col in numeric_cols:
        result[col] = pd.to_numeric(result[col], errors="coerce").round(6)

    result = result.sort_values("层级", key=lambda s: s.map(sort_level_key)).reset_index(drop=True)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    result.to_csv(output_file, index=False, encoding="utf-8-sig")
    print(f"已生成: {output_file}，行数: {len(result)}")


def generate_multi_source_drill(config: dict[str, Any]) -> None:
    template = load_template(config["template_file"])
    sources = load_sources(config)
    primary_key = config["data_file"].name
    if primary_key not in sources:
        primary_key = next(iter(sources))
    source = sources[primary_key]
    week_starts, week_labels, label_by_date = build_week_context(source)

    print(f"\n=== {config['name']} 下钻 ===")
    print("周映射：")
    for d in week_starts:
        print(f"  {label_by_date[d]} = {d.strftime('%Y/%m/%d')}")

    denominator_source = None
    denominator_filters = config.get("denominator_filters")
    denominator_key = config.get("denominator_source_key")
    if denominator_key:
        denominator_source = sources.get(denominator_key)

    records: list[dict[str, Any]] = []
    for _, row in template.iterrows():
        level = row["层级"]
        metric = row["指标"]
        source_key = resolve_source_key(row, config)

        if source_key == "本表":
            rec = build_self_table_record(records, row, week_labels, config)
            if rec:
                records.append(rec)
            continue

        if source_key not in sources:
            continue

        current_source = sources[source_key]
        source_columns = set(current_source.columns)
        metric_cols = resolve_metric_columns(config, row, source_columns)
        if not metric_cols:
            continue
        value_column, denominator_column = metric_cols

        filters = effective_filters(parse_dimension(row["取数口径"]), config)
        expand_dim = get_expand_dimension(filters)

        weekly_kwargs = {
            "denominator_column": denominator_column,
            "denominator_source": denominator_source,
            "denominator_filters": denominator_filters,
        }

        if expand_dim:
            for expand_value in get_expand_values(expand_dim, current_source, config):
                rec = {
                    "层级": str(level).replace(".x", f".{expand_value}"),
                    "指标": replace_expand_placeholder(metric, expand_value),
                }
                rec.update(
                    weekly_values(
                        current_source,
                        value_column,
                        week_starts,
                        week_labels,
                        filters,
                        expand_dim=expand_dim,
                        expand_value=expand_value,
                        **weekly_kwargs,
                    )
                )
                records.append(rec)
        else:
            rec = {"层级": level, "指标": metric}
            rec.update(
                weekly_values(
                    current_source,
                    value_column,
                    week_starts,
                    week_labels,
                    filters,
                    **weekly_kwargs,
                )
            )
            records.append(rec)

    finalize_drill_result(records, week_labels, config["output_file"], config["name"])


def generate_drill(config: dict[str, Any]) -> None:
    if config.get("sources"):
        generate_multi_source_drill(config)
        return

    template = load_template(config["template_file"])
    source = load_source(config)
    week_starts, week_labels, label_by_date = build_week_context(source)
    countries = sorted(c for c in source["国家"].dropna().unique() if c != "整体")

    print(f"\n=== {config['name']} 下钻 ===")
    print("周映射：")
    for d in week_starts:
        print(f"  {label_by_date[d]} = {d.strftime('%Y/%m/%d')}")

    records: list[dict[str, Any]] = []
    source_columns = set(source.columns)
    for _, row in template.iterrows():
        level = row["层级"]
        metric = row["指标"]
        metric_cols = resolve_metric_columns(config, row, source_columns)
        if not metric_cols:
            continue
        value_column, denominator_column = metric_cols

        filters = parse_dimension(row["取数口径"])
        country_rule = filters.get("国家", "")

        if is_expand_country(country_rule):
            for country in countries:
                rec = {
                    "层级": level.replace(".x", f".{country}"),
                    "指标": replace_country_placeholder(metric, country),
                }
                rec.update(
                    weekly_values(
                        source,
                        value_column,
                        week_starts,
                        week_labels,
                        filters,
                        country=country,
                        denominator_column=denominator_column,
                    )
                )
                records.append(rec)
        else:
            rec = {"层级": level, "指标": metric}
            rec.update(
                weekly_values(
                    source,
                    value_column,
                    week_starts,
                    week_labels,
                    filters,
                    denominator_column=denominator_column,
                )
            )
            records.append(rec)

    finalize_drill_result(records, week_labels, config["output_file"], config["name"])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 周报下钻 CSV")
    parser.add_argument(
        "--metric",
        choices=["dau", "dnu", "bookings", "retention", "new_retention", "save", "all"],
        default="all",
        help="指定生成的指标（默认 all）",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    all_metrics = ["dau", "dnu", "bookings", "retention", "new_retention", "save"]
    metrics = all_metrics if args.metric == "all" else [args.metric]
    for metric_key in metrics:
        generate_drill(METRIC_CONFIGS[metric_key])


if __name__ == "__main__":
    main()

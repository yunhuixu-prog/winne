#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""导出 AI 月报下钻分析 Markdown。

格式对齐周报 skill/计算脚本/数据处理/s3导出下钻md脚本.py；
月报 s2 使用 本月/上月/mom/mom%，本脚本加载时映射为 本周/上周/wow/wow%。

输入：
  output/贡献度/s2_{mau,bookings,valid_vip}贡献度.csv
输出：
  output/下钻报告/{mau,bookings,valid_vip}下钻分析报告.md
"""
from __future__ import annotations

import argparse
import os
import re
from pathlib import Path
from typing import Any

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]

MONTH_TO_WEEK_COLUMN_MAP = {
    "本月": "本周",
    "上月": "上周",
    "mom": "wow",
    "mom%": "wow%",
}


def resolve_output_dir() -> Path:
    env = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output" / "_staging"


OUTPUT_DIR = resolve_output_dir()
S2_OUTPUT_DIR = OUTPUT_DIR / "贡献度"
S3_OUTPUT_DIR = OUTPUT_DIR / "下钻报告"

THRESHOLD = 1.0

REPORT_CONFIGS: dict[str, dict[str, Any]] = {
    "mau": {
        "name": "MAU",
        "input_file": S2_OUTPUT_DIR / "s2_mau贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "mau下钻分析报告.md",
        "report_type": "dimension",
        "title": "MAU下钻分析报告",
        "overall_label": "整体MAU",
        "value_formatter": "int",
        "metric_suffixes": [" MAU", "（国家值）MAU", "MAU"],
        "metric_aliases": {"新渠道用户": "渠道", "新自然用户": "自然"},
        "first_level_contrib_label": "整体MAU环比",
    },
    "bookings": {
        "name": "Bookings",
        "input_file": S2_OUTPUT_DIR / "s2_bookings贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "bookings下钻分析报告.md",
        "report_type": "dimension",
        "title": "订阅毛利下钻分析报告",
        "overall_label": "订阅毛利（剔除退款，$）",
        # 订阅毛利美元绝对金额取整、不写小数（见 memory/归因思路.md 术语库 7.1）
        "value_formatter": "int",
        "metric_suffixes": [],
        "first_level_contrib_label": "订阅毛利环比",
    },
    "valid_vip": {
        "name": "月有效会员数",
        "input_file": S2_OUTPUT_DIR / "s2_valid_vip贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "valid_vip下钻分析报告.md",
        "report_type": "dimension",
        "title": "月有效会员数下钻分析报告",
        "overall_label": "整体月有效会员数",
        "value_formatter": "int",
        "metric_suffixes": [],
        "first_level_contrib_label": "整体月有效会员数环比",
        "force_display_levels": ["1.1"],
        "no_drill_children_levels": ["1.1"],
    },
}


def strip_emoji(text: str) -> str:
    return re.sub(
        "[\U0001F000-\U0001FAFF"
        "\U00002600-\U000027BF"
        "\U0000FE00-\U0000FE0F"
        "\U0000200D"
        "\U000020E3"
        "]+",
        "",
        text,
    ).strip()


def format_number(num: float) -> str:
    if pd.isna(num):
        return ""
    return f"{num:,.2f}"


def format_number_int(num: float) -> str:
    if pd.isna(num):
        return ""
    return f"{int(round(num)):,}"


def format_percent(num: float) -> str:
    if pd.isna(num):
        return ""
    return f"{num:.2f}%"


def format_rate_value(num: float) -> str:
    if pd.isna(num):
        return ""
    return format_percent(num * 100)


def parse_hierarchy(level: str) -> list[str]:
    if pd.isna(level):
        return []
    return [part for part in str(level).split(".") if part]


def get_level_depth(level: str) -> int:
    return len(parse_hierarchy(level))


def is_ancestor(parent: str, child: str) -> bool:
    parent_parts = parse_hierarchy(parent)
    child_parts = parse_hierarchy(child)
    if len(parent_parts) >= len(child_parts):
        return False
    return child_parts[: len(parent_parts)] == parent_parts


def clean_metric_name(
    name: str,
    suffixes: list[str] | None = None,
    aliases: dict[str, str] | None = None,
) -> str:
    cleaned = strip_emoji(str(name))
    cleaned = cleaned.replace("x（国家值）", "").strip()
    for suffix in suffixes or []:
        if cleaned.endswith(suffix) and len(cleaned) > len(suffix):
            cleaned = cleaned[: -len(suffix)]
            break
    cleaned = cleaned.strip()
    if aliases and cleaned in aliases:
        cleaned = aliases[cleaned]
    return cleaned


def contribution_abs(row: pd.Series) -> float:
    value = row.get("对整体变化值贡献率")
    if pd.isna(value):
        return 0.0
    return abs(float(value))


def should_display(
    row: pd.Series,
    df: pd.DataFrame,
    threshold: float,
    force_display_levels: set[str] | None = None,
) -> bool:
    level = str(row["层级"])
    if force_display_levels and level in force_display_levels:
        return True
    if contribution_abs(row) >= threshold:
        return True

    for _, candidate in df.iterrows():
        child_level = str(candidate["层级"])
        if is_ancestor(level, child_level) and contribution_abs(candidate) >= threshold:
            return True
    return False


def get_display_children(
    level: str,
    df: pd.DataFrame,
    threshold: float,
    force_display_levels: set[str] | None = None,
    no_drill_children_levels: set[str] | None = None,
) -> list[pd.Series]:
    if no_drill_children_levels and level in no_drill_children_levels:
        return []

    children: list[pd.Series] = []
    parent_depth = get_level_depth(level)
    for _, row in df.iterrows():
        child_level = str(row["层级"])
        if not is_ancestor(level, child_level):
            continue
        if get_level_depth(child_level) != parent_depth + 1:
            continue
        if should_display(row, df, threshold, force_display_levels):
            children.append(row)
    return sorted(children, key=contribution_abs, reverse=True)


def format_value_range(row: pd.Series, formatter: str) -> str:
    prev_value = row.get("上周")
    curr_value = row.get("本周")
    if pd.isna(prev_value) or pd.isna(curr_value):
        return ""
    prev = format_overall_value(float(prev_value), formatter)
    curr = format_overall_value(float(curr_value), formatter)
    return f"{prev} --> {curr}"


def generate_drilldown_line(
    row: pd.Series,
    prefix: str = "",
    overall_wow_pct: float | None = None,
    is_first_level_breakdown: bool = False,
    metric_suffixes: list[str] | None = None,
    metric_aliases: dict[str, str] | None = None,
    first_level_contrib_label: str = "整体环比",
    value_formatter: str = "float",
) -> str:
    metric_name = clean_metric_name(
        str(row["指标"]),
        metric_suffixes,
        aliases=metric_aliases,
    )
    contrib_value = row["对整体变化值贡献率"] if not pd.isna(row["对整体变化值贡献率"]) else 0
    if contrib_value < 0:
        metric_name = "*反向提拉* " + metric_name

    wow_pct = row["wow%"] if not pd.isna(row["wow%"]) else 0
    contrib_pct = row["对整体变化率贡献"] if not pd.isna(row["对整体变化率贡献"]) else 0
    value_range = format_value_range(row, value_formatter)
    range_suffix = f"，{value_range}" if value_range else ""
    contrib_detail = f"占比{format_percent(contrib_value)}{range_suffix}"

    if is_first_level_breakdown and overall_wow_pct is not None:
        return (
            f"{prefix}{metric_name}，环比{format_percent(wow_pct)}，"
            f"贡献{first_level_contrib_label}{format_percent(overall_wow_pct)}的"
            f"{format_percent(contrib_pct)}（{contrib_detail}）"
        )

    return (
        f"{prefix}{metric_name}，环比{format_percent(wow_pct)}，"
        f"贡献{format_percent(contrib_pct)}（{contrib_detail}）"
    )


def generate_dimension_drilldown(
    df: pd.DataFrame,
    root_level: str = "1",
    threshold: float = THRESHOLD,
    overall_wow_pct: float | None = None,
    metric_suffixes: list[str] | None = None,
    metric_aliases: dict[str, str] | None = None,
    first_level_contrib_label: str = "整体环比",
    value_formatter: str = "float",
    force_display_levels: list[str] | None = None,
    no_drill_children_levels: list[str] | None = None,
) -> str:
    lines: list[str] = []
    force_levels = set(force_display_levels or [])
    no_drill_levels = set(no_drill_children_levels or [])

    def drill_down(level: str, prefix: str = "", is_first_level: bool = False) -> None:
        children = get_display_children(
            level,
            df,
            threshold,
            force_levels,
            no_drill_levels,
        )
        for idx, child in enumerate(children):
            is_last = idx == len(children) - 1
            current_prefix = prefix + ("└── " if is_last else "├── ")
            lines.append(
                generate_drilldown_line(
                    child,
                    current_prefix,
                    overall_wow_pct=overall_wow_pct,
                    is_first_level_breakdown=is_first_level,
                    metric_suffixes=metric_suffixes,
                    metric_aliases=metric_aliases,
                    first_level_contrib_label=first_level_contrib_label,
                    value_formatter=value_formatter,
                )
            )
            child_level = str(child["层级"])
            if get_display_children(
                child_level,
                df,
                threshold,
                force_levels,
                no_drill_levels,
            ):
                next_prefix = prefix + ("    " if is_last else "│   ")
                drill_down(child_level, next_prefix, is_first_level=False)

    drill_down(root_level, is_first_level=True)
    return "\n".join(line for line in lines if line)


def load_contribution(input_file: Path) -> pd.DataFrame:
    if not input_file.exists():
        raise FileNotFoundError(f"未找到输入文件: {input_file}")

    df = pd.read_csv(input_file, encoding="utf-8-sig")
    df = df.rename(columns=MONTH_TO_WEEK_COLUMN_MAP)
    df["层级"] = df["层级"].astype(str)
    df["指标"] = df["指标"].apply(lambda x: strip_emoji(str(x)) if pd.notna(x) else x)

    numeric_cols = [
        "本周",
        "上周",
        "wow",
        "wow%",
        "对整体变化绝对值贡献",
        "对整体变化值贡献率",
        "对整体变化率贡献",
    ]
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def format_overall_value(value: float, formatter: str) -> str:
    if formatter == "percent":
        return format_rate_value(value)
    if formatter == "int":
        return format_number_int(value)
    return format_number(value)


def build_phenomenon(overall_row: pd.Series, config: dict[str, Any]) -> str:
    formatter = config.get("value_formatter", "float")
    prev_value = overall_row["上周"]
    curr_value = overall_row["本周"]
    wow_value = overall_row["wow"]
    wow_pct = overall_row["wow%"]
    overall_label = config.get("overall_label", "整体")

    if formatter == "percent":
        return (
            f"现象：{overall_label}环比{format_percent(wow_pct)}"
            f"（{format_rate_value(prev_value)} --> {format_rate_value(curr_value)}, "
            f"{format_rate_value(wow_value)}）"
        )

    return (
        f"现象：{overall_label}环比{format_percent(wow_pct)}"
        f"（{format_overall_value(prev_value, formatter)} --> "
        f"{format_overall_value(curr_value, formatter)}, "
        f"{format_overall_value(wow_value, formatter)}）"
    )


def generate_report(config: dict[str, Any]) -> None:
    print(f"\n=== {config['name']} 报告 ===")
    df = load_contribution(config["input_file"])

    overall = df[df["层级"] == "1"]
    if overall.empty:
        raise ValueError(f"{config['name']} 未找到层级=1 的整体行")

    overall_row = overall.iloc[0]
    wow_pct = overall_row["wow%"]
    phenomenon = build_phenomenon(overall_row, config)

    drilldown = generate_dimension_drilldown(
        df,
        "1",
        threshold=THRESHOLD,
        overall_wow_pct=wow_pct,
        metric_suffixes=config.get("metric_suffixes"),
        metric_aliases=config.get("metric_aliases"),
        first_level_contrib_label=config.get("first_level_contrib_label", "整体环比"),
        value_formatter=config.get("value_formatter", "float"),
        force_display_levels=config.get("force_display_levels"),
        no_drill_children_levels=config.get("no_drill_children_levels"),
    )

    report = f"""# {config['title']}

{phenomenon}

## 维度下钻
{drilldown}

"""
    output_file = config["output_file"]
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(report, encoding="utf-8")
    print(f"报告已生成：{output_file}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="导出 AI 月报下钻分析 Markdown")
    parser.add_argument(
        "--metric",
        choices=["mau", "bookings", "valid_vip", "all"],
        default="all",
        help="指定生成的报告（默认 all）",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    metrics = ["mau", "bookings", "valid_vip"] if args.metric == "all" else [args.metric]
    for metric_key in metrics:
        generate_report(REPORT_CONFIGS[metric_key])


if __name__ == "__main__":
    main()

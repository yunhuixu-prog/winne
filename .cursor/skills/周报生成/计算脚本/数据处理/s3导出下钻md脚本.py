#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""导出 AI 周报下钻分析 Markdown。

参考：
  参考文档/分析下钻报告实现过程/计算脚本/2数据处理/s3导出下钻md脚本.py

输入：
  output/贡献度/s2_{dau,dnu,retention,new_retention,bookings,save}贡献度.csv
输出：
  output/下钻报告/{dau,dnu,retention,new_retention,bookings,save}下钻分析报告.md
"""
from __future__ import annotations

import argparse
import os
import re
from pathlib import Path
from typing import Any

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]


def resolve_output_dir() -> Path:
    env = os.environ.get("ZHOUBAO_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output"


OUTPUT_DIR = resolve_output_dir()
S2_OUTPUT_DIR = OUTPUT_DIR / "贡献度"
S3_OUTPUT_DIR = OUTPUT_DIR / "下钻报告"

THRESHOLD = 1.0

REPORT_CONFIGS: dict[str, dict[str, Any]] = {
    "dau": {
        "name": "DAU",
        "input_file": S2_OUTPUT_DIR / "s2_dau贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "dau下钻分析报告.md",
        "report_type": "dimension",
        "title": "DAU下钻分析报告",
        "overall_label": "整体DAU",
        "value_formatter": "int",
        "metric_suffixes": ["（国家）DAU", "整体DAU", "DAU"],
        "first_level_contrib_label": "整体DAU环比",
    },
    "dnu": {
        "name": "DNU",
        "input_file": S2_OUTPUT_DIR / "s2_dnu贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "dnu下钻分析报告.md",
        "report_type": "dimension",
        "title": "DNU下钻分析报告",
        "overall_label": "整体DNU",
        "value_formatter": "int",
        "metric_suffixes": [" DNU", "整体DNU"],
        "first_level_contrib_label": "整体DNU环比",
    },
    "retention": {
        "name": "Retention",
        "input_file": S2_OUTPUT_DIR / "s2_retention贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "retention下钻分析报告.md",
        "report_type": "dual_factor",
        "title": "活跃次留下钻分析报告",
        "overall_label": "整体活跃次留",
        "value_formatter": "percent",
        "formula": "活跃次留=子层级次留*子层级占活跃UV比",
        "branch_labels": ["子层级次留", "子层级占活跃UV比"],
        "first_level_contrib_label": "整体活跃次留环比",
    },
    "new_retention": {
        "name": "New Retention",
        "input_file": S2_OUTPUT_DIR / "s2_new_retention贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "new_retention下钻分析报告.md",
        "report_type": "dual_factor",
        "title": "新增次留下钻分析报告",
        "overall_label": "整体新增次留",
        "value_formatter": "percent",
        "formula": "新增次留=子层级新增次留*子层级占新增UV比",
        "branch_labels": ["子层级新增次留", "子层级占新增UV比"],
        "first_level_contrib_label": "整体新增次留环比",
    },
    "bookings": {
        "name": "Bookings",
        "input_file": S2_OUTPUT_DIR / "s2_bookings贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "bookings下钻分析报告.md",
        "report_type": "dimension",
        "title": "订阅毛利下钻分析报告",
        "overall_label": "日均订阅毛利（剔除退款，$）",
        "value_formatter": "float",
        "metric_suffixes": [],
        "first_level_contrib_label": "日均订阅毛利环比",
    },
    "save": {
        "name": "Save",
        "input_file": S2_OUTPUT_DIR / "s2_save贡献度.csv",
        "output_file": S3_OUTPUT_DIR / "save下钻分析报告.md",
        "report_type": "multiplicative_save",
        "title": "保存量下钻分析报告",
        "overall_label": "整体保存量",
        "value_formatter": "int",
        "formula": "保存量 = DAU × 保存率",
        "factor_levels": ["2", "3"],
        "factor_labels": ["DAU", "保存率"],
        "first_level_contrib_label": "整体保存量环比",
        "volatility_threshold": 5.0,
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


def clean_metric_name(name: str, suffixes: list[str] | None = None) -> str:
    cleaned = strip_emoji(str(name))
    for suffix in suffixes or []:
        if cleaned.endswith(suffix):
            cleaned = cleaned[: -len(suffix)]
            break
    return cleaned.strip()


def contribution_abs(row: pd.Series) -> float:
    value = row.get("对整体变化值贡献率")
    if pd.isna(value):
        return 0.0
    return abs(float(value))


def should_display(row: pd.Series, df: pd.DataFrame, threshold: float) -> bool:
    if contribution_abs(row) >= threshold:
        return True

    level = str(row["层级"])
    for _, candidate in df.iterrows():
        child_level = str(candidate["层级"])
        if is_ancestor(level, child_level) and contribution_abs(candidate) >= threshold:
            return True
    return False


def get_display_children(level: str, df: pd.DataFrame, threshold: float) -> list[pd.Series]:
    children: list[pd.Series] = []
    parent_depth = get_level_depth(level)
    for _, row in df.iterrows():
        child_level = str(row["层级"])
        if not is_ancestor(level, child_level):
            continue
        if get_level_depth(child_level) != parent_depth + 1:
            continue
        if should_display(row, df, threshold):
            children.append(row)
    return sorted(children, key=contribution_abs, reverse=True)


def generate_drilldown_line(
    row: pd.Series,
    prefix: str = "",
    overall_wow_pct: float | None = None,
    is_first_level_breakdown: bool = False,
    metric_suffixes: list[str] | None = None,
    first_level_contrib_label: str = "整体环比",
) -> str:
    metric_name = clean_metric_name(str(row["指标"]), metric_suffixes)
    contrib_value = row["对整体变化值贡献率"] if not pd.isna(row["对整体变化值贡献率"]) else 0
    if contrib_value < 0:
        metric_name = "*反向提拉* " + metric_name

    wow_pct = row["wow%"] if not pd.isna(row["wow%"]) else 0
    contrib_pct = row["对整体变化率贡献"] if not pd.isna(row["对整体变化率贡献"]) else 0

    if is_first_level_breakdown and overall_wow_pct is not None:
        return (
            f"{prefix}{metric_name}，环比{format_percent(wow_pct)}，"
            f"贡献{first_level_contrib_label}{format_percent(overall_wow_pct)}的"
            f"{format_percent(contrib_pct)}（占比{format_percent(contrib_value)}）"
        )

    return (
        f"{prefix}{metric_name}，环比{format_percent(wow_pct)}，"
        f"贡献{format_percent(contrib_pct)}（{format_percent(contrib_value)}）"
    )


def generate_dimension_drilldown(
    df: pd.DataFrame,
    root_level: str = "1",
    threshold: float = THRESHOLD,
    overall_wow_pct: float | None = None,
    metric_suffixes: list[str] | None = None,
    first_level_contrib_label: str = "整体环比",
) -> str:
    lines: list[str] = []

    def drill_down(level: str, prefix: str = "", is_first_level: bool = False) -> None:
        children = get_display_children(level, df, threshold)
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
                    first_level_contrib_label=first_level_contrib_label,
                )
            )
            if get_display_children(str(child["层级"]), df, threshold):
                next_prefix = prefix + ("    " if is_last else "│   ")
                drill_down(str(child["层级"]), next_prefix, is_first_level=False)

    drill_down(root_level, is_first_level=True)
    return "\n".join(line for line in lines if line)


def generate_formula_drilldown(
    df: pd.DataFrame,
    root_levels: list[str],
    branch_labels: list[str],
    formula: str,
    threshold: float = THRESHOLD,
    overall_wow_pct: float | None = None,
    metric_suffixes: list[str] | None = None,
    first_level_contrib_label: str = "整体环比",
) -> str:
    lines = [formula]

    def drill_down(
        level: str,
        prefix: str = "",
        is_last: bool = False,
        is_first_level: bool = False,
    ) -> None:
        row_df = df[df["层级"] == level]
        if not row_df.empty:
            lines.append(
                generate_drilldown_line(
                    row_df.iloc[0],
                    prefix,
                    overall_wow_pct=overall_wow_pct,
                    is_first_level_breakdown=is_first_level,
                    metric_suffixes=metric_suffixes,
                    first_level_contrib_label=first_level_contrib_label,
                )
            )

        children = get_display_children(level, df, threshold)
        for child_idx, child in enumerate(children):
            child_is_last = child_idx == len(children) - 1
            if prefix:
                child_prefix = (
                    prefix[:-4]
                    + ("    " if is_last else "│   ")
                    + ("└── " if child_is_last else "├── ")
                )
            else:
                child_prefix = "└── " if child_is_last else "├── "
            drill_down(
                str(child["层级"]),
                child_prefix,
                child_is_last,
                is_first_level=False,
            )

    for idx, level in enumerate(root_levels):
        is_last_branch = idx == len(root_levels) - 1
        branch_prefix = "└── " if is_last_branch else "├── "
        lines.append(f"{branch_prefix}{branch_labels[idx]}")

        children = get_display_children(level, df, threshold)
        for child_idx, child in enumerate(children):
            child_is_last = child_idx == len(children) - 1
            spacer = "    " if is_last_branch else "│   "
            prefix = spacer + ("└── " if child_is_last else "├── ")
            drill_down(
                str(child["层级"]),
                prefix,
                child_is_last,
                is_first_level=True,
            )

    return "\n".join(line for line in lines if line)


def generate_multiplicative_save_drilldown(
    df: pd.DataFrame,
    factor_levels: list[str],
    factor_labels: list[str],
    formula: str,
    overall_wow_pct: float | None = None,
    first_level_contrib_label: str = "整体环比",
) -> str:
    lines = [formula]
    for idx, level in enumerate(factor_levels):
        row_df = df[df["层级"] == level]
        if row_df.empty:
            continue
        prefix = "└── " if idx == len(factor_levels) - 1 else "├── "
        lines.append(
            generate_drilldown_line(
                row_df.iloc[0],
                prefix,
                overall_wow_pct=overall_wow_pct,
                is_first_level_breakdown=True,
                first_level_contrib_label=first_level_contrib_label,
            )
        )
    return "\n".join(line for line in lines if line)


def generate_function_volatility_section(
    df: pd.DataFrame,
    threshold: float = 5.0,
) -> str:
    feature_rows = df[
        df["层级"].astype(str).str.match(r"^3\.[^.]+$")
        & df["wow%"].notna()
        & (df["wow%"].abs() > threshold)
    ].copy()
    if feature_rows.empty:
        return ""

    feature_rows = feature_rows.assign(_abs_wow=feature_rows["wow"].abs()).sort_values(
        "_abs_wow", ascending=False
    )
    lines: list[str] = []
    for idx, (_, row) in enumerate(feature_rows.iterrows()):
        metric_name = clean_metric_name(str(row["指标"]))
        wow_pct = row["wow%"] if not pd.isna(row["wow%"]) else 0
        prev_value = row["上周"]
        curr_value = row["本周"]
        prefix = "└── " if idx == len(feature_rows) - 1 else "├── "
        lines.append(
            f"{prefix}{metric_name}，环比{format_percent(wow_pct)}"
            f"（{format_rate_value(prev_value)} --> {format_rate_value(curr_value)}）"
        )
    return "\n".join(lines)


def load_contribution(input_file: Path) -> pd.DataFrame:
    if not input_file.exists():
        raise FileNotFoundError(f"未找到输入文件: {input_file}")

    df = pd.read_csv(input_file, encoding="utf-8-sig")
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

    report_type = config.get("report_type", "dimension")
    common_kwargs = {
        "threshold": THRESHOLD,
        "overall_wow_pct": wow_pct,
        "metric_suffixes": config.get("metric_suffixes"),
        "first_level_contrib_label": config.get("first_level_contrib_label", "整体环比"),
    }

    if report_type == "dual_factor":
        rate_df = df[df["层级"].str.match(r"^1(\.|$)")].copy()
        uv_df = df[df["层级"].str.match(r"^2(\.|$)")].copy()
        drilldown = generate_formula_drilldown(
            pd.concat([rate_df, uv_df]),
            ["1", "2"],
            config["branch_labels"],
            config["formula"],
            **common_kwargs,
        )
        section_title = "## 关联下钻"
        extra_section = ""
    elif report_type == "multiplicative_save":
        drilldown = generate_multiplicative_save_drilldown(
            df,
            config["factor_levels"],
            config["factor_labels"],
            config["formula"],
            overall_wow_pct=wow_pct,
            first_level_contrib_label=config.get("first_level_contrib_label", "整体环比"),
        )
        section_title = "## 关联下钻"
        volatility = generate_function_volatility_section(
            df,
            threshold=config.get("volatility_threshold", 5.0),
        )
        extra_section = f"\n\n## 功能保存率波动\n{volatility}" if volatility else ""
    else:
        drilldown = generate_dimension_drilldown(df, "1", **common_kwargs)
        section_title = "## 维度下钻"
        extra_section = ""

    report = f"""# {config['title']}

{phenomenon}

{section_title}
{drilldown}{extra_section}

"""
    output_file = config["output_file"]
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(report, encoding="utf-8")
    print(f"报告已生成：{output_file}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="导出 AI 周报下钻分析 Markdown")
    parser.add_argument(
        "--metric",
        choices=["dau", "dnu", "retention", "new_retention", "bookings", "save", "all"],
        default="all",
        help="指定生成的报告（默认 all）",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    metrics = (
        ["dau", "dnu", "retention", "new_retention", "bookings", "save"]
        if args.metric == "all"
        else [args.metric]
    )
    for metric_key in metrics:
        generate_report(REPORT_CONFIGS[metric_key])


if __name__ == "__main__":
    main()

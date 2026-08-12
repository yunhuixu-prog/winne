#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 周报 v1 Markdown。

输入：
  - output/下钻报告/{dau,dnu,bookings,retention,new_retention,save}下钻分析报告.md
  - output/异常指标检测.md（不存在或指定 --run-s5 时会先运行 s5异常检测.py）
  - raw_data/{dau,dnu,bookings,retention,new_retention,save}.csv
  - memory/业务双周会周报框架.md

输出：
  - output/weekly_report_v1.md

说明：
  主体结构参考历史「业务双周会数据同步」文档，保留 OKR/业务动态等无法
  从当前流水线自动生成的章节占位，并将下钻归因与异常检测作为附录合并。
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]
SCRIPT_DIR = Path(__file__).resolve().parent
RAW_DATA_DIR = BASE_DIR / "raw_data"
MEMORY_DIR = BASE_DIR / "memory"
FRAMEWORK_FILE = MEMORY_DIR / "业务双周会周报框架.md"
S5_SCRIPT = SCRIPT_DIR / "s5异常检测.py"


def resolve_output_dir() -> Path:
    env = os.environ.get("ZHOUBAO_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output"


OUTPUT_DIR = resolve_output_dir()
DRILLDOWN_DIR = OUTPUT_DIR / "下钻报告"
ANOMALY_FILE = OUTPUT_DIR / "异常指标检测.md"
DEFAULT_OUTPUT_FILE = OUTPUT_DIR / "weekly_report_v1.md"

CORE_COUNTRIES = ["美国", "巴西", "英国"]


@dataclass(frozen=True)
class ReportSpec:
    key: str
    title: str
    file_name: str


REPORT_SPECS = [
    ReportSpec("dau", "DAU", "dau下钻分析报告.md"),
    ReportSpec("dnu", "DNU", "dnu下钻分析报告.md"),
    ReportSpec("bookings", "订阅毛利", "bookings下钻分析报告.md"),
    ReportSpec("retention", "活跃次留", "retention下钻分析报告.md"),
    ReportSpec("new_retention", "新增次留", "new_retention下钻分析报告.md"),
    ReportSpec("save", "保存量", "save下钻分析报告.md"),
]

SAVE_OVERALL_FILTERS = {
    "渠道自然": "整体",
    "国家": "整体",
    "平台": "整体",
    "新老": "整体",
    "付费状态": "整体",
    "版本": "整体",
    "一级功能": "整体",
    "二级功能": "整体",
}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def load_csv(file_name: str) -> pd.DataFrame:
    path = RAW_DATA_DIR / file_name
    if not path.exists():
        raise FileNotFoundError(f"源数据不存在: {path}")
    df = pd.read_csv(path, encoding="utf-8-sig")
    if "日期" not in df.columns:
        raise ValueError(f"{path} 缺少必要字段: 日期")
    df = df.copy()
    df["__日期__"] = pd.to_datetime(df["日期"], errors="coerce").dt.normalize()
    return df[df["__日期__"].notna()]


def all_week_starts() -> list[pd.Timestamp]:
    dates: set[pd.Timestamp] = set()
    for file_name in [
        "dau.csv",
        "dnu.csv",
        "bookings.csv",
        "retention.csv",
        "new_retention.csv",
        "save.csv",
    ]:
        df = load_csv(file_name)
        dates.update(pd.Timestamp(d).normalize() for d in df["__日期__"].dropna().unique())
    weeks = sorted(dates)
    # 历史周期：截断到 ZHOUBAO_TARGET_WEEK（含）为止，避免用更新的周当「本周」
    import sys

    _scripts = Path(__file__).resolve().parents[1]
    if str(_scripts) not in sys.path:
        sys.path.insert(0, str(_scripts))
    from skill_paths import target_week_start

    target = target_week_start()
    if target is not None:
        target = pd.Timestamp(target).normalize()
        weeks = [d for d in weeks if d <= target]
        if not weeks:
            raise ValueError(f"ZHOUBAO_TARGET_WEEK={target.date()} 在 raw_data 中无可用周")
    return weeks


def latest_report_date(week_start: pd.Timestamp) -> str:
    # 历史双周会通常在周结束后的周二同步。
    report_date = pd.Timestamp(week_start) + pd.Timedelta(days=8)
    return report_date.strftime("%Y%m%d")


def week_label(week_start: pd.Timestamp) -> str:
    week_end = pd.Timestamp(week_start) + pd.Timedelta(days=6)
    return f"{week_start:%m%d}-{week_end:%m%d}"


def apply_filters(df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    result = df
    for col, value in filters.items():
        if col not in result.columns:
            raise ValueError(f"源数据缺少筛选字段: {col}")
        result = result[result[col].astype(str) == value]
    return result


def weekly_sum_value(
    df: pd.DataFrame,
    week: pd.Timestamp,
    value_col: str,
    filters: dict[str, str],
) -> float | None:
    filtered = apply_filters(df, filters)
    rows = filtered[filtered["__日期__"] == week]
    if rows.empty or value_col not in rows.columns:
        return None
    values = pd.to_numeric(rows[value_col], errors="coerce")
    if values.notna().sum() == 0:
        return None
    return float(values.sum())


def weekly_rate_value(
    df: pd.DataFrame,
    week: pd.Timestamp,
    numerator_col: str,
    denominator_col: str,
    filters: dict[str, str],
) -> float | None:
    filtered = apply_filters(df, filters)
    rows = filtered[filtered["__日期__"] == week]
    if rows.empty:
        return None
    numerator = pd.to_numeric(rows[numerator_col], errors="coerce").sum()
    denominator = pd.to_numeric(rows[denominator_col], errors="coerce").sum()
    if pd.isna(denominator) or denominator == 0:
        return None
    return float(numerator / denominator)


def calc_wow(values: list[float | None]) -> float | None:
    if len(values) < 2 or values[-1] is None or values[-2] in (None, 0):
        return None
    return (values[-1] - values[-2]) / values[-2] * 100


def fmt_number(value: float | None, style: str = "int") -> str:
    if value is None or pd.isna(value):
        return "-"
    if style == "pct":
        return f"{value * 100:.2f}%"
    if style == "float":
        return f"{value:,.0f}"
    return f"{int(round(value)):,}"


def fmt_wow(value: float | None) -> str:
    if value is None or pd.isna(value):
        return "-"
    return f"{value:+.2f}%"


def format_delta(cur: float | None, prev: float | None, style: str = "int") -> str:
    if cur is None or prev is None:
        return "-"
    delta = cur - prev
    if style == "pct":
        return f"{delta * 100:+.2f}pp"
    if style == "float":
        return f"{delta:+,.0f}"
    return f"{int(round(delta)):+,}"


def build_metric_rows(weeks: list[pd.Timestamp]) -> list[dict[str, Any]]:
    dau = load_csv("dau.csv")
    dnu = load_csv("dnu.csv")
    bookings = load_csv("bookings.csv")
    retention = load_csv("retention.csv")
    new_retention = load_csv("new_retention.csv")
    save = load_csv("save.csv")

    row_defs: list[dict[str, Any]] = [
        {
            "name": "DAU",
            "style": "int",
            "df": dau,
            "value_col": "DAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "整体", "新老": "整体"},
        },
        {
            "name": "- DAU iOS",
            "style": "int",
            "df": dau,
            "value_col": "DAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "iOS", "新老": "整体"},
        },
        {
            "name": "- DAU Android",
            "style": "int",
            "df": dau,
            "value_col": "DAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "Android", "新老": "整体"},
        },
    ]

    for country in CORE_COUNTRIES:
        row_defs.append(
            {
                "name": f"- DAU {country}",
                "style": "int",
                "df": dau,
                "value_col": "DAU",
                "filters": {"渠道自然": "整体", "国家": country, "平台": "整体", "新老": "整体"},
            }
        )

    row_defs.extend(
        [
            {
                "name": "日均新增",
                "style": "int",
                "df": dnu,
                "value_col": "DNU",
                "filters": {"渠道自然": "整体", "国家": "整体", "平台": "整体"},
            },
            {
                "name": "- 自然新增",
                "style": "int",
                "df": dnu,
                "value_col": "DNU",
                "filters": {"渠道自然": "Organic", "国家": "整体", "平台": "整体"},
            },
            {
                "name": "- 渠道新增",
                "style": "int",
                "df": dnu,
                "value_col": "DNU",
                "filters": {"渠道自然": "non-Organic", "国家": "整体", "平台": "整体"},
            },
            {
                "name": "活跃次留",
                "style": "pct",
                "df": retention,
                "rate": True,
                "numerator_col": "次日留存人数",
                "denominator_col": "活跃用户数",
                "filters": {"渠道自然": "整体", "国家": "整体", "平台": "整体", "新老": "整体"},
            },
            {
                "name": "新增次留",
                "style": "pct",
                "df": new_retention,
                "rate": True,
                "numerator_col": "新增次日留存人数",
                "denominator_col": "DNU",
                "filters": {"渠道自然": "整体", "国家": "整体", "平台": "整体"},
            },
            {
                "name": "日均订阅毛利($，剔除退款)",
                "style": "float",
                "df": bookings,
                "value_col": "日均订阅毛利（剔除退款，$）",
                "filters": {"国家": "整体", "平台": "整体", "订阅类型": "整体"},
            },
            {
                "name": "- 新增毛利",
                "style": "float",
                "df": bookings,
                "value_col": "新增毛利",
                "filters": {"国家": "整体", "平台": "整体", "订阅类型": "整体"},
            },
            {
                "name": "- 续订毛利",
                "style": "float",
                "df": bookings,
                "value_col": "续订毛利",
                "filters": {"国家": "整体", "平台": "整体", "订阅类型": "整体"},
            },
            {
                "name": "保存量UV",
                "style": "int",
                "df": save,
                "value_col": "保存 UV",
                "filters": SAVE_OVERALL_FILTERS,
            },
        ]
    )

    rows: list[dict[str, Any]] = []
    for row_def in row_defs:
        if "values" in row_def:
            values = row_def["values"]
        elif row_def.get("rate"):
            values = [
                weekly_rate_value(
                    row_def["df"],
                    week,
                    row_def["numerator_col"],
                    row_def["denominator_col"],
                    row_def["filters"],
                )
                for week in weeks
            ]
        else:
            values = [
                weekly_sum_value(row_def["df"], week, row_def["value_col"], row_def["filters"])
                for week in weeks
            ]

        wow = calc_wow(values)
        rows.append(
            {
                "name": row_def["name"],
                "style": row_def["style"],
                "values": values,
                "wow": wow,
                "note": row_def.get("note") or auto_note(wow),
            }
        )
    return rows


def auto_note(wow: float | None) -> str:
    if wow is None:
        return "待补充"
    if abs(wow) < 3:
        return "正常波动"
    if wow > 0:
        return "上涨，需结合节日、投放或功能变化确认原因"
    return "下降，需结合下钻报告确认主要贡献项"


def build_detail_table(weeks: list[pd.Timestamp]) -> str:
    rows = build_metric_rows(weeks)
    headers = [week_label(week) for week in weeks]
    lines = [
        "| **指标** | "
        + " | ".join(f"**{h}**" for h in headers)
        + " | **本周环比上周** | **解读（文字+ 部分图趋势）** |",
        "|---|" + "---|" * (len(headers) + 2),
    ]
    for row in rows:
        value_cells = [fmt_number(value, row["style"]) for value in row["values"]]
        lines.append(
            f"| {row['name']} | "
            + " | ".join(value_cells)
            + f" | {fmt_wow(row['wow'])} | {row['note']} |"
        )
    return "\n".join(lines)


def extract_phenomenon(content: str) -> str:
    match = re.search(r"^现象：(.+)$", content, re.MULTILINE)
    return match.group(1).strip() if match else ""


def strip_tree_prefix(line: str) -> str:
    text = line.strip()
    text = re.sub(r"^[│\s]*[├└]──\s*", "", text)
    text = re.sub(r"\*\*", "", text)
    return text.strip()


def extract_top_drivers(content: str, limit: int = 3) -> list[str]:
    drivers: list[str] = []
    for raw_line in content.splitlines():
        line = raw_line.rstrip()
        if not re.match(r"^[│\s]*[├└]──", line):
            continue
        cleaned = strip_tree_prefix(line)
        if cleaned and "贡献" in cleaned:
            drivers.append(cleaned)
        if len(drivers) >= limit:
            break
    return drivers


def report_content_map() -> dict[str, str]:
    return {
        spec.key: read_text(DRILLDOWN_DIR / spec.file_name)
        for spec in REPORT_SPECS
    }


def build_summary_section(contents: dict[str, str]) -> str:
    def sentence(key: str, label: str) -> str:
        content = contents.get(key, "")
        phenomenon = extract_phenomenon(content) or f"{label}待补充"
        drivers = extract_top_drivers(content, limit=2)
        driver_text = "；主要下钻：" + "；".join(drivers) if drivers else ""
        return f"{phenomenon}{driver_text}。"

    lines = [
        "1、" + sentence("dau", "DAU"),
        "2、" + sentence("dnu", "DNU"),
        "3、" + sentence("bookings", "订阅毛利"),
        "4、" + sentence("save", "保存量"),
        "",
        "> 活跃次留和新增次留详见「四、核心指标数据详情」及「附录一、下钻和归因」。",
    ]
    return "\n".join(lines)


def build_business_placeholder() -> str:
    return "\n".join(
        [
            "**3.1 近期业务AB实验同步**",
            "",
            "> 当前流水线未接入本周实验、投放、功能上线等业务动态。本节保留历史周报结构，生成后请补充：",
            "",
            "1、【待补充：本周重点实验/需求】",
            "",
            "- 核心指标影响：待补充",
            "- 分端 / 分新老 / 分国家拆解：待补充",
            "- 后续：待补充",
        ]
    )


def run_s5_if_needed(force: bool) -> None:
    if not force and ANOMALY_FILE.exists():
        return
    if not S5_SCRIPT.exists():
        raise FileNotFoundError(f"未找到异常检测脚本: {S5_SCRIPT}")
    subprocess.run([sys.executable, str(S5_SCRIPT)], cwd=str(BASE_DIR), check=True)


def build_anomaly_section() -> str:
    content = read_text(ANOMALY_FILE).strip()
    if not content:
        return "未找到异常指标检测结果。"
    # 去掉原文件 H1，作为当前文档附录内容。
    return re.sub(r"^# .+\n\n?", "", content, count=1).strip()


def build_drilldown_appendix(contents: dict[str, str]) -> str:
    sections: list[str] = []
    for spec in REPORT_SPECS:
        content = contents.get(spec.key, "").strip()
        if not content:
            sections.append(f"## {spec.title}\n\n未找到 `{spec.file_name}`。")
            continue
        body = re.sub(r"^# .+\n\n?", "", content, count=1).strip()
        body = re.sub(r"^## ", "### ", body, flags=re.MULTILINE)
        sections.append(f"## {spec.title}\n\n{body}")
    return "\n\n---\n\n".join(sections)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 周报 v1 Markdown")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_FILE)
    parser.add_argument("--run-s5", action="store_true", help="生成周报前强制重新运行 s5异常检测.py")
    parser.add_argument("--detail-weeks", type=int, default=8, help="核心指标明细展示周数（与归因思路「二、下钻趋势表」近8周对齐）")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.detail_weeks < 2:
        raise ValueError("--detail-weeks 至少为 2")

    run_s5_if_needed(args.run_s5)

    weeks = all_week_starts()
    if len(weeks) < 2:
        raise ValueError("raw_data 中可用周数不足，无法生成周报")
    detail_weeks = weeks[-args.detail_weeks :]
    report_date = latest_report_date(detail_weeks[-1])
    year = pd.Timestamp(detail_weeks[-1]).year
    contents = report_content_map()
    framework_note = (
        f"> 生成框架参考 `{FRAMEWORK_FILE.relative_to(BASE_DIR)}`。"
        if FRAMEWORK_FILE.exists()
        else "> 生成框架文件未找到，使用脚本内置结构。"
    )

    lines = [
        f"# {report_date}日 业务双周会数据同步",
        "",
        framework_note,
        "",
        "---",
        "",
        f"### 一、{year}年OKR完成度",
        "",
        "> 本节依赖外部 OKR 数据源，当前 AI 周报流水线暂未自动生成。请按 `memory/业务双周会周报框架.md` 补充累计订阅毛利、MAU、完成度与口径备注。",
        "",
        "---",
        "",
        "### 二、本周数据小结",
        "",
        build_summary_section(contents),
        "",
        "---",
        "",
        "### 三、近期业务动态数据同步",
        "",
        build_business_placeholder(),
        "",
        "---",
        "",
        "### 四、核心指标数据详情",
        "",
        build_detail_table(detail_weeks),
        "",
        "---",
        "",
        "# 附录一、下钻和归因",
        "",
        build_drilldown_appendix(contents),
        "",
        "---",
        "",
        "# 附录二、异常指标检测",
        "",
        build_anomaly_section(),
        "",
    ]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines), encoding="utf-8")
    print(f"已生成: {args.output}")


if __name__ == "__main__":
    main()

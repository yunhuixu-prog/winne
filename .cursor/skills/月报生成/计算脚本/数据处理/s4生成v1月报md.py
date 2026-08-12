#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 月报 v1 Markdown。

输入：
  - output/下钻报告/{mau,bookings,valid_vip}下钻分析报告.md
  - output/异常指标检测.md（不存在或指定 --run-s5 时会先运行 s5异常检测.py）
  - raw_data/{mau,bookings,valid_vip}.csv
  - memory/月报框架.md

输出：
  - output/monthly_report_v1.md

说明：
  主体结构参考 memory/月报框架.md，保留 OKR/业务动态等无法从当前流水线
  自动生成的章节占位，并将下钻归因与异常检测作为附录合并。
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
FRAMEWORK_FILE = MEMORY_DIR / "月报框架.md"
S5_SCRIPT = SCRIPT_DIR / "s5异常检测.py"


def resolve_output_dir() -> Path:
    env = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output" / "_staging"


OUTPUT_DIR = resolve_output_dir()
DRILLDOWN_DIR = OUTPUT_DIR / "下钻报告"
ANOMALY_FILE = OUTPUT_DIR / "异常指标检测.md"
DEFAULT_OUTPUT_FILE = OUTPUT_DIR / "monthly_report_v1.md"

CORE_COUNTRIES = ["美国", "巴西", "英国"]


@dataclass(frozen=True)
class ReportSpec:
    key: str
    title: str
    file_name: str


REPORT_SPECS = [
    ReportSpec("mau", "MAU", "mau下钻分析报告.md"),
    ReportSpec("bookings", "订阅毛利", "bookings下钻分析报告.md"),
    ReportSpec("valid_vip", "月有效会员数", "valid_vip下钻分析报告.md"),
]


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


def all_month_starts() -> list[pd.Timestamp]:
    dates: set[pd.Timestamp] = set()
    for file_name in ["mau.csv", "bookings.csv", "valid_vip.csv"]:
        df = load_csv(file_name)
        dates.update(pd.Timestamp(d) for d in df["__日期__"].dropna().unique())
    return sorted(dates)


def month_label(month_start: pd.Timestamp) -> str:
    return pd.Timestamp(month_start).strftime("%Y-%m")


def apply_filters(df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    result = df
    for col, value in filters.items():
        if col not in result.columns:
            raise ValueError(f"源数据缺少筛选字段: {col}")
        result = result[result[col].astype(str) == value]
    return result


def monthly_sum_value(
    df: pd.DataFrame,
    month: pd.Timestamp,
    value_col: str,
    filters: dict[str, str],
) -> float | None:
    filtered = apply_filters(df, filters)
    rows = filtered[filtered["__日期__"] == month]
    if rows.empty or value_col not in rows.columns:
        return None
    values = pd.to_numeric(rows[value_col], errors="coerce")
    if values.notna().sum() == 0:
        return None
    return float(values.sum())


def calc_mom(values: list[float | None]) -> float | None:
    if len(values) < 2 or values[-1] is None or values[-2] in (None, 0):
        return None
    return (values[-1] - values[-2]) / values[-2] * 100


def fmt_number(value: float | None, style: str = "int") -> str:
    if value is None or pd.isna(value):
        return "-"
    if style == "pct":
        return f"{value * 100:.2f}%"
    if style == "float":
        return f"{value:,.2f}"
    return f"{int(round(value)):,}"


def fmt_mom(value: float | None) -> str:
    if value is None or pd.isna(value):
        return "-"
    return f"{value:+.2f}%"


def auto_note(mom: float | None) -> str:
    if mom is None:
        return "待补充"
    if abs(mom) < 3:
        return "正常波动"
    if mom > 0:
        return "上涨，需结合节日、投放或功能变化确认原因"
    return "下降，需结合下钻报告确认主要贡献项"


def build_metric_rows(months: list[pd.Timestamp]) -> list[dict[str, Any]]:
    mau = load_csv("mau.csv")
    bookings = load_csv("bookings.csv")
    valid_vip = load_csv("valid_vip.csv")

    row_defs: list[dict[str, Any]] = [
        {
            "name": "整体 MAU",
            "style": "int",
            "df": mau,
            "value_col": "MAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "整体", "新老": "整体"},
        },
        {
            "name": "- MAU iOS",
            "style": "int",
            "df": mau,
            "value_col": "MAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "iOS", "新老": "整体"},
        },
        {
            "name": "- MAU Android",
            "style": "int",
            "df": mau,
            "value_col": "MAU",
            "filters": {"渠道自然": "整体", "国家": "整体", "平台": "Android", "新老": "整体"},
        },
    ]

    for country in CORE_COUNTRIES:
        row_defs.append(
            {
                "name": f"- MAU {country}",
                "style": "int",
                "df": mau,
                "value_col": "MAU",
                "filters": {"渠道自然": "整体", "国家": country, "平台": "整体", "新老": "整体"},
            }
        )

    row_defs.extend(
        [
            {
                "name": "订阅毛利（剔除退款，$）",
                # 订阅毛利美元绝对金额取整、不写小数（见 memory/归因思路.md 术语库 7.1）
                "style": "int",
                "df": bookings,
                "value_col": "订阅毛利（剔除退款，$）",
                "filters": {"国家": "整体", "订阅类型": "整体"},
            },
            {
                "name": "- 新增毛利",
                "style": "int",
                "df": bookings,
                "value_col": "新增毛利",
                "filters": {"国家": "整体", "订阅类型": "整体"},
            },
            {
                "name": "- 续订毛利",
                "style": "int",
                "df": bookings,
                "value_col": "续订毛利",
                "filters": {"国家": "整体", "订阅类型": "整体"},
            },
            {
                "name": "整体月有效会员数",
                "style": "int",
                "df": valid_vip,
                "value_col": "月有效会员数",
                "filters": {"国家": "整体", "订阅类型": "整体"},
            },
        ]
    )

    rows: list[dict[str, Any]] = []
    for row_def in row_defs:
        values = [
            monthly_sum_value(row_def["df"], month, row_def["value_col"], row_def["filters"])
            for month in months
        ]
        mom = calc_mom(values)
        rows.append(
            {
                "name": row_def["name"],
                "style": row_def["style"],
                "values": values,
                "mom": mom,
                "note": auto_note(mom),
            }
        )
    return rows


def build_detail_table(months: list[pd.Timestamp]) -> str:
    rows = build_metric_rows(months)
    headers = [month_label(month) for month in months]
    lines = [
        "| **指标** | "
        + " | ".join(f"**{h}**" for h in headers)
        + " | **本月环比上月** | **解读（文字+ 部分图趋势）** |",
        "|---|" + "---|" * (len(headers) + 2),
    ]
    for row in rows:
        value_cells = [fmt_number(value, row["style"]) for value in row["values"]]
        lines.append(
            f"| {row['name']} | "
            + " | ".join(value_cells)
            + f" | {fmt_mom(row['mom'])} | {row['note']} |"
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
    return {spec.key: read_text(DRILLDOWN_DIR / spec.file_name) for spec in REPORT_SPECS}


def build_summary_section(contents: dict[str, str]) -> str:
    def sentence(key: str, label: str) -> str:
        content = contents.get(key, "")
        phenomenon = extract_phenomenon(content) or f"{label}待补充"
        drivers = extract_top_drivers(content, limit=2)
        driver_text = "；主要下钻：" + "；".join(drivers) if drivers else ""
        return f"{phenomenon}{driver_text}。"

    lines = [
        "1、" + sentence("mau", "MAU"),
        "2、" + sentence("bookings", "订阅毛利"),
        "3、" + sentence("valid_vip", "月有效会员数"),
    ]
    return "\n".join(lines)


def build_business_placeholder() -> str:
    return "\n".join(
        [
            "**3.1 近期业务动态同步**",
            "",
            "> 当前流水线未接入本月实验、投放、功能上线等业务动态。本节保留历史月报结构，生成后请补充：",
            "",
            "1、【待补充：本月重点实验/需求/版本发布】",
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
    env = os.environ.copy()
    env.setdefault("AI_MONTHLY_OUTPUT_DIR", str(OUTPUT_DIR))
    subprocess.run([sys.executable, str(S5_SCRIPT)], cwd=str(BASE_DIR), env=env, check=True)


def build_anomaly_section() -> str:
    content = read_text(ANOMALY_FILE).strip()
    if not content:
        return "未找到异常指标检测结果。"
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


def format_period_label(period: str, latest_month: pd.Timestamp) -> str:
    if period and re.fullmatch(r"\d{6}", period):
        year = int(period[:4])
        month = int(period[4:6])
        return f"{year}年{month:02d}月"
    return latest_month.strftime("%Y年%m月")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 月报 v1 Markdown")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_FILE)
    parser.add_argument("--run-s5", action="store_true", help="生成月报前强制重新运行 s5异常检测.py")
    parser.add_argument("--detail-months", type=int, default=6, help="核心指标明细展示月数")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.detail_months < 2:
        raise ValueError("--detail-months 至少为 2")

    run_s5_if_needed(args.run_s5)

    months = all_month_starts()
    if len(months) < 2:
        raise ValueError("raw_data 中可用月数不足，无法生成月报")
    detail_months = months[-args.detail_months :]
    period = os.environ.get("AI_MONTHLY_PERIOD", "").strip() or OUTPUT_DIR.name
    period_label = format_period_label(period, detail_months[-1])
    year = pd.Timestamp(detail_months[-1]).year
    contents = report_content_map()
    framework_note = (
        f"> 生成框架参考 `{FRAMEWORK_FILE.relative_to(BASE_DIR)}`。"
        if FRAMEWORK_FILE.exists()
        else "> 生成框架文件未找到，使用脚本内置结构。"
    )

    lines = [
        f"# AirBrush AI 月报 v1（{period_label}）",
        "",
        framework_note,
        "",
        "---",
        "",
        f"### 一、{year}年OKR完成度",
        "",
        "> 本节依赖外部 OKR 数据源，当前 AI 月报流水线暂未自动生成。请按 `memory/月报框架.md` 补充累计订阅毛利、MAU、完成度与口径备注。",
        "",
        "---",
        "",
        "### 二、本月数据小结",
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
        build_detail_table(detail_months),
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

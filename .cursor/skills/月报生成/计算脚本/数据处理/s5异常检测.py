#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 月报异常指标检测 Markdown。

输入：
  - raw_data/{mau,bookings,valid_vip}.csv

输出：
  - output/异常指标检测.md

说明：
  raw_data 中的数据已经是 MONTH + SUM 后的月度数据，日期字段表示每月第 1 天。
  异常判定规则与周报 skill/计算脚本/数据处理/s5异常检测.py 保持一致（3% / -3% / 5% 阈值）。
"""
from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import FETCH_MONTHS

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = BASE_DIR / "raw_data"


def resolve_output_dir() -> Path:
    env = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output" / "_staging"


OUTPUT_DIR = resolve_output_dir()
OUTPUT_FILE = OUTPUT_DIR / "异常指标检测.md"

DEFAULT_DISPLAY_MONTHS = 8
DEFAULT_HISTORY_MONTHS = FETCH_MONTHS


@dataclass(frozen=True)
class MetricSpec:
    name: str
    file_name: str
    filters: dict[str, str]
    fmt: str = "int"
    value_column: str | None = None
    numerator_column: str | None = None
    denominator_column: str | None = None


METRIC_SPECS: list[MetricSpec] = [
    MetricSpec(
        name="整体 MAU",
        file_name="mau.csv",
        value_column="MAU",
        filters={"渠道自然": "整体", "国家": "整体", "平台": "整体", "新老": "整体"},
    ),
    MetricSpec(
        name="订阅毛利（剔除退款，$）",
        file_name="bookings.csv",
        value_column="订阅毛利（剔除退款，$）",
        filters={"国家": "整体", "平台": "整体", "订阅类型": "整体"},
        fmt="float",
    ),
    MetricSpec(
        name="新增毛利",
        file_name="bookings.csv",
        value_column="新增毛利",
        filters={"国家": "整体", "平台": "整体", "订阅类型": "整体"},
        fmt="float",
    ),
    MetricSpec(
        name="续订毛利",
        file_name="bookings.csv",
        value_column="续订毛利",
        filters={"国家": "整体", "平台": "整体", "订阅类型": "整体"},
        fmt="float",
    ),
    MetricSpec(
        name="整体月有效会员数",
        file_name="valid_vip.csv",
        value_column="月有效会员数",
        filters={"国家": "整体", "订阅类型": "整体"},
    ),
]


def load_source(file_name: str) -> pd.DataFrame:
    path = RAW_DATA_DIR / file_name
    if not path.exists():
        raise FileNotFoundError(f"源数据不存在: {path}")

    df = pd.read_csv(path, encoding="utf-8-sig")
    if "日期" not in df.columns:
        raise ValueError(f"{path} 缺少必要字段: 日期")

    df = df.copy()
    df["__日期__"] = pd.to_datetime(df["日期"], errors="coerce").dt.normalize()
    df = df[df["__日期__"].notna()]
    return df


def apply_filters(df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    result = df
    for col, value in filters.items():
        if col not in result.columns:
            continue
        result = result[result[col].astype(str) == value]
    return result


def fetch_monthly(spec: MetricSpec, history_months: int) -> pd.DataFrame:
    """返回按月升序排列的 date/value 明细。"""
    source = apply_filters(load_source(spec.file_name), spec.filters)
    if source.empty:
        return pd.DataFrame(columns=["date", "value"])

    if spec.value_column:
        if spec.value_column not in source.columns:
            raise ValueError(f"{spec.file_name} 缺少指标字段: {spec.value_column}")
        source[spec.value_column] = pd.to_numeric(source[spec.value_column], errors="coerce")
        monthly = (
            source.groupby("__日期__", as_index=False)[spec.value_column]
            .sum(min_count=1)
            .rename(columns={"__日期__": "date", spec.value_column: "value"})
        )
    else:
        if not spec.numerator_column or not spec.denominator_column:
            raise ValueError(f"{spec.name} 未配置分子/分母字段")
        missing = {
            col
            for col in (spec.numerator_column, spec.denominator_column)
            if col not in source.columns
        }
        if missing:
            raise ValueError(f"{spec.file_name} 缺少指标字段: {sorted(missing)}")

        source[spec.numerator_column] = pd.to_numeric(
            source[spec.numerator_column], errors="coerce"
        )
        source[spec.denominator_column] = pd.to_numeric(
            source[spec.denominator_column], errors="coerce"
        )
        grouped = source.groupby("__日期__", as_index=False)[
            [spec.numerator_column, spec.denominator_column]
        ].sum(min_count=1)
        grouped["value"] = grouped[spec.numerator_column] / grouped[spec.denominator_column]
        monthly = grouped.rename(columns={"__日期__": "date"})[["date", "value"]]

    monthly = monthly.dropna(subset=["value"]).sort_values("date")
    return monthly.tail(history_months).reset_index(drop=True)


def make_month_label(month_start: pd.Timestamp) -> str:
    month_start = pd.Timestamp(month_start)
    return f"{month_start:%Y-%m}"


def calc_consec_decline(history: list[float]) -> int:
    if len(history) < 2:
        return 0

    recent = history[-8:]
    count = 0
    for i in range(len(recent) - 1, 0, -1):
        if recent[i] < recent[i - 1]:
            count += 1
        else:
            break
    return count


def is_history_low(history: list[float]) -> bool:
    if len(history) < 2:
        return False
    return history[-1] <= min(history)


def pre_3m_stable(history: list[float]) -> bool:
    if len(history) < 5:
        return False

    for i in range(len(history) - 4, len(history) - 1):
        prev = history[i - 1]
        if prev == 0:
            continue
        chg = abs((history[i] - prev) / prev * 100)
        if chg >= 3:
            return False
    return True


def detect_anomaly(display_vals: list[float], raw_hist: list[float], name: str) -> tuple[str, str]:
    if len(display_vals) < 2:
        return "稳定", ""

    cur = display_vals[-1]
    prev = display_vals[-2]
    mom_pct = (cur - prev) / prev * 100 if prev != 0 else 0.0
    abs_mom = abs(mom_pct)
    history_label = f"近{len(raw_hist)}月最低值"

    if mom_pct > 3:
        return "增长", ""
    if mom_pct > 0:
        return "稳定", ""

    consec = calc_consec_decline(display_vals)
    is_low = is_history_low(raw_hist)
    desc: list[str] = []

    if consec >= 2 and is_low:
        desc.append(f"{name}连续{consec + 1}月下跌且达{history_label}")
    elif consec >= 2:
        desc.append(f"{name}连续{consec + 1}月下跌")
    elif is_low:
        desc.append(f"{name}达{history_label}")

    if mom_pct > -3:
        if not desc:
            desc.append(f"{name}下跌，需关注")
        return "稳定", "；".join(desc)

    if not desc and pre_3m_stable(display_vals) and abs_mom > 5:
        desc.append(f"{name}连续三个月稳定后骤然下跌")
    if not desc:
        if abs_mom > 5:
            desc.append(f"{name}大幅下跌，需重点关注")
        else:
            desc.append(f"{name}跌幅异常，需关注")
    return "异常", "；".join(desc)


def fmt_value(value: float, fmt: str) -> str:
    if pd.isna(value):
        return "-"
    if fmt == "pct":
        return f"{float(value) * 100:.2f}%"
    if fmt == "float":
        return f"{float(value):,.2f}"
    return f"{int(round(float(value))):,}"


def fmt_pct(value: float) -> str:
    if pd.isna(value):
        return "-"
    return f"{float(value):+.2f}%"


def status_icon(status: str, mom: float) -> str:
    if status == "增长":
        return "🟢"
    if status == "异常":
        return "🔴"
    if status == "稳定":
        return "🟡" if mom <= 0 else "⚫"
    return ""


def build_report(display_months: int, history_months: int) -> str:
    rows: list[dict[str, Any]] = []
    month_dates: list[pd.Timestamp] = []

    for spec in METRIC_SPECS:
        monthly = fetch_monthly(spec, history_months)
        if len(monthly) < 2:
            continue

        display = monthly.tail(display_months)
        dates = [pd.Timestamp(d) for d in display["date"].tolist()]
        values = [float(v) for v in display["value"].tolist()]
        history_values = [float(v) for v in monthly["value"].tolist()]
        prev = values[-2]
        mom = (values[-1] - prev) / prev * 100 if prev != 0 else 0.0
        status, desc = detect_anomaly(values, history_values, spec.name)

        if len(dates) > len(month_dates):
            month_dates = dates

        rows.append(
            {
                "name": spec.name,
                "fmt": spec.fmt,
                "dates": dates,
                "values": values,
                "mom": mom,
                "status": status,
                "desc": desc,
            }
        )

    if not rows:
        return "# 异常指标检测\n\n未找到可用于异常检测的数据。"

    labels = [make_month_label(d) for d in month_dates]
    title_months = len(labels)
    table = "| 指标 | " + " | ".join(labels) + " | 月环比变化 | 指标状态 | 异常说明 |\n"
    table += "|" + "---|" * (title_months + 4) + "\n"

    for row in rows:
        value_by_date = dict(zip(row["dates"], row["values"]))
        line = f"| **{row['name']}** |"
        for date in month_dates:
            value = value_by_date.get(date, pd.NA)
            line += f" {fmt_value(value, row['fmt'])} |"
        line += f" {fmt_pct(row['mom'])} |"
        line += f" {status_icon(row['status'], row['mom'])} |"
        line += f" {row['desc'] if row['desc'] else '-'} |\n"
        table += line

    note = (
        "*说明：环比增长超过3%为🟢增长(绿色)，环比变化在0~3%(不含0%，含3%)为⚫稳定(黑色)，"
        "环比变化在0~-3%(含0%，不含-3%)为🟡稳定(黄色)，环比下跌超过3%(含-3%)为🔴异常(红色)。"
        f"最低值判断基于当前源数据可用的最近最多{history_months}月历史。*"
    )
    return f"# 异常指标检测（近{title_months}月）\n\n{table}\n{note}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 月报异常指标检测 Markdown")
    parser.add_argument("--display-months", type=int, default=DEFAULT_DISPLAY_MONTHS)
    parser.add_argument("--history-months", type=int, default=DEFAULT_HISTORY_MONTHS)
    parser.add_argument("--output", type=Path, default=OUTPUT_FILE)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.display_months < 2:
        raise ValueError("--display-months 至少为 2")
    if args.history_months < args.display_months:
        raise ValueError("--history-months 不能小于 --display-months")

    print("生成异常指标检测MD文档...")
    md = build_report(args.display_months, args.history_months)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(md, encoding="utf-8")
    print(f"异常指标检测: {args.output} ({args.output.stat().st_size / 1024:.1f} KB)")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 月报贡献度 CSV。

加法贡献度（mau / bookings）：
  - 对整体变化绝对值贡献 = mom
  - 对整体变化值贡献率 = mom / 整体 mom
  - 对整体变化率贡献 = mom / 整体上月值

月有效会员数（valid_vip）加法贡献度，带符号：
  本月有效会员数 = 上月有效会员数 + 本月新增订阅会员数 - 月流失订阅会员数
  环比变化 Δ有效 ≈ Δ上月有效 + 本月新增 - 月流失
  - 1.1（上月有效，整体）：正向，绝对值贡献 = mom；1.1.x 国家层不参与环比贡献
  - 1.2 / 1.2.x（本月新增）：正向，绝对值贡献 = mom
  - 1.3 / 1.3.x（月流失）：负向，绝对值贡献 = -mom
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import FETCH_MONTHS

BASE_DIR = Path(__file__).resolve().parents[2]


def resolve_output_dir() -> Path:
    env = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if env:
        path = Path(env)
        return path if path.is_absolute() else BASE_DIR / path
    return BASE_DIR / "output" / "_staging"


OUTPUT_DIR = resolve_output_dir()
S1_OUTPUT_DIR = OUTPUT_DIR / "下钻"
S2_OUTPUT_DIR = OUTPUT_DIR / "贡献度"
MONTH_COLUMNS = ["本月", "上月"] + [f"{i}月前" for i in range(2, FETCH_MONTHS)]

METRIC_CONFIGS: dict[str, dict[str, Any]] = {
    "mau": {
        "input_file": S1_OUTPUT_DIR / "s1_mau下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_mau贡献度.csv",
        "attribution": "additive",
    },
    "bookings": {
        "input_file": S1_OUTPUT_DIR / "s1_bookings下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_bookings贡献度.csv",
        "attribution": "additive",
    },
    "valid_vip": {
        "input_file": S1_OUTPUT_DIR / "s1_valid_vip下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_valid_vip贡献度.csv",
        "attribution": "valid_vip_additive",
    },
}


def sort_level_key(level: str) -> tuple:
    tokens = []
    for part in str(level).split("."):
        tokens.append((0, int(part)) if part.isdigit() else (1, part))
    return tuple(tokens)


def ensure_numeric(df: pd.DataFrame) -> None:
    for col in [*MONTH_COLUMNS, "mom", "mom%"]:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")


def contribution_columns(
    signed_mom: float | None,
    overall_mom: float,
    overall_prev: float,
) -> tuple[Any, Any, Any]:
    if signed_mom is None or pd.isna(signed_mom):
        return pd.NA, pd.NA, pd.NA
    abs_contrib = round(float(signed_mom), 6)
    share_contrib = (
        round(signed_mom / overall_mom * 100, 6)
        if not pd.isna(overall_mom) and overall_mom != 0
        else pd.NA
    )
    rate_contrib = (
        round(signed_mom / overall_prev * 100, 6)
        if not pd.isna(overall_prev) and overall_prev != 0
        else pd.NA
    )
    return abs_contrib, share_contrib, rate_contrib


def add_additive_contribution_columns(df: pd.DataFrame) -> pd.DataFrame:
    overall = df.loc[df["层级"].astype(str) == "1"]
    if overall.empty:
        raise ValueError("未找到层级=1 的整体行")

    overall_mom = float(overall["mom"].iloc[0])
    overall_prev = float(overall["上月"].iloc[0])
    abs_col, share_col, rate_col = [], [], []
    for _, row in df.iterrows():
        abs_val, share_val, rate_val = contribution_columns(row["mom"], overall_mom, overall_prev)
        abs_col.append(abs_val)
        share_col.append(share_val)
        rate_col.append(rate_val)

    result = df.copy()
    result["对整体变化绝对值贡献"] = abs_col
    result["对整体变化值贡献率"] = share_col
    result["对整体变化率贡献"] = rate_col
    return result


def valid_vip_signed_mom(level: str, mom: float | None) -> float | None:
    """月有效会员数流动分解：上月有效/新增正向，流失负向；1.1.x 国家层不参与贡献。"""
    if mom is None or pd.isna(mom):
        return None
    level_s = str(level).strip()
    if level_s.startswith("1.1."):
        return None
    if level_s == "1.1":
        return float(mom)
    if level_s.startswith("1.3"):
        return -float(mom)
    if level_s.startswith("1.2"):
        return float(mom)
    return float(mom)


def add_valid_vip_additive_contribution_columns(df: pd.DataFrame) -> pd.DataFrame:
    overall = df.loc[df["层级"].astype(str) == "1"]
    if overall.empty:
        raise ValueError("未找到层级=1 的整体月有效会员数行")

    overall_mom = float(overall["mom"].iloc[0])
    overall_prev = float(overall["上月"].iloc[0])
    abs_col, share_col, rate_col = [], [], []
    for _, row in df.iterrows():
        signed = valid_vip_signed_mom(str(row["层级"]), row["mom"])
        abs_val, share_val, rate_val = contribution_columns(signed, overall_mom, overall_prev)
        abs_col.append(abs_val)
        share_col.append(share_val)
        rate_col.append(rate_val)

    result = df.copy()
    result["对整体变化绝对值贡献"] = abs_col
    result["对整体变化值贡献率"] = share_col
    result["对整体变化率贡献"] = rate_col
    return result


def process_metric(config: dict[str, Any]) -> pd.DataFrame:
    df = pd.read_csv(config["input_file"], encoding="utf-8-sig")
    ensure_numeric(df)
    attribution = config.get("attribution", "additive")
    if attribution == "valid_vip_additive":
        df = add_valid_vip_additive_contribution_columns(df)
    else:
        df = add_additive_contribution_columns(df)
    return df.sort_values("层级", key=lambda s: s.map(sort_level_key))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 月报贡献度 CSV")
    parser.add_argument(
        "--metric",
        choices=list(METRIC_CONFIGS.keys()),
        action="append",
        help="仅处理指定指标，可重复指定",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    S2_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    keys = args.metric or list(METRIC_CONFIGS.keys())
    for key in keys:
        config = METRIC_CONFIGS[key]
        df = process_metric(config)
        df.to_csv(config["output_file"], index=False, encoding="utf-8-sig")
        print(f"已生成 {key}: {config['output_file']} ({len(df)} 行)")


if __name__ == "__main__":
    main()

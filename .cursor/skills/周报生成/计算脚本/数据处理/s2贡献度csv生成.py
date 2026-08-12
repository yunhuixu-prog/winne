#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AI 周报贡献度 CSV。

参考 `参考文档/分析下钻报告实现过程/计算脚本/2数据处理/s2贡献度csv生成.py`
中的贡献度逻辑。

加法贡献度：
  - 对整体变化绝对值贡献 = 当前行 wow
  - 对整体变化值贡献率 = 当前行 wow / 整体 wow
  - 对整体变化率贡献 = 当前行 wow / 整体上周值

双因子贡献度：
  - 1 系列：留存率变化贡献
  - 2 系列：UV 占比结构变化贡献

乘法贡献度（Save）：
  - 保存量 = DAU × 保存率，对层级 1/2/3 使用 LMDI 归因
  - 3.x 功能保存率行不计算贡献度

输入：
  - output/下钻/s1_dau下钻.csv → output/贡献度/s2_dau贡献度.csv
  - output/下钻/s1_dnu下钻.csv → output/贡献度/s2_dnu贡献度.csv
  - output/下钻/s1_bookings下钻.csv → output/贡献度/s2_bookings贡献度.csv
  - output/下钻/s1_retention下钻.csv → output/贡献度/s2_retention贡献度.csv
  - output/下钻/s1_new_retention下钻.csv → output/贡献度/s2_new_retention贡献度.csv
  - output/下钻/s1_save下钻.csv → output/贡献度/s2_save贡献度.csv
"""
from __future__ import annotations

import argparse
import math
import os
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
S1_OUTPUT_DIR = OUTPUT_DIR / "下钻"
S2_OUTPUT_DIR = OUTPUT_DIR / "贡献度"

WEEK_COLUMNS = ["本周", "上周", "2周前", "3周前", "4周前", "5周前", "6周前", "7周前"]

METRIC_CONFIGS: dict[str, dict[str, Any]] = {
    "dau": {
        "name": "DAU",
        "input_file": S1_OUTPUT_DIR / "s1_dau下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_dau贡献度.csv",
        "attribution": "additive",
    },
    "dnu": {
        "name": "DNU",
        "input_file": S1_OUTPUT_DIR / "s1_dnu下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_dnu贡献度.csv",
        "attribution": "additive",
    },
    "bookings": {
        "name": "Bookings",
        "input_file": S1_OUTPUT_DIR / "s1_bookings下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_bookings贡献度.csv",
        "attribution": "additive",
    },
    "retention": {
        "name": "Retention",
        "input_file": S1_OUTPUT_DIR / "s1_retention下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_retention贡献度.csv",
        "attribution": "dual_factor",
    },
    "new_retention": {
        "name": "New Retention",
        "input_file": S1_OUTPUT_DIR / "s1_new_retention下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_new_retention贡献度.csv",
        "attribution": "dual_factor",
    },
    "save": {
        "name": "Save",
        "input_file": S1_OUTPUT_DIR / "s1_save下钻.csv",
        "output_file": S2_OUTPUT_DIR / "s2_save贡献度.csv",
        "attribution": "multiplicative_save",
    },
}


def ensure_numeric(df: pd.DataFrame, cols: list[str]) -> None:
    for col in cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")


def sort_level_key(level: str) -> tuple:
    tokens = []
    for part in str(level).split("."):
        if part.isdigit():
            tokens.append((0, int(part)))
        else:
            tokens.append((1, part))
    return tuple(tokens)


def add_additive_contribution_columns(df: pd.DataFrame) -> tuple[pd.DataFrame, float, float]:
    """加法归因：wow 即绝对值贡献。"""
    overall = df.loc[df["层级"].astype(str) == "1"]
    if overall.empty:
        raise ValueError("未找到层级=1 的整体行")

    overall_wow = overall["wow"].iloc[0]
    overall_prev = overall["上周"].iloc[0]

    abs_list, share_list, rate_list = [], [], []
    for _, row in df.iterrows():
        wow = row["wow"]
        if pd.isna(wow):
            abs_list.append(pd.NA)
            share_list.append(pd.NA)
            rate_list.append(pd.NA)
            continue

        abs_contrib = wow
        share_contrib = (
            wow / overall_wow * 100
            if not pd.isna(overall_wow) and overall_wow != 0
            else pd.NA
        )
        rate_contrib = (
            wow / overall_prev * 100
            if not pd.isna(overall_prev) and overall_prev != 0
            else pd.NA
        )

        abs_list.append(round(abs_contrib, 6))
        share_list.append(round(share_contrib, 6) if not pd.isna(share_contrib) else pd.NA)
        rate_list.append(round(rate_contrib, 6) if not pd.isna(rate_contrib) else pd.NA)

    df = df.copy()
    df["对整体变化绝对值贡献"] = abs_list
    df["对整体变化值贡献率"] = share_list
    df["对整体变化率贡献"] = rate_list
    return df, float(overall_wow), float(overall_prev)


def is_direct_child(parent: str, child: str) -> bool:
    return child.startswith(parent + ".") and child.count(".") == parent.count(".") + 1


def _multiplicative_attribution(
    value_b_1: float,
    value_b_2: float,
    value_a_1: float,
    value_a_2: float,
) -> tuple[float, float]:
    """乘法归因 LMDI：整体 = factor1 × factor2。"""
    if any(pd.isna(v) or v <= 0 for v in [value_b_1, value_b_2, value_a_1, value_a_2]):
        return float("nan"), float("nan")

    overall_b = value_b_1 * value_b_2
    overall_a = value_a_1 * value_a_2
    delta_overall = overall_a - overall_b
    if math.isclose(delta_overall, 0, abs_tol=1e-12):
        return 0.0, 0.0

    log_diff = math.log(overall_a) - math.log(overall_b)
    if math.isclose(log_diff, 0, abs_tol=1e-12):
        scale = 0.0
    else:
        scale = delta_overall / log_diff

    contrib_1 = scale * (math.log(value_a_1) - math.log(value_b_1))
    contrib_2 = scale * (math.log(value_a_2) - math.log(value_b_2))
    return contrib_1, contrib_2


def add_multiplicative_save_contribution_columns(df: pd.DataFrame) -> tuple[pd.DataFrame, float, float]:
    """保存量 = DAU × 保存率，对层级 1/2/3 做 LMDI 归因。"""
    rows = {str(row["层级"]).strip(): row for _, row in df.iterrows()}
    if "1" not in rows or "2" not in rows or "3" not in rows:
        raise ValueError("Save 归因未找到层级 1/2/3 行")

    overall_wow = float(rows["1"]["wow"])
    overall_wow_pct = float(rows["1"]["wow%"])
    overall_prev = float(rows["1"]["上周"])

    dau_contrib, rate_contrib = _multiplicative_attribution(
        float(rows["2"]["上周"]),
        float(rows["3"]["上周"]),
        float(rows["2"]["本周"]),
        float(rows["3"]["本周"]),
    )

    contrib: dict[str, tuple[float, float, float]] = {
        "1": (overall_wow, 100.0, overall_wow_pct),
    }
    if not pd.isna(dau_contrib) and not pd.isna(overall_wow) and overall_wow != 0:
        dau_share = dau_contrib / overall_wow * 100
        contrib["2"] = (round(dau_contrib, 6), round(dau_share, 6), round(dau_share / 100 * overall_wow_pct, 6))
    if not pd.isna(rate_contrib) and not pd.isna(overall_wow) and overall_wow != 0:
        rate_share = rate_contrib / overall_wow * 100
        contrib["3"] = (round(rate_contrib, 6), round(rate_share, 6), round(rate_share / 100 * overall_wow_pct, 6))

    abs_col, share_col, rate_col = [], [], []
    for _, row in df.iterrows():
        code = str(row["层级"]).strip()
        if code in contrib:
            abs_value, share_value, rate_value = contrib[code]
        else:
            abs_value = share_value = rate_value = pd.NA
        abs_col.append(abs_value)
        share_col.append(share_value)
        rate_col.append(rate_value)

    df = df.copy()
    df["对整体变化绝对值贡献"] = abs_col
    df["对整体变化值贡献率"] = share_col
    df["对整体变化率贡献"] = rate_col
    return df, overall_wow, overall_prev


def add_dual_factor_contribution_columns(df: pd.DataFrame) -> tuple[pd.DataFrame, float, float]:
    """双因子归因：留存率变化贡献 + UV 占比结构变化贡献。"""
    rate_rows: dict[str, pd.Series] = {}
    uv_rows: dict[str, pd.Series] = {}
    for _, row in df.iterrows():
        code = str(row["层级"]).strip()
        if code.startswith("1"):
            rate_rows[code] = row
        elif code.startswith("2"):
            uv_rows[code] = row

    if "1" not in rate_rows:
        raise ValueError("未找到层级=1 的整体留存率行")
    if "2" not in uv_rows:
        raise ValueError("未找到层级=2 的整体 UV 行")

    overall_wow = rate_rows["1"]["wow"]
    overall_wow_pct = rate_rows["1"]["wow%"]
    uv_total_prev = uv_rows["2"]["上周"]
    uv_total_cur = uv_rows["2"]["本周"]
    overall_prev_rate = rate_rows["1"]["上周"]

    contrib_rate: dict[str, tuple] = {"1": (overall_wow, 100.0, overall_wow_pct)}
    contrib_uv: dict[str, tuple] = {"2": (0.0, 0.0, 0.0)}

    rate_codes = sorted(rate_rows.keys(), key=lambda c: (c.count("."), c))
    for parent_code in rate_codes:
        children = [c for c in rate_codes if is_direct_child(parent_code, c)]
        if not children:
            continue

        group = []
        for child_code in children:
            uv_child_code = "2" + child_code[1:]
            uv_child = uv_rows.get(uv_child_code)
            if uv_child is None:
                continue

            prev_rate = rate_rows[child_code]["上周"]
            cur_rate = rate_rows[child_code]["本周"]
            prev_uv = uv_child["上周"]
            cur_uv = uv_child["本周"]

            if any(pd.isna(v) for v in [prev_rate, cur_rate, prev_uv, cur_uv]):
                continue
            if uv_total_prev == 0 or uv_total_cur == 0:
                continue

            group.append(
                {
                    "rate_code": child_code,
                    "uv_code": uv_child_code,
                    "prev_rate": prev_rate,
                    "cur_rate": cur_rate,
                    "prev_share": prev_uv / uv_total_prev,
                    "cur_share": cur_uv / uv_total_cur,
                }
            )

        for item in group:
            rate_effect = (item["cur_rate"] - item["prev_rate"]) * item["prev_share"]
            share_effect = (item["cur_share"] - item["prev_share"]) * (
                item["cur_rate"] - overall_prev_rate
            )

            if not pd.isna(overall_wow) and overall_wow != 0:
                rate_abs = round(rate_effect, 10)
                rate_share = round(rate_effect / overall_wow * 100, 6)
                rate_rate = round(rate_share / 100 * overall_wow_pct, 6)
                uv_abs = round(share_effect, 10)
                uv_share = round(share_effect / overall_wow * 100, 6)
                uv_rate = round(uv_share / 100 * overall_wow_pct, 6)
            else:
                rate_abs = uv_abs = 0.0
                rate_share = uv_share = 0.0
                rate_rate = uv_rate = 0.0

            contrib_rate[item["rate_code"]] = (rate_abs, rate_share, rate_rate)
            contrib_uv[item["uv_code"]] = (uv_abs, uv_share, uv_rate)

    abs_col, share_col, rate_col = [], [], []
    for _, row in df.iterrows():
        code = str(row["层级"]).strip()
        if code in contrib_rate:
            abs_value, share_value, rate_value = contrib_rate[code]
        elif code in contrib_uv:
            abs_value, share_value, rate_value = contrib_uv[code]
        else:
            abs_value = share_value = rate_value = pd.NA

        abs_col.append(abs_value)
        share_col.append(share_value)
        rate_col.append(rate_value)

    df = df.copy()
    df["对整体变化绝对值贡献"] = abs_col
    df["对整体变化值贡献率"] = share_col
    df["对整体变化率贡献"] = rate_col
    return df, float(overall_wow), float(overall_prev_rate)


def generate_contribution(config: dict[str, Any]) -> None:
    input_file = config["input_file"]
    output_file = config["output_file"]

    if not input_file.exists():
        raise FileNotFoundError(f"未找到输入文件: {input_file}")

    print(f"\n=== {config['name']} 贡献度 ===")
    df = pd.read_csv(input_file, encoding="utf-8-sig")
    ensure_numeric(df, WEEK_COLUMNS + ["wow", "wow%"])

    attribution = config.get("attribution", "additive")
    if attribution == "dual_factor":
        df, overall_wow, overall_prev = add_dual_factor_contribution_columns(df)
        attribution_desc = "双因子归因 (留存率变化贡献 + UV占比结构变化贡献)"
    elif attribution == "multiplicative_save":
        df, overall_wow, overall_prev = add_multiplicative_save_contribution_columns(df)
        attribution_desc = "乘法归因 LMDI (保存量 = DAU × 保存率)"
    else:
        df, overall_wow, overall_prev = add_additive_contribution_columns(df)
        attribution_desc = "加法归因 (wow 即贡献绝对值)"

    df = df.sort_values("层级", key=lambda s: s.map(sort_level_key)).reset_index(drop=True)

    output_file.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_file, index=False, encoding="utf-8-sig")

    print(f"已生成: {output_file}")
    print(f"  行数: {len(df)}")
    print(f"  归因: {attribution_desc}")
    print(f"  整体 wow: {overall_wow}")
    print(f"  整体上周: {overall_prev}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成 AI 周报贡献度 CSV")
    parser.add_argument(
        "--metric",
        choices=["dau", "dnu", "bookings", "retention", "new_retention", "save", "all"],
        default="all",
        help="指定生成的指标（默认 all）",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    metrics = (
        ["dau", "dnu", "bookings", "retention", "new_retention", "save"]
        if args.metric == "all"
        else [args.metric]
    )
    for metric_key in metrics:
        generate_contribution(METRIC_CONFIGS[metric_key])


if __name__ == "__main__":
    main()

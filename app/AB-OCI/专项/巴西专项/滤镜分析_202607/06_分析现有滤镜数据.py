#!/usr/bin/env python3
"""基于已完成的北斗素材数据与 trace_info 会话路径输出阶段性分析表。"""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
WEIGHT = "edit_trace_count"


def ratio(df: pd.DataFrame, condition: pd.Series) -> float:
    return float(df.loc[condition, WEIGHT].sum() / df[WEIGHT].sum())


def weighted_mean(df: pd.DataFrame, column: str) -> float:
    return float(np.average(pd.to_numeric(df[column]), weights=df[WEIGHT]))


def path_summary(name: str, df: pd.DataFrame) -> dict[str, object]:
    total = float(df[WEIGHT].sum())
    sub_enter = float(df.loc[df["has_subscription_enter_after_check"] == 1, WEIGHT].sum())
    sub_click = float(df.loc[df["has_subscription_click_after_check"] == 1, WEIGHT].sum())
    sub_success = float(df.loc[df["has_subscription_success_after_check"] == 1, WEIGHT].sum())
    return {
        "市场/分层": name,
        "滤镜打勾编辑会话数": int(total),
        "会话平均素材点击PV_上限20": weighted_mean(df, "trace_click_pv_capped"),
        "会话平均点击素材数_上限20": weighted_mean(df, "trace_distinct_click_materials_capped"),
        "仅点击1个素材占比": ratio(df, df["trace_distinct_click_materials_capped"] == 1),
        "点击2至3个素材占比": ratio(df, df["trace_distinct_click_materials_capped"].between(2, 3)),
        "点击4至5个素材占比": ratio(df, df["trace_distinct_click_materials_capped"].between(4, 5)),
        "点击6个及以上素材占比": ratio(df, df["trace_distinct_click_materials_capped"] >= 6),
        "无素材点击记录占比": ratio(df, df["trace_distinct_click_materials_capped"] == 0),
        "仅打勾1次占比": ratio(df, df["filter_check_pv_capped"] == 1),
        "打勾后保存率_会话": ratio(df, df["has_save_after_check"] == 1),
        "打勾后订阅页曝光率_会话": sub_enter / total,
        "订阅页曝光后点击率_会话": sub_click / sub_enter if sub_enter else np.nan,
        "订阅页曝光后成功率_会话": sub_success / sub_enter if sub_enter else np.nan,
    }


def add_depth_bucket(df: pd.DataFrame) -> pd.DataFrame:
    result = df.copy()
    depth = result["trace_distinct_click_materials_capped"]
    result["素材选择深度"] = np.select(
        [depth == 0, depth == 1, depth.between(2, 3), depth.between(4, 5), depth.between(6, 10), depth.between(11, 19), depth >= 20],
        ["0", "1", "2-3", "4-5", "6-10", "11-19", "20+"],
        default="Unknown",
    )
    return result


def depth_summary(df: pd.DataFrame) -> pd.DataFrame:
    markets = {
        "巴西": df["country_group"] == "Brazil",
        "整体": pd.Series(True, index=df.index),
    }
    rows: list[dict[str, object]] = []
    order = ["0", "1", "2-3", "4-5", "6-10", "11-19", "20+"]
    for market, mask in markets.items():
        current = df[mask]
        total = current[WEIGHT].sum()
        for bucket in order:
            part = current[current["素材选择深度"] == bucket]
            count = part[WEIGHT].sum()
            rows.append(
                {
                    "市场": market,
                    "素材选择深度": bucket,
                    "编辑会话数": int(count),
                    "会话占比": count / total if total else np.nan,
                    "打勾后保存率": ratio(part, part["has_save_after_check"] == 1) if count else np.nan,
                    "订阅页曝光率": ratio(part, part["has_subscription_enter_after_check"] == 1) if count else np.nan,
                }
            )
    return pd.DataFrame(rows)


def main() -> None:
    path = pd.read_csv(OUT / "02_巴西滤镜编辑会话路径_202607.csv", encoding="utf-8-sig")
    path = add_depth_bucket(path)
    masks = {
        "巴西": path["country_group"] == "Brazil",
        "整体": pd.Series(True, index=path.index),
        "巴西-iOS": (path["country_group"] == "Brazil") & (path["os_type"].str.lower() == "ios"),
        "巴西-Android": (path["country_group"] == "Brazil") & (path["os_type"].str.lower() == "android"),
        "巴西-新用户": (path["country_group"] == "Brazil") & (path["is_new"] == "New"),
        "巴西-老用户": (path["country_group"] == "Brazil") & (path["is_new"] == "Old"),
        "巴西-自然新用户": (path["country_group"] == "Brazil") & (path["is_new"] == "New") & (path["is_ua"] == "Organic"),
        "巴西-渠道新用户": (path["country_group"] == "Brazil") & (path["is_new"] == "New") & (path["is_ua"] != "Organic"),
        "巴西-当前付费": (path["country_group"] == "Brazil") & (path["pay_status"] == "Paying"),
        "巴西-当前非付费": (path["country_group"] == "Brazil") & (path["pay_status"] == "Un-Paying"),
    }
    summary = pd.DataFrame(path_summary(name, path[mask]) for name, mask in masks.items())
    depth = depth_summary(path)
    summary.to_csv(OUT / "会话路径市场及分层汇总_现有数据.csv", index=False, encoding="utf-8-sig")
    depth.to_csv(OUT / "会话路径选择深度与转化_现有数据.csv", index=False, encoding="utf-8-sig")
    print(summary.to_string(index=False))
    print("\n选择深度：\n", depth.to_string(index=False))


if __name__ == "__main__":
    main()

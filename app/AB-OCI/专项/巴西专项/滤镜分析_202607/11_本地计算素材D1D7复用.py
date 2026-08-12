#!/usr/bin/env python3
"""基于用户×日期×素材宽表，在本地计算严格 D1 / D7 复用率。"""

from pathlib import Path
import numpy as np
import pandas as pd


ROOT = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
)
INPUT_DIR = ROOT / "03A_用户日宽表分片"
DETAIL_OUTPUT = ROOT / "03_巴西滤镜素材复用_D1_D7_202607.csv"
MATERIAL_OUTPUT = ROOT / "03_巴西滤镜素材复用_D1_D7_素材汇总_202607.csv"

RENAME = {
    "material_use.date_p": "date_p",
    "material_use.gid": "gid",
    "material_use.material_id": "material_id",
    "material_use.category_id": "category_id",
}
DIMENSIONS = [
    "country_group",
    "os_type",
    "is_new",
    "is_ua",
    "install_age_bucket",
    "pay_status",
    "material_id",
    "category_id",
]
METRICS = [
    "cohort_user_days",
    "d1_mature_cohort_user_days",
    "d1_any_filter_user_days",
    "d1_same_material_user_days",
    "d7_mature_cohort_user_days",
    "d7_exact_any_filter_user_days",
    "d7_exact_same_material_user_days",
]


def mark_future_usage(frame: pd.DataFrame, delta: int) -> tuple[np.ndarray, np.ndarray]:
    """返回每行在严格第 delta 日是否使用任意滤镜、是否复用同素材。"""
    any_flag = np.zeros(len(frame), dtype=np.int8)
    same_flag = np.zeros(len(frame), dtype=np.int8)
    max_cohort_date = 20260731 - delta

    for cohort_date in range(20260701, max_cohort_date + 1):
        cohort_positions = np.flatnonzero(frame["date_p"].to_numpy() == cohort_date)
        if len(cohort_positions) == 0:
            continue
        future = frame.loc[frame["date_p"] == cohort_date + delta, ["gid", "material_id"]]
        if future.empty:
            continue

        cohort = frame.iloc[cohort_positions]
        future_gids = pd.Index(future["gid"].unique())
        any_flag[cohort_positions] = cohort["gid"].isin(future_gids).to_numpy(np.int8)

        future_same = pd.MultiIndex.from_frame(future.drop_duplicates())
        cohort_same = pd.MultiIndex.from_frame(cohort[["gid", "material_id"]])
        same_flag[cohort_positions] = cohort_same.isin(future_same).astype(np.int8)

    return any_flag, same_flag


def rate(numerator: pd.Series, denominator: pd.Series) -> pd.Series:
    return numerator.div(denominator.where(denominator.ne(0)))


def main() -> None:
    files = sorted(INPUT_DIR.glob("03A_滤镜素材用户日宽表_*.csv"))
    if len(files) != 5:
        raise RuntimeError(f"期望5个用户日分片，实际{len(files)}个：{INPUT_DIR}")

    frames = []
    for path in files:
        chunk = pd.read_csv(path, encoding="utf-8-sig", low_memory=False).rename(columns=RENAME)
        frames.append(chunk)
    frame = pd.concat(frames, ignore_index=True)

    required = {"date_p", "gid", *DIMENSIONS}
    missing = sorted(required.difference(frame.columns))
    if missing:
        raise KeyError(f"宽表缺少字段：{missing}")

    frame["date_p"] = pd.to_numeric(frame["date_p"], errors="raise").astype("int32")
    frame["gid"] = pd.to_numeric(frame["gid"], errors="raise").astype("int64")
    for column in DIMENSIONS:
        frame[column] = frame[column].fillna("Missing").astype("category")

    duplicate_count = int(frame.duplicated(["date_p", "gid", "material_id", "category_id"]).sum())
    if duplicate_count:
        raise AssertionError(f"用户日素材粒度存在重复：{duplicate_count:,}行")

    d1_any, d1_same = mark_future_usage(frame, 1)
    d7_any, d7_same = mark_future_usage(frame, 7)
    d1_mature = (frame["date_p"].to_numpy() <= 20260730).astype(np.int8)
    d7_mature = (frame["date_p"].to_numpy() <= 20260724).astype(np.int8)

    frame["cohort_user_days"] = np.ones(len(frame), dtype=np.int8)
    frame["d1_mature_cohort_user_days"] = d1_mature
    frame["d1_any_filter_user_days"] = d1_any * d1_mature
    frame["d1_same_material_user_days"] = d1_same * d1_mature
    frame["d7_mature_cohort_user_days"] = d7_mature
    frame["d7_exact_any_filter_user_days"] = d7_any * d7_mature
    frame["d7_exact_same_material_user_days"] = d7_same * d7_mature

    detail = (
        frame.groupby(DIMENSIONS, observed=True, dropna=False)[METRICS]
        .sum()
        .reset_index()
        .sort_values("cohort_user_days", ascending=False)
    )
    detail.to_csv(DETAIL_OUTPUT, index=False, encoding="utf-8-sig")

    material_parts = []
    for market, market_frame in (
        ("Brazil", frame.loc[frame["country_group"] == "Brazil"]),
        ("Overall", frame),
    ):
        dominant_category = (
            market_frame.groupby(["material_id", "category_id"], observed=True, dropna=False)[
                "cohort_user_days"
            ]
            .sum()
            .reset_index()
            .sort_values("cohort_user_days", ascending=False)
            .drop_duplicates("material_id")[["material_id", "category_id"]]
        )
        part = (
            market_frame.groupby(["material_id"], observed=True, dropna=False)[METRICS]
            .sum()
            .reset_index()
            .merge(dominant_category, on="material_id", how="left")
        )
        part.insert(0, "market", market)
        material_parts.append(part)
    material = pd.concat(material_parts, ignore_index=True)
    material["d1_any_filter_reuse_rate"] = rate(
        material["d1_any_filter_user_days"], material["d1_mature_cohort_user_days"]
    )
    material["d1_same_material_reuse_rate"] = rate(
        material["d1_same_material_user_days"], material["d1_mature_cohort_user_days"]
    )
    material["d7_any_filter_reuse_rate"] = rate(
        material["d7_exact_any_filter_user_days"], material["d7_mature_cohort_user_days"]
    )
    material["d7_same_material_reuse_rate"] = rate(
        material["d7_exact_same_material_user_days"], material["d7_mature_cohort_user_days"]
    )
    material = material.sort_values(["market", "cohort_user_days"], ascending=[True, False])
    material.to_csv(MATERIAL_OUTPUT, index=False, encoding="utf-8-sig")

    for numerator, denominator in (
        ("d1_any_filter_user_days", "d1_mature_cohort_user_days"),
        ("d1_same_material_user_days", "d1_mature_cohort_user_days"),
        ("d7_exact_any_filter_user_days", "d7_mature_cohort_user_days"),
        ("d7_exact_same_material_user_days", "d7_mature_cohort_user_days"),
        ("d1_same_material_user_days", "d1_any_filter_user_days"),
        ("d7_exact_same_material_user_days", "d7_exact_any_filter_user_days"),
    ):
        if (detail[numerator] > detail[denominator]).any():
            raise AssertionError(f"存在 {numerator} > {denominator}")

    print(f"用户日素材 cohort: {len(frame):,}")
    print(f"明细输出行数: {len(detail):,}")
    for market, market_frame in (
        ("巴西", frame.loc[frame["country_group"] == "Brazil"]),
        ("整体", frame),
    ):
        print(market)
        for label, numerator, denominator in (
            ("D1任意滤镜", "d1_any_filter_user_days", "d1_mature_cohort_user_days"),
            ("D1同素材", "d1_same_material_user_days", "d1_mature_cohort_user_days"),
            ("D7任意滤镜", "d7_exact_any_filter_user_days", "d7_mature_cohort_user_days"),
            ("D7同素材", "d7_exact_same_material_user_days", "d7_mature_cohort_user_days"),
        ):
            n = int(market_frame[numerator].sum())
            d = int(market_frame[denominator].sum())
            value = n / d if d else float("nan")
            print(f"  {label}: {value:.2%} ({n:,}/{d:,})")


if __name__ == "__main__":
    main()

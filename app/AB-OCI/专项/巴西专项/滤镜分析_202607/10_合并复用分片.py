#!/usr/bin/env python3
"""合并按 cohort 日期拆分的素材复用结果，并校验复用率分母分子。"""

from pathlib import Path
import pandas as pd


ROOT = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
)
INPUT_DIR = ROOT / "03_复用分片_cohort"
OUTPUT = ROOT / "03_巴西滤镜素材复用_D1_D7_202607.csv"

METRICS = [
    "cohort_user_days",
    "d1_mature_cohort_user_days",
    "d1_any_filter_user_days",
    "d1_same_material_user_days",
    "d7_mature_cohort_user_days",
    "d7_exact_any_filter_user_days",
    "d7_exact_same_material_user_days",
]


def safe_rate(numerator: int, denominator: int) -> float:
    return numerator / denominator if denominator else float("nan")


def main() -> None:
    files = sorted(INPUT_DIR.glob("03_巴西滤镜素材复用_cohort_*.csv"))
    if len(files) != 5:
        raise RuntimeError(f"期望5个 cohort 分片，实际{len(files)}个：{INPUT_DIR}")

    frames = [pd.read_csv(path, encoding="utf-8-sig") for path in files]
    merged = pd.concat(frames, ignore_index=True)
    missing = [column for column in METRICS if column not in merged.columns]
    if missing:
        raise KeyError(f"缺少计数字段：{missing}")

    dims = [column for column in merged.columns if column not in METRICS]
    result = (
        merged.groupby(dims, dropna=False, as_index=False)[METRICS]
        .sum()
        .sort_values("cohort_user_days", ascending=False)
    )
    result.to_csv(OUTPUT, index=False, encoding="utf-8-sig")

    checks = [
        ("D1任意滤镜", "d1_any_filter_user_days", "d1_mature_cohort_user_days"),
        ("D1同素材", "d1_same_material_user_days", "d1_mature_cohort_user_days"),
        ("严格D7任意滤镜", "d7_exact_any_filter_user_days", "d7_mature_cohort_user_days"),
        ("严格D7同素材", "d7_exact_same_material_user_days", "d7_mature_cohort_user_days"),
    ]
    for label, numerator, denominator in checks:
        if (result[numerator] > result[denominator]).any():
            raise AssertionError(f"{label}存在分子大于分母")

    pair_checks = [
        ("d1_same_material_user_days", "d1_any_filter_user_days"),
        ("d7_exact_same_material_user_days", "d7_exact_any_filter_user_days"),
    ]
    for same, any_filter in pair_checks:
        if (result[same] > result[any_filter]).any():
            raise AssertionError(f"{same}存在大于{any_filter}")

    print(f"输出行数: {len(result):,}")
    print(f"cohort用户日: {int(result['cohort_user_days'].sum()):,}")
    for market, frame in (
        ("巴西", result[result["country_group"] == "Brazil"]),
        ("整体", result),
    ):
        print(market)
        for label, numerator, denominator in checks:
            n = int(frame[numerator].sum())
            d = int(frame[denominator].sum())
            print(f"  {label}: {safe_rate(n, d):.2%} ({n:,}/{d:,})")


if __name__ == "__main__":
    main()

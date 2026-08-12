#!/usr/bin/env python3
"""Aggregate exact Filters exposure-depth output into Brazil/Overall tables."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
INPUT = OUT / "06G_Filters曝光不同素材数分布与打勾率_20260729_20260804.csv"
OUTPUT = OUT / "06H_Filters曝光不同素材数分布与打勾率_分层.csv"

DIMENSIONS = [
    ("overall", None),
    ("os_type", "os_type"),
    ("is_new", "is_new"),
    ("is_ua_new_only", "is_ua"),
    ("pay_status", "pay_status"),
    ("install_age_bucket", "install_age_bucket"),
]


def segment_values(row):
    for name, field in DIMENSIONS:
        if name == "overall":
            yield name, "ALL"
        elif name == "is_ua_new_only":
            if row["is_new"] == "New":
                yield name, row["is_ua"]
        else:
            yield name, row[field]


def div(n, d):
    return n / d if d else None


def main():
    with INPUT.open(encoding="utf-8-sig", newline="") as f:
        rows = list(csv.DictReader(f))

    agg = defaultdict(lambda: [0, 0, 0])
    for row in rows:
        markets = ["Overall"]
        if row["country_group"] == "Brazil":
            markets.append("Brazil")
        for market in markets:
            for dim, value in segment_values(row):
                key = (market, dim, value, row["exposure_depth_bucket"])
                agg[key][0] += int(row["filter_entry_count"])
                agg[key][1] += int(row["checked_entry_count"])
                agg[key][2] += int(row["distinct_exposure_material_sum"])

    totals = defaultdict(int)
    for (market, dim, value, _), (entries, _, _) in agg.items():
        totals[(market, dim, value)] += entries

    def bucket_sort(value):
        return 50 if value == "50+" else int(value)

    output_rows = []
    for (market, dim, value, bucket), (entries, checked, exposure_sum) in sorted(
        agg.items(), key=lambda x: (x[0][0], x[0][1], x[0][2], bucket_sort(x[0][3]))
    ):
        output_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                "distinct_exposure_material_bucket": bucket,
                "filter_entry_count": entries,
                "entry_share": div(entries, totals[(market, dim, value)]),
                "checked_entry_count": checked,
                "entry_check_rate": div(checked, entries),
                "distinct_exposure_material_sum": exposure_sum,
            }
        )

    fields = [
        "country_group",
        "segment_dimension",
        "segment_value",
        "distinct_exposure_material_bucket",
        "filter_entry_count",
        "entry_share",
        "checked_entry_count",
        "entry_check_rate",
        "distinct_exposure_material_sum",
    ]
    with OUTPUT.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(output_rows)

    overall_check = {}
    for market in ("Brazil", "Overall"):
        selected = [r for r in output_rows if r["country_group"] == market and r["segment_dimension"] == "overall"]
        overall_check[market] = (
            sum(r["filter_entry_count"] for r in selected),
            sum(r["checked_entry_count"] for r in selected),
        )
    assert overall_check["Brazil"] == (1133392, 540652)
    assert overall_check["Overall"] == (3260761, 1527056)
    print(OUTPUT)
    print(overall_check)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Aggregate pre-first-click exposure depth into Brazil/Overall analysis data."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
INPUT = OUT / "06I_Filters首次点击前曝光不同素材数分布_20260729_20260804.csv"
OUTPUT = OUT / "06J_Filters首次点击前曝光不同素材数分布_分层.csv"

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

    agg = defaultdict(lambda: [0, 0, 0, 0, 0, 0])
    for row in rows:
        markets = ["Overall"]
        if row["country_group"] == "Brazil":
            markets.append("Brazil")
        for market in markets:
            for dim, value in segment_values(row):
                key = (market, dim, value, row["pre_click_exposure_bucket"])
                values = agg[key]
                values[0] += int(row["filter_entry_count"])
                values[1] += int(row["clicked_entry_count"])
                values[2] += int(row["checked_entry_count"])
                values[3] += int(row["pre_click_exposure_material_sum"])
                values[4] += int(row["same_second_exposure_material_sum"])
                values[5] += int(row["clicked_entry_with_same_second_exposure_count"])

    all_totals = defaultdict(int)
    clicked_totals = defaultdict(int)
    for (market, dim, value, bucket), values in agg.items():
        all_totals[(market, dim, value)] += values[0]
        if bucket != "NO_CLICK":
            clicked_totals[(market, dim, value)] += values[1]

    def sort_bucket(value):
        if value == "NO_CLICK":
            return 999
        if value == "50+":
            return 50
        return int(value)

    output_rows = []
    for (market, dim, value, bucket), values in sorted(
        agg.items(), key=lambda x: (x[0][0], x[0][1], x[0][2], sort_bucket(x[0][3]))
    ):
        entries, clicked, checked, before_sum, same_sum, same_entries = values
        output_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                "pre_click_exposure_bucket": bucket,
                "filter_entry_count": entries,
                "clicked_entry_count": clicked,
                "share_among_clicked_entries": (
                    div(clicked, clicked_totals[(market, dim, value)]) if bucket != "NO_CLICK" else None
                ),
                "share_among_all_entries": div(entries, all_totals[(market, dim, value)]),
                "checked_entry_count": checked,
                "entry_check_rate": div(checked, entries),
                "pre_click_exposure_material_sum": before_sum,
                "same_second_exposure_material_sum": same_sum,
                "clicked_entry_with_same_second_exposure_count": same_entries,
                "same_second_exposure_affected_rate": div(same_entries, clicked),
            }
        )

    fields = list(output_rows[0])
    with OUTPUT.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(output_rows)

    expected = {
        "Brazil": (1133392, 818122, 540652),
        "Overall": (3260761, 2282832, 1527056),
    }
    actual = {}
    for market in expected:
        selected = [r for r in output_rows if r["country_group"] == market and r["segment_dimension"] == "overall"]
        actual[market] = (
            sum(r["filter_entry_count"] for r in selected),
            sum(r["clicked_entry_count"] for r in selected),
            sum(r["checked_entry_count"] for r in selected),
        )
    assert actual == expected, (actual, expected)
    print(OUTPUT)
    print(actual)


if __name__ == "__main__":
    main()

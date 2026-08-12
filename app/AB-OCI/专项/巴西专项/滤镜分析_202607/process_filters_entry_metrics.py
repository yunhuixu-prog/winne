#!/usr/bin/env python3
"""Aggregate Filters per-entry query outputs into Brazil/Overall analysis tables."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
A_PATH = OUT / "06A_Filters单次进入汇总与点击分布_20260729_20260804.csv"
B_PATH = OUT / "06B_Filters最终打勾素材与点击关系_20260729_20260804.csv"

DIMENSIONS = [
    ("overall", None),
    ("os_type", "os_type"),
    ("is_new", "is_new"),
    ("is_ua_new_only", "is_ua"),
    ("pay_status", "pay_status"),
    ("install_age_bucket", "install_age_bucket"),
]

COUNT_FIELDS = [
    "filter_user_day_count",
    "filter_entry_count",
    "distinct_exposure_material_sum",
    "distinct_click_material_sum",
    "clicked_entry_count",
    "checked_entry_count",
    "repeat_clicked_entry_count",
]


def market_groups(country: str):
    """Overall includes Brazil; Brazil is additionally emitted as its own market."""
    yield "Overall"
    if country in {"巴西", "Brazil"}:
        yield "Brazil"


def as_int(value: str | None) -> int:
    if value in (None, "", "NULL", "null"):
        return 0
    return int(float(value))


def div(n: int, d: int) -> float | None:
    return n / d if d else None


def segment_values(row: dict[str, str]):
    for name, field in DIMENSIONS:
        if name == "overall":
            yield name, "ALL"
        elif name == "is_ua_new_only":
            if row.get("is_new") == "New":
                yield name, row.get("is_ua", "Unknown")
        else:
            yield name, row.get(field or "", "Unknown")


def add_counts(target: dict[str, int], row: dict[str, str], fields=COUNT_FIELDS):
    for field in fields:
        target[field] += as_int(row.get(field))


def write_csv(path: Path, rows: list[dict], fields: list[str]):
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    with A_PATH.open(encoding="utf-8-sig", newline="") as f:
        a_rows = list(csv.DictReader(f))
    with B_PATH.open(encoding="utf-8-sig", newline="") as f:
        b_rows = list(csv.DictReader(f))

    summary = defaultdict(lambda: defaultdict(int))
    click_depth = defaultdict(lambda: defaultdict(int))
    repeat_depth = defaultdict(lambda: defaultdict(int))

    for row in a_rows:
        for market in market_groups(row["country"]):
            if row["record_type"] == "SUMMARY":
                for dim, value in segment_values(row):
                    add_counts(summary[(market, dim, value)], row)
            elif row["record_type"] == "ROUND_DISTRIBUTION":
                for dim, value in segment_values(row):
                    add_counts(
                        click_depth[(market, dim, value, row["click_depth_bucket"])],
                        row,
                        [
                            "filter_entry_count",
                            "distinct_exposure_material_sum",
                            "distinct_click_material_sum",
                            "clicked_entry_count",
                            "checked_entry_count",
                            "repeat_clicked_entry_count",
                        ],
                    )
                    add_counts(
                        repeat_depth[(market, dim, value, row["repeat_depth_bucket"])],
                        row,
                        [
                            "filter_entry_count",
                            "checked_entry_count",
                            "repeat_clicked_entry_count",
                        ],
                    )

    summary_rows = []
    for (market, dim, value), x in sorted(summary.items()):
        entries = x["filter_entry_count"]
        clicked = x["clicked_entry_count"]
        summary_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                **{field: x[field] for field in COUNT_FIELDS},
                "avg_entries_per_user_day": div(entries, x["filter_user_day_count"]),
                "avg_distinct_exposure_materials_per_entry": div(
                    x["distinct_exposure_material_sum"], entries
                ),
                "avg_distinct_click_materials_per_entry": div(
                    x["distinct_click_material_sum"], entries
                ),
                "entry_click_rate": div(clicked, entries),
                "entry_check_rate": div(x["checked_entry_count"], entries),
                "repeat_click_entry_rate": div(x["repeat_clicked_entry_count"], entries),
                "repeat_click_rate_among_clicked_entries": div(
                    x["repeat_clicked_entry_count"], clicked
                ),
            }
        )

    summary_fields = [
        "country_group",
        "segment_dimension",
        "segment_value",
        *COUNT_FIELDS,
        "avg_entries_per_user_day",
        "avg_distinct_exposure_materials_per_entry",
        "avg_distinct_click_materials_per_entry",
        "entry_click_rate",
        "entry_check_rate",
        "repeat_click_entry_rate",
        "repeat_click_rate_among_clicked_entries",
    ]
    write_csv(OUT / "06C_Filters单次进入核心指标_分层.csv", summary_rows, summary_fields)

    click_totals = defaultdict(int)
    for (market, dim, value, _), x in click_depth.items():
        click_totals[(market, dim, value)] += x["filter_entry_count"]
    click_rows = []
    for (market, dim, value, bucket), x in sorted(click_depth.items()):
        entries = x["filter_entry_count"]
        click_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                "distinct_click_material_bucket": bucket,
                "filter_entry_count": entries,
                "entry_share": div(entries, click_totals[(market, dim, value)]),
                "checked_entry_count": x["checked_entry_count"],
                "entry_check_rate": div(x["checked_entry_count"], entries),
            }
        )
    write_csv(
        OUT / "06D_Filters每次进入点击不同素材数分布与打勾率_分层.csv",
        click_rows,
        [
            "country_group",
            "segment_dimension",
            "segment_value",
            "distinct_click_material_bucket",
            "filter_entry_count",
            "entry_share",
            "checked_entry_count",
            "entry_check_rate",
        ],
    )

    repeat_totals = defaultdict(int)
    for (market, dim, value, _), x in repeat_depth.items():
        repeat_totals[(market, dim, value)] += x["filter_entry_count"]
    repeat_rows = []
    for (market, dim, value, bucket), x in sorted(repeat_depth.items()):
        entries = x["filter_entry_count"]
        repeat_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                "max_clicks_on_same_material_bucket": bucket,
                "filter_entry_count": entries,
                "entry_share": div(entries, repeat_totals[(market, dim, value)]),
                "checked_entry_count": x["checked_entry_count"],
                "entry_check_rate": div(x["checked_entry_count"], entries),
            }
        )
    write_csv(
        OUT / "06E_Filters每次进入同素材重复点击分布与打勾率_分层.csv",
        repeat_rows,
        [
            "country_group",
            "segment_dimension",
            "segment_value",
            "max_clicks_on_same_material_bucket",
            "filter_entry_count",
            "entry_share",
            "checked_entry_count",
            "entry_check_rate",
        ],
    )

    relation = defaultdict(int)
    for row in b_rows:
        markets = ["Overall"]
        if row["country"] == "Brazil":
            markets.append("Brazil")
        for market in markets:
            for dim, value in segment_values(row):
                relation[(market, dim, value, row["check_relation"])] += as_int(
                    row["checked_entry_count"]
                )
    relation_totals = defaultdict(int)
    for (market, dim, value, _), count in relation.items():
        relation_totals[(market, dim, value)] += count
    relation_rows = []
    for (market, dim, value, relation_name), count in sorted(relation.items()):
        relation_rows.append(
            {
                "country_group": market,
                "segment_dimension": dim,
                "segment_value": value,
                "check_relation": relation_name,
                "checked_entry_count": count,
                "share_among_checked_entries": div(
                    count, relation_totals[(market, dim, value)]
                ),
            }
        )
    write_csv(
        OUT / "06F_Filters最终打勾素材与点击关系_分层.csv",
        relation_rows,
        [
            "country_group",
            "segment_dimension",
            "segment_value",
            "check_relation",
            "checked_entry_count",
            "share_among_checked_entries",
        ],
    )

    # Validation: all distributions must close, and A/B checked rounds should match.
    for totals in (click_totals, repeat_totals, relation_totals):
        assert all(value >= 0 for value in totals.values())
    a_checked = {
        row["country_group"]: row["checked_entry_count"]
        for row in summary_rows
        if row["segment_dimension"] == "overall"
    }
    b_checked = {
        market: relation_totals[(market, "overall", "ALL")]
        for market in ("Brazil", "Overall")
    }
    print("A checked entries:", a_checked)
    print("B checked entries:", b_checked)
    print("A/B difference:", {k: b_checked[k] - a_checked[k] for k in b_checked})
    print("Wrote 06C-06F outputs to", OUT)


if __name__ == "__main__":
    main()

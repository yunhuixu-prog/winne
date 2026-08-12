#!/usr/bin/env python3
"""按 cohort 日期拆分复用 SQL；原始行为与未来7日观察窗保持整月。"""

from pathlib import Path
import argparse
import subprocess
import sys


CHUNKS = [
    (20260701, 20260707),
    (20260708, 20260714),
    (20260715, 20260721),
    (20260722, 20260728),
    (20260729, 20260731),
]
TEMP_QUERY = Path(
    "/Users/xuyunhui/.agents/skills/shenzhou-temp-query/scripts/temp_query.py"
)
COHORT_RANGE = "WHERE date_p BETWEEN 20260701 AND 20260731 -- COHORT_DATE_RANGE"
PROFILE_RANGE = "WHERE date_p BETWEEN 20260701 AND 20260731 -- PROFILE_DATE_RANGE"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--sql-dir", required=True, type=Path)
    args = parser.parse_args()

    template = args.template.read_text()
    if template.count(COHORT_RANGE) != 1:
        raise ValueError(
            f"cohort 范围标记应恰好出现1次，实际{template.count(COHORT_RANGE)}次"
        )
    if template.count(PROFILE_RANGE) != 1:
        raise ValueError(
            f"profile 范围标记应恰好出现1次，实际{template.count(PROFILE_RANGE)}次"
        )
    args.output_dir.mkdir(parents=True, exist_ok=True)
    args.sql_dir.mkdir(parents=True, exist_ok=True)

    for start, end in CHUNKS:
        suffix = f"{start}_{end}"
        sql_path = args.sql_dir / f"{args.prefix}_{suffix}.sql"
        csv_path = args.output_dir / f"{args.prefix}_{suffix}.csv"
        chunk_sql = template.replace(
            COHORT_RANGE,
            f"WHERE date_p BETWEEN {start} AND {end} -- COHORT_DATE_RANGE",
        )
        chunk_sql = chunk_sql.replace(
            PROFILE_RANGE,
            f"WHERE date_p BETWEEN {start} AND {end} -- PROFILE_DATE_RANGE",
        )
        sql_path.write_text(chunk_sql)
        if csv_path.exists() and csv_path.stat().st_size > 0:
            print(f"SKIP existing: {csv_path}", flush=True)
            continue

        cmd = [
            sys.executable,
            str(TEMP_QUERY),
            "run",
            "--sql-file",
            str(sql_path),
            "--project",
            "Airbrush",
            "--env",
            "oci",
            "--engine",
            "hive",
            "--wait",
            "--download",
            "-o",
            str(csv_path),
        ]
        print(f"RUN cohort {start}-{end}", flush=True)
        completed = subprocess.run(cmd, check=False)
        if completed.returncode != 0:
            print(f"FAILED cohort {start}-{end}: exit={completed.returncode}", file=sys.stderr)
            return completed.returncode
        print(f"DONE cohort {start}-{end}: {csv_path}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

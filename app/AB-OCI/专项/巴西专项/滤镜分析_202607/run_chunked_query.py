#!/usr/bin/env python3
"""将整月神舟 SQL 按日期分片执行，并分别下载 CSV。"""

from __future__ import annotations

import argparse
from pathlib import Path
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
MONTH_RANGE = "BETWEEN 20260701 AND 20260731"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--sql-dir", type=Path)
    args = parser.parse_args()

    sql_dir = args.sql_dir or args.output_dir / "sql_chunks"
    sql_dir.mkdir(parents=True, exist_ok=True)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    template = args.template.read_text()
    if MONTH_RANGE not in template:
        raise ValueError(f"模板中没有找到固定月范围: {MONTH_RANGE}")

    for start, end in CHUNKS:
        suffix = f"{start}_{end}"
        sql_path = sql_dir / f"{args.prefix}_{suffix}.sql"
        csv_path = args.output_dir / f"{args.prefix}_{suffix}.csv"
        sql_path.write_text(template.replace(MONTH_RANGE, f"BETWEEN {start} AND {end}"))
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
        print(f"RUN {start}-{end}", flush=True)
        completed = subprocess.run(cmd, check=False)
        if completed.returncode != 0:
            print(f"FAILED {start}-{end}: exit={completed.returncode}", file=sys.stderr)
            return completed.returncode
        print(f"DONE {start}-{end}: {csv_path}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

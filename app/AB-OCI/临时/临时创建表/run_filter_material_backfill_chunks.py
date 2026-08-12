#!/usr/bin/env python3
"""滤镜素材表回刷：7 天一片在神舟执行 INSERT OVERWRITE（Hive / oci / Airbrush）。"""

from __future__ import annotations

import argparse
import datetime as dt
import subprocess
import sys
from pathlib import Path

TEMP_QUERY = Path(
    "/Users/xuyunhui/.agents/skills/shenzhou-temp-query/scripts/temp_query.py"
)
TEMPLATE = Path(__file__).resolve().parent / "滤镜素材表.sql"
SQL_DIR = Path(__file__).resolve().parent / "sql_chunks_filter_material"
LOG_DIR = Path(__file__).resolve().parent / "backfill_logs"

CHUNK_DAYS = 7
DEFAULT_START = 20260701


def yesterday_yyyymmdd() -> int:
    d = dt.date.today() - dt.timedelta(days=1)
    return int(d.strftime("%Y%m%d"))


def iter_chunks(start: int, end: int, step: int) -> list[tuple[int, int]]:
    chunks: list[tuple[int, int]] = []
    cur = start
    while cur <= end:
        chunk_end = min(end, add_days(cur, step - 1))
        chunks.append((cur, chunk_end))
        cur = add_days(chunk_end, 1)
    return chunks


def add_days(yyyymmdd: int, days: int) -> int:
    s = str(yyyymmdd)
    d = dt.datetime.strptime(s, "%Y%m%d").date() + dt.timedelta(days=days)
    return int(d.strftime("%Y%m%d"))


def render_sql(template: str, start: int, end: int) -> str:
    return (
        template.replace("${start_time}", str(start)).replace("${end_time}", str(end))
    )


def run_chunk(sql_path: Path, log_path: Path) -> int:
    log_path.parent.mkdir(parents=True, exist_ok=True)
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
    ]
    with log_path.open("w", encoding="utf-8") as log:
        log.write("CMD: " + " ".join(cmd) + "\n\n")
        log.flush()
        completed = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, check=False)
    return completed.returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", type=int, default=DEFAULT_START)
    parser.add_argument("--end", type=int, default=yesterday_yyyymmdd())
    parser.add_argument("--chunk-days", type=int, default=CHUNK_DAYS)
    parser.add_argument(
        "--from-chunk",
        type=int,
        default=1,
        help="从第几片开始跑（1-based），用于失败后续跑",
    )
    args = parser.parse_args()

    if args.end < args.start:
        print(f"invalid range: {args.start} > {args.end}", file=sys.stderr)
        return 1

    template = TEMPLATE.read_text(encoding="utf-8")
    if "${start_time}" not in template or "${end_time}" not in template:
        print("模板缺少 ${start_time} / ${end_time}", file=sys.stderr)
        return 1

    chunks = iter_chunks(args.start, args.end, args.chunk_days)
    SQL_DIR.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Backfill {args.start}..{args.end}, {len(chunks)} chunk(s), step={args.chunk_days}d")

    for idx, (start, end) in enumerate(chunks, start=1):
        if idx < args.from_chunk:
            continue
        suffix = f"{start}_{end}"
        sql_path = SQL_DIR / f"滤镜素材表_{suffix}.sql"
        log_path = LOG_DIR / f"滤镜素材表_{suffix}.log"
        sql_path.write_text(render_sql(template, start, end), encoding="utf-8")
        print(f"[{idx}/{len(chunks)}] RUN {start}-{end} -> {sql_path.name}", flush=True)
        code = run_chunk(sql_path, log_path)
        if code != 0:
            print(
                f"FAILED chunk {idx} ({start}-{end}), exit={code}, log={log_path}",
                file=sys.stderr,
            )
            print(f"Resume: python3 {Path(__file__)} --from-chunk {idx}", file=sys.stderr)
            return code
        print(f"[{idx}/{len(chunks)}] DONE {start}-{end}, log={log_path}", flush=True)

    print("All chunks finished.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

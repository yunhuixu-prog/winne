#!/usr/bin/env python3
"""
AB 实验留存分析一键脚本：生成 SQL → 神舟取数 → Python 后处理。

默认不限新用户；若只要进入实验当日为新设备，加 --new-users-only。

示例：
  python3 scripts/run_analysis.py \\
    --experiment 激励广告实验 \\
    --start-date 20260428 \\
    --end-date 20260514 \\
    --abcodes 28905,28906,28907

仅新设备进组：
  ... 同上 ... --new-users-only
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent.parent
SQL_TEMPLATE = SKILL_ROOT / "sql" / "step1_retention.sql"
PROCESS_SCRIPT = SKILL_ROOT / "scripts" / "process_retention.py"
SHENZHOU_SCRIPT = Path.home() / ".agents/skills/shenzhou-temp-query/scripts/temp_query.py"
DEFAULT_OUT_ROOT = SKILL_ROOT / "out"


def parse_date(s: str) -> datetime:
    s = s.strip().replace("-", "")
    if len(s) != 8 or not s.isdigit():
        raise ValueError(f"日期须为 yyyymmdd 或 yyyy-mm-dd，收到: {s}")
    return datetime.strptime(s, "%Y%m%d")


def format_abcode_in_list(codes: list[str]) -> str:
    return ",".join(f"'{c.strip()}'" for c in codes if c.strip())


def enter_new_sql_fragment(new_users_only: bool) -> str:
    return "\n          AND enter_new = 1" if new_users_only else ""


def build_sql(start: str, end: str, end_p90: str, abcode_in_list: str, new_users_only: bool) -> str:
    tpl = SQL_TEMPLATE.read_text(encoding="utf-8")
    repl = {
        "${start_date}": start,
        "${end_date}": end,
        "${end_date_p90}": end_p90,
        "${abcode_in_list}": abcode_in_list,
        "${enter_new_sql}": enter_new_sql_fragment(new_users_only),
    }
    for k, v in repl.items():
        tpl = tpl.replace(k, v)
    return tpl


def run_shenzhou(sql_file: Path, csv_out: Path, env: str, project: str, engine: str) -> None:
    if not SHENZHOU_SCRIPT.is_file():
        raise FileNotFoundError(f"未找到神舟脚本: {SHENZHOU_SCRIPT}")
    cmd = [
        sys.executable,
        str(SHENZHOU_SCRIPT),
        "run",
        "--sql-file",
        str(sql_file),
        "--project",
        project,
        "--env",
        env,
        "--engine",
        engine,
        "--wait",
        "--download",
        "-o",
        str(csv_out),
    ]
    print(f"[shenzhou] engine={engine} -> {csv_out}")
    subprocess.run(cmd, check=True)


def main() -> None:
    ap = argparse.ArgumentParser(description="AB 实验留存：神舟 step1 + 幂律/LT/曲线")
    ap.add_argument("--experiment", required=True, help="实验名称，产出目录 out/<实验名>/")
    ap.add_argument("--start-date", required=True, help="实验开始日 yyyymmdd")
    ap.add_argument("--end-date", required=True, help="实验结束日 yyyymmdd")
    ap.add_argument("--abcodes", required=True, help="abcode 列表，逗号分隔，如 28905,28906,28907")
    ap.add_argument("--out-root", type=Path, default=DEFAULT_OUT_ROOT)
    ap.add_argument("--env", default="oci", help="神舟环境，默认 oci")
    ap.add_argument("--project", default="Airbrush", help="神舟项目")
    ap.add_argument("--skip-shenzhou", action="store_true", help="跳过神舟，使用已有 step1 CSV")
    ap.add_argument("--skip-process", action="store_true", help="仅跑神舟，不跑 Python 后处理")
    ap.add_argument(
        "--new-users-only",
        action="store_true",
        help="仅保留进入实验当日为新设备的用户（WHERE 增加 AND enter_new = 1）；默认不限",
    )
    args = ap.parse_args()

    start_dt = parse_date(args.start_date)
    end_dt = parse_date(args.end_date)
    start_s = start_dt.strftime("%Y%m%d")
    end_s = end_dt.strftime("%Y%m%d")
    end_p90_s = (end_dt + timedelta(days=90)).strftime("%Y%m%d")
    codes = [c.strip() for c in args.abcodes.replace("，", ",").split(",") if c.strip()]
    if not codes:
        raise SystemExit("至少提供一个 abcode")

    out_dir = args.out_root / args.experiment
    out_dir.mkdir(parents=True, exist_ok=True)

    sql_path = out_dir / "step1_retention.sql"
    csv_path = out_dir / "step1留存率_presto.csv"

    ab_in = format_abcode_in_list(codes)
    sql_path.write_text(
        build_sql(start_s, end_s, end_p90_s, ab_in, args.new_users_only),
        encoding="utf-8",
    )
    print(f"SQL -> {sql_path}")
    nou = "是（AND enter_new = 1）" if args.new_users_only else "否（全量进入用户）"
    print(f"  start={start_s} end={end_s} end_p90={end_p90_s} abcodes IN ({ab_in})  仅新用户: {nou}")

    if not args.skip_shenzhou:
        if csv_path.is_file():
            print(f"提示: 将覆盖已有 {csv_path}")
        for engine in ("presto", "hive"):
            try:
                run_shenzhou(sql_path, csv_path, args.env, args.project, engine)
                break
            except subprocess.CalledProcessError:
                if engine == "presto":
                    print("[shenzhou] presto 失败，改用 hive on spark 重试…")
                else:
                    raise
    elif not csv_path.is_file():
        raise FileNotFoundError(f"--skip-shenzhou 但缺少 {csv_path}")

    if not args.skip_process:
        subprocess.run(
            [sys.executable, str(PROCESS_SCRIPT), "--input", str(csv_path), "--out-dir", str(out_dir)],
            check=True,
        )

    print(f"\n完成。目录: {out_dir}")
    print("  最终产物: 幂律预估-长表.csv | LT汇总.csv | 拟合曲线.png")
    if not args.skip_shenzhou:
        print(f"  神舟明细: {csv_path.name}")


if __name__ == "__main__":
    main()

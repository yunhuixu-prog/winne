#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""AI 月报生成流水线：北斗取数 → s1→s5 → v1。"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent
SCRIPTS = SKILL_ROOT / "计算脚本"
DATA = SCRIPTS / "数据处理"
FETCH = SCRIPTS / "北斗取数"


def last_complete_month(ref: date | None = None) -> tuple[int, int]:
    today = ref or date.today()
    year, month = today.year, today.month - 1
    if month == 0:
        year -= 1
        month = 12
    return year, month


def latest_complete_period_label(ref: date | None = None) -> str:
    year, month = last_complete_month(ref)
    return f"{year}{month:02d}"


def parse_period_label(text: str) -> str | None:
    raw = text.strip()
    m = re.fullmatch(r"(\d{4})[-/.年]?(\d{1,2})月?", raw)
    if not m:
        m = re.fullmatch(r"(\d{6})", raw)
        if m:
            return m.group(1)
        return None
    return f"{int(m.group(1)):04d}{int(m.group(2)):02d}"


def resolve_output_dir(period: str, user_output: str | None) -> Path:
    if user_output:
        return Path(user_output).expanduser().resolve()
    return SKILL_ROOT / "output" / period


def run_step(cmd: list[str], env: dict[str, str]) -> None:
    print(f"\n>>> {' '.join(cmd)}")
    subprocess.run(cmd, cwd=str(SKILL_ROOT), env=env, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="AI 月报生成流水线（至 v1）")
    parser.add_argument("--period", type=str, default="", help="月份标签，如 202605；与 --recent 互斥")
    parser.add_argument(
        "--recent",
        action="store_true",
        help="取最近一个已结束的完整自然月，并强制北斗取数覆盖 raw_data",
    )
    parser.add_argument("-o", "--output-dir", type=str, default="", help="输出目录")
    parser.add_argument("--skip-fetch", action="store_true", help="跳过北斗取数（--recent 时无效）")
    parser.add_argument("--skip-v1", action="store_true", help="跳过 s4 生成 v1")
    args = parser.parse_args()

    if args.recent and args.period:
        raise ValueError("不可同时指定 --recent 与 --period")

    recent_mode = args.recent or not args.period
    if recent_mode:
        period = latest_complete_period_label()
        do_fetch = True
        if args.skip_fetch:
            print("⚠️  --recent 模式将强制北斗取数，忽略 --skip-fetch")
    else:
        period = parse_period_label(args.period)
        if not period:
            raise ValueError(f"无法解析月份: {args.period!r}")
        do_fetch = not args.skip_fetch

    out_dir = resolve_output_dir(period, args.output_dir or None)
    out_dir.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["AI_MONTHLY_OUTPUT_DIR"] = str(out_dir)
    env["AI_MONTHLY_PERIOD"] = period
    env["PYTHONPATH"] = str(SCRIPTS) + os.pathsep + env.get("PYTHONPATH", "")

    py = sys.executable
    if do_fetch:
        run_step([py, str(FETCH / "fetch_beidou.py")], env)

    for script in ("s1下钻csv生成.py", "s2贡献度csv生成.py", "s3导出下钻md脚本.py", "s5异常检测.py"):
        run_step([py, str(DATA / script)], env)

    if not args.skip_v1:
        run_step([py, str(DATA / "s4生成v1月报md.py")], env)

    print("\n✅ AI 月报流水线完成")
    print(f"   月份: {period}")
    print(f"   输出: {out_dir}")
    print("   产物: monthly_report_v1.md")


if __name__ == "__main__":
    main()

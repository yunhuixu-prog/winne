#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""周报生成流水线：北斗取数 → s1→s5 → v1。

v2 归因周报由 Agent 按 memory/归因思路.md 生成（不调用 s6 脚本）。
异常指标检测仅作中间产物，不保留到最终输出目录。
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from datetime import date, timedelta
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent
SCRIPTS = SKILL_ROOT / "计算脚本"
DATA = SCRIPTS / "数据处理"
FETCH = SCRIPTS / "北斗取数"
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))
from skill_paths import default_deliverable_dir  # noqa: E402


def parse_period_label(text: str) -> str | None:
    """0608～0614 / 6.8～6.14 / 0608-0614 → 0608～0614"""
    text = text.strip().replace("-", "～").replace("~", "～")
    m = re.search(r"(\d{1,2})\.?(\d{1,2})\s*～\s*(\d{1,2})\.?(\d{1,2})", text)
    if not m:
        m2 = re.search(r"(\d{4})\s*～\s*(\d{4})", text.replace(".", ""))
        if m2:
            return f"{m2.group(1)}～{m2.group(2)}"
        return None
    return f"{int(m.group(1)):02d}{int(m.group(2)):02d}～{int(m.group(3)):02d}{int(m.group(4)):02d}"


def last_complete_week_bounds(ref: date | None = None) -> tuple[date, date]:
    """最近一个已结束的完整自然周：周一 00:00 ～ 周日（与 fetch_beidou 口径一致）。"""
    today = ref or date.today()
    days_back = (today.weekday() + 1) % 7
    if days_back == 0:
        days_back = 7
    end_sunday = today - timedelta(days=days_back)
    start_monday = end_sunday - timedelta(days=6)
    return start_monday, end_sunday


def latest_complete_period_label(ref: date | None = None) -> str:
    start, end = last_complete_week_bounds(ref)
    return f"{start.strftime('%m%d')}～{end.strftime('%m%d')}"


def resolve_output_dir(period: str, user_output: str | None) -> Path:
    if user_output:
        return Path(user_output).expanduser().resolve()
    # 默认可交付目录（与历史周报归档一致）；skill/output 仅当显式 -o 时使用
    return default_deliverable_dir(period)


def run_step(cmd: list[str], env: dict[str, str]) -> None:
    print(f"\n>>> {' '.join(cmd)}")
    subprocess.run(cmd, cwd=str(SKILL_ROOT), env=env, check=True)


def period_to_target_week(period: str, ref: date | None = None) -> str:
    """0601～0614 → YYYY-06-01（年份按 ref 推断，跨年则回退一年）。"""
    m = re.match(r"(\d{2})(\d{2})～", period)
    if not m:
        return ""
    mm, dd = int(m.group(1)), int(m.group(2))
    today = ref or date.today()
    monday = date(today.year, mm, dd)
    if monday > today:
        monday = date(today.year - 1, mm, dd)
    return monday.isoformat()


def main() -> None:
    parser = argparse.ArgumentParser(description="周报生成流水线（至 v1）")
    parser.add_argument(
        "--period",
        type=str,
        default="",
        help="周期标签，如 0608～0614；与 --recent 互斥",
    )
    parser.add_argument(
        "--recent",
        action="store_true",
        help="输出近期周报：按日历取最近完整周一～周日，并强制北斗取数覆盖 raw_data",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        type=str,
        default="",
        help="输出目录；默认 app/AB-OCI/专项/AI周报月报/AI周报/{周期}/",
    )
    parser.add_argument("--skip-fetch", action="store_true", help="跳过北斗取数（--recent 时无效）")
    parser.add_argument("--skip-v1", action="store_true", help="跳过 s4 生成 v1")
    args = parser.parse_args()

    recent_mode = args.recent or not args.period
    if args.recent and args.period:
        raise ValueError("不可同时指定 --recent 与 --period")

    if recent_mode:
        start_monday, end_sunday = last_complete_week_bounds()
        period = latest_complete_period_label()
        do_fetch = True
        target_week = start_monday.isoformat()
        print(
            f"近期周报：最近完整周 {start_monday.isoformat()}（周一）～"
            f"{end_sunday.isoformat()}（周日）→ {period}"
        )
        if args.skip_fetch:
            print("⚠️  --recent 模式将强制北斗取数，忽略 --skip-fetch")
    else:
        period = parse_period_label(args.period)
        if not period:
            raise ValueError(f"无法解析周期: {args.period!r}")
        do_fetch = not args.skip_fetch
        target_week = period_to_target_week(period)

    out_dir = resolve_output_dir(period, args.output_dir or None)
    out_dir.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["ZHOUBAO_OUTPUT_DIR"] = str(out_dir)
    env["PYTHONPATH"] = str(SCRIPTS) + os.pathsep + env.get("PYTHONPATH", "")
    if target_week:
        env["ZHOUBAO_TARGET_WEEK"] = target_week

    py = sys.executable
    if do_fetch:
        run_step([py, str(FETCH / "fetch_beidou.py")], env)

    for script in ("s1下钻csv生成.py", "s2贡献度csv生成.py", "s3导出下钻md脚本.py", "s5异常检测.py"):
        run_step([py, str(DATA / script)], env)

    if not args.skip_v1:
        run_step([py, str(DATA / "s4生成v1周报md.py"), "--run-s5"], env)

    anomaly = out_dir / "异常指标检测.md"
    if anomaly.exists():
        anomaly.unlink()
        print(f"\n已移除中间产物: {anomaly.name}")

    print(f"\n✅ 流水线完成")
    print(f"   周期: {period}")
    print(f"   输出: {out_dir}")
    print(f"   下一步: Phase B 按 memory/归因思路.md 生成 weekly_report_v2.md")
    print(f"           Phase D python 计算脚本/convert_weekly_v2.py -o {out_dir}")
    print(f"   可选: Phase C 按 memory/终审专家.md 审核 v2（只读）→ 审核报告.md + weekly_report_v3.md")


if __name__ == "__main__":
    main()

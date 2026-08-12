#!/usr/bin/env python3
"""一键：step1 留存（含幂律/LT）+ 冲突定量 step2～4/YAU。"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent.parent
RUN_RETENTION = SKILL_ROOT / "scripts" / "run_analysis.py"
RUN_CONFLICT = SKILL_ROOT / "scripts" / "run_conflict_steps.py"


def main() -> None:
    ap = argparse.ArgumentParser(description="留存 + 冲突定量全量取数")
    ap.add_argument("--experiment", required=True, help="如 激励广告实验/所有用户")
    ap.add_argument("--start-date", required=True)
    ap.add_argument("--end-date", required=True)
    ap.add_argument("--abcodes", required=True)
    ap.add_argument("--out-root", type=Path, default=SKILL_ROOT / "out")
    ap.add_argument("--env", default="oci")
    ap.add_argument("--project", default="Airbrush")
    ap.add_argument("--new-users-only", action="store_true")
    ap.add_argument("--skip-retention", action="store_true", help="只跑冲突定量 step2～4")
    ap.add_argument("--skip-conflict", action="store_true", help="只跑留存 step1")
    ap.add_argument("--skip-shenzhou", action="store_true", help="留存：跳过神舟（需已有 step1 CSV）")
    args = ap.parse_args()

    common = [
        "--experiment",
        args.experiment,
        "--start-date",
        args.start_date,
        "--end-date",
        args.end_date,
        "--abcodes",
        args.abcodes,
        "--out-root",
        str(args.out_root),
        "--env",
        args.env,
        "--project",
        args.project,
    ]
    if args.new_users_only:
        common.append("--new-users-only")

    if not args.skip_retention:
        cmd = [sys.executable, str(RUN_RETENTION), *common]
        if args.skip_shenzhou:
            cmd.append("--skip-shenzhou")
        print("=== step1 留存 + 幂律/LT ===")
        subprocess.run(cmd, check=True)

    if not args.skip_conflict:
        cmd = [sys.executable, str(RUN_CONFLICT), *common]
        print("\n=== 冲突定量 step2～4 + YAU ===")
        subprocess.run(cmd, check=True)

    print(f"\n全部完成: {args.out_root / args.experiment}")


if __name__ == "__main__":
    main()

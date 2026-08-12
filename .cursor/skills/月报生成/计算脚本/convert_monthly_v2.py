#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase D：将月报 v2/v3 转为 *_converted.md（md_convert）。"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
MD_CONVERT_SCRIPT = (
    SKILL_ROOT.parent / "md_convert" / "convert" / "convert_monthly_report_v2.py"
)


def main() -> None:
    parser = argparse.ArgumentParser(description="月报格式转换（md_convert）")
    parser.add_argument(
        "-o",
        "--output-dir",
        type=str,
        default="",
        help="月报输出目录；默认读环境变量 YUEBAO_OUTPUT_DIR",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        default="",
        help="源 md 路径（默认按 --v3 选择 v2/v3）",
    )
    parser.add_argument(
        "--out",
        type=str,
        default="",
        help="目标路径（默认 *_converted.md）",
    )
    parser.add_argument(
        "--v3",
        action="store_true",
        help="转换 monthly_report_v3.md → monthly_report_v3_converted.md",
    )
    args = parser.parse_args()

    out_dir = args.output_dir or os.environ.get("YUEBAO_OUTPUT_DIR", "")
    if not out_dir:
        print("请指定 --output-dir 或设置 YUEBAO_OUTPUT_DIR", file=sys.stderr)
        sys.exit(1)

    out_path = Path(out_dir).expanduser().resolve()
    if args.input:
        input_file = Path(args.input)
    elif args.v3:
        input_file = out_path / "monthly_report_v3.md"
    else:
        input_file = out_path / "monthly_report_v2.md"

    if args.out:
        output_file = Path(args.out)
    elif args.v3 or input_file.name.startswith("monthly_report_v3"):
        output_file = out_path / "monthly_report_v3_converted.md"
    else:
        output_file = out_path / "monthly_report_v2_converted.md"

    if not input_file.is_file():
        print(f"未找到源文件: {input_file}", file=sys.stderr)
        sys.exit(1)
    if not MD_CONVERT_SCRIPT.is_file():
        print(f"未找到转换脚本: {MD_CONVERT_SCRIPT}", file=sys.stderr)
        sys.exit(1)

    cmd = [
        sys.executable,
        str(MD_CONVERT_SCRIPT),
        "-i",
        str(input_file),
        "-o",
        str(output_file),
    ]
    print(f"\n>>> {' '.join(cmd)}")
    subprocess.run(cmd, check=True)
    print(f"\n✅ converted: {output_file}")


if __name__ == "__main__":
    main()

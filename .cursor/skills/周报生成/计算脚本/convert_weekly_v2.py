#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase D：将周报 v2/v3 转为平台规范版 *_converted.md。"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
MD_CONVERT_SCRIPT = (
    SKILL_ROOT.parent / "md_convert" / "convert" / "convert_weekly_report_v2.py"
)


def preprocess_source(text: str) -> str:
    """v3 等源文件中「背景参考」与 md_convert 知识库字段对齐。"""
    return text.replace("背景参考：", "命中原因：")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="周报格式转换（md_convert）；默认 v2，可用 --v3 转换终审版",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        type=str,
        default="",
        help="周报输出目录；默认读环境变量 ZHOUBAO_OUTPUT_DIR",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        default="",
        help="源文件路径（默认依 --v3 取 weekly_report_v3.md 或 weekly_report_v2.md）",
    )
    parser.add_argument(
        "--out",
        type=str,
        default="",
        help="目标路径（默认依 --v3 取 weekly_report_v3_converted.md 或 weekly_report_v2_converted.md）",
    )
    parser.add_argument(
        "--v3",
        action="store_true",
        help="转换 weekly_report_v3.md → weekly_report_v3_converted.md",
    )
    args = parser.parse_args()

    out_dir = args.output_dir or os.environ.get("ZHOUBAO_OUTPUT_DIR", "")
    if not out_dir:
        print("请指定 --output-dir 或设置 ZHOUBAO_OUTPUT_DIR", file=sys.stderr)
        sys.exit(1)

    out_path = Path(out_dir).expanduser().resolve()
    version = "v3" if args.v3 else "v2"
    default_input = out_path / f"weekly_report_{version}.md"
    default_output = out_path / f"weekly_report_{version}_converted.md"

    input_file = Path(args.input) if args.input else default_input
    output_file = Path(args.out) if args.out else default_output

    if not input_file.is_file():
        print(f"未找到源文件: {input_file}", file=sys.stderr)
        sys.exit(1)
    if not MD_CONVERT_SCRIPT.is_file():
        print(f"未找到转换脚本: {MD_CONVERT_SCRIPT}", file=sys.stderr)
        sys.exit(1)

    src_text = input_file.read_text(encoding="utf-8")
    if "背景参考：" in src_text:
        src_text = preprocess_source(src_text)
        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".md",
            delete=False,
            encoding="utf-8",
        ) as tmp:
            tmp.write(src_text)
            convert_input = tmp.name
    else:
        convert_input = str(input_file)

    cmd = [
        sys.executable,
        str(MD_CONVERT_SCRIPT),
        "-i",
        convert_input,
        "-o",
        str(output_file),
    ]
    print(f"\n>>> {' '.join(cmd)}")
    subprocess.run(cmd, check=True)
    if convert_input != str(input_file):
        Path(convert_input).unlink(missing_ok=True)
    print(f"\n✅ converted: {output_file}")


if __name__ == "__main__":
    main()

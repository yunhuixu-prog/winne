#!/usr/bin/env python3
"""合并神舟分片结果，并输出可复核的完整月聚合文件。"""

from __future__ import annotations

from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"


def merge_grouped_chunks(
    input_dir: Path,
    pattern: str,
    value_columns: list[str],
    output_file: Path,
) -> pd.DataFrame:
    files = sorted(input_dir.glob(pattern))
    if not files:
        raise FileNotFoundError(f"没有匹配到分片文件: {input_dir / pattern}")

    frames = [pd.read_csv(path, encoding="utf-8-sig") for path in files]
    source_rows = sum(len(frame) for frame in frames)
    merged = pd.concat(frames, ignore_index=True)
    for column in value_columns:
        merged[column] = pd.to_numeric(merged[column], errors="raise")
    dimensions = [column for column in merged.columns if column not in value_columns]
    result = (
        merged.groupby(dimensions, dropna=False, as_index=False)[value_columns]
        .sum()
        .sort_values(dimensions, kind="stable")
    )
    result.to_csv(output_file, index=False, encoding="utf-8-sig")

    print(f"files={len(files)} source_rows={source_rows:,} merged_rows={len(result):,}")
    print(f"output={output_file}")
    return result


def main() -> None:
    path_df = merge_grouped_chunks(
        OUT / "02_会话路径分片",
        "滤镜编辑会话路径_*.csv",
        ["edit_trace_count"],
        OUT / "02_巴西滤镜编辑会话路径_202607.csv",
    )
    checks = (
        path_df.groupby("country_group", as_index=False)["edit_trace_count"]
        .sum()
        .sort_values("edit_trace_count", ascending=False)
    )
    print("\n编辑会话数（至少完成一次 Filters material_check）：")
    print(checks.to_string(index=False))


if __name__ == "__main__":
    main()

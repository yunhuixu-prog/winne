#!/usr/bin/env python3
"""合并 first_func_enter 路径分片与“每次打勾”滑杆分片，并输出基础 QA。"""

from pathlib import Path
import pandas as pd


ROOT = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
)


def merge_grouped(input_dir: Path, pattern: str, metric: str, output: Path) -> pd.DataFrame:
    files = sorted(input_dir.glob(pattern))
    if len(files) != 5:
        raise RuntimeError(f"期望5个分片，实际{len(files)}个：{input_dir}")

    frames = [pd.read_csv(path, encoding="utf-8-sig") for path in files]
    merged = pd.concat(frames, ignore_index=True)
    if metric not in merged.columns:
        raise KeyError(f"缺少计数字段 {metric}：{list(merged.columns)}")

    dims = [column for column in merged.columns if column != metric]
    result = (
        merged.groupby(dims, dropna=False, as_index=False)[metric]
        .sum()
        .sort_values(metric, ascending=False)
    )
    result.to_csv(output, index=False, encoding="utf-8-sig")
    return result


def main() -> None:
    path = merge_grouped(
        ROOT / "02C_会话路径分片_first_func_enter",
        "02C_巴西滤镜编辑会话路径_first_func_enter_*.csv",
        "edit_trace_count",
        ROOT / "02_巴西滤镜编辑会话路径_202607_first_func_enter.csv",
    )
    slider = merge_grouped(
        ROOT / "02D_滑杆分布分片_每次打勾",
        "02D_巴西滤镜滑杆分布_每次打勾_*.csv",
        "material_check_pv",
        ROOT / "02B_巴西滤镜滑杆分布_202607_每次打勾.csv",
    )

    path_total = int(path["edit_trace_count"].sum())
    path_enter = int(
        path.loc[path["has_filter_enter"] == 1, "edit_trace_count"].sum()
    )
    slider_total = int(slider["material_check_pv"].sum())
    slider_missing = int(
        slider.loc[slider["filters_value_raw"].astype(str) == "Missing", "material_check_pv"].sum()
    )

    print(f"路径编辑会话数: {path_total:,}")
    print(f"入口命中率: {path_enter / path_total:.2%}")
    print(f"滑杆打勾事件PV: {slider_total:,}")
    print(f"filters_value缺失率: {slider_missing / slider_total:.2%}")
    print("默认值来源分布:")
    source = slider.groupby("default_value_source")["material_check_pv"].sum().sort_values(ascending=False)
    for name, value in source.items():
        print(f"  {name}: {int(value):,} ({value / slider_total:.2%})")


if __name__ == "__main__":
    main()

from pathlib import Path
import subprocess

import pandas as pd


QUERY_TOOL = (
    "/Users/xuyunhui/.agents/skills/shenzhou-temp-query/scripts/temp_query.py"
)
BASE_DIR = Path(
    "/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项"
)
OUTPUT_DIR = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302"
)
CHUNKS = [
    (20260601, 20260605),
    (20260606, 20260610),
    (20260611, 20260615),
    (20260616, 20260620),
    (20260621, 20260625),
    (20260626, 20260630),
]
MARKETS = ["整体", "巴西"]


for market in MARKETS:
    base_sql_path = (
        BASE_DIR / f"Face_Jaw_Nose滑杆值分布_{market}_202606.sql"
    )
    base_sql = base_sql_path.read_text(encoding="utf-8")
    chunk_files = []
    for start_date, end_date in CHUNKS:
        sql = base_sql.replace(
            "BETWEEN 20260601 AND 20260630",
            f"BETWEEN {start_date} AND {end_date}",
        )
        output = OUTPUT_DIR / (
            f"Face_Jaw_Nose滑杆值分布_{market}_{start_date}_{end_date}.csv"
        )
        command = [
            "python3",
            QUERY_TOOL,
            "run",
            "--sql",
            sql,
            "--project",
            "Airbrush",
            "--env",
            "oci",
            "--engine",
            "hive",
            "--wait",
            "--download",
            "-o",
            str(output),
        ]
        print(
            f"Running {market} {start_date}-{end_date}",
            flush=True,
        )
        subprocess.run(command, check=True)
        chunk_files.append(output)

    frames = [pd.read_csv(path, encoding="utf-8-sig") for path in chunk_files]
    merged = pd.concat(frames, ignore_index=True)
    value_col = "value_count"
    merged[value_col] = pd.to_numeric(merged[value_col], errors="coerce").fillna(0)
    group_cols = [
        "market_name",
        "feature_name",
        "subitem_name",
        "raw_value",
    ]
    merged = (
        merged.groupby(group_cols, dropna=False, as_index=False)[value_col]
        .sum()
        .sort_values(["feature_name", "subitem_name", "raw_value"])
    )
    merged.to_csv(
        OUTPUT_DIR / f"Face_Jaw_Nose滑杆值分布_{market}_202606.csv",
        index=False,
        encoding="utf-8-sig",
    )

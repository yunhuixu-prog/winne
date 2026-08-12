from pathlib import Path
import subprocess


BASE_SQL = Path(
    "/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/"
    "Adjust打勾同时使用子项数分布_巴西_202606.sql"
)
QUERY_TOOL = (
    "/Users/xuyunhui/.agents/skills/shenzhou-temp-query/scripts/temp_query.py"
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


base_sql = BASE_SQL.read_text(encoding="utf-8")
for start_date, end_date in CHUNKS:
    sql = base_sql.replace(
        "BETWEEN 20260601 AND 20260630",
        f"BETWEEN {start_date} AND {end_date}",
    )
    output = OUTPUT_DIR / (
        f"Adjust打勾同时使用子项数分布_巴西_{start_date}_{end_date}.csv"
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
        "presto",
        "--wait",
        "--download",
        "-o",
        str(output),
    ]
    print(f"Running {start_date}-{end_date}", flush=True)
    subprocess.run(command, check=True)

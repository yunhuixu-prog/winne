from pathlib import Path
import subprocess


QUERY_TOOL = (
    "/Users/xuyunhui/.agents/skills/shenzhou-temp-query/scripts/temp_query.py"
)
SQL_FILE = Path(
    "/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/"
    "AI任务成功率及耗时_巴西vs整体_202606.sql"
)
OUTPUT_DIR = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302"
)


sql_parts = SQL_FILE.read_text(encoding="utf-8").split("\nUNION ALL\n")
if len(sql_parts) != 2:
    raise RuntimeError(f"Expected 2 SQL parts, found {len(sql_parts)}")

jobs = [
    ("整体", sql_parts[0]),
    ("巴西", sql_parts[1]),
]

for market, sql in jobs:
    output = OUTPUT_DIR / f"AI任务成功率及耗时_{market}_202606.csv"
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
    print(f"Running {market}", flush=True)
    subprocess.run(command, check=True)

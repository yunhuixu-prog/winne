#!/usr/bin/env python3
"""
冲突定量选择 step2～4 + YAU：神舟取数 → arpdau / enter_ratio / yau / bookings。

默认从 skill/sql/*.sql 读模板；可用 --source-sql 从主仓库冲突定量选择.sql 按段解析。
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = SKILL_ROOT / "sql"
PROJECT_ROOT = SKILL_ROOT.parent.parent.parent
DEFAULT_SOURCE_SQL = PROJECT_ROOT / "app/ab新sdk/实验/激励广告实验/冲突定量选择.sql"
SHENZHOU_SCRIPT = Path.home() / ".agents/skills/shenzhou-temp-query/scripts/temp_query.py"

SEGMENTS = [
    ("step2", "step2_arpdau.sql", "arpdau.csv"),
    ("step3", "step3_enter_ratio.sql", "enter_ratio.csv"),
    ("YAU", "yau.sql", "yau.csv"),
    ("step4", "step4_bookings.sql", "bookings.csv"),
]


def parse_date(s: str) -> datetime:
    s = s.strip().replace("-", "")
    if len(s) != 8 or not s.isdigit():
        raise ValueError(f"日期须为 yyyymmdd，收到: {s}")
    return datetime.strptime(s, "%Y%m%d")


def format_abcode_in_list(codes: list[str]) -> str:
    return ",".join(f"'{c.strip()}'" for c in codes if c.strip())


def build_repl(start_dt: datetime, end_dt: datetime, abcodes: list[str]) -> dict[str, str]:
    return {
        "${start_date}": start_dt.strftime("%Y%m%d"),
        "${end_date}": end_dt.strftime("%Y%m%d"),
        "${end_date_p7}": (end_dt + timedelta(days=7)).strftime("%Y%m%d"),
        "${end_date_p90}": (end_dt + timedelta(days=90)).strftime("%Y%m%d"),
        "${end_date_m365}": (end_dt - timedelta(days=365)).strftime("%Y%m%d"),
        "${abcode_in_list}": format_abcode_in_list(abcodes),
    }


def enter_new_sql_fragment(new_users_only: bool) -> str:
    """与 run_analysis.py / step1 一致：默认空，限制新用户时注入。"""
    return "\n          AND enter_new = 1" if new_users_only else ""


def substitute(sql: str, repl: dict[str, str], new_users_only: bool) -> str:
    full = {
        **repl,
        "${enter_new_sql}": enter_new_sql_fragment(new_users_only),
    }
    for k, v in full.items():
        sql = sql.replace(k, v)
    sql = re.sub(
        r"params\['current_abcode'\]\s+IN\s*\([^)]+\)",
        f"params['current_abcode'] IN ({repl['${abcode_in_list}']})",
        sql,
    )
    return sql


def extract_segments_from_file(path: Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    markers: list[tuple[str, int]] = []
    for i, line in enumerate(lines):
        for tag in ("step2", "step3", "YAU", "step4"):
            if line.startswith(f"-- {tag}"):
                markers.append((tag, i))
    markers.sort(key=lambda x: x[1])
    out: dict[str, str] = {}
    for idx, (name, start) in enumerate(markers):
        end = markers[idx + 1][1] if idx + 1 < len(markers) else len(lines)
        sql_lines: list[str] = []
        in_select = False
        for ln in lines[start:end]:
            if ln.strip().upper().startswith("SELECT"):
                in_select = True
            if in_select:
                sql_lines.append(ln)
                if ln.strip().endswith(";"):
                    break
        out[name] = "\n".join(sql_lines).strip()
    return out


def load_segment(seg_key: str, tpl_name: str, source_sql: Path | None) -> str:
    tpl_path = SQL_DIR / tpl_name
    if tpl_path.is_file():
        return tpl_path.read_text(encoding="utf-8")
    if source_sql and source_sql.is_file():
        return extract_segments_from_file(source_sql)[seg_key]
    raise FileNotFoundError(f"缺少 SQL 模板: {tpl_path}")


def run_shenzhou(sql_path: Path, csv_out: Path, env: str, project: str) -> None:
    if not SHENZHOU_SCRIPT.is_file():
        raise FileNotFoundError(f"未找到神舟脚本: {SHENZHOU_SCRIPT}")
    for engine in ("presto", "hive"):
        cmd = [
            sys.executable,
            str(SHENZHOU_SCRIPT),
            "run",
            "--sql-file",
            str(sql_path),
            "--project",
            project,
            "--env",
            env,
            "--engine",
            engine,
            "--wait",
            "--download",
            "-o",
            str(csv_out),
        ]
        print(f"[shenzhou] {csv_out.name} engine={engine}")
        try:
            subprocess.run(cmd, check=True)
            return
        except subprocess.CalledProcessError:
            if engine == "presto":
                print("  presto 失败，改用 hive on spark…")
            else:
                raise


def run(
    experiment: str,
    start_date: str,
    end_date: str,
    abcodes: str,
    out_root: Path,
    env: str,
    project: str,
    new_users_only: bool,
    source_sql: Path | None,
) -> Path:
    start_dt = parse_date(start_date)
    end_dt = parse_date(end_date)
    codes = [c.strip() for c in abcodes.replace("，", ",").split(",") if c.strip()]
    if not codes:
        raise SystemExit("至少提供一个 abcode")
    repl = build_repl(start_dt, end_dt, codes)
    out_dir = out_root / experiment
    out_dir.mkdir(parents=True, exist_ok=True)
    nou = "是" if new_users_only else "否（全量进入用户）"
    print(f"冲突定量 step2～4+YAU | 仅新用户: {nou} | 目录: {out_dir}\n")

    for seg_key, tpl_name, out_name in SEGMENTS:
        sql = substitute(load_segment(seg_key, tpl_name, source_sql), repl, new_users_only)
        sql_path = out_dir / f"{seg_key}.sql"
        csv_path = out_dir / out_name
        sql_path.write_text(sql, encoding="utf-8")
        run_shenzhou(sql_path, csv_path, env, project)
        print(f"  -> {csv_path}\n")
    return out_dir


def main() -> None:
    ap = argparse.ArgumentParser(description="冲突定量 step2～4 + YAU 神舟取数")
    ap.add_argument("--experiment", required=True, help="产出目录 out/<实验名>/，如 激励广告实验/所有用户")
    ap.add_argument("--start-date", required=True)
    ap.add_argument("--end-date", required=True)
    ap.add_argument("--abcodes", required=True)
    ap.add_argument("--out-root", type=Path, default=SKILL_ROOT / "out")
    ap.add_argument("--env", default="oci")
    ap.add_argument("--project", default="Airbrush")
    ap.add_argument("--new-users-only", action="store_true")
    ap.add_argument(
        "--source-sql",
        type=Path,
        default=None,
        help="可选：从该文件按注释段解析 SQL（默认用 skill/sql/ 模板）",
    )
    args = ap.parse_args()
    out_dir = run(
        args.experiment,
        args.start_date,
        args.end_date,
        args.abcodes,
        args.out_root,
        args.env,
        args.project,
        args.new_users_only,
        args.source_sql,
    )
    print(f"完成: {out_dir}")
    print("  arpdau.csv | enter_ratio.csv | yau.csv | bookings.csv")


if __name__ == "__main__":
    main()

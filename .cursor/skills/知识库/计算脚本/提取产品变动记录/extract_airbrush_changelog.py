#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 Pixocial产品数据变动记录.xlsx 提取 AirBrush sheet 为 Markdown 知识库。"""
from __future__ import annotations

import re
from pathlib import Path

import pandas as pd

import sys

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))
from skill_paths import kb_raw_dir

XLSX = kb_raw_dir("其他") / "Pixocial产品数据变动记录.xlsx"
OUT_DIR = kb_raw_dir("知识库") / "manual"

HOLIDAY_CALENDAR = {
    "复活节": {"note": "西方/东正教偶合同日", "dates": {"2024": "2024-03-31", "2025": "2025-04-20", "2026": "2026-04-05"}},
    "开斋节": {"note": "伊斯兰历", "dates": {"2024": "2024-04-10", "2025": "2025-03-30", "2026": "2026-03-20"}},
    "宰牲节": {"note": "伊斯兰历；南亚 DAU", "dates": {"2024": "2024-06-17", "2025": "2025-06-07", "2026": "2026-05-27"}},
    "巴西狂欢节": {
        "note": "Carnaval 末段；促销常 2 月底～3 月上旬",
        "dates": {"2024": "2024-02-13", "2025": "2025-03-03", "2026": "2026-02-17"},
        "periods": {"2025": "2025-02-28～2025-03-04（3/2～3/3 里约游行）"},
    },
    "Festa Junina/六月节": {"note": "巴西六月节整月", "dates": {"2024": "2024-06", "2025": "2025-06", "2026": "2026-06"}},
    "美国母亲节": {"note": "5 月第二个周日", "dates": {"2024": "2024-05-12", "2025": "2025-05-11", "2026": "2026-05-10"}},
    "俄罗斯胜利日": {"note": "固定 5/9", "dates": {"2024": "2024-05-09", "2025": "2025-05-09", "2026": "2026-05-09"}},
    "俄罗斯国庆节": {"note": "固定 6/12", "dates": {"2024": "2024-06-12", "2025": "2025-06-12", "2026": "2026-06-12"}},
    "俄罗斯青年节/红帆节": {"note": "6 月最后一个周六", "dates": {"2024": "2024-06-29", "2025": "2025-06-28", "2026": "2026-06-27"}},
    "情人节": {"note": "2/14；巴西另有 6/12", "dates": {"2024": "2024-02-14", "2025": "2025-02-14", "2026": "2026-02-14"}},
    "万圣节": {"note": "10/31", "dates": {"2024": "2024-10-31", "2025": "2025-10-31", "2026": "2026-10-31"}},
    "黑五": {"note": "感恩节次日", "dates": {"2024": "2024-11-29", "2025": "2025-11-28", "2026": "2026-11-27"}},
    "圣诞节": {"note": "12/25", "dates": {"2024": "2024-12-25", "2025": "2025-12-25", "2026": "2026-12-25"}},
    "新年": {"note": "跨年", "dates": {"2024": "2024-12-31～2025-01-01", "2025": "2025-12-31～2026-01-01"}},
    "五一劳动节": {"note": "5/1", "dates": {"2024": "2024-05-01", "2025": "2025-05-01", "2026": "2026-05-01"}},
    "妇女节": {"note": "3/8", "dates": {"2024": "2024-03-08", "2025": "2025-03-08", "2026": "2026-03-08"}},
    "圣帕特里克节": {"note": "3/17", "dates": {"2024": "2024-03-17", "2025": "2025-03-17", "2026": "2026-03-17"}},
}

HOLIDAY_ALIASES = [
    (r"复活节|Easter", "复活节"),
    (r"开斋节", "开斋节"),
    (r"宰牲节", "宰牲节"),
    (r"狂欢节|Carnival", "巴西狂欢节"),
    (r"六月节|Festa Junina", "Festa Junina/六月节"),
    (r"母亲节", "美国母亲节"),
    (r"胜利日", "俄罗斯胜利日"),
    (r"俄罗斯国庆节", "俄罗斯国庆节"),
    (r"青年节|红帆节", "俄罗斯青年节/红帆节"),
    (r"情人节", "情人节"),
    (r"万圣节", "万圣节"),
    (r"黑五", "黑五"),
    (r"圣诞节", "圣诞节"),
    (r"新年", "新年"),
    (r"劳动节|五一", "五一劳动节"),
    (r"妇女节", "妇女节"),
    (r"圣帕特里克", "圣帕特里克节"),
]


def clean(val) -> str:
    if pd.isna(val):
        return ""
    s = str(val).strip()
    return "" if s == "nan" else s


def detect_holidays(text: str) -> list[str]:
    found: list[str] = []
    for pat, name in HOLIDAY_ALIASES:
        if re.search(pat, text, re.I) and name not in found:
            found.append(name)
    return found


def calendar_hint(names: list[str]) -> str:
    lines = []
    for n in names:
        info = HOLIDAY_CALENDAR.get(n)
        if not info:
            continue
        ds = "；".join(f"{y}={d}" for y, d in sorted(info["dates"].items()))
        lines.append(f"  - **{n}**（{info['note']}）→ {ds}")
    return "\n".join(lines)


def write_holiday_calendar() -> None:
    lines = [
        "# AirBrush 节日公历对照（2024～2026）",
        "",
        "> 来源：Pixocial产品数据变动记录.xlsx / AirBrush sheet + 公历换算",
        "> **周报归因必查**：移动节日不可沿用去年日期",
        "",
    ]
    for name, info in HOLIDAY_CALENDAR.items():
        lines += [f"## {name}", info["note"], ""]
        for y in sorted(info["dates"]):
            lines.append(f"- **{y}**：{info['dates'][y]}")
        if "periods" in info:
            lines += ["", "活动/游行窗口："]
            for y, p in sorted(info["periods"].items()):
                lines.append(f"- {y}：{p}")
        lines.append("")
    (OUT_DIR / "airbrush-holiday-calendar-2024-2026.md").write_text("\n".join(lines), encoding="utf-8")


def write_changelog() -> None:
    df = pd.read_excel(XLSX, sheet_name="AirBrush", header=0)
    df.columns = ["time_range", "change_type", "data_impact", "change_content", "notes"]
    lines = [
        "# AirBrush 产品数据变动记录",
        "",
        "> 来源：`raw_data/其他/Pixocial产品数据变动记录.xlsx` → **AirBrush** sheet",
        "> 用途：周报归因知识库；**节日须对照「节日公历对照表」按年份匹配**",
        "",
        "## 节日公历对照表（2024～2026）",
        "",
        "| 节日 | 说明 | 2024 | 2025 | 2026 |",
        "|------|------|------|------|------|",
    ]
    for name, info in HOLIDAY_CALENDAR.items():
        d = info["dates"]
        lines.append(f"| {name} | {info['note']} | {d.get('2024','')} | {d.get('2025','')} | {d.get('2026','')} |")
    lines += ["", "## 变动记录（倒序）", ""]
    for idx, row in df.iterrows():
        if idx == 0:
            continue
        tr = clean(row.time_range)
        if not tr and not clean(row.data_impact) and not clean(row.change_content):
            continue
        ctype, impact, content, notes = map(clean, [row.change_type, row.data_impact, row.change_content, row.notes])
        blob = " ".join([tr, ctype, impact, content, notes])
        lines.append(f"### {tr or '(无时间)'}")
        if ctype:
            lines.append(f"- **变动类型**：{ctype}")
        if impact:
            lines.append(f"- **数据影响**：{impact.replace(chr(10), '；')}")
        if content:
            lines.append(f"- **变动内容**：{content.replace(chr(10), '；')}")
        if notes:
            lines.append(f"- **备注**：{notes.replace(chr(10), '；')}")
        holidays = detect_holidays(blob)
        if holidays:
            hint = calendar_hint(holidays)
            if hint:
                lines += ["- **节日公历对照**（按年匹配）：", hint]
        lines.append("")
    (OUT_DIR / "airbrush-product-data-changelog.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    if not XLSX.exists():
        raise FileNotFoundError(XLSX)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    write_holiday_calendar()
    write_changelog()
    print(f"OK: {OUT_DIR}/airbrush-product-data-changelog.md")
    print(f"OK: {OUT_DIR}/airbrush-holiday-calendar-2024-2026.md")


if __name__ == "__main__":
    main()

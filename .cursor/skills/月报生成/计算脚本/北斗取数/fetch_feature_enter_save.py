#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""功能类需求：版本上线前后进入保存率 + 进入渗透率（路径 B 补取数）。

看板：OCI / oci，Dashboard 10015706
  - Chart 90628：进入保存率 = 保存uv/进入uv（日均）
  - Chart 90774：进入渗透率（看板字段，日均）
筛选：平台/国家/新老/渠道自然/付费状态/版本=整体，一级功能=图片编辑，二级功能=候选功能
日期：上线前 [launch-14, launch-1]、上线后 [launch, launch+13]，aggr=DAY
相对变动=(后-前)/前

总结入选门槛（满足任一）：
  规则1：进入保存率相对变动 >5% 且 进入渗透率相对变动 > -3%
  规则2：进入保存率相对变动 > -3% 且 进入渗透率相对变动 >10%
  规则3：完全新增功能（上线前渗透率/进入量为测试量级，允许少量灰度数据）；
        相对变动列记「新功能」；上线后日均进入渗透率 >5% 可入选总结

功能名匹配：先原名；未命中 options，或原名取数无效时，再试「AI {原名}」
Skin：看板二级「Skin」无聚合进入保存率/渗透率，拆解到 Skin 时须再映射至子功能
（如 Smooth、Clean Skin、Redness Fix 等）再取数；子功能名从需求 name/desc 与 options 匹配。
版本后有效日数不足 7 天：不计算前后对比，status=数据不足7天。

用法：
  python 计算脚本/北斗取数/fetch_feature_enter_save.py \\
    --launch 20260617 --feature Face --name "Face新增3D骨相还原" \\
    -o output/202606/业务举措/

  python 计算脚本/北斗取数/fetch_feature_enter_save.py \\
    --candidates candidates.json -o output/202606/业务举措/
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from skill_paths import skill_root

DASHBOARD_ID = 10015706
CHART_ENTER_SAVE = 90628
CHART_ENTER_PENETRATION = 90774
ENV = "oci"
LEVEL1 = "图片编辑"
WINDOW_DAYS = 14
MIN_AFTER_DAYS = 7
# 总结门槛
SAVE_UPLIFT_MIN = 0.05  # 规则1：保存率 >5%
REL_FLOOR = -0.03  # 规则1：渗透率 > -3%；规则2：保存率 > -3%
PEN_UPLIFT_MIN = 0.10  # 规则2：渗透率 >10%
NEW_FEATURE_PEN_AFTER_MIN = 0.05  # 规则3：新功能上线后日均进入渗透率 >5%
# 完全新增判定：上线前允许少量测试/灰度，用阈值而非严格为 0
NEW_FEATURE_PEN_BEFORE_MAX = 0.01  # 上线前日均进入渗透率 ≤1% 视为测试量级
NEW_FEATURE_ENTER_UV_BEFORE_MAX = 300  # 上线前日均进入 uv ≤300 视为测试量级


def resolve_beidou_tool_dir() -> str:
    base = skill_root()
    candidates = [
        base.resolve().parents[3]
        / "参考文档"
        / "分析下钻报告实现过程"
        / ".agents"
        / "skills"
        / "beidou-dashboard-data"
        / "scripts",
        Path.home() / ".agents/skills/beidou-dashboard-data/scripts",
    ]
    for p in candidates:
        if (p / "beidou_tool_api.py").is_file():
            return str(p)
    raise RuntimeError("未找到 beidou_tool_api.py")


def ensure_token() -> None:
    if os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip():
        return
    token_file = skill_root() / "memory" / "token.txt"
    if token_file.is_file():
        content = token_file.read_text(encoding="utf-8").strip()
        token = content.split("=", 1)[1].strip() if content.startswith("token=") else content
        if token:
            os.environ["OMNIBUS_ACCESS_TOKEN"] = token
            return
    raise RuntimeError("未读取到 OMNIBUS_ACCESS_TOKEN")


def call_dashboard_data(params: dict[str, Any]) -> dict[str, Any]:
    ensure_token()
    tool_dir = resolve_beidou_tool_dir()
    if tool_dir not in sys.path:
        sys.path.insert(0, tool_dir)
    from beidou_tool_api import BeidouToolClient, _build_dashboard_body, _resolve_base_url

    body = _build_dashboard_body(params)
    client = BeidouToolClient(base_url=_resolve_base_url(env=ENV))
    response = client.dashboard_data(body=body)
    if isinstance(response, dict) and response.get("code") not in (0, 200, None):
        raise RuntimeError(f"北斗接口错误: {response.get('message')}")
    return response


def parse_launch(value: str) -> date:
    raw = value.strip().replace("-", "").replace("/", "")
    if len(raw) == 8 and raw.isdigit():
        return date(int(raw[:4]), int(raw[4:6]), int(raw[6:8]))
    raise ValueError(f"上线日格式无效: {value}（期望 YYYYMMDD）")


def ymd(d: date) -> str:
    return d.strftime("%Y%m%d")


def list_level2_options() -> list[str]:
    resp = call_dashboard_data({"dashboard_id": DASHBOARD_ID, "include_response": False})
    inner = resp.get("response", resp) if isinstance(resp, dict) else resp
    if isinstance(inner, dict) and "linkageConfig" not in inner:
        inner = inner.get("response", inner)
    linkage = (inner or {}).get("linkageConfig", {}) if isinstance(inner, dict) else {}
    for item in linkage.get("filters", []):
        if item.get("name") == "二级功能":
            return [str(x) for x in (item.get("options") or item.get("value") or [])]
    return []


def _match_option(name: str, opts: list[str]) -> str | None:
    if name in opts:
        return name
    lower = {o.lower(): o for o in opts}
    return lower.get(name.lower())


def resolve_feature_candidates(
    feature: str, options: list[str] | None = None
) -> list[str]:
    opts = options if options is not None else list_level2_options()
    raw = feature.strip()
    ordered: list[str] = []

    def _add(name: str) -> None:
        hit = _match_option(name, opts)
        if hit and hit not in ordered:
            ordered.append(hit)

    _add(raw)
    if not raw.lower().startswith("ai "):
        _add(f"AI {raw}")
    return ordered


def resolve_feature(feature: str, options: list[str] | None = None) -> str | None:
    cands = resolve_feature_candidates(feature, options)
    return cands[0] if cands else None


# 看板有「Skin」option 但无整体聚合数据，路径 B 须下钻至子功能
SKIN_LEAF_ALIASES: list[tuple[str, str]] = [
    ("磨皮", "Smooth"),
    ("smooth", "Smooth"),
    ("clean skin", "Clean Skin"),
    ("redness fix", "Redness Fix"),
    ("skin tone", "Skin Tone"),
    ("去红", "Redness Fix"),
    ("红润", "Redness"),
]


def _is_skin_parent(feature: str) -> bool:
    return feature.strip().lower() == "skin"


def resolve_skin_leaf_candidates(
    name: str, desc: str, options: list[str]
) -> list[str]:
    """从需求文案匹配看板二级中的 Skin 子功能（排除聚合项 Skin）。"""
    text = f"{name} {desc}"
    text_lower = text.lower()
    text_compact = text_lower.replace(" ", "")
    ordered: list[str] = []

    def _add(opt_name: str) -> None:
        hit = _match_option(opt_name, options)
        if not hit:
            return
        if hit.strip().lower() == "skin":
            return
        if hit not in ordered:
            ordered.append(hit)

    for kw, opt in SKIN_LEAF_ALIASES:
        kw_l = kw.lower()
        if kw_l in text_lower or kw_l.replace(" ", "") in text_compact:
            _add(opt)

    for opt in sorted(options, key=len, reverse=True):
        ol = opt.strip().lower()
        if ol in ("", "skin"):
            continue
        if ol in text_lower or ol.replace(" ", "") in text_compact:
            _add(opt)

    return ordered


def expand_feature_candidates(
    feature_raw: str,
    name: str,
    desc: str,
    options: list[str] | None = None,
) -> list[str]:
    """路径 B 功能候选：Skin 父级直接展开为子功能，其余走二级原名 / AI 前缀。"""
    opts = options if options is not None else list_level2_options()
    if _is_skin_parent(feature_raw):
        leaf = resolve_skin_leaf_candidates(name, desc, opts)
        if leaf:
            return leaf
    return resolve_feature_candidates(feature_raw, opts)


def extract_chart_rows(response: dict[str, Any], chart_id: int) -> list[dict[str, Any]]:
    inner = response.get("response", response) if isinstance(response, dict) else response
    data = inner.get("data") if isinstance(inner, dict) else None
    if not isinstance(data, list):
        return []
    for chart in data:
        if not isinstance(chart, dict):
            continue
        if int(chart.get("chartID") or chart.get("chartId") or 0) != chart_id:
            continue
        rows = chart.get("data")
        return rows if isinstance(rows, list) else []
    if data and isinstance(data[0], dict):
        rows = data[0].get("data")
        return rows if isinstance(rows, list) else []
    return []


def _base_filters(feature: str, start: date, end: date) -> list[dict[str, Any]]:
    return [
        {"name": "日期", "value": [ymd(start), ymd(end)]},
        {"name": "平台", "value": ["整体"]},
        {"name": "国家", "value": ["整体"]},
        {"name": "新老", "value": ["整体"]},
        {"name": "渠道/自然", "value": ["整体"]},
        {"name": "付费状态", "value": ["整体"]},
        {"name": "版本", "value": ["整体"]},
        {"name": "一级功能", "value": [LEVEL1]},
        {"name": "二级功能", "value": [feature]},
    ]


def fetch_enter_save_daily(feature: str, start: date, end: date) -> pd.DataFrame:
    resp = call_dashboard_data(
        {
            "dashboard_id": DASHBOARD_ID,
            "chart_id": [CHART_ENTER_SAVE],
            "filters": _base_filters(feature, start, end),
            "aggr": "DAY",
        }
    )
    rows = extract_chart_rows(resp, CHART_ENTER_SAVE)
    if not rows:
        return pd.DataFrame()
    df = pd.DataFrame(rows)
    colmap = {}
    for c in df.columns:
        cl = str(c).lower().replace(" ", "")
        if "日期" in str(c):
            colmap[c] = "日期"
        elif cl in ("进入uv",) or str(c) == "进入uv":
            colmap[c] = "进入uv"
        elif cl in ("保存uv",) or str(c) == "保存uv":
            colmap[c] = "保存uv"
    df = df.rename(columns=colmap)
    if "日期" not in df.columns or "进入uv" not in df.columns or "保存uv" not in df.columns:
        return pd.DataFrame()
    df["日期"] = pd.to_datetime(df["日期"], errors="coerce").dt.date
    df["进入uv"] = pd.to_numeric(df["进入uv"], errors="coerce")
    df["保存uv"] = pd.to_numeric(df["保存uv"], errors="coerce")
    df = df.dropna(subset=["日期", "进入uv", "保存uv"])
    df = df[(df["日期"] >= start) & (df["日期"] <= end)]
    df["进入保存率"] = df.apply(
        lambda r: (float(r["保存uv"]) / float(r["进入uv"]))
        if float(r["进入uv"]) > 0
        else float("nan"),
        axis=1,
    )
    return df.sort_values("日期").reset_index(drop=True)


def fetch_enter_penetration_daily(feature: str, start: date, end: date) -> pd.DataFrame:
    resp = call_dashboard_data(
        {
            "dashboard_id": DASHBOARD_ID,
            "chart_id": [CHART_ENTER_PENETRATION],
            "filters": _base_filters(feature, start, end),
            "aggr": "DAY",
        }
    )
    rows = extract_chart_rows(resp, CHART_ENTER_PENETRATION)
    if not rows:
        return pd.DataFrame()
    df = pd.DataFrame(rows)
    colmap = {}
    for c in df.columns:
        if "日期" in str(c):
            colmap[c] = "日期"
        elif "进入渗透率" in str(c):
            colmap[c] = "进入渗透率"
    df = df.rename(columns=colmap)
    if "日期" not in df.columns or "进入渗透率" not in df.columns:
        return pd.DataFrame()
    df["日期"] = pd.to_datetime(df["日期"], errors="coerce").dt.date
    df["进入渗透率"] = pd.to_numeric(df["进入渗透率"], errors="coerce")
    df = df.dropna(subset=["日期", "进入渗透率"])
    df = df[(df["日期"] >= start) & (df["日期"] <= end)]
    return df.sort_values("日期").reset_index(drop=True)


def _pen_before_test_level(pen_before: pd.DataFrame) -> bool:
    if pen_before.empty:
        return True
    vals = pd.to_numeric(pen_before["进入渗透率"], errors="coerce").fillna(0)
    return float(vals.mean()) <= NEW_FEATURE_PEN_BEFORE_MAX


def _save_before_test_level(save_before: pd.DataFrame) -> bool:
    if save_before.empty:
        return True
    uv = pd.to_numeric(save_before["进入uv"], errors="coerce").fillna(0)
    return float(uv.mean()) <= NEW_FEATURE_ENTER_UV_BEFORE_MAX


def _is_fully_new_feature(
    save_before: pd.DataFrame, pen_before: pd.DataFrame
) -> bool:
    """上线前渗透率/进入 uv 处于测试量级（非正式放量；允许少量灰度数据）。"""
    return _pen_before_test_level(pen_before) and _save_before_test_level(
        save_before
    )


def _eligible(save_rel: float, pen_rel: float) -> tuple[bool, str]:
    """Return (eligible, rule_label)."""
    if save_rel > SAVE_UPLIFT_MIN and pen_rel > REL_FLOOR:
        return True, "规则1"
    if save_rel > REL_FLOOR and pen_rel > PEN_UPLIFT_MIN:
        return True, "规则2"
    return False, ""


def analyze_one(
    *,
    launch: date,
    feature_raw: str,
    name: str,
    desc: str = "",
    level2_options: list[str] | None = None,
) -> dict[str, Any]:
    candidates = expand_feature_candidates(
        feature_raw, name, desc, level2_options
    )
    skin_parent = _is_skin_parent(feature_raw)
    before_start = launch - timedelta(days=WINDOW_DAYS)
    before_end = launch - timedelta(days=1)
    after_start = launch
    after_end = launch + timedelta(days=WINDOW_DAYS - 1)

    base: dict[str, Any] = {
        "name": name,
        "desc": desc,
        "launch": ymd(launch),
        "feature_requested": feature_raw,
        "feature_resolved": "",
        "feature_candidates_tried": candidates,
        "level1": LEVEL1,
        "before_start": ymd(before_start),
        "before_end": ymd(before_end),
        "after_start": ymd(after_start),
        "after_end": ymd(after_end),
        "before_avg_enter_save_rate": None,
        "after_avg_enter_save_rate": None,
        "relative_change": None,
        "relative_change_pct": None,
        "before_avg_enter_penetration": None,
        "after_avg_enter_penetration": None,
        "penetration_relative_change": None,
        "penetration_relative_change_pct": None,
        "is_new_feature": False,
        "summary_eligible": False,
        "summary_rule": "",
        "status": "",
        "note": "",
        "gate_label": "",
    }

    if not candidates:
        base["status"] = "未找到对应数据"
        tried = feature_raw.strip()
        if tried:
            # 需求已抽出功能名，但 options 中无 XX / AI XX（Skin 须再拆子功能）
            base["gate_label"] = f"未从看板拉取到对应功能（{tried}功能）"
            base["feature_resolved"] = tried
            ai_hint = (
                f"AI {tried}"
                if not tried.lower().startswith("ai ")
                else ""
            )
            if skin_parent:
                base["note"] = (
                    "看板无整体 Skin 聚合数据，须映射至子功能（如 Smooth/Clean Skin 等）；"
                    "未能从需求名匹配到子功能 option"
                )
            else:
                base["note"] = (
                    f"看板二级功能 options 中无「{tried}」"
                    + (f" / 「{ai_hint}」" if ai_hint else "")
                )
        else:
            base["gate_label"] = "未提取到功能"
            base["note"] = "需求未抽出可映射的二级功能名"
        return base

    last_fail_note = ""
    for feature in candidates:
        save_before = fetch_enter_save_daily(feature, before_start, before_end)
        save_after = fetch_enter_save_daily(feature, after_start, after_end)
        pen_before = fetch_enter_penetration_daily(feature, before_start, before_end)
        pen_after = fetch_enter_penetration_daily(feature, after_start, after_end)

        is_new = _is_fully_new_feature(save_before, pen_before)
        if is_new:
            if save_after.empty or pen_after.empty:
                last_fail_note = (
                    f"「{feature}」完全新增但上线后取数为空 "
                    f"save_after={len(save_after)} pen_after={len(pen_after)}"
                )
                continue
            after_days = min(
                int(save_after["日期"].nunique()), int(pen_after["日期"].nunique())
            )
            base["feature_resolved"] = feature
            base["before_days"] = 0
            base["after_days"] = after_days
            base["is_new_feature"] = True
            if feature != candidates[0]:
                base["feature_match_note"] = (
                    f"原名「{feature_raw}」取数无效，回退匹配「{feature}」"
                )
            if after_days < MIN_AFTER_DAYS:
                base["status"] = "数据不足7天"
                base["gate_label"] = "数据不足7天"
                base["summary_eligible"] = False
                base["note"] = (
                    f"完全新增功能；数据不足7天（版本后仅 {after_days} 天，"
                    f"门槛>={MIN_AFTER_DAYS}）"
                )
                return base

            save_a = float(save_after["进入保存率"].mean())
            pen_a = float(pen_after["进入渗透率"].mean())
            if pd.isna(save_a) or pd.isna(pen_a) or pen_a <= 0:
                last_fail_note = f"「{feature}」完全新增但上线后指标无效"
                continue

            eligible = pen_a > NEW_FEATURE_PEN_AFTER_MIN
            rule = "规则3" if eligible else ""
            base.update(
                {
                    "before_avg_enter_save_rate": None,
                    "after_avg_enter_save_rate": round(save_a, 6),
                    "relative_change": None,
                    "relative_change_pct": None,
                    "before_avg_enter_penetration": None,
                    "after_avg_enter_penetration": round(pen_a, 6),
                    "penetration_relative_change": None,
                    "penetration_relative_change_pct": None,
                    "summary_eligible": eligible,
                    "summary_rule": rule,
                    "gate_label": f"是（{rule}）" if eligible else "否",
                }
            )
            if eligible:
                base["status"] = "入选总结（规则3）"
                base["note"] = (
                    f"{feature} 完全新增；上线后日均进入渗透率 "
                    f"{pen_a*100:.1f}%（>{NEW_FEATURE_PEN_AFTER_MIN*100:.0f}%）"
                )
            else:
                base["status"] = "未达总结入选门槛"
                base["note"] = (
                    f"{feature} 完全新增；上线后日均进入渗透率 "
                    f"{pen_a*100:.1f}%（未达{NEW_FEATURE_PEN_AFTER_MIN*100:.0f}%）；"
                    f"相对变动不适用，记新功能"
                )
            return base

        if save_before.empty or save_after.empty:
            last_fail_note = (
                f"「{feature}」进入保存率取数为空 "
                f"before_rows={len(save_before)} after_rows={len(save_after)}"
            )
            continue
        if pen_before.empty or pen_after.empty:
            last_fail_note = (
                f"「{feature}」进入渗透率取数为空 "
                f"before_rows={len(pen_before)} after_rows={len(pen_after)}"
            )
            continue

        before_days = min(
            int(save_before["日期"].nunique()), int(pen_before["日期"].nunique())
        )
        after_days = min(
            int(save_after["日期"].nunique()), int(pen_after["日期"].nunique())
        )

        base["feature_resolved"] = feature
        base["before_days"] = before_days
        base["after_days"] = after_days
        if feature != candidates[0]:
            base["feature_match_note"] = (
                f"原名「{feature_raw}」取数无效，回退匹配「{feature}」"
            )

        if after_days < MIN_AFTER_DAYS:
            base["status"] = "数据不足7天"
            base["gate_label"] = "数据不足7天"
            base["summary_eligible"] = False
            base["note"] = (
                f"数据不足7天（版本后仅 {after_days} 天有效数据，"
                f"门槛>={MIN_AFTER_DAYS}）；不计算前后对比"
            )
            return base

        save_b = float(save_before["进入保存率"].mean())
        save_a = float(save_after["进入保存率"].mean())
        pen_b = float(pen_before["进入渗透率"].mean())
        pen_a = float(pen_after["进入渗透率"].mean())
        if (
            save_b <= 0
            or pen_b <= 0
            or pd.isna(save_b)
            or pd.isna(save_a)
            or pd.isna(pen_b)
            or pd.isna(pen_a)
        ):
            last_fail_note = f"「{feature}」日均保存率/渗透率无效"
            continue

        save_rel = (save_a - save_b) / save_b
        pen_rel = (pen_a - pen_b) / pen_b
        eligible, rule = _eligible(save_rel, pen_rel)

        base.update(
            {
                "before_avg_enter_save_rate": round(save_b, 6),
                "after_avg_enter_save_rate": round(save_a, 6),
                "relative_change": round(save_rel, 6),
                "relative_change_pct": round(save_rel * 100, 2),
                "before_avg_enter_penetration": round(pen_b, 6),
                "after_avg_enter_penetration": round(pen_a, 6),
                "penetration_relative_change": round(pen_rel, 6),
                "penetration_relative_change_pct": round(pen_rel * 100, 2),
                "summary_eligible": eligible,
                "summary_rule": rule,
                "gate_label": f"是（{rule}）" if eligible else "否",
            }
        )

        if eligible:
            base["status"] = f"入选总结（{rule}）"
            if rule == "规则1":
                base["note"] = (
                    f"{feature} 进入保存率上涨 {save_rel*100:.1f}% "
                    f"({save_b*100:.1f}%→{save_a*100:.1f}%)；"
                    f"进入渗透率相对变动 {pen_rel*100:.1f}%（>-3%）"
                )
            else:
                base["note"] = (
                    f"{feature} 进入渗透率上涨 {pen_rel*100:.1f}% "
                    f"({pen_b*100:.1f}%→{pen_a*100:.1f}%)；"
                    f"进入保存率相对变动 {save_rel*100:.1f}%（>-3%）"
                )
        else:
            base["status"] = "未达总结入选门槛"
            base["note"] = (
                f"{feature} 保存率相对变动 {save_rel*100:.1f}% "
                f"({save_b*100:.1f}%→{save_a*100:.1f}%)；"
                f"渗透率相对变动 {pen_rel*100:.1f}% "
                f"({pen_b*100:.1f}%→{pen_a*100:.1f}%)；未达规则1/规则2/规则3"
            )
        return base

    base["feature_resolved"] = candidates[-1]
    base["status"] = "未找到对应数据"
    # options 命中名称但取数为空：仍视为「从看板未拉到」
    label_feat = feature_raw.strip() if skin_parent else candidates[0]
    base["gate_label"] = f"未从看板拉取到对应功能（{label_feat}功能）"
    prefix = (
        "看板无整体 Skin 聚合，已尝试子功能："
        if skin_parent
        else ""
    )
    base["note"] = prefix + (
        last_fail_note or f"候选均无有效数据（尝试：{' → '.join(candidates)}）"
    )
    if len(candidates) > 1:
        base["note"] = f"尝试 {' → '.join(candidates)} 均失败；最后：{base['note']}"
    return base


def format_summary_bullet(row: dict[str, Any]) -> str:
    launch = row["launch"]
    launch_fmt = f"{int(launch[4:6])}/{int(launch[6:8])}上线"
    desc = row.get("desc") or row.get("name") or row.get("feature_resolved")
    feat = row.get("feature_resolved") or row.get("feature_requested")
    rule = row.get("summary_rule") or ""
    if rule == "规则3":
        after = float(row["after_avg_enter_penetration"]) * 100
        return (
            f"> - **{launch_fmt}**：{desc}；"
            f"{feat} 完全新增，上线后进入渗透率 {after:.1f}%（>{NEW_FEATURE_PEN_AFTER_MIN*100:.0f}%）"
        )
    if rule == "规则2":
        before = float(row["before_avg_enter_penetration"]) * 100
        after = float(row["after_avg_enter_penetration"]) * 100
        pct = float(row["penetration_relative_change_pct"])
        return (
            f"> - **{launch_fmt}**：{desc}；"
            f"{feat} 进入渗透率上涨 {pct:.1f}%（{before:.1f}%→{after:.1f}%）"
        )
    before = float(row["before_avg_enter_save_rate"]) * 100
    after = float(row["after_avg_enter_save_rate"]) * 100
    pct = float(row["relative_change_pct"])
    return (
        f"> - **{launch_fmt}**：{desc}；"
        f"{feat} 进入保存率上涨 {pct:.1f}%（{before:.1f}%→{after:.1f}%）"
    )


def _rel_pct(val: float | None, *, new_feature: bool = False) -> str:
    if new_feature:
        return "新功能"
    if val is None:
        return "-"
    sign = "+" if val >= 0 else ""
    return f"{sign}{val:.1f}%"


def _pct_pair(
    before: float | None, after: float | None, *, new_feature: bool = False
) -> str:
    if after is None:
        return "-"
    if new_feature or before is None:
        return f"{after*100:.1f}%"
    return f"{before*100:.1f}%→{after*100:.1f}%"


def format_table_row(row: dict[str, Any]) -> str:
    launch = row["launch"]
    launch_fmt = f"{int(launch[4:6])}/{int(launch[6:8])}"
    desc = (row.get("desc") or row.get("name") or "").replace("|", "/")
    feat = row.get("feature_resolved") or row.get("feature_requested") or ""
    gate = row.get("gate_label") or row.get("status") or "-"
    is_new = bool(row.get("is_new_feature"))
    if row.get("after_avg_enter_penetration") is None and not is_new:
        return (
            f"| {launch_fmt} | {desc} | {feat} | - | - | - | - | {gate} |"
        )
    return (
        f"| {launch_fmt} | {desc} | {feat} | "
        f"{_pct_pair(row.get('before_avg_enter_penetration'), row.get('after_avg_enter_penetration'), new_feature=is_new)} | "
        f"{_rel_pct(row.get('penetration_relative_change_pct'), new_feature=is_new)} | "
        f"{_pct_pair(row.get('before_avg_enter_save_rate'), row.get('after_avg_enter_save_rate'), new_feature=is_new)} | "
        f"{_rel_pct(row.get('relative_change_pct'), new_feature=is_new)} | {gate} |"
    )


def load_candidates(path: Path) -> list[dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise ValueError("candidates 须为 JSON 数组")
    return data


def main() -> int:
    parser = argparse.ArgumentParser(
        description="功能进入保存率+进入渗透率补取数（月报路径 B）"
    )
    parser.add_argument("--launch", help="版本上线日 YYYYMMDD")
    parser.add_argument("--feature", help="二级功能名，如 Face")
    parser.add_argument("--name", default="", help="需求名称")
    parser.add_argument("--desc", default="", help="需求简述")
    parser.add_argument("--candidates", type=Path, help="批量 JSON 候选")
    parser.add_argument(
        "-o",
        "--output-dir",
        type=Path,
        default=None,
        help="输出目录，默认 output/_staging/业务举措",
    )
    parser.add_argument("--list-features", action="store_true", help="列出二级功能 options")
    args = parser.parse_args()

    if args.list_features:
        opts = list_level2_options()
        print("\n".join(opts))
        return 0

    out_dir = args.output_dir
    if out_dir is None:
        out_dir = skill_root() / "output" / "_staging" / "业务举措"
    out_dir.mkdir(parents=True, exist_ok=True)

    candidates: list[dict[str, Any]] = []
    if args.candidates:
        candidates = load_candidates(args.candidates)
    elif args.launch and args.feature:
        candidates = [
            {
                "launch": args.launch,
                "feature": args.feature,
                "name": args.name or args.feature,
                "desc": args.desc,
            }
        ]
    else:
        parser.error("请提供 --candidates，或同时提供 --launch 与 --feature")

    level2_options = list_level2_options()
    results: list[dict[str, Any]] = []
    for item in candidates:
        launch = parse_launch(str(item["launch"]))
        row = analyze_one(
            launch=launch,
            feature_raw=str(item["feature"]),
            name=str(item.get("name") or item["feature"]),
            desc=str(item.get("desc") or ""),
            level2_options=level2_options,
        )
        results.append(row)
        print(
            f"[{row['status']}] {row['name']} / {row['feature_requested']}: {row['note']}"
        )

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    json_path = out_dir / f"feature_enter_save_rate_{ts}.json"
    csv_path = out_dir / "feature_enter_save_rate.csv"
    latest_json = out_dir / "feature_enter_save_rate.json"

    json_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    latest_json.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    pd.DataFrame(results).to_csv(csv_path, index=False, encoding="utf-8-sig")

    bullets = [format_summary_bullet(r) for r in results if r.get("summary_eligible")]
    md_lines = [
        "# 业务举措 · 功能进入保存率 / 进入渗透率补取数",
        "",
        f"生成时间：{datetime.now().isoformat(timespec='seconds')}",
        (
            f"看板：dashboard={DASHBOARD_ID} "
            f"enter_save_chart={CHART_ENTER_SAVE} "
            f"enter_pen_chart={CHART_ENTER_PENETRATION} env={ENV}"
        ),
        "",
        "## 总结可写入（规则1/规则2/规则3）",
        "",
    ]
    if bullets:
        md_lines.extend(bullets)
    else:
        md_lines.append("（无）")
    md_lines.extend(
        [
            "",
            "## 二章备案表（路径 B）",
            "",
            "| 上线日期 | 需求概述 | 二级功能 | 进入渗透率变化 | 进入渗透率相对变动 | 进入保存率变化 | 进入保存率相对变动 | 是否达到总结入选门槛 |",
            "| --- | --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for r in results:
        md_lines.append(format_table_row(r))
    md_path = out_dir / "业务举措_进入保存率.md"
    md_path.write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    print(f"已写入: {csv_path}")
    print(f"已写入: {latest_json}")
    print(f"已写入: {md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

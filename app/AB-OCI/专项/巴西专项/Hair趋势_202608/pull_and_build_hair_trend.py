#!/usr/bin/env python3
"""Pull Hair new-user monthly trend from Beidou and build CSV/PNG outputs."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import math
from pathlib import Path

os.environ.setdefault("MPLCONFIGDIR", "/private/tmp/codex-mpl-hair-trend")

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import FancyBboxPatch
from matplotlib.ticker import FuncFormatter


OUT_DIR = Path(__file__).resolve().parent
RAW_DIR = OUT_DIR / "raw"
BEIDOU_CLI = Path("/Users/xuyunhui/.codex/skills/beidou-dashboard-data/scripts/beidou_tool_api.py")
SYSTEM_PYTHON = sys.executable
DATE_START = "20260101"
DATE_END = "20260731"

COUNTRIES = ["整体", "美国", "英国", "巴西", "墨西哥"]
COUNTRY_BATCHES = [["整体"], ["美国", "英国", "巴西", "墨西哥"]]
PLATFORMS = ["iOS", "Android"]
CHANNELS = ["Organic", "non-Organic"]
FUNCTIONS = [
    "AI Repair", "Acne", "Adjust", "AI Expand", "AI Image", "AI Replace",
    "AI Retouch", "AI Tattoo", "Background", "Blur", "Body", "Bokeh",
    "Brighten", "Clean Skin", "Collarbone", "Concealer", "Contour", "Crop",
    "Dark Circles", "Details", "Effects", "Eraser", "Expression", "Eye Brighten",
    "Face", "Face Fix", "Filters", "Flawless", "Glitter", "Glowup", "Hair",
    "Magic", "Makeup", "Matte", "Muscle", "Mykit", "Plump", "Preset", "Prism",
    "Relight", "Reshape", "Resize", "Skin Tone", "Smooth", "Stamp", "Teeth",
    "Text", "Whiten",
]

COUNTRY_COLORS = {
    "整体": "#9AA7B8",
    "美国": "#1769E0",
    "英国": "#9A45B5",
    "巴西": "#E94B43",
    "墨西哥": "#F39A26",
}
CHANNEL_LABELS = {"Organic": "自然新增", "non-Organic": "渠道新增"}


def setup_font() -> None:
    candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            font_manager.fontManager.addfont(path)
            family = font_manager.FontProperties(fname=path).get_name()
            plt.rcParams["font.family"] = family
            break
    plt.rcParams["axes.unicode_minus"] = False


def call_beidou(params: dict, label: str) -> dict:
    cmd = [
        SYSTEM_PYTHON,
        str(BEIDOU_CLI),
        "--env", "oci",
        "--api", "dashboard_data",
        "--params", json.dumps(params, ensure_ascii=False, separators=(",", ":")),
    ]
    print(f"START {label}", flush=True)
    proc = subprocess.run(cmd, check=False, capture_output=True, text=True, timeout=300)
    if proc.returncode != 0:
        raise RuntimeError(f"{label} failed ({proc.returncode}): {proc.stderr[-2000:]}")
    try:
        payload = json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"{label} returned non-JSON: {proc.stdout[-2000:]}") from exc
    if payload.get("response", {}).get("code") != 0:
        raise RuntimeError(f"{label} API error: {payload}")
    (RAW_DIR / f"{label}.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    rows = payload["response"]["response"].get("data", [])
    n = sum(len(x.get("data", [])) for x in rows)
    print(f"DONE  {label}: {n} rows", flush=True)
    return payload


def chart_rows(payload: dict, chart_id: int) -> list[dict]:
    charts = payload["response"]["response"].get("data", [])
    for chart in charts:
        if int(chart.get("chartID")) == chart_id:
            return chart.get("data", [])
    return []


def pull_function_data() -> pd.DataFrame:
    all_rows: list[dict] = []
    for channel in CHANNELS:
        for batch_i, countries in enumerate(COUNTRY_BATCHES, start=1):
            params = {
                "dashboard_id": 10015706,
                "chart_id": [90628],
                "aggr": "MONTH",
                "aggrType": "AVG",
                "filters": [
                    {"name": "日期", "value": [DATE_START, DATE_END]},
                    {"name": "平台", "value": PLATFORMS},
                    {"name": "国家/地区", "value": countries},
                    {"name": "新老", "value": ["New"]},
                    {"name": "渠道/自然", "value": [channel]},
                    {"name": "版本", "value": ["整体"]},
                    {"name": "付费状态", "value": ["整体"]},
                    {"name": "一级功能", "value": ["图片编辑"]},
                    {"name": "二级功能", "value": FUNCTIONS},
                ],
            }
            payload = call_beidou(params, f"function_{channel}_{batch_i}")
            for row in chart_rows(payload, 90628):
                row = dict(row)
                row["渠道/自然"] = channel
                all_rows.append(row)
    df = pd.DataFrame(all_rows)
    rename = {
        "日期(按日)": "月份",
        "日期": "月份",
        "国家/地区": "市场",
        "国家": "市场",
        "二级功能": "功能",
        "进入uv": "进入人数",
        "打勾uv": "打勾人数",
    }
    df = df.rename(columns=rename)
    required = ["月份", "市场", "平台", "功能", "进入人数", "打勾人数", "渠道/自然"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise RuntimeError(f"Function data missing columns: {missing}; got {df.columns.tolist()}")
    return df[required].copy()


def pull_active_data() -> pd.DataFrame:
    all_rows: list[dict] = []
    for channel in CHANNELS:
        for batch_i, countries in enumerate(COUNTRY_BATCHES, start=1):
            params = {
                "dashboard_id": 10015816,
                "chart_id": [89122],
                "aggr": "MONTH",
                "aggrType": "AVG",
                "filters": [
                    {"name": "日期", "value": [DATE_START, DATE_END]},
                    {"name": "平台", "value": PLATFORMS},
                    {"name": "国家/地区", "value": countries},
                    {"name": "新老", "value": ["New"]},
                    {"name": "渠道/自然", "value": [channel]},
                ],
            }
            payload = call_beidou(params, f"active_{channel}_{batch_i}")
            for row in chart_rows(payload, 89122):
                row = dict(row)
                row["渠道/自然"] = channel
                all_rows.append(row)
    df = pd.DataFrame(all_rows)
    rename = {"日期": "月份", "国家": "市场", "国家/地区": "市场", "DAU": "活跃人数"}
    df = df.rename(columns=rename)
    required = ["月份", "市场", "平台", "活跃人数", "渠道/自然"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise RuntimeError(f"Active data missing columns: {missing}; got {df.columns.tolist()}")
    return df[required].copy()


def pull_new_user_dnu_retention() -> pd.DataFrame:
    """Pull monthly DNU and new-user D1 retention for the Hair comparison cohorts."""
    params = {
        "dashboard_id": 10015834,
        "chart_id": [89255, 89258],
        "aggr": "MONTH",
        "aggrType": "AVG",
        "filters": [
            {"name": "日期", "value": [DATE_START, DATE_END]},
            {"name": "平台", "value": PLATFORMS},
            {"name": "国家/地区", "value": COUNTRIES},
            {"name": "渠道/自然", "value": CHANNELS},
        ],
    }
    payload = call_beidou(params, "dnu_retention_202601_202607")

    dnu = pd.DataFrame(chart_rows(payload, 89255)).rename(columns={
        "日期": "月份", "国家": "市场", "国家/地区": "市场",
        "渠道自然": "渠道/自然",
    })
    retention = pd.DataFrame(chart_rows(payload, 89258)).rename(columns={
        "日期(按日)": "月份", "日期": "月份", "国家": "市场",
        "国家/地区": "市场", "渠道自然": "渠道/自然",
        "次日留存率": "新增次日留存率",
    })
    for frame, metric in [(dnu, "DNU"), (retention, "新增次日留存率")]:
        required = ["月份", "市场", "平台", "渠道/自然", metric]
        missing = [c for c in required if c not in frame.columns]
        if missing:
            raise RuntimeError(f"DNU/retention data missing columns: {missing}; got {frame.columns.tolist()}")
        frame["月份"] = normalize_month(frame["月份"])
        frame[metric] = pd.to_numeric(frame[metric], errors="coerce")

    result = dnu[["月份", "市场", "平台", "渠道/自然", "DNU"]].merge(
        retention[["月份", "市场", "平台", "渠道/自然", "新增次日留存率"]],
        on=["月份", "市场", "平台", "渠道/自然"], how="outer", validate="one_to_one",
    )
    result = result.sort_values(["平台", "渠道/自然", "市场", "月份"]).reset_index(drop=True)
    expected = 7 * len(COUNTRIES) * len(PLATFORMS) * len(CHANNELS)
    if len(result) != expected:
        print(f"WARN DNU/retention rows={len(result)}, expected={expected}", flush=True)
    return result


def pull_enter_penetration() -> pd.DataFrame:
    """Pull the dashboard-native monthly penetration metric (AVG of daily rates)."""
    all_rows: list[dict] = []
    for channel in CHANNELS:
        for batch_i, countries in enumerate(COUNTRY_BATCHES, start=1):
            params = {
                "dashboard_id": 10015706,
                "chart_id": [90774],
                "aggr": "MONTH",
                "aggrType": "AVG",
                "filters": [
                    {"name": "日期", "value": [DATE_START, DATE_END]},
                    {"name": "平台", "value": PLATFORMS},
                    {"name": "国家/地区", "value": countries},
                    {"name": "新老", "value": ["New"]},
                    {"name": "渠道/自然", "value": [channel]},
                    {"name": "版本", "value": ["整体"]},
                    {"name": "付费状态", "value": ["整体"]},
                    {"name": "一级功能", "value": ["图片编辑"]},
                    {"name": "二级功能", "value": FUNCTIONS},
                ],
            }
            payload = call_beidou(params, f"enter_rate_{channel}_{batch_i}")
            for row in chart_rows(payload, 90774):
                row = dict(row)
                row["渠道/自然"] = channel
                all_rows.append(row)
    df = pd.DataFrame(all_rows).rename(columns={
        "日期(按日)": "月份", "日期": "月份", "国家/地区": "市场",
        "国家": "市场", "二级功能": "功能",
    })
    required = ["月份", "市场", "平台", "功能", "进入渗透率", "渠道/自然"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise RuntimeError(f"Enter-rate data missing columns: {missing}; got {df.columns.tolist()}")
    return df[required].copy()


def pull_function_daily_data() -> pd.DataFrame:
    """Pull daily function UVs so check penetration can follow dashboard aggregation."""
    all_rows: list[dict] = []
    # Split countries one-by-one to keep daily payloads bounded.
    for channel in CHANNELS:
        for country in COUNTRIES:
            params = {
                "dashboard_id": 10015706,
                "chart_id": [90628],
                "aggr": "DAY",
                "aggrType": "AVG",
                "filters": [
                    {"name": "日期", "value": [DATE_START, DATE_END]},
                    {"name": "平台", "value": PLATFORMS},
                    {"name": "国家/地区", "value": [country]},
                    {"name": "新老", "value": ["New"]},
                    {"name": "渠道/自然", "value": [channel]},
                    {"name": "版本", "value": ["整体"]},
                    {"name": "付费状态", "value": ["整体"]},
                    {"name": "一级功能", "value": ["图片编辑"]},
                    {"name": "二级功能", "value": FUNCTIONS},
                ],
            }
            safe_country = "overall" if country == "整体" else country
            payload = call_beidou(params, f"function_daily_{channel}_{safe_country}")
            for row in chart_rows(payload, 90628):
                row = dict(row)
                row["渠道/自然"] = channel
                all_rows.append(row)
    df = pd.DataFrame(all_rows).rename(columns={
        "日期(按日)": "日期", "国家/地区": "市场", "国家": "市场",
        "二级功能": "功能", "进入uv": "进入人数", "打勾uv": "打勾人数",
    })
    required = ["日期", "市场", "平台", "功能", "进入人数", "打勾人数", "渠道/自然"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise RuntimeError(f"Function daily data missing columns: {missing}; got {df.columns.tolist()}")
    return df[required].copy()


def pull_active_daily_data() -> pd.DataFrame:
    """Pull daily DAU with exactly the same new/channel/platform/country filters."""
    all_rows: list[dict] = []
    for channel in CHANNELS:
        for batch_i, countries in enumerate(COUNTRY_BATCHES, start=1):
            params = {
                "dashboard_id": 10015816,
                "chart_id": [89122],
                "aggr": "DAY",
                "aggrType": "AVG",
                "filters": [
                    {"name": "日期", "value": [DATE_START, DATE_END]},
                    {"name": "平台", "value": PLATFORMS},
                    {"name": "国家/地区", "value": countries},
                    {"name": "新老", "value": ["New"]},
                    {"name": "渠道/自然", "value": [channel]},
                ],
            }
            payload = call_beidou(params, f"active_daily_{channel}_{batch_i}")
            for row in chart_rows(payload, 89122):
                row = dict(row)
                row["渠道/自然"] = channel
                all_rows.append(row)
    df = pd.DataFrame(all_rows).rename(columns={
        "日期": "日期", "国家": "市场", "国家/地区": "市场", "DAU": "活跃人数",
    })
    required = ["日期", "市场", "平台", "活跃人数", "渠道/自然"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise RuntimeError(f"Active daily data missing columns: {missing}; got {df.columns.tolist()}")
    return df[required].copy()


def build_detail_strict(
    enter_rate_df: pd.DataFrame,
    function_daily_df: pd.DataFrame,
    active_daily_df: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Build monthly rates as AVG(daily UV / daily DAU), matching dashboard 90774."""
    enter = enter_rate_df.copy()
    enter["月份"] = normalize_month(enter["月份"])
    enter["进入渗透率"] = pd.to_numeric(enter["进入渗透率"], errors="coerce")
    enter = enter.groupby(
        ["月份", "市场", "平台", "渠道/自然", "功能"], as_index=False
    ).agg(进入渗透率=("进入渗透率", "mean"))

    func = function_daily_df.copy()
    dau = active_daily_df.copy()
    func["日期"] = pd.to_datetime(func["日期"]).dt.strftime("%Y-%m-%d")
    dau["日期"] = pd.to_datetime(dau["日期"]).dt.strftime("%Y-%m-%d")
    for col in ["进入人数", "打勾人数"]:
        func[col] = pd.to_numeric(func[col], errors="coerce").fillna(0)
    dau["活跃人数"] = pd.to_numeric(dau["活跃人数"], errors="coerce")
    daily = func.merge(
        dau, on=["日期", "市场", "平台", "渠道/自然"], how="left", validate="many_to_one"
    )
    daily["月份"] = pd.to_datetime(daily["日期"]).dt.to_period("M").astype(str)
    daily["打勾渗透率_日"] = daily["打勾人数"] / daily["活跃人数"]
    monthly = daily.groupby(
        ["月份", "市场", "平台", "渠道/自然", "功能"], as_index=False
    ).agg(
        进入人数=("进入人数", "mean"),
        打勾人数=("打勾人数", "mean"),
        活跃人数=("活跃人数", "mean"),
        打勾渗透率=("打勾渗透率_日", "mean"),
    )
    merged = monthly.merge(
        enter, on=["月份", "市场", "平台", "渠道/自然", "功能"], how="inner", validate="one_to_one"
    )
    keys = ["月份", "市场", "平台", "渠道/自然"]
    merged["进入排名"] = merged.groupby(keys)["进入渗透率"].rank(method="min", ascending=False).astype("Int64")
    merged["打勾排名"] = merged.groupby(keys)["打勾渗透率"].rank(method="min", ascending=False).astype("Int64")
    hair = merged.loc[merged["功能"].str.casefold() == "hair"].copy()
    hair["渠道"] = hair["渠道/自然"].map(CHANNEL_LABELS)
    hair["月份标签"] = hair["月份"].str.replace("2026-", "", regex=False).astype(int).astype(str) + "月"
    return merged, hair


def normalize_month(series: pd.Series) -> pd.Series:
    return pd.to_datetime(series).dt.to_period("M").astype(str)


def build_detail(function_df: pd.DataFrame, active_df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    function_df["月份"] = normalize_month(function_df["月份"])
    active_df["月份"] = normalize_month(active_df["月份"])
    for c in ["进入人数", "打勾人数"]:
        function_df[c] = pd.to_numeric(function_df[c], errors="coerce").fillna(0)
    active_df["活跃人数"] = pd.to_numeric(active_df["活跃人数"], errors="coerce")

    # Defensive aggregation: a configured function should have one row per cohort/month.
    func = (
        function_df.groupby(["月份", "市场", "平台", "渠道/自然", "功能"], as_index=False)
        .agg(进入人数=("进入人数", "sum"), 打勾人数=("打勾人数", "sum"))
    )
    dau = (
        active_df.groupby(["月份", "市场", "平台", "渠道/自然"], as_index=False)
        .agg(活跃人数=("活跃人数", "sum"))
    )
    merged = func.merge(dau, on=["月份", "市场", "平台", "渠道/自然"], how="left", validate="many_to_one")
    merged["进入渗透率"] = merged["进入人数"] / merged["活跃人数"]
    merged["打勾渗透率"] = merged["打勾人数"] / merged["活跃人数"]
    keys = ["月份", "市场", "平台", "渠道/自然"]
    merged["进入排名"] = merged.groupby(keys)["进入人数"].rank(method="min", ascending=False).astype("Int64")
    merged["打勾排名"] = merged.groupby(keys)["打勾人数"].rank(method="min", ascending=False).astype("Int64")
    hair = merged.loc[merged["功能"].str.casefold() == "hair"].copy()
    hair["渠道"] = hair["渠道/自然"].map(CHANNEL_LABELS)
    hair["月份标签"] = hair["月份"].str.replace("2026-", "", regex=False).astype(int).astype(str) + "月"
    hair.loc[hair["月份"] == "2026-08", "月份标签"] = "8月*"
    return merged, hair


def validate_coverage(hair: pd.DataFrame) -> None:
    expected = {(m, c, p, ch) for m in pd.period_range("2026-01", "2026-07", freq="M").astype(str)
                for c in COUNTRIES for p in PLATFORMS for ch in CHANNELS}
    actual = set(map(tuple, hair[["月份", "市场", "平台", "渠道/自然"]].itertuples(index=False, name=None)))
    missing = sorted(expected - actual)
    if missing:
        print(f"WARN missing {len(missing)} Hair cohort-month rows: {missing[:20]}", flush=True)


def add_panel_header(fig: plt.Figure, title: str, subtitle: str) -> None:
    fig.patch.set_facecolor("#F4F7FB")
    fig.text(0.035, 0.965, title, fontsize=24, fontweight="bold", color="#16233A", va="top")
    fig.text(0.035, 0.925, subtitle, fontsize=11, color="#7D8CA3", va="top")


def style_axis(ax: plt.Axes) -> None:
    ax.set_facecolor("white")
    ax.grid(axis="y", color="#E6EBF2", linewidth=0.9)
    ax.spines[["top", "right", "left"]].set_visible(False)
    ax.spines["bottom"].set_color("#D6DEE9")
    ax.tick_params(colors="#74839A", labelsize=9)


def plot_rank(hair: pd.DataFrame, out_path: Path) -> None:
    setup_font()
    fig, axes = plt.subplots(2, 4, figsize=(22, 10), sharex=True, constrained_layout=False)
    plt.subplots_adjust(left=0.05, right=0.985, top=0.86, bottom=0.10, wspace=0.16, hspace=0.28)
    add_panel_header(
        fig,
        "Hair 在新用户功能中的排名趋势",
        "2026年1月—8月6日｜月均口径｜排名范围为看板配置的48个二级功能；数值越靠上越好，8月为截至8月6日的月内数据",
    )
    columns = [("iOS", "Organic"), ("iOS", "non-Organic"), ("Android", "Organic"), ("Android", "non-Organic")]
    metrics = [("进入排名", "进入渗透率排名"), ("打勾排名", "打勾渗透率排名")]
    months = [f"2026-{m:02d}" for m in range(1, 9)]
    labels = [f"{m}月" for m in range(1, 8)] + ["8月*"]
    for r, (metric, row_label) in enumerate(metrics):
        for c, (platform, channel) in enumerate(columns):
            ax = axes[r, c]
            style_axis(ax)
            sub = hair[(hair["平台"] == platform) & (hair["渠道/自然"] == channel)]
            for country in COUNTRIES:
                s = sub[sub["市场"] == country].set_index("月份").reindex(months)
                y = pd.to_numeric(s[metric], errors="coerce")
                ax.plot(range(8), y, marker="o", ms=4.5, lw=2.0, color=COUNTRY_COLORS[country], label=country, alpha=0.98)
                if country == "巴西":
                    for x, val in enumerate(y):
                        if pd.notna(val) and (x in {0, 5, 7} or val <= 3):
                            ax.text(x, val - 0.55, f"#{int(val)}", color=COUNTRY_COLORS[country], fontsize=8,
                                    ha="center", va="bottom", fontweight="bold")
            ax.set_ylim(30.5, 0.5)
            ax.set_yticks([1, 5, 10, 15, 20, 25, 30])
            ax.set_xticks(range(8), labels)
            if r == 0:
                ax.set_title(f"{platform} · {CHANNEL_LABELS[channel]}", fontsize=13, color="#263348", pad=13, fontweight="bold")
            if c == 0:
                ax.set_ylabel(row_label, fontsize=11, color="#425168")
            if r == 1:
                ax.set_xlabel("月份", fontsize=10, color="#74839A")
    handles = [plt.Line2D([0], [0], color=COUNTRY_COLORS[c], lw=3, marker="o", ms=5, label=c) for c in COUNTRIES]
    fig.legend(handles=handles, loc="upper right", bbox_to_anchor=(0.98, 0.962), ncol=5, frameon=False, fontsize=10)
    fig.text(0.05, 0.035, "注：同一分群内活跃人数分母相同，因此按渗透率排序与按对应UV排序一致；并列名次采用竞赛排名。", fontsize=9, color="#8996A9")
    fig.savefig(out_path, dpi=220, facecolor=fig.get_facecolor())
    plt.close(fig)


def plot_penetration(hair: pd.DataFrame, out_path: Path) -> None:
    setup_font()
    fig, axes = plt.subplots(2, 4, figsize=(22, 10), sharex=True, constrained_layout=False)
    plt.subplots_adjust(left=0.055, right=0.985, top=0.86, bottom=0.10, wspace=0.16, hspace=0.28)
    add_panel_header(
        fig,
        "Hair 新用户渗透率趋势",
        "2026年1月—8月6日｜进入/打勾人数 ÷ 对应市场、平台、渠道的新用户DAU｜8月为截至8月6日的月内数据",
    )
    columns = [("iOS", "Organic"), ("iOS", "non-Organic"), ("Android", "Organic"), ("Android", "non-Organic")]
    metrics = [("进入渗透率", "进入渗透率"), ("打勾渗透率", "打勾渗透率")]
    months = [f"2026-{m:02d}" for m in range(1, 9)]
    labels = [f"{m}月" for m in range(1, 8)] + ["8月*"]
    for r, (metric, row_label) in enumerate(metrics):
        for c, (platform, channel) in enumerate(columns):
            ax = axes[r, c]
            style_axis(ax)
            sub = hair[(hair["平台"] == platform) & (hair["渠道/自然"] == channel)]
            max_y = 0.0
            for country in COUNTRIES:
                s = sub[sub["市场"] == country].set_index("月份").reindex(months)
                y = pd.to_numeric(s[metric], errors="coerce") * 100
                if y.notna().any():
                    max_y = max(max_y, float(y.max()))
                ax.plot(range(8), y, marker="o", ms=4.5, lw=2.0, color=COUNTRY_COLORS[country], label=country)
                if country == "巴西":
                    for x in [0, 5, 7]:
                        val = y.iloc[x] if x < len(y) else np.nan
                        if pd.notna(val):
                            ax.text(x, val + max(max_y * 0.025, 0.3), f"{val:.1f}%", color=COUNTRY_COLORS[country],
                                    fontsize=8, ha="center", va="bottom", fontweight="bold")
            ax.set_ylim(0, max(10, max_y * 1.18))
            ax.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")
            ax.set_xticks(range(8), labels)
            if r == 0:
                ax.set_title(f"{platform} · {CHANNEL_LABELS[channel]}", fontsize=13, color="#263348", pad=13, fontweight="bold")
            if c == 0:
                ax.set_ylabel(row_label, fontsize=11, color="#425168")
            if r == 1:
                ax.set_xlabel("月份", fontsize=10, color="#74839A")
    handles = [plt.Line2D([0], [0], color=COUNTRY_COLORS[c], lw=3, marker="o", ms=5, label=c) for c in COUNTRIES]
    fig.legend(handles=handles, loc="upper right", bbox_to_anchor=(0.98, 0.962), ncol=5, frameon=False, fontsize=10)
    fig.text(0.055, 0.035, "注：月度人数均为日均UV；整体市场包含巴西。", fontsize=9, color="#8996A9")
    fig.savefig(out_path, dpi=220, facecolor=fig.get_facecolor())
    plt.close(fig)


def _rank_limits(values: pd.Series) -> tuple[tuple[float, float], list[int]]:
    """Return an inverted, compact rank axis and readable integer ticks."""
    values = pd.to_numeric(values, errors="coerce").dropna()
    lo = max(1, int(math.floor(values.min())))
    hi = int(math.ceil(values.max()))
    span = max(hi - lo, 1)
    step = 1 if span <= 7 else 2 if span <= 15 else 5
    tick_lo = max(1, (lo // step) * step)
    tick_hi = int(math.ceil(hi / step) * step)
    ticks = list(range(tick_lo, tick_hi + 1, step))
    return (tick_hi + 0.7, max(0.3, tick_lo - 0.7)), ticks


def _percent_limits(values: pd.Series) -> tuple[float, float, int]:
    """Compact percent axis with a small margin and round ticks."""
    values = pd.to_numeric(values, errors="coerce").dropna() * 100
    lo_raw, hi_raw = float(values.min()), float(values.max())
    spread = max(hi_raw - lo_raw, 1.0)
    step = 1 if spread <= 6 else 2 if spread <= 12 else 5 if spread <= 30 else 10
    lo = max(0, math.floor((lo_raw - spread * 0.10) / step) * step)
    hi = math.ceil((hi_raw + spread * 0.12) / step) * step
    if hi - lo < step * 3:
        hi += step
    return lo, hi, step


def plot_metric_combined(
    hair: pd.DataFrame,
    metric_prefix: str,
    out_path: Path,
) -> None:
    """Plot rank and penetration for one metric in a single 2x4 figure."""
    setup_font()
    hair = hair[hair["月份"] <= "2026-07"].copy()
    rank_col = f"{metric_prefix}排名"
    rate_col = f"{metric_prefix}渗透率"
    fig, axes = plt.subplots(2, 4, figsize=(22, 10), sharex=True, constrained_layout=False)
    plt.subplots_adjust(left=0.055, right=0.985, top=0.86, bottom=0.10, wspace=0.17, hspace=0.30)
    add_panel_header(
        fig,
        f"Hair {metric_prefix}渗透率：功能排名与数值趋势",
        f"2026年1—7月｜新用户｜上排为{metric_prefix}渗透率在功能中的排名，下排为每日{metric_prefix}UV ÷ 当日新用户DAU后做月均",
    )
    columns = [("iOS", "Organic"), ("iOS", "non-Organic"), ("Android", "Organic"), ("Android", "non-Organic")]
    months = [f"2026-{m:02d}" for m in range(1, 8)]
    labels = [f"{m}月" for m in range(1, 8)]
    (rank_bottom, rank_top), rank_ticks = _rank_limits(hair[rank_col])
    rate_lo, rate_hi, rate_step = _percent_limits(hair[rate_col])

    for c, (platform, channel) in enumerate(columns):
        sub = hair[(hair["平台"] == platform) & (hair["渠道/自然"] == channel)].copy()
        for r, col in enumerate([rank_col, rate_col]):
            ax = axes[r, c]
            style_axis(ax)
            for country in COUNTRIES:
                s = sub[sub["市场"] == country].set_index("月份").reindex(months)
                y = pd.to_numeric(s[col], errors="coerce")
                if r == 1:
                    y = y * 100
                is_brazil = country == "巴西"
                is_mexico = country == "墨西哥"
                ax.plot(
                    range(7), y,
                    color=COUNTRY_COLORS[country],
                    linestyle="-" if (is_brazil or is_mexico) else "--",
                    linewidth=3.0 if is_brazil else 1.65,
                    marker="o" if is_brazil else None,
                    markersize=5 if is_brazil else 0,
                    alpha=1.0 if is_brazil else 0.82,
                    zorder=4 if is_brazil else 2,
                    label=country,
                )
                if is_brazil:
                    # Label June and July for the focus market.
                    for x in [5, 6]:
                        val = y.iloc[x] if x < len(y) else np.nan
                        if pd.notna(val):
                            label = f"#{int(val)}" if r == 0 else f"{val:.1f}%"
                            text_offset = -14 if r == 0 else 8
                            ax.annotate(
                                label, (x, val), xytext=(0, text_offset),
                                textcoords="offset points", ha="center", va="bottom",
                                fontsize=8, fontweight="bold", color=COUNTRY_COLORS[country],
                                zorder=6,
                            )

            if r == 0:
                ax.set_ylim(rank_bottom, rank_top)
                ax.set_yticks(rank_ticks)
                ax.set_ylabel(f"{metric_prefix}渗透率排名" if c == 0 else "", fontsize=11, color="#425168")
                ax.set_title(f"{platform} · {CHANNEL_LABELS[channel]}", fontsize=13, color="#263348", pad=13, fontweight="bold")
            else:
                ax.set_ylim(rate_lo, rate_hi)
                ax.set_yticks(np.arange(rate_lo, rate_hi + 0.001, rate_step))
                ax.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")
                ax.set_ylabel(f"{metric_prefix}渗透率" if c == 0 else "", fontsize=11, color="#425168")
                ax.set_xlabel("月份", fontsize=10, color="#74839A")
            ax.set_xticks(range(7), labels)

    handles = []
    for country in COUNTRIES:
        is_brazil = country == "巴西"
        is_mexico = country == "墨西哥"
        handles.append(plt.Line2D(
            [0], [0], color=COUNTRY_COLORS[country],
            lw=3.0 if is_brazil else 1.65,
            ls="-" if (is_brazil or is_mexico) else "--",
            marker="o" if is_brazil else None,
            ms=5 if is_brazil else 0,
            alpha=1.0 if is_brazil else 0.82,
            label=country,
        ))
    fig.legend(handles=handles, loc="upper right", bbox_to_anchor=(0.98, 0.962), ncol=5, frameon=False, fontsize=10)
    fig.text(
        0.055, 0.035,
        "注：同一张图中四个面板的排名轴、渗透率轴分别保持一致；排名越靠上越好。巴西为加粗实线，墨西哥为普通实线，其他市场为普通虚线；月度值为日渗透率算术平均。",
        fontsize=9, color="#8996A9",
    )
    fig.savefig(out_path, dpi=220, facecolor=fig.get_facecolor())
    plt.close(fig)


def plot_all_metrics_long(hair: pd.DataFrame, out_path: Path) -> None:
    """Combine the corrected enter/check figures into one executive long image."""
    setup_font()
    hair = hair[hair["月份"] <= "2026-07"].copy()
    fig, axes = plt.subplots(4, 4, figsize=(22, 20), sharex=True, constrained_layout=False)
    fig.patch.set_facecolor("#F4F7FB")
    plt.subplots_adjust(left=0.055, right=0.985, top=0.82, bottom=0.065, wspace=0.17, hspace=0.38)

    fig.text(0.035, 0.972, "Hair 新用户渗透率与功能排名趋势", fontsize=27,
             fontweight="bold", color="#16233A", va="top")
    fig.text(0.035, 0.925,
             "2026年1—7月｜新用户｜进入渗透率直接取看板10015706/90774；打勾渗透率按每日打勾UV÷每日DAU后做月均",
             fontsize=10.5, color="#7D8CA3", va="top")

    columns = [("iOS", "Organic"), ("iOS", "non-Organic"),
               ("Android", "Organic"), ("Android", "non-Organic")]
    months = [f"2026-{m:02d}" for m in range(1, 8)]
    labels = [f"{m}月" for m in range(1, 8)]
    row_specs = [
        ("进入排名", "进入渗透率排名", "rank", "进入"),
        ("进入渗透率", "进入渗透率", "rate", "进入"),
        ("打勾排名", "打勾渗透率排名", "rank", "打勾"),
        ("打勾渗透率", "打勾渗透率", "rate", "打勾"),
    ]
    limits: dict[tuple[str, str], tuple] = {}
    for prefix in ["进入", "打勾"]:
        limits[(prefix, "rank")] = _rank_limits(hair[f"{prefix}排名"])
        limits[(prefix, "rate")] = _percent_limits(hair[f"{prefix}渗透率"])

    for r, (col, ylabel, kind, prefix) in enumerate(row_specs):
        for c, (platform, channel) in enumerate(columns):
            ax = axes[r, c]
            style_axis(ax)
            sub = hair[(hair["平台"] == platform) & (hair["渠道/自然"] == channel)]
            for country in COUNTRIES:
                s = sub[sub["市场"] == country].set_index("月份").reindex(months)
                y = pd.to_numeric(s[col], errors="coerce")
                if kind == "rate":
                    y = y * 100
                is_brazil = country == "巴西"
                is_mexico = country == "墨西哥"
                ax.plot(
                    range(7), y,
                    color=COUNTRY_COLORS[country],
                    linestyle="-" if (is_brazil or is_mexico) else "--",
                    linewidth=3.2 if is_brazil else 1.65,
                    marker="o" if is_brazil else None,
                    markersize=5.2 if is_brazil else 0,
                    alpha=1.0 if is_brazil else 0.82,
                    zorder=5 if is_brazil else 2,
                )
                if is_brazil:
                    for x in [5, 6]:
                        val = y.iloc[x] if x < len(y) else np.nan
                        if pd.notna(val):
                            text_value = f"#{int(val)}" if kind == "rank" else f"{val:.1f}%"
                            ax.annotate(
                                text_value, (x, val), xytext=(0, -14 if kind == "rank" else 8),
                                textcoords="offset points", ha="center", va="bottom",
                                fontsize=8.2, fontweight="bold", color=COUNTRY_COLORS[country], zorder=6,
                            )
            if kind == "rank":
                (bottom, top), ticks = limits[(prefix, kind)]
                ax.set_ylim(bottom, top)
                ax.set_yticks(ticks)
            else:
                lo, hi, step = limits[(prefix, kind)]
                ax.set_ylim(lo, hi)
                ax.set_yticks(np.arange(lo, hi + 0.001, step))
                ax.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")
            ax.set_xticks(range(7), labels)
            if r in {0, 2}:
                ax.set_title(f"{platform} · {CHANNEL_LABELS[channel]}", fontsize=13,
                             color="#263348", pad=12, fontweight="bold")
            if c == 0:
                ax.set_ylabel(ylabel, fontsize=11, color="#425168")
            if r in {1, 3}:
                ax.set_xlabel("月份", fontsize=10, color="#74839A")

    # Large separator between the two source figures.
    divider_y = 0.445
    fig.add_artist(plt.Line2D([0.035, 0.985], [divider_y, divider_y], transform=fig.transFigure,
                              color="#23324A", linewidth=5.0, solid_capstyle="round", alpha=0.92))
    fig.text(0.035, 0.838, "01  进入渗透率", fontsize=16, color="#E94B43", fontweight="bold")
    fig.text(0.035, 0.421, "02  打勾渗透率", fontsize=16, color="#E94B43", fontweight="bold")

    handles = []
    for country in COUNTRIES:
        is_brazil = country == "巴西"
        is_mexico = country == "墨西哥"
        handles.append(plt.Line2D(
            [0], [0], color=COUNTRY_COLORS[country], lw=3.2 if is_brazil else 1.65,
            ls="-" if (is_brazil or is_mexico) else "--",
            marker="o" if is_brazil else None, ms=5 if is_brazil else 0,
            alpha=1.0 if is_brazil else 0.82, label=country,
        ))
    fig.legend(handles=handles, loc="upper right", bbox_to_anchor=(0.982, 0.974),
               ncol=5, frameon=False, fontsize=10)
    fig.text(
        0.055, 0.025,
        "注：排名越靠上越好；巴西为加粗实线，墨西哥为普通实线，其他市场为普通虚线。月度渗透率均为日渗透率的算术平均。",
        fontsize=9, color="#8996A9",
    )
    fig.savefig(out_path, dpi=220, facecolor=fig.get_facecolor())
    plt.close(fig)


def _format_dnu(value: float) -> str:
    if abs(value) >= 10000:
        return f"{value / 10000:.1f}万"
    if abs(value) >= 1000:
        return f"{value / 1000:.1f}k"
    return f"{value:.0f}"


def _build_column_insights(
    hair: pd.DataFrame,
    cohort: pd.DataFrame,
) -> dict[tuple[str, str], str]:
    """Create compact, data-backed notes shown below the four cohort headers."""
    notes: dict[tuple[str, str], str] = {}
    for platform in ["iOS", "Android"]:
        overall = hair[
            (hair["平台"] == platform)
            & (hair["渠道/自然"] == "Organic")
            & (hair["市场"] == "整体")
        ]
        avg_rate = pd.to_numeric(overall["进入渗透率"], errors="coerce").mean() * 100
        avg_rank = pd.to_numeric(overall["进入排名"], errors="coerce").mean()
        notes[(platform, "Organic")] = (
            f"整体：Hair进入渗透率基本维持{avg_rate:.1f}%\n"
            f"Hair进入渗透率功能Top{avg_rank:.0f}（月均）"
        )

    us = hair[
        (hair["平台"] == "iOS")
        & (hair["渠道/自然"] == "non-Organic")
        & (hair["市场"] == "美国")
    ].set_index("月份")
    us_jan = float(us.loc["2026-01", "进入渗透率"] * 100)
    us_jul = float(us.loc["2026-07", "进入渗透率"] * 100)
    us_retention = cohort[
        (cohort["平台"] == "iOS")
        & (cohort["渠道/自然"] == "non-Organic")
        & (cohort["市场"] == "美国")
    ].set_index("月份")
    us_ret_jan = float(us_retention.loc["2026-01", "新增次日留存率"] * 100)
    us_ret_jul = float(us_retention.loc["2026-07", "新增次日留存率"] * 100)
    notes[("iOS", "non-Organic")] = (
        f"美国：1–5月Hair进入渗透率功能Top1\n"
        f"6–7月降至Top2–3\n"
        f"1–7月进入渗透率从{us_jan:.0f}%逐步下降到{us_jul:.0f}%\n"
        f"同期新增次留从{math.floor(us_ret_jan):.0f}%逐步上涨到{us_ret_jul:.0f}%"
    )

    br = hair[
        (hair["平台"] == "Android")
        & (hair["渠道/自然"] == "non-Organic")
        & (hair["市场"] == "巴西")
    ].set_index("月份")
    mx = hair[
        (hair["平台"] == "Android")
        & (hair["渠道/自然"] == "non-Organic")
        & (hair["市场"] == "墨西哥")
    ].set_index("月份")
    br_top = pd.to_numeric(br.loc[[f"2026-{m:02d}" for m in range(4, 7)], "进入渗透率"], errors="coerce") * 100
    mx_top = pd.to_numeric(mx.loc[[f"2026-{m:02d}" for m in range(3, 8)], "进入渗透率"], errors="coerce") * 100
    br_jul_rate = float(br.loc["2026-07", "进入渗透率"] * 100)
    br_jul_rank = int(br.loc["2026-07", "进入排名"])
    br_retention = cohort[
        (cohort["平台"] == "Android")
        & (cohort["渠道/自然"] == "non-Organic")
        & (cohort["市场"] == "巴西")
    ].set_index("月份")
    br_ret_apr_jun = pd.to_numeric(
        br_retention.loc[["2026-04", "2026-05", "2026-06"], "新增次日留存率"],
        errors="coerce",
    ).mean() * 100
    br_ret_jul = float(br_retention.loc["2026-07", "新增次日留存率"] * 100)
    notes[("Android", "non-Organic")] = (
        f"巴西：4–6月Hair进入渗透率功能Top1（{br_top.min():.0f}%–{br_top.max():.0f}%）\n"
        f"7月降至Top{br_jul_rank}（{br_jul_rate:.0f}%）\n"
        f"新增次留由{br_ret_apr_jun:.1f}%（4–6月均值）提升至{br_ret_jul:.1f}%（7月）\n"
        f"墨西哥：3–7月Hair进入渗透率功能持续Top1（{mx_top.min():.0f}%–{math.floor(mx_top.max()):.0f}%）"
    )
    return notes


def plot_enter_dnu_retention_long(
    hair: pd.DataFrame,
    cohort: pd.DataFrame,
    out_path: Path,
) -> None:
    """Combine Hair enter rank/rate with matching DNU and new-user D1 retention."""
    setup_font()
    hair = hair[hair["月份"] <= "2026-07"].copy()
    cohort = cohort[cohort["月份"] <= "2026-07"].copy()
    fig, axes = plt.subplots(4, 4, figsize=(22, 18), sharex=True, constrained_layout=False)
    fig.patch.set_facecolor("#F4F7FB")
    # Reserve more room for the cohort conclusions and compress the four chart rows.
    plt.subplots_adjust(left=0.06, right=0.985, top=0.700, bottom=0.060, wspace=0.17, hspace=0.30)

    fig.text(0.035, 0.972, "Hair 新用户进入渗透率、DNU与次日留存趋势", fontsize=27,
             fontweight="bold", color="#16233A", va="top")
    fig.text(
        0.035, 0.925,
        "2026年1—7月｜同一市场、平台及自然/渠道新用户分组｜Hair进入取看板10015706；DNU与新增次日留存率取看板10015834",
        fontsize=10.5, color="#7D8CA3", va="top",
    )

    columns = [("iOS", "Organic"), ("iOS", "non-Organic"),
               ("Android", "Organic"), ("Android", "non-Organic")]
    months = [f"2026-{m:02d}" for m in range(1, 8)]
    labels = [f"{m}月" for m in range(1, 8)]
    row_specs = [
        (hair, "进入排名", "进入渗透率排名", "rank"),
        (hair, "进入渗透率", "进入渗透率", "rate"),
        (cohort, "新增次日留存率", "新增次日留存率", "retention"),
        (cohort, "DNU", "DNU（日均）", "dnu"),
    ]
    column_insights = _build_column_insights(hair, cohort)
    (rank_bottom, rank_top), rank_ticks = _rank_limits(hair["进入排名"])
    rate_lo, rate_hi, rate_step = _percent_limits(hair["进入渗透率"])
    retention_lo, retention_hi, retention_step = _percent_limits(cohort["新增次日留存率"])
    for r, (source, col, ylabel, kind) in enumerate(row_specs):
        for c, (platform, channel) in enumerate(columns):
            ax = axes[r, c]
            style_axis(ax)
            sub = source[(source["平台"] == platform) & (source["渠道/自然"] == channel)]
            for country in COUNTRIES:
                s = sub[sub["市场"] == country].set_index("月份").reindex(months)
                y = pd.to_numeric(s[col], errors="coerce")
                if kind in {"rate", "retention"}:
                    y = y * 100
                # Emphasis follows the conclusion of each cohort, not a global market rule.
                if channel == "Organic":
                    linestyle, linewidth, marker, markersize, alpha, zorder = "--", 1.65, None, 0, 0.84, 2
                elif platform == "iOS":
                    is_focus = country == "美国"
                    linestyle = "-" if is_focus else "--"
                    linewidth = 3.4 if is_focus else 1.55
                    marker, markersize = ("o", 5.2) if is_focus else (None, 0)
                    alpha, zorder = (1.0, 5) if is_focus else (0.80, 2)
                else:
                    is_brazil = country == "巴西"
                    is_mexico = country == "墨西哥"
                    linestyle = "-" if (is_brazil or is_mexico) else "--"
                    linewidth = 3.4 if is_brazil else 1.75 if is_mexico else 1.55
                    marker, markersize = ("o", 5.2) if is_brazil else (None, 0)
                    alpha, zorder = (1.0, 5) if is_brazil else (0.88, 3) if is_mexico else (0.78, 2)
                ax.plot(
                    range(7), y,
                    color=COUNTRY_COLORS[country],
                    linestyle=linestyle,
                    linewidth=linewidth,
                    marker=marker,
                    markersize=markersize,
                    alpha=alpha,
                    zorder=zorder,
                )
                # Organic cohorts carry no value labels. For iOS paid acquisition,
                # label only the US extrema; DNU remains label-free in all panels.
                if channel == "non-Organic" and platform == "iOS" and country == "美国" and kind != "dnu":
                    valid = y.dropna()
                    extreme_x = sorted({int(valid.idxmin().split("-")[1]) - 1,
                                        int(valid.idxmax().split("-")[1]) - 1})
                    for x in extreme_x:
                        val = y.iloc[x] if x < len(y) else np.nan
                        if pd.notna(val):
                            if kind == "rank":
                                text_value, offset = f"#{int(val)}", -15
                            else:
                                text_value, offset = f"{val:.1f}%", 8
                            ax.annotate(
                                text_value, (x, val), xytext=(0, offset),
                                textcoords="offset points", ha="center", va="bottom",
                                fontsize=8.2, fontweight="bold", color=COUNTRY_COLORS[country], zorder=6,
                            )
                # For Android paid acquisition, retain concise Brazil labels around
                # the latest change while leaving Mexico and comparison markets clean.
                if channel == "non-Organic" and platform == "Android" and country == "巴西" and kind != "dnu":
                    label_x = [5, 6] if kind in {"rank", "rate"} else [3, 6]
                    for x in label_x:
                        val = y.iloc[x] if x < len(y) else np.nan
                        if pd.notna(val):
                            if kind == "rank":
                                text_value, offset = f"#{int(val)}", -15
                            else:
                                text_value, offset = f"{val:.1f}%", 8
                            ax.annotate(
                                text_value, (x, val), xytext=(0, offset),
                                textcoords="offset points", ha="center", va="bottom",
                                fontsize=8.2, fontweight="bold", color=COUNTRY_COLORS[country], zorder=6,
                            )

            if kind == "rank":
                ax.set_ylim(rank_bottom, rank_top)
                ax.set_yticks(rank_ticks)
            elif kind == "rate":
                ax.set_ylim(rate_lo, rate_hi)
                ax.set_yticks(np.arange(rate_lo, rate_hi + 0.001, rate_step))
                ax.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")
            elif kind == "dnu":
                # DNU level varies substantially by platform and acquisition type;
                # use an independent y-axis for each panel so local movement remains legible.
                panel_max = float(pd.to_numeric(sub["DNU"], errors="coerce").max())
                panel_step = 5000 if panel_max >= 20000 else 2000 if panel_max >= 10000 else 1000
                panel_hi = math.ceil(panel_max * 1.08 / panel_step) * panel_step
                ax.set_ylim(0, panel_hi)
                ax.set_yticks(np.arange(0, panel_hi + 0.001, panel_step))
                ax.yaxis.set_major_formatter(FuncFormatter(
                    lambda x, pos: f"{x / 10000:.1f}万" if x >= 10000 else (f"{x / 1000:.0f}k" if x >= 1000 else "0")
                ))
            else:
                ax.set_ylim(retention_lo, retention_hi)
                ax.set_yticks(np.arange(retention_lo, retention_hi + 0.001, retention_step))
                ax.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")

            ax.set_xticks(range(7), labels)
            ax.tick_params(axis="x", labelbottom=True)
            if c == 0:
                ax.set_ylabel(ylabel, fontsize=11, color="#425168")
            ax.set_xlabel("月份", fontsize=10, color="#74839A")

    # Four standalone conclusion cards keep each cohort's takeaway visually separate.
    card_y0, card_y1 = 0.748, 0.895
    for c, (platform, channel) in enumerate(columns):
        pos = axes[0, c].get_position()
        card_x0 = pos.x0 - 0.006
        card_x1 = pos.x1 + 0.006
        card_face, card_edge = "#FFFFFF", "#D7E0EB"
        card = FancyBboxPatch(
            (card_x0, card_y0), card_x1 - card_x0, card_y1 - card_y0,
            transform=fig.transFigure,
            boxstyle="round,pad=0.007,rounding_size=0.012",
            linewidth=1.15,
            edgecolor=card_edge,
            facecolor=card_face,
            zorder=1,
        )
        fig.add_artist(card)
        # A slim accent instead of a large color fill keeps the cards prominent but restrained.
        accent_y = card_y1 - 0.009
        if channel == "Organic":
            accents = [("#7D8CA3", 0.044)]
        elif platform == "iOS":
            accents = [(COUNTRY_COLORS["美国"], 0.044)]
        else:
            accents = [(COUNTRY_COLORS["巴西"], 0.029), (COUNTRY_COLORS["墨西哥"], 0.013)]
        accent_x = card_x0 + 0.012
        for accent_color, accent_width in accents:
            accent = FancyBboxPatch(
                (accent_x, accent_y), accent_width, 0.0045,
                transform=fig.transFigure,
                boxstyle="round,pad=0.0001,rounding_size=0.002",
                linewidth=0, facecolor=accent_color, zorder=2,
            )
            fig.add_artist(accent)
            accent_x += accent_width + 0.003
        fig.text(
            card_x0 + 0.012, card_y1 - 0.025,
            f"{platform} · {CHANNEL_LABELS[channel]}：",
            fontsize=16.5, color="#263348", fontweight="bold",
            ha="left", va="top", zorder=2,
        )
        if platform == "Android" and channel == "non-Organic":
            insight_lines = column_insights[(platform, channel)].splitlines()
            for line_index, line in enumerate(insight_lines):
                fig.text(
                    card_x0 + 0.012, card_y1 - 0.056 - line_index * 0.020,
                    line,
                    fontsize=12.3,
                    color=COUNTRY_COLORS["墨西哥"] if line.startswith("墨西哥：") else COUNTRY_COLORS["巴西"],
                    fontweight="bold", ha="left", va="top", zorder=2,
                )
        else:
            insight_color = (
                COUNTRY_COLORS["美国"]
                if platform == "iOS" and channel == "non-Organic"
                else "#33455E"
            )
            fig.text(
                card_x0 + 0.012, card_y1 - 0.058,
                column_insights[(platform, channel)],
                fontsize=13.0 if channel == "Organic" else 12.6,
                color=insight_color,
                fontweight="bold",
                ha="left", va="top", linespacing=1.47, zorder=2,
            )

    handles = []
    for country in COUNTRIES:
        handles.append(plt.Line2D(
            [0], [0], color=COUNTRY_COLORS[country], lw=2.0,
            ls="--", alpha=0.9, label=country,
        ))
    fig.legend(handles=handles, loc="upper right", bbox_to_anchor=(0.982, 0.974),
               ncol=5, frameon=False, fontsize=10)
    fig.text(
        0.06, 0.025,
        "注：进入排名越靠上越好；Hair进入渗透率为每日进入UV÷当日DNU后做月均；DNU为月内日均新增用户；留存为新增次日留存率。自然新增均为虚线；渠道新增按结论重点突出美国或巴西。",
        fontsize=9, color="#8996A9",
    )
    fig.savefig(out_path, dpi=220, facecolor=fig.get_facecolor())
    plt.close(fig)


def write_excel(merged: pd.DataFrame, hair: pd.DataFrame, path: Path) -> None:
    with pd.ExcelWriter(path, engine="openpyxl") as writer:
        hair.sort_values(["渠道/自然", "平台", "市场", "月份"]).to_excel(writer, sheet_name="Hair趋势", index=False)
        merged.sort_values(["月份", "市场", "平台", "渠道/自然", "进入排名"]).to_excel(writer, sheet_name="全功能排名底表", index=False)
        wb = writer.book
        for ws in wb.worksheets:
            ws.freeze_panes = "A2"
            ws.auto_filter.ref = ws.dimensions
            for col in ws.columns:
                width = min(max(len(str(cell.value)) if cell.value is not None else 0 for cell in col) + 2, 24)
                ws.column_dimensions[col[0].column_letter].width = width
        ws = wb["Hair趋势"]
        header = {cell.value: cell.column for cell in ws[1]}
        for name in ["进入渗透率", "打勾渗透率"]:
            col_idx = header.get(name)
            if col_idx:
                for row in range(2, ws.max_row + 1):
                    ws.cell(row, col_idx).number_format = "0.0%"


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    cohort_path = OUT_DIR / "DNU及新增次日留存率_202601-202607.csv"
    new_long_path = OUT_DIR / "Hair进入渗透率_DNU_新增次日留存率趋势_202601-202607.png"
    if "--refresh-dnu-retention" in sys.argv:
        hair = pd.read_csv(OUT_DIR / "Hair排名及渗透率明细_202601-202607_看板一致.csv")
        cohort = pull_new_user_dnu_retention()
        cohort.to_csv(cohort_path, index=False, encoding="utf-8-sig")
        plot_enter_dnu_retention_long(hair, cohort, new_long_path)
        print(new_long_path, flush=True)
        return
    if "--plots-only" in sys.argv:
        hair = pd.read_csv(OUT_DIR / "Hair排名及渗透率明细_202601-202607_看板一致.csv")
        plot_metric_combined(hair, "进入", OUT_DIR / "Hair进入渗透率排名与趋势_202601-202607.png")
        plot_metric_combined(hair, "打勾", OUT_DIR / "Hair打勾渗透率排名与趋势_202601-202607.png")
        plot_all_metrics_long(hair, OUT_DIR / "Hair进入与打勾渗透率趋势合并_202601-202607.png")
        if cohort_path.exists():
            cohort = pd.read_csv(cohort_path)
            plot_enter_dnu_retention_long(hair, cohort, new_long_path)
        print("PLOTS_ONLY_DONE", flush=True)
        return
    enter_rate_df = pull_enter_penetration()
    function_daily_df = pull_function_daily_data()
    active_daily_df = pull_active_daily_data()
    enter_rate_df.to_csv(OUT_DIR / "功能进入渗透率月均_看板90774.csv", index=False, encoding="utf-8-sig")
    function_daily_df.to_csv(OUT_DIR / "功能日数据_202601-202607.csv", index=False, encoding="utf-8-sig")
    active_daily_df.to_csv(OUT_DIR / "新用户DAU日数据_202601-202607.csv", index=False, encoding="utf-8-sig")
    merged, hair = build_detail_strict(enter_rate_df, function_daily_df, active_daily_df)
    validate_coverage(hair)
    merged.to_csv(OUT_DIR / "全功能月度排名底表_看板一致.csv", index=False, encoding="utf-8-sig")
    hair.to_csv(OUT_DIR / "Hair排名及渗透率明细_202601-202607_看板一致.csv", index=False, encoding="utf-8-sig")
    write_excel(merged, hair, OUT_DIR / "Hair排名及渗透率趋势_202601-202607_看板一致.xlsx")
    plot_metric_combined(hair, "进入", OUT_DIR / "Hair进入渗透率排名与趋势_202601-202607.png")
    plot_metric_combined(hair, "打勾", OUT_DIR / "Hair打勾渗透率排名与趋势_202601-202607.png")
    plot_all_metrics_long(hair, OUT_DIR / "Hair进入与打勾渗透率趋势合并_202601-202607.png")
    print("OUTPUTS", flush=True)
    for path in sorted(OUT_DIR.iterdir()):
        if path.is_file():
            print(path, flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise

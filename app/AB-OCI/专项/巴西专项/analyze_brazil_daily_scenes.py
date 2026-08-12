from __future__ import annotations

import bisect
import json
import math
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd

import matplotlib

matplotlib.use("Agg")
import matplotlib.font_manager as fm
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, TwoSlopeNorm
from matplotlib.patches import FancyBboxPatch, Rectangle


BASE_DIR = Path("/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项")
OUTPUT_DIR = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302"
)
RAW_CSV = OUTPUT_DIR / "巴西用户日场景分析一次性宽取数_202607.csv"
ANALYSIS_DIR = OUTPUT_DIR / "巴西用户日场景分析_202607"

SCENES = [
    "人像结构精修",
    "自然轻修",
    "AI一键出片",
    "氛围出片",
    "任务型工具编辑",
    "玩法尝试",
]

SCENE_DEFINITION = {
    "人像结构精修": "核心人像塑形：面部、身体、姿态等结构调整",
    "自然轻修": "皮肤、妆容等局部自然美化",
    "AI一键出片": "以少量操作完成整体效果的 AI 功能",
    "氛围出片": "光影、色调、裁剪等成片质感与风格调整",
    "任务型工具编辑": "消除、扩图、修复等目标明确的任务型操作",
    "玩法尝试": "换发型、AI 创作等探索和娱乐型体验",
}

FEATURE_TO_SCENE = {
    # 人像结构精修
    "reshape": "人像结构精修",
    "face": "人像结构精修",
    "body": "人像结构精修",
    "muscle": "人像结构精修",
    "stretch": "人像结构精修",
    # 自然轻修
    "skin": "自然轻修",
    "smooth": "自然轻修",
    "acne": "自然轻修",
    "skin tone": "自然轻修",
    "makeup": "自然轻修",
    "teeth": "自然轻修",
    "brighten": "自然轻修",
    "concealer": "自然轻修",
    "wrinkle": "自然轻修",
    "contour": "自然轻修",
    "matte": "自然轻修",
    "detail": "自然轻修",
    "blemish": "自然轻修",
    "eye brighten": "自然轻修",
    "dark circles": "自然轻修",
    "plump": "自然轻修",
    "clean skin": "自然轻修",
    "redness fix": "自然轻修",
    # AI 一键出片
    "magic": "AI一键出片",
    "ai retouch": "AI一键出片",
    "glowup": "AI一键出片",
    "preset": "AI一键出片",
    "expression": "AI一键出片",
    # 氛围出片
    "filters": "氛围出片",
    "filter": "氛围出片",
    "relight": "氛围出片",
    "bokeh": "氛围出片",
    "prism": "氛围出片",
    "glitter": "氛围出片",
    "effects": "氛围出片",
    "effect": "氛围出片",
    "adjust": "氛围出片",
    "crop": "氛围出片",
    "resize": "氛围出片",
    "blur": "氛围出片",
    "texture": "氛围出片",
    # 任务型工具编辑
    "eraser": "任务型工具编辑",
    "ai replace": "任务型工具编辑",
    "ai expand": "任务型工具编辑",
    "background": "任务型工具编辑",
    "ai repair": "任务型工具编辑",
    "stamp": "任务型工具编辑",
    "face fix": "任务型工具编辑",
    "text": "任务型工具编辑",
    "select area": "任务型工具编辑",
    "background adjust": "任务型工具编辑",
    # 玩法尝试
    "hair": "玩法尝试",
    "ai image": "玩法尝试",
    "ai tattoo": "玩法尝试",
    "hair dye": "玩法尝试",
    "hair enrich": "玩法尝试",
    "hairstyles": "玩法尝试",
    "hairdye finetune": "玩法尝试",
    "enrich": "玩法尝试",
    "volume": "玩法尝试",
    "mykit": "玩法尝试",
}

FEATURE_ALIASES = {
    "details": "detail",
    "detail": "detail",
    "ai-retouch": "ai retouch",
    "ai_retouch": "ai retouch",
    "airetouch": "ai retouch",
    "ai-repair": "ai repair",
    "ai_repair": "ai repair",
    "ai-expand": "ai expand",
    "ai_expand": "ai expand",
    "ai-replace": "ai replace",
    "ai_replace": "ai replace",
    "facefix": "face fix",
    "face_fix": "face fix",
    "skin_tone": "skin tone",
    "skintone": "skin tone",
    "glow up": "glowup",
    "aiimage": "ai image",
    "ai_image": "ai image",
    "aitattoo": "ai tattoo",
    "ai_tattoo": "ai tattoo",
}

DISPLAY_NAMES = {
    "reshape": "Reshape",
    "face": "Face",
    "body": "Body",
    "muscle": "Muscle",
    "stretch": "Stretch",
    "skin": "Skin",
    "smooth": "Smooth",
    "acne": "Acne",
    "skin tone": "Skin Tone",
    "makeup": "Makeup",
    "teeth": "Teeth",
    "brighten": "Brighten",
    "concealer": "Concealer",
    "wrinkle": "Wrinkle",
    "contour": "Contour",
    "matte": "Matte",
    "detail": "Detail",
    "blemish": "Blemish",
    "eye brighten": "Eye Brighten",
    "dark circles": "Dark Circles",
    "plump": "Plump",
    "clean skin": "Clean Skin",
    "redness fix": "Redness Fix",
    "magic": "Magic",
    "ai retouch": "AI Retouch",
    "glowup": "Glowup",
    "preset": "Preset",
    "expression": "Expression",
    "filters": "Filters",
    "filter": "Filters",
    "relight": "Relight",
    "bokeh": "Bokeh",
    "prism": "Prism",
    "glitter": "Glitter",
    "effects": "Effects",
    "effect": "Effects",
    "adjust": "Adjust",
    "crop": "Crop",
    "resize": "Resize",
    "blur": "Blur",
    "texture": "Texture",
    "eraser": "Eraser",
    "ai replace": "AI Replace",
    "ai expand": "AI Expand",
    "background": "Background",
    "ai repair": "AI Repair",
    "stamp": "Stamp",
    "face fix": "Face Fix",
    "text": "Text",
    "select area": "Select Area",
    "background adjust": "Background Adjust",
    "hair": "Hair",
    "ai image": "AI Image",
    "ai tattoo": "AI Tattoo",
    "hair dye": "Hair Dye",
    "hair enrich": "Hair Enrich",
    "hairstyles": "Hairstyles",
    "hairdye finetune": "Hair Dye Finetune",
    "enrich": "Enrich",
    "volume": "Volume",
    "mykit": "MyKit",
}

COLORS = {
    "ink": "#172033",
    "muted": "#7C8AA0",
    "grid": "#E4E9F0",
    "panel": "#F7F9FC",
    "blue": "#3B6FF5",
    "blue_light": "#DCE7FF",
    "orange": "#FF8A3D",
    "orange_light": "#FFE5D4",
    "teal": "#20A39E",
    "gold": "#D6A21D",
}


def clean_feature_name(value: object) -> str:
    text = "" if value is None else str(value)
    text = text.strip()
    if not text or text == "\\N" or text.lower() == "nan":
        return ""
    key = re.sub(r"\s+", " ", text.replace("_", " ")).strip().lower()
    key = FEATURE_ALIASES.get(key, key)
    return key


def display_feature(key: str) -> str:
    if key in DISPLAY_NAMES:
        return DISPLAY_NAMES[key]
    return " ".join(part.capitalize() for part in key.split())


def scene_for_feature(value: object) -> str | None:
    return FEATURE_TO_SCENE.get(clean_feature_name(value))


def safe_int(value: object, default: int = 0) -> int:
    if value is None:
        return default
    text = str(value).strip()
    if not text or text == "\\N" or text.lower() == "nan":
        return default
    try:
        return int(float(text))
    except (TypeError, ValueError):
        return default


def safe_float(value: object, default: float = 0.0) -> float:
    if value is None:
        return default
    text = str(value).strip()
    if not text or text == "\\N" or text.lower() == "nan":
        return default
    try:
        return float(text)
    except (TypeError, ValueError):
        return default


def clean_value(value: object, fallback: str = "未知") -> str:
    text = "" if value is None else str(value).strip()
    if not text or text == "\\N" or text.lower() == "nan":
        return fallback
    return text


def normalize_os(value: object) -> str:
    text = clean_value(value)
    lower = text.lower()
    if "ios" in lower or "iphone" in lower:
        return "iOS"
    if "android" in lower:
        return "Android"
    return text


def normalize_new(value: object) -> str:
    text = clean_value(value)
    lower = text.lower()
    if lower in {"new", "新用户", "1"}:
        return "New"
    if lower in {"old", "老用户", "0"}:
        return "Old"
    return text


def normalize_channel(value: object) -> str:
    text = clean_value(value)
    lower = text.lower()
    if any(
        token in lower
        for token in ["non-organic", "non organic", "ua", "渠道", "paid"]
    ):
        return "渠道新用户"
    if any(token in lower for token in ["organic", "自然"]):
        return "自然新用户"
    if lower in {"not applicable", "n/a"}:
        return "不适用"
    return text


def parse_function_detail(detail: object) -> dict[str, tuple[int, int, int]]:
    text = "" if detail is None else str(detail)
    if not text or text == "\\N" or text.lower() == "nan":
        return {}
    result: dict[str, list[int]] = {}
    for part in text.split("|"):
        fields = part.rsplit("~", 3)
        if len(fields) != 4:
            continue
        name = clean_feature_name(fields[0])
        if not name:
            continue
        values = [safe_int(fields[1]), safe_int(fields[2]), safe_int(fields[3])]
        if name not in result:
            result[name] = values
        else:
            for idx, value in enumerate(values):
                result[name][idx] += value
    return {key: tuple(values) for key, values in result.items()}


def get_header_columns(path: Path) -> list[str]:
    return list(pd.read_csv(path, nrows=0, encoding="utf-8-sig").columns)


def resolve_columns(header: list[str], wanted: list[str]) -> dict[str, str]:
    by_tail: dict[str, str] = {}
    for column in header:
        by_tail.setdefault(column.split(".")[-1], column)
    resolved = {}
    for name in wanted:
        if name in header:
            resolved[name] = name
        elif name in by_tail:
            resolved[name] = by_tail[name]
        else:
            raise KeyError(f"Missing column {name}; available={header}")
    return resolved


def metric_counter() -> Counter:
    return Counter()


def update_behavior_metric(
    metric: Counter,
    *,
    enter_pv: int,
    check_pv: int,
    save_pv: int,
    function_count: int,
    d1_active: int,
    d7_active: int,
    d1_mature: int,
    d7_mature: int,
    newpay_d0: int,
    newpay_d7: int,
    renew_d0: int,
    renew_d7: int,
) -> None:
    metric["scene_user_days"] += 1
    metric["enter_pv"] += enter_pv
    metric["check_pv"] += check_pv
    metric["save_pv"] += save_pv
    metric["check_user_days"] += int(check_pv > 0)
    metric["save_user_days"] += int(save_pv > 0)
    metric["function_count_sum"] += function_count
    metric["d1_eligible_days"] += d1_mature
    metric["d1_retained_days"] += d1_active * d1_mature
    metric["d7_eligible_days"] += d7_mature
    metric["d7_retained_days"] += d7_active * d7_mature
    metric["d0_newpay_days"] += newpay_d0
    metric["d7_newpay_eligible_days"] += d7_mature
    metric["d7_newpay_days"] += newpay_d7 * d7_mature
    metric["d0_renew_days"] += renew_d0
    metric["d7_renew_eligible_days"] += d7_mature
    metric["d7_renew_days"] += renew_d7 * d7_mature


def update_sub_metric(metric: Counter, source_metric: Counter) -> None:
    for key in [
        "sub_enter_pv",
        "sub_enter_uv",
        "sub_suc_uv",
        "sub_paid_uv",
        "sub_gross",
    ]:
        metric[key] += source_metric.get(key, 0)


def make_segments(
    os_type: str,
    is_new: str,
    is_ua: str,
    install_age_bucket: str,
    pay_status: str,
    province: str,
) -> list[tuple[str, str]]:
    segments = [
        ("整体", "整体"),
        ("平台", normalize_os(os_type)),
        ("新老", normalize_new(is_new)),
        ("安装龄", clean_value(install_age_bucket)),
        ("付费状态", clean_value(pay_status)),
    ]
    if normalize_new(is_new) == "New":
        segments.append(("新用户来源", normalize_channel(is_ua)))
    if province:
        segments.append(("省份", clean_value(province)))
    return segments


def date_ordinal(date_p: int) -> int:
    return datetime.strptime(str(date_p), "%Y%m%d").date().toordinal()


def first_pass_events_and_denominators(
    header: list[str],
) -> tuple[
    dict[tuple[int, str], dict[str, Counter]],
    dict[str, dict[str, object]],
    Counter,
    Counter,
    Counter,
    dict[str, tuple[int, int]],
    Counter,
]:
    wanted = [
        "record_type",
        "date_p",
        "gid",
        "os_type",
        "province",
        "is_new",
        "is_ua",
        "install_age_bucket",
        "pay_status",
        "source_function",
        "sub_enter_pv",
        "sub_enter_uv",
        "sub_suc_uv",
        "sub_paid_uv",
        "sub_gross",
        "pay_stage",
        "pay_withhold_stage",
        "period_type",
        "pay_channel",
        "paid_order_count",
        "paid_gross",
        "dau_user_days",
    ]
    resolved = resolve_columns(header, wanted)
    usecols = list(dict.fromkeys(resolved.values()))
    rename_map = {actual: canonical for canonical, actual in resolved.items()}

    sub_by_user_day: dict[tuple[int, str], dict[str, Counter]] = {}
    pay_by_gid: dict[str, dict[str, object]] = {}
    dau_denom = Counter()
    daily_dau = Counter()
    record_counts = Counter()
    date_ranges: dict[str, tuple[int, int]] = {}
    source_function_metric = Counter()

    for chunk_no, chunk in enumerate(
        pd.read_csv(
            RAW_CSV,
            usecols=usecols,
            dtype=str,
            keep_default_na=False,
            encoding="utf-8-sig",
            chunksize=300_000,
        ),
        start=1,
    ):
        chunk = chunk.rename(columns=rename_map)
        counts = chunk["record_type"].value_counts()
        record_counts.update({str(k): int(v) for k, v in counts.items()})

        for record_type, date_series in chunk.groupby("record_type")["date_p"]:
            numeric_dates = pd.to_numeric(date_series, errors="coerce").dropna()
            if numeric_dates.empty:
                continue
            low = int(numeric_dates.min())
            high = int(numeric_dates.max())
            old = date_ranges.get(str(record_type))
            if old is None:
                date_ranges[str(record_type)] = (low, high)
            else:
                date_ranges[str(record_type)] = (
                    min(old[0], low),
                    max(old[1], high),
                )

        sub_rows = chunk.loc[chunk["record_type"] == "SUB_SOURCE"]
        for row in sub_rows.itertuples(index=False):
            data = row._asdict()
            date_p = safe_int(data["date_p"])
            gid = clean_value(data["gid"], "")
            source_function = clean_feature_name(data["source_function"])
            scene = scene_for_feature(source_function)
            if not date_p or not gid:
                continue
            scene_key = scene or "未分类来源"
            key = (date_p, gid)
            by_scene = sub_by_user_day.setdefault(key, {})
            metric = by_scene.setdefault(scene_key, Counter())
            enter_pv = safe_int(data["sub_enter_pv"])
            enter_uv = safe_int(data["sub_enter_uv"])
            suc_uv = safe_int(data["sub_suc_uv"])
            paid_uv = safe_int(data["sub_paid_uv"])
            gross = safe_float(data["sub_gross"])
            metric["sub_enter_pv"] += enter_pv
            metric["sub_enter_uv"] = max(metric["sub_enter_uv"], enter_uv)
            metric["sub_suc_uv"] = max(metric["sub_suc_uv"], suc_uv)
            metric["sub_paid_uv"] = max(metric["sub_paid_uv"], paid_uv)
            metric["sub_gross"] += gross
            source_key = source_function or "未识别"
            for metric_name, value in [
                ("rows", 1),
                ("sub_enter_pv", enter_pv),
                ("sub_enter_uv", enter_uv),
                ("sub_suc_uv", suc_uv),
                ("sub_paid_uv", paid_uv),
                ("sub_gross", gross),
            ]:
                source_function_metric[(source_key, scene_key, metric_name)] += value

        pay_rows = chunk.loc[chunk["record_type"] == "PAY_EVENT"]
        for row in pay_rows.itertuples(index=False):
            data = row._asdict()
            date_p = safe_int(data["date_p"])
            gid = clean_value(data["gid"], "")
            if not date_p or not gid:
                continue
            ordinal = date_ordinal(date_p)
            stage = safe_int(data["pay_withhold_stage"])
            info = pay_by_gid.setdefault(
                gid,
                {
                    "new_dates": [],
                    "renew_dates": [],
                    "gross_by_date": Counter(),
                    "orders_by_date": Counter(),
                },
            )
            if stage == 1:
                info["new_dates"].append(ordinal)
            elif stage >= 2:
                info["renew_dates"].append(ordinal)
            info["gross_by_date"][ordinal] += safe_float(data["paid_gross"])
            info["orders_by_date"][ordinal] += safe_int(data["paid_order_count"])

        dau_rows = chunk.loc[chunk["record_type"] == "DAU_SEGMENT"]
        for row in dau_rows.itertuples(index=False):
            data = row._asdict()
            date_p = safe_int(data["date_p"])
            value = safe_int(data["dau_user_days"])
            if not date_p or value <= 0:
                continue
            os_type = normalize_os(data["os_type"])
            is_new = normalize_new(data["is_new"])
            is_ua = normalize_channel(data["is_ua"])
            install_bucket = clean_value(data["install_age_bucket"])
            pay_status = clean_value(data["pay_status"])
            province = clean_value(data["province"])
            daily_dau[date_p] += value
            for dimension, segment in make_segments(
                os_type,
                is_new,
                is_ua,
                install_bucket,
                pay_status,
                province,
            ):
                dau_denom[(dimension, segment)] += value

        if chunk_no % 10 == 0:
            print(f"first pass chunks: {chunk_no}", flush=True)

    for info in pay_by_gid.values():
        info["new_dates"] = sorted(set(info["new_dates"]))
        info["renew_dates"] = sorted(set(info["renew_dates"]))

    return (
        sub_by_user_day,
        pay_by_gid,
        dau_denom,
        daily_dau,
        record_counts,
        date_ranges,
        source_function_metric,
    )


def has_event_in_window(sorted_dates: list[int], start: int, days: int) -> int:
    if not sorted_dates:
        return 0
    idx = bisect.bisect_left(sorted_dates, start)
    return int(idx < len(sorted_dates) and sorted_dates[idx] <= start + days)


def second_pass_user_days(
    header: list[str],
    sub_by_user_day: dict[tuple[int, str], dict[str, Counter]],
    pay_by_gid: dict[str, dict[str, object]],
) -> dict[str, object]:
    wanted = [
        "record_type",
        "date_p",
        "gid",
        "os_type",
        "province",
        "is_new",
        "is_ua",
        "install_age_bucket",
        "pay_status",
        "d1_active",
        "d7_active",
        "d1_mature",
        "d7_mature",
        "function_detail",
    ]
    resolved = resolve_columns(header, wanted)
    usecols = list(dict.fromkeys(resolved.values()))
    rename_map = {actual: canonical for canonical, actual in resolved.items()}

    scene_metric = defaultdict(metric_counter)
    scene_sub_metric = defaultdict(metric_counter)
    segment_metric = defaultdict(metric_counter)
    segment_sub_metric = defaultdict(metric_counter)
    daily_metric = defaultdict(metric_counter)
    function_metric = defaultdict(metric_counter)
    unknown_function_metric = defaultdict(metric_counter)
    scene_combo = Counter()
    within_scene_combo = {scene: Counter() for scene in SCENES}
    scene_pair = Counter()
    scene_count_dist = Counter()
    function_count_dist = defaultdict(Counter)
    function_active_user_days = 0
    mapped_user_days = 0
    linked_sub_keys = set()
    malformed_detail_rows = 0

    for chunk_no, chunk in enumerate(
        pd.read_csv(
            RAW_CSV,
            usecols=usecols,
            dtype=str,
            keep_default_na=False,
            encoding="utf-8-sig",
            chunksize=120_000,
        ),
        start=1,
    ):
        chunk = chunk.rename(columns=rename_map)
        user_rows = chunk.loc[chunk["record_type"] == "USER_DAY"]
        for row in user_rows.itertuples(index=False):
            data = row._asdict()
            date_p = safe_int(data["date_p"])
            gid = clean_value(data["gid"], "")
            if not date_p or not gid:
                continue

            function_active_user_days += 1
            detail = parse_function_detail(data["function_detail"])
            if not detail and clean_value(data["function_detail"], ""):
                malformed_detail_rows += 1

            scene_functions: dict[str, dict[str, tuple[int, int, int]]] = {
                scene: {} for scene in SCENES
            }
            for feature, values in detail.items():
                enter_pv, check_pv, save_pv = values
                if enter_pv <= 0:
                    continue
                scene = scene_for_feature(feature)
                if scene is None:
                    metric = unknown_function_metric[feature]
                    metric["enter_user_days"] += 1
                    metric["enter_pv"] += enter_pv
                    metric["check_user_days"] += int(check_pv > 0)
                    metric["save_user_days"] += int(save_pv > 0)
                    continue
                scene_functions[scene][feature] = values

            scenes = sorted(
                [scene for scene, values in scene_functions.items() if values],
                key=SCENES.index,
            )
            if scenes:
                mapped_user_days += 1
            scene_count_dist[len(scenes)] += 1
            if scenes:
                scene_combo[tuple(scenes)] += 1
            for left_idx, left in enumerate(scenes):
                for right in scenes[left_idx + 1 :]:
                    scene_pair[(left, right)] += 1

            os_type = normalize_os(data["os_type"])
            province = clean_value(data["province"])
            is_new = normalize_new(data["is_new"])
            is_ua = normalize_channel(data["is_ua"])
            install_bucket = clean_value(data["install_age_bucket"])
            pay_status = clean_value(data["pay_status"])
            segments = make_segments(
                os_type,
                is_new,
                is_ua,
                install_bucket,
                pay_status,
                province,
            )

            d1_active = safe_int(data["d1_active"])
            d7_active = safe_int(data["d7_active"])
            d1_mature = safe_int(data["d1_mature"])
            d7_mature = safe_int(data["d7_mature"])

            ordinal = date_ordinal(date_p)
            pay_info = pay_by_gid.get(gid)
            if pay_info:
                new_dates = pay_info["new_dates"]
                renew_dates = pay_info["renew_dates"]
                newpay_d0 = has_event_in_window(new_dates, ordinal, 0)
                newpay_d7 = has_event_in_window(new_dates, ordinal, 7)
                renew_d0 = has_event_in_window(renew_dates, ordinal, 0)
                renew_d7 = has_event_in_window(renew_dates, ordinal, 7)
            else:
                newpay_d0 = newpay_d7 = renew_d0 = renew_d7 = 0

            for scene in scenes:
                features = scene_functions[scene]
                enter_pv = sum(values[0] for values in features.values())
                check_pv = sum(values[1] for values in features.values())
                save_pv = sum(values[2] for values in features.values())
                function_count = len(features)
                update_behavior_metric(
                    scene_metric[scene],
                    enter_pv=enter_pv,
                    check_pv=check_pv,
                    save_pv=save_pv,
                    function_count=function_count,
                    d1_active=d1_active,
                    d7_active=d7_active,
                    d1_mature=d1_mature,
                    d7_mature=d7_mature,
                    newpay_d0=newpay_d0,
                    newpay_d7=newpay_d7,
                    renew_d0=renew_d0,
                    renew_d7=renew_d7,
                )
                update_behavior_metric(
                    daily_metric[(date_p, scene)],
                    enter_pv=enter_pv,
                    check_pv=check_pv,
                    save_pv=save_pv,
                    function_count=function_count,
                    d1_active=d1_active,
                    d7_active=d7_active,
                    d1_mature=d1_mature,
                    d7_mature=d7_mature,
                    newpay_d0=newpay_d0,
                    newpay_d7=newpay_d7,
                    renew_d0=renew_d0,
                    renew_d7=renew_d7,
                )
                function_count_dist[scene][function_count] += 1
                combo = tuple(sorted(display_feature(feature) for feature in features))
                within_scene_combo[scene][combo] += 1

                for feature, values in features.items():
                    metric = function_metric[(scene, display_feature(feature))]
                    metric["enter_user_days"] += 1
                    metric["enter_pv"] += values[0]
                    metric["check_user_days"] += int(values[1] > 0)
                    metric["check_pv"] += values[1]
                    metric["save_user_days"] += int(values[2] > 0)
                    metric["save_pv"] += values[2]

                for dimension, segment in segments:
                    update_behavior_metric(
                        segment_metric[(dimension, segment, scene)],
                        enter_pv=enter_pv,
                        check_pv=check_pv,
                        save_pv=save_pv,
                        function_count=function_count,
                        d1_active=d1_active,
                        d7_active=d7_active,
                        d1_mature=d1_mature,
                        d7_mature=d7_mature,
                        newpay_d0=newpay_d0,
                        newpay_d7=newpay_d7,
                        renew_d0=renew_d0,
                        renew_d7=renew_d7,
                    )

            sub_info = sub_by_user_day.get((date_p, gid))
            if sub_info:
                linked_sub_keys.add((date_p, gid))
                for source_scene, source_metric in sub_info.items():
                    scene_sub_metric[source_scene]["matched_user_days"] += 1
                    update_sub_metric(scene_sub_metric[source_scene], source_metric)
                    for dimension, segment in segments:
                        update_sub_metric(
                            segment_sub_metric[(dimension, segment, source_scene)],
                            source_metric,
                        )
                    if source_scene in SCENES:
                        update_sub_metric(
                            daily_metric[(date_p, source_scene)], source_metric
                        )

        if chunk_no % 10 == 0:
            print(f"second pass chunks: {chunk_no}", flush=True)

    return {
        "scene_metric": scene_metric,
        "scene_sub_metric": scene_sub_metric,
        "segment_metric": segment_metric,
        "segment_sub_metric": segment_sub_metric,
        "daily_metric": daily_metric,
        "function_metric": function_metric,
        "unknown_function_metric": unknown_function_metric,
        "scene_combo": scene_combo,
        "within_scene_combo": within_scene_combo,
        "scene_pair": scene_pair,
        "scene_count_dist": scene_count_dist,
        "function_count_dist": function_count_dist,
        "function_active_user_days": function_active_user_days,
        "mapped_user_days": mapped_user_days,
        "linked_sub_key_count": len(linked_sub_keys),
        "malformed_detail_rows": malformed_detail_rows,
    }


def divide(numerator: float, denominator: float) -> float:
    if denominator in (0, None) or pd.isna(denominator):
        return np.nan
    return numerator / denominator


def metric_to_row(
    scene: str,
    metric: Counter,
    sub_metric: Counter,
    denominator: int,
) -> dict[str, object]:
    row = {
        "场景": scene,
        "场景定义": SCENE_DEFINITION.get(scene, ""),
        "DAU用户日": denominator,
        "场景使用用户日": metric["scene_user_days"],
        "场景用户日渗透率": divide(metric["scene_user_days"], denominator),
        "进入PV": metric["enter_pv"],
        "日均进入频次": divide(metric["enter_pv"], metric["scene_user_days"]),
        "打勾用户日": metric["check_user_days"],
        "进入打勾率": divide(
            metric["check_user_days"], metric["scene_user_days"]
        ),
        "保存用户日": metric["save_user_days"],
        "进入保存率": divide(
            metric["save_user_days"], metric["scene_user_days"]
        ),
        "打勾保存率": divide(
            metric["save_user_days"], metric["check_user_days"]
        ),
        "日均使用功能数": divide(
            metric["function_count_sum"], metric["scene_user_days"]
        ),
        "D1样本用户日": metric["d1_eligible_days"],
        "D1留存用户日": metric["d1_retained_days"],
        "D1留存率": divide(
            metric["d1_retained_days"], metric["d1_eligible_days"]
        ),
        "D7样本用户日": metric["d7_eligible_days"],
        "D7留存用户日": metric["d7_retained_days"],
        "D7留存率": divide(
            metric["d7_retained_days"], metric["d7_eligible_days"]
        ),
        "订阅页曝光PV": sub_metric["sub_enter_pv"],
        "订阅页曝光用户日": sub_metric["sub_enter_uv"],
        "场景订阅页曝光率": divide(
            sub_metric["sub_enter_uv"], metric["scene_user_days"]
        ),
        "订阅成功用户日": sub_metric["sub_suc_uv"],
        "曝光订阅成功率": divide(
            sub_metric["sub_suc_uv"], sub_metric["sub_enter_uv"]
        ),
        "订阅付费用户日": sub_metric["sub_paid_uv"],
        "订阅成功付费率": divide(
            sub_metric["sub_paid_uv"], sub_metric["sub_suc_uv"]
        ),
        "订阅毛利": sub_metric["sub_gross"],
        "实际D0首购用户日": metric["d0_newpay_days"],
        "实际D0首购关联率": divide(
            metric["d0_newpay_days"], metric["scene_user_days"]
        ),
        "实际D7首购样本用户日": metric["d7_newpay_eligible_days"],
        "实际D7首购用户日": metric["d7_newpay_days"],
        "实际D7首购关联率": divide(
            metric["d7_newpay_days"], metric["d7_newpay_eligible_days"]
        ),
        "实际D0续费用户日": metric["d0_renew_days"],
        "实际D0续费关联率": divide(
            metric["d0_renew_days"], metric["scene_user_days"]
        ),
        "实际D7续费样本用户日": metric["d7_renew_eligible_days"],
        "实际D7续费用户日": metric["d7_renew_days"],
        "实际D7续费关联率": divide(
            metric["d7_renew_days"], metric["d7_renew_eligible_days"]
        ),
    }
    return row


def build_output_tables(
    first_pass: tuple,
    second_pass: dict[str, object],
) -> dict[str, pd.DataFrame]:
    (
        sub_by_user_day,
        pay_by_gid,
        dau_denom,
        daily_dau,
        record_counts,
        date_ranges,
        source_function_metric,
    ) = first_pass

    scene_metric = second_pass["scene_metric"]
    scene_sub_metric = second_pass["scene_sub_metric"]
    segment_metric = second_pass["segment_metric"]
    segment_sub_metric = second_pass["segment_sub_metric"]
    total_dau = dau_denom[("整体", "整体")]

    core_rows = []
    for scene in SCENES:
        core_rows.append(
            metric_to_row(
                scene,
                scene_metric[scene],
                scene_sub_metric[scene],
                total_dau,
            )
        )
    core_df = pd.DataFrame(core_rows)

    segment_rows = []
    for (dimension, segment, scene), metric in segment_metric.items():
        if scene not in SCENES:
            continue
        denom = dau_denom[(dimension, segment)]
        row = metric_to_row(
            scene,
            metric,
            segment_sub_metric[(dimension, segment, scene)],
            denom,
        )
        row = {"维度": dimension, "分层": segment, **row}
        segment_rows.append(row)
    segment_df = pd.DataFrame(segment_rows)
    if not segment_df.empty:
        dimension_order = {
            "整体": 0,
            "新老": 1,
            "新用户来源": 2,
            "安装龄": 3,
            "付费状态": 4,
            "平台": 5,
            "省份": 6,
        }
        segment_df["_dim_order"] = segment_df["维度"].map(dimension_order).fillna(99)
        segment_df["_scene_order"] = segment_df["场景"].map(
            {scene: idx for idx, scene in enumerate(SCENES)}
        )
        segment_df = (
            segment_df.sort_values(
                ["_dim_order", "分层", "_scene_order"],
                kind="stable",
            )
            .drop(columns=["_dim_order", "_scene_order"])
            .reset_index(drop=True)
        )

    daily_rows = []
    for date_p in sorted(daily_dau):
        for scene in SCENES:
            daily_rows.append(
                {
                    "日期": date_p,
                    **metric_to_row(
                        scene,
                        second_pass["daily_metric"][(date_p, scene)],
                        second_pass["daily_metric"][(date_p, scene)],
                        daily_dau[date_p],
                    ),
                }
            )
    daily_df = pd.DataFrame(daily_rows)

    function_rows = []
    for (scene, function), metric in second_pass["function_metric"].items():
        scene_days = scene_metric[scene]["scene_user_days"]
        function_rows.append(
            {
                "场景": scene,
                "功能": function,
                "进入用户日": metric["enter_user_days"],
                "占场景用户日": divide(metric["enter_user_days"], scene_days),
                "进入PV": metric["enter_pv"],
                "进入频次": divide(metric["enter_pv"], metric["enter_user_days"]),
                "打勾用户日": metric["check_user_days"],
                "进入打勾率": divide(
                    metric["check_user_days"], metric["enter_user_days"]
                ),
                "保存用户日": metric["save_user_days"],
                "进入保存率": divide(
                    metric["save_user_days"], metric["enter_user_days"]
                ),
            }
        )
    function_df = pd.DataFrame(function_rows)
    if not function_df.empty:
        function_df = function_df.sort_values(
            ["场景", "进入用户日"], ascending=[True, False]
        ).reset_index(drop=True)

    total_any_scene_days = second_pass["mapped_user_days"]
    pair_rows = []
    for x in SCENES:
        x_count = scene_metric[x]["scene_user_days"]
        for y in SCENES:
            if x == y:
                xy_count = x_count
            else:
                pair_key = tuple(sorted((x, y), key=SCENES.index))
                xy_count = second_pass["scene_pair"][pair_key]
            y_count = scene_metric[y]["scene_user_days"]
            conditional = divide(xy_count, x_count)
            y_penetration = divide(y_count, total_dau)
            union = x_count + y_count - xy_count
            pair_rows.append(
                {
                    "X场景": x,
                    "Y场景": y,
                    "X用户日": x_count,
                    "XY共用用户日": xy_count,
                    "使用X时同时使用Y占比": conditional,
                    "Y占DAU": y_penetration,
                    "Lift": divide(conditional, y_penetration),
                    "Jaccard": divide(xy_count, union),
                }
            )
    pair_df = pd.DataFrame(pair_rows)

    combo_rows = []
    for combo, count in second_pass["scene_combo"].most_common():
        combo_rows.append(
            {
                "场景组合": " + ".join(combo),
                "场景数": len(combo),
                "用户日": count,
                "占DAU": divide(count, total_dau),
                "占有场景使用用户日": divide(count, total_any_scene_days),
            }
        )
    scene_combo_df = pd.DataFrame(combo_rows)

    within_rows = []
    for scene in SCENES:
        scene_days = scene_metric[scene]["scene_user_days"]
        for combo, count in second_pass["within_scene_combo"][scene].most_common(50):
            within_rows.append(
                {
                    "场景": scene,
                    "功能组合": " + ".join(combo),
                    "功能数": len(combo),
                    "用户日": count,
                    "占场景用户日": divide(count, scene_days),
                }
            )
    within_combo_df = pd.DataFrame(within_rows)

    count_rows = []
    zero_scene_days = max(total_dau - total_any_scene_days, 0)
    count_rows.append(
        {
            "口径": "场景数",
            "场景": "全部",
            "数量": 0,
            "用户日": zero_scene_days,
            "占DAU或场景用户日": divide(zero_scene_days, total_dau),
        }
    )
    for count, user_days in sorted(second_pass["scene_count_dist"].items()):
        if count == 0:
            continue
        count_rows.append(
            {
                "口径": "场景数",
                "场景": "全部",
                "数量": count,
                "用户日": user_days,
                "占DAU或场景用户日": divide(user_days, total_dau),
            }
        )
    for scene in SCENES:
        scene_days = scene_metric[scene]["scene_user_days"]
        for count, user_days in sorted(
            second_pass["function_count_dist"][scene].items()
        ):
            count_rows.append(
                {
                    "口径": "场景内功能数",
                    "场景": scene,
                    "数量": count,
                    "用户日": user_days,
                    "占DAU或场景用户日": divide(user_days, scene_days),
                }
            )
    count_dist_df = pd.DataFrame(count_rows)

    source_rows = []
    source_keys = sorted(
        {
            (function_name, scene)
            for function_name, scene, metric_name in source_function_metric
        }
    )
    for function_name, scene in source_keys:
        source_rows.append(
            {
                "订阅来源功能": display_feature(function_name)
                if function_name != "未识别"
                else function_name,
                "场景": scene,
                "订阅页曝光PV": source_function_metric[
                    (function_name, scene, "sub_enter_pv")
                ],
                "订阅页曝光用户日": source_function_metric[
                    (function_name, scene, "sub_enter_uv")
                ],
                "订阅成功用户日": source_function_metric[
                    (function_name, scene, "sub_suc_uv")
                ],
                "曝光订阅成功率": divide(
                    source_function_metric[
                        (function_name, scene, "sub_suc_uv")
                    ],
                    source_function_metric[
                        (function_name, scene, "sub_enter_uv")
                    ],
                ),
                "订阅付费用户日": source_function_metric[
                    (function_name, scene, "sub_paid_uv")
                ],
                "订阅毛利": source_function_metric[
                    (function_name, scene, "sub_gross")
                ],
            }
        )
    source_df = pd.DataFrame(source_rows)
    if not source_df.empty:
        source_df = source_df.sort_values(
            ["订阅毛利", "订阅页曝光用户日"], ascending=False
        ).reset_index(drop=True)

    unknown_rows = []
    for feature, metric in second_pass["unknown_function_metric"].items():
        unknown_rows.append(
            {
                "原始功能": display_feature(feature),
                "标准化键": feature,
                "进入用户日": metric["enter_user_days"],
                "进入PV": metric["enter_pv"],
                "打勾用户日": metric["check_user_days"],
                "保存用户日": metric["save_user_days"],
            }
        )
    unknown_df = pd.DataFrame(unknown_rows)
    if not unknown_df.empty:
        unknown_df = unknown_df.sort_values(
            "进入用户日", ascending=False
        ).reset_index(drop=True)

    qc_rows = []
    for record_type, count in sorted(record_counts.items()):
        low, high = date_ranges.get(record_type, (None, None))
        qc_rows.append(
            {
                "检查项": f"{record_type}记录",
                "值": count,
                "日期开始": low,
                "日期结束": high,
                "状态": "通过" if count > 0 else "异常",
                "说明": "",
            }
        )
    unknown_enter_days = (
        unknown_df["进入用户日"].sum() if not unknown_df.empty else 0
    )
    qc_rows.extend(
        [
            {
                "检查项": "DAU用户日",
                "值": total_dau,
                "日期开始": min(daily_dau) if daily_dau else None,
                "日期结束": max(daily_dau) if daily_dau else None,
                "状态": "通过" if total_dau > 0 else "异常",
                "说明": "DAU_SEGMENT完整分层求和",
            },
            {
                "检查项": "有功能行为用户日",
                "值": second_pass["function_active_user_days"],
                "日期开始": None,
                "日期结束": None,
                "状态": "通过",
                "说明": "USER_DAY记录数",
            },
            {
                "检查项": "六类场景覆盖用户日",
                "值": total_any_scene_days,
                "日期开始": None,
                "日期结束": None,
                "状态": "通过",
                "说明": f"占DAU {divide(total_any_scene_days, total_dau):.2%}",
            },
            {
                "检查项": "未分类功能进入用户日（可重叠）",
                "值": int(unknown_enter_days),
                "日期开始": None,
                "日期结束": None,
                "状态": "关注" if unknown_enter_days else "通过",
                "说明": "详见未分类功能sheet",
            },
            {
                "检查项": "订阅来源用户日键",
                "值": len(sub_by_user_day),
                "日期开始": None,
                "日期结束": None,
                "状态": "通过",
                "说明": "SUB_SOURCE按日期+用户聚合",
            },
            {
                "检查项": "可匹配功能用户日的订阅来源键",
                "值": second_pass["linked_sub_key_count"],
                "日期开始": None,
                "日期结束": None,
                "状态": "通过",
                "说明": (
                    f"匹配率 "
                    f"{divide(second_pass['linked_sub_key_count'], len(sub_by_user_day)):.2%}"
                ),
            },
            {
                "检查项": "有实际支付事件用户",
                "值": len(pay_by_gid),
                "日期开始": None,
                "日期结束": None,
                "状态": "通过",
                "说明": "PAY_EVENT用户数",
            },
            {
                "检查项": "无法解析function_detail记录",
                "值": second_pass["malformed_detail_rows"],
                "日期开始": None,
                "日期结束": None,
                "状态": (
                    "通过"
                    if second_pass["malformed_detail_rows"] == 0
                    else "关注"
                ),
                "说明": "",
            },
        ]
    )
    qc_df = pd.DataFrame(qc_rows)

    return {
        "scene_core": core_df,
        "scene_segment": segment_df,
        "daily_scene": daily_df,
        "scene_function": function_df,
        "scene_pair": pair_df,
        "scene_combo": scene_combo_df,
        "within_scene_combo": within_combo_df,
        "count_distribution": count_dist_df,
        "subscription_source": source_df,
        "unknown_function": unknown_df,
        "quality_check": qc_df,
    }


def save_tables(tables: dict[str, pd.DataFrame]) -> None:
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)
    filenames = {
        "scene_core": "01_场景核心指标.csv",
        "scene_segment": "02_场景分层指标.csv",
        "daily_scene": "03_场景日趋势.csv",
        "scene_function": "04_场景功能表现.csv",
        "scene_pair": "05_场景关联矩阵明细.csv",
        "scene_combo": "06_多场景组合.csv",
        "within_scene_combo": "07_单场景功能组合.csv",
        "count_distribution": "08_功能及场景数分布.csv",
        "subscription_source": "09_订阅来源功能.csv",
        "unknown_function": "10_未分类功能.csv",
        "quality_check": "11_数据质检.csv",
    }
    for key, filename in filenames.items():
        tables[key].to_csv(
            ANALYSIS_DIR / filename,
            index=False,
            encoding="utf-8-sig",
        )

    mapping_rows = []
    for key, scene in sorted(FEATURE_TO_SCENE.items(), key=lambda x: (x[1], x[0])):
        mapping_rows.append(
            {
                "场景": scene,
                "功能标准化键": key,
                "展示名": display_feature(key),
                "场景定义": SCENE_DEFINITION[scene],
            }
        )
    pd.DataFrame(mapping_rows).to_csv(
        ANALYSIS_DIR / "00_场景功能映射.csv",
        index=False,
        encoding="utf-8-sig",
    )


def configure_plot() -> None:
    font_candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    ]
    for path in font_candidates:
        if Path(path).exists():
            fm.fontManager.addfont(path)
            prop = fm.FontProperties(fname=path)
            plt.rcParams["font.family"] = prop.get_name()
            break
    plt.rcParams["axes.unicode_minus"] = False
    plt.rcParams["figure.facecolor"] = COLORS["panel"]
    plt.rcParams["axes.facecolor"] = "white"
    plt.rcParams["text.color"] = COLORS["ink"]
    plt.rcParams["axes.labelcolor"] = COLORS["ink"]
    plt.rcParams["xtick.color"] = COLORS["muted"]
    plt.rcParams["ytick.color"] = COLORS["muted"]


def format_percent(value: float) -> str:
    if pd.isna(value):
        return "—"
    return f"{value:.1%}"


def render_core_table(core: pd.DataFrame) -> Path:
    columns = [
        ("场景用户日渗透率", "渗透率"),
        ("进入打勾率", "进入打勾率"),
        ("进入保存率", "进入保存率"),
        ("D1留存率", "D1留存率"),
        ("D7留存率", "D7留存率"),
        ("场景订阅页曝光率", "订阅页曝光率"),
        ("曝光订阅成功率", "曝光订阅成功率"),
    ]
    fig = plt.figure(figsize=(16, 7.8), dpi=180)
    ax = fig.add_axes([0.03, 0.08, 0.94, 0.75])
    ax.set_xlim(0, 1)
    ax.set_ylim(0, len(core) + 1.25)
    ax.axis("off")

    fig.text(
        0.035,
        0.93,
        "巴西用户日场景核心表现",
        fontsize=23,
        fontweight="bold",
        color=COLORS["ink"],
    )
    fig.text(
        0.035,
        0.875,
        "2026年7月1–30日｜分母为巴西DAU用户日；留存按场景使用日观察后续活跃",
        fontsize=11,
        color=COLORS["muted"],
    )

    left_width = 0.19
    cell_width = (1 - left_width) / len(columns)
    header_y = len(core) + 0.55
    ax.add_patch(
        FancyBboxPatch(
            (0, header_y - 0.45),
            1,
            0.8,
            boxstyle="round,pad=0.012,rounding_size=0.018",
            facecolor="#F1F4F8",
            edgecolor="none",
        )
    )
    ax.text(
        0.018,
        header_y,
        "场景",
        va="center",
        fontsize=11,
        fontweight="bold",
    )
    for idx, (_, label) in enumerate(columns):
        ax.text(
            left_width + idx * cell_width + cell_width / 2,
            header_y,
            label,
            ha="center",
            va="center",
            fontsize=10.5,
            fontweight="bold",
        )

    blue_cmap = LinearSegmentedColormap.from_list(
        "blue_scale", ["#EEF3FF", "#BFD0FF", COLORS["blue"]]
    )
    for row_idx, row in core.reset_index(drop=True).iterrows():
        y = len(core) - row_idx - 0.05
        if row_idx % 2 == 1:
            ax.add_patch(
                Rectangle(
                    (0, y - 0.42),
                    1,
                    0.84,
                    facecolor="#FBFCFE",
                    edgecolor="none",
                )
            )
        ax.text(
            0.018,
            y + 0.07,
            row["场景"],
            va="center",
            fontsize=11.5,
            fontweight="bold",
        )
        ax.text(
            0.018,
            y - 0.2,
            f"{int(row['场景使用用户日']):,} 用户日",
            va="center",
            fontsize=8.5,
            color=COLORS["muted"],
        )
        for col_idx, (metric, _) in enumerate(columns):
            value = row[metric]
            x0 = left_width + col_idx * cell_width + 0.014
            width = cell_width - 0.028
            bar_y = y - 0.13
            ax.add_patch(
                FancyBboxPatch(
                    (x0, bar_y),
                    width,
                    0.14,
                    boxstyle="round,pad=0,rounding_size=0.035",
                    facecolor="#E8EDF4",
                    edgecolor="none",
                )
            )
            scaled = 0 if pd.isna(value) else min(max(float(value), 0), 1)
            ax.add_patch(
                FancyBboxPatch(
                    (x0, bar_y),
                    width * scaled,
                    0.14,
                    boxstyle="round,pad=0,rounding_size=0.035",
                    facecolor=blue_cmap(0.35 + 0.6 * scaled),
                    edgecolor="none",
                )
            )
            ax.text(
                x0 + width / 2,
                y + 0.14,
                format_percent(value),
                ha="center",
                va="center",
                fontsize=10.5,
                fontweight="bold",
            )
        ax.plot([0, 1], [y - 0.48, y - 0.48], color=COLORS["grid"], lw=0.7)

    fig.text(
        0.035,
        0.025,
        "注：订阅指标来自 SUB_SOURCE 直接来源归因；实际支付关联另见明细表，二者不相加。",
        fontsize=8.5,
        color=COLORS["muted"],
    )
    path = ANALYSIS_DIR / "巴西场景核心指标_202607.png"
    fig.savefig(path, bbox_inches="tight", facecolor=COLORS["panel"])
    plt.close(fig)
    return path


def render_segment_heatmap(segment: pd.DataFrame) -> Path:
    desired = [
        ("新老", "New"),
        ("新老", "Old"),
        ("新用户来源", "自然新用户"),
        ("新用户来源", "渠道新用户"),
        ("付费状态", "Paying"),
        ("付费状态", "Un-Paying"),
        ("平台", "iOS"),
        ("平台", "Android"),
    ]
    labels = ["新用户", "老用户", "自然新用户", "渠道新用户", "付费", "非付费", "iOS", "Android"]
    matrix = np.full((len(SCENES), len(desired)), np.nan)
    for col_idx, (dimension, value) in enumerate(desired):
        selected = segment.loc[
            (segment["维度"] == dimension) & (segment["分层"] == value)
        ]
        by_scene = selected.set_index("场景")["场景用户日渗透率"].to_dict()
        for row_idx, scene in enumerate(SCENES):
            matrix[row_idx, col_idx] = by_scene.get(scene, np.nan)

    fig, ax = plt.subplots(figsize=(15, 7.6), dpi=180)
    cmap = LinearSegmentedColormap.from_list(
        "blue_heat", ["#F5F8FF", "#C8D7FF", "#7899FA", "#315ED6"]
    )
    image = ax.imshow(matrix, cmap=cmap, aspect="auto", vmin=0, vmax=np.nanmax(matrix))
    ax.set_xticks(range(len(labels)), labels=labels, fontsize=10)
    ax.set_yticks(range(len(SCENES)), labels=SCENES, fontsize=11)
    ax.tick_params(length=0)
    for row_idx in range(matrix.shape[0]):
        for col_idx in range(matrix.shape[1]):
            value = matrix[row_idx, col_idx]
            if pd.isna(value):
                label = "—"
                color = COLORS["muted"]
            else:
                label = f"{value:.1%}"
                color = "white" if value > np.nanmax(matrix) * 0.58 else COLORS["ink"]
            ax.text(
                col_idx,
                row_idx,
                label,
                ha="center",
                va="center",
                fontsize=10,
                fontweight="bold",
                color=color,
            )
    ax.set_title(
        "巴西场景渗透率｜用户分层",
        loc="left",
        fontsize=21,
        fontweight="bold",
        pad=38,
    )
    ax.text(
        0,
        1.045,
        "2026年7月1–30日｜每列分母为对应分层DAU用户日",
        transform=ax.transAxes,
        fontsize=10.5,
        color=COLORS["muted"],
    )
    for spine in ax.spines.values():
        spine.set_visible(False)
    cbar = fig.colorbar(image, ax=ax, fraction=0.018, pad=0.025)
    cbar.ax.yaxis.set_major_formatter(
        matplotlib.ticker.FuncFormatter(lambda x, pos: f"{x:.0%}")
    )
    cbar.outline.set_visible(False)
    fig.tight_layout(rect=[0.02, 0.02, 0.98, 0.93])
    path = ANALYSIS_DIR / "巴西场景分层渗透率_202607.png"
    fig.savefig(path, bbox_inches="tight", facecolor=COLORS["panel"])
    plt.close(fig)
    return path


def render_lift_matrix(pair: pd.DataFrame) -> Path:
    matrix = np.full((len(SCENES), len(SCENES)), np.nan)
    for row in pair.itertuples(index=False):
        x_idx = SCENES.index(row.X场景)
        y_idx = SCENES.index(row.Y场景)
        matrix[x_idx, y_idx] = row.Lift
    for idx in range(len(SCENES)):
        matrix[idx, idx] = 1.0
    finite = matrix[np.isfinite(matrix)]
    vmax = max(1.5, np.nanpercentile(finite, 92))
    norm = TwoSlopeNorm(vmin=0, vcenter=1, vmax=vmax)
    cmap = LinearSegmentedColormap.from_list(
        "lift",
        ["#E7EEF9", "#FFFFFF", "#FFB37E", "#EA6D2F"],
    )
    fig, ax = plt.subplots(figsize=(10.8, 9.2), dpi=180)
    image = ax.imshow(matrix, cmap=cmap, norm=norm)
    ax.set_xticks(range(len(SCENES)), labels=SCENES, rotation=28, ha="right")
    ax.set_yticks(range(len(SCENES)), labels=SCENES)
    ax.tick_params(length=0, labelsize=10.5)
    for i in range(len(SCENES)):
        for j in range(len(SCENES)):
            value = matrix[i, j]
            ax.text(
                j,
                i,
                f"{value:.2f}×" if np.isfinite(value) else "—",
                ha="center",
                va="center",
                fontsize=10,
                fontweight="bold",
                color=COLORS["ink"],
            )
    ax.set_title(
        "巴西场景共用 Lift 矩阵",
        loc="left",
        fontsize=21,
        fontweight="bold",
        pad=42,
    )
    ax.text(
        0,
        1.05,
        "同一用户同一天｜行=X、列=Y；Lift>1 表示使用X时更倾向同时使用Y",
        transform=ax.transAxes,
        fontsize=10.5,
        color=COLORS["muted"],
    )
    for spine in ax.spines.values():
        spine.set_visible(False)
    cbar = fig.colorbar(image, ax=ax, fraction=0.036, pad=0.04)
    cbar.set_label("Lift", color=COLORS["muted"])
    cbar.outline.set_visible(False)
    fig.tight_layout(rect=[0.02, 0.02, 0.98, 0.92])
    path = ANALYSIS_DIR / "巴西场景关联Lift矩阵_202607.png"
    fig.savefig(path, bbox_inches="tight", facecolor=COLORS["panel"])
    plt.close(fig)
    return path


def render_top_combos(combo: pd.DataFrame) -> Path:
    data = combo.head(12).sort_values("占DAU", ascending=True)
    fig, ax = plt.subplots(figsize=(13.5, 8.2), dpi=180)
    bars = ax.barh(
        data["场景组合"],
        data["占DAU"],
        color=COLORS["blue"],
        edgecolor="#2856CC",
        linewidth=0.8,
    )
    ax.set_xlim(0, max(data["占DAU"].max() * 1.22, 0.01))
    ax.xaxis.set_major_formatter(
        matplotlib.ticker.FuncFormatter(lambda x, pos: f"{x:.0%}")
    )
    ax.grid(axis="x", color=COLORS["grid"], lw=0.8)
    ax.set_axisbelow(True)
    for bar, value, user_days in zip(bars, data["占DAU"], data["用户日"]):
        ax.text(
            bar.get_width() + ax.get_xlim()[1] * 0.012,
            bar.get_y() + bar.get_height() / 2,
            f"{value:.2%}｜{int(user_days):,}",
            va="center",
            fontsize=9.5,
            color=COLORS["ink"],
            fontweight="bold",
        )
    ax.set_title(
        "巴西多场景使用组合 Top 12",
        loc="left",
        fontsize=21,
        fontweight="bold",
        pad=38,
    )
    ax.text(
        0,
        1.035,
        "2026年7月1–30日｜同一用户同一天；占比的分母为DAU用户日",
        transform=ax.transAxes,
        fontsize=10.5,
        color=COLORS["muted"],
    )
    ax.set_xlabel("占DAU用户日")
    ax.set_ylabel("")
    ax.spines[["top", "right", "left"]].set_visible(False)
    ax.tick_params(axis="y", length=0, labelsize=10)
    fig.tight_layout(rect=[0.02, 0.02, 0.98, 0.93])
    path = ANALYSIS_DIR / "巴西多场景组合Top12_202607.png"
    fig.savefig(path, bbox_inches="tight", facecolor=COLORS["panel"])
    plt.close(fig)
    return path


def render_subscription_table(core: pd.DataFrame) -> Path:
    data = core.copy()
    gross_total = data["订阅毛利"].sum()
    data["毛利占比"] = data["订阅毛利"] / gross_total if gross_total else np.nan
    data = data.sort_values("订阅毛利", ascending=False).reset_index(drop=True)
    fig = plt.figure(figsize=(15.2, 7.6), dpi=180)
    ax = fig.add_axes([0.04, 0.09, 0.92, 0.72])
    ax.axis("off")
    fig.text(
        0.04,
        0.92,
        "巴西场景订阅链路与毛利",
        fontsize=22,
        fontweight="bold",
        color=COLORS["ink"],
    )
    fig.text(
        0.04,
        0.865,
        "2026年7月1–30日｜SUB_SOURCE直接来源归因；毛利为分成后美元",
        fontsize=10.5,
        color=COLORS["muted"],
    )
    headers = [
        "场景",
        "订阅页曝光用户日",
        "场景订阅页曝光率",
        "曝光订阅成功率",
        "订阅成功付费率",
        "订阅毛利（占比）",
    ]
    values = []
    for row in data.itertuples(index=False):
        values.append(
            [
                row.场景,
                f"{int(row.订阅页曝光用户日):,}",
                format_percent(row.场景订阅页曝光率),
                format_percent(row.曝光订阅成功率),
                format_percent(row.订阅成功付费率),
                f"${row.订阅毛利:,.0f}（{row.毛利占比:.1%}）",
            ]
        )
    table = ax.table(
        cellText=values,
        colLabels=headers,
        cellLoc="center",
        colLoc="center",
        loc="center",
        bbox=[0, 0, 1, 1],
    )
    table.auto_set_font_size(False)
    table.set_fontsize(10.5)
    for (row_idx, col_idx), cell in table.get_celld().items():
        cell.set_edgecolor(COLORS["grid"])
        cell.set_linewidth(0.6)
        if row_idx == 0:
            cell.set_facecolor("#EEF2F7")
            cell.set_text_props(weight="bold", color=COLORS["ink"])
        else:
            cell.set_facecolor("white" if row_idx % 2 else "#FAFBFD")
            if col_idx == 0:
                cell.set_text_props(weight="bold", ha="left")
    widths = [0.18, 0.18, 0.17, 0.17, 0.16, 0.2]
    for col_idx, width in enumerate(widths):
        for row_idx in range(len(values) + 1):
            table[(row_idx, col_idx)].set_width(width)
    path = ANALYSIS_DIR / "巴西场景订阅链路_202607.png"
    fig.savefig(path, bbox_inches="tight", facecolor=COLORS["panel"])
    plt.close(fig)
    return path


def render_all(tables: dict[str, pd.DataFrame]) -> list[Path]:
    configure_plot()
    return [
        render_core_table(tables["scene_core"]),
        render_segment_heatmap(tables["scene_segment"]),
        render_lift_matrix(tables["scene_pair"]),
        render_top_combos(tables["scene_combo"]),
        render_subscription_table(tables["scene_core"]),
    ]


def load_saved_tables() -> dict[str, pd.DataFrame]:
    filenames = {
        "scene_core": "01_场景核心指标.csv",
        "scene_segment": "02_场景分层指标.csv",
        "daily_scene": "03_场景日趋势.csv",
        "scene_function": "04_场景功能表现.csv",
        "scene_pair": "05_场景关联矩阵明细.csv",
        "scene_combo": "06_多场景组合.csv",
        "within_scene_combo": "07_单场景功能组合.csv",
        "count_distribution": "08_功能及场景数分布.csv",
        "subscription_source": "09_订阅来源功能.csv",
        "unknown_function": "10_未分类功能.csv",
        "quality_check": "11_数据质检.csv",
    }
    return {
        key: pd.read_csv(ANALYSIS_DIR / filename, encoding="utf-8-sig")
        for key, filename in filenames.items()
    }


def qc_record_metadata(
    qc: pd.DataFrame,
) -> tuple[Counter, dict[str, tuple[int, int]]]:
    counts = Counter()
    ranges: dict[str, tuple[int, int]] = {}
    for row in qc.itertuples(index=False):
        label = str(row.检查项)
        if not label.endswith("记录"):
            continue
        record_type = label[: -len("记录")]
        counts[record_type] = safe_int(row.值)
        low = safe_int(row.日期开始)
        high = safe_int(row.日期结束)
        if low and high:
            ranges[record_type] = (low, high)
    return counts, ranges


def write_manifest(
    tables: dict[str, pd.DataFrame],
    image_paths: list[Path],
    record_counts: Counter,
    date_ranges: dict[str, tuple[int, int]],
) -> None:
    core = tables["scene_core"].copy()
    summary = {
        "data_source": str(RAW_CSV),
        "sql_source": str(BASE_DIR / "巴西用户日场景分析一次性宽取数_202607.sql"),
        "date_scope": "2026-07-01 to 2026-07-30",
        "record_counts": dict(record_counts),
        "date_ranges": {key: list(value) for key, value in date_ranges.items()},
        "core_metrics": core.to_dict(orient="records"),
        "images": [str(path) for path in image_paths],
        "metric_notes": {
            "penetration": "场景使用用户日 / DAU用户日",
            "retention": "场景使用用户日中，次日/第7日仍活跃的比例；D1截至7月29日，D7截至7月23日",
            "sub_source": "订阅页与毛利按SUB_SOURCE直接来源归因",
            "actual_pay": "PAY_EVENT用于场景使用后D0/D7实际首购/续费关联，不与SUB_SOURCE毛利相加",
            "association": "同一用户同一天，无先后顺序；为相关性而非因果",
        },
    }
    (ANALYSIS_DIR / "analysis_manifest.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2, default=str),
        encoding="utf-8",
    )


def main() -> None:
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)
    if "--render-only" in sys.argv:
        tables = load_saved_tables()
        image_paths = render_all(tables)
        record_counts, date_ranges = qc_record_metadata(tables["quality_check"])
        write_manifest(tables, image_paths, record_counts, date_ranges)
        print(
            json.dumps(
                {
                    "mode": "render-only",
                    "analysis_dir": str(ANALYSIS_DIR),
                    "images": [str(path) for path in image_paths],
                },
                ensure_ascii=False,
                indent=2,
            ),
            flush=True,
        )
        return
    if not RAW_CSV.exists():
        raise FileNotFoundError(RAW_CSV)
    header = get_header_columns(RAW_CSV)
    print(f"columns={len(header)}", flush=True)
    first_pass = first_pass_events_and_denominators(header)
    print(
        "first pass complete",
        {
            "record_counts": dict(first_pass[4]),
            "sub_user_days": len(first_pass[0]),
            "pay_users": len(first_pass[1]),
            "dau_user_days": first_pass[2][("整体", "整体")],
        },
        flush=True,
    )
    second_pass = second_pass_user_days(header, first_pass[0], first_pass[1])
    print(
        "second pass complete",
        {
            "function_active_user_days": second_pass["function_active_user_days"],
            "mapped_user_days": second_pass["mapped_user_days"],
            "linked_sub_keys": second_pass["linked_sub_key_count"],
        },
        flush=True,
    )
    tables = build_output_tables(first_pass, second_pass)
    save_tables(tables)
    image_paths = render_all(tables)
    write_manifest(tables, image_paths, first_pass[4], first_pass[5])
    print(
        json.dumps(
            {
                "analysis_dir": str(ANALYSIS_DIR),
                "tables": {key: len(value) for key, value in tables.items()},
                "images": [str(path) for path in image_paths],
            },
            ensure_ascii=False,
            indent=2,
        ),
        flush=True,
    )


if __name__ == "__main__":
    main()

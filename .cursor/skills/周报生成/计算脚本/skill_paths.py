"""周报生成 skill 统一路径（SKILL_ROOT = 含 memory/、计算脚本/ 的目录）。"""
from __future__ import annotations

import os
import re
from pathlib import Path

import pandas as pd


def skill_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    if not (root / "memory").is_dir() or not (root / "计算脚本").is_dir():
        raise RuntimeError(f"未找到 skill 根目录: {root}")
    return root


def kb_skill_root() -> Path:
    """共用知识库 skill（与月报生成同路径）。"""
    root = skill_root().parent / "知识库"
    if not (root / "wiki").is_dir():
        raise RuntimeError(f"未找到知识库 skill: {root}")
    return root


def workspace_root() -> Path:
    """项目根目录（含 app/）。skill 在 .cursor/skills/周报生成/。"""
    return skill_root().parent.parent.parent


def default_deliverable_dir(period: str) -> Path:
    """默认可交付目录：app/AB-OCI/专项/AI周报月报/AI周报/{周期}/"""
    return workspace_root() / "app" / "AB-OCI" / "专项" / "AI周报月报" / "AI周报" / period


def output_dir() -> Path:
    custom = os.environ.get("ZHOUBAO_OUTPUT_DIR", "").strip()
    if custom:
        return Path(custom)
    return skill_root() / "output" / "_staging"


def raw_data_dir() -> Path:
    return skill_root() / "raw_data"


def memory_dir() -> Path:
    return skill_root() / "memory"


def wiki_dir() -> Path:
    return kb_skill_root() / "wiki"


def target_week_start() -> pd.Timestamp | None:
    """环境变量 ZHOUBAO_TARGET_WEEK：YYYY-MM-DD 或 MMDD（默认当年）。"""
    raw = os.environ.get("ZHOUBAO_TARGET_WEEK", "").strip()
    if not raw:
        return None
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw):
        return pd.Timestamp(raw).normalize()
    if re.fullmatch(r"\d{4}", raw):
        mm, dd = int(raw[:2]), int(raw[2:])
        return pd.Timestamp(2026, mm, dd).normalize()
    raise ValueError(f"无效的 ZHOUBAO_TARGET_WEEK: {raw}")


def ensure_output_subdirs() -> Path:
    out = output_dir()
    for sub in ("下钻", "贡献度", "下钻报告"):
        (out / sub).mkdir(parents=True, exist_ok=True)
    return out

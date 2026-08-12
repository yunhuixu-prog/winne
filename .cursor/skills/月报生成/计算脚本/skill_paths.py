"""AI 月报 skill 统一路径。"""
from __future__ import annotations

import os
from pathlib import Path

# 北斗取数窗口 & 下钻月序列长度（含分析月共 N 个完整自然月）
FETCH_MONTHS = 14


def skill_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    if not (root / "memory").is_dir() or not (root / "计算脚本").is_dir():
        raise RuntimeError(f"未找到 skill 根目录: {root}")
    return root


def kb_skill_root() -> Path:
    """共用知识库 skill（与周报生成同路径）。"""
    root = skill_root().parent / "知识库"
    if not (root / "wiki").is_dir():
        raise RuntimeError(f"未找到知识库 skill: {root}")
    return root


def wiki_dir() -> Path:
    return kb_skill_root() / "wiki"


def output_dir() -> Path:
    custom = os.environ.get("AI_MONTHLY_OUTPUT_DIR", "").strip()
    if custom:
        return Path(custom)
    return skill_root() / "output" / "_staging"


def raw_data_dir() -> Path:
    return skill_root() / "raw_data"


def memory_dir() -> Path:
    return skill_root() / "memory"


def ensure_output_subdirs() -> Path:
    out = output_dir()
    for sub in ("下钻", "贡献度", "下钻报告", "业务举措"):
        (out / sub).mkdir(parents=True, exist_ok=True)
    return out

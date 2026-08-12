"""知识库 skill 统一路径（KB_SKILL_ROOT = 含 raw_data/、wiki/、计算脚本/ 的目录）。"""
from __future__ import annotations

from pathlib import Path


def skill_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    if not (root / "raw_data").is_dir() or not (root / "wiki").is_dir():
        raise RuntimeError(f"未找到知识库 skill 根目录: {root}")
    return root


def raw_data_dir() -> Path:
    return skill_root() / "raw_data"


def wiki_dir() -> Path:
    return skill_root() / "wiki"


def kb_raw_dir(name: str) -> Path:
    """name: 知识库 | 北斗标注 | 其他"""
    return raw_data_dir() / name


def scripts_dir() -> Path:
    return skill_root() / "计算脚本"

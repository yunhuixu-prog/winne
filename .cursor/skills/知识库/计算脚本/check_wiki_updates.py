#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""检查默认知识库目录是否有未 ingest 的新增/变更文件。

默认目录（相对 AI 周报项目根）：
  - raw_data/知识库/
  - raw_data/北斗标注/

对照 wiki/sources/_ingest_manifest.json；无 manifest 时以当前目录快照为基线并提示。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from skill_paths import kb_raw_dir, skill_root, wiki_dir

BASE_DIR = skill_root()
DEFAULT_KB_DIRS = [
    kb_raw_dir("知识库"),
    kb_raw_dir("北斗标注"),
]
MANIFEST_PATH = wiki_dir() / "sources" / "_ingest_manifest.json"
SKIP_NAMES = {"structure.md"}


def file_fingerprint(path: Path) -> dict[str, int | str]:
    stat = path.stat()
    return {"mtime": int(stat.st_mtime), "size": stat.st_size}


def collect_files(dirs: list[Path]) -> dict[str, dict[str, int | str]]:
    out: dict[str, dict[str, int | str]] = {}
    for root in dirs:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*")):
            if not path.is_file():
                continue
            if path.name in SKIP_NAMES:
                continue
            rel = path.relative_to(BASE_DIR).as_posix()
            out[rel] = file_fingerprint(path)
    return out


def load_manifest() -> dict[str, dict[str, int | str]]:
    if not MANIFEST_PATH.exists():
        return {}
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8")).get("files", {})


def save_manifest(files: dict[str, dict[str, int | str]]) -> None:
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "default_kb_dirs": [
            "raw_data/知识库",
            "raw_data/北斗标注",
        ],
        "files": dict(sorted(files.items())),
    }
    MANIFEST_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def diff(
    current: dict[str, dict[str, int | str]],
    recorded: dict[str, dict[str, int | str]],
) -> tuple[list[str], list[str], list[str]]:
    new_files = sorted(set(current) - set(recorded))
    changed = sorted(
        p for p in set(current) & set(recorded) if current[p] != recorded[p]
    )
    removed = sorted(set(recorded) - set(current))
    return new_files, changed, removed


def main() -> int:
    parser = argparse.ArgumentParser(description="检查知识库默认目录是否有待 ingest 更新")
    parser.add_argument(
        "--write-baseline",
        action="store_true",
        help="将当前文件快照写入 _ingest_manifest.json（首次基线或 ingest 完成后）",
    )
    args = parser.parse_args()

    current = collect_files(DEFAULT_KB_DIRS)
    recorded = load_manifest()

    if args.write_baseline:
        save_manifest(current)
        print(f"已写入基线 manifest: {MANIFEST_PATH} ({len(current)} 个文件)")
        return 0

    if not recorded:
        print("未找到 wiki/sources/_ingest_manifest.json，当前目录文件视为待处理：")
        for p in sorted(current):
            print(f"  [new] {p}")
        print(f"\n共 {len(current)} 个文件。ingest 完成后运行: python check_wiki_updates.py --write-baseline")
        return 1

    new_files, changed, removed = diff(current, recorded)
    pending = new_files + changed

    if not pending and not removed:
        print("默认知识库目录无新增或变更，wiki 与 raw 快照一致。")
        return 0

    if new_files:
        print("新增文件：")
        for p in new_files:
            print(f"  [new] {p}")
    if changed:
        print("变更文件：")
        for p in changed:
            print(f"  [changed] {p}")
    if removed:
        print("已删除（manifest 中仍有记录，可选清理 wiki 引用）：")
        for p in removed:
            print(f"  [removed] {p}")

    print(f"\n待 ingest: {len(pending)} 个文件")
    print("目录: raw_data/知识库/, raw_data/北斗标注/")
    return 1 if pending else 0


if __name__ == "__main__":
    sys.exit(main())

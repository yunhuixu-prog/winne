#!/usr/bin/env python3
"""Trigger a Cursor Cloud Agent for AirBrush weekly report automations.

Uses Cloud Agents API: POST https://api.cursor.com/v1/agents
Auth: Basic (CURSOR_API_KEY as username, empty password) or Bearer.

Usage:
  export CURSOR_API_KEY=...
  export OMNIBUS_ACCESS_TOKEN=...   # injected into cloud agent env
  python3 trigger_cloud_agent.py --task monday
  python3 trigger_cloud_agent.py --task tuesday
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API_URL = "https://api.cursor.com/v1/agents"
DEFAULT_REPO = "https://github.com/yunhuixu-prog/winne"
DEFAULT_REF = "main"

TASK_META = {
    "monday": {
        "name": "AirBrush 周一-知识库+周报初版",
        "prompt_file": "monday-kb-and-weekly.md",
        "extra": (
            "你是 AirBrush 数据周报 Agent。严格按项目内 Skill 执行，不要跳过步骤。\n"
            "完成后：将本周产物提交到仓库（优先开 PR），并在回复中给出 agent URL、周期标签、输出目录、产物清单。\n"
            "环境变量 OMNIBUS_ACCESS_TOKEN 已注入，用于知识库 / 北斗拉取。\n\n"
            "—— 详细步骤 ——\n"
        ),
    },
    "tuesday": {
        "name": "AirBrush 周二-周报刷新(含周日次留)",
        "prompt_file": "tuesday-weekly-refresh.md",
        "extra": (
            "你是 AirBrush 数据周报 Agent。本任务为「周二刷新」：补全上周日次留后覆盖周一版周报。\n"
            "不要跑知识库全量更新（除非 marks/CF 有紧急变更）。\n"
            "完成后：提交覆盖后的产物（优先开 PR），汇报周期、相对周一版的 diff 摘要、最终 v3 路径。\n"
            "环境变量 OMNIBUS_ACCESS_TOKEN 已注入，用于北斗取数。\n\n"
            "—— 详细步骤 ——\n"
        ),
    },
}


def _prompts_dir() -> Path:
    return Path(__file__).resolve().parents[1] / "prompts"


def _load_prompt(task: str) -> tuple[str, str]:
    meta = TASK_META[task]
    path = _prompts_dir() / meta["prompt_file"]
    if not path.is_file():
        raise FileNotFoundError(f"prompt file not found: {path}")
    body = path.read_text(encoding="utf-8")
    text = meta["extra"] + body
    return meta["name"], text


def _auth_header(api_key: str) -> str:
    token = base64.b64encode(f"{api_key}:".encode("utf-8")).decode("ascii")
    return f"Basic {token}"


def trigger(
    *,
    task: str,
    api_key: str,
    repo_url: str,
    starting_ref: str,
    omnibus_token: str | None,
    auto_create_pr: bool,
    work_on_current_branch: bool,
) -> dict:
    name, prompt_text = _load_prompt(task)
    payload: dict = {
        "name": name,
        "prompt": {"text": prompt_text},
        "repos": [
            {
                "url": repo_url,
                "startingRef": starting_ref,
            }
        ],
        "autoCreatePR": auto_create_pr,
        "skipReviewerRequest": True,
        "workOnCurrentBranch": work_on_current_branch,
    }
    if omnibus_token:
        payload["envVars"] = {"OMNIBUS_ACCESS_TOKEN": omnibus_token}

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=data,
        method="POST",
        headers={
            "Authorization": _auth_header(api_key),
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"API HTTP {e.code}: {body}") from e


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task", choices=sorted(TASK_META), required=True)
    parser.add_argument("--repo", default=os.environ.get("CURSOR_REPO_URL", DEFAULT_REPO))
    parser.add_argument(
        "--ref",
        default=os.environ.get("CURSOR_STARTING_REF", DEFAULT_REF),
        help="starting branch/ref (default: main)",
    )
    parser.add_argument(
        "--push-main",
        action="store_true",
        help="push directly to startingRef instead of opening a PR",
    )
    args = parser.parse_args()

    api_key = os.environ.get("CURSOR_API_KEY", "").strip()
    if not api_key:
        print("CURSOR_API_KEY is required", file=sys.stderr)
        return 1

    omnibus = os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip() or None
    if not omnibus:
        print(
            "WARNING: OMNIBUS_ACCESS_TOKEN unset; cloud agent may fail Beidou/CF fetch",
            file=sys.stderr,
        )

    auto_pr = not args.push_main
    work_current = bool(args.push_main)

    result = trigger(
        task=args.task,
        api_key=api_key,
        repo_url=args.repo,
        starting_ref=args.ref,
        omnibus_token=omnibus,
        auto_create_pr=auto_pr,
        work_on_current_branch=work_current,
    )

    agent = result.get("agent") or {}
    run = result.get("run") or {}
    print(
        json.dumps(
            {
                "agent_id": agent.get("id"),
                "agent_url": agent.get("url"),
                "agent_name": agent.get("name"),
                "run_id": run.get("id"),
                "run_status": run.get("status"),
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    if agent.get("url"):
        print(f"\nOpen: {agent['url']}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

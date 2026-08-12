#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""更新事件埋点：按 CF 版本增量拉大禹需求，并合并「事件清单（手动版）.csv」。"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import tempfile
import time
from datetime import date
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

try:
    from packaging.version import InvalidVersion, Version
except ImportError:
    print("需要 packaging：pip install packaging", file=sys.stderr)
    sys.exit(1)

EVENTS_DIR = Path(__file__).resolve().parents[1] / "raw_data" / "埋点事件"
STATE_PATH = EVENTS_DIR / "update_state.json"
MANUAL_CSV = EVENTS_DIR / "事件清单（手动版）.csv"
DAYU_DIR = EVENTS_DIR / "dayu_gt722"
DETAIL_CSV = EVENTS_DIR / "dayu_gt722_事件参数值清单.csv"
EVENT_CSV = EVENTS_DIR / "dayu_gt722_事件清单.csv"
LOOKUP_CSV = EVENTS_DIR / "事件知识_检索.csv"
INDEX_CSV = DAYU_DIR / "需求索引.csv"


def _norm_ver(raw: str) -> Optional[str]:
    raw = (raw or "").strip()
    m = re.search(r"(\d+\.\d+(?:\.\d+)?)", raw)
    if not m:
        return None
    v = m.group(1)
    if v.count(".") == 1:
        v = f"{v}.0"
    try:
        Version(v)
    except InvalidVersion:
        return None
    return v


def load_state() -> Dict[str, Any]:
    if not STATE_PATH.exists():
        raise FileNotFoundError(f"缺少 {STATE_PATH}")
    return json.loads(STATE_PATH.read_text(encoding="utf-8"))


def save_state(state: Dict[str, Any]) -> None:
    STATE_PATH.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def cf_versions_after(cf_dir: Path, after: str) -> List[str]:
    base = Version(after)
    found: Set[str] = set()
    if not cf_dir.is_dir():
        raise FileNotFoundError(f"CF 版本目录不存在: {cf_dir}")
    for p in cf_dir.iterdir():
        v = _norm_ver(p.name)
        if v and Version(v) > base:
            found.add(v)
    return sorted(found, key=Version)


def _dayu_call(params: Dict[str, Any], env: str) -> Dict[str, Any]:
    skill_root = Path(__file__).resolve().parents[2] / "dayu-requirement-query"
    scripts = skill_root / "scripts"
    sys.path.insert(0, str(scripts))
    from dayu_openapi_gateway import (  # type: ignore
        API_ENDPOINTS,
        _ensure_token,
        _resolve_base_url,
    )
    import requests

    token = _ensure_token()
    base = _resolve_base_url(env=env)
    url = f"{base}{API_ENDPOINTS['dayu_query_requirements']}"
    session = requests.Session()
    session.headers.update(
        {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    )
    last_err: Optional[Exception] = None
    for attempt in range(3):
        try:
            resp = session.post(url, json=params, timeout=90)
            if not resp.ok:
                raise RuntimeError(f"HTTP {resp.status_code}: {resp.text[:300]}")
            data = resp.json()
            if isinstance(data, dict) and "response" in data:
                if data.get("code") not in (0, "0"):
                    raise RuntimeError(str(data)[:400])
                return data["response"]
            return data
        except Exception as e:  # noqa: BLE001
            last_err = e
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(last_err)


def fetch_baseline_total(app_id: int, env: str, client_type: str) -> int:
    r = _dayu_call(
        {"queryAppId": app_id, "clientType": client_type, "pageNum": 1, "pageSize": 1},
        env=env,
    )
    return int(r.get("total") or 0)


def fetch_version_reqs(
    app_id: int, env: str, client_type: str, version: str, baseline: int
) -> List[Dict[str, Any]]:
    r = _dayu_call(
        {
            "queryAppId": app_id,
            "clientType": client_type,
            "versions": version,
            "pageNum": 1,
            "pageSize": 100,
        },
        env=env,
    )
    total = int(r.get("total") or 0)
    # 不存在的版本会返回全量
    if total <= 0 or total >= baseline:
        return []
    reqs = list(r.get("requirements") or [])
    page = 2
    while len(reqs) < total and page < 20:
        r2 = _dayu_call(
            {
                "queryAppId": app_id,
                "clientType": client_type,
                "versions": version,
                "pageNum": page,
                "pageSize": 100,
            },
            env=env,
        )
        more = r2.get("requirements") or []
        if not more:
            break
        reqs.extend(more)
        page += 1
    return reqs


def flatten_requirement(
    req: Dict[str, Any], versions: List[str]
) -> Tuple[List[Dict[str, str]], Dict[str, Any]]:
    rid = str(req.get("id") or "")
    rname = req.get("name") or ""
    share = req.get("shareLink") or ""
    rows: List[Dict[str, str]] = []
    events_meta: Dict[str, Any] = {}
    for ev in req.get("events") or []:
        eid = ev.get("event") or ""
        ename = ev.get("eventName") or ""
        einfo = ev.get("info") or ""
        if eid not in events_meta:
            events_meta[eid] = {
                "event_id": eid,
                "event_name": ename,
                "event_desc": einfo,
                "param_keys": set(),
                "requirement_ids": {rid},
                "versions": set(versions),
            }
        else:
            events_meta[eid]["requirement_ids"].add(rid)
            events_meta[eid]["versions"].update(versions)
        for rt in ev.get("requirementTypes") or []:
            for p in rt.get("params") or []:
                pk = p.get("param") or ""
                pn = p.get("paramName") or ""
                pi = p.get("info") or ""
                if pk:
                    events_meta[eid]["param_keys"].add(pk)
                vals = p.get("values") or [None]
                for val in vals:
                    rows.append(
                        {
                            "source": "dayu",
                            "event_id": eid,
                            "event_name": ename,
                            "event_desc": einfo,
                            "param_key": pk,
                            "param_name": pn,
                            "param_desc": pi,
                            "param_value": (val or {}).get("val", "") if val else "",
                            "param_value_name": (val or {}).get("valName", "") if val else "",
                            "param_value_desc": (val or {}).get("info", "") if val else "",
                            "requirement_type": rt.get("requirementTypeName") or "",
                            "requirement_id": rid,
                            "requirement_name": rname,
                            "versions": ",".join(versions),
                            "shareLink": share,
                            "含义": pi or einfo,
                            "备注": "",
                        }
                    )
    return rows, events_meta


def read_csv(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows: List[Dict[str, str]], fieldnames: List[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in fieldnames})


def load_manual_rows() -> List[Dict[str, str]]:
    rows = []
    for r in read_csv(MANUAL_CSV):
        ename = (r.get("事件名") or "").strip()
        key = (r.get("key名") or "").strip()
        if not ename and not key:
            continue
        rows.append(
            {
                "source": "manual",
                "event_id": ename,
                "event_name": ename,
                "event_desc": (r.get("含义") or "").strip(),
                "param_key": key,
                "param_name": key,
                "param_desc": (r.get("含义") or "").strip(),
                "param_value": (r.get("key值") or "").strip(),
                "param_value_name": "",
                "param_value_desc": "",
                "requirement_type": "",
                "requirement_id": "",
                "requirement_name": "",
                "versions": "",
                "shareLink": "",
                "含义": (r.get("含义") or "").strip(),
                "备注": (r.get("备注") or "").strip(),
            }
        )
    return rows


def row_key(r: Dict[str, str]) -> Tuple[str, ...]:
    return (
        r.get("source", ""),
        r.get("requirement_id", ""),
        r.get("event_id", ""),
        r.get("param_key", ""),
        r.get("param_value", ""),
        r.get("含义", ""),
        r.get("备注", ""),
    )


def merge_rows(existing: List[Dict[str, str]], new_rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    seen = {row_key(r) for r in existing}
    out = list(existing)
    for r in new_rows:
        k = row_key(r)
        if k in seen:
            continue
        seen.add(k)
        out.append(r)
    return out


def rebuild_event_summary(detail: List[Dict[str, str]]) -> List[Dict[str, str]]:
    agg: Dict[str, Dict[str, Any]] = {}
    for r in detail:
        if r.get("source") == "manual":
            continue
        eid = r.get("event_id") or ""
        if not eid:
            continue
        a = agg.setdefault(
            eid,
            {
                "event_id": eid,
                "event_name": r.get("event_name") or "",
                "event_desc": r.get("event_desc") or "",
                "param_keys": set(),
                "requirement_ids": set(),
                "versions": set(),
            },
        )
        if r.get("param_key"):
            a["param_keys"].add(r["param_key"])
        if r.get("requirement_id"):
            a["requirement_ids"].add(r["requirement_id"])
        for v in (r.get("versions") or "").split(","):
            v = v.strip()
            if v:
                a["versions"].add(v)
        if r.get("event_name") and not a["event_name"]:
            a["event_name"] = r["event_name"]
        if r.get("event_desc") and not a["event_desc"]:
            a["event_desc"] = r["event_desc"]
    rows = []
    for a in agg.values():
        vers = sorted(a["versions"], key=lambda s: Version(_norm_ver(s) or "0.0.0"))
        rows.append(
            {
                "event_id": a["event_id"],
                "event_name": a["event_name"],
                "event_desc": a["event_desc"],
                "param_count": str(len(a["param_keys"])),
                "param_keys": ",".join(sorted(a["param_keys"])),
                "requirement_count": str(len(a["requirement_ids"])),
                "versions": ",".join(vers),
                "requirement_ids": ",".join(sorted(a["requirement_ids"])),
            }
        )
    return sorted(rows, key=lambda x: x["event_id"])


def export_new_requirements(reqs: List[Dict[str, Any]], out_dir: Path) -> List[Dict[str, Any]]:
    if not reqs:
        return []
    skill_root = Path(__file__).resolve().parents[2] / "dayu-requirement-query"
    scripts = skill_root / "scripts"
    out_dir.mkdir(parents=True, exist_ok=True)
    payload = {"total": len(reqs), "pageNum": 1, "pageSize": len(reqs), "requirements": reqs}
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as tf:
        json.dump(payload, tf, ensure_ascii=False)
        tmp = Path(tf.name)
    try:
        import subprocess

        cmd = [
            sys.executable,
            str(scripts / "dayu_requirement_table_export.py"),
            "--skill-root",
            str(skill_root),
            "--input",
            str(tmp),
            "--output-dir",
            str(out_dir),
            "--mode",
            "expanded",
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True)
        if proc.returncode != 0:
            raise RuntimeError(proc.stderr or proc.stdout)
        return json.loads(proc.stdout).get("exports") or []
    finally:
        tmp.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="更新事件埋点")
    parser.add_argument("--dry-run", action="store_true", help="只打印待拉版本，不请求大禹")
    parser.add_argument(
        "--manual-only",
        action="store_true",
        help="只合并手动版，不拉大禹",
    )
    args = parser.parse_args()

    state = load_state()
    last = state.get("last_synced_version") or "0.0.0"
    app_id = int(state["app_id"])
    env = state.get("env") or "oci"
    client_type = state.get("client_type") or "APP"
    cf_rel = state.get("cf_versions_dir") or "../../../知识库/raw_data/知识库/site_632691935"
    cf_dir = (EVENTS_DIR / cf_rel).resolve()

    pending = cf_versions_after(cf_dir, last)
    print(f"last_synced_version={last}")
    print(f"cf_dir={cf_dir}")
    print(f"pending_versions={pending}")

    if args.dry_run:
        return

    new_detail: List[Dict[str, str]] = []
    new_reqs_by_id: Dict[str, Dict[str, Any]] = {}
    hit_versions: List[Dict[str, Any]] = []
    ver_map: Dict[str, List[str]] = {}

    if not args.manual_only:
        if not pending:
            print("无新版本（CF 中无 > last_synced_version 的目录）")
        else:
            baseline = fetch_baseline_total(app_id, env, client_type)
            print(f"baseline_total={baseline}")
            for v in pending:
                reqs = fetch_version_reqs(app_id, env, client_type, v, baseline)
                if not reqs:
                    print(f"SKIP {v} (invalid or empty)")
                    continue
                hit_versions.append({"version": v, "total": len(reqs)})
                print(f"HIT {v} n={len(reqs)}")
                for req in reqs:
                    rid = str(req.get("id"))
                    ver_map.setdefault(rid, [])
                    if v not in ver_map[rid]:
                        ver_map[rid].append(v)
                    if rid not in new_reqs_by_id:
                        new_reqs_by_id[rid] = req
            for rid, req in new_reqs_by_id.items():
                rows, _ = flatten_requirement(req, ver_map.get(rid, []))
                new_detail.extend(rows)

            exports = export_new_requirements(
                list(new_reqs_by_id.values()), DAYU_DIR / "requirements"
            )
            # 更新需求索引：追加
            idx = read_csv(INDEX_CSV)
            by_id = {r.get("requirement_id"): r for r in idx}
            for e in exports:
                rid = str(e.get("requirementId") or "")
                by_id[rid] = {
                    "requirement_id": rid,
                    "requirement_name": e.get("requirementName") or "",
                    "versions": ",".join(ver_map.get(rid, [])),
                    "shareLink": e.get("shareLink") or "",
                    "xlsx": e.get("xlsx") or "",
                    "markdown": e.get("markdown") or "",
                    "priority": "",
                }
            if by_id:
                write_csv(
                    INDEX_CSV,
                    [by_id[k] for k in sorted(by_id.keys())],
                    ["requirement_id", "requirement_name", "versions", "shareLink", "xlsx", "markdown", "priority"],
                )

            # meta 追加
            meta_path = DAYU_DIR / "meta.json"
            meta = json.loads(meta_path.read_text(encoding="utf-8")) if meta_path.exists() else {}
            old_hits = {h["version"]: h for h in meta.get("hit_versions") or [] if "version" in h}
            for h in hit_versions:
                old_hits[h["version"]] = h
            meta["hit_versions"] = [
                old_hits[v] for v in sorted(old_hits.keys(), key=lambda s: Version(s))
            ]
            meta["last_incremental_at"] = str(date.today())
            meta["last_incremental_versions"] = [h["version"] for h in hit_versions]
            meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

            if hit_versions:
                max_v = max((h["version"] for h in hit_versions), key=Version)
                # 若 CF pending 最大版本未被大禹命中，仍推进到 pending max（避免反复扫无效号）
                pending_max = max(pending, key=Version)
                state["last_synced_version"] = str(
                    max(Version(max_v), Version(pending_max))
                )
                state["last_synced_at"] = str(date.today())
                save_state(state)
                print(f"updated last_synced_version -> {state['last_synced_version']}")
            else:
                # 全部 SKIP：推进到 pending 最大，避免死循环
                pending_max = max(pending, key=Version)
                state["last_synced_version"] = str(pending_max)
                state["last_synced_at"] = str(date.today())
                save_state(state)
                print(f"no dayu hits; advanced watermark -> {pending_max}")

    # 合并 dayu 明细 + 手动版 → 检索表
    existing_detail = read_csv(DETAIL_CSV)
    # 规范化已有行补 source
    for r in existing_detail:
        r.setdefault("source", "dayu")
        r.setdefault("含义", r.get("param_desc") or r.get("event_desc") or "")
        r.setdefault("备注", "")

    detail = merge_rows(existing_detail, new_detail)
    write_csv(
        DETAIL_CSV,
        detail,
        [
            "event_id",
            "event_name",
            "event_desc",
            "param_key",
            "param_name",
            "param_desc",
            "param_value",
            "param_value_name",
            "param_value_desc",
            "requirement_type",
            "requirement_id",
            "requirement_name",
            "versions",
            "shareLink",
        ],
    )
    write_csv(
        EVENT_CSV,
        rebuild_event_summary(detail),
        [
            "event_id",
            "event_name",
            "event_desc",
            "param_count",
            "param_keys",
            "requirement_count",
            "versions",
            "requirement_ids",
        ],
    )

    manual = load_manual_rows()
    lookup = merge_rows(
        [
            {
                **r,
                "source": r.get("source") or "dayu",
                "含义": r.get("含义") or r.get("param_desc") or r.get("event_desc") or "",
                "备注": r.get("备注") or "",
            }
            for r in detail
        ],
        manual,
    )
    write_csv(
        LOOKUP_CSV,
        lookup,
        [
            "source",
            "event_id",
            "event_name",
            "param_key",
            "param_value",
            "含义",
            "备注",
            "param_name",
            "event_desc",
            "requirement_id",
            "requirement_name",
            "versions",
            "shareLink",
        ],
    )
    print(f"detail_rows={len(detail)} manual_rows={len(manual)} lookup_rows={len(lookup)}")
    print(f"wrote {DETAIL_CSV.name}, {EVENT_CSV.name}, {LOOKUP_CSV.name}")


if __name__ == "__main__":
    main()

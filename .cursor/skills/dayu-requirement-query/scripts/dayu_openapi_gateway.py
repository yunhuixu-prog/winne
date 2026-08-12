# -*- coding: utf-8 -*-
"""Dayu OpenAPI gateway client.

Data source constraint:
- Only call Dayu OpenAPI via gateway mode.
- Auth/request style follows dayu_openapi_gateway.py:
  - Authorization: Bearer ${OMNIBUS_ACCESS_TOKEN}
  - Content-Type: application/json
"""

import argparse
import json
import os

CONNECTORS_BASE_URL = os.getenv("MEITU_CONNECTORS_BASE_URL", "https://connectors.meitu-int.com").rstrip("/")
import subprocess
import sys
import warnings
from pathlib import Path
from typing import Any, Dict, Optional

# macOS system python often links LibreSSL and may emit this warning with urllib3 v2.
# It does not block requests, so silence it to avoid polluting stderr-based workflows.
warnings.filterwarnings(
    "ignore",
    message=r"urllib3 v2 only supports OpenSSL 1\.1\.1\+",
    category=Warning,
)


def _auto_install_enabled() -> bool:
    value = os.environ.get("DAYU_AUTO_INSTALL_DEPS", "1").strip().lower()
    return value not in ("0", "false", "no", "off")


def _deps_dir() -> str:
    override = os.environ.get("DAYU_DEPS_DIR")
    if override:
        return override
    home = os.path.expanduser("~")
    return os.path.join(home, ".agents", "skills", ".pydeps")


def _in_virtualenv() -> bool:
    return (
        os.environ.get("VIRTUAL_ENV") is not None
        or getattr(sys, "base_prefix", sys.prefix) != sys.prefix
        or hasattr(sys, "real_prefix")
    )


def _ensure_requests():
    deps_dir = _deps_dir()
    if os.path.isdir(deps_dir) and deps_dir not in sys.path:
        sys.path.insert(0, deps_dir)
    try:
        import requests  # type: ignore
        return requests
    except ModuleNotFoundError:
        if not _auto_install_enabled():
            raise RuntimeError(
                "Missing dependency 'requests'. Set DAYU_AUTO_INSTALL_DEPS=1 "
                "or install it manually (python3 -m pip install --user requests)."
            )

        sys.stderr.write("Dependency 'requests' missing. Installing via pip...\n")
        try:
            os.makedirs(deps_dir, exist_ok=True)
            install_cmd = [
                sys.executable,
                "-m",
                "pip",
                "install",
                "--target",
                deps_dir,
                "requests",
            ]
            subprocess.run(
                install_cmd,
                check=True,
                stdout=sys.stderr,
                stderr=sys.stderr,
            )
        except Exception as exc:
            raise RuntimeError(
                "Failed to auto-install 'requests'. "
                "Please grant permission for pip installs or run: "
                f"python3 -m pip install --target {deps_dir} requests"
            ) from exc

        if deps_dir not in sys.path:
            sys.path.insert(0, deps_dir)
        import requests  # type: ignore
        return requests


requests = _ensure_requests()

SKILL_DIR_ENV_KEYS = (
    "SKILL_DIR",
    "CODEX_SKILL_DIR",
    "CURSOR_SKILL_DIR",
    "CLAUDE_SKILL_DIR",
    "GOOGLE_SKILL_DIR",
)


def _resolve_skill_root(cli_skill_root: Optional[str]) -> Path:
    script_path = Path(__file__).resolve()
    inferred = script_path.parent.parent
    if cli_skill_root:
        candidate = Path(cli_skill_root).expanduser().resolve()
        skill_md = candidate / "SKILL.md"
        expected_script = candidate / "scripts" / script_path.name
        if skill_md.is_file() and expected_script == script_path:
            return candidate
        raise ValueError(
            f"Invalid --skill-root: {cli_skill_root}. "
            "Expected a skill root that contains SKILL.md and this script under scripts/."
        )

    candidates: list[Path] = []
    for key in SKILL_DIR_ENV_KEYS:
        value = os.environ.get(key, "").strip()
        if value:
            path = Path(value).expanduser().resolve()
            if path not in candidates:
                candidates.append(path)
    candidates.append(inferred)

    for candidate in candidates:
        skill_md = candidate / "SKILL.md"
        expected_script = candidate / "scripts" / script_path.name
        if skill_md.is_file() and expected_script == script_path:
            return candidate

    raise ValueError(
        "Unable to resolve current skill root. Set --skill-root or SKILL_DIR; global file search is disabled."
    )


DAYU_HOSTS = {
    "default": f"{CONNECTORS_BASE_URL}/gateway/bd-gateway.meitustat.com/forward/dayu",
    "starii": f"{CONNECTORS_BASE_URL}/gateway/bd-gateway.meitustat.com/forward/dayu-starii",
    "oci": f"{CONNECTORS_BASE_URL}/gateway/bd-gateway.meitustat.com/forward/dayu-oci",
}
ENV_ALIASES = {
    "domestic": "default",
    "cn": "default",
    "oversea": "starii",
    "pix": "oci",
    "pixocial": "oci",
}
DEFAULT_ENV = "default"

API_ENDPOINTS = {
    "dayu_query_project_list": os.environ.get(
        "DAYU_PROJECT_LIST_PATH", "/project_list"
    ),
    "dayu_query_requirements": os.environ.get(
        "DAYU_REQUIREMENTS_PATH", "/requirements"
    ),
}
# HTTP method per API: project_list is GET, requirements is POST (see references/dayu-api.md)
API_METHODS = {
    "dayu_query_project_list": "GET",
    "dayu_query_requirements": "POST",
}


def _ensure_token() -> str:
    token = os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip()
    if not token:
        raise RuntimeError(
            "Missing OMNIBUS_ACCESS_TOKEN. Set gateway token before querying Dayu."
        )
    return token


def _normalize_payload(api: str, params: Optional[Dict[str, Any]]) -> Dict[str, Any]:
    params = params or {}
    if api == "dayu_query_project_list":
        allowed = {"name"}
        return {k: v for k, v in params.items() if k in allowed and v is not None}

    if api == "dayu_query_requirements":
        allowed = {
            "creator",
            "clientType",
            "queryAppId",
            "versions",
            "name",
            "shareLink",
            "contentLike",
            "requirementTypes",
            "priority",
            "platforms",
        }
        payload = {k: v for k, v in params.items() if k in allowed and v is not None}
        if "queryAppId" not in payload or "clientType" not in payload:
            raise ValueError(
                "dayu_query_requirements requires queryAppId and clientType."
            )
        return payload

    raise ValueError(f"Unknown API: {api}")


def _resolve_base_url(host: Optional[str] = None, env: Optional[str] = None) -> str:
    if host:
        return host.rstrip("/")
    env_raw = (env or os.environ.get("DAYU_ENV") or DEFAULT_ENV).lower()
    env_name = ENV_ALIASES.get(env_raw, env_raw)
    if env_name not in DAYU_HOSTS:
        raise ValueError(
            f"Unknown env '{env_raw}', choose from {list(DAYU_HOSTS.keys())} "
            "or aliases {domestic, cn, oversea, pix, pixocial}."
        )
    return DAYU_HOSTS[env_name].rstrip("/")


def call_dayu_openapi(
    api: str,
    params: Optional[Dict[str, Any]] = None,
    host: Optional[str] = None,
    env: Optional[str] = None,
    timeout: int = 30,
) -> Any:
    if api not in API_ENDPOINTS:
        raise ValueError(f"Unsupported api '{api}', choose from {list(API_ENDPOINTS)}")

    token = _ensure_token()
    base = _resolve_base_url(host=host, env=env)
    path = API_ENDPOINTS[api]
    url = f"{base}{path}"
    payload = _normalize_payload(api, params)

    session = requests.Session()
    session.headers.update(
        {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}",
        }
    )
    method = API_METHODS.get(api, "POST").upper()
    if method == "GET":
        resp = session.get(url, params=payload, timeout=timeout)
    else:
        resp = session.post(url, json=payload, timeout=timeout)
    if not resp.ok:
        raise RuntimeError(f"HTTP {resp.status_code} {resp.reason}: {resp.text}")
    data = resp.json()

    # Compatible with common gateway response wrappers.
    if isinstance(data, dict) and "code" in data and data.get("code") not in (0, "0"):
        raise RuntimeError(f"API error [{data.get('code')}]: {data.get('message')}")
    if isinstance(data, dict):
        if "response" in data:
            return data["response"]
        if "data" in data:
            return data["data"]
    return data


def _load_params(
    raw: Optional[str],
    file_path: Optional[str],
    kwargs_raw: Optional[str],
) -> Optional[Dict[str, Any]]:
    values = [v for v in (raw, kwargs_raw) if v]
    if len(values) > 1:
        raise ValueError("--params and --kwargs are mutually exclusive.")
    if values and file_path:
        raise ValueError("--params/--kwargs and --params-file are mutually exclusive.")
    if raw:
        return json.loads(raw)
    if kwargs_raw:
        return json.loads(kwargs_raw)
    if file_path:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None


def main() -> None:
    parser = argparse.ArgumentParser(description="Call Dayu OpenAPI through gateway.")
    parser.add_argument(
        "--host",
        default=None,
        help="Gateway host override. If provided, --env is ignored.",
    )
    parser.add_argument(
        "--env",
        default=DEFAULT_ENV,
        choices=["default", "starii", "oci", "domestic", "cn", "oversea", "pix", "pixocial"],
        help="Host environment: default/domestic/cn, starii/oversea, oci/pix/pixocial.",
    )
    parser.add_argument("--api", required=True, choices=list(API_ENDPOINTS.keys()))
    parser.add_argument("--params", default=None, help="JSON string payload")
    parser.add_argument(
        "--kwargs",
        default=None,
        help="Compatibility alias of --params (JSON string payload).",
    )
    parser.add_argument("--params-file", default=None, help="JSON file payload")
    parser.add_argument(
        "--skill-root",
        default=None,
        help="Lock skill root directory explicitly. Resolution order: --skill-root, SKILL_DIR/agent envs, script location.",
    )
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args()

    try:
        _resolve_skill_root(args.skill_root)
        params = _load_params(args.params, args.params_file, args.kwargs)
        result = call_dayu_openapi(
            api=args.api,
            params=params,
            host=args.host,
            env=args.env,
            timeout=args.timeout,
        )
        print(json.dumps(result, ensure_ascii=False, indent=2))
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

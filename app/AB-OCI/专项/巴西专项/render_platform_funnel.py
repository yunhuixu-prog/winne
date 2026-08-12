#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path


HERE = Path(__file__).parent
SOURCE = HERE / "巴西专项_分端行为漏斗_202606.json"
BASE_RENDER = HERE / "render_funnel_priority.py"
OUTPUT_DIR = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302")

spec = importlib.util.spec_from_file_location("render_funnel_priority", BASE_RENDER)
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


def render(platform, payload):
    rows = [
        {key: value for key, value in row.items() if key != "平台"}
        for row in payload["rows"]
        if row["平台"] == platform
    ]
    dau_index = {
        row["国家维度"]: row["DAU"]
        for row in payload["dau"]
        if row["平台"] == platform
    }
    filtered_source = HERE / f"巴西专项_{platform}行为漏斗_202606.json"
    filtered_source.write_text(
        json.dumps({"period": payload["period"], "rows": rows}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    renderer.SOURCE = filtered_source
    renderer.OUTPUT = OUTPUT_DIR / f"巴西专项_{platform}重点优化功能漏斗对比.png"
    renderer.BRAZIL_DAU = dau_index["巴西"]
    renderer.OVERALL_DAU = dau_index["整体"]
    renderer.TITLE = f"{platform}｜巴西进入人数 Top 25｜行为漏斗对比"
    renderer.SUBTITLE = (
        f"2026年6月 {platform}；按巴西进入人数从高到低；"
        "指标格式为 gap（巴西 / 整体），P0/P1 功能分别标红、标橙。"
    )
    renderer.main()
    return renderer.OUTPUT


def main():
    payload = json.loads(SOURCE.read_text(encoding="utf-8"))
    for platform in ("iOS", "Android"):
        print(render(platform, payload))


if __name__ == "__main__":
    main()

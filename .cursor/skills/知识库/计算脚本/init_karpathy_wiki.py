#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""初始化 AI 周报 Karpathy Wiki。

原始知识库（只读）：
  raw_data/知识库/

Wiki 输出：
  wiki/
"""
from __future__ import annotations

import re
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from skill_paths import kb_raw_dir, skill_root, wiki_dir

BASE_DIR = skill_root()
RAW_KB_DIR = kb_raw_dir("知识库")
WIKI_DIR = wiki_dir()
FRAMEWORK_FILE = BASE_DIR.parent / "周报生成" / "memory" / "业务双周会周报框架.md"
TODAY = date.today().isoformat()

SITE_BIWEEKLY = "site_658377761"
SITE_VERSIONS = "site_632691935"


def slugify(text: str) -> str:
    text = re.sub(r"[^\w\u4e00-\u9fff\-]+", "-", text.strip().lower())
    return re.sub(r"-+", "-", text).strip("-") or "page"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def frontmatter(title: str, page_type: str, tags: list[str], sources: list[str]) -> str:
    src = ", ".join(f'"{s}"' for s in sources)
    tag = ", ".join(tags)
    return (
        "---\n"
        f"title: {title}\n"
        f"type: {page_type}\n"
        f"tags: [{tag}]\n"
        f"created: {TODAY}\n"
        f"updated: {TODAY}\n"
        f"sources: [{src}]\n"
        "---\n\n"
    )


def list_biweekly_reports() -> list[Path]:
    site_dir = RAW_KB_DIR / SITE_BIWEEKLY
    return sorted(p for p in site_dir.glob("*.md") if p.name != "structure.md")


def list_version_docs() -> list[Path]:
    site_dir = RAW_KB_DIR / SITE_VERSIONS
    return sorted(p for p in site_dir.rglob("*.md") if p.name != "structure.md")


def extract_version_name(path: Path) -> str:
    rel = path.relative_to(RAW_KB_DIR / SITE_VERSIONS)
    return rel.parts[0] if rel.parts else path.stem


def summarize_biweekly(path: Path) -> dict[str, str]:
    text = read_text(path)
    title = path.stem
    page_id = re.search(r"\*\*页面ID\*\*:\s*(\d+)", text)
    okr = re.search(r"全球累计订阅毛利[^。\n]*。", text)
    dau = re.search(r"本周DAU[^。\n]*。", text)
    dnu = re.search(r"本周DNU[^。\n]*。", text) or re.search(r"本周日均新增[^。\n]*。", text)
    bookings = re.search(r"本周日均订阅[^。\n]*。", text)
    return {
        "title": title,
        "page_id": page_id.group(1) if page_id else "",
        "okr": okr.group(0) if okr else "",
        "dau": dau.group(0) if dau else "",
        "dnu": dnu.group(0) if dnu else "",
        "bookings": bookings.group(0) if bookings else "",
        "raw": str(path.relative_to(BASE_DIR)),
    }


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def build_schema() -> str:
    return frontmatter(
        "Wiki Schema",
        "overview",
        ["meta", "schema"],
        ["memory/业务双周会周报框架.md"],
    ) + """AI 周报 Karpathy Wiki 约定。

## 知识库来源（默认目录）

| 目录 | 产出脚本 | 内容 |
|------|----------|------|
| `raw_data/知识库/` | `计算脚本/提取cf/提取cf文档.py` | Confluence 导出站点 |
| `raw_data/北斗标注/` | `计算脚本/北斗mark提取/.../fetch_marks.py` | 北斗 marks 标注 |

用户说「更新知识库」时：先重跑 fetch_marks.py 与 提取cf文档.py，再运行 check_wiki_updates.py；有新增/变更则 ingest，最后 --write-baseline。

### raw_data/知识库/ 子站点

- 来源 A：`site_658377761/` — 2026 业务双周会数据同步
- 来源 B：`site_632691935/` — 2026 年版本需求 / AB 实验 / 复盘

## 页面类型

| type | 目录 | 说明 |
|------|------|------|
| concept | concepts/ | 可复用概念与方法论 |
| entity | entities/ | 站点、版本、产品实体 |
| source | sources/ | 对 raw 文档的摘要 |
| query | queries/ | 查询结果归档 |
| overview | 根目录 | 总览与 schema |

## 写作规则

- 使用 `[[wikilinks]]` 交叉引用
- 不复制 raw 全文，只写结构化摘要
- 每次 ingest 更新 `index.md` 并追加 `log.md`
- 双周会周报优先沉淀框架、指标口径、实验结论模式
"""


def build_overview(report_count: int, version_count: int, experiment_count: int) -> str:
    return frontmatter(
        "AI 周报知识库总览",
        "overview",
        ["overview", "airbrush", "biweekly"],
        [f"raw_data/知识库/{SITE_BIWEEKLY}/structure.md", f"raw_data/知识库/{SITE_VERSIONS}/structure.md"],
    ) + f"""本 Wiki 基于 Confluence 导出的 AirBrush 业务知识库构建，服务 [[concepts/ai-weekly-report-pipeline|AI 周报流水线]] 与 [[concepts/biweekly-report-framework|业务双周会周报]] 写作。

## 知识域

1. **业务双周会数据同步**（{report_count} 期）
   - 固定四段式：OKR → 本周小结 → 业务动态 → 核心指标明细
   - 覆盖 DAU / DNU / 订阅毛利 / 留存 / AB 实验结论

2. **2026 版本与 AB 实验**（{version_count} 个版本目录，{experiment_count} 篇文档）
   - 按版本组织的需求、实验、复盘、技术需求
   - P0/P1/P2 优先级与功能域（Face、Body、订阅、Hair 等）

## 关键交叉主题

- [[concepts/core-business-metrics|核心业务指标]]：DAU、DNU、订阅毛利、留存
- [[concepts/ab-experiment-review|AB 实验复盘模式]]
- [[concepts/okr-tracking|OKR 跟踪]]
- [[entities/confluence-biweekly-site|双周会 Confluence 站点]]
- [[entities/confluence-2026-versions-site|2026 版本 Confluence 站点]]

## 使用方式

- 写周报：先查 [[sources/biweekly-reports-index|双周会历史索引]] 与 [[sources/business-biweekly-framework|周报框架]]
- 解释业务动态：查 [[sources/2026-versions-index|版本/实验索引]]，再按需深入 raw 原文
- 后续新增 raw 文档：运行 `init_karpathy_wiki.py --ingest-new` 增量入库
"""


def build_biweekly_index(reports: list[dict[str, str]]) -> str:
    lines = [
        frontmatter(
            "双周会历史索引",
            "source",
            ["biweekly", "index"],
            [f"raw_data/知识库/{SITE_BIWEEKLY}/structure.md"],
        ),
        "2026 年业务双周会数据同步历史索引。\n",
        "| 日期 | 页面 | 核心摘要 |",
        "|------|------|----------|",
    ]
    for item in reports:
        slug = slugify(item["title"])
        summary = item["dau"] or item["okr"] or "见原文"
        lines.append(
            f"| {item['title'][:8]} | [[sources/{slug}|{item['title']}]] | {summary[:80]} |"
        )
    lines.append("\n最新一期详见 [[sources/20260616-biweekly-sync|20260616 双周会]]。")
    return "\n".join(lines)


def build_versions_index(version_docs: list[Path]) -> str:
    by_version: dict[str, list[str]] = {}
    for path in version_docs:
        version = extract_version_name(path)
        by_version.setdefault(version, []).append(path.name)

    lines = [
        frontmatter(
            "2026 版本与实验索引",
            "source",
            ["versions", "ab-experiment", "index"],
            [f"raw_data/知识库/{SITE_VERSIONS}/structure.md"],
        ),
        "2026 年 AirBrush 版本需求 / AB 实验 / 复盘文档索引。\n",
        f"- 版本目录数：{len(by_version)}",
        f"- 文档总数：{len(version_docs)}",
        "",
        "## 版本列表",
        "",
    ]
    for version in sorted(by_version):
        docs = by_version[version]
        p0 = sum("【P0】" in d for d in docs)
        p1 = sum("【P1】" in d for d in docs)
        p2 = sum("【P2】" in d for d in docs)
        lines.append(
            f"- **{version}**：{len(docs)} 篇（P0={p0}, P1={p1}, P2={p2}）"
        )
    lines.extend(
        [
            "",
            "## 常见主题",
            "",
            "- 订阅策略：连续包周、挽留 SKU、价格实验",
            "- 功能实验：Face / Body / Hair / Relight / AI Retouch / Repair",
            "- 技术需求：底层改造 MTImageKit、素材中台、广告 SDK",
            "",
            "具体实验结论需按需从 raw 原文检索；双周会周报第三节会引用近期实验摘要。",
        ]
    )
    return "\n".join(lines)


def build_latest_biweekly_summary(item: dict[str, str]) -> str:
    return frontmatter(
        "20260616 业务双周会数据同步",
        "source",
        ["biweekly", "2026"],
        [item["raw"]],
    ) + f"""{item['title']} 摘要（页面 ID {item['page_id']}）。

## OKR

{item['okr'] or '见 raw 原文'}

## 本周数据小结

- {item['dau'] or 'DAU：见原文'}
- {item['dnu'] or 'DNU：见原文'}
- {item['bookings'] or '订阅毛利：见原文'}

## 关联

- 框架：[[concepts/biweekly-report-framework|业务双周会周报框架]]
- 指标：[[concepts/core-business-metrics|核心业务指标]]
- 历史：[[sources/biweekly-reports-index|双周会历史索引]]
"""


def build_framework_source() -> str:
    framework = read_text(FRAMEWORK_FILE)
    return frontmatter(
        "业务双周会周报框架",
        "source",
        ["biweekly", "framework"],
        ["memory/业务双周会周报框架.md"],
    ) + (
        "从 10 期历史双周会抽象出的固定写作框架。\n\n"
        "## 四段结构\n\n"
        "1. OKR 完成度\n"
        "2. 本周数据小结（DAU / DNU / 订阅毛利）\n"
        "3. 近期业务动态（AB 实验同步）\n"
        "4. 核心指标数据详情（近 4 周表格）\n\n"
        "详见概念页 [[concepts/biweekly-report-framework|业务双周会周报框架]]。\n\n"
        "## 原始框架文档摘录\n\n"
        + framework[:2500]
        + ("\n...\n" if len(framework) > 2500 else "")
    )


def build_concept_pages() -> dict[str, str]:
    return {
        "biweekly-report-framework.md": frontmatter(
            "业务双周会周报框架",
            "concept",
            ["biweekly", "framework", "writing"],
            ["memory/业务双周会周报框架.md", f"raw_data/知识库/{SITE_BIWEEKLY}/"],
        )
        + """业务双周会数据同步的标准四段式结构，用于 AI 周报 v1 生成。

## 结构

1. **OKR 完成度**：累计订阅毛利 + MAU + 时间进度对比
2. **本周数据小结**：DAU → DNU → 订阅毛利，各 1 条，可展开国家/渠道/节日
3. **近期业务动态**：AB 实验条目（指标影响 + 后续决策）
4. **核心指标明细**：近 4 周表格 + 解读列

## 写作惯例

- 环比表述、贡献度、同比参照
- 节日 / 投放 / 版本 bug 作为波动解释
- 实验必须有「后续/结论」

## 关联

- [[sources/business-biweekly-framework|框架来源]]
- [[sources/biweekly-reports-index|历史双周会]]
- [[concepts/ai-weekly-report-pipeline|AI 周报流水线]]
""",
        "core-business-metrics.md": frontmatter(
            "核心业务指标",
            "concept",
            ["metrics", "dau", "dnu", "bookings", "retention"],
            [f"raw_data/知识库/{SITE_BIWEEKLY}/"],
        )
        + """AirBrush 双周会核心指标口径。

## 用户规模

| 指标 | 说明 |
|------|------|
| DAU | 整体 / iOS / Android / 核心国家 |
| DNU | 整体；拆分自然 vs 渠道 |
| 活跃次留 | 次日留存率 = 次日留存人数 / 活跃用户数 |
| 新增次留 | 新增次日留存人数 / DNU |

## 收入

| 指标 | 说明 |
|------|------|
| 日均订阅毛利 | 剔除退款，OCI 口径 |
| 新增毛利 / 续订毛利 | 结构与驱动拆分 |

## 分析维度

- 环比上周、W-3、YoY 同期
- 核心国家：美国、英国、巴西
- 贡献度下钻

## 关联

- [[concepts/biweekly-report-framework|周报框架]]
- [[concepts/ab-experiment-review|AB 实验复盘]]
""",
        "ab-experiment-review.md": frontmatter(
            "AB 实验复盘模式",
            "concept",
            ["ab-experiment", "review"],
            [f"raw_data/知识库/{SITE_VERSIONS}/"],
        )
        + """AirBrush AB 实验文档与双周会引用的常见结构。

## 实验条目模板

```
N、【实验名】：Confluence 链接

- 核心指标影响（留存 / 保存 / 订阅 / ARPU）
- 分端 / 分新老 / 分国家
- 功能级指标（打勾率、保存渗透率、订阅成功渗透率）
- 后续：全量 / 回对照组 / 待讨论
```

## 常见结论类型

- 无显著影响
- 功能正向、整体无变化
- 功能负向、回对照组
- 订阅正向、预估年化增量
- 分端决策（iOS 全量 A，Android 回对照）

## 关联

- [[sources/2026-versions-index|2026 版本实验索引]]
- [[entities/confluence-2026-versions-site|版本 Confluence 站点]]
""",
        "okr-tracking.md": frontmatter(
            "OKR 跟踪",
            "concept",
            ["okr", "bookings", "mau"],
            [f"raw_data/知识库/{SITE_BIWEEKLY}/"],
        )
        + """双周会 OKR 部分的跟踪逻辑。

## 主指标

- 全年累计订阅毛利（退款后、分成后）
- MAU（月度目标）

## 表形态

- 年度简表 / 分月明细 / 分维度汇总（Q1 + 当月 + 年度）

## 解读要点

- 完成度 vs 时间进度（领先/落后）
- 口径切换备注（OCI / Pix）
- Q1 小结、分市场缺口

## 关联

- [[concepts/biweekly-report-framework|周报框架]]
""",
        "ai-weekly-report-pipeline.md": frontmatter(
            "AI 周报流水线",
            "concept",
            ["pipeline", "automation"],
            ["memory/业务双周会周报框架.md"],
        )
        + """AI 周报项目的数据处理与文档生成流水线。

## 流程

1. `fetch_beidou.py` → `raw_data/*.csv`
2. `s1下钻csv生成.py` → `output/下钻/`
3. `s2贡献度csv生成.py` → `output/贡献度/`
4. `s3导出下钻md脚本.py` → `output/下钻报告/`
5. `s5异常检测.py` → `output/异常指标检测.md`
6. `s4生成v1周报md.py` → `output/weekly_report_v1.md`

## 与 Wiki 的关系

- raw 实验/历史周报：`raw_data/知识库/`
- 框架：`memory/业务双周会周报框架.md`
- 本 Wiki：结构化索引 + 概念沉淀

## 关联

- [[concepts/biweekly-report-framework|业务双周会框架]]
- [[sources/biweekly-reports-index|历史双周会]]
""",
    }


def build_entity_pages(report_count: int, version_count: int) -> dict[str, str]:
    return {
        "confluence-biweekly-site.md": frontmatter(
            "双周会 Confluence 站点",
            "entity",
            ["confluence", "biweekly"],
            [f"raw_data/知识库/{SITE_BIWEEKLY}/structure.md"],
        )
        + f"""Confluence 站点 `{SITE_BIWEEKLY}`：2026 年业务双周会数据同步。

- 根页面：26年业务数据
- 子页面：{report_count} 期双周会 Markdown
- 用途：历史周报样式、指标解读、实验引用

## 关联

- [[sources/biweekly-reports-index|双周会索引]]
- [[concepts/biweekly-report-framework|周报框架]]
""",
        "confluence-2026-versions-site.md": frontmatter(
            "2026 版本 Confluence 站点",
            "entity",
            ["confluence", "versions", "ab-experiment"],
            [f"raw_data/知识库/{SITE_VERSIONS}/structure.md"],
        )
        + f"""Confluence 站点 `{SITE_VERSIONS}`：2026 年版本需求与 AB 实验。

- 根页面：2026年版本
- 版本目录：约 {version_count} 个
- 内容：需求、AB 实验、复盘、技术需求、底层先行

## 关联

- [[sources/2026-versions-index|版本实验索引]]
- [[concepts/ab-experiment-review|AB 实验复盘模式]]
""",
    }


def build_index(pages: list[tuple[str, str, str]]) -> str:
    lines = [
        frontmatter("Wiki Index", "overview", ["index"], []),
        "# Wiki Index\n",
        "## Overview",
        f"- [[overview|AI 周报知识库总览]] — 知识域与使用方式 ({TODAY})",
        f"- [[schema|Wiki Schema]] — 约定与 raw 路径 ({TODAY})",
        "",
    ]
    sections: dict[str, list[tuple[str, str, str]]] = {}
    for section, title, path in pages:
        sections.setdefault(section, []).append((title, path, TODAY))

    for section, items in sections.items():
        lines.append(f"## {section}")
        for title, path, updated in items:
            lines.append(f"- [{title}]({path}) — ({updated})")
        lines.append("")
    return "\n".join(lines)


def build_log(report_count: int, version_doc_count: int, pages_touched: int) -> str:
    return (
        frontmatter("Wiki Log", "overview", ["log"], [])
        + f"""# Wiki Log

## [{TODAY}] init | AI 周报知识库初始化
- Raw source: raw_data/知识库/
- Biweekly reports ingested (catalog): {report_count}
- Version/experiment docs indexed: {version_doc_count}
- Pages created: schema, overview, index, concepts/*, entities/*, sources/*
- Total pages touched: {pages_touched}
- Note: 366 篇版本/实验文档先做索引级 ingest，后续可按版本或实验名单篇深化
"""
    )


def build_manifest(version_docs: list[Path], reports: list[Path]) -> str:
    lines = ["# Raw Manifest", "", f"Generated: {TODAY}", ""]
    lines.append("## Biweekly reports")
    for p in reports:
        lines.append(f"- {p.relative_to(BASE_DIR)}")
    lines.append("")
    lines.append("## Version / experiment docs")
    for p in version_docs:
        lines.append(f"- {p.relative_to(BASE_DIR)}")
    return "\n".join(lines)


def main() -> None:
    reports_paths = list_biweekly_reports()
    version_docs = list_version_docs()
    report_summaries = [summarize_biweekly(p) for p in reports_paths]
    latest = report_summaries[-1] if report_summaries else {}

    concept_pages = build_concept_pages()
    entity_pages = build_entity_pages(len(reports_paths), len({extract_version_name(p) for p in version_docs}))

    source_pages = {
        "biweekly-reports-index.md": build_biweekly_index(report_summaries),
        "2026-versions-index.md": build_versions_index(version_docs),
        "business-biweekly-framework.md": build_framework_source(),
    }
    if latest:
        source_pages["20260616-biweekly-sync.md"] = build_latest_biweekly_summary(latest)

    write(WIKI_DIR / "schema.md", build_schema())
    write(WIKI_DIR / "overview.md", build_overview(len(reports_paths), len({extract_version_name(p) for p in version_docs}), len(version_docs)))
    for name, content in concept_pages.items():
        write(WIKI_DIR / "concepts" / name, content)
    for name, content in entity_pages.items():
        write(WIKI_DIR / "entities" / name, content)
    for name, content in source_pages.items():
        write(WIKI_DIR / "sources" / name, content)
    write(WIKI_DIR / "sources" / "_manifest.md", build_manifest(version_docs, reports_paths))

    index_entries: list[tuple[str, str, str]] = [
        ("Concepts", "业务双周会周报框架", "concepts/biweekly-report-framework.md"),
        ("Concepts", "核心业务指标", "concepts/core-business-metrics.md"),
        ("Concepts", "AB 实验复盘模式", "concepts/ab-experiment-review.md"),
        ("Concepts", "OKR 跟踪", "concepts/okr-tracking.md"),
        ("Concepts", "AI 周报流水线", "concepts/ai-weekly-report-pipeline.md"),
        ("Entities", "双周会 Confluence 站点", "entities/confluence-biweekly-site.md"),
        ("Entities", "2026 版本 Confluence 站点", "entities/confluence-2026-versions-site.md"),
        ("Sources", "双周会历史索引", "sources/biweekly-reports-index.md"),
        ("Sources", "2026 版本与实验索引", "sources/2026-versions-index.md"),
        ("Sources", "业务双周会周报框架", "sources/business-biweekly-framework.md"),
    ]
    if latest:
        index_entries.append(("Sources", "20260616 双周会", "sources/20260616-biweekly-sync.md"))

    pages_touched = 3 + len(concept_pages) + len(entity_pages) + len(source_pages) + 1
    write(WIKI_DIR / "index.md", build_index(index_entries))
    write(WIKI_DIR / "log.md", build_log(len(reports_paths), len(version_docs), pages_touched))

    print(f"Wiki 已初始化: {WIKI_DIR}")
    print(f"- 双周会报告: {len(reports_paths)}")
    print(f"- 版本/实验文档: {len(version_docs)}")
    print(f"- Wiki 页面: {pages_touched}")


if __name__ == "__main__":
    main()

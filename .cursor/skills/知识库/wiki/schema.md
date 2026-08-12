---
title: Wiki Schema
type: overview
tags: [meta, schema]
created: 2026-06-17
updated: 2026-06-17
sources: ["memory/业务双周会周报框架.md"]
---

AI 周报 Karpathy Wiki 约定。

## 知识库来源（默认目录）

以下目录为 **只读** 原始知识库；ingest 时不得修改其中文件。

| 目录 | 产出脚本 | 内容 |
|------|----------|------|
| `raw_data/知识库/` | `计算脚本/提取cf/提取cf文档.py` | Confluence 导出站点 |
| `raw_data/北斗标注/` | `计算脚本/北斗mark提取/.../fetch_marks.py` | 北斗看板 marks 标注 |
| `raw_data/知识库/manual/` | `计算脚本/提取产品变动记录/extract_airbrush_changelog.py` | AirBrush 产品变动记录 & 节日公历对照（源自 `raw_data/其他/*.xlsx`） |

**默认行为**：
- **「更新知识库」**：每次先重跑 `fetch_marks.py` + `提取cf文档.py`，再扫描相对 `_ingest_manifest.json` 的新增/变更并 INGEST，最后 `--write-baseline`。
- **「拉取最新北斗mark标识」** / **「拉取最新cf」**：只跑对应拉取，再同样 INGEST + `--write-baseline`。

检查命令（`KB_SKILL_ROOT` = 知识库 skill 根目录）：

```bash
python 计算脚本/check_wiki_updates.py
```

### raw_data/知识库/ 子站点

- 来源 A：`site_658377761/` — 2026 业务双周会数据同步（10 期）
- 来源 B：`site_632691935/` — 2026 年版本需求 / AB 实验 / 复盘（366 篇）
- 来源 C：`site_658377754/` — 2026 年分析报告（8 篇）
- 来源 D：`site_599276617/` — 2025 年分析报告 / 实验汇总（20 篇）

### raw_data/北斗标注/

- `marks_merged.json` — OCI 看板 marks 标注线（归因优先级见 `memory/归因思路.md`）

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

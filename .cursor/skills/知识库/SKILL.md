---
name: airbrush-knowledge-base
description: "知识库 — AirBrush 周报/月报共用的 Karpathy Wiki 与 raw 知识源。含 Confluence、北斗 marks、产品变动记录、节日公历对照。TRIGGER: /知识库、更新知识库、拉取北斗mark、拉取cf、拉取产品变动记录、知识库 QUERY、ingest wiki。周报生成与月报生成均引用本 skill。"
---

# 知识库

AirBrush 周报、月报**共用**的知识库 skill。Skill 根目录 = 本文件所在目录（`KB_SKILL_ROOT`）。

## 目录结构

```
知识库/                            # KB_SKILL_ROOT
├── SKILL.md
├── raw_data/
│   ├── 知识库/                    # Confluence 导出 + manual/
│   ├── 北斗标注/                  # marks_merged.json
│   └── 其他/                      # Pixocial产品数据变动记录.xlsx 等
├── wiki/                          # Karpathy Wiki（ingest 产物）
├── references/
│   └── 知识库同步.md
└── 计算脚本/
    ├── skill_paths.py
    ├── check_wiki_updates.py
    ├── init_karpathy_wiki.py
    ├── 提取cf/
    ├── 北斗mark提取/
    └── 提取产品变动记录/
```

## 触发与参数

| 用户说法 | 行为 |
|---------|------|
| **`/知识库`** | 进入本 skill；归因 QUERY 或拉取/同步知识库 |
| **`拉取最新北斗mark标识`** / `拉取北斗mark` / `拉 marks` | `fetch_marks.py` → INGEST → `--write-baseline` |
| **`拉取最新cf`** / `拉取cf` / `拉 cf` | `提取cf文档.py` → INGEST → `--write-baseline` |
| **`拉取产品变动记录`** / `更新变动记录` | `extract_airbrush_changelog.py` → INGEST → `--write-baseline` |
| **`更新知识库`** | **每次**重跑北斗 mark + CF 拉取 → INGEST → `--write-baseline`（不含产品变动记录；需单独说「拉取产品变动记录」） |

`cwd = KB_SKILL_ROOT`。拉取需环境变量 `OMNIBUS_ACCESS_TOKEN`。任一步拉取失败则**不得** `--write-baseline`。

## 执行流程

### 拉取 + 同步

| 用户说法 | ① 拉取 raw | ② 更新 wiki |
|---------|-----------|------------|
| **拉取最新北斗mark标识** | `python 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py` | `check_wiki_updates.py` → karpathy-wiki **INGEST** → `--write-baseline` |
| **拉取最新cf** | `python 计算脚本/提取cf/提取cf文档.py` | 同上 |
| **拉取产品变动记录** | `python 计算脚本/提取产品变动记录/extract_airbrush_changelog.py` | 同上 |
| **更新知识库** | **先** `fetch_marks.py`，**再** `提取cf文档.py`（两步都跑） | 同上 |

详细步骤见 [references/知识库同步.md](references/知识库同步.md)。

### 检查命令

```bash
cd KB_SKILL_ROOT
python 计算脚本/check_wiki_updates.py
python 计算脚本/check_wiki_updates.py --write-baseline
```

## 与报告 skill 的关系

| 消费方 | wiki 路径 | 说明 |
|--------|-----------|------|
| [周报生成](../周报生成/SKILL.md) | `KB_SKILL_ROOT/wiki/` | v2/v3 归因 QUERY |
| [月报生成](../月报生成/SKILL.md) | `KB_SKILL_ROOT/wiki/` | 月报归因 QUERY（若启用） |

INGEST 规则：调 `karpathy-wiki` skill，扫描 `raw_data/知识库/`、`raw_data/北斗标注/` 相对 `wiki/sources/_ingest_manifest.json` 的新增/变更，写入 **`KB_SKILL_ROOT/wiki/`**；**不得修改 raw_data/**。

匹配优先级（归因）：**marks > 历史周报 > 节假日 > 产品需求**。节假日须按分析周期年份查 `wiki/concepts/airbrush-holiday-calendar.md`。

## 禁止

- 混用 `app/AB-OCI/专项/AI周报/wiki/` 与本 skill 的 `wiki/`
- ingest 时修改 `raw_data/` 下原始文件
- 拉取失败仍执行 `--write-baseline`

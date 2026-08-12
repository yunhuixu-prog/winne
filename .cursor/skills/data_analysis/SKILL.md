---
name: data_analysis
description: >-
  AirBrush 数据分析师日常工作入口。覆盖临时取数、异动归因、周报月报、专题分析、实验分析、更新事件埋点。
  Use when the user mentions 临时取数、看板取数、神舟跑数、异动归因、周报、月报、专题分析、
  实验分析、更新事件埋点、下钻、贡献度，或说「用 data_analysis」「按分析师流程」「日常分析」。
---

# data_analysis — 分析师日常工作

Skill 根目录 = 本文件所在目录（`SKILL_ROOT`）。本 skill 是**编排入口**：先读本文件与配套文档，再按场景**调用**既有子 skill，禁止在本 skill 内重写子 skill 的完整流程。

## 必读配套

| 文件 | 用途 |
|------|------|
| [分析思路.md](分析思路.md) | 日常分析步骤与场景分流 |
| [注意事项.md](注意事项.md) | 踩坑与约定；每次调用发现新问题须追加 |
| [raw_data/](raw_data/README.md) | 取数知识：看板说明、埋点事件 |

## 场景 → 子 skill 路由

| 场景 | 做法 |
|------|------|
| **看板取数** | 读 **`raw_data/看板说明/看板.csv`** 定位 `dashboardId` / `chartId` / 网关 / 筛选；再按 **beidou-dashboard-data** skill 取数（`--env` 与 CSV「网关」列一致，常见 `oci`） |
| **神舟跑数** | 见下方「神舟跑数要点」：**先写 SQL 给用户确认 → 再跑**；事件未命中埋点知识时**先问用户** |
| **更新事件埋点** | 见下方专节：调 **[dayu-requirement-query](../dayu-requirement-query/SKILL.md)** + 合并手动版 |
| **周报** | 读并执行 **[周报生成](../周报生成/SKILL.md)** |
| **月报** | 读并执行 **[月报生成](../月报生成/SKILL.md)** |
| **归因 / 知识查找** | 读并执行 **[知识库](../知识库/SKILL.md)**（QUERY `wiki/`；匹配优先级 marks > 历史周报 > 节假日 > 产品需求） |
| **实验冲突定量** | **[ab-experiment-conflict](../ab-experiment-conflict/SKILL.md)** |
| **续费率宽表** | **[ab-renewal-rates-date-p](../ab-renewal-rates-date-p/SKILL.md)** |
| **双周会 SOP** | **[biweekly-data-sop](../biweekly-data-sop/SKILL.md)** |

口径与表字段：优先 `app/AB-OCI/口径/`、`app/AB-OCI/说明/`；禁止参考 BigQuery 旧表（`dataintegration-265403`、`airbrush-1324` 等）。

## 更新事件埋点（触发词）

用户说 **「更新事件埋点」** 时**必须**执行本流程（默认一键脚本）：

```bash
cd SKILL_ROOT
zsh -lic "python3 scripts/update_event_tracking.py"
```

| 步骤 | 说明 |
|------|------|
| 1. 水位 | 读 `raw_data/埋点事件/update_state.json` → `last_synced_version` |
| 2. 待拉版本 | 扫描 **知识库** `raw_data/知识库/site_632691935` 目录名中的版本号，取 **> 水位** 的版本 |
| 3. 大禹 | 项目 **Airbrush**（OCI `dayu_query_project_list`，当前 appId=282）、环境 **oci**；按版本拉需求；无效版本（返回全量）跳过 |
| 4. 落盘 | 更新 `dayu_gt722_*`、`dayu_gt722/requirements/`、需求索引；回写水位 |
| 5. 手动版 | **每次**把 `事件清单（手动版）.csv` 合并进 `事件知识_检索.csv`（即便无新版本也要合并） |

仅合并手动：`python3 scripts/update_event_tracking.py --manual-only`  
只看待拉版本：`python3 scripts/update_event_tracking.py --dry-run`

手动版列：`事件名,key名,key值,含义,备注`。鉴权失败按 dayu skill 处理，**不跨环境兜底**。

## 工作流（每次任务）

1. **定场景**：按 [分析思路.md](分析思路.md) 判断是取数 / SQL / 报告 / 归因 / 实验 / 专题 / 更新埋点。
2. **查注意事项**：先扫 [注意事项.md](注意事项.md) 是否已有相关坑。
3. **调子 skill**：只读对应子 skill 的 `SKILL.md`（及它要求的 memory/references），按其硬性规则执行。
4. **交付**：给出结果路径或结论；数据结论须带来源（看板 id / SQL 文件 / 报告文件）。
5. **回写注意事项**：若本次出现**新**报错、口径歧义、筛选踩坑或手动约定，追加到 [注意事项.md](注意事项.md)（已有条目不重复）。

## 看板取数要点

1. 打开 **`raw_data/看板说明/看板.csv`**，按「大类 / 指标」匹配行。
2. 记录：`dashboardId`、`chartId`、`网关`、`筛选说明`、`备注`。
3. 调用 beidou-dashboard-data：先探测 `linkageConfig`，再带真实 `filters` 二次取数；禁止把首轮默认结果当最终答案。
4. 订阅毛利注意 CSV 备注（2026：`89060` vs `89046`）。
5. **订阅来源多级看板**（功能/子功能订阅人数）：先读 **`raw_data/订阅归因层级/`**（见 [分析思路.md](分析思路.md) §2.0）；权威表为同目录 `官方分级mapping.csv`（自 Google Sheet 导出）。

## 神舟跑数要点（硬性）

与「看板取数 / 北斗」不同：本路径要写 SQL 并在神舟执行时，必须遵守：

1. **事件口径**：先查 **`raw_data/埋点事件/事件知识_检索.csv`**（及 dayu / 手动版 / 全量清单）。涉及事件但**未找到**对应 `event_id` / key / 值口径时 → **先询问用户**，禁止编造后续写 SQL。
2. **先写后跑**：按 **[hive_sql_create](../hive_sql_create/SKILL.md)** 写好 SQL 后，**先把完整 SQL 发给用户审阅**；仅在用户明确确认（如「没问题」「可以跑」）后，才调用 shenzhou-temp-query。
3. **禁止**：未经确认直接 `run --wait --download`；用户改口径后须再贴一版 SQL 确认。

确认后执行示例：

```bash
python3 <shenzhou-temp-query>/scripts/temp_query.py run \
  --sql-file ./query.sql \
  --project <用户指定项目> \
  --env oci --engine presto \
  --wait --download -o result.csv
```

## 触发话术示例

```text
更新事件埋点
```

```text
用 data_analysis 查近 7 天 DAU（整体/iOS）
```

```text
生成近期周报 / 生成 202606 月报
```

## 检查清单

```
- [ ] 已读 分析思路.md 并完成场景分流
- [ ] 已扫 注意事项.md
- [ ] 更新事件埋点：update_event_tracking.py（含手动版合并）
- [ ] 神舟：事件知识命中（未命中先问）→ 写出 SQL 给用户确认 → 再 shenzhou-temp-query
- [ ] 新问题已追加 注意事项.md（如有）
```

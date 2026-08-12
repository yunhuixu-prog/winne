---
title: AI 周报流水线
type: concept
tags: [pipeline, automation]
created: 2026-06-17
updated: 2026-06-17
sources: ["memory/业务双周会周报框架.md", "raw/北斗标注/marks_merged.json"]
---

AI 周报项目的数据处理与文档生成流水线。

## 流程

1. `fetch_beidou.py` → `raw_data/*.csv`
2. `fetch_marks.py` → `raw_data/北斗标注/marks_merged.json` → 同步 `raw/北斗标注/` 供 Wiki ingest
3. `s1下钻csv生成.py` → `output/下钻/`
4. `s2贡献度csv生成.py` → `output/贡献度/`
5. `s3导出下钻md脚本.py` → `output/下钻报告/`
6. `s5异常检测.py` → `output/异常指标检测.md`
7. `s4生成v1周报md.py` → `output/weekly_report_v1.md`
8. **Agent Phase B** → `weekly_report_v2.md`（`memory/归因思路.md`，引用 [[concepts/beidou-marks-attribution|Marks 归因]]）
9. **Agent Phase C** → `审核报告.md` + `weekly_report_v3.md`（`memory/终审专家.md`；**v2 只读不修改**）

## 与 Wiki 的关系

- raw 实验/历史周报：`raw_data/知识库/site_658377761`、`site_658377754`、`site_599276617`
- raw 版本需求：`raw_data/知识库/site_632691935`
- 北斗 marks：`raw/北斗标注/`
- 框架：`memory/业务双周会周报框架.md`
- 本 Wiki：结构化索引 + 概念沉淀

## 关联

- [[concepts/biweekly-report-framework|业务双周会框架]]
- [[sources/biweekly-reports-index|历史双周会]]

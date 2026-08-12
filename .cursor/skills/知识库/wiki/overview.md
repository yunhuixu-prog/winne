---
title: AI 周报知识库总览
type: overview
tags: [overview, airbrush, biweekly]
created: 2026-06-17
updated: 2026-07-07
sources: ["raw_data/知识库/site_658377761/structure.md", "raw_data/知识库/site_632691935/structure.md", "raw_data/知识库/site_658377754/structure.md", "raw_data/知识库/site_599276617/structure.md", "raw/北斗标注/marks_merged.json"]
---

本 Wiki 基于 Confluence 导出的 AirBrush 业务知识库构建，服务 [[concepts/ai-weekly-report-pipeline|AI 周报流水线]] 与 [[concepts/biweekly-report-framework|业务双周会周报]] 写作。

## 知识域

1. **业务双周会数据同步**（10 期，`site_658377761`）
   - 固定四段式：OKR → 本周小结 → 业务动态 → 核心指标明细

2. **2026 版本与 AB 实验**（366 篇，`site_632691935`）
   - 按版本组织的需求、实验、复盘、技术需求

3. **2026 分析报告**（8 篇，`site_658377754`）
   - 增长月会、Q1/年度复盘、实验汇总、行业/调研分析
   - 见 [[sources/2026-analysis-reports-index|2026 分析报告索引]]

4. **2025 分析报告**（20 篇，`site_599276617`）
   - AB 实验评估、促销复盘、Q3 复盘、潜力国家分析
   - 见 [[sources/2025-analysis-reports-index|2025 分析报告索引]]

5. **北斗 Marks 标注**（`raw/北斗标注/`）
   - 见 [[sources/beidou-marks-merged|Marks 索引]]

6. **历史月度指标归因**（`raw_data/知识库/manual/`，PDF 提取 + 手工补充）
   - [[concepts/airbrush-historical-metric-attribution|历史指标归因索引]]
   - 活跃/行为：[[sources/airbrush-overseas-activity-behavior-attribution|MAU/DAU/留存/保存]]
   - 经营：[[sources/airbrush-monthly-business-metrics-attribution|VPU/MRR/Bookings/续费率]]
   - 续订季节性：[[sources/manual-commercial-seasonality-renewal-20260721|Reshape/Resize 转付费 & 截屏拦截]]

## 关键交叉主题

- [[concepts/core-business-metrics|核心业务指标]]：DAU、DNU、订阅毛利、留存
- [[concepts/beidou-marks-attribution|北斗 Marks 归因]]
- [[concepts/ab-experiment-review|AB 实验复盘模式]]
- [[entities/confluence-2026-analysis-site|2026 分析站点]]
- [[entities/confluence-2025-analysis-site|2025 分析站点]]
- [[concepts/okr-tracking|OKR 跟踪]]
- [[entities/confluence-biweekly-site|双周会 Confluence 站点]]
- [[entities/confluence-2026-versions-site|2026 版本 Confluence 站点]]

## 使用方式

- 写周报：先查 [[sources/biweekly-reports-index|双周会历史索引]] 与 [[sources/business-biweekly-framework|周报框架]]
- 解释业务动态：查 [[sources/2026-versions-index|版本/实验索引]]、[[sources/2026-experiment-summary|2026 实验汇总]]
- 深度归因：查 [[sources/20260616-may-growth-review|5月增长月会]]、[[sources/2025-experiment-summary|2025 实验汇总]]
- 历史同月对照：查 [[concepts/airbrush-historical-metric-attribution|历史指标归因索引]]
- 周报归因：查 [[sources/beidou-marks-merged|北斗 Marks]] 与 [[concepts/beidou-marks-attribution|归因规则]]
- 后续新增 raw 文档：运行 `init_karpathy_wiki.py --ingest-new` 增量入库

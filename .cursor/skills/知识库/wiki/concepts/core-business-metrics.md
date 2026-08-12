---
title: 核心业务指标
type: concept
tags: [metrics, dau, dnu, bookings, retention]
created: 2026-06-17
updated: 2026-07-07
sources: ["raw_data/知识库/site_658377761/", "raw/北斗标注/marks_merged.json", "raw_data/知识库/manual/airbrush-overseas-activity-behavior-attribution.md", "raw_data/知识库/manual/airbrush-monthly-business-metrics-attribution.md"]
---

AirBrush 双周会核心指标口径。

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
- 北斗 marks 标注：见 [[sources/beidou-marks-merged|Marks 索引]]（归因最高优先级）

## 历史月度归因

- [[concepts/airbrush-historical-metric-attribution|历史指标归因索引]]：往期同月 MAU/DAU/留存/Bookings 等波动解释（2021–2025）

## 关联

- [[concepts/biweekly-report-framework|周报框架]]
- [[concepts/beidou-marks-attribution|Marks 归因]]
- [[concepts/ab-experiment-review|AB 实验复盘]]

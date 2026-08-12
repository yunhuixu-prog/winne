---
title: AirBrush 历史指标归因索引
type: concept
tags: [airbrush, attribution, mau, bookings, retention, manual]
created: 2026-07-07
updated: 2026-07-21
sources: ["raw_data/知识库/manual/airbrush-overseas-activity-behavior-attribution.md", "raw_data/知识库/manual/airbrush-monthly-business-metrics-attribution.md", "raw_data/知识库/manual/20260721-历史商业化策略续订季节性.md"]
---

AirBrush **历史月度指标波动归因**查询入口，供周报/月报在 marks、产品变动、节日之外补充「往期同类月份」解释依据。

## 数据源

| 文档 | 覆盖指标 | 时间跨度 |
|------|----------|----------|
| [[sources/airbrush-overseas-activity-behavior-attribution\|活跃与行为指标]] | MAU、DAU、DNU、次月留存、日均次留、保存渗透率、人均保存 | 2021-07 ~ 2025-06 |
| [[sources/airbrush-monthly-business-metrics-attribution\|经营指标]] | Paid Retention、VPU/VPR、ROAS、MRR、Bookings、New Paying Users、年 SKU R1 | 2021 ~ 2025-06 |
| [[sources/manual-commercial-seasonality-renewal-20260721\|历史商业化策略续订季节性]] | 新增/续订季节性机制（Reshape·Resize 转付费、截屏拦截） | 事件：2022-07、2023-08；用法：每年同期 |

## 归因优先级（与本 Wiki 其他源配合）

1. **北斗 marks** — 见 [[concepts/beidou-marks-attribution|Marks 归因]]
2. **历史周报/月报** — 双周会、增长月会
3. **本索引（历史月度归因）** — 结构性因素与往期同月对照
4. **节假日** — [[concepts/airbrush-holiday-calendar|节日公历对照]]（须按分析周年份）
5. **产品需求/变动** — [[sources/airbrush-product-data-changelog|产品数据变动记录]]

## 常见结构性因素速查

- **月天数**：2 月 28/29 天、6 月少一天 → MAU/DNU 结构性波动
- **Reshape/Resize 非巴西免费转付费（2022-07 初）**：当时新增收入大涨；**每年同期续订收入**亦上涨 — [[entities/reshape-resize-freemium-202207|实体]]
- **免费改付费余波（2022-07~10）**：活跃/留存偏负面；Paid Retention / 应续高基见经营归因月表
- **截屏拦截 & 取消付费召回（2023-08 下旬）**：当时新增收入暴涨；**每年同期续订收入**亦上涨 — [[entities/screenshot-intercept-cancel-recall-202308|实体]]；后续部分窗口见防截屏用户续费率回落
- **Android UA 停投（2024-08~11）**：MNU/MAU 滞后下降
- **年底冲量（2024-12）→ 节后减投（2025-01）**：MNU/MAU 大幅波动
- **新用户限免实验（2025-04~05）**：DAU、次留、次月留存正向

## 关联

- [[concepts/core-business-metrics|核心业务指标]]
- [[concepts/airbrush-holiday-calendar|节日公历对照]]
- [[sources/airbrush-product-data-changelog|产品数据变动记录]]
- [[entities/reshape-resize-freemium-202207|Reshape/Resize 非巴西转付费 202207]]
- [[entities/screenshot-intercept-cancel-recall-202308|截屏拦截&取消付费召回 202308]]

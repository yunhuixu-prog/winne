---
title: AirBrush 产品数据变动记录
type: source
tags: [airbrush, changelog, holiday, attribution]
created: 2026-06-24
updated: 2026-06-24
sources: ["raw_data/其他/Pixocial产品数据变动记录.xlsx"]
---

# AirBrush 产品数据变动记录

## 来源

| 项 | 值 |
|---|---|
| 原文件 | `raw_data/其他/Pixocial产品数据变动记录.xlsx` |
| Sheet | **AirBrush**（138 条变动，倒序） |
| Markdown 提取 | `raw_data/知识库/manual/airbrush-product-data-changelog.md` |
| 节日对照 | `raw_data/知识库/manual/airbrush-holiday-calendar-2024-2026.md` → [[concepts/airbrush-holiday-calendar]] |

## 字段说明

| 列 | 含义 |
|----|------|
| 时间范围 | 变动发生时段（倒序填写） |
| 变动类型 | 活跃 / 付费 / 节日 / UA / 指标异动 / 产品迭代等 |
| 数据影响 | 对 DAU、DNU、订阅收入等的核心描述 |
| 变动内容 | 事件、促销复盘链接、原因补充 |
| 备注 | 促销本地化时间、价格策略等 |

## 内容概要

- **时间跨度**：约 2021～2025，以 2024～2025 最密。
- **节日类**：情人节、狂欢节、复活节、母亲节、万圣节、黑五、圣诞、开斋节、宰牲节、六月节等；含订阅促销复盘与活跃波动。
- **非节日类**：伊朗网络封锁、Google Play 续费规则、算法/存储故障、UA 投放、版本迭代、埋点异常等。
- **地区**：巴西、美国、俄罗斯、南亚（孟加拉/巴基斯坦）、伊朗、韩国等高频出现。

## 周报归因要点

1. 匹配「节日,活跃」「节日,付费」类记录时，用 [[concepts/airbrush-holiday-calendar|节日公历对照]] 验证**当年**日期是否与分析周重合。
2. 促销类常含 **7 天试用**，当期 new paying/booking 偏低、收入滞后转化 — 勿与真实收入下滑混淆。
3. 与 Confluence 复盘（如 `20250912 历年节日活动会员促销复盘`）可交叉引用。

## 重新提取

Excel 更新后，在 `SKILL_ROOT` 运行：

```bash
python 计算脚本/知识库/提取产品变动记录/extract_airbrush_changelog.py
python 计算脚本/知识库/check_wiki_updates.py
# → INGEST → --write-baseline
```

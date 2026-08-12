---
title: Onboarding 订阅页优化 AB（V8.10.0）
type: source
tags: [ab-experiment, onboarding, subscription, 8.10.0]
created: 2026-07-13
updated: 2026-07-13
sources:
  - "raw_data/知识库/site_632691935/V8.10.0版本（6_8上线）/【P0】Onboarding订阅页优化AB实验（忻恬）.md"
  - "raw_data/知识库/site_658377754/26年实验与分析汇总.md"
---

V8.10.0（**6/8 上线**）Onboarding 订阅页 UI 改版 AB：更突出 $0 试用信息，目标提升该页订阅转化与 GMV。

## 实验结论（汇总序号 44）

- **明显正向**：Onboarding 订阅率显著上涨带动**整体订阅率**显著上涨。
- **预估影响**：一年累积订阅毛利增量约 **$26w**（All $261,902；iOS $254,330 / Android $7,571）。
- iOS：Onboarding 订阅率 +14% → 整体订阅率 +5%；ARPU +4.4%（试用年 SKU 倾斜，付费转化略降但 ARPPU 升）。
- Android：Onboarding 订阅率 +9% → 整体订阅率 +6%；ARPU 不显著 +2.2%。
- 国家：美英优于巴西（巴西订阅率无明显波动）。
- **建议**：全量实验组。启明：experiment/11425、11424。

## 需求要点

- onboarding 约占全站收入 13%；上期精简权益/突出试用曾带来订阅成功人数 +12.3%、收入 +5.8%。
- 实验组：视觉升级、循环 banner、试用开关默认开、按钮 Try for $0.00 / Unlock Pro、促销态替换为折扣横幅。
- V8.13.0 有对应「代码删除：Onboarding 订阅页优化实验」条目（全量后清实验代码）。

## 关联

- [[sources/2026-experiment-summary|2026 实验分析汇总]]
- [[sources/2026-versions-index|2026 版本索引]]
- [[concepts/ab-experiment-review|AB 实验复盘模式]]

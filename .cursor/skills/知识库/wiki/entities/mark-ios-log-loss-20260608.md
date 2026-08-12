---
title: iOS 日志丢失 20260608
type: entity
tags: [marks, data-quality, dau, dnu, ios, deprecated-attribution]
created: 2026-06-22
updated: 2026-06-23
sources: ["raw_data/北斗标注/marks_merged.json", "raw_data/知识库/manual/20260623-iOS日志丢失已修复-归因停用.md"]
---

2026/06/08 北斗 marks：**6月9日–6月17日 iOS 部分日志丢失，大数据已修复底层活跃表和新增表**（标注人：郭庆丽）。

> **状态（2026-06-23）**：问题**已修复**。**后续周报不得**用本条解释 DAU 波动。详见 [[sources/manual-ios-log-loss-resolved-20260623|归因停用说明]]。

## 出现图表

- DAU（10015816 / 89122）

## 历史口径（仅复盘 6/9–6/17 重叠周）

- 影响时段约 **6/9–6/17**，涉及 iOS 端活跃与新增底层表
- 与上述窗口重叠的历史周（如 0608～0614、0615～0621 部分时段），可作**历史数据口径说明**，须标注「历史修复窗口」，**不宜**作为修复完成后的当周主因

## 归因停用规则

- **禁止**：修复完成日（约 6/17）之后的分析周，将「iOS 日志丢失 / 修复窗口 / 底层表口径扰动」写入 DAU 知识库命中或逻辑链
- **替代**：DAU 波动从下钻贡献、节假日、发版/运营活动等业务因素解释

## 关联

- [[sources/manual-ios-log-loss-resolved-20260623|iOS 日志丢失已修复 — 归因停用]]
- [[entities/mark-save-tracking-loss-20260609|上报埋点丢失 20260609]]
- [[sources/beidou-marks-merged|Marks 索引]]
- [[concepts/beidou-marks-attribution|Marks 归因]]

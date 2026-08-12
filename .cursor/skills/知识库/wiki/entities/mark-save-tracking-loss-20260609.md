---
title: 上报埋点丢失 20260609
type: entity
tags: [marks, data-quality, save, deprecated-attribution]
created: 2026-06-22
updated: 2026-06-26
sources: ["raw_data/北斗标注/marks_merged.json", "raw_data/知识库/manual/20260626-上报埋点丢失已恢复-归因停用.md"]
---

2026/06/09 北斗 marks：**上报埋点丢失**（标注人：许赟晖）。**6/9 起上报埋点丢失，6/18 已恢复**。

> **状态（2026-06-26）**：埋点上报**已恢复**（6/18）。**后续周报不得**用本条解释保存量 / 保存率波动。详见 [[sources/manual-save-tracking-recovered-20260626|归因停用说明]]。

## 出现图表

- 保存 UV（10015697 / 88125）

## 历史口径（仅复盘 6/9–6/18 重叠周）

- 影响时段 **6/9–6/18**：保存相关埋点上报口径异常
- 与上述窗口重叠的历史周（如 0608～0614、0615～0621 部分时段），可作**历史数据口径说明**，须标注「历史修复窗口」，**不宜**作为 6/18 恢复后的当周主因

## 归因停用规则

- **禁止**：6/18 恢复完成之后的分析周，将「上报埋点丢失 / 埋点修复窗口 / 保存埋点口径扰动」写入保存量/保存率知识库命中或逻辑链
- **替代**：保存波动从下钻贡献（国家、平台、功能保存率）、节假日、发版/运营活动等业务因素解释

## 关联

- [[sources/manual-save-tracking-recovered-20260626|上报埋点丢失已恢复 — 归因停用]]
- [[entities/mark-ios-log-loss-20260608|iOS 日志丢失 20260608]]
- [[sources/beidou-marks-merged|Marks 索引]]
- [[concepts/beidou-marks-attribution|Marks 归因]]

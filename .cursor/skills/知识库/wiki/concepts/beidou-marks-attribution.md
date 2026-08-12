---
title: 北斗 Marks 归因
type: concept
tags: [beidou, marks, attribution, weekly-report]
created: 2026-06-17
updated: 2026-08-03
sources: ["raw_data/北斗标注/marks_merged.json", "raw_data/知识库/manual/20260623-iOS日志丢失已修复-归因停用.md", "raw_data/知识库/manual/20260626-上报埋点丢失已恢复-归因停用.md", "memory/归因思路.md"]
---

北斗看板 marks（标注线）是 AI 周报 v2 **知识库命中事件**的最高优先级来源。

## 数据流

```
知识库地址.csv → fetch_marks.py → raw_data/北斗标注/marks_merged.json → 本 Wiki
                                                      ↓
                              Agent v2 归因「知识库命中事件」
```

## 匹配规则

1. **时间段重合**：mark 日期落在分析周或相邻周
2. **国家/地区一致**：标注内容提及的国家与下钻贡献国家吻合
3. **功能相关**：smooth、relight、支付限制、补量 campaign 关停等与指标变动方向可建立逻辑链
4. **历史同期**：可参考往年同 mark 的表现（如母亲节）

## 优先级

| 级别 | 来源 | 示例 |
|------|------|------|
| 1 | marks | relight 荷兰冲榜、尼日利亚 smooth、**美国 KOL Relight（6.26–7.5）**、**巴墨补量关停（20260708）**、上报埋点丢失 |
| 2 | 历史周报 / 增长月会 | 20260616 双周会；[[sources/20260721-jun-jul-growth-review\|6-7月增长月会]] |
| 3 | 节假日 | 巴西情人节、六月节 |
| 4 | 产品需求 | V8.10.0～V8.15.0 上线 |

## 写法模板

> 知识库命中事件：
>
> - {事件名}，出处：marks标记（{yyyyMMdd}），命中原因：时间段重合，事件描述：{内容}

## 归因停用 Marks

以下 marks **不得**再用于解释对应指标波动（修复/恢复完成之后）：

| Mark | 停用自 | 指标 | 说明 |
|------|--------|------|------|
| [[entities/mark-ios-log-loss-20260608\|iOS 日志丢失 20260608]] | 2026-06-23 | DAU | 6/9–6/17 修复窗口；见 [[sources/manual-ios-log-loss-resolved-20260623\|归因停用说明]] |
| [[entities/mark-save-tracking-loss-20260609\|上报埋点丢失 20260609]] | 2026-06-26 | 保存量/保存率 | 6/9–6/18 修复窗口；见 [[sources/manual-save-tracking-recovered-20260626\|归因停用说明]] |

## 当前已入库 Marks

见 [[sources/beidou-marks-merged|北斗 Marks 标注索引]]（**16 条 / 10 事件**，含巴墨补量关停）。

## 关联

- [[concepts/ai-weekly-report-pipeline|AI 周报流水线]]
- [[concepts/core-business-metrics|核心业务指标]]

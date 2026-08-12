---
title: 巴西墨西哥补量 campaign 关停 20260708
type: entity
tags: [beidou, marks, brazil, mexico, channel, campaign, retention, dnu, 20260708]
created: 2026-08-03
updated: 2026-08-03
sources: ["raw_data/北斗标注/marks_merged.json"]
---

北斗 DNU 标注：**陆续关停巴西和墨西哥用于补量的 campaign（因留存表现较差）**。

| 字段 | 值 |
|------|-----|
| 标注日期 | 2026-07-08 |
| 内容 | 陆续关停巴西和墨西哥用于补量的campaign（因留存表现较差） |
| 标注人 | 郭庆丽 |
| 图表 | DNU（dashboard 10015834 / chart 89255） |

## 归因用法

- **窗口**：分析周覆盖 **7/8～7/9 及之后**，可解释巴西/墨西哥**渠道** DNU 回落、新增次留结构改善
- marks 明确覆盖 **巴西 + 墨西哥**；业务手工知识此前侧重巴西（起点 **7/9**），见 [[entities/br-refill-campaign-winddown-20260709|巴西补量关停]]
- 表述用「陆续关停 / 逐步收缩」，勿写单日全关；与 [[entities/google-br-campaign-iran-vpn-20260629|Google BR 误触伊朗]] 区分

## 关联

- [[sources/beidou-marks-merged|北斗 Marks 标注索引]]
- [[concepts/beidou-marks-attribution|北斗 Marks 归因]]
- [[sources/manual-br-campaign-iran-vpn-20260714|巴西补量关停手工知识]]
- [[sources/20260721-jun-jul-growth-review|6-7月增长月会复盘]]

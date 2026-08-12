---
title: 北斗 Marks 标注索引
type: source
tags: [beidou, marks, attribution]
created: 2026-06-17
updated: 2026-08-11
sources: ["raw_data/北斗标注/marks_merged.json"]
---

北斗 OCI 看板图表 marks（标注线）合并导出，供 [[concepts/beidou-marks-attribution|周报归因]] 优先引用。

**原始文件**：`raw_data/北斗标注/marks_merged.json`  
**提取脚本**：`计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py`  
**网关**：CSV `网关=oci` → `beidou-voyager.pix-int.com`  
**2026-08-11 拉取**：仍为 **16 条 / 10 事件**；文案与实体映射**无新增**（上次 +1 为 20260708 巴墨补量关停）。

### 本次拉取

无新增 mark；`marks_merged.json` 哈希变更可能来自 API 元数据（`updateTime` 等），归因清单不变。

## 覆盖图表

| 指标 | dashboardId | chartId | marks 数 |
|------|-------------|---------|----------|
| DAU | 10015816 | 89122 | 3 |
| 活跃次留 | 10015816 | 90629 | 2 |
| DNU | 10015834 | 89255 | **6**（+1） |
| 新增次留 | 10015834 | 90267 | 3 |
| 日均订阅毛利 | 10015810 | 89046 | 1 |
| 保存 UV | 10015697 | 88125 | 1 |

## 标注清单（按日期）

| 日期 | 内容 | 标注人 | 关联指标 | 实体页 |
|------|------|--------|----------|--------|
| 2026/03/31 | 俄罗斯iOS支付限制升级 | 郭庆丽 | 日均订阅毛利 | [[entities/mark-russia-ios-payment-20260331\|俄罗斯 iOS 支付限制]] |
| 2026/04/17 | relight🔥带动荷兰iOS冲榜第1 | 郭庆丽 | DNU、新增次留 | [[entities/mark-relight-netherlands-20260417\|Relight 荷兰冲榜]] |
| 2026/04/23 | 尼日利亚smooth功能带动 | 郭庆丽 | DAU、活跃次留、DNU、新增次留 | [[entities/mark-nigeria-smooth-20260423\|尼日利亚 Smooth]] |
| 2026/05/09 | 母亲节 | 郭庆丽 | DAU、活跃次留 | [[entities/mark-mothers-day-20260509\|母亲节]] |
| 2026/05/21 | relight带动乌克兰、哈萨克斯坦、白俄罗斯、波兰、德国新增 | 郭庆丽 | DNU、新增次留 | [[entities/mark-relight-eastern-europe-20260521\|Relight 东欧新增]] |
| 2026/06/02 | relight带动意大利、马来西亚、美国新增 | 郭庆丽 | DNU | [[entities/mark-relight-us-it-my-20260602\|Relight 美意马新增]] |
| 2026/06/08 | 6月9日–6月17日iOS部分日志丢失，大数据已修复底层活跃表和新增表，但其他功能埋点丢失 | 郭庆丽 | DAU | [[entities/mark-ios-log-loss-20260608\|iOS 日志丢失]] |
| 2026/06/09 | 上报埋点丢失 | 许赟晖 | 保存 UV | [[entities/mark-save-tracking-loss-20260609\|上报埋点丢失]] |
| 2026/06/24 | 6.26-7.5日，美国KOL推广relight有带动自然新增 | 郭庆丽 | DNU | [[entities/mark-relight-us-kol-20260624\|Relight 美国 KOL]] |
| 2026/07/08 | 陆续关停巴西和墨西哥用于补量的campaign（因留存表现较差） | 郭庆丽 | DNU | [[entities/mark-br-mx-refill-campaign-winddown-20260708\|巴墨补量关停]] |

## 归因使用要点

- 匹配优先级：**marks > 历史周报 > 节假日 > 产品需求**（见 `memory/归因思路.md`）
- 匹配维度：时间段重合、国家/地区、功能相关
- **数据质量类 marks**（日志丢失、埋点丢失）优先于产品功能归因；已修复/恢复后按对应 manual 规则停用
- 同一 mark 可出现在多个 chart（如「尼日利亚 smooth」同时标在 DAU/DNU 图）
- **美国 KOL Relight**：仅解释 **6/26～7/5** 窗口内美国自然新增；窗口结束后写回落，勿与独立日混为一谈
- **巴墨补量关停**：解释 **7/8～7/9 起** 巴西/墨西哥渠道 DNU 回落；与手工 [[entities/br-refill-campaign-winddown-20260709\|巴西补量关停 7/9]] 交叉引用（marks 额外点明墨西哥）
- **欧洲 Relight 余温（手工）**：[[entities/relight-europe-spread-202606\|Relight 欧洲小幅传播 202606]] — 仅作 202606 欧洲次级辅因，勿与美国 KOL 混用、勿作英美巴主因

## 关联

- [[concepts/beidou-marks-attribution|北斗 Marks 归因]]
- [[concepts/core-business-metrics|核心业务指标]]
- [[concepts/ai-weekly-report-pipeline|AI 周报流水线]]

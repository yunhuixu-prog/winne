---
title: Wiki Log
type: overview
tags: [log]
created: 2026-06-17
updated: 2026-07-21
sources: []
---

# Wiki Log

## [2026-06-17] init | AI 周报知识库初始化
- Raw source: raw_data/知识库/
- Biweekly reports ingested (catalog): 10
- Version/experiment docs indexed: 366
- Pages created: schema, overview, index, concepts/*, entities/*, sources/*
- Total pages touched: 15
- Note: 366 篇版本/实验文档先做索引级 ingest，后续可按版本或实验名单篇深化

## [2026-06-17] ingest | 北斗 Marks 标注
- Raw source: raw/北斗标注/marks_merged.json（同步自 raw_data/北斗标注/）
- Marks ingested: 12 条（6 个独立事件 × 多图表）
- Pages created/updated: sources/beidou-marks-merged, concepts/beidou-marks-attribution, entities/mark-* (6)
- Updated: index.md, overview.md, schema.md, concepts/ai-weekly-report-pipeline, concepts/core-business-metrics
- Total pages touched: 11

## [2026-06-17] ingest | raw_data/知识库 Confluence 全量更新
- Raw source: raw_data/知识库/（4 个站点，412 文件）
- site_658377761: 双周会 10 期（保持索引）
- site_632691935: 版本/实验 366 篇（保持索引）
- site_658377754: **新增** 2026 分析报告 8 篇
- site_599276617: **新增** 2025 分析报告 20 篇
- Pages created: entities/confluence-2026-analysis-site, entities/confluence-2025-analysis-site, sources/2026-analysis-reports-index, sources/2025-analysis-reports-index, sources/20260616-may-growth-review, sources/2026-experiment-summary, sources/2025-experiment-summary
- Updated: index.md, overview.md, schema.md, concepts/ab-experiment-review
- Total pages touched: 12

## [2026-06-22] ingest | 北斗 Marks 更新（marks_merged.json 变更）
- Raw source: raw_data/北斗标注/marks_merged.json
- 新增事件: iOS 日志丢失（20260608）、上报埋点丢失（20260609）
- Pages created: entities/mark-ios-log-loss-20260608, entities/mark-save-tracking-loss-20260609
- Updated: sources/beidou-marks-merged, index.md, concepts/beidou-marks-attribution
- Total marks 条目: 14（8 个独立事件）
- Manifest baseline refreshed

## [2026-06-23] ingest | iOS 日志丢失已修复 — DAU 归因停用
- Raw source: raw_data/知识库/manual/20260623-iOS日志丢失已修复-归因停用.md
- Pages created: sources/manual-ios-log-loss-resolved-20260623
- Updated: entities/mark-ios-log-loss-20260608, concepts/beidou-marks-attribution, index.md, memory/归因思路.md
- Rule: 后续周报禁止用 iOS 日志丢失解释 DAU 波动
- Manifest baseline refreshed

## [2026-06-24] ingest | AirBrush 产品数据变动记录（xlsx）
- Raw source: raw_data/其他/Pixocial产品数据变动记录.xlsx → AirBrush sheet
- Markdown: raw_data/知识库/manual/airbrush-product-data-changelog.md, airbrush-holiday-calendar-2024-2026.md
- Pages created: sources/airbrush-product-data-changelog, concepts/airbrush-holiday-calendar
- Updated: index.md, schema.md, memory/归因思路.md（节假日按年对照）
- Extract script: 计算脚本/提取产品变动记录/extract_airbrush_changelog.py
- Manifest baseline refreshed

## [2026-06-24] refactor | 知识库独立为 sibling skill「知识库」
- Moved from 周报生成: raw_data/{知识库,北斗标注,其他}、wiki/、计算脚本/{check_wiki,提取cf,北斗mark,提取产品变动记录}
- 周报生成、月报生成 共用 `KB_SKILL_ROOT/wiki/`；`skill_paths.wiki_dir()` 已指向新路径

## [2026-06-26] ingest | 上报埋点丢失已恢复 — 保存归因停用
- Raw source: raw_data/知识库/manual/20260626-上报埋点丢失已恢复-归因停用.md
- 时间线: 6/9 起上报埋点丢失，6/18 已恢复
- Pages created: sources/manual-save-tracking-recovered-20260626
- Updated: entities/mark-save-tracking-loss-20260609, concepts/beidou-marks-attribution, index.md, memory/归因思路.md
- Rule: 6/18 恢复之后的分析周，禁止用上报埋点丢失解释保存量/保存率波动
- Manifest baseline refreshed

## [2026-06-26] ingest | 核心市场主要节日（美国/巴西/英国）
- Raw source: raw_data/知识库/manual/core-markets-major-holidays-us-br-uk.md
- Pages created: sources/core-markets-major-holidays-us-br-uk
- Updated: concepts/airbrush-holiday-calendar（分国节日表）, index.md
- 用途: 周报/月报核心国家（美/巴/英）节日归因；须按分析周年份查移动节日公历
- Manifest: 已写入 core-markets-major-holidays-us-br-uk.md 基线条目

## [2026-06-26] update | 巴西六月节细目（圣安东尼/圣约翰/圣彼得等）
- Raw: core-markets-major-holidays-us-br-uk.md（新增「六月节细目」整节）、airbrush-holiday-calendar-2024-2026.md
- 子节点: 6/12 情人节、6/13 圣安东尼、6/14～6/23 中段高峰、6/24 圣约翰（正日）、6/29 圣彼得；Corpus Christi 移动预热
- Updated: concepts/airbrush-holiday-calendar, sources/core-markets-major-holidays-us-br-uk
- 依据: 20260616 双周会（6/12～6/14 巴西 DAU 归因口径）

## [2026-06-30] ingest | 扩展九国主要节日
- Raw source: raw_data/知识库/manual/extended-markets-major-holidays.md
- Updated: raw_data/知识库/manual/airbrush-holiday-calendar-2024-2026.md（九国移动节点摘要）
- Pages created: sources/extended-markets-major-holidays
- Updated: concepts/airbrush-holiday-calendar, memory/归因思路.md（节假日 cross-link）
- 覆盖: 西班牙、澳大利亚、俄罗斯、墨西哥、德国、加拿大、荷兰、孟加拉、哥伦比亚
- Manifest baseline refreshed

## [2026-07-07] ingest | 更新知识库（CF 双周会 + 分析报告 + marks 快照）
- Raw sources: 19 files（`site_601943060` 2025 双周会 10 期；`site_658377761` 20260630；`site_658377754` H1 复盘/行业分析/实验汇总；`marks_merged.json` 快照刷新）
- Pages created: sources/20260630-biweekly-sync, 20260706-h1-growth-review, 20260629-imaging-industry-h1, 2025-biweekly-reports-index
- Updated: biweekly-reports-index, 2026-analysis-reports-index, 2026-experiment-summary, 20260616-biweekly-sync, beidou-marks-merged, confluence-biweekly-site, index.md
- Highlights: H1 OKR 89%（MAU -8% 主缺口）；6/30 巴西圣若昂节；8.10 Relight/Face 实验全量；iOS 订阅页曝光/横幅改造回对照
- Manifest baseline refreshed

## [2026-07-07] ingest | AirBrush 历史月度指标归因（PDF 提取）
- Raw sources: raw_data/知识库/manual/airbrush-overseas-activity-behavior-attribution.md, airbrush-monthly-business-metrics-attribution.md
- 来源 PDF: 海外活跃&行为指标波动情况说明、经营指标月维度数据变动原因（仅提取 AirBrush 部分）
- Pages created: sources/airbrush-overseas-activity-behavior-attribution, sources/airbrush-monthly-business-metrics-attribution, concepts/airbrush-historical-metric-attribution
- Updated: index.md, overview.md, concepts/core-business-metrics
- 覆盖: 活跃指标 2021-07~2025-06；经营指标 2021~2025-06（Paid Retention/VPU/ROAS/MRR/Bookings/NPU）
- Manifest baseline refreshed

## [2026-07-13] ingest | 更新知识库（marks + CF 重拉）
- Raw: `fetch_marks.py`（14 条/8 事件，无新日期）+ `提取cf文档.py`（4 站点，437 页；待 ingest 扫描 75 文件）
- Highlights: **Onboarding 订阅页优化（序号44）** 明显正向、预估一年订阅毛利 +~$26w；激励广告 Acne（5.22 全量）与 2 期 Skin Tone 结论刷新；Relight 法线打光复盘入库；版本索引扩至 V8.11.5～V8.15
- Pages created: sources/onboarding-subscribe-page-ab-v810, sources/relight-normal-lighting-review
- Updated: 2026-experiment-summary, 2026-versions-index, beidou-marks-merged, 2026-analysis-reports-index, index.md
- 其余 [new]/changed] 技术/代码删除类以 raw 为准，已纳入 manifest 基线

## [2026-07-13] sync | 更新知识库（月报前二次拉取）
- marks + CF 重跑：无实质正文变更（多为 _update_times / marks 快照刷新）
- Manifest baseline refreshed（494 文件）
- 随后重生成月报 202606 v2/v3（补 Onboarding、激励广告 Acne 举措）

## [2026-07-13] query | 0706～0712周报归因：独立日节后回落/巴西六月节后退潮/伊朗渠道脉冲回调
- 周期: 0706～0712；优先 marks>历史周报>节假日；命中独立日(7/4)节后、Festa Junina收尾持续退潮、wk27伊朗渠道脉冲

## [2026-07-14] ingest | 伊朗网络逐步恢复（手工知识）
- Raw source: `raw_data/知识库/manual/20260526-伊朗网络逐步恢复.md`
- Pages created: sources/manual-iran-network-recovery-20260526, entities/iran-network-recovery-20260526
- Updated: index.md, sources/20260616-may-growth-review（交叉引用起始日）
- 要点: **2026-05-26** 起伊朗网络逐步恢复；可用于 202605 下旬～202606 伊朗活跃/MAU 归因

## [2026-07-20] ingest | 更新知识库（marks + CF 重拉）
- Raw: `fetch_marks.py`（**15 条 / 9 事件**）+ `提取cf文档.py`（4 站点，**494** 页；扫描待 ingest 75 文件）
- **新 mark**：20260624「6.26-7.5 美国 KOL 推广 Relight 带动自然新增」（DNU）→ entities/mark-relight-us-kol-20260624
- **新双周会**：20260714（覆盖 0706～0712：独立日/六月节后回落、巴伊渠道回落、Onboarding +$26w 等）
- 版本索引扩至 **V8.12～V8.16**；多期需求复盘 / V8.14 需求正文以 raw 为准索引级收录
- Pages created: sources/20260714-biweekly-sync, entities/mark-relight-us-kol-20260624
- Updated: beidou-marks-merged, biweekly-reports-index, 2026-versions-index, beidou-marks-attribution, index.md
- Manifest baseline refreshed

## [2026-07-20] ingest | Relight 欧洲 6 月仍有小幅传播（手工知识）
- Raw: `raw_data/知识库/manual/202606-relight欧洲小幅传播.md`
- 要点：**2026-06** Relight 在欧洲仍有小幅传播（4～5 月余温）；作欧洲活跃/DNU/MAU 辅因，不作英美巴/全球主因；与美国 KOL Relight 分窗口
- Pages created: sources/manual-relight-europe-june-202606, entities/relight-europe-spread-202606
- Updated: mark-relight-eastern-europe-20260521, mark-relight-us-it-my-20260602, 20260616-may-growth-review, beidou-marks-merged, index.md
- Manifest baseline refreshed

## [2026-07-20] ingest | 美英巴父亲母亲节（补齐节日表）
- Raw: `core-markets-major-holidays-us-br-uk.md`、`airbrush-holiday-calendar-2024-2026.md`
- **新增**：美国/英国父亲节（6 月第 3 周日：06-16 / 06-15 / **06-21**）；巴西父亲节原已有（8 月第 2 周日）升入 wiki 总表；三国父母节对照专表
- **已有确认**：美/巴母亲节（5 月第 2 周日）、英 Mothering Sunday（3～4 月）
- Updated: concepts/airbrush-holiday-calendar, sources/core-markets-major-holidays-us-br-uk, index.md
- Manifest baseline refreshed

## [2026-07-20] ingest | 英国 TikTok 投放加码自 20260618（手工知识）
- Raw: `raw_data/知识库/manual/20260618-英国TikTok投放加码.md`
- 要点：**2026-06-18** 起逐步加大英国 TikTok 投放；可解释英国渠道新用户 / 英国 MAU / 英国渠道 DNU；可与 6/21 父亲节并列
- Pages created: sources/manual-uk-tiktok-spend-20260618, entities/uk-tiktok-spend-ramp-20260618
- Updated: sources/20260630-biweekly-sync, index.md
- Manifest baseline refreshed

## [2026-07-21] query | 0713～0719周报归因（巴西补量关停/独立日节后/次留重拉）
- Queried: entities/br-refill-campaign-winddown-20260714, entities/google-br-campaign-iran-vpn-20260629, sources/20260714-biweekly-sync, concepts/airbrush-holiday-calendar, sources/core-markets-major-holidays-us-br-uk
- Answer: 0713～0719 主因巴西补量陆续关停拉动渠道DNU/新增次留结构改善；独立日节后第二周解释美国侧偏弱；续订按2.8对照去年同期美国订阅毛利+6.85%。

## [2026-07-21] ingest | 历史商业化策略续订季节性
- Raw: raw_data/知识库/manual/20260721-历史商业化策略续订季节性.md
- Source: sources/manual-commercial-seasonality-renewal-20260721.md
- Entities: reshape-resize-freemium-202207, screenshot-intercept-cancel-recall-202308
- Updated: concepts/airbrush-historical-metric-attribution, index, overview
- Note: 22/7 Reshape·Resize 非巴西转付费、23/8 下旬截屏拦截&取消付费召回 → 当年新增大涨 + 每年同期续订抬升

## [2026-07-22] update | 巴西补量 campaign 关停起点更正 7/9
- Raw updated: `raw_data/知识库/manual/20260714-巴西补量关停与Google-BR误触伊朗.md`
- Correction: 补量陆续关闭起点 **2026-07-09**（非 7/14）；7/14 仅为双周会同步日
- Pages: entities/br-refill-campaign-winddown-20260709（主条）；entities/br-refill-campaign-winddown-20260714 → 重定向；sources/manual-br-campaign-iran-vpn-20260714、sources/20260714-biweekly-sync、index、uk-tiktok-spend-ramp 交叉链已改
- Manifest baseline refreshed



## [2026-08-03] ingest | marks + V8.13～15 + 6-7月增长月会
- Raw: `raw_data/北斗标注/marks_merged.json`；V8.13/14/15 版本目录与 P0/P1 需求；`site_658377754/20260721日【复盘】6-7月增长月会数据复盘.md`；`26年实验与分析汇总.md`（变更）
- Marks：**15→16 条 / 9→10 事件**；**新增** DNU「陆续关停巴西和墨西哥用于补量的campaign」（20260708）
- Pages created: sources/beidou-marks-merged（更新）, entities/mark-br-mx-refill-campaign-winddown-20260708, sources/20260721-jun-jul-growth-review, sources/v813-attribution-features, sources/v814-attribution-features, sources/v815-attribution-features
- Updated: concepts/beidou-marks-attribution, entities/br-refill-campaign-winddown-20260709, sources/2026-versions-index, sources/2026-experiment-summary, sources/2026-analysis-reports-index, index.md
- Light: `_update_times.json` 忽略；V8.14/15 技术·代码删除·底层先行仅在 versions-index 汇总；俄罗斯支付正文变更索引级
- Note: 未跑 `--write-baseline`（交父 agent）

## [2026-08-04] ingest | 巴西 7 月底恢复测试 campaign 投放（手工）
- Raw: `raw_data/知识库/manual/20260728-巴西恢复测试campaign投放.md`
- Pages: sources/manual-br-test-campaign-resume-202607, entities/br-test-campaign-resume-202607
- Updated: index.md, entities/br-refill-campaign-winddown-20260709（交叉链）
- Note: 业务确认 7 月底巴西恢复部分投放用于测试 campaign；与 7/9 补量关停区分，供 0727～0802 巴西渠道 DNU 归因

## [2026-08-11] ingest | 全量更新知识库（marks + CF + wiki）
- Raw: `fetch_marks.py` → marks **16 条无新增**；`提取cf文档.py` → site_632691935/658377754 等 **66 文件**待同步（含 V8.15～17、实验汇总、复盘子页）
- Pages created: sources/v816-attribution-features, sources/v817-attribution-features
- Updated: sources/beidou-marks-merged, sources/2026-experiment-summary（序号50～52、Magic全量B、Glowup全量）, sources/2026-versions-index（V8.16/17）, index.md
- Light: manual/*.md 与 `_update_times.json` 随 CF 批量拉取标记 changed，内容无结构性变更则未逐页重写；V8.11.5～13 复盘子页 raw 已落盘，wiki 按需 QUERY 读 raw
- Baseline: `--write-baseline` 已执行

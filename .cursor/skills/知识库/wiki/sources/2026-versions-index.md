---
title: 2026 版本与实验索引
type: source
tags: [versions, ab-experiment, index]
created: 2026-06-17
updated: 2026-08-11
sources: ["raw_data/知识库/site_632691935/structure.md"]
---

2026 年 AirBrush 版本需求 / AB 实验 / 复盘文档索引（`site_632691935`，2026-08-11 同步）。

## 近期版本（2026-08-11 同步）

| 版本 | 上线 | 归因相关要点 | Wiki |
|------|------|----------------|------|
| V8.10.0 | 6/8 | Onboarding 订阅页优化 AB；Relight 法线打光；**需求复盘已入库** | [[sources/onboarding-subscribe-page-ab-v810\|Onboarding]] / [[sources/relight-normal-lighting-review\|Relight]] |
| V8.11.0 | 6/17 | Face 子项排序、激励广告等；**V8.11.0 / Face 提拉 Pro / Repair 批量复盘** | — |
| V8.11.5 | 7/1 | Skin 功能顺序；**Relight 一级入口**（7/21 全量，见增长月会） | — |
| V8.12.0 | 7/8 | Hair 去碎发、Clean Skin、Body 多族裔 Auto、美国 3 天试用、iOS 年 SKU 月付 | — |
| V8.13.0 | 7/22 | **Retouch 效果**、**Skin Redness Fix**、**Acne/Concealer 匀肤 AB**；多族裔默认值；Relight 界面复盘 | [[sources/v813-attribution-features\|V8.13 归因功能]] |
| V8.13.5 | 7/30 | 俄罗斯 UID 会员体系、DukPay；账号体系支持俄罗斯支付（正文 7/20 有更新） | — |
| V8.14.0 | 8/5 | **Body 体态调整**、**Google 促销/多段优惠**、视频异步、视频 Face 排序；丰胸多人 | [[sources/v814-attribution-features\|V8.14 归因功能]] |
| V8.15.0 | 8/19 | Jawline Pro、**高 ARPU 周卡重启**、老用户升级订阅页 AB、Body 薄肌/顺序、Glowup 排序 AB、视频首页入口；Relight 打光灯/取消率（部分延至 9/2） | [[sources/v815-attribution-features\|V8.15 归因功能]] |
| V8.16.0 | 9/2 | **AI 打光灯**、Hair Silky Straight、Body Upper Arms、**巴西 Makeup/Filters 排序**、俄罗斯 DukPay | [[sources/v816-attribution-features\|V8.16 归因功能]] |
| V8.17.0 | 9/16 | CF 根页待补（空壳） | [[sources/v817-attribution-features\|V8.17 占位]] |

## V8.14 / V8.15 技术·代码删除（索引级，不单建 entity）

| 版本 | 类型 | 提及 |
|------|------|------|
| V8.14 | 代码删除 | 激励广告策略调整 2 期等 |
| V8.14 | 底层先行 | Face Head 畸变还原、GlowUp MTImageKit |
| V8.14 | 技术 | targetSdk 36、双端 SDK 调试、云端压缩/aigc 在线配置、Bokeh/Blur 智枢、Muscle MTImageKit、滤镜美妆魔法屋 |
| V8.15 | 代码删除 | Relight 一级入口 AB、AI 任务创建时机、Face 子项排序、Face 限免、保分页 camera 按钮 |
| V8.15 | 底层先行 | Jawline Pro |
| V8.15 | 技术 | aigcSDK 升级、EyeBrighten MTImageKit、Relight 素材依赖模型、订阅审核开关迁移 Black Admin |

## 常用主题

- 订阅：Onboarding、试用、分层、挽留 SKU、俄罗斯支付、**Google 促销/多段优惠**、**高 ARPU 周卡**
- 功能实验：Face / Relight（**AI 打光灯**）/ Skin（**Redness Fix**）/ Hair / Body（**体态调整**）/ 激励广告
- 技术：MTImageKit、素材中台、云端压缩（索引级）

具体实验结论优先查 [[sources/2026-experiment-summary|2026 实验分析汇总]]、[[sources/20260721-jun-jul-growth-review|6-7月增长月会]]；需求原文在 `raw_data/知识库/site_632691935/`。

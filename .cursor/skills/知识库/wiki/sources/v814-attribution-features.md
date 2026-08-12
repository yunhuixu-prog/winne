---
title: V8.14.0 归因相关功能（8/5）
type: source
tags: [versions, v8.14.0, body, google, promo, video, 20260805]
created: 2026-08-03
updated: 2026-08-03
sources:
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P0】功能新增：Airbrush Body 新增「体态调整」功能（Jamie）.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P0】Google支持促销优惠（忻恬）——仅Android.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P1】Google支持多段优惠 + 新用户优惠商品调整AB实验（忻恬）——仅Android.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P1】AB实验：Airbrush 视频Face模块子功能顺序调整（帅王）.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P1】体验优化：Airbrush视频模块接入异步处理能力—长线需求（思思）.md"
  - "raw_data/知识库/site_632691935/V8.14.0版本（8_5上线）🚩/【P2】功能新增：Airbrush Body 丰胸 Plus_Pro 支持多人（Zac）.md"
---

V8.14.0（**2026-08-05** 上线）归因相关 P0/P1 摘要。大量技术/代码删除/底层先行仅在 [[sources/2026-versions-index|版本索引]] 汇总，不单建 entity。

## P0 / P1（产品·商业化）

| 优先级 | 需求 | 归因提示 |
|--------|------|----------|
| **P0** | Body 新增「**体态调整**」（Jamie） | Body 使用率/打勾/保存；人像精修升级主叙事 |
| **P0** | **Google 支持促销优惠**（忻恬，仅 Android） | 接入自定义优惠，同一商品可多次促销；订阅转化/续费 |
| **P1** | Google **多段优惠** + 新用户优惠商品 AB（忻恬，仅 Android） | 「7 天试用 + 首年优惠」；Google 新用户订阅转化 |
| **P1** | 视频 Face 子功能顺序调整 AB（帅王） | 视频模块 Face 渗透/保存 |
| **P1** | 视频模块**异步处理**（长线，思思） | 视频保存转化；跨版本长线 |
| **P2** | Body 丰胸 Plus/Pro 支持多人（Zac） | Body 多人编辑渗透 |

## 版本目录要点

- 人像：体态调整、人体点 SDK、丰胸多人、面部提拉滑杆、Body AI 顺序
- 视频：异步处理、视频 Face 排序 AB
- 收入：Google 促销 / 多段优惠；活动期取消支付挽留（相关版本线）

关注指标：体态调整 → Body；促销/多段优惠 → Android 订阅收入；视频异步 → 视频打勾。OKR：MAU、订阅收入。

## 轻量汇总（不单建页）

- 代码删除：激励广告 2 期实验等
- 底层先行：Face Head 畸变还原、GlowUp MTImageKit 等
- 技术：targetSdk 36、双端 SDK 调试、云端压缩、Bokeh/Blur 智枢、Muscle MTImageKit、滤镜美妆魔法屋等

## 关联

- [[sources/2026-versions-index|2026 版本与实验索引]]
- [[sources/v815-attribution-features|V8.15.0 归因功能]]
- [[entities/confluence-2026-versions-site|2026 版本站点]]

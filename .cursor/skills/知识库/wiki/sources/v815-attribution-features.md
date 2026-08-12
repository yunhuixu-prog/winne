---
title: V8.15.0 归因相关功能（8/19）
type: source
tags: [versions, v8.15.0, relight, weekly-sku, body, crop, 20260819]
created: 2026-08-03
updated: 2026-08-03
sources:
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P0】功能新增：Airbrush Relight 新增 AI打光灯 功能（Zac）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P0】高ARPU市场周卡实验重启（大璐）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】老用户升级启动订阅页替换AB实验（忻恬）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】功能新增：Airbrush Crop新增「畸变还原」功能（思思）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】体验优化：Airbrush Relight 取消率优化（Zac）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】体验优化：Airbrush Body 功能应用顺序调整（Jamie）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】体验优化：Airbrush Body 新增 曲线-薄肌 功能（Jamie）.md"
  - "raw_data/知识库/site_632691935/V8.15.0版本（8_19上线）/【P1】AB实验：Airbrush Eraser 算法替换实验（Jamie）.md"
---

V8.15.0（**2026-08-19** 上线）归因相关 P0/P1 摘要。纯技术/代码删除见 [[sources/2026-versions-index|版本索引]]。

## P0 / P1（产品·商业化）

| 优先级 | 需求 | 归因提示 |
|--------|------|----------|
| **P0** | Relight 新增 **AI 打光灯**（Zac） | Relight 渗透/保存；扩大对 MAU 影响力（光影主叙事） |
| **P0** | **高 ARPU 市场周卡实验重启**（大璐） | 英/澳/加/德；对照年+月 vs 实验年+周；周价≈月价×0.65；看整体/年卡/周续费 |
| **P1** | 老用户升级启动订阅页 → Onboarding 页 AB（忻恬） | 老用户升级转化；审美疲劳假设 |
| **P1** | Crop「畸变还原」（思思） | Crop/畸变相关保存 |
| **P1** | Relight **取消率优化**（Zac） | Relight 任务取消/成功率 |
| **P1** | Body 应用顺序调整；曲线-**薄肌**（Jamie） | Body 打勾/保存；男性薄肌双滑杆 |
| **P1** | Eraser 算法替换 AB（Jamie） | Eraser 打勾/保存 |
| **P1** | 视频异步处理（长线，续） | 视频渗透长线 |

另有 P2：激励广告 3 期、Glow Up 排序、Body 人体点 SDK、大数据 SDK 等（索引级）。

## 版本目录要点

- 人像：Jawline Pro（底层先行）、畸变还原、Body 顺序/薄肌/人体点、Glowup 排序 AB
- 光影：AI 打光灯、Relight 取消率
- 视频：首页 Videos 入口 AB、异步长线
- 收入：周卡重启、老用户升级订阅页 AB

关注：AI 打光灯 → Relight；周卡 → 高 ARPU 订阅收入；Body/Jawline。OKR：MAU、订阅收入。

## 轻量汇总（不单建页）

- 代码删除：Relight 一级入口 AB、AI 任务创建时机、Face 子项排序、Face 限免、保分页 camera 按钮等
- 技术：aigcSDK 升级、EyeBrighten MTImageKit、Relight 素材依赖模型、订阅审核开关迁移等

## 关联

- [[sources/2026-versions-index|2026 版本与实验索引]]
- [[sources/v814-attribution-features|V8.14.0 归因功能]]
- [[sources/relight-normal-lighting-review|Relight 法线打光复盘]]
- [[entities/confluence-2026-versions-site|2026 版本站点]]

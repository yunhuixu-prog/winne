# 【P1】Google支持多段优惠 + 新用户优惠商品调整AB实验（忻恬）——仅Android

**页面ID**: 709005633

**路径**: V8.14.0版本（8_5上线）/【P1】Google支持多段优惠 + 新用户优惠商品调整AB实验（忻恬）——仅Android

---

**JIRA地址：**待补充

#### 前置项

| 模块 | 负责人 | 进度 | 备注 ||
| | 陈晶晶 | 已可接入 | 本期客户端/业务侧接入 Google 两段优惠商品 ||

#### 更改记录

| 更新时间 | 更新人 | 说明 | 备注 ||
| 2026.07.15 | 
 | 
 | 
 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景

- Google当前已支持同一订阅商品配置多段优惠，例如「7 天免费试用 + 首年优惠」。但我们现有能力仅支持单段优惠，无法同时向用户下发免费试用和首年优惠。

- 在接入分层实验时，我们发现：针对Google新用户，仅下发无免费试用的首年优惠，效果反而低于不下发优惠。主要原因是未下发优惠的用户仍可购买带免费试用的常态价格商品，而实验组用户进入无免费试用的首年优惠路径后，免费试用权益缺失，反而影响了转化。

- 因此，本期需要接入 Google 多段优惠能力，支持在同一商品上组合配置并下发「免费试用 + 首年优惠」等多阶段优惠，提升 Google 订阅优惠策略的灵活性和转化效果。

- 同时，本次需求计划将 Google 新用户的新手优惠升级为「7 天免费试用 + 首年优惠」的多段优惠方案，验证在保留免费试用转化优势的基础上，叠加首年价格激励，是否能够提升新用户订阅转化率和首年付费效率。

### 2、功能目标

| 需求 | 目标 ||
| 需求一：Google 多段优惠能力接入 | Google 商品支持「免费试用 + 一次性付款」及「免费试用 + 周期性付款」多段优惠。 ||
| 需求二：新用户优惠商品调整 AB 实验 | 验证 Google 新用户采用「7 天免费试用 + 首年优惠」后，是否在不显著损害首年实收与退款表现的前提下提升订阅转化。 ||

### 3、需求一：Google 多段优惠能力接入（通用能力）
**一、能力范围**

- 当前中台能力说明：。
- 平台范围：仅Google。
- 本期接入的优惠组合：第一段均为免费试用；第二段为一次性付款或周期性付款。优惠结束后进入商品原有的常态订阅代扣。
- 免费试用仅支持按天配置，即 N-day free trial；常态订阅周期仅需支持年、月、周。

**二、****商品辅助信息／付费说明文案**
以下为本期全部需支持的付费说明：

| 优惠组合类型 | 常态订阅周期 | 适用场景 | AirBrush 英文文案 | 参数说明 ||
| 免费试用 + 一次性付款优惠 | 年 | N 天免费试用 + 首年优惠 | Start with a %1$s-day free trial, then get your first year for %2$s. After that, %3$s/year. Cancel anytime. | %1$s = 免费试用天数；%2$s = 首年优惠价；%3$s = 常态年价 ||
| 免费试用 + 一次性付款优惠 | 月 | N 天免费试用 + 首月优惠 | Start with a %1$s-day free trial, then get your first month for %2$s. After that, %3$s/month. Cancel anytime. | %1$s = 免费试用天数；%2$s = 首月优惠价；%3$s = 常态月价 ||
| 免费试用 + 一次性付款优惠 | 周 | N 天免费试用 + 首周优惠 | Start with a %1$s-day free trial, then get your first week for %2$s. After that, %3$s/week. Cancel anytime. | %1$s = 免费试用天数；%2$s = 首周优惠价；%3$s = 常态周价 ||
| 免费试用 + 周期性付款优惠 | 年 | N 天免费试用 + 前 N 年优惠价 | Start with a %1$s-day free trial, then pay %2$s/year for the first %3$s year(s). After that, %4$s/year. Cancel anytime. | %1$s = 免费试用天数；%2$s = 优惠年价；%3$s = 优惠持续年数；%4$s = 常态年价 ||
| 免费试用 + 周期性付款优惠 | 月 | N 天免费试用 + 前 N 个月优惠价 | Start with a %1$s-day free trial, then pay %2$s/month for the first %3$s month(s). After that, %4$s/month. Cancel anytime. | %1$s = 免费试用天数；%2$s = 优惠月价；%3$s = 优惠持续月数；%4$s = 常态月价 ||
| 免费试用 + 周期性付款优惠 | 周 | N 天免费试用 + 前 N 周优惠价 | Start with a %1$s-day free trial, then pay %2$s/week for the first %3$s week(s). After that, %4$s/week. Cancel anytime. | %1$s = 免费试用天数；%2$s = 优惠周价；%3$s = 优惠持续周数；%4$s = 常态周价 ||

### 4、需求二：新用户优惠商品调整 AB 实验（多段优惠首个应用场景）
**实验方案**

| 项目 | 方案 ||
| 实验对象 | Google端、命中分层ID=10005的用户 ||
| 对照组 | 线上常态新用户优惠商品：连续包年（首年8折）+ 连续包月/连续包周
 ||
| 实验组1 | 连续包年（7天免费试用+首年8折）+ 连续包月/连续包周 ||
| 实验组2 | 新用户不下发特殊分层商品（无新用户优惠） ||

### 5、统计需求

### 6、翻译需求

| 英文 | 简中 ||
| Start with a %1$s-day free trial, then get your first year for %2$s. After that, %3$s/year. Cancel anytime. | 先享受%1$s天免费试用，首年仅需%2$s。之后%3$s/年。可随时取消。 ||
| Start with a %1$s-day free trial, then get your first month for %2$s. After that, %3$s/month. Cancel anytime. | 先享受%1$s天免费试用，首月仅需%2$s。之后%3$s/月。可随时取消。 ||
| Start with a %1$s-day free trial, then get your first week for %2$s. After that, %3$s/week. Cancel anytime. | 先享受%1$s天免费试用，首周仅需%2$s。之后%3$s/周。可随时取消。 ||
| Start with a %1$s-day free trial, then pay %2$s/year for the first %3$s year(s). After that, %4$s/year. Cancel anytime. | 先享受%1$s天免费试用，前%3$s年每年%2$s。之后%4$s/年。可随时取消。 ||
| Start with a %1$s-day free trial, then pay %2$s/month for the first %3$s month(s). After that, %4$s/month. Cancel anytime. | 先享受%1$s天免费试用，前%3$s个月每月%2$s。之后%4$s/月。可随时取消。 ||
| Start with a %1$s-day free trial, then pay %2$s/week for the first %3$s week(s). After that, %4$s/week. Cancel anytime. | 先享受%1$s天免费试用，前%3$s周每周%2$s。之后%4$s/周。可随时取消。 ||
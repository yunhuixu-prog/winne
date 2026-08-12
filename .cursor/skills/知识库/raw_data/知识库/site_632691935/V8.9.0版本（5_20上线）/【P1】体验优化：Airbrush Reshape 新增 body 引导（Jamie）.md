# 【P1】体验优化：Airbrush Reshape 新增 body 引导（Jamie）

**页面ID**: 685226428

**路径**: V8.9.0版本（5_20上线）/【P1】体验优化：Airbrush Reshape 新增 body 引导（Jamie）

---

#### JIRA地址：

| 模块
 | 

1202
incomplete
翻译需求

 | 

1203
incomplete
隐私整改

 | 

1204
incomplete
UI

 | 

1205
incomplete
特效

 | 

1206
incomplete
AR

 | 

1207
incomplete
素材

 | 

1208
incomplete
前端

 | 

1209
complete
服务端

 | 

1210
complete
底层

 | 

1211
complete
iOS

 | 

1212
complete
Android

 | 

1213
complete
测试

 ||

#### 前置项

| 模块
 | 负责人|到期时间
 | 进度
 | 备注
 ||
| 
 | 
 | 
 | 
 ||

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026.04.15 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | Photo &rarr; Retouch &rarr; Reshape、Body（两模块配合，非新建） ||
| 涉及第三方业务/APP | 否 ||

## 一、需求背景
为什么要做：

- 场景篇用户研究结论：稳定活跃用户在 Reshape&harr;Smooth 之间形成了最高频的精修迭代路径（全局相邻操作 Top 1），但 Body 作为相邻的身材精修能力，在所有用户类型的路径中几乎没有出现&mdash;&mdash;**Body 不是用户不要，是用户没从 Reshape 连过去**。
- Body 功能自身数据健康，但入口曝光不足：
- 日均进入 UV 68k，进入率仅 7-10%（vs Reshape 32%）
- 进入后转化优秀：打勾率 82.4%、保存率 72.3%
- 订阅归因：订阅页进入 192k/月、付费率 2.09%、贡献 $52k/月

- 场景篇 P2 建议原文：*&quot;用户已经用 Reshape 调完脸型，顺势推荐「要不要顺便调一下身形？」&quot;*
- 承接 Q2 规划：6 月主题「身材/体态调整（巴西重点）」，提前在 4-5 月把 Reshape&rarr;Body 链路铺好，等 6 月新能力上线时流量能直接承接。

用户反馈/调研：

- 场景篇：Body 进入率在各用户类型中都偏低，但进入后转化不差（稳定用户打勾率 84.2%），说明是入口问题而非需求问题。
- 流失原因分析：UA 素材 AI tattoo / body edit 在巴西已验证是 winning theme，说明身材精修的外部需求强、内部承接不够。

竞品情况：

- Facetune / Facetlab 在完成脸型精修后，普遍会在结果页或编辑主入口引导用户进入身型精修能力，场景化编辑已是行业常规做法。

**需求定性**

| 

255
complete
用户反馈/调研

256
incomplete
公司/产品战略

257
complete
自己灵感/推演

258
incomplete
竞品跟进

259
incomplete
运营推广

260
incomplete
技术研发

261
incomplete
老板提的

262
incomplete
我党提的

263
incomplete
用户合规

 | 

265
complete
基础优化

266
incomplete
人有我有（参考x产品）

267
incomplete
人有我优（参考x产品）

268
incomplete
美图独创

 | 

269
complete
全体适用

270
incomplete
小白用户

271
incomplete
中端用户

272
incomplete
高端用户

 | 
 | 

273
incomplete
高频

274
complete
中频

275
incomplete
低频但刚需

276
incomplete
低频非刚需

 | 

283
complete
不提升复杂度

284
incomplete
化繁为简

285
incomplete
略微提升复杂度

286
incomplete
大大提升复杂度

 | 

293
incomplete
基础型：必备，缺失会引起不满

294
complete
期望型：做越多，用户越满意

295
incomplete
惊喜型：缺失不会引起不满，一但具备会显著提升满意度

296
incomplete
不关心型：无论是否具备，用户都不关心，可做可不做

297
incomplete
负向型：具备了会引起不满

 | 

287
incomplete
不产生口碑传播

288
complete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标

## 三、预估投入工时

| 职能 | 设计 | 前端 | 服务端 | 中间架构 | iOS | android | 测试 | 总 ||
| owner | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 工时/人天 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||

## 四、原型流程图

## 五、需求描述
1、需求内容
在 Reshape 完成一次有效调整后，于编辑器主画面 banner 推荐「顺便调一下身形」，引导用户进入 Body 功能。不新增功能、不改变 Reshape 和 Body 自身能力，仅是跨模块推荐。
**【触发条件】**

- 用户在 Reshape 内至少调整过（有实际编辑行为）
- 点击「&radic; 」时，当前结果与进入 Reshape 时的初始状态存在差异

- 使用的图片为 **含身体部位图片（单人body场景用的skin检测）**
- 用户点击「&radic; 」确认回到编辑器主画面时触发
- 仅在本次编辑 session 内第一次 Reshape 完成时触发
- 若用户在最近 3 次内都**主动点击打x**，则在最近一个月内不再弹出

- 若用户本次 session 内已经进入过 Body，不再触发

**【展示规则】**

- 位置：编辑器主画面底部浮层（Retouch tab 上方），非全屏、非弹窗、非遮挡主画布
- 展示时机：编辑器主画面恢复显示后 200-300ms 延迟出现
- 文案（待翻译确认）：**&quot;Try Body to shape your full figure&quot; **+ 进入 Body 的 CTA 按钮「Open Body」
- 展示时长：6 秒后自动消失；期间用户有以下其他操作也消失
- 进入其他 tab、点击其他工具、保存、返回；
- 单纯的画布手势不算

- 点击区域规则：

- 点 CTA 按钮 &rarr; 进入 Body
- 点 ✕ &rarr; 仅关闭浮层，本 session 不再展示
- 点 banner 正文区域（图标 + 文案）&rarr; 也算点 CTA，进入 Body（扩大有效点击区域，提升转化）
- 点 banner 之外的区域 &rarr; 不影响 banner，继续展示

**【交互流程】**

- 点击 CTA &rarr; 关闭浮层 &rarr; 直接打开 Body 功能（保留当前编辑中的图片与 Reshape 的编辑结果）
- 用户进入 Body 后的所有行为不受本需求影响（Body 原有逻辑不变）
- 用户从 Body 返回编辑器主画面时，**不再重复展示banner**（避免循环打扰）

**【黑后台 配置】**

- 支持全局开关（默认开启）
- 支持按国家开关（方便 Q2 巴西主推前后灵活调整）
- 支持按版本开关
- 支持配置文案（多语言）、CTA内容、Deeplink
- 文案、CTA 需求UI定义总字符长度限制

- 支持配置频次上限
- 同一用户跨 session 累计展示 N 次后不再展示（即使他从没主动关闭过）

**【异常处理】**

- Body 功能资源未下载完成：点击 CTA 走 Body 正常的加载流程（与用户从 tab 点击 Body 一致）
- Body 识别不到身体：由 Body 自身的兜底逻辑处理

**【多人脸／整体识别说明】**

- Reshape 操作人脸 A，推荐进入 Body 后，Body 默认用识别出来最大的人脸做人脸选中（Body 本身为单独的人脸框识别）

2、AB 实验方案
实验触发时机：进入reshape功能时

| 实验类型 | 客户端 AB 实验（对照 33% / 实验 33%） ||
| 对照组 | 维持线上现状 ||
| 实验组 | reshape 新增 body 引导推荐 ||
| 实验周期 | 14-30 天， ||
| 观测指标 | P0：Body 进入 UV、Body 保存率、Reshape 完成后直接保存比例、整体编辑完成率
P1：Body 订阅页进入、付费率、收入 $、$/千次进入 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

- Reshape &rarr; Body 跳转协议（保留当前编辑图片、保留 Reshape 已应用效果、进入 Body 的来源）

## 七、翻译
翻译文档link

## 八、埋点需求
**新增埋点字段：**

- **banner 展示曝光 **
- **banner 点击 CTA**：含 Reshape 调整强度值
- **banner 主动关闭**（✕ / Not now）
- **banner 自动消失**（未交互自动消失也需上报）
- **Body 进入来源标识**：source=reshape_banner
- **由banner进入后在 Body 内的行为**：打勾、保存、订阅页进入、订阅页点击、订阅成功（需可按 source 维度拆分）
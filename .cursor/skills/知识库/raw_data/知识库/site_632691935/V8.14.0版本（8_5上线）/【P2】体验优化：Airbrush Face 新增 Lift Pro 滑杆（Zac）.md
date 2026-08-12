# 【P2】体验优化：Airbrush Face 新增 Lift Pro 滑杆（Zac）

**页面ID**: 709004020

**路径**: V8.14.0版本（8_5上线）/【P2】体验优化：Airbrush Face 新增 Lift Pro 滑杆（Zac）

---

#### JIRA地址：link

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

#### 更改记录：

| 2026.07.14 | Zac | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 之前测试 Face 提拉 Pro 单向滑杆能力时，发现滑杆强度在 40-60 区间时，融合效果会出现轻微偏移，导致脸颊两侧出现融合线、眉眼清晰度降低等问题；其他数值区间基本正常。因此该能力此前未正式上线。当前 Face 提拉 Pro 支持档位滑杆调节，用户只能在固定档位之间选择，无法选择档位之间的中间强度，精细化调节能力有限。
- 

- 此次希望将 Face 提拉 Pro 由档位滑杆替代为单向滑杆，让用户可以在 0 到 100 之间自由调节提拉强度。

**需求定性**

| 

255
incomplete
用户反馈/调研

256
complete
公司/产品战略

257
incomplete
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
incomplete
全体适用

270
incomplete
小白用户

271
complete
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
incomplete
不提升复杂度

284
incomplete
化繁为简

285
complete
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
预计回收数据时间：8/28

| 

3001
complete
用户指标

 | 

3002
incomplete
预计可带来新增**万

3003
incomplete
留存提升**%

3004
complete
打勾率提升0.5%

3005
incomplete
新增子项使用量预估 ** 次/天

 ||
| 

3006
incomplete
收入贡献

 | 

3007
incomplete
高（日均收入5万以上）

3008
incomplete
中（日均收入1-5万）

3009
incomplete
低（日均收入低于1万）

3010
complete
不产生收入或者产生负向收入

1216
incomplete
收入预估：每月新增 $800

 ||

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

| 原型图 | 需求描述 ||
| 
 | **单向滑杆能力**

- 滑杆范围：0-100。

- 0 对应 Original，即回到原图 / 不应用 Face 提拉 Pro 效果。

- 100 对应最高强度 Face 提拉 Pro 效果。

- 用户可以停留在 0-100 之间的任意强度值。

- 每张图片首次请求 Face 提拉 Pro 时，默认强度沿用当前「中等」档位对应的强度值。

- 用户拖动单向滑杆时，画面应实时或准实时更新预览效果。

- 用户松手后，最终效果稳定应用到当前图片。

- 若底层仍需要重新投递生成效果，需明确拖动中预览与松手后最终生成的处理策略。

 ||

**新增 AB 实验**

| **组别 ** | **内容** | 流量 ||
| 对照组（线上） | 提拉 Pro 使用 「档位滑杆」（线上逻辑）
 | 33.3%
 ||
| Test A | 提拉 Pro 使用 「档位滑杆」
 | 33.3% ||
| Test B | 提拉 Pro 使用 「单向滑杆」
 | 33.3% ||
| 实验触发时机
 | 用户进入 Body 模块时
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | / ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=675221282](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
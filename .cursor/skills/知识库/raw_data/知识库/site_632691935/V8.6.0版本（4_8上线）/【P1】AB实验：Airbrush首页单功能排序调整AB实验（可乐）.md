# 【P1】AB实验：Airbrush首页单功能排序调整AB实验（可乐）

**页面ID**: 677152674

**路径**: V8.6.0版本（4_8上线）/【P1】AB实验：Airbrush首页单功能排序调整AB实验（可乐）

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
incomplete
服务端

 | 

1210
incomplete
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
| 2026.03.17 | 可乐 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
本需求会做3件事：弱化Camera曝光、下线Passport photo、强化Relight入口，原因如下
1、弱化Camera曝光：目前Camera在首页垂类第一位，但这个模块渗透仅3%左右，非Airbrush用户主心智功能，且Camera年久未更，能力已远落后于竞品，继续放在第一位不利于引导用户进入后快速使用满意度高的功能。
2、下线Passport photo：证件照在端内只有xx%的渗透，海外用户在这方面需求少，但服务端仍有一些维护成本，本次考虑下线。
3、强化Relight入口：Relight是目前被验证的除人像精修外，有潜力的差异化方向，且模块满意度高，为后续进一步扩大该功能的影响力，考虑外放入口，一方面尝试提升主编辑器保存率，另一方面为后续Relight新功能上线提供更好的曝光。
为控制变量，本次调整不改变其他单功能位置。

**需求定性**

| 

255
incomplete
用户反馈/调研

256
incomplete
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
incomplete
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
incomplete
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
incomplete
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
incomplete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
Relight功能进入率提升10%，首页垂类整体曝光点击率提升3%

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

## 四、需求描述
1、需求简述

| 对照组（当前线上） | 实验组A | 实验组B ||
| 第1行第1位：Camera
第2行第3位：Passport photo
 | 第1行第1位：Relight
第2行第3位：下线Passport photo，改为Camera
 | 第1行第1位：Face
第2行第3位：下线Passport photo，改为Camera
 ||
| 
 | 
 | 
 ||

2、实验设置

| 项目 | 说明 ||
| 实验类型 | 客户端实验 ||
| 实验触发时机 | 新用户首次进入首页、老用户升级后首次进入首页 ||
| 实验停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 

实验组说明
 | 对照组 | 当前线上状态 ||
| 实验组A | 第1行第1位：Relight
第2行第3位：下线Passport photo，改为Camera
 ||
| 实验组B | 第1行第1位：Face
第2行第3位：下线Passport photo，改为Camera
 ||
| 实验观察指标 | 1、首页垂类模块曝光点击率
（看首页垂类整体点击率是否有提升，同时对比换功能的位置的点击率是否有提升）
2、Relight、Face、Camera功能进入率、保存率
3、次日留存率、3日留存率
 ||
| 流量控制 | 初始流量各33%，后续根据数据和反馈评估 ||
| 测试周期 | 实验开启14天后结合数据表现开放最优实验组33%流量，如果实验组有收益扩全量
 ||
| 目标用户 | 全体用户（需要分国家分新老用户看数据，国家分：美、英、巴、其他）
 ||
| 实验预期 | 首页垂类模块整体曝光点击率提升、主编辑器打勾率提升、留存提升（至少不负向） ||

## 五、协议跳转
Relight单功能：点击-相选-进入Relight模块（不选中任何效果）-与当前主编辑器进入Relight模块逻辑一致
Face单功能：点击-相选-进入Face-Jaw模块（不选中任何效果）-与当前主编辑器进入Face模块逻辑一致

## 六、翻译
无

## 七、埋点需求
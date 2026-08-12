# 【P0】AB实验：Airbrush首页新增Videos入口AB实验（可乐）

**页面ID**: 707422947

**路径**: V8.15.0版本（8_19上线）/【P0】AB实验：Airbrush首页新增Videos入口AB实验（可乐）

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
| 2026.07.14 | 可乐 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
视频模块升级后，主要提升点在"进入后的保存转化"（51.9% &rarr; 55.16%，+3.26pp），而"视频进入渗透"仍有继续提升空间（4.3% &rarr; 4.67%，+0.37pp）。要提升视频模块渗透，需要在首页新增一个常驻入口同时提高视频模块推广效率。目前首页各个点位曝光点击率如下，结合过往经验（Tools放入满意度和功能覆盖面不如现有功能的情况下会拉低进入和满意度），本次主要调整projects点位。

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
预计回收数据时间：8月14日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
incomplete
预计可带来新增**万

300
incomplete
留存提升**%

1215
incomplete
打勾率提升**%

301
complete
视频模块渗透提升3%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
complete
不产生收入或者产生负向收入

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

## 四、需求原型图

## 五、需求描述

| 原型图 | 描述 ||
| 
 | 
- **入口变化**
- projects移动到settings左边，原projects位置改为videos

- projects页面内的设计、projects的红点逻辑均不变

 ||
| 
 | **首页videos入口**

- 点击右下角videos展开「视频相册页」如左图1，最新的在最右下角，视频排列逻辑和线上相册一致
- 不同授权状态下的视频相册页，对视频不同授权状态下的情况：
- 完全授权，如左1，上方可选择系统相册名
- 部分授权，如左2，右下角有add more按钮
- iOS：点击「Add more」拉起系统相册界面，点击「Change」跳转系统授权界面
- Android：安卓13及以上交互和完全iOS一致，安卓13以下不存在部分授权的情况，故没有add more这条路径

- 完全未授权：如左3，点击continue跳转系统设置页进行授权

不同授权情况下相关逻辑可参考之前的需求：[https://cf.meitu.com/confluence/pages/resumedraft.action?draftId=607593988&draftShareId=e2f60002-140b-4d90-8a93-e580f176915e&](https://cf.meitu.com/confluence/pages/resumedraft.action?draftId=607593988&draftShareId=e2f60002-140b-4d90-8a93-e580f176915e&)

- Videos入口支持小红点逻辑（点击后消失），服务端可配置（无需配置后台），本次暂不展示小红点（2周后再配置红点）

 ||

实验设置

| 项目 | 说明 ||
| 实验类型 | 客户端实验 ||
| 实验触发时机 | 首次进入首页 ||
| 实验停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 

实验组说明
 | 对照组A | 当前线上状态 ||
| 对照组AA | 当前线上状态
 ||
| 实验组 | 
- projects移动到settings左边
- 原projects位置改为videos入口

 ||
| 实验观察指标 | 1、视频模块使用渗透
2、订阅收入
3、新老用户留存
 ||
| 流量控制 | 初始流量各33%，后续根据数据和反馈评估 ||
| 测试周期 | 实验开启14天后结合数据表现开放最优实验组33%流量，如果实验组有收益扩全量
 ||
| 目标用户 | 全体用户（需要分国家分新老用户看数据，国家分：美、英、巴、其他）
 ||
| 实验预期 | 订阅收入不受影响，视频模块渗透上市，新增留存无负向 ||

## 六、协议跳转
无

## 七、翻译
无

## 八、埋点需求

| 埋点 ||
| 首页videos入口曝光/点击UV/PV ||
| 视频相册页不同授权状态UV/PV ||
| 视频相册页add more按钮曝光/点击UV/PV ||
| 视频相册页continue按钮曝光/点击UV/PV ||
| 视频相册页change按钮曝光/点击UV/PV ||
| projects新入口曝光/点击UV/PV ||
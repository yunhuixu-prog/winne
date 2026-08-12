# 【P2】其他：Airbrush Skin/Magic 新增埋点（Jamie）

**页面ID**: 701458887

**路径**: V8.12.0版本（7_8上线）🚩/【P2】其他：Airbrush Skin/Magic 新增埋点（Jamie）

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
| 2026.06.10 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

Skin、Magic、Face、Body 是 Retouch 的主流量来源，但现有埋点存在以下缺口，导致关键问题无法定位：

- Skin 滑杆值埋点缺失：
- Smooth、Concealer、Brighten 在保存（打勾）时未记录滑杆强度值，无法看到用户实际保存的强度分布。
- Concealer（打勾率 47%）、Brighten（51%）属于高进入、中等打勾率的功能，但缺少强度数据就无法判断其低转化是「默认强度不合适」还是「效果本身待优化」，也无法支撑 Smooth 等功能的默认强度调优。

- Magic 进入埋点缺失：
- Magic 为一键应用多效果（Smooth、Acne、Dark Circles、Whiten、Brighten、Tint）的功能，但自动应用的子项当前只有「打勾」埋点、没有「进入」埋点，导致 Magic 内部「进入&rarr;打勾」漏斗看不全，无法定位最常被用户取消 / 调整的子项

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
需求能带来多大的数据提升

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

本需求为埋点补齐，不涉及算法、UI 与交互改动，仅在现有事件上新增 / 补充所需位置的上报（具体事件名与字段由数据同学处理）。各模块所需埋点位置如下：

| **功能模块**
 | **埋点新增内容**
 | **所需位置**
 ||
| Skin
 | 三级子功能 新增 打勾滑杆强度值
 | 保存（打勾）
 ||
| Magic
 | 自动应用子项（Smooth / Acne / Dark Circles / Whiten / Brighten / Tint）新增进入事件，逐项可区分
 | 进入
 ||

**补充说明：**

- Skin 滑杆强度值口径与现有其他子项滑杆埋点保持一致，便于横向对比分布。

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
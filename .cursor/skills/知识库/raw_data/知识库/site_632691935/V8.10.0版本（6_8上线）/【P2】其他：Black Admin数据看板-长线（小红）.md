# 【P2】其他：Black Admin数据看板-长线（小红）

**页面ID**: 681970817

**路径**: V8.10.0版本（6_8上线）/【P2】其他：Black Admin数据看板-长线（小红）

---

#### JIRA地址：link

| （模块
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
| 2026.4.1 | 小红 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
运营数据接入黑后台展示，数据看板分为两期进行。

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
complete
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
incomplete
中端用户

272
incomplete
高端用户

 | 
 | 

273
complete
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
complete
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
complete
不产生口碑传播

288
incomplete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
提高运营数据查询效率

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
1、基础数据查询看板：首页弹窗、首页banner（单独）、首页banner分类、保分页，ID、name、缩略图对应数据展示。均需要UV、PV字段。看板字段如下：
Avg.daily⬇️

| Operation Type
 | Operation ID | Operation Name
 | Image | Avg.daily Exposure | Avg.daily Click | Avg.daily Exposure to Click CR | Avg.daily Sub Click | Avg.daily Sub Click to Success CR | Avg.daily Sub Click to Success CR | Avg.daily Sub Success to Paid | Avg.daily Sub Success to Paid Booking | Exposure (Total) | Click (Total) | Sub Success (Total) | Sub Success to Paid Booking(Total) ||
| Popup | HPO_0000000024
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| Banner | HOP_0000000024
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 保分页 | HSS_ | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| banner分类 | HOP_ATT_0000027 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||

Daily Data⬇️：需要折线趋势图，横坐标为日期，纵坐标为表格中字段（可支持筛选）

| Date
 | Operation Type
 | Operation ID | Operation Name
 | Image | Exposure | Click | Exposure to Click CR | Sub Click | Sub Click to Success CR | Sub Click to Success CR | Sub Success to Paid | Sub Success to Paid Booking ||
| 2026-05-05 | Popup | HPO_0000000024
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 2026-05-11 | Banner | HOP_0000000024
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 
 | 保分页 | HSS_ | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 
 | banner分类 | HOP_ATT_0000027 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||

| 
 | Avg.daily/ PV、UV | by Day / PV、UV ||
| 数据字段 | Exposure
Click
Exposure to Click CR
Sub Click 
Sub Click to Success CR
Click to Sub success CR
Sub Success to Paid 
Sub Success to Paid Booking
Exposure (Total)
Click (Total)
Sub Success (Total)
Sub Success to Paid Booking(Total)
 | Exposure
Click
Exposure to Click CR
Sub Click 
Sub Click to Success CR
Click to Sub success CR
Sub Success to Paid 
Sub Success to Paid Booking ||

2、按照业务需求展示趋势图、核心指标等数据

| benchmark看板
 | 分模块的曝光、点击、订阅benchmark | 
 ||
| 涨幅趋势 | 按照首页位置显示，根据筛选条件显示同比涨幅
类似⬇️
 | 
 ||
| 保分页
 | 按照二级功能 对应 保分页推荐banner、按钮的点击数据 | 
 ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
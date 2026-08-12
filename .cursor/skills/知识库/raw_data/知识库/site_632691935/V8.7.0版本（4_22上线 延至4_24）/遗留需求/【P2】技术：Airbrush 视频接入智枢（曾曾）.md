# 【P2】技术：Airbrush 视频接入智枢（曾曾）

**页面ID**: 673240774

**路径**: V8.7.0版本（4_22上线 延至4_24）/遗留需求/【P2】技术：Airbrush 视频接入智枢（曾曾）

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

| **更新时间**
 | **更改人**
 | **更改内容（变更用不同颜色mark）**
 | **备注**
 ||
| **2025.03.03** | **曾曾** | **创建文档**
 | 
 ||
| 
 | 
 | 
 | 
 ||

#### **涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）**

| **涉及模块** | 
 ||
| **涉及第三方业务/APP** | 
 ||

## **一、需求背景**
AB 视频模块计划近期接入视频中台，而视频中台的模型依赖智枢能力，因此需先完成智枢在 AB 端的接入前置工作。

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
/

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

| 原型图 | 功能详情说明 ||
| 
 | **交互流程--大部分follow视频中台已有交互**
Wi-Fi自动下载时

- 除内置功能外，连接Wi-Fi打开APP后，自动下载功能模型（功能范围均follow视频中台）
- 触发手动下载交互（自动下载未完成时）：
- 用户首次点击该功能，当前页面触发toast "The first use requires downloading. Please wait a moment.首次使用需下载，请稍后"（预计1-5s内）
- 并增加「转圈动画」
- 下载完成后进入该功能界面

无网络情况

- AI类功能：可进入功能，但不可使用，提示"This function requires an Internet connection for use"
- Wi-Fi自动下载功能：功能不置灰，点击后提示"Internet connection required for first-time use.首次使用需要连接互联网"

 ||

本地和需要下载的功能：待补充

## 六、翻译
翻译文档link

## 七、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
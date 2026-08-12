# 【P1】功能新增：Airbrush Hair新增去碎发（曾曾）--底层先行

**页面ID**: 698133599

**路径**: V8.11.0版本（6_17 端午版本）🚩/V8.11.0底层先行/【P1】功能新增：Airbrush Hair新增去碎发（曾曾）--底层先行

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

1215
incomplete
效果

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
 | 更改内容
 ||
| 2026.4.23 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**发质发量模块**作为头发产品矩阵中的核心功能板块，长期以来保持着较高的用户使用率和满意度，功能健康度表现良好，已形成稳定的用户心智和使用习惯。
随着用户对头发精细化修图需求的不断提升，碎发问题逐渐成为影响成片质感和自然度的常见痛点。
在此背景下，本次计划在发质发量模块中新增「云修-去碎发」功能**，通过智能识别与一键处理能力，帮助用户快速解决碎发困扰，提升修图效率与成片质量。此举不仅能进一步完善发质发量模块的功能闭环，增强用户粘性，更能强化产品在头发修图领域的差异化竞争力，巩固并扩大现有优势。

**需求定性**

| 

255
complete
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
incomplete
不产生口碑传播

288
complete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

**功能数据目标（勾选对应指标）**

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
incomplete
5-20万

1143
complete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

## 二、预估投入工时

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

## 三、原型流程图

## 四、需求描述
算法接口文档：

| 原型图 | 功能详情说明 ||
| 
 | 功能入口：Hair- Hair Enrich 
功能排序：Hydra gloss、Shiny、Smooth、**Sleek**（第四位）、Oil control、Thick、Volume、Hairline、Hair part
交互流程：

- 用户点击 Sleek 即进入loading流程（组件4）
- loading完成则返回结果图，undoredo和对比按钮高亮
- 未loading完取消/生成失败/网络错误，则选中上一个效果，若无上一个效果则选中none
- 同功能效果互斥，不同功能效果叠加（同线上）

其他调整：

- hair enrich增加小红点
- 增加new，用户点击后消失

订阅策略：

- 策略一，非会员限免 3 次，同hair 其他模块共用限免次数 3 次。

 ||

## 五、订阅相关
无

## 六、协议跳转
七、翻译

## 八、埋点需求
新增 Sleek 的pv/uv，曝光/点击/打勾/保存/订阅转化
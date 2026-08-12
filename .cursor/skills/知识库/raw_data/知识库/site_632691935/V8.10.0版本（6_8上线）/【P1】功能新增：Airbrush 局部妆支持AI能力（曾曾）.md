# 【P1】功能新增：Airbrush 局部妆支持AI能力（曾曾）

**页面ID**: 679593473

**路径**: V8.10.0版本（6_8上线）/【P1】功能新增：Airbrush 局部妆支持AI能力（曾曾）

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

1214
complete
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
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026.3.09 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Makeup 后续计划新增 AI 局部妆容能力。当前 AI 妆容采用整体替换逻辑实现，无法满足局部妆与其他妆容叠加使用的需求。为支持更灵活的组合化妆容体验，需对客户端能力进行升级改造，将现有替换逻辑调整为可叠加逻辑，实现局部妆容与其他妆效的兼容叠加使用。
**需求定性**

| 

255
incomplete
用户反馈/调研

256
incomplete
公司/产品战略

257
complete
自己灵感/推演

258
complete
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
complete
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
incomplete
期望型：做越多，用户越满意

295
complete
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
complete
5-20万

1143
incomplete
5万以下

1144
incomplete
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

## 四、原型流程图

## 五、需求描述
算法接口：

| 原型图 | 功能详情说明 ||
| 
 | 
- **功能入口：**Retouch**-**Makeup-**Lips**
- **素材样式：**icon上增加✨标
- **素材数量：**新增 2 款AI素材，增加new角标
- **素材名称：**
- 柔感杏仁 / Matte Nude
- 裸色水光 / Glaze 

- **功能排序：**排第一屏4-5位置
- **素材默认程度值：**100
- **交互流程：**

- 点击Ai局部妆，进入loading（组件二）
- 取消/超时/请求错误则停留当前页面，默认选中上一个妆容，若无上个妆容则选中none
- loading完成后返回结果图，默认滑杆100%（支持素材中台下发控制）

- **叠加/互斥逻辑：**
- 支持与其他不同类别素材妆容叠加（如blush、contouring）
- 与同类别（lips）为互斥逻辑
- 与AI 整妆互斥，与无眉互斥
- 不支持加入进mylook，具体交互followAI 整妆

- **多人脸逻辑**
- 仅支持单人脸，多人脸图片进入点击该效果则弹出toast "This effect only supports one person"

- **订阅策略：**
- 局部妆里AI效果：
1、非会员：局部妆AI效果（本期2个）走策略一，共享终身3次限免
2、会员：局部妆AI效果（本期2个）每日限免30次

- **其他**
- Lips Tab新增小红点，用户点击后消失

 ||

## 七、协议跳转
/

## 八、翻译
/

## 九、埋点需求

| 2个素材的 | 点击/打勾/保存/订阅的UV/PV ||
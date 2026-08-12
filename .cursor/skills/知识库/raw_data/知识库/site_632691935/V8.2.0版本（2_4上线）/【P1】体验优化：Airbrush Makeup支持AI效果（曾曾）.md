# 【P1】体验优化：Airbrush Makeup支持AI效果（曾曾）

**页面ID**: 660498500

**路径**: V8.2.0版本（2_4上线）/【P1】体验优化：Airbrush Makeup支持AI效果（曾曾）

---

#### JIRA地址：

| 模块
 | 

1202
complete
翻译需求

 | 

1203
incomplete
隐私整改

 | 

1204
complete
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
complete
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
| 2025.1.12 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | ||

## 一、需求背景

- 目前 AB 的彩妆效果主要通过素材贴图实现，在效率上具备优势，但在妆容与肤质的融合度和真实感上存在明显上限。结合用户行为观察，欧美用户对妆容效果的自然度与真实质感要求较高，真实度不足的妆容往往影响保存与分享意愿。同时，竞品已逐步通过 AI 方式提升妆容与面部的融合效果。基于此，有必要引入 AI 方式优化彩妆质感，以提升整体真实度与用户体验；

- 当前AB的美妆模块暂不支持AI方案，需要将将AI能力接入，以支撑后续的AI能力(巴西狂欢节)。
- 

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

| 

1189
incomplete
用户指标

 | 

299
incomplete
保存率

 | 
 | 
 ||
| 

280
incomplete
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

 | 
 | 
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

| 原型图 | 功能详情说明 ||
| 
 | **入口：Retouch - Makeup - Popular**
**视觉呈现：**
在AI美妆icon下增加「✨」角标（同AI滤镜）
**交互流程：**

- 进入Makeup-位置根据妆容类型而定
- 点击选择ai 美妆
- 若用户在app内未同意过AI云处理，则需要优先弹出云处理弹窗，用户同意后进入loading流程
- 若用户已经同意过云处理，则直接进入loading流程

- 进入loading流程，实时显示进度，点击「❌」可停止当前loading流程，停留在「None」中并保持选中
- loading完成后显示强度值和对比按钮，可调整强度值并实时看见强度变化
- 强度调整不重新走AI生成，采用原图与结果图混合形式
- 单个效果的默认程度值待设计师根据效果定义

- 按下对比按钮可与原图对比

- **互斥逻辑**

- AI 美妆不支持人脸点调整（因AI生成，调整后需要重新生成）
- AI美妆与其他妆容互斥，点击其他妆容则直接替换（含整妆/局部妆）
- AI美妆不支持增加进入my look，逻辑follow无眉：[https://cf.meitu.com/confluence/x/hU_hIw](https://cf.meitu.com/confluence/x/hU_hIw)
- 文案：This Effect is not supported in My Look

- **多人脸逻辑**

- AI美妆仅支持单人脸，在上传多人脸使用该效果时会进行拦截，并弹出toast：Not available for group photos

- **记忆逻辑**

- 在美妆面板中，已经加载过的效果，需要记忆，即切换其他妆容后再切换回来无需重新加载，离开面板（打勾/退出）后再次进入则不记忆，需要重新生成

 ||

3、订阅限免策略
0.004043 美元/单张
走策略2：[https://cf.meitu.com/confluence/x/oli4Iw](https://cf.meitu.com/confluence/x/oli4Iw)
保留当前线上逻辑（会员才能打勾/保存），同时预埋每天限免请求N次（覆盖98%用户的当天次数），非会员可预览效果，打勾会进行订阅拦截
非会员每日30次预览（不可保存），会员每日50次
👉控制AI成本，避开极端用户（刷效果的）

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求

| 埋点 | 指标 ||
| AI美妆的-曝光/点击/打勾/保存/订阅/取消 | pv/uv ||
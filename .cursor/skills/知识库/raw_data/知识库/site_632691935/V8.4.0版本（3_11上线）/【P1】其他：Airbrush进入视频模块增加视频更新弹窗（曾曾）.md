# 【P1】其他：Airbrush进入视频模块增加视频更新弹窗（曾曾）

**页面ID**: 669678420

**路径**: V8.4.0版本（3_11上线）/【P1】其他：Airbrush进入视频模块增加视频更新弹窗（曾曾）

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
| 2026.02.13 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
AB 视频模块已长期未进行版本更新，后续将统一接入视频中台，整体交互体验与功能都会有较大调整。为避免对用户使用造成影响，需通过弹窗形式提前告知用户相关变更。

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
 | 
- **标题**

New Video Experience Is Coming! 🎬
视频工具升级啦！ 🎬

- **文案**

Video Tools are getting a major upgrade with new features and a brand-new visual design. Stay tuned for the update!
视频工具将进行重大升级，具有新的功能和全新的视觉外观。敬请期待更新！

- **按钮**

Got It
知道了
**顶部UI图标样式**

- 摄影机样式📹

**弹窗响应时机**

- 弹出时机：升级版本在编辑器中进入了视频模块后弹出（含卸载重装）
- 弹出次数：每个进入视频模块的用户仅弹出1次（客户端做）
- 用户点击「got it」按钮后下次不再弹出
- 若用户未点击按钮，杀掉后台后重新进入则需要再次弹出直到用户点击按钮

- 弹出优先级：**本次升级弹窗**>其他弹窗

 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
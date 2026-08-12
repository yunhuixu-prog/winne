# 【P2】体验优化：Airbrush 创建AI分身增加黄图/涉政检测（曾曾）

**页面ID**: 646808737

**路径**: V8.0.0版本（1_7上线）/【P2】体验优化：Airbrush 创建AI分身增加黄图/涉政检测（曾曾）

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
| 2025.12.08 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
在以往版本中，AI 功能均在服务端处理阶段进行黄图 / 摄政检测，但这在部分功能中会产生体验问题。
以 **AI 分身** 为例：创建分身时当前未进行任何检测，因此用户可能基于不合规图片成功创建分身。
但在随后选择效果生成时，服务端才触发安全检测，导致生成失败、功能无法继续使用，用户还必须返回重新创建分身，严重中断整体体验。
为提升链路顺畅度，建议 **将分身的安全检测前置**：在用户选择图片并点击"创建分身"时即执行检测，确保内容安全，也能减少后续流程的失败率，提升分身创建与使用的连贯体验。
[https://doc.weixin.qq.com/sheet/e3_ARQA8QZwACQSGbe8ci20RSeuWSmG8?scode=ACIAJAeGAAgESdQSdBAdUAnwaPAHA&tab=41ij3h](https://doc.weixin.qq.com/sheet/e3_ARQA8QZwACQSGbe8ci20RSeuWSmG8?scode=ACIAJAeGAAgESdQSdBAdUAnwaPAHA&tab=41ij3h)
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
 | **交互流程**

- 点击「My AI avatar」进入分身上传图片流程
- 选择超过3张图片
- 同意云授权
- 点击「create」生成
- 进入黄图/摄政检测

- 检测通过，直接进入训练分身流程
- 检测不通过，且张数少于3张（最少张数）则：
- 自动去除不合格的图片，并弹出toast："Non-compliant images deleted. Please select and upload new ones."3s后渐隐消失

 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
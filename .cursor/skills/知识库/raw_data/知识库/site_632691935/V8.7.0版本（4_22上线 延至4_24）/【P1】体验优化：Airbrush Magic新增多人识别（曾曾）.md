# 【P1】体验优化：Airbrush Magic新增多人识别（曾曾）

**页面ID**: 679595807

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P1】体验优化：Airbrush Magic新增多人识别（曾曾）

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
incomplete
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
 | 更改内容
 ||
| 2026.3.17 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- Magic 模块是AB Top3使用的功能，但当前此模块不支持多人图片使用，收到较多的客诉
- 为了给用户带来更好的用户体验，故对 Magic 模块的多人识别算法进行新增、优化。

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
incomplete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
incomplete
5-20万

1143
incomplete
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

| xxxx算法接口 | 
 ||
| demo地址 | 
 ||
| 算法对接人 | 
 ||
| 效果设计师 | 
 ||

| 原型图 | 功能详情说明 ||
| 
 | **用户进入 Magic 功能，可支持单人、多人编辑**

- 进入 Magic 可对多人进行识别与编辑
- 单人逻辑与线上一致，无调整
- 无人像图片，不支持

**新增【人像切换】组件**

- 在 Magic 内新增人脸切换组件
- 用户点击人脸组件可切换不同人脸。
- 用户点击人脸组件，则弹出人脸框提示用户选择人脸，选中的人脸 人脸框高亮展示(默认选中占比最大的人脸，同线上 face 多人脸逻辑）
- 人脸选中后，再次点击人脸组件，人脸框消失（同线上 face 多人脸逻辑）
- 人脸框与效果编辑不互斥，可同时存在人脸框进行效果编辑。

- Magic 内效果，**多人脸统一上效果，但当用户切换人脸时，可针对单个人脸调节各个小项的参数**

**固化逻辑**

- 不固化，在同一面板下（未打勾情况下）切换人脸和调整的参数均需要记忆
- 支持人脸数量：同美妆，至多支持10人脸

**默认参数**

- follow当前 Magic默认参数不做默认值调整

**其他**

- 本次修改仅影响编辑器，相机不受影响，故相机需要和编辑器解藕，功能之间不互相影响

 ||

## 五、订阅相关
无

## 六、协议跳转
七、翻译

## 八、埋点需求
Magic多人脸的进入/打勾/保存
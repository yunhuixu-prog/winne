# 【P1】体验优化：Airbrush body模块滑杆统一（Jamie）

**页面ID**: 660501686

**路径**: V8.2.0版本（2_4上线）/【P1】体验优化：Airbrush body模块滑杆统一（Jamie）

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
| 2026.01.13 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- **当前 body 模块存在交互问题**：
- 背景保护与滑杆的位置布局不合理，占据编辑器画面过多。
- body 模块与 face 模块的滑杆交互不统一。且当前重置按钮与多人脸组件位置冲突，对于后续接入body支持多人会需要额外的 UI 改造。

| body 模块滑杆遮挡 | face 模块滑杆样式 ||
| 
 | 
 ||

**优化方案：**

- 降低整体组件画面遮挡占比
- 统一 face 与 body 模块的滑杆样式，且同时间预留人脸组件的接入空间，避免多人接入时同时间有算法、交互更改等多重变量。

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
1、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| 
 | **body模块交互优化**

- **统一滑杆长样式（同 face 模块）**
- 统一滑杆长度
- 调整并固定 背景保护、对比、重置按钮位置

- 因为要考虑是否有侦测到部位，期望是：

- 有侦测到slim的时候，分组默认选中【全身】，图标默认选中slim，滑杆值为0

- 没有检测到slim时，分组默认选中【全身】，无默认选中图标，滑杆无法滑动

- 若为从合集图标（如：丰胸）内回到body:
- 默认未选中图标，滑杆置灰

- 移除部分功能点击后叫出滑杆逻辑，全部改成 滑杆常置：
- 涉及功能：丰胸、丰胸plus、丰胸lite

- 影响功能

- 单向滑杆：长腿、天鹅颈、直角肩、丰胸-丰胸、丰胸-丰胸plus
- 双向滑杆：Auto、瘦身、瘦腰、瘦手臂、丰胸-经典丰胸、美跨、腿部、肩宽、小头

＊＊本次交互调整**不涉及**订阅限免策略调整
**＊＊＊线上对照组实验组都需实现**
 ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
ai效果（丰胸、收腹、丰臀）需加上成本埋点
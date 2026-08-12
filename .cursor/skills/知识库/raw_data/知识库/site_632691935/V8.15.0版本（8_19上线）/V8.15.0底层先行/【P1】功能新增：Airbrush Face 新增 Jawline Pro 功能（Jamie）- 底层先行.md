# 【P1】功能新增：Airbrush Face 新增 Jawline Pro 功能（Jamie）- 底层先行

**页面ID**: 710772479

**路径**: V8.15.0版本（8_19上线）/V8.15.0底层先行/【P1】功能新增：Airbrush Face 新增 Jawline Pro 功能（Jamie）- 底层先行

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
| 2026.07.28 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 在欧美审美中，下颌线清晰度是与吸引力、健康感、体型感知关联最强的面部特征之一；受体型、广角摄影等因素影响，照片中常出现男性下巴不明显的问题。欧美医美报告显示，男性 Jawline 需求逐年上升，一款以男性特点为主的下巴优化功能，能快速提升面部结构、实现自信提升，满足男性用户需求。
- 女性面临同样的下颌线不清晰、下巴内缩等问题，本功能同步满足女性需求，实现紧致的下巴效果，并注意男女的调整差异。
- 为此，本次在 Face-Jaw 内新增 Jawline Pro** 功能，重建下巴外轮廓，优化下巴与颈部连接处垂坠，强化骨骼特征，整体变化区域限制在下颌范围内，并支持多人脸与背景保护；同时为评估新增功能及其排序对 Jaw 原有子项使用数据的影响，本次将开展 AB 实验**，通过对比不同排序策略下的用户行为数据，确定最优上线方案。

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
预计回收数据时间：9/08

| 提升指标 | 具体数值 ||
| 

2000
complete
用户指标

 | 

2001
incomplete
预计可带来新增**万

2002
incomplete
留存提升**%

2003
incomplete
打勾率提升**%

2004
complete
Jawline Pro 使用量级预估：8000 次/天

 ||
| 

2009
complete
收入贡献

 | 

2005
incomplete
高（日均收入5万以上）

2006
incomplete
中（日均收入1-5万）

2007
complete
低（日均收入低于1万）

2008
incomplete
不产生收入或者产生负向收入

 ||

收入预估：每月新增200

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
1、涉及算法

| xxxx算法接口 | /v1/ai_jawlines_async

推理耗时：5s
成本：$0.005
 ||
| demo地址 | [https://insight-mtlab.meitu-int.com/doc/1102](https://insight-mtlab.meitu-int.com/doc/1102) ||
| 算法对接人 | 效果：张子锋
滑杆：黄李达
 ||
| 效果设计师 | 小孔 ||

2、需求内容

| 原型图 | 功能详情说明 ||
| 

 | **功能位置**

- Face - Jaw - Jawline Pro

**排序**

- 实验组B：Jaw 中末位（Jaw Shape 后一位）；
- 实验组BB：Jawline 后一位，具体见上方 AB 实验方案
- 进入 Jaw 默认选中项与线上保持一致

**功能交互流程**

- 首次进入 Jaw，在 Jawline Pro 下增加 New 角标，在 Jaw tab 下增加小红点，用户点击后消失
- 点击 Jawline Pro 后进入 loading 流程（组件3）
- 取消/超时/请求错误则停留当前页面，默认选中上一个子项，若无上一个则默认选中 Chin
- loading完成后返回结果图

- 滑杆逻辑：本地融合的无极滑杆，AI 结果图返回后，根据滑杆强度在端上对原图与结果图做实时融合，调节强度不重新发起请求、不重复扣减次数
- 滑杆默认值需效果/UI确认

- 整体交互、流程与现有 Face 内 Pro 功能（Tighten Pro / Sculpt / Double Chin Pro）保持一致

**多人脸**** AI 固化逻辑**

- 多人脸场景下，每张人脸的 AI 状态独立记录，互不影响；
- 当 A 人脸使用 Jawline Pro 或其他 AI 功能后：
- AI 结果仅对 A 人脸生效并固化；
- 切换至 B 人脸时，B 人脸仍保持原图状态。

- 若在 B 人脸继续使用 AI 功能：
- 则仅对 B 人脸生成新的 AI 结果并固化；
- 不影响 A 人脸已生成的结果。

- 同一人脸内，Jawline Pro 与其他 AI 功能（如 Sculpt / Double Chin Pro）共用 AI 固化链路，后续 AI 功能均基于当前最新结果图继续生成。
- Jawline Pro 切换人脸时，需重新请求，次数一样扣减。

**背景保护**

- 支持背景保护，形变仅作用于人像下颌区域，背景不产生形变、畸变

**底层效果逻辑**

- **若当前仅使用该 AI 效果，未叠加其他 AI 功能：**
- 当前 AI 效果不固化，不生成新的底图；
- 用户可继续与其他本地效果自由切换、实时调节；
- 该逻辑在跨 Tab 场景下同样生效，跨 Tab 返回该功能时，保留当前效果状态与滑杆参数，不重复触发 AI 生成；
- 后续本地效果均基于当前实时渲染结果进行预览，不生成新的底图。

- **若用户继续叠加使用其他 AI 功能（如 Double Chin Pro ）：**
- 使用其他AI功能并成功应用（返回了结果图）则当前结果图将被固化；
- 后续 AI 能力基于当前结果图继续生成；
- 所有本地子功能调节项均基于新的结果图进行调整；
- 效果固化后，再次使用 AI 功能时，需基于当前最新结果图重新发起生成；
- 该逻辑对多人脸场景同样适用。

**Undo/Redo：**暂不支持Undo/Redo（follow 线上 Pro 功能）

**订阅限免**

- Follow 线上 Pro 功能限免逻辑（非会员终身限免3次），具体以订阅同学确认为准

 ||

3、AB 实验方案

| **组别 ** | **内容** | 流量 ||
| 对照组ａ（线上） | Chin、Jawline、Jaw Angle、Length、Double Chin、Double Chin Pro、Jaw Shape | 33%
 ||
| 实验组ｂ | Chin、Jawline、Jaw Angle、Length、Double Chin、Double Chin Pro、Jaw Shape、**Jawline Pro** | 33% ||
| 实验组ｂｂ | Chin、Jawline、**Jawline Pro**、Jaw Angle、Length、Double Chin、Double Chin Pro、Jaw Shape | 33% ||
| 实验触发时机
 | 升级后首次进入「**Jaw**」
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率、Jaw 原有子项的使用数据
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | / ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有

- Face-Jaw-Jawline Pro 的：曝光、点击、打勾、保存、订阅收入 UV/PV
- 成本相关埋点：Jawline Pro AI 请求发起、成功、失败（含取消/超时）次数，用于核对算法成本；
- AB 实验分组上报：命中实验的用户上报所属分组（对照组ａ/实验组ｂ/实验组ｂｂ），以上指标均需支持按分组、分国家、分新老用户拆分
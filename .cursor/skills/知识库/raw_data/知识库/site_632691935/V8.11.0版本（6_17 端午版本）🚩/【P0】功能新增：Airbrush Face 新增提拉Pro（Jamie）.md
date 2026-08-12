# 【P0】功能新增：Airbrush Face 新增提拉Pro（Jamie）

**页面ID**: 697013699

**路径**: V8.11.0版本（6_17 端午版本）🚩/【P0】功能新增：Airbrush Face 新增提拉Pro（Jamie）

---

#### JIRA地址：link

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
complete
底层

 | 

1216
complete
效果设计师

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
| 2026.5.26 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 欧美人由于遗传学关系，皮肤老化相对亚洲人来说速度较快，通常30岁初期就常见明显皱纹。考虑到社会风气的转变，面部提拉（非手术）的需求逐年上升，在2025年的市场规模就达到的 $3.7B，市场的增长潜力看好。

- 欧美面部程度的提拉刚需，与面向亚洲的提拉需求不同，属于健康化人像修容。且美国本土约占40%的非手术提拉市场，因此，一款一键提升面部紧致度的提拉效果，能快速优化面部细纹、填充眼周、提亮皮肤光泽度，实现视觉化的颜值提升。重点著重在抚平用户纹路并年輕化嘴边肌理走向，进行纹路逆转与拉提，实现逆龄效果。*

*

- Lift 与超声刀对比

| **Face-Lift 拉皮**
 | 
 ||
| **U****ltherapy**** 超声刀**
** **
 | 
 ||

- 为此，新增面部提拉功能，实现肌肉走向的向上优化，并同步修饰面部凹陷、皱纹，达成医美级年轻化效果；

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
complete
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
incomplete
能产生一点的口碑传播

298
complete
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
complete
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

预计数据回收时间：

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

- **Face**-Face-Tighten Pro

## 六、需求描述
1、涉及算法

| 接口 | /v1/facelift_async ||
| 算法文档 | [https://insight-mtlab.meitu-int.com/document/editor?id=1098&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=1098&type=preview) ||
| 成本信息 | 耗时：10s 推理
单人: 0.0123079 RMB/次 (多一人加80%）
2人: 0.23 RMB/次
5人: 0.45 RMB/次
 ||
| 算法对接人 | 陈进山 ||
| 效果设计师 | 小孔 ||

2、需求内容

| 原型图 | 功能详情说明 ||
| 
 | **功能位置**

- Face - Face - Lift Pro

**排序**

- Face 中第五位（lift后一位），默认选中Width

**功能交互流程**

- 首次进入 Face，在 Lift Pro 下增加 New 角标，在 Face tab 下增加小红点，用户点击后消失
- 点击 Lift Pro 后进入 loading 流程（组件4）
- 取消/超时/请求错误则停留当前页面，默认选中上一个子项，若无上一个则默认选中Width
- loading完成后返回结果图

**滑杆逻辑（具体样式是否更改，需要UI定义一下）**

- 每张图片首次请求，默认是「中等」强度档位
- 每次调整档位需要重新投递
- 然后用户可以调整到「弱」、「强」两个档位，或是回到原图

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
- 改逻辑对多人脸场景同样适用。

**多人脸**** AI 固化逻辑**

- 多人脸场景下，每张人脸的 AI 状态独立记录，互不影响；

- 当 A 人脸使用 Tighten Pro 或其他 AI 功能后：
- AI 结果仅对 A 人脸生效并固化；

- 切换至 B 人脸时，B 人脸仍保持原图状态。

- 若在 B 人脸继续使用 AI 功能：
- 则仅对 B 人脸生成新的 AI 结果并固化；

- 不影响 A 人脸已生成的结果。

- 同一人脸内，Life Pro 与其他 AI 功能（如 Sculpt / Double Chin Pro）共用 AI 固化链路，后续 AI 功能均基于当前最新结果图继续生成。

- Lift Pro 切换人脸时，需重新请求，次数一样扣减。

**Undo/Redo：**暂不支持Undo/Redo

**订阅限免**

- 非会员3次终身限免。

 ||

## 七、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=675221282](0. AB路由协议)

## 八、翻译

## 九、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
另外记录是否有
# 【P2】体验优化：Airbrush Hair loading组件统一(kiki)

**页面ID**: 697012257

**路径**: V8.11.0版本（6_17 端午版本）🚩/【P2】体验优化：Airbrush Hair loading组件统一(kiki)

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
| 2026.05.21 | Kiki | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 否 ||

## 一、需求背景
Airbrush Hair 功能包含三个子模块：Hairstyles（发型）、Color（颜色）、Hair Enrich（发质增强）。三个模块在用户提交生成请求后，均需要一段等待处理时间进入loading页面。
当前 Hair Enrich 模块中，除&quot;oil control（去油）&quot;与&quot;hair part（发缝）&quot;功能外，其余功能的等待状态 UI 组件存在以下两处问题：
① 各功能间所使用的组件样式不统一，视觉表现缺乏一致性；
② 部分功能 AI 处理耗时较长，当前 Loading 状态的设计未能有效承接这段等待时长，影响用户体验。
因此，本次优化将针对 Hair Enrich 模块，复用 Hairstyles 模块现有的 Loading 组件，统一等待状态 UI 表现。Color 模块暂不在本次优化范围内。

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
complete
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
complete
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

## 二、功能目标
预计回收数据时间：7月1日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
complete
留存提升1-2%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
complete
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

## 四、参考原型图

| 原型图 ||
| 
 ||

## 五、需求描述

## **5.1 概述**
本次需求改动模块的前端 UI 层： Hair Enrich，目的是统一hair模块整体的loading页面。

| **改动位置**
 | Hair Enrich（除&quot;oil control去油&quot;与&quot;hair part发缝&quot;外的所有功能）在用户点击效果选项、系统触发 AI 生成时弹出的 Loading 页
 ||
| **改动内容**
 | 将现有深色卡片 Toast 替换为全屏半透明蒙层，加入实时百分比进度数字和 Cancel 操作按钮
 ||
| **不改动内容**
 | 算法逻辑、后端接口结构、底部功能选择栏交互、Hairstyles /color 模块的任何现有逻辑
 ||
| **复用内容**
 | Hairstyles 模块现有 Loading Overlay 组件（前端直接复用，无需重新开发）
 ||

## **5.2 现状 vs 目标样式 **

| 目前状态 | 改进后样式 ||
| 
 | 
 ||
| 缺乏明确进度预期，易引发等待焦虑 | 提供了带百分比的进度提示，用户可清晰感知处理进度 ||

## **5.3 改进内容细节表**
****

| 
 | 英语 | 中文 | 备注 | 是否变更 | loading组件样式图片 ||
| 

Hair Enrich
 | Hydra Gloss | 水光发 | 组件4 | **是** | 
 ||
| Shiny | 光泽 | 组件4 | **是** | 
 ||
| Smooth | 柔顺 | 组件4 | **是** | 
 ||
| Oil Control | 去油 | 组件2 | 否 | 
 ||
| Thick | 丰盈 | 组件4 | **是** | 
 ||
| Volume | 发量 | 组件4 | **是** | 
 ||
| Hairline | 发际线 | 组件4 | **是** | 
 ||
| Hair Part | 发缝 | 组件2 | 否 | 
 ||

**5.4 现状 vs 目标对比明细**

| 图示 | 功能详情说明 ||
| 
 | hair全场景loading 页面（haitstyle/color部分保持现状，hair enrich部分进行以下修改）：
loading覆盖在人像预览图上方，由上至下依次呈现以下元素：
**1. 背景蒙层** 半透明黑色蒙层覆盖整个预览图区域，使下方人像内容可见但视觉权重降低，将用户注意力引导至进度信息区域。
**2. **Airbrush 品牌图标（橙色渐变 A 形图标）居中展示于蒙层中央区域，并且呈现动态走动样式。
**3. 主文案 &mdash; 进度数字** Logo 正下方展示主状态文案：Generating... X%，其中 X 为实时更新的百分比整数（0 至 100）。
**4. 副文案** ："Hold tight, your image is on the way&hellip;"
**5. Cancel ：胶囊按钮** 副文案下方居中放置 Cancel 按钮，圆角胶囊形态，白色描边+白色文字，背景透明。
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议-弃用)

## 七、翻译
本次改动复用 Hairstyles 模块已有文案，无需新增翻译资源：

| 

 | **文案内容（EN）**
 | **说明**
 | **是否需要新增翻译**
 ||
| 1
 | Generating... X%
 | 进度主文案，X 为动态数字占位符
 | 否，复用 Hairstyles 已有翻译资源
 ||
| 2
 | Hold tight, your image is on the way...
 | 进度副文案
 | 否，复用 Hairstyles 已有翻译资源
 ||
| 3
 | Cancel
 | 取消按钮文案
 | 否，复用全局公共文案
 ||

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有

## 九、TPM信息

| 能力类型 | 

22
complete
业务自研

 | 

26
incomplete
外采转自研

 | 

23
incomplete
接入

 | 

25
incomplete
外采

 ||
| **TPM项目名称
(可附上jira链接)** | 举例：TPM-演唱会场景画质修复 ||
| 业务侧的功能入口 | 举例：演唱会神器-超清现场 ||
| **从哪个业务接入（接入的需填写）** | 说明：只有存在接入的，才需要填写，此时，填写的是接入功能的归属方 ||
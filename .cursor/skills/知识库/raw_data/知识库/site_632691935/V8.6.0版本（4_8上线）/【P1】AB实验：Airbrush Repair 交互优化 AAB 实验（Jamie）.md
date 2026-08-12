# 【P1】AB实验：Airbrush Repair 交互优化 AAB 实验（Jamie）

**页面ID**: 635548124

**路径**: V8.6.0版本（4_8上线）/【P1】AB实验：Airbrush Repair 交互优化 AAB 实验（Jamie）

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
| 2026.03.18 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做:

- 替换修复算法观测到数据有显著提升，但过往的 UI 形式，会将主要的人像场景能力藏的过深，导致用户不好第一时间挖掘。
- 新版交互强化了人像增强档位存在感，在人像场景下支持效果更好的人像修复。

数据状况：

- 过往交互 颜色增强、去噪 等使用率很低，可以收合功能到场景里面，不用特别 highlight 出来一个按钮。
- 实验复盘文档：。

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
1、如涉及算法，注明算法相关信息

| 算法接口 | /v2/image_restoration 
/v1/imagefacesr_async [https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](面部超清) ||
| demo地址 | 面部超清
[https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview)
 ||
| 算法对接人 | 陈进山 ||
| 效果设计师 | 
 ||

2、需求内容

#### 【实验组-功能概述】

| 原型图 | 描述 ||
| 

 | **Repair 新增交互**

- 进入repair，默认不选中，不自动投递（deeplink可选择投递与否）
- 展示四个图标：UHD、Portrait、Denoise、Colorize
- 调整成场景增强，分成四个场景超清、人像增强、去噪、黑白上色，四个场景互斥仅为单选。

- 实验组即使是无人图，也要展示 portrait 图标。
- AIRepair的结果图缓存，退出AI Repair后，就不保留
- 任务投递过程中，底下的按钮高亮选选中，失败后再去选

**功能交互**

- 点击任一图标后，图标高亮，进入ai任务投递：
- 使用loading组件4

- 返回结果图后，对比按钮高亮：
- 若点击其他按钮，如果没有记忆的效果图，就会触发任务投递。
- 若有结果图，需展示结果图。

**通用逻辑**

- 云服务弹窗与线上逻辑一致
- loading组件与线上一致
- 请求反馈与线上逻辑一致（无网络、安审、请求失败）

 ||

场景与参数关系

| 序号 | 选项 | 调用算法(照顺序) | 画质修复参数 | 备注 ||
| 1 | UHD | 画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
 | 无上色能力 ||
| 2 | Portrait | 画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4

 | 无上色能力 ||
| 3 | 去噪 | 画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
&quot;use_denoise&quot;: 1
 | 无上色能力 ||
| 4 | 上色 | 著色用旧算法/v1/sdcolorization_async

 | 

 | 黑白图 ||

3、实验规划
针对 AI Repair 算法替换 做如下AAB实验：

- 对照组：维持线上不变。
- 实验组：

- **调整 AI Repair UI交互**
- 原订阅逻辑维持不变。

**AAB实验信息：**

| 实验触发时机 | ** 进入AI Repaire功能时** ||
| 对照 | 维持现有 AI Repair 算法 ||
| 实验组AA | 维持现有 AI Repair 算法
 ||
| 实验组B | 
- **调整 AI Repair UI交互**

 ||
| 实验观察指标 | P0: 打勾率、用户留存
 ||
| 流量控制 | 全区，对照组AA、实验组B 各30%流量 ||
| 测试周期 | 14天（看結果決定是否延長） ||

**AI Repair 算法替换 - AAB实验**

| 平台 | 对照组 | 实验组AA | 实验组B | 实验链接 ||
| iOS | 
 | 
 | 
 | 
 ||
| Android | 
 | 
 | 
 | 
 ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
# 【P1】体验优化：Airbrush Replace 实验组算法速度优化（Jamie）

**页面ID**: 660495527

**路径**: V8.1.0版本（1_21上线）/【P1】体验优化：Airbrush Replace 实验组算法速度优化（Jamie）

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
| | Jamie | 
 | 
 ||

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2025.08.22 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
前置需求：

1、编辑器内的 ai image 的算法当前实验组在上线两周之后，数据已有明确的结论，实验组出现显著负向结果。但考虑到风格、通用性、模型稳定性，体验下来整体相比旧算法来说效果整体来说更好，主要问题出在于新算法的处理时长翻倍，导致取消率明显提升，影响到实验的对比基础。

*实验组AI Replace保存渗透率显著下降，原因在于新算法处理时长翻倍（对照组17s~18s VS 实验组 40s~42s），建议优化*
*实验连结：[https://qiming-voyager.pixocial.com/experiment/11269/result/status](https://qiming-voyager.pixocial.com/experiment/11269/result/status)*

2、因此，期望在这个基础上，优化当前实验组版本算法，透过串连并发等方式大幅降低生成图的时间。以期能重新评估实验成效。

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

| xxxx算法接口 | token_type: replace
task_type: workflow
task: aigc_ab_qwen_edit_parallel_flow

工作流

 ||
| demo地址 | 
 ||
| 算法对接人 | 黄军 ||
| 效果设计师 | Mucha ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

- 替换 内的实验组算法，换成新的并发版本
- 原实验触发时机、实验code、流程不变：

针对 AI Replace 算法替换 做如下AAB实验：
对照组：维持AI Replace 交互与算法不变
实验组：
**替换 AI Replace 成新的pix换装算法**
原交互、生成数量、订阅逻辑维持不变。
**AAB实验信息：**

| 实验触发时机 | **进入AI Replace功能时** ||
| 线上 | 维持现有 AI Replace 算法 ||
| 实验组AA | 维持现有 AI Replace 算法 /v1/sd?cqpdotjk268fqo5fltt0
 ||
| 实验组B | **替换 AI Replace 成新的换装算法**
 ||
| 实验观察指标 | P0: 打勾率、保存、用户留存
 ||
| 流量控制 | 全区，对照组AA、实验组B 各 33% 流量 ||
| 测试周期 | 14天（看結果決定是否延長） ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
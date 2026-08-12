# 【P1】体验优化：Airbrush Relight 取消率优化（Zac）

**页面ID**: 710772648

**路径**: V8.15.0版本（8_19上线）/【P1】体验优化：Airbrush Relight 取消率优化（Zac）

---

#### JIRA地址：link

| 

模块
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
| 2026.02.10 | Jamie | 创建文档 | 
 ||
| 2026.07.29 | Zac | 补充方案 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
根据[https://meitu.feishu.cn/wiki/SoPGwJdbbifloYkxxnocDb4Onnf?fromScene=spaceOverview](后台数据统计)，目前 **Relight** 为编辑器内使用量较高的 AI 功能，但取消率均超过 8%。

| 功能 | 上报量 | 取消率 | 平均耗时 ||
| Relight | 2,472,662 | 9.13% | 30.8s ||

从用户行为来看，当前取消主要发生在任务创建后，用户一旦点击 Apply 即开始上传图片并创建 AI 任务，即使随后立即取消，也已经产生云端推理成本。同时，用户在等待过程中只能停留在 Loading 页面，无法继续编辑，长时间等待也进一步提高了取消率。
因此，本次希望针对 Relight 等待流程，将任务处理改为异步模式，在降低无效 AI 成本的同时，减少用户因等待导致的取消行为

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

## 二、功能目标

- 降低 Relight 的取消 2%
- 数据回收时间：9/9

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

 | **复用 AI Image 的History 能力**
Relight 接入 AI Image 已有的 History 能力，整体交互、页面及任务处理流程保持一致，复用能力包括：

- Loading 页面
- History 入口
- History 页面
- Notification
- 服务端能力
- Task 创建
- Task 状态管理
- Task 查询
- Task 删除
- History 保存周期
- Notification 下发

 ||
| 
 | **History 保存页新增 Compare 对比按钮**

#### 功能说明

- Relight 支持 Compare 能力，因此用户从 History 中进入已完成的 Relight 任务后，编辑器新增 **Compare** 按钮，用于查看当前任务生成前后的效果对比。

#### 交互逻辑

- 用户点击 History 中已完成的 Relight 任务。
- 进入 Relight 保存页。
- 保存页展示当前任务对应的效果图，并新增 Compare 按钮。
- 用户长按 Compare 按钮时，展示该任务对应的原图。
- 用户松开 Compare 按钮后，恢复展示当前任务对应的效果图。

**服务端**

- 每条 History 任务需保存对应的原图与效果图映射关系。
- 返回 History 数据时，同时返回当前任务对应的原图信息，保证 Compare 可正常展示。

#### 异常情况
**原图不存在或获取失败**

- Compare 按钮置灰
- 用户仍可正常查看效果图及进行后续操作。

**History 数据异常**

- Compare 按钮置灰，点击跳出 Toast
- Toast 提示：Unable to load comparison image.

 ||

**新增 A/B 实验**

| **组别 ** | **内容** | 流量 ||
| 对照组（线上） | 线上逻辑：Relight 无 History 能力
 | 33.3%
 ||
| Test A | Relight 无 History 能力
 | 33.3% ||
| Test B | Relight 新增 History 能力
 | 33.3% ||
| 实验触发时机
 | 用户进入 Edit 模块时
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
P1:功能整体的留存率
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

- 用户点击 loading 页 「check later」
- 用户点击「History」按钮进入History 页
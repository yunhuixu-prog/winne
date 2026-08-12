# 【P1】体验优化：Airbrush Relight 取消率优化（Zac）

**页面ID**: 710772648

**路径**: V8.15.0版本（8_19上线）🚩/【P1】体验优化：Airbrush Relight 取消率优化（Zac）

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
| 2026.8.2 | Zac | 根据内审补充 | 
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

 | **Relight AI 效果新增「History」支持移步处理**
交互复用 AI Image 的历史页面，整体交互、页面及任务处理流程保持一致，复用能力包括：

- Loading 页面
- History 入口
- History 页面
- Manage按钮：点击变成选中删除交互，支持单条任务选中＆全选。
- 下载按钮交互、错误状态、重新生成按钮，都与AI Image内一致。
- Notification

- 成功状态：
- 标题「Your photos are ready.」
- 副标题「Click to see the results. >>」

- 失败状态：
- 标题「Mission failed. Please try again」
- 副标题「Click to check.>>」

- Relight 历史页面只展示 Relight 的内容，与其他功能不互通

 ||
| 
 | **异步处理逻辑**

- 用户点击移步处理后，从 Loading 页面回到编辑器时：
- 若移步处理未完成，则当前在处理的效果缩略图显示加载态（具体样式由 UI 定义），用户点击后弹出进度
- 若移步处理已完成，则加载态消失，用户点击后再次发起请求

- 移步处理完成后，当前页面不返回效果图
- 同张图片，用户点击会拉取已有效果图

 ||
| 
 | **Relight History 定制内容**
**用户点击任务**

- 用户点击 History 中的任务。
- 若任务进行中、失败：点击弹 toast
- 若任务成功：点击后：
- 收起history页回到编辑器，替换画布中的图片为点击的任务效果图。对比按钮展示为新图片的原图。
- 滑杆值为默认值

**换图逻辑**

- 换图之后，**原图0（进入 Relight 时的原图），要在history页的最上方置顶，具体交互参考 AI Repair**，点击后，收合 history 页，进入编辑器，图片替换为原图。
- 需记忆进入Relight 时的原图，以置顶的样式存在 history 页

**撤销逻辑**

- 打勾时非进入图片
- 以打勾的效果图，在编辑器内的编辑步骤+1
- **打勾：即在目前的步骤记忆里面，加上一步（打勾的这张图），点击撤销可回到上一张**
- 点击撤销回退得回到之前的编辑记录

- 打叉：则回到进入时的原图

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
 | P0:打勾/保存/订阅/取消率
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
# 【P2】体验优化：Airbrush Eraser 取消率优化（Zac）

**页面ID**: 710797075

**路径**: V8.16.0版本（9_2上线）🚩/【P2】体验优化：Airbrush Eraser 取消率优化（Zac）

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

#### 更改记录：

| 2026.08.09 | Zac | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
根据[https://meitu.feishu.cn/wiki/SoPGwJdbbifloYkxxnocDb4Onnf?fromScene=spaceOverview](后台数据统计)，目前 Eraser 为编辑器内使用量第二高的 AI 功能，但取消率均超过 8%。

| 功能** | 上报量** | 取消率** | 平均耗时** ||
| Edit -> Erase
 | 1,192,373
 | 9.55%
 | 16.3s ||

**现状与竞品对比**

| AB | 秀秀调色样式
 | 秀秀改图样式
 | Hypic
 | Pisart ||
| 
 | 
 | | | ||
| 取消率：9.55%
平均耗时：16.3s | 取消率：22%
平均耗时：13.1s
 | 取消率：4.90%
平均耗时：14.31s
 | 
 | 
 ||
| 
- 目前的进度体验比较不符合用户预期
- 可能会存在停滞，突然加速等情况

 | 
- 调色、改图平均耗时差不多，但UI交互不一样，取消率相差很多。

- 秀秀改图样式loading更优、且取消按钮延迟出现，整体取消率低很多。

 | 
- Hypic 进度更符合预期。更反映真实进度。

 | 
- 仅有 loading 态，感知较弱。

 ||

本次希望针对 Eraser 模块的等待流程，优化 Loading 页面交互体验，减少用户因对等待时间没预期导致的取消行为

- 优化 Loading 页进度展示
- 优化 Loading 页文案展示
- 新增倒计时
- 延迟取消键出现时间

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

- 降低 Eraser 模块的的取消 2%
- 数据回收时间：9/18

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

| **原型图** | **需求描述** ||
| 
 | **复用 AI Repair 的 Loading 页组件**

- 呈现 动画+解说文字＋处理进度+取消按钮+处理进读文字说明，动画需与AB Logo产生品牌连结
- 需要有背景蒙层
- 解说文字：Generating...
- 处理进度：x%
- 取消按扭：
- 按钮文字：Cancel
- 点击取消即回退到上一步
- 若为 限免功能|限免素材|付费功能，以任务投递为交界，未投递即不扣减相应次数。

- 处理进度文字说明：
- 需区分成 投递前、处理中 
- 处理中文字需以轮播处理
- 帮助用户了解当前任务阶段且避免限免次数扣减争议(2s轮播)

| 投递前 | 
- Setting things up for you...

 ||
| 处理中 | 
- This might take a moment, but it&lsquo;ll be worth the wait.
- Almost there - we're refining the details for you.
- Hang tight! Your photo's about to look amazing. （照片用）
- Hang tight! Your video's about to look amazing. （视频用）

 ||

 ||
| 

 | **新增优化**

- 进度条逻辑修改
- 上传阶段不显示取消按钮
- 投递阶段使用新aigc sdk

- 处理进度文字说明
- 新增「剩余时间倒数」：About x sec remaining 加入处理中的文字轮播

 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=675221282](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
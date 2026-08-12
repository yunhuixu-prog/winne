# 【P1】体验优化：Airbrush评分弹窗优化（曾曾）

**页面ID**: 679593344

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P1】体验优化：Airbrush评分弹窗优化（曾曾）

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

#### /更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026.3.25 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
目前的评分弹窗在弹出机制上存在问题，让用户感到反感和打扰，因此需要优化评分交互，限制弹出机制，避免另用户感到反感。

现状分析

- 弹出机制：当用户保存5次后，在没有优先级更高的弹窗时弹出，如果有优先级更高的弹窗会被抢占不显示
- 未评分的用户，第 4 次保存首次触发，之后每 10 次触发一次。
- 评分弹窗为两步：喜欢则去 App Store 评分，不喜欢则关闭弹窗。

 从用户反馈情况来看，「刚点开就弹出评分弹窗」真实性存疑，目前逻辑不存在刚点开功能没有用就强制要5🌟好评的情况，但用户仍觉得体验差，因此需将弹窗限制逻辑做的更加清晰，
目前的交互问题是未做**"好评引导 + 差评拦截"**，统一跳转，评分差也不知道原因，希望可以将差评拦截至内部，也能够搜集更多用户反馈。

| 安卓 | ios ||
| 
 | 
 ||

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
complete
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
complete
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
complete
能产生一点的口碑传播

298
incomplete
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

数据回收时间：5.28

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
 | 
### **评分触发场景与时机**

- **保存/分享成功**：

- 用户至少保存**5次**，每次**完成至少1个打勾操作后，点击保存**，成功返回结果页并**停留 2s 后**，在保分页中展示。

- 当前无其他优先级更高的弹窗系统会按优先级判断是否有其他更高优先级弹窗要出

- 评分弹窗会被其他保存后弹窗抢占，优先级：订阅 offer > 宽限期提醒 > 运营弹窗 > **评分弹窗** > IDFA 提醒

### **交互与视觉**
**场景：** 用户点击"保存"成功后，在结果页直接展示。

- **布局：**

- 动图/图案
- 标题： 🌟Rate Airbrush 🌟
- 文案：Are you enjoying AirBrush? Your feedback means a lot to us.
- 按钮：Yes, go and rate
- 按钮：No, I'm not satisfied
- 按钮：Not Now

### **评分交互**

- **用户点击「Not Now」按钮**
- 立即关闭弹窗，返回当前页面，30天内不再触发

- **用户点击 Yes, go and rate**

- 立即跳转至 App Store评分页面

- **用户点击 No, I'm not satisfied**

- 展开新的弹窗页面
- 标题："您对哪里不满意？What are you not satisfied with?"
- 提供几个快捷标签供用户点选，例如：

- 效果不自然：The effect is not natural.

- 画质差：Poor picture quality

- 操作太复杂：The operation is complex

- 没找到我喜欢的功能/效果：I can't find any features that I like

- Others,Please enter（点击后用户可以自由输入）

- 用户点击"提交"后，弹出 Toast 提示：*"Thanks for your feedback. We&rsquo;ll keep improving AirBrush for you.感谢你的反馈，Airbrush正在努力改进中！"*

- 提交后自动关闭评分区域，**不再唤起系统评分弹窗**，让用户继续停留或离开结果页。

### **其他逻辑**

- **展示上限：**

- 单个用户每 365 天最多触发 3 次系统评分弹窗（以弹窗展示为计数口径）

- 冷却时间（30天 / 60天）

- 用户点击"Not Now"或者"关闭（X）"后，30 天内不再触发弹窗。

- 用户在当前版本已操作「跳转app store」评价或「提交差评」后，当前版本内不再触发评分弹窗（即使跨过60天也不触发，需**升级版本+过了60天后**才可再次触发）

### **异常情况**

- **用户点完星级后直接杀后台：**无需处理，下次满 足条件再触发（需记录已触发次数）。

- **网络异常：**用户反馈提交失败时，提示"网络不给力"，允许用户点击"取消"跳过。

- **评价中途退出：**用户点了反馈后，如果点击"X"，应直接退出弹窗。

 ||

## 七、协议跳转
/

## 八、埋点需求

- **触发场景分布**

- **差评标签分布**

- **用户自定义提交的反馈意见**
- **跳转至App Store****系统弹窗唤起数**
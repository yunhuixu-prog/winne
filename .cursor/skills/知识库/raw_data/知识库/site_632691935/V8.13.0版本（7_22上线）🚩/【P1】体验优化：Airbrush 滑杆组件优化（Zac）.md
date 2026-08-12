# 【P1】体验优化：Airbrush 滑杆组件优化（Zac）

**页面ID**: 695522820

**路径**: V8.13.0版本（7_22上线）🚩/【P1】体验优化：Airbrush 滑杆组件优化（Zac）

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
| 2026.05.22 | Kiki | 创建文档 | 
 ||
| 2026.6.15 | Zac | 修改文档，添加更多细节 | 
 ||
| 2026.7.7 | Zac | 更新ios/安卓双端逻辑；更新前置优化功能 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 否 ||

## 一、需求背景
当前 Airbrush 端内滑杆组件存在两类问题：

- **现存两种类型的滑杆均存在热区问题**
端内目前存在两种滑杆组件：

- **参数调节滑杆组件**：用于调节效果强度、参数数值、滤镜程度等。
- **范围调节滑杆组件**：用于调节作用范围大小，例如画笔大小、橡皮擦大小、局部编辑范围等。

当前两种滑杆组件都存在**端点热区偏小的问题**。用户将滑杆拖动至左右两侧极值后，反向回拉时容易出现难以命中滑杆、需要多次拖动才能继续调整的情况。

| 
 | 安卓 | iOS ||
| 参数调节滑杆 | 
 | 
 ||
| 范围调节滑杆 | 
 | 
 ||

此前已有部分功能通过「参数调节滑杆组件左右两端热区各扩大 30px」的方式完成优化，但该优化目前仅覆盖部分参数调节滑杆组件，尚未覆盖全部参数调节滑杆组件，也未覆盖范围调节滑杆组件。

- **滑杆组件体验不统一问题**目前端内部分功能已使用新版参数调节滑杆组件，但仍有部分功能保留旧版滑杆样式，导致不同编辑功能之间的滑杆视觉和交互体验不一致。

| 新样式 | 旧样式 ||
| 
 | 
 ||

本次需求需要统一优化 Airbrush 端内滑杆组件体验：

- 优化双端的参数调节滑杆，保证用户在滑杆极值状态下可以顺畅反向回拉。
- iOS：「滑杆左右两端热区各横向扩大30px，竖向扩大12px」
- Android：「滑杆左右两端热区各横向扩大 x px」

- 同步统一参数调节滑杆组件样式，将仍使用旧版样式的功能更新为新版样式，保证端内参数调节滑杆的视觉和交互体验一致；替换端内范围调节滑杆，统一使用新样式的参数调节滑杆，减少维护成本，提高端内组件视觉统一性

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
complete
不产生口碑传播

288
incomplete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
预计回收数据时间：xx月xx日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

1217
complete
打勾率提升1%

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

## 四、原型流程图

## 五、需求描述
**本次需求主要包含三部分：**

- 参数调节滑杆优化
- 范围调节滑杆替换
- 旧样式滑杆替换

### **参数调节滑杆优化**

| 图例 | 描述 ||
| 

 | **优化方式 区分双端**
具体规则如下（iOS）：

- 参数调节滑杆左端横向扩大30px，竖向扩大12px。
- 参数调节滑杆右端横向扩大30px，竖向扩大12px
- 不应出现滑杆到达极值后，需要多次点击或多次拖动才能重新命中滑杆的情况。

**优化范围（仅iOS）**

- 当前部分模块已完成参数调节滑杆两端热区扩大 30px 的优化，但尚未确认是否已接入统一组件逻辑；
- 部分模块仍未完成热区优化。本次需统一梳理并补齐参数调节滑杆的热区优化，保证各模块最终体验一致。

| 已完成优化的模块 | 未完成优化的模块 ||
| 
- Smooth
- V8.11.5 重构，需重新适配

- Tattoo
- Breast Enhancement
- 分段式滑竿已优化，连续滑竿未优化

- Hair Enrich
- 分段式滑竿已优化，连续滑竿未优化

- AI Expand
- Crop

 | 
- Face
- Body 
- Waist
- AI Retouch
- Breast Enhance Finetune
- Plump
- Hair Dye
- Glow Up
- Relight
- Adjust
- AI Replace
- Breast Enhancement
- 连续滑杆需优化

- Hair Enrich
- 连续滑杆需优化

 ||

具体规则如下（Android）：

- 待更新
- 不应出现滑杆到达极值后，需要多次点击或多次拖动才能重新命中滑杆的情况。

 ||

### 范围调节滑杆替换

| 图例 | 描述 ||
| 

 | **优化方式**
双端均替换旧的范围调节滑杆为参数滑杆样式，之后只统一维护一组滑杆
**替换范围（存在旧滑杆样式的模块）**

- Eraser

- AI Eraser
- Spot Remover

- Blur
- Stamp
- Skin
- Smooth
- Skin Tone
- Concealer
- Brighten
- Dark Circles
- Wrinkles
- Eye Brighten
- Details
- Matte
- Texture

- Teeth
- Whiten

- Reshape
- Refine
- Reshape
- Restore

注：以上为当前已梳理到的范围调节滑杆入口。研发接入时需进一步确认是否存在其他使用范围调节滑杆的功能；如有遗漏，需按同样规则补充。
 ||

### 旧样式数值滑杆替换

| 图例 | 描述 ||
| 
 | **替换规则（iOS）**

- 样式替换后，滑杆左右两端热区也需各横向扩大30px，竖向扩大12px。
- 样式替换不影响原功能的参数范围、默认值、调节精度和实时预览效果。
- 样式替换后，不影响撤销、重做、对比、打勾等原有编辑流程。

**替换规则（Android）**
**替换范围**

- Bokeh
- Prism
- Magic
- Smooth
- Width
- Chin
- Nose Size
- Lip Size
- Contouring

- Makeup
- Looks
- Lipstick
- Blush
- Contouring
- Freckles
- Eyebrows
- Eyelashes
- Eyeliner
- Eyeshadow
- Eye Color

- Skin
- Skin Tone

- Reshape
- Resize
- Stretch
- Vertical
- Horizontal

- Muscle
- Body
- Abs
- V-Line
- Pecs
- Breats
- Arms
- Collarbone

- Glitter
- Filters
- Effects
- Edit

- Text

 ||

五.协议跳转

### 六.AB code

### 七.AB结论

### 八.埋点需求

### 九.翻译需求

### 十一.UI
Figma链接：
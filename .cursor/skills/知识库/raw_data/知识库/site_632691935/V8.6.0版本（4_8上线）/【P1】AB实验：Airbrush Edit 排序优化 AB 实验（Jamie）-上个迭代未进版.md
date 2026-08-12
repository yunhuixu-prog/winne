# 【P1】AB实验：Airbrush Edit 排序优化 AB 实验（Jamie）-上个迭代未进版

**页面ID**: 673240798

**路径**: V8.6.0版本（4_8上线）/【P1】AB实验：Airbrush Edit 排序优化 AB 实验（Jamie）-上个迭代未进版

---

#### JIRA地址： 

服务端：

| 模块 | 

1181
incomplete
**翻译**

 | 

1182
incomplete
**隐私整改**

 | 

1183
complete
 **UI**

 | 

1184
incomplete
**特效**

 | 

1185
incomplete
**AR**

 | 

1186
incomplete
**素材**

 | 

1187
incomplete
 **前端**

 | 

1188
incomplete
**服务端**

 | 

1194
incomplete
设计

 | 

1189
incomplete
**底层**

 | 

1190
complete
**iOS**

 | 

1191
complete
 **Android**

 | 

1192
complete
**测试**

 ||

# 需求变更记录表**

| 更新时间
 | 更新内容
 | 变更发起人
 ||
| 2026/03/05 | 创建文档 | Jamie ||

# 一、需求背景

- 当前编辑器内 edit 模块的功能排序，主要依据历史版本的功能布局进行展示，但随着新 AI 功能的持续优化调整，各功能的 用户满意度与进入结构已发生变化。从用户使用反馈及功能数据表现来看，部分 AI 功能在 用户满意度与转化表现上具备较好的潜力，但由于当前排序位置靠后，整体曝光量不足，未能充分发挥其价值。

- 以 AI Repair 为例：
- 用户对 AI Repair 的使用满意度处于 第二梯队
- 但由于当前排序位置较后，功能曝光量相对较低，导致该功能 整体使用量未能达到预期水平

- 为了验证 功能排序调整是否能够提升高潜力功能的使用率与转化表现，本次实验对 edit 模块内部分功能顺序进行优化。

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

# 二、相关文档

# 三、功能数据目标（勾选对应指标）

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

# 四、预估投入工时

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

# 五、需求原型

# 六 、需求描述
**1**、需求详述**

| 需求描述 ||
| **edit 排序优化**
1、重新排序

- 实验组B排序:

| Adjust | Crop | Eraser | Relight | AI Repair | Bokeh | Blur | AI Expand | AI Replace | Stamp | Prism ||

- 实验组BB排序：

| Adjust | Crop | Eraser | Relight | AI Repair | Blur | Bokeh | AI Replace | AI Expand | Stamp | Prism ||

--- 对照实验组都做 ---
2、移除 ai expand new 角标

 ||

**2、实验详述**
AAB 实验 
实验触发时机：进入 edit 时

| 组别 | 对照组 | 实验组A | 实验组B ||
| 内容 | 线上版本 | 仅调动Repair、Expand排序 | 5~9位顺序重排 ||
| 流量 | 25% | 25% | 25% ||
| 实验周期 | 2 周 ||
| 对比数据 | 模块的进入、打勾率、使用、订阅情况 ||

# 七、协议跳转

# 无

# 八、翻译

# 九、埋点需求
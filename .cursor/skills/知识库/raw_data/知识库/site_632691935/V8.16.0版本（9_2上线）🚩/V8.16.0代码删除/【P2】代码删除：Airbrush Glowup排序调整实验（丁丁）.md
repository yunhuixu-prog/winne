# 【P2】代码删除：Airbrush Glowup排序调整实验（丁丁）

**页面ID**: 710799636

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0代码删除/【P2】代码删除：Airbrush Glowup排序调整实验（丁丁）

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
| 2025.08.22 | 丁丁 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**背景**：调整Glowup&Plump功能顺序
**需求：**

**结论**：

- 留存率，整体订阅成功&Glowup、Plump订阅成功，整体保存率均不可信变化
- 与预期一致，Glowup行为指标可信上升（6%～10%）（第一行为对照组，第二行中立组，第三行实验组）

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
预计回收数据时间：xx月xx日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
complete
曝光提升10%

300
incomplete
留存提升**%

1215
complete
打勾率提升5%

301
complete
订阅转化提升2%

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
incomplete
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
*** ***

## 六. AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 33.3%
 ||
| 实验组A | 目前线上版本
 | 33.3% ||
| 实验组B
（建议全量实验组）
 | **Glow Up前置**至第二屏第一个（位于Plumping前）
 | 33.3% ||
| 实验触发时机
 | **App 启动完成分流**，进入Retouch模块展示实验组排序，优先覆盖新用户观察冷启动表现
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量，若有明显负反馈则停止实验
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 ||
| **实验预期**
 | 实验组P0和P1数据或持平硬盘，P1数据无明显负向，后台无负反馈
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接：
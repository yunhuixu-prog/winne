# 【P1】AB实验：Airbrush Makeup付费密度降低（曾曾）

**页面ID**: 622565821

**路径**: V8.9.0版本（5_20上线）/【P1】AB实验：Airbrush Makeup付费密度降低（曾曾）

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

1215
complete
效果设计师

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
| 2026.04.15 | 曾曾 | 创建文档 | 
 ||
| 2026.05.13 | 曾曾 | 删除实验组BB | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
1、当前 Makeup 模块内免费/付费素材比例约为 4:6，整体付费密度偏高。从用户体验来看，进入 Makeup 后首屏付费素材占比过大，容易强化"过度收费"的感知；同时，由于当前 Makeup 仅支持体验、无法打勾，进一步削弱了新用户的使用意愿及后续传播效果。
2、结合 2026 年以用户增长与留存为核心的目标，本次优化将从用户体验出发，对 Makeup 各分类下的首屏素材排序进行调整，并适当降低付费素材密度：一方面提升高吸引力素材的曝光，另一方面优化整体付费结构，从而增强用户心智、提升使用意愿与留存表现。
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

| 

1189
incomplete
用户指标

 | 

299
incomplete
预计可带来新增**万

300
complete
留存提升5%

301
incomplete
频次提升**%

 ||
| 

280
complete
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

## 三、需求描述
针对 Makeup 内素材 降低付费密度的目标做如下AABB实验：

- 对照组：维持线上付费比例不变
- 实验组：

- **调整各分类下的Makeup排序 (透过排序调整首两屏内的付费/免费比例）**
- 付费订阅比例调整，部分订阅素材转免费
- 原订阅逻辑维持不变。

**AAB实验信息：**

| 实验触发时机 | 进入Makeup | 
 ||
| 对照组 | 维持线上排序（免费付费比约4:6） | 
 ||
| 实验组AA | 维持线上排序（免费付费比约4:6）
 | 
- **排序调整**

**--- for实验组B和BB**

- **付费转免费list**

**[https://docs.google.com/spreadsheets/d/1MN0DwT6lNsLEgMzt8WxmcMCZ1E3J_vlA_pztrpfQUug/edit?usp=sharing](数据汇总) -- for实验组BB**

 ||
| 实验组B | 调整各分类下首两屏的Makeup排序，照点击/打勾/保存率综合排序

- 保证首两屏付费素材占与免费5:5

 ||
| 实验组BB | 调整各分类下首两屏的Makeup排序，照保存率排序

- 调整素材排序，保证首两屏付费素材占与免费5:5
- 付费比例调整（所有素材免费付费比约4.5:5.5），部分素材由付费改为免费

 ||
| 实验观察指标 | P0: 打勾率、用户留存、LTV、未来一年收入预估
 | 
 ||
| 流量控制 | 全区，对照组AA、实验组B 各30%流量 | 
 ||
| 测试周期 | 14天（看結果決定是否延長） | 
 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
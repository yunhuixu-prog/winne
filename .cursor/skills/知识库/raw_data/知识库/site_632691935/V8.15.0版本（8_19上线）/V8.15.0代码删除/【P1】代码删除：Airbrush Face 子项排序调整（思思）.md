# 【P1】代码删除：Airbrush Face 子项排序调整（思思）

**页面ID**: 710773655

**路径**: V8.15.0版本（8_19上线）/V8.15.0代码删除/【P1】代码删除：Airbrush Face 子项排序调整（思思）

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
| 2026.5.29 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Face-face 模块已新增两项 2026 年 TPM 重点能力：3D 骨相还原与 AI 提拉。为评估功能排序对原功能用户使用数据的影响，将开展 Face 子项排序 AB 实验，通过对比不同排序策略下的用户行为数据，确定最优排序方案。

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

预计数据回收时间：

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
/

## 五、需求描述

| **组别 ** | **内容** | 流量 ||
| 对照组（线上） | width、cheekbone-s、lift、forehead、hairline、size、short、midface、lower face、philtrum、top、temples、Sculpt、****Tighten Pro**** | 33%
 ||
| （建议全量实验组A）Test A | **Tighten Pro**、**width、cheekbone-s、lift、Sculpt**、forehead、hairline、size、short、midface、lower face、philtrum、top、temples | 33% ||
| Test B | **Sculpt**、**width、cheekbone-s、lift、**Tighten Pro****、forehead、hairline、size、short、midface、lower face、philtrum、top、temples | 33% ||
| 实验触发时机
 | 升级后首次进入「**F****ace**」
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
/

## 七、翻译
/
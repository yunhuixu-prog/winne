# 【P0】AB实验：Airbrush Reshape位置调整AB实验（可乐）

**页面ID**: 680774928

**路径**: V8.6.5（小版本，4_13上线）/【P0】AB实验：Airbrush Reshape位置调整AB实验（可乐）

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
incomplete
服务端

 | 

1210
incomplete
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
| 2026.03.31 | 可乐 | 创建文档
 | 
 ||
| 2026.04.09 | 可乐 | 实验触发时机：editor菜单获取到服务器数据时 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
分析发现reshape是高留存高收入功能，但目前该功能在主编辑器位置非首屏，导致无论是新用户还是回流用户都难以找到这个功能，本次希望提高reshape功能曝光率，提升留存，具体分析见👇
[https://doc.weixin.qq.com/doc/w3_AKkAagbVAJwCNfUfq4ubaQHO28iZo?scode=ACIAJAeGAAgLsyMpVSAdQA1QaKAGs](https://doc.weixin.qq.com/doc/w3_AKkAagbVAJwCNfUfq4ubaQHO28iZo?scode=ACIAJAeGAAgLsyMpVSAdQA1QaKAGs)

综合考虑使用量和收入，本次需求在尽可能控制变量的情况下前置reshape，后置makeup和plumping
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
reshape功能进入率提升5%，主编辑器打勾率提升3%，活跃留存提升0.5%

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

## 四、需求描述
1、前置reshape，后置makeup和plumping，AB实验

| 对照组 | 对照组A | 实验组 ||
| 线上状态
排序：Retouch、Magic、Face、Makeup、Skin、Plumping、Glow up、Reshape、Resize、Stretch、Body、Tattoo、Muscle、Face Fix、Expression、Teeth、Glitter

 | 线上状态
排序：Retouch、Magic、Face、Makeup、Skin、Plumping、Glow up、Reshape、Resize、Stretch、Body、Tattoo、Muscle、Face Fix、Expression、Teeth、Glitter

 | 前置reshape，后置makeup和plumping
排序：Retouch、Magic、Face、Reshape、Skin、Makeup、Glow up、Plumping、Resize、Stretch、Body、Tattoo、Muscle、Face Fix、Expression、Teeth、Glitter

 ||

2、实验设置

| 项目 | 说明 ||
| 实验类型 | 客户端实验 ||
| 实验触发时机 | editor菜单获取到服务器数据时 ||
| 实验停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 

实验组说明
 | 对照组 | 当前线上状态 ||
| 对照组A | 当前线上状态
 ||
| 实验组 | 如上述
 ||
| 实验观察指标 | 1、reshape进入量和保存率
2、retouch模块整体打勾率
3、新老用户留存率
 ||
| 流量控制 | 初始流量各33%，后续根据数据和反馈评估 ||
| 测试周期 | 实验开启14天后结合数据表现开放最优实验组33%流量，如果实验组有收益扩全量
 ||
| 目标用户 | 全体用户（需要分国家分新老用户看数据，国家分：美、英、巴、其他）
 ||
| 实验预期 | Reshape使用量和订阅收入上涨，主编辑器打勾率上升，留存上升 ||

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求
AB实验数据中的reshape数据注意剔除来自新手引导reshape功能过来的用户，避免2个实验互相影响
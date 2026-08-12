# 【P1】AB实验：Airbrush AI Retouch 缩略图替换（Jamie）

**页面ID**: 692608895

**路径**: V8.10.0版本（6_8上线）/【P1】AB实验：Airbrush AI Retouch 缩略图替换（Jamie）

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

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026.05.13 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
AI retouch 在 Airbrush的用量靠前（日均点击编辑器第八），但交互存在不足问题

- 缩略图尺寸较小，难以直接辨别不同风格的差异
- 缩略图模特物料与AI Feature风格差异过大，不符合近期审美，需替换统一

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
需求能带来多大的数据提升

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
1、需求内容

| 原型图 | 功能详情说明 ||
| 

 | **AI retouch 模块 缩略图样式调整**

- 线上 AI retouch 9款线上风格的缩略图由替换新版本（具体物料由效果设计师提交）

 ||

2、实验内容

| 项目 | 描述 ||
| 实验概述 | 实验类型 | **客户端 AAB 实验** ||
| 实验方式 | 观察对比实验组和对照组的功能使用数据、转化差异 ||
| 重点关注数据
（分析师评估）
 | 观测指标pv/uv：
p0: AI Retouch 的进入、打勾
 ||
| 实验命中条件 | 用户进入 AI Retouch 时 ||
| 停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 实验组描述 | 流量控制 | 线上组 A/对照组 AA/实验组B 每组各 33% ||
| 实验周期 | 14-30天 ||
| 线上组 A | 保持目前线上样式
 ||
| 对照组 AA | 保持目前线上样式 ||
| 实验组 B | 替换缩略图
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
# 【P2】其他：Black Admin首页弹窗配置迁移接入客户端（小红）

**页面ID**: 664737729

**路径**: V8.3.0版本（2_26上线）/【P2】其他：Black Admin首页弹窗配置迁移接入客户端（小红）

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
| 2026.1.23 | 小红 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
目前，AW中首页推荐位、订阅页配置已完成迁移。首页弹窗完成迁移后可逐渐弃用AW。
后端迁移已完成，需接入客户端。

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

## 四、原型图

## 五、需求描述
1、新增配置后台需求
与保存分享页配置逻辑相似，

| 界面 | 描述 ||
| 
 | 分发：走配置分发
配置：包含左侧所有限制条件，并可选择pre/release

- 名称：不显示给用户，用户埋点上报和内部识别
- 位置：目前运营使用位置为&quot;Home&quot;，其他位置不确定配置入口和需求
- 权重：用于控制弹出优先级，已生效弹窗按照优先级依次弹出用排序顺序控制优先级
- 频次：可删除该字段，目前首页弹窗均为"有效期内弹出一次"
- 类型：基本上都是Image/video
- 多语言：
- 物料：动态文件为Pag。有Pag时，cover image为兜底图，预期显示Pag
- deeplink：一键应用所有配置
- Whether it is permanently on the homepage：如果是弹窗只播放一次的意思，则保留。反之则删除该字段，同时支持配置弹窗 循环播放/单次播放（需要重新提需，本次不做）
- background pic：删除该字段

 ||

2、需迁移的AW现有后台
[https://dashboard.appwheel.com/management/ynn1n3jvvy3p1o/new-ab-home-page](https://dashboard.appwheel.com/management/ynn1n3jvvy3p1o/new-ab-home-page)

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求
与AW埋点一致
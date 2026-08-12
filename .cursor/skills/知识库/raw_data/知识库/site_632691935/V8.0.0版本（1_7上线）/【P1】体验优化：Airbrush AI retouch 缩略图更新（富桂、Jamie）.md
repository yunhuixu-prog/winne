# 【P1】体验优化：Airbrush AI retouch 缩略图更新（富桂、Jamie）

**页面ID**: 650134719

**路径**: V8.0.0版本（1_7上线）/【P1】体验优化：Airbrush AI retouch 缩略图更新（富桂、Jamie）

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
 | 更改内容
 ||
| 2025.11.18 | 刘晓 | 创建文档 ||
| 12.01 | 刘晓 | 补充实验触发时机 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
AI retouch 在 Airbrush的用量靠前（日均点击编辑器第八），但交互存在不足问题

- 缩略图尺寸较小，难以直接辨别不同风格的差异
- 缩略图模特物料陈旧，不符合近期审美

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
incomplete
惊喜型：缺失不会引起不满，一但具备会显著提升满意度

296
complete
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

**功能数据目标（勾选对应指标）**

| **用户指标**
 | **保存率**
 ||
| 

280
incomplete
收入指标（如有）

 | 

1141
incomplete
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

## 二、预估投入工时

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

## 三、原型流程图

## 四、需求描述

| xxxx算法接口 | 
 ||
| demo地址 | 
 ||
| 算法对接人 | 
 ||
| 效果设计师 | 
 ||

| 原型图 | 功能详情说明
 ||
| 
 | **AI retouch 模块 缩略图样式调整**

- 线上 AI retouch7 项风格的缩略图由原来 1:1 调整为 3:4（180x240）**
- 线上 AI retouch7 项风格的缩略图 更换素材物料（具体物料由效果设计师提交）

 ||
| AAB 实验 

| 组别 | 对照组A | 对照组B | 实验组A ||
| 内容 | 线上版本 | 线上版本 | AI retouch缩略图调整方案 ||
| 流量 | 33% | 33% | 33% ||
| 实验周期 | 2 周 ||
| 对比数据 | 模块的曝光、点击情况 ||
| 实验触发 | 进入 AI retouch 功能后触发 ||

 ||

## 五、订阅相关
无

## 六、协议跳转
无
七、翻译
无

## 八、埋点需求
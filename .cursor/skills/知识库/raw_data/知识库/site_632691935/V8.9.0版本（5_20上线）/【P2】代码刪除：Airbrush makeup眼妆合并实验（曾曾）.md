# 【P2】代码刪除：Airbrush makeup眼妆合并实验（曾曾）

**页面ID**: 688607048

**路径**: V8.9.0版本（5_20上线）/【P2】代码刪除：Airbrush makeup眼妆合并实验（曾曾）

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
| 2026.04.20 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 对留存没有显著影响
- 因为tab合并，使用层级变深一级，两个实验组通过Makeup眼妆保存渗透率显著下降（实验组下降5.07%，11.12%->10.56%;实验组B下降5.09%，11.12%->10.56%），但是没有影响到Makeup功能保存渗透率，也没有影响到编辑器保存渗透率
- 两个实验组通过makeup订阅成功渗透率和整体订阅成功渗透率没有显著性变化，其中实验组（合并+默认选中睫毛）通过makeup眼妆订阅成功渗透率显著下降24.15%（对照组0.09%->实验组0.07%）

新用户Makeup眼妆保存率不可信下降，老用户结论同整体一致（两个实验组通过Makeup眼妆保存渗透率显著下降+实验组（合并+默认选中睫毛）通过makeup眼妆订阅成功渗透率显著下降）

实验结果无正向收益因此已经返回线上对照组，本次需删除实验组代码
变更实验结论和数据见：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=658379090](26年实验与分析汇总)

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
1、需求详述
历史需求：
实验链接：[https://qiming-voyager.pixocial.com/experiment/11279/result/status](https://qiming-voyager.pixocial.com/experiment/11279/result/status)

停止实验，删除实验代码，全量线上组

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
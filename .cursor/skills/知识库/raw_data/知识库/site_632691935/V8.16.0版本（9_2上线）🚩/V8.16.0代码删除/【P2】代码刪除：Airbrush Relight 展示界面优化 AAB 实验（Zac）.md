# 【P2】代码刪除：Airbrush Relight 展示界面优化 AAB 实验（Zac）

**页面ID**: 710801056

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0代码删除/【P2】代码刪除：Airbrush Relight 展示界面优化 AAB 实验（Zac）

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

#### 更改记录：

| 2026.08.09 | Zac | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- Relight 模块为主要AB Q2的增长点，随著我们后续规划更多效果的上线，当前Relight模块已经有26款效果。
- 当前的交互上，主要以单行的左右滑动为主，随著款式的上新增多，发现新上线的款式逐渐存在曝光不足的问题。考虑到之后每月会持续上新2~3款新光效，期望是能调整此模块素材展示逻辑，以优化曝光效率。
- 由于主流的竟品处理多素材的方式，多以长图为主，考虑到素材的复用性、可拓展性，因此考虑以长图做网格性拓展方案。

整体结论：

- **关键指标：**
- **实验组 B 能可信提升 Relight 使用，**整体 Relight 使用 +1.84% 且可信。iOS、Android 保存均有正向趋势，但结果暂不可信，之后版本再观察

整体使用

iOS

安卓

- 因此本次将**全量实验组ｂ**，本次需求需删除相关实验代码。

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
数据文档：

整体使用

iOS

安卓

停止实验，全量对照组ｂ

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
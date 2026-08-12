# 【P1】代码删除：Airbrush Body 多族裔 Auto 参数AB实验（Jamie）

**页面ID**: 710800478

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0代码删除/【P1】代码删除：Airbrush Body 多族裔 Auto 参数AB实验（Jamie）

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
complete
UI

 | 

1215
complete
效果

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
| 2026.08.11 | 丁丁 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
历史需求：
实验链接：[https://qiming-voyager.pixocial.com/experiment/11477/result/status](https://qiming-voyager.pixocial.com/experiment/11477/result/status)

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

| **项目**
 | **描述**
 ||
| **实验类型**
 | 客户端 AB 实验
 ||
| **实验方式**
 | 对比对照组与实验组的 Body Auto 使用、保存与转化差异
 ||
| **重点关注数据****
****（分析师评估）**
 | P0：Body 进入 &rarr; 保存、Auto 一键使用率、Auto 后二次手动微调率、滑杆保存值分布（是否更贴近手动中位）
 ||
| **实验命中条件**
 | 用户进入 Body 时
 ||
| **对照组 A
（建议全量对照组）**
 | 维持线上
 ||
| **实验组 B** | 新Auto参数 ||
| **实验组 BB**
 | 新Auto参数＋子项默认值
 ||
| **停止方式**
 | 根据结果决定关闭、扩量或全量同步
 ||
| **实验周期**
 | 14&ndash;30 天（black 样本偏薄，必要时延长）
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
新曾子项默认状态埋点
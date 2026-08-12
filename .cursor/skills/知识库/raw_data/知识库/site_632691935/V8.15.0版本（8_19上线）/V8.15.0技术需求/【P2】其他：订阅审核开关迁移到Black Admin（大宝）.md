# 【P2】其他：订阅审核开关迁移到Black Admin（大宝）

**页面ID**: 710780671

**路径**: V8.15.0版本（8_19上线）/V8.15.0技术需求/【P2】其他：订阅审核开关迁移到Black Admin（大宝）

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
| 
 | 
 | 

 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
目前还有一个订阅合规配置是在飞书表格维护，该项目已经废弃，所以需要将这个合规配置迁移到黑后台来进行配置。

历史需求文档：[https://meitu.feishu.cn/wiki/ExGGwCe6pirLcbkOkyEcDLv5nRf](https://meitu.feishu.cn/wiki/ExGGwCe6pirLcbkOkyEcDLv5nRf)

历史配置地址：[https://meitu.feishu.cn/wiki/RwNWwFLiYinHprk8ZLqcPo0Dnid?table=tblIxvqFtj0jhHHe&view=vewQC52lne](https://meitu.feishu.cn/wiki/RwNWwFLiYinHprk8ZLqcPo0Dnid?table=tblIxvqFtj0jhHHe&view=vewQC52lne)
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
迁移后的订阅合规开关配置使用 黑后台的 kv配置 承接，客户端需要将 /v1/compliance/subs 更换 拉取 kv配置接口

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求
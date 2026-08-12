# 【P2】技术：Airbrush Volume/Texture接入Duffle平台（曾曾）

**页面ID**: 616737063

**路径**: V8.2.0版本（2_4上线）/V8.2.0技术需求/【P2】技术：Airbrush Volume/Texture接入Duffle平台（曾曾）

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
complete
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
complete
前端

 | 

1209
complete
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
| 2025.09.18 | 曾曾 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
当前 Hair 模块正处于功能/视觉优化阶段。其中，Hairstyle和Hair color均已接入 duffle 平台，可通过线上快速配置实现敏捷上线/调整；但Volume/Texture尚未接入该平台，相关调整和功能优化无法同步推进，需经历较长的发版流程，不利于后续功能（功能/效果更新）的快速迭代与持续优化。

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
 | 

273
incomplete
高频

274
incomplete
中频

275
complete
低频但刚需

276
incomplete
低频非刚需

 | 

283
incomplete
不提升复杂度

284
complete
化繁为简

285
incomplete
略微提升复杂度

286
incomplete
大大提升复杂度

 | 

293
complete
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
complete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
-

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
-

## 五、需求描述
在 Volume/Texture 接入 duffle 平台后，可与发型、发色保持一致，支持以下能力：

| 能力 | 是否支持 ||
| 素材的上新与下架
 | ✅ ||
| 素材缩略图配置（画幅/尺寸/比例）
 | ✅ ||
| 素材命名管理 | ✅ ||
| 素材的强度（程度）配置 | ✅ ||
| 素材排序管理
 | ✅ ||
| 支持 模型/ AIGC 参数配置
 | ✅ ||

其他素材配置：均与发型/发色素材配置保持一致

## 六、协议跳转
-

## 七、翻译
-

## 八、埋点需求
-
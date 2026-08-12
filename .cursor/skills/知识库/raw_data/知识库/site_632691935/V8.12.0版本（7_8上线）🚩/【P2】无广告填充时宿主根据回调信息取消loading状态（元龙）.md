# 【P2】无广告填充时宿主根据回调信息取消loading状态（元龙）

**页面ID**: 702262154

**路径**: V8.12.0版本（7_8上线）🚩/【P2】无广告填充时宿主根据回调信息取消loading状态（元龙）

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

1215
incomplete
效果

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
| 2026.6.11 | 元龙 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

## **AB上banner广告未填充或渲染失败时，宿主客户端还会持续展示loading状态，实际此时已经不会再请求广告进行填充了，这种持续展示loading状态会给用户一种不好的体验。**
**需求定性**

| 

255
complete
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

**功能数据目标（勾选对应指标）**

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

- 针对banner类型广告：拍照banner、照选页banner、图片编辑页banner、视频编辑页banner等4个广告位
- 根据广告SDK的填充回调，若回调内容为无广告下发/填充或渲染失败情况下，客户端收到回调时立即取消掉banner广告的loading动效状态；直到下次重新发起广告位请求

双端广告SDK回调方法如下：
iOS：可咨询开发@康剑全 
/// 广告加载失败 /// **@param **adView 广告View /// **@param **error 加载失败的原因 - (**void**)adView:(MTBMediaAdView ***_Nonnull**)adView didFailLoadingWithError:(NSError ***_Nullable**)error;

android：可咨询开发@罗友凤
客户端有回调MtbDefaultCallbackWrapper#showDefaultUi isFailed = true

## 五、订阅相关

## 六、协议跳转

七、翻译
无

## 八、埋点需求
**无**
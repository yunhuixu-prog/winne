# 【P0】AB实验：Airbrush激励广告策略调整AB实验（可乐）

**页面ID**: 628965415

**路径**: V8.7.5（小版本 五一前4_27发版）/【P0】AB实验：Airbrush激励广告策略调整AB实验（可乐）

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
| 2026.04.13 | 可乐 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
目前产品内存在几个激励广告策略，具体线上已有策略如下👇，其中「肤色」、「祛痘」属于非常基础的功能，几乎所有人像修图竞品都具备这个能力，目前Ab需要看广告才能使用，对用户体验（留存）不友好。本次希望调整策略达到：
1）提升留存
2）将有付费意愿的用户筛选出来更合理地提升收入

过往策略：
[https://doc.weixin.qq.com/doc/w3_AdQA1QaKAGsCNNTcPvKGHRJ2xsaHs?scode=ACIAJAeGAAgMnOXRAmAdQA1QaKAGs](https://doc.weixin.qq.com/doc/w3_AdQA1QaKAGsCNNTcPvKGHRJ2xsaHs?scode=ACIAJAeGAAgMnOXRAmAdQA1QaKAGs)
[http://pixocial.feishu.cn/docx/XttndLRbyoupPGxOURCcZkaOnae](pixocial.feishu.cn/docx/XttndLRbyoupPGxOURCcZkaOnae)
数据分析：
[https://doc.weixin.qq.com/sheet/e3_AKkAagbVAJwCNXSvvyuC4Qhe8hwq7?scode=ACIAJAeGAAgHWtdCn1AdQA1QaKAGs&tab=BB08J2](https://doc.weixin.qq.com/sheet/e3_AKkAagbVAJwCNXSvvyuC4Qhe8hwq7?scode=ACIAJAeGAAgHWtdCn1AdQA1QaKAGs&tab=BB08J2)
[https://pixocial.feishu.cn/docx/Hg9jdFlhdo2kFmxquIYcZyRFnBx](https://pixocial.feishu.cn/docx/Hg9jdFlhdo2kFmxquIYcZyRFnBx)

当前线上逻辑：

- 新增首日没有激励广告
- 祛痘第2次开始有广告（一开始有1次免费机会），然后看3次广告，然后就没有广告了
肤色第1次开始就有广告（一开始没有免费机会），然后看3次广告，然后就没有广告了

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
留存提升的长期价值+订阅收入的收益 能高于 广告收入降低的损失

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
1、需求简述

- 本次只调整「Acne」的策略，暂不调整「Skin Tone」的策略
- 本次实验组「Acne」去掉分享解锁逻辑

| 双端 | 对照组 | 实验组A | 实验组B ||
| iOS | 
- 新增首日没有广告
- 祛痘第2次开始有广告（一开始有1次免费机会），然后看3次广告，然后就没有广告了

 | 
- 免费打勾2次
- 第3次开始要订阅
- 订阅逻辑：可以预览不可以打勾，打勾触发订阅@忻恬（同线上逻辑，预览时即展示订阅横幅）

 | 
- 免费打勾2次
- 第3次要看广告（所有广告逻辑不变）
- 第4次开始要订阅
- 订阅逻辑：可以预览不可以打勾，打勾触发订阅@忻恬（同线上逻辑，预览时即展示订阅横幅）

 ||
| Android ||

- 希望可以通过服务端灵活控制不同人群、免费次数（即如果发现收益不佳，是否可以在定义一个用户群体后，通过白名单针对这部分用户下发）--简单服务端代码控制，无需服务端配置后台

2、实验设置

| 项目 | 说明 ||
| 实验类型 | 客户端实验 ||
| 实验触发时机 | 进入主编辑器时 ||
| 实验停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 

实验组说明
 | 对照组 | 1）新增首日没有激励广告
2）祛痘第1次开始有广告（一开始没有免费机会），然后看3次广告，然后就没有广告了
肤色第1次开始就有广告（一开始没有免费机会），然后看3次广告，然后就没有广告了 ||
| 实验组A | 
- 新增当前没有激励广告
- 下线激励广告，每天前2次免费用，第3次需要订阅

 ||
| 实验组B | 
- 新增当前没有激励广告
- 下线激励广告，每天前2次免费用，第3次要看广告，第4次订阅

 ||
| 实验观察指标 | 分国家：广告收入变化、订阅收入变化、新老用户留存变化
 ||
| 流量控制 | 初始流量各10%，后续根据数据和反馈评估放量 ||
| 测试周期 | 稳定性表现没问题后扩大到各33%流量看数据表现，如果实验组有收益扩全量
 ||
| 目标用户 | 全体有激励广告的用户（需要分国家分新老用户看数据）
 ||
| 实验预期 | 留存提升的长期价值+订阅收入提升>广告收入损失 ||

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求

- Acne分国家订阅收入打点，区分第几次后订阅

*注意确认两个功能的曝光、点击、打勾打点齐全
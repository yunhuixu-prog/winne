# 【P0】取消支付挽留优惠价格调整AB实验 （晉羽）

**页面ID**: 680787583

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P0】取消支付挽留优惠价格调整AB实验 （晉羽）

---

**JIRA地址： **

#### 前置项

| 模块** | 负责人|到期时间** | 进度** | 备注** ||
| 例如：UI | 
 | 
 | 
 ||
| 
 | 
 | 
 | 
 ||

#### 更改记录：

| 更新时间** | 更改人** | 更改内容** | 备注** ||
| 2020.5.21 | xxx | 细节补充：广告不在本需求调整范围内（红色字体标注） | 举例说明 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景：

- Airbrush根据最新调价实验，已全量上线新涨价的价格，因此原线上的各订阅策略，需根据新价格重新测试。
- 原取消支付挽留优惠订阅策略，以新价格覆盖后，再实验首期7折 & 首期8折的成效。

需求定性

| 需求来源** | 需求创新性** | 目标用户** | 目标用户标签（如宠物、电商、宝妈、摄影爱好者等）** | 目标用户的需求频次** | 对产品复杂度的影响** | 对用户满意度预判** | 预估能否带来口碑传播** ||
| 

256
incomplete
用户反馈/调研

257
incomplete
公司/产品战略

258
incomplete
自己灵感/推演

259
incomplete
竞品跟进

260
incomplete
运营推广

261
incomplete
技术研发

262
incomplete
老板提的

263
incomplete
我党提的

264
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

### 2、功能目标：
全球市场订阅价格合理、对齐，新价格覆盖到各订阅策略，提升ARPU、收入

### 3、需求原型：

### 4、需求说明：

商品入口：

| 入口名称 | 入口ID | 分类名称 | 分类标识 ||
| 老用户取消年SKU支付挽留-美国 | 7427304195466217578 | 老用户取消年SKU支付挽留 | airbrush.olduser_cancel_year ||
| 老用户取消年SKU支付挽留-除美国 | 7382745827162748424 | 老用户取消年SKU支付挽留 | airbrush.olduser_cancel_year ||
| 新用户取消年SKU支付挽留-美国 | 7427301907884439307 | 新用户取消年SKU支付挽留 | airbrush.newuser_cancel_year ||
| 新用户取消年SKU支付挽留-除美国 | 7382747388534355487 | 新用户取消年SKU支付挽留 | airbrush.newuser_cancel_year ||
| 老用户取消月SKU支付挽留 | 7382747265158903323 | 老用户取消月SKU支付挽留 | airbrush.olduser_cancel_month ||
| 新用户取消月SKU支付挽留 | 7382746166251255309 | 新用户取消月SKU支付挽留 | airbrush.newuser_cancel_month ||

**实验1: 取消&quot;年&quot;支付的挽留**
原取消支付挽留优惠订阅策略，以新价格覆盖后，再实验包年首期7折 & 包年首期8折的成效。

| 对照组 | 实验组1 | 实验组2 ||
| 线上方案
iOS 

- 连续包年（旧价格）（取消年支付优惠价）

- 连续包月

- (连续包周）（美国才有）

GP

- 连续包年 （旧价格 ）（取消年支付优惠价）

- 连续包月

- 连续包季

- (连续包周）（美国才有）

 | 

iOS 

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）

- 连续包月

- (连续包周）（美国才有）

GP

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）

- 连续包月

- 连续包季

- (连续包周）（美国才有）

 | 

iOS 

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）

- 连续包月

- (连续包周）（美国才有）

GP

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）

- 连续包月

- 连续包季

- (连续包周）（美国才有）

 ||

**实验2: 取消&quot;月&quot;支付的挽留**
原取消支付挽留优惠订阅策略，以新价格覆盖后，再实验包月首期7折 & 包月首期8折的成效。

| 对照组 | 实验组1 | 实验组2 ||
| 线上方案
iOS 

- 连续包年 

- 连续包月 （旧价格）（取消月支付优惠）

GP

- 连续包年 

- 连续包月 （旧价格）（取消月支付优惠）

- 连续包季

 | 

iOS 

- 连续包年 

- 连续包月 （新价格首期7折）（取消月支付优惠）

GP

- 连续包年 

- 连续包月 （新价格首期7折）（取消月支付优惠）

- 连续包季

 | 

iOS 

- 连续包年 

- 连续包月 （新价格首期8折）（取消月支付优惠）

GP

- 连续包年 

- 连续包月 （新价格首期8折）（取消月支付优惠）

- 连续包季

 ||

pre环境：
对应正式环境入口名称：
老用户取消年SKU支付挽留-美国
老用户取消年SKU支付挽留-除美国

| 对照组 (线上方案） | 实验组1 | 实验组2 ||
| iOS

- 商品名稱： 老用戶-连续包年（取消年支付优惠价）

- 三方ID：airbrush.subs.month12.func00.lev00.campaign.instant2023.ver2 

- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 商品名稱： 老用戶-连续包年（取消年支付优惠价）

- 三方ID：com.meitu.airbrush.12mo_discount30

- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季

- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 | iOS 

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）
- 三方ID：com.meitu.airbrush.autorenew.vip7

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）

- 三方ID：com.meitu.airbrush.subscription.vip16

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季

- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 | iOS

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）
- 三方ID：com.meitu.airbrush.autorenew.vip8

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）

- 三方ID：com.meitu.airbrush.subscription.vip17

- 商品名稱： 连续包月
- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 ||

pre环境：
对应正式环境入口名称：
新用户取消年SKU支付挽留-美国
新用户取消年SKU支付挽留-除美国

| 对照组 (线上方案） | 实验组1 | 实验组2 ||
| iOS

- 商品名稱： 新用户-连续包年（取消年支付优惠价）

- 三方ID：airbrush.subs.month12.func00.lev00.campaign.recall30.ver0 

- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 商品名稱： 新用户-连续包年（取消年支付优惠价）

- 三方ID：airbrush.subs_12mo_30off_2024.func00

- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季

- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 | iOS 

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）
- 三方ID：com.meitu.airbrush.autorenew.vip7

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 连续包年（新价格 包年首期7折） （取消年支付优惠价）

- 三方ID：com.meitu.airbrush.subscription.vip16

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季

- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 | iOS

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）
- 三方ID：com.meitu.airbrush.autorenew.vip8

- 
- 商品名稱： 连续包月

- 三方ID：com.meitu.airbrush.autorenew.vip2

- 商品名稱： 连续包周 （美国才有）
- 三方ID： com.meitu.airbrush.autorenew.vip4

GP

- 连续包年（新价格 包年首期8折） （取消年支付优惠价）

- 三方ID：com.meitu.airbrush.subscription.vip17

- 商品名稱： 连续包月
- 三方ID：com.meitu.airbrush.subscription.vip2

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

- 商品名稱：連續包周（美国才有）
- 三方ID：com.meitu.airbrush.subscription.vip11

 ||

pre环境：
对应正式环境入口名称：
老用户取消月SKU支付挽留

| 对照组 (线上方案） | 实验组1 | 实验组2 ||
| iOS

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 老用户-连续包月（取消月支付优惠）

- 三方ID：airbrush.subs.month1.func00.lev00.campaign.instant2023.ver0

GP

- 商品名稱： 老用户-连续包月（取消月支付优惠）

- 三方ID：airbrush.subs.func00.lev00.1mo.instant

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

 | iOS

- 
- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 连续包月首月7折(取消年支付优惠价)

- 三方ID：com.meitu.airbrush.autorenew.vip13

GP

- 商品名稱： 连续包月首月7折(取消月支付优惠价)

- 三方ID：com.meitu.airbrush.subscription.vip18

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

 | iOS

- 
- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 连续包月首月8折(取消年支付优惠价)

- 三方ID：com.meitu.airbrush.autorenew.vip14

GP

- 商品名稱： 连续包月首月8折(取消月支付优惠价)

- 三方ID： com.meitu.airbrush.subscription.vip19

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

 ||

pre环境：
对应正式环境入口名称：
新用户取消月SKU支付挽留

| 对照组 (线上方案） | 实验组1 | 实验组2 ||
| iOS

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 新用户-连续包月（取消月支付优惠）

- 三方ID：airbrush.subs.month1.func00.lev00.campaign.recall30.ver0

GP

- 商品名稱： 新用户-连续包月（取消月支付优惠）

- 三方ID：airbrush.subs_1mo_30off_2024.func00

- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季

- 三方ID：com.meitu.airbrush.subscription.vip6

 | iOS

- 
- 商品名稱： 连续包年

- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 连续包月首月7折(取消月支付优惠价)

- 三方ID：com.meitu.airbrush.autorenew.vip13

GP

- 商品名稱： 连续包月首月7折(取消月支付优惠价)
- 三方ID： com.meitu.airbrush.subscription.vip18

- 商品名稱： 连续包年
- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

 | iOS

- 商品名稱： 连续包年
- 三方ID：com.meitu.airbrush.autorenew.vip1

- 商品名稱： 连续包月首月8折(取消月支付优惠价)

- 三方ID：com.meitu.airbrush.autorenew.vip14

GP

- 商品名稱： 连续包月首月8折(取消月支付优惠价)
- 三方ID： com.meitu.airbrush.subscription.vip19

- 商品名稱： 连续包年
- 三方ID：com.meitu.airbrush.subscription.vip5

- 商品名稱： 连续包季
- 三方ID：com.meitu.airbrush.subscription.vip6

 ||

### 5、统计需求：

### 6、翻译需求：
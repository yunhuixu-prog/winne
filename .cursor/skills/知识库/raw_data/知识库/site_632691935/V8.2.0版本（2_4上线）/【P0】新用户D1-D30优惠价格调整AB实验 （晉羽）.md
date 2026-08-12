# 【P0】新用户D1-D30优惠价格调整AB实验 （晉羽）

**页面ID**: 658385648

**路径**: V8.2.0版本（2_4上线）/【P0】新用户D1-D30优惠价格调整AB实验 （晉羽）

---

**JIRA地址： **

#### 前置项

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

| 2020.5.21 | xxx | 细节补充：广告不在本需求调整范围内（红色字体标注） | 举例说明 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景：

- Airbrush根据最新调价实验，已全量上线新涨价的价格，因此原线上的订阅策略，需根据新价格重新测试。
- AB测试原订阅策略D1-D30天新用户优惠（连续包年首年优惠7折）的原始价格，以及覆盖新价格后的首年优惠7折和首年优惠8折的AB实验。

需求定性

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
入口名称：新用户D1-D30优惠
入口ID： 7382746629356942866
分类名称：新用户D1-D30优惠
分类标识：airbrush.newuser_day1_30_offer 

原新用户D1-D30优惠订阅策略，以新价格覆盖后，再实验包年首期7折 & 首期8折。

| 对照组 | 实验组1 | 实验组2 ||
| 线上方案
iOS 
旧价格 包年首期7折
连续包月

GP
旧价格 包年首期7折
连续包月
连续包季
 | 

iOS 
新价格 包年首期7折
连续包月

GP
新价格 包年首期7折
连续包月
连续包季
 | 

iOS 
新价格 包年首期8折
连续包月

GP
新价格 包年首期8折
连续包月
连续包季
 ||

| 对照组 (线上方案） | 实验组1 | 实验组2 ||
| iOS
连续包年（新用户D1-D30优惠）
airbrush.subs.month12.func00.lev0.campaign.newuserdiscount.ver0
商品ID：7377178842903365453

连续包月
com.meitu.airbrush.autorenew.vip2
商品ID：7396026501508389645

GP
连续包年（新用户D1-D30优惠）
airbrush.sub.mon12.fun00.lev00.newdis30
商品ID：7377171585834697855

连续包月
com.meitu.airbrush.subscription.vip2
商品ID：7396046937344459896

连续包季
com.meitu.airbrush.subscription.vip6
商品ID：7399092450977398976
 | iOS 
新 - 连续包年（新用户D1-D30优惠7折）
com.meitu.airbrush.autorenew.vip7

连续包月
com.meitu.airbrush.autorenew.vip2
商品ID：7396026501508389645

GP
新 - 连续包年（新用户D1-D30优惠7折）
com.meitu.airbrush.subscription.vip16

连续包月
com.meitu.airbrush.subscription.vip2
商品ID：7396046937344459896

连续包季
com.meitu.airbrush.subscription.vip6
商品ID：7399092450977398976
 | iOS
新 - 连续包年（新用户D1-D30优惠8折）
com.meitu.airbrush.autorenew.vip8

连续包月
com.meitu.airbrush.autorenew.vip2
商品ID：7396026501508389645

GP
新 - 连续包年（新用户D1-D30优惠8折）
com.meitu.airbrush.subscription.vip17

连续包月
com.meitu.airbrush.subscription.vip2
商品ID：7396046937344459896

连续包季
com.meitu.airbrush.subscription.vip6
商品ID：7399092450977398976
 ||

### 5、统计需求：

### 6、翻译需求：
# 【P0】接入LiveX支付挽留AB实验（忻恬）—仅iOS

**页面ID**: 639223450

**路径**: V8.1.0版本（1_21上线）/【P0】接入LiveX支付挽留AB实验（忻恬）—仅iOS

---

**JIRA地址： **

#### 前置项

| 模块
 | 负责人|到期时间
 | 进度
 | 备注
 ||
| 用户画像 | 高蕾 | 开发中，预计12/17可提供 | 
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
| 2020.5.21 | xxx | 细节补充：广告不在本需求调整范围内（红色字体标注） | 举例说明 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景：

##### 1、目的 WHAT

- LiveX [https://www.livex.ai/](https://www.livex.ai/) 提供AI Agent服务，通过在特定时刻与用户进行交互帮助产品提升用户满意度，从而提升用户的留存率。常用在客服场景、挽留场景等。

- 竞品Fotor（桌面端）通过接入LiveX，在用户解约时进行挽留，试用转化率提升了3倍。

- AirBrush希望接入LiveX，尝试在用户在订购页面调起收银台却取消支付时，通过AI Agent进行挽留，提升用户的订阅成功率，从而提升总收入。

- 首期仅iOS接入进行验证。

##### 2、目标与收益预期 WHY & Expected Return

- AirBrush 2025年6月，日均sub click uv 28,602，sub success uv 7,240，支付成功转化率为25.3%。

- 本次进行AB实验，对比LiveX AI Agent与线上取消支付时的挽留策略的效果。期望接入LiveX的组别（实验组）提升支付成功转化率+10%至27.8%。

##### 3、竞品 Competitive
案例为fashionpass（客服场景），在首页右下角点击chatbot入口进入AI Agent客服

需求定性

| 需求来源 | 需求创新性 | 目标用户 | 目标用户标签🏷️（如宠物、电商、宝妈、摄影爱好者等） | 目标用户的需求频次 | 对产品复杂度的影响 | 对用户满意度预判 | 预估能否带来口碑传播 ||
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

- 期望接入LiveX的组别（实验组）提升支付成功转化率+10%至27.8%。

### 3、需求原型：

### 4、需求说明：

##### 1、实验简述
非会员于常规订购页（非促销期间、非onboarding场景）调起收银台却取消了支付后，做如下AB实验：

- 对照组：当前线上策略，调起问卷并根据问卷填写结果下发连续包年优惠SKU或展示7天试用介绍页

- 实验组：调起LiveX的对话页面，LiveX通过对话对用户进行挽留

2、实验组方案详细说明

- 实验平台：仅iOS
- 实验人群：仅非会员，会员不触发
- 触发时机：非促销期间、非onboarding场景，在常规订购页调起收银台却取消了支付后
- 触发频率：同对照组，触发间隔为**7天**，距上次触发事件7*24小时后，再次满足条件才触发
- 触发实验组后流程：
- 用户进入LiveX的webview页面，具体对话内容由LiveX提供

- 挽留商品融入LiveX对话：AI Agent在特定时机可向用户推荐线上的挽留商品（优惠SKU 或 7天试用年SKU）

- 关闭对话页面即回到上一级页面（订购页）

- 如果在LiveX对话过程中有向用户推荐优惠SKU（触发了折扣挽留），则回到订购页后24h内，该优惠SKU将展示在订购页（同对照组逻辑）

##### 3、LiveX接入流程（待技术进一步确认）
3.1、我们将用户画像传给LiveX。画像包含用户在app内的活跃程度、用什么功能多、如何进入付费页面等数据。

- 可以使用的数据维度在隐私协议里体现：[https://airbrush.com/legal/privacy-policy](https://airbrush.com/legal/privacy-policy)

- 传递的画像信息包含：

| 序号
 | 标签
 | 标签名称
 | 说明
 ||
| 1
 | BASIC_944
 | 付费潜力概率
 | 用户在接下来一年内订阅付费的概率值
 ||
| 2
 | BASIC_782
 | 近30日累计进入订阅页的次数-主动类
 | 主动进入订阅页的次数（除弹窗强制类的其他，包括订阅横幅，编辑页保存打勾等）
 ||
| 3
 | BASIC_747
 | 近30天修图二级功能偏好top3
 | 使用top3的修图二级分类功能的次数
 ||
| 4
 | BASIC_9
 | 手机型号(最近)
 | 最近活跃的手机型号
 ||
| 5
 | BASIC_2
 | 常驻地-国家
 | 取最近365天活跃的最多的国家
 ||
| 6
 | BASIC_3
 | 最近国家
 | 最近活跃的国家
 ||
| 7
 | BASIC_927
 | 近30天活跃天数
 | 不包含今日往前推30天，活跃天数
 ||

3.2、LiveX提供API，当用户在app内取消支付时调用API，进入AI挽留流程。挽留页面可以选择native or webview。native的页面需要自己研发，webview页面可以直接用LiveX的SDK实现。&mdash;&mdash;**考虑直接使用webview，UI提供AB的主题色、agent头像等元素**
3.3、挽留话术由LiveX准备（通过学习app的介绍、功能等），我们无需介入。但支持把挽留的优惠商品嵌入挽留流程。

##### 4、LiveX收费策略
前3个月为合作试验期，期间的收费方式为：

- 20% of (Test Group Revenue &ndash; Control Group Revenue), calculated after Apple Store tax and users' refunds

- 20%（实验组收入 - 对照组收入），收入为扣除苹果分成和用户退款后的收入。仅包含首单收入，不包含续费收入

- 该部分收入仅限取消支付挽留场景，即：

- 对照组的收入来源仅包含：挽留折扣SKU弹窗、挽留7天试用时间线页面、触发折扣挽留后24h常规订购页

- 实验组的收入来源仅包含：在LiveX对话中调起挽留商品进行付费、触发折扣挽留后24h常规订购页

- No minimum fee

##### 5、合作期间需要提供给对方的数据报表

- 对照组和实验组每日在挽留场景下调起收银台的PV&UV（需要区分来源）

- 对照组包含：从挽留折扣SKU弹窗调起收银台、挽留7天试用时间线页面调起收银台、触发折扣挽留后24h常规订购页调起收银台

- 实验组包含：在LiveX对话中调起收银台、触发折扣挽留后24h常规订购页

- 对照组和实验组每日在挽留场景下的收入（场景同2.5，希望注明苹果税、退款部分）

附：当前支付挽留线上相关数据
[https://pixocial.feishu.cn/sheets/LysLsNR51hXFJPtpyMZc99DknNb?sheet=7y7o0c](AirBrush订阅挽回策略data 2025.6.1~6.30)

### 5、统计需求：

### 6、翻译需求：
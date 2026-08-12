# 【P1】其他：About Airbrush页面支持复制gid（忻恬）

**页面ID**: 646831467

**路径**: V8.0.0版本（1_7上线）/【P1】其他：About Airbrush页面支持复制gid（忻恬）

---

**JIRA地址： **

#### 前置项

| 模块
 | 负责人|到期时间
 | 进度
 | 备注
 ||
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

- 当前运营及客服给用户发放会员的方式是用三方商店的promo code能力，但苹果即将在2026年3月下线该能力。因此后续发放会员流程将改为和集团一致：用户提供gid&mdash;&mdash;>运营客服在订阅后台为用户添加会员时长。
- 但当前获取用户gid的流程繁琐（用户通过help center发送消息到zendesk，然后zendesk会获取到用户gid，客服再去zendesk找对应用户的gid），因此本期将支持用户在应用内自行复制gid的能力。

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

- 在About Airbrush页面新增用户自行获取gid的隐性入口，在保护大部分用户隐私的同时，方便部分有需要的用户获取gid提供给客服。

### 3、需求说明：
双端Settings&rarr;About Airbrush页面新增隐性复制gid入口：

- 长按3秒如图红框区域【版本号】文案区域，复制当前设备gid，复制成功后toast提示 "感谢您的支持！"
- v8.5.0版本长按秒数由3s调整到1.5s

### 4、统计需求：

### 5、翻译需求：
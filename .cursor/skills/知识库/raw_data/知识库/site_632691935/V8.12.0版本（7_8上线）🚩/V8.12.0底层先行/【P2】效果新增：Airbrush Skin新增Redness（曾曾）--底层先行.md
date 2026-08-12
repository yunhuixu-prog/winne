# 【P2】效果新增：Airbrush Skin新增Redness（曾曾）--底层先行

**页面ID**: 702258913

**路径**: V8.12.0版本（7_8上线）🚩/V8.12.0底层先行/【P2】效果新增：Airbrush Skin新增Redness（曾曾）--底层先行

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
complete
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
complete
底层

 | 

1215
complete
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
| 2026.6.10 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**看自己：**通过上半年AB功能数据洞察显示，当前用户中**White 用户占 27.6%，Latin 用户占 50.9%，二者合计 78.5% 为浅肤色群体**。浅肤色人群的皮肤泛红（Redness）问题在视觉上更加显著，因此用户对&quot;均匀肤色&quot;类功能的需求极为强烈，但AB目前尚未对&quot;泛红去除&quot;这一细分场景做专门覆盖；Retouch模块数据和洞察👉[https://cf.meitu.com/confluence/x/EDLPKQ](https://cf.meitu.com/confluence/x/EDLPKQ)
**看用户：**从用户本身肤质画像来看，欧美成年高加索人群中，玫瑰痤疮（Rosacea）发病率约为 **5%&ndash;10%**，是一种常见的慢性炎症性皮肤病，典型表现为面颊、鼻部、下巴等区域持续性泛红和毛细血管扩张。这一数据进一步印证了泛红问题在欧美市场的普遍性和刚性需求。
**看市场：**从市场需求来看，丝芙兰等主流美妆渠道的热销粉底液产品，核心卖点高度集中于**&quot;均匀肤色&quot;和&quot;遮盖泛红&quot;**（洞察报告 P13），说明消费者在日常美妆场景中对泛红修正存在持续且明确的需求。这也从侧面表明：修图工具中缺乏专门的去红能力，是当前用户体验链路中的一个显著缺口。260509肤质模块洞察
[https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNSgnUTAlGSY0yfCX9?scode=ACIAJAeGAAgCI6PNwsAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNSgnUTAlGSY0yfCX9?scode=ACIAJAeGAAgCI6PNwsAdUAnwaPAHA)

**综合以上背景，计划针对AB skin能力进行优化升级：**
**1）效果上：**解决多族裔色沉/瑕疵祛除不干净/泛红问题

- 接入匀肤，单独解决泛红问题

需求定性**

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
complete
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
complete
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

**功能数据目标（勾选对应指标）**

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
complete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

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
匀肤接口：
算法对接人：林顺达
设计师：莫策

| 原型图 | 需求描述 ||
| 
 | **入口：Retouch- Skin-Redness**（第六位）**
**效果参数：（待设计师@莫策 明确）**
**视觉：**

- 新增 **Redness**** Icon
- Skin UI增加New角标，用户点击后消失
- Redness上方新增New角标，用户点击后消失

**交互流程**

- 进入Skin，进入Redness**，****进入三级页面，支持自动，手动，橡皮擦，默认自动（界面和交互方式follow smooth）

**固化逻辑**

- 打勾即固化

**多人脸/网络错误等其他逻辑**

- Follow skin线上

**其他-算法方案**

- 本地方案

**订阅方案**

- follow忻恬本地功能订阅逻辑：[https://cf.meitu.com/confluence/x/kLvbKQ](https://cf.meitu.com/confluence/x/kLvbKQ)
- 非订阅用户终身限免**20**次，超过次数订阅横幅+打勾拦截

 ||

## 五、订阅相关

## 六、协议跳转
新功能，需要新的DL链接🔗：
七、翻译

## 八、埋点需求
**Redness****的曝光/点击/打勾/保存/订阅的UV/PV埋点
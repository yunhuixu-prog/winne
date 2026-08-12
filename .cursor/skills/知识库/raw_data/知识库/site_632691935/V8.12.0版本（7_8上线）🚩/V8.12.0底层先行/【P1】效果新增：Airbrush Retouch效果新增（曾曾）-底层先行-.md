# 【P1】效果新增：Airbrush Retouch效果新增（曾曾）-底层先行-

**页面ID**: 703957959

**路径**: V8.12.0版本（7_8上线）🚩/V8.12.0底层先行/【P1】效果新增：Airbrush Retouch效果新增（曾曾）-底层先行-

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
| 2026.6.09 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Retouch 作为核心高收入、高用户渗透的功能，是平台用户留存与商业变现的关键抓手。为持续放大其数据增长潜力，我们计划基于用户真实需求与市场流行趋势，对该能力进行效果拓展。
本次升级将以数据与海外审美洞察为核心依据，将 AI Retouch 能力重新划分为三大方向：**通用风格类、定向人群类、人像问题解决类**。针对性补充高潜力、高可行性的新效果，以快速响应用户需求、提升功能渗透率与用户粘性，进一步打开该模块的数据增长空间。
数据洞察和效果规划：[https://cf.meitu.com/confluence/x/EDLPKQ](https://cf.meitu.com/confluence/x/EDLPKQ)

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
1）效果定义和描述

2）功能描述

| 原型图 | 需求描述 ||
| 
 | 效果新增**

- 淡颜光泽-Dewy--纯本地
- 眼部提升-Eye lift--纯本地
- 年轻提拉-Defined--纯本地
- 下颌提拉-Chin lift&ndash;本地+AI子项

具体效果串联子项见👉：[https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNQ9VE03gUTLSfo1vS?scode=ACIAJAeGAAghssFYc1AdUAnwaPAHA](Retouch-新效果定义)
**素材排序**
**Retouch：Natural、Smile、Cute、Dewy、Refine、Even、Delicate、Clean、Sculpted、Defined、Eye lift、Chin lift、Modle、Chiselled、Glowy**
****
**交互视觉**

- 角标：Retouch UI，4个新增素材，用户点击后消失
- 红点：Retouch tab，用户切换tab再次点击后消失
- loading组件：Follow线上

**素材叠加/互斥/固化**

- 同Tab：不固化，与其他Retouch素材互斥，点击素材即切换效果
- 不同Tab：切换Ai五官Tab并使用新效果即固化，基于固化结果生成新效果

**滑杆**

- 单根滑杆，控制整体效果的不透明度，默认值待设计师确认
- Dewy--70%
- Eye lift--70%
- Defined--70%
- Chin lift--70%

**undoredo/多人脸/网络/请求失败**

- Follow当前线上逻辑

**订阅**
Chin lift、Defined、Dewy（云端）

- 走策略 2，非会员每天 30 次，会员每天 50 次（全素材共享限免次数）
- 非会员限免使用后提示剩余次数，限免次数使用完后，不可再次请求效果。（请求效果展示兜底图）

Eye lift（本地）

- follow忻恬本地功能订阅逻辑：[https://cf.meitu.com/confluence/x/kLvbKQ](https://cf.meitu.com/confluence/x/kLvbKQ)
- 
- 非订阅用户：
- 美英澳：终身限免**3**次
- 其他国家：终身限免**10**次
- 超过次数订阅横幅+打勾拦截

 ||

## 六、协议跳转
七、翻译

## 八、埋点需求

- Dewy、Eye lift、Defined、Chin lift的曝光/点击/打勾/保存/订阅的UV/PV
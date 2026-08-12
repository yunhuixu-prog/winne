# 【P1】功能新增：Airbrush Makeup新增Freckles（曾曾）

**页面ID**: 605948841

**路径**: V8.6.0版本（4_8上线）/【P1】功能新增：Airbrush Makeup新增Freckles（曾曾）

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
complete
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
| 2026.3.09 | 曾曾 | 创建文档 | 
 ||
| 2026.3.26 | 曾曾 | 增加雀斑妆容叠加逻辑 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
1️⃣**审美趋势：**在欧美主流审美中，雀斑的地位在近十年经历了巨大的反转，从过去想要遮盖的"瑕疵"，变成了如今**"****自然美****"****与****"****高级感****"**的代名词，在 TikTok 和 Instagram 上，#freckles 相关的标签拥有数十亿次的播放量。"Faux Freckles"(假雀斑妆)是过去几年最火的化妆趋势之一。
2️⃣**雀斑代表的审美价值：**雀斑被视为拒绝"塑料假脸"的标志，**它传递出一种****"****我接受并热爱我原始肤质****"****的自信**，也与阳光、户外活动相关联，在视觉心理上，它能让人联想到**健康的户外生活方式和旺盛的生命力**；
因此AB计划在美妆模块新增雀斑模块，以承接用户需求，增加欧美用户付费意愿

**竞品分析**

- **face app：**共5款素材，传统素材方案，可调节强度，覆盖不同密集程度值的雀斑款式
- **face app：**共1款素材，AI方案，5档不同程度值的雀斑强度

| face app | face tun ||
| 
 | 
 ||

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
complete
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
complete
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
complete
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
complete
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
complete
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

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
complete
20万以上

1142
incomplete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

数据回收时间：5.8

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

## 五、效果定义

- 首批新增5款（部分复用自B+，经过数据验证），3免费2订阅
- 效果默认程度值：暂定80

| 款式1
Sprinkled
 | 款式2
Cheek
 | 款式3
Dappled
 | 款式4
Naive 💰
 | 款式5
Wild 💰
 ||
| 
 | 
 | 

 | 
 | 
 ||
| 自然
贴合原生皮肤肌理质感雀斑
 | 自然
两颊雀斑 模拟阳光面颊晒斑
 | 个性风格款全脸雀斑
 | 俏皮活力的面中鼻梁局部雀斑
（B+订阅转化最佳）
 | 野生风格 覆盖面中区域 重点表现鼻梁和颧骨侧 ||

## 六、需求描述

| 原型图 | 功能详情说明 ||
| 
 | 
- **功能入口：**Retouch**-**Makeup-Freckles（美妆底部新增Tab）
- **功能排序：**Looks , Lipstick , Blush , Contouring , Freckles , Eyebrows , Eyelashes , Eyeshadow , Eyecolor（第五位）
- **素材数量：**新增 5 款素材
- **素材排序：**Sprinkled、Cheek、Dappled、Naive、Wild
- **素材默认程度值：**暂定80（后续设计师根据验收实际情况来定）
- **交互流程：**纯素材类新增，交互流程follow目前线上逻辑
- **订阅策略：**follow当前美妆订阅策略，按单个素材订阅 
- 免费素材：Cheek、Sprinkled、Dappled
- 订阅素材💰：Naive、Wild

- **其他**
- Freckles Tab新增小红点，用户点击后消失
- 底部Tab的选中态需要用新的（hair模块样式）
- 雀斑妆容与其他妆容为叠加逻辑，即
- 使用整妆后使用雀斑，应在原来妆容上做叠加而非替换
- 其他妆容的逻辑不受影响，仍为替换逻辑

 ||

## 七、协议跳转
新功能，需研发新增DL链接。按照功能结构补充至deeplink cf文档：
IOS🔗：
安卓🔗：

## 八、翻译

| 英文 | 中文 ||
| Freckles | 雀斑 ||

## 九、埋点需求

| 英文 | 中文 ||
| Freckles | 点击/打勾/保存/订阅的UV/PV ||
| 素材FK01-FK05的 | 点击/打勾/保存/订阅的UV/PV ||
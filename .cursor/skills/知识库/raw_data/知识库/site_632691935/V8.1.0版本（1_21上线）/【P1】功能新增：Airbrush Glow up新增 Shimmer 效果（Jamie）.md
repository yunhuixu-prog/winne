# 【P1】功能新增：Airbrush Glow up新增 Shimmer 效果（Jamie）

**页面ID**: 655409456

**路径**: V8.1.0版本（1_21上线）/【P1】功能新增：Airbrush Glow up新增 Shimmer 效果（Jamie）

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
| 2025.12.29 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 在欧美市场中 无论是日常出街、夏日露肤还是派对造型，Body Shimmer 都能让身体闪耀，用它点亮肌肤，打造"会发光的身体妆效"。高光的使用普遍用于人脸，但观察到当下的趋势已由面部延展至身体。在皮肤上涂抹高光已成为当下的一种妆容风向，通过在肌肤表面轻抹带有细腻珠光的高光油或乳液，让光线在皮肤上自然折射，形成流动的亮泽光感，不仅能够强化身体的线条与轮廓，也赋予肌肤通透、饱满的光泽质地。
- 因此 glow up 二期计划新增该效果，带动短期社媒分享与glowup的点击/留存及社交分享。

市场情况：

- 明星/红人通过社媒持续输出相关内容，使 body shimmer 在平台上保持高热度，并表现出明显的「**夏季性流行**」特征。
- 在身上加上光泽油＆微亮粉妆容，从 2024 年底至 2025 全年为欧美彩妆产品线的持续热推重点，反应出相关方向的高需求。

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
incomplete
基础优化

266
incomplete
人有我有（参考x产品）

267
complete
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
需求能带来多大的数据提升

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

## 五、需求描述
1、如涉及算法，注明算法相关信息

| xxxx算法接口 | link ||
| 单张成本 | 约 xx 元/次 ||
| demo地址 | 
 ||
| 算法对接人 | 李明悦 ||
| 效果设计师 | 田梅琳 ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| 

 | **功能入口**

- Retouch-Glow up-Sun-kissed

**
功能协议**

- **新增跳转至 Shimmer 效果并应用
**

**功能交互**

- 点击 Shimmer，进入 loading流程并展示实时进度
- 进度条样式：其余所有Ai素材使用该进度样式

- 滑杆常驻，展示 1 根滑杆：
- Sun blush：效果强度滑杆，默认强度50%
- 滑杆组件复用Relight里的样式

- 该效果不支持叠加，点击其他效果则直接替换
- 在当前面板中，切换其他效果，需保留 Shimmer 的调节强度
- 在当前面板中切换效果，不重新跑 loading 流程

**角标/位置：**

- 首次进入展示「New」，点击1次后不再展示
- 排在第三位

- 排序更改：
Flawless, Natural Tan, Shimmer, Soft Glow, Body Glow, Matte, Sun-kissed, Tanned

**其他：**

- 记忆规则/多人脸/网络异常等与当前线上逻辑保持一致
- 支持无人脸（必须要有skin）

**新增小气泡：**
Glow up 新增 小气泡指引

- **移除** 面部丰盈小气泡
- 在 glow up 图标上方展示「小气泡」
- 点击气泡跳转进入 glow up 内，选中并请求 Shimmer 效果
- 气泡文案：Shimmer On Your Skin!
- 小气泡规则，参考[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=613432396](【P1】功能新增：AirBrush新增小气泡指引（刘晓）)

 ||

3、如涉及订阅限免策略调整，与订阅同学讨论后由订阅同学补充对应内容
**走限免策略二**

| 功能 | 介面 | 面向非会员策略 | 面向会员策略 ||
| Glow Up | 
 | 【次数上限】
每日限免20次
【触发时机】
点击Apply/Retry按钮时
 | 与glow up内其他AI素材共享每天限免50次请求

 ||

- 具体交互follow AI功能订阅策略需求：[https://cf.meitu.com/confluence/x/oli4Iw](https://cf.meitu.com/confluence/x/oli4Iw)

## 六、协议跳转

## 七、翻译

| 中文 | en ||
| 珠光** | Shimmer ||
| **肌肤自带珠光**
 | Shimmer On Your Skin! ||

## 八、埋点需求

- 曝光 PV/UV
- 请求次数 PV/UV
- 保存次数 PV/UV
- 滑杆强度参数
- 成本埋点 
- 订阅转化埋点
- 小气泡相关埋点 曝光/点击
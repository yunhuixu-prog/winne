# 【P1】功能新增：Airbrush web 增加AI胡须功能（曾曾）

**页面ID**: 649358658

**路径**: V8.0.0版本（1_7上线）/v8.0.0 web需求/【P1】功能新增：Airbrush web 增加AI胡须功能（曾曾）

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
| 2025.12.15 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为给AB app端引流，计划在 Web 端接入 App 内已成熟的 **AI 胡须**能力，通过 Web 场景承接更多自然流量，引导用户进一步下载并使用 App，从而实现 Web 向 App 的有效引流与转化。

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
/

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

- **PC端**

- **手机端**

## 五、需求描述
1、如涉及算法，注明算法相关信息

| xxxx算法接口 | [https://cf.meitu.com/confluence/x/0vzZH](https://cf.meitu.com/confluence/x/0vzZH) ||
| demo地址 | xxx ||
| 算法对接人 | xxx ||
| 效果设计师 | xxx ||

2、需求描述

| 原型图 | 功能详情说明 ||
| 
- **PC端界面**

- **移动端界面**

 | **功能名称：**AI Beard
**功能位置：**Online tools - Portrait Tools
**效果款式：**提供7款胡须款式，具体如下

- Shaved、Hipster、Full Beard、Goatee、Mustache、Petite Goatee、Circle Beard

**交互流程：**

- 用户进入AI beard，进入上传图片页面流程
- 上传完图片后，7款胡须icon显示
- 默认「Shaved」选中
- 用户选择胡须效果，点击「Generate」，进入loading流程，并生成对应结果
- 「Generate」按钮下实时显示剩余限免次数，文案「x free uses left」，次数用完则数字依次递减

- 用户生成图片时扣减次数（逻辑顺序: 次数 &rarr; Credits )，资源用完后，弹出导流弹窗，**导流弹窗**内容如下：
- **物料展示区：**
- 标题
- 文案「Download this app and explore more interesting features！」
- banner动图：16:9，最小800*450
- banner动图内容：
- 滚轮展示功能：发型/打光/面部丰盈/AI image

- 二维码（pc）/ 下载按钮（手机）用户无需登录即可顺利下载app
- 积分按钮
- 文案：Click to purchase credits for use
- 若用户已登录，点击则跳转充值积分页面，若用户未登录，点击则跳转登录页面

- **导流弹窗动画：**
- 
- 
- **下载弹窗：共用历史组件**

- 标题 Photo Saved!
- 文案 Download the app now to access advanced features and enjoy unlimited free downloads. 
- 二维码（pc）/ 下载按钮（手机）

**素材逻辑：**

- 所有胡须效果之间为**「相互互斥」**关系，不可叠加

**限免逻辑：**

- 同 Hair 逻辑，终身**「限免3次」**
- **文案：3** free trials

**其他：**

- undo/redo，重做，换图，下载等逻辑/流程follow当前web线上逻辑

**多人脸逻辑：**

- 胡须效果不支持多人脸，在图片上传流程中，若用户选择多人脸则弹出toast并将该图片置灰（已有逻辑和toast）

 ||
| 
- **导流弹窗：**

下载弹窗

 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
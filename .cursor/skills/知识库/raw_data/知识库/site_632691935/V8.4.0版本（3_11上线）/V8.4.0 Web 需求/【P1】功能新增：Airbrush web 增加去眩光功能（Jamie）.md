# 【P1】功能新增：Airbrush web 增加去眩光功能（Jamie）

**页面ID**: 669664778

**路径**: V8.4.0版本（3_11上线）/V8.4.0 Web 需求/【P1】功能新增：Airbrush web 增加去眩光功能（Jamie）

---

#### JIRA地址：link

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
incomplete
服务端

 | 

1210
incomplete
底层

 | 

1211
incomplete
iOS

 | 

1212
incomplete
Android

 | 

1213
incomplete
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
| 2026.2.10 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 为给AB app端引流，计划在 Web 端接入 App 内的 去眩光 能力，通过 Web 场景承接更多自然流量，引导用户进一步下载并使用 App，从而实现 Web 向 App 的有效引流与转化。
- remove glare / remove flare 搜索詞 sv 在美國屬於穩定有搜索量級，且同時競爭者少的長尾搜索詞，屬於潛力不小的搜索詞方向，可以針對此長尾詞新增專門的功能頁面，以期帶來穩定的功能引流。

- 

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
 | 

273
incomplete
高频

274
incomplete
中频

275
complete
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

- **PC端

**

- **手机端****

**

## 五、需求描述
1、需求描述

| 原型图 | 功能详情说明 ||
| 
- **PC端界面**

- **移动端界面**

**弹窗请复用之前组件**

 | **功能名称：AI Magic Earser**
**功能位置：**Online tools - All Tools
**功能：**

- People、Text、Watermark、Wrinkles、Glare(本次新增）

**交互流程：**

- 用户进入 AI Magic Eraser Landing 页，点击上传图片按钮，拉起相册后上传图片
- 新增去眩光图标、效果物料

- 上传完图片后，需展示
- 大图、换图按钮、下载按钮（置灰）、拖拽/画笔toggle（默认拖拽）

- 新增去炫光图标

- 点击图标后

- 拖拽/画笔toggle 隐藏
- **面板处笔刷大小、橡皮擦切换组件 隐藏**

- **点击即消耗次数，次数用完后拉起app导流用弹窗**

**导流弹窗**

- **复用之前历史组件**

**接口信息**
① 去炫光接口文档：[https://insight-mtlab.meitu-int.com/doc/992](https://insight-mtlab.meitu-int.com/doc/992)
② 超分接口文档：
[https://insight-mtlab.meitu-int.com/document/editor?id=912&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=912&type=preview)
参数：&quot;parameter&quot;: {
 &quot;rsp_media_type&quot;: &quot;url&quot;,
 &quot;mode&quot;: &quot;去眩光&quot;
 }
 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
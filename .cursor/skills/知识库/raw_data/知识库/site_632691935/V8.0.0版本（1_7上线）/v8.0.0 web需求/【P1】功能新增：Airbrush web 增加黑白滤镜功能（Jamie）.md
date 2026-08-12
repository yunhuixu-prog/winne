# 【P1】功能新增：Airbrush web 增加黑白滤镜功能（Jamie）

**页面ID**: 650127323

**路径**: V8.0.0版本（1_7上线）/v8.0.0 web需求/【P1】功能新增：Airbrush web 增加黑白滤镜功能（Jamie）

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
| 2025.12.17 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 为给AB app端引流，计划在 Web 端接入 App 内的 黑白滤镜能力，通过 Web 场景承接更多自然流量，引导用户进一步下载并使用 App，从而实现 Web 向 App 的有效引流与转化。
- Black n white filter 搜索詞 sv 在美國屬於穩定有搜索量級，且同時競爭者少的長尾搜索詞，屬於潛力不小的搜索詞方向，可以針對此長尾詞新增專門的功能頁面，以期帶來穩定的功能引流。

竞品情况：

- Canva、photoroom、photoaid 都有針對此搜索詞做專門的功能頁面，

| photoaid | canva | photoroom ||
| 
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
****
 | **功能名称：Black and White Filter**
**功能位置：**Online tools - Image Tools
**效果款式：**提供 6 款黑白滤镜款式＋3 款其他滤镜素材＋more图标，首评展示 6.5 款素材，具体如下

- Tenacity、Classic、Noir、Rustic、Film、MON-5 
- 3 款其他滤镜素材＋more图标：接为锁定功能，仅能预览，点击后弹起弹窗。

**交互流程：**

- 用户进入B+W Filter，点击上传图片按钮，拉起相册后上传图片
- 上传完图片后，需展示
- 大图：展示套用滤镜套用效果
- 9 款小图黑白滤净素材实时预览显示，只有前 6 款能点击，后续 3 款点击后弹出弹窗 （PC则是从左至右、从上至下排序）
- 改用图标展示，滤镜预览会降低性能 &mdash; 26.02.10

- 9 款图标可左右滑动，默认选中「第一款」Tenacity，图标需呈现外框高亮选中态。
- 再次点击选中效果图标无反应
- **点击其他非选中图标可切换**
- 切换效果时也要扣减次数（逻辑顺序: 次数 &rarr; Credits )
- 若次数不够支付时，要拉起弹窗

- 仅可点击 6 款，剩馀 3 款点击要拉起引导下载app弹窗

- **下载按钮**
- 画布右上角，点击后级下载效果图
- 弹出下载弹窗 

- **换图按钮**
- 点击后可替换其他上传图，换图时须扣减次数。（逻辑顺序: 次数 &rarr; Credits )
- 若次数不够支付时，要拉起弹窗

**导流弹窗**

- 用户点击锁定的图标，需弹出导流弹窗，导流弹窗内容如下：

- 视频物料
- 标题
- 文案「Download this app to unlock exclusive filters！」
- 二维码（pc）/ 下载按钮（手机）
- 购买credit link
- 点击后

**下载弹窗：共用历史组件**

- 标题 Photo Saved!
- 文案 Download the app now to access advanced features and enjoy unlimited free downloads. 
- 二维码（pc）/ 下载按钮（手机）
- ios端才弹出，历史逻辑 &mdash; 26.02.10

**使用效果前校验，是否弹出导流弹窗：**

- 判断限免次数是否用完
- 未用完：直接扣减
- 用完：
- 是否登录
- 已登录
- 是否有积分
- 有 -> 直接消费
- 无 -> 弹引导弹出

- 未登录
- 弹引导弹窗

**素材逻辑：**

- 所有滤镜效果效果之间为**「相互互斥」**关系，不可叠加

次数为终身限免n次。
 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
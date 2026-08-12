# 【P1】体验优化：Airbrush Web 落地页改版（Zac）

**页面ID**: 688605892

**路径**: V8.9.0版本（5_20上线）/V8.9.0 Web 需求/【P1】体验优化：Airbrush Web 落地页改版（Zac）

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

#### 更改记录：

| 2026.04.27 | Zac | 创建文档 | v1.0
 ||
| 2026.05.05 | Zac | 基于内审更新 | v1.1 ||
| 2026.05.14 | Zac | 基于 UI 更新 | v1.2 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
当前 Airbrush 官网 **/tools/app 页面已上线多年，页面整体视觉风格及内容结构相对老旧**，与当前 AI 影像产品市场主流设计趋势存在明显差距。与此同时，页面展示的核心功能也较为陈旧，未能体现 Airbrush 当前产品能力升级及差异化优势，因此需要同步进行升级优化。
竞品情况：
Facetune、Remini、Picsart 等竞品官网已普遍升级为更现代的视觉风格，并重点展示 AI 效果及核心卖点

| Facetune：
官网视觉现代，强调自然变美、自我表达
 | Remini：
通过强 before/after 展示 AI 效果，视觉冲击力强
 | Picsart：
整体品牌年轻化，设计感强，突出创作能力与多功能生态
 ||
| | 
 | ||

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
UI稿：[https://www.figma.com/design/hBxfN3b8w5Bgqz7ZXOd9kZ/ABM-Landing-Page?node-id=1-2082&t=b2aB3AtaNam47kGA-0](https://www.figma.com/design/hBxfN3b8w5Bgqz7ZXOd9kZ/ABM-Landing-Page?node-id=1-2082&t=b2aB3AtaNam47kGA-0)
原型图：[https://www.figma.com/design/TGVOQmhRNznX26vgLDGcp6/Untitled?node-id=0-1&t=q3h5PrJvf6PmNn0k-1](https://www.figma.com/design/TGVOQmhRNznX26vgLDGcp6/Untitled?node-id=0-1&t=q3h5PrJvf6PmNn0k-1)

## 五、需求描述

### 页面结构概览
本次优化基于现有页面 **[https://airbrush.com/tools/app?utm_source=chatgpt.com](https://airbrush.com/tools/app)** 进行，不新建页面、不修改 URL。优化后页面整体由以下 section 组成：

| Landing Section | 页面首屏，说明 Airbrush App 核心定位，并**提供 App Store、Google Play、APK 下载**入口 ||
| Portrait Retouch | 展示人像编辑能力，重点突出 **AI Retouch、妆容和皮肤处理** ||
| Relight | 展示打光能力，重点展示**闪光灯、沙滩光、G7X** 及当前排名较靠前的光效 ||
| Eraser / Object Removal | 展示消除能力，重点突出**镜面消除、擦除笔**等高频清理场景 ||
| Video Retouch | 展示视频人像能力，重点突出**视频中的脸部和 Body** 编辑 ||
| AI Tools | 展示工具合集，包括 AI Replace、AI Expand、AI Repair、Eraser、Bokeh、Prism ||
| User Reviews | 展示用户评价，增强信任感 ||
| Pricing | 价格表，样式复用Web已有价格表 ||
| FAQ | 回答用户下载前常见问题，同时承接 SEO 长尾关键词 ||
| Footer | 沿用现有页脚结构 ||

| 原型图 | 功能详情说明 ||
| 
 | Landing Section
**保留内容**

- 保留页面URL：[https://airbrush.com/tools/app](https://airbrush.com/tools/app)
- 保留 App 下载入口跳转逻辑：
- Download on the App Store - 跳转苹果商城
Get it on Google Play - 跳转谷歌商城
Download Airbrush APK - 下载安卓 APK

**修改内容**

- 该模块采用 **居中标题 + 下方横向效果图** 的结构
- Section title
- Section description
- 下载按钮
- 头图：头图标题需后台配置

- 修改 H1 标题：Edit Photos Naturally - Download Airbrush App
- 修改副标题: Download Airbrush App to retouch portraits, fix lighting, remove distractions, edit videos, and create photos that feel ready to share, right from your phone.
- 修改APK下载标题：Download Airbrush APK
- 效果图交互逻辑：
- 效果图自动轮播，用户点击任意效果图后，选中图片居中
- 往下滚动有滚轮控制的视差效果，详情见 UI 稿

 ||
| 
 | Portrait Retouch Section

- 该模块用于展示 Airbrush App 的人像编辑能力，重点突出：

- AI Retouch
- 妆容
- 皮肤处理

- 页面展示内容
- 该模块采用 **标题 + 副标题 + 效果图** 的结构。

- 从左到右依次展示
- Section title
- Section description
- 三张动态效果图：动态效果图角标需后端配置

- 模块标题：Retouch Every Detail, Naturally
- 模块描述：Use AI Retouch, makeup, and skin tools to gently refine portraits while keeping the final look natural. Smooth skin, brighten details, and adjust your look without losing details.
- 
#### 效果图交互逻辑：三张 GIF 动图循环播放

 ||
| 
 | Relight Section

- 该模块用于展示 Airbrush App 的 Relight 打光能力，重点突出当前用户感知较强、排名较靠前的光效。

- 页面展示内容
- 该模块采用 **效果图 + 标题 + 副标题** 的结构。

- 页面左边展示一张横向效果图，内容包括：

- 效果图
- 底部 Relight 效果选项栏：效果栏名称需后台配置
- None
- Sunsoft
- G7X
- Flashnight
- Digicam
- 默认选中：Sunsoft

- 页面右边展示：
- Section title
- Section description
- 下载按钮

- 模块标题：Set the Mood with Relight
- 模块描述：Try different lighting effects to make your photo feel brighter, softer, warmer, or more atmospheric. Choose the look that fits the moment, even after the shot.
- 效果图交互逻辑：
- 用户点击底部任意 Relight 效果：

- 当前点击项高亮
- 主图切换为对应 Relight 效果
- 其他效果选项取消高亮
- 若用户点击 None，主图切换回原图
- 效果切换过程中可展示轻量 loading 状态

 ||
| 
 | Eraser / Object Removal Section

- 该模块用于展示 Airbrush App 的消除能力，重点突出镜面消除、擦除笔等高频清理场景。

**页面展示内容**

- 页面展示内容
- 该模块采用 **标题 + 副标题 + 效果图** 的结构。

- 从左到右依次展示
- Section title
- Section description
- 下载按钮
- 四种效果

- 页面右边展示一张横向效果图，内容包括：
- 带有干扰物的主
- 消除前 / 消除后对比效果
- 底部或侧边功能选项：功能名需后台配置
- Mirror
- Eraser
- Object Removal
- Passerby

- 模块标题：
- Remove Distractions in One Tap with Airbrush App

- 模块描述：
- Remove mirror marks, background clutter, small distractions, or unwanted objects with easy cleanup tools. Keep the focus on the people and moments you actually want to show.

- 效果图交互逻辑：
- 大屏：
- 切换效果：用户点击效果图下方按钮切换效果
- B&A：用户用鼠标滑动滑杆查看效果，左边为Before，右边为After。滑杆默认在中间

- 移动端：
- 切换效果：用户点击效果图下方按钮切换效果
- B&A：用户点击滑动滑杆查看效果，左边为Before，右边为After。滑杆默认在中间

 ||
| 
 | Video Retouch Section

- 该模块用于展示 Airbrush App 的视频人像能力，重点突出视频中的脸部和 Body 编辑。

- 页面展示内容

- 该模块采用 **居中标题 + 下方视频 mockup / 视频播放器样式效果图** 的结构。

- 页面上方展示：

- Section title

- Section description

- 下载按钮

- 页面下方展示效果视频

- 时间轴
- 开始按钮
- 切换按钮
- 切换效果
- Body
- Face

- 切换B&A
- Before
- After

- 模块标题：Bring Retouching Into Your Videos
- 模块副标题：Apply face and body editing to videos, so clips can look as clean and consistent as your photos. Adjust details while keeping movement natural using Airbrush app.

- 效果视频交互逻辑
- 用户点击开始按钮开始播放视频
- 用户点击Face/Body切换效果视频
- 用户点击before/after按钮切换至对应效果的对应帧

 ||
| 
 | AI Tools Section

- 页面展示内容
- 该模块采用 **标题 + 副标题 + 工具卡片合集** 的结构。

- 模块标题：Fix, Create, and Transform with AI Tools
- 模块描述：From cleaning up backgrounds to expanding your frame or adding stylized effects, Airbrush app gives you smart AI tools to turn almost-good photos into finished edits.
- 页面下方展示 AI Tools 卡片合集，共展示 6 个工具：名字和标题需后台配置
- AI Replace
- AI Expand
- AI Repair
- Eraser
- Bokeh
- Prism

- 每张卡片包含：
- 工具效果图
- 工具名称
- 一句简短说明

- 单个工具卡片内容
- AI Replace：Swap unwanted objects or areas with AI-generated content that fits naturally.
- AI Expand：Extend your photo beyond the original frame and create more room for the moment.
- AI Repair：Fix blurry, damaged, or imperfect areas for a cleaner final.
- Eraser：Remove distractions like passersby, clutter, or unwanted background objects.
- Bokeh：Add soft background blur to make your subject stand out.
- Prism：Create artistic light effects for a more stylized, eye-catching finish.

- 效果图交互逻辑：
- 大屏：用户鼠标 Hover，或者点击对比按钮查看After效果。鼠标移开，则回到 Before 效果。
- 移动端：用户点击对比按钮切换 Before/After 效果

 ||
| 
 | User Reviews Section

- 复用当前逻辑及 UI
- 三个静态评论

 ||

### 异常处理

| 场景 | 处理方式 ||
| 图片加载失败 | 展示默认占位图，不影响标题、文案和下载入口 ||
| AI Image / Relight 效果切换失败 | 保持上一张成功加载的图片，并提示 Preview unavailable. Please try again. ||
| 下载链接失效 | 对应入口隐藏或置灰，提示 Download link is temporarily unavailable. ||
| APK 包不可用 | 隐藏 APK 入口，或提示用户使用 Google Play ||
| 移动端展示异常 | 横向图自适应宽度，效果选项可横向滑动，AI Tools 改为 1&ndash;2 列 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议-弃用)

## 七、翻译
[https://docs.google.com/spreadsheets/d/1ldeUcGozkt4JFo-9gHNy0cTxKZdCE7kMy2sX9U-B7X4/edit?pli=1&gid=1471611961#gid=1471611961](https://docs.google.com/spreadsheets/d/1ldeUcGozkt4JFo-9gHNy0cTxKZdCE7kMy2sX9U-B7X4/edit?pli=1&gid=1471611961#gid=1471611961)

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有

## 九、TPM信息

| 
 | 
 | 
 | 
 | 
 ||
| 
 | 
 ||
| 
 | 
 ||
| 
 | 
 ||
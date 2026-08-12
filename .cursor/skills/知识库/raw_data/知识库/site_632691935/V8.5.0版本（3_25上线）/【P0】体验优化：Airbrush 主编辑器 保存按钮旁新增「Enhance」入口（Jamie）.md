# 【P0】体验优化：Airbrush 主编辑器 保存按钮旁新增「Enhance」入口（Jamie）

**页面ID**: 673231519

**路径**: V8.5.0版本（3_25上线）/【P0】体验优化：Airbrush 主编辑器 保存按钮旁新增「Enhance」入口（Jamie）

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
| 2026.03.04 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 通过用户使用数据与案例观察发现，用户上传的原图中，存在较多清晰度不足的情况，例如：
- 社交媒体压缩图
- 二次下载图片
- 截图素材
- 旧型号手机拍摄

- 在图片编辑完成后，原图清晰度问题会被进一步放大，影响最终成图质量。除此之外，用户在当前编辑流程中，较少主动进入 AI Repair 功能，导致 AI Repair 虽为转化较好的能力之一，但该能力的使用率仍有提升空间。
- 当前编辑器支持高分辨率图片输出能力，用户在完成编辑后，往往对最终成图的 清晰度与细节质量有更高要求。
- 考虑到用户对"清晰度提升 / 修复模糊图片"有明确需求，理解成本低，使用路径清晰。且用户在完成编辑后，往往希望获得 更高质量的最终输出效果，AI Repair 能够进一步提升画面细节与清晰度。

竞品情况：

| Hypic | Meitu ||
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
incomplete
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
complete
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

| 算法接口 | /v2/image_restoration [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=326782812](图像画质修复V3)
/v1/imagefacesr_async [https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](面部超清

成本)：#0.008 ||
| demo地址 | 面部超清
[https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview)
 ||
| 算法对接人 | 陈进山 ||
| 效果设计师 | 孔宇琴 ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| 

 | **编辑器 新增 Enhance 按扭**

- 点击像相册后，进入主编辑器：

- Enhance 按钮 与 下载按钮 采用一样的展示逻辑，需展示在主编辑器的 edit/retouch 分类
- 首次进入展示 tooltips

- 展示时机为首次or升级后首次进入编辑器，3s后消失，点击任意部位也消失。

- Enhance 点击后展示下拉清单
- 默认显示 Enhance 
- 下拉清单：Orignal、UHD、Portrait
- 点击后 UHD or Portrait 后，收合面板，展示 loading 动效，开始任务投递
- 首次 ai 任务需展示云弹窗，拒绝云弹窗则留在编辑器内
- 投递中 Enhance 按钮文字要改成 UHD or Portrait
- 特殊状况：

- 弱网环境 - 超时候弹出弱网弹窗，请用户检查网路
- 无网环境 - 弹出弱网弹窗，请用户检查网路
- 请求失败 - 展示 toast 

- 限免扣减
- 与 ai repair 共用次数
- **无需弹限免次数横幅**

- 其馀通用规则：
- 云弹窗
- AI loading
- 错误等处理规则

- 逻辑补充：
- 若用户为非会员（原图：图片0），使用enhance按钮后未转订阅（图片1），后续进行其他编辑时，會以原始画质（图片0）进入其他功能，再次回到主编辑器（edit/retouch），展示 **原始画质图标。

**
- 若用户为会员（原图：图片0），使用enhance按钮后（图片1），后续进行其他编辑时，會以 **当前图标选中 **的画质（图片1）进入其他功能，再次回到主编辑器（edit/retouch），展示 **原始画质图标。

**
- **每次点击一次UHD/Portrait,都要新增步骤，选中了Portrait后，进入其他功能再应用效果出来，Enhance按钮又要恢复选中Origin**

 ||
| 
 | **新增订阅弹窗按钮**

- 新增「仍已原始画质保存按钮」：
- 点击后交互
- 弹窗消失 &rarr; 保存原始画质图 &rarr; 弹出保存 toast
- 画布内仍展示提升画质后效果图
- enhance按钮需展示对应程度图标

- 按下载拉起弹窗的时候（用户此时画布预览是高清图，但因为预览不能保存），这个弹窗要有两个按钮，一个是订阅、一个是以原图画质保存。点击原图画质保存之后，以「原始画质」保存图片，然后关掉弹窗，在画布一样展示高清后的预览图片。

- 按钮仅出现在由enhance按钮触发的限免弹窗

 ||
| / | **AI Repair 接入限免**

- 本次需求 ai repair 接入限免，采用限免策略2
- 具体限免逻辑：
- 限免横幅、限免弹窗等参考之前实现的通用逻辑

4. 后续期望调整进入功能自动投递逻辑（），本次接入限免先以临时逻辑处理以下案例：

- 若用户用完限免次数后，再次进入画质修复功能，一样给予投递。（不扣次数）

 ||

用户场景与参数关系

| 序号 | Image Quality | 颜色增强 | 去噪 | 著色 | 调用算法(照顺序) | 画质修复参数 | 备注 ||
| 1 | ☑️ HD | 
 | 
 | - | 画质修复 /v2/image_restoration_async | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
 | 
 ||
| 2 | ☑️ Portrait | 
 | 
 | - | 画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4

 | 
 ||

3、如涉及订阅限免策略调整

| 限免策略 | **新增【enhance 按钮】为收费功能，ai repair 共享限免次数。**

- 走策略二，非会员每日10次，会员每日50次
- 非会员限免使用后提示剩余次数，限免次数使用完后，不可再次请求效果。（请求效果展示兜底图）
- 可保存；无「分享 解锁效果」配置

 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

## 七、翻译

| en | chs ||
| enhance | 画质 ||
| Tap "Enhance" to improve your image quality. | **点击「画质」提升图片质量**
 ||
| Save Orignial | 以原始画质保存 ||

## 八、埋点需求
主编辑器限免弹窗 曝光/点击 埋点
enhance按钮、清单内选项 点击
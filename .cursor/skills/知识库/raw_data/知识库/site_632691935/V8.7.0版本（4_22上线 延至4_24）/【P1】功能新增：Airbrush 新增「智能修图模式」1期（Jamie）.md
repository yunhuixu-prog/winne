# 【P1】功能新增：Airbrush 新增「智能修图模式」1期（Jamie）

**页面ID**: 681970497

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P1】功能新增：Airbrush 新增「智能修图模式」1期（Jamie）

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
 | 更改内容（变更用不同w颜色mark）
 | 备注
 ||
| 2026.02.10 | Jamie | 创建文档 | 
 ||
| 2026.04.09 | Jamie | 补充弹窗、切换模式下的步骤记忆交互、AB实验 | 
 ||
| 2026.04.17 | Jamie | 无人脸逻辑补充、弹窗修改、分类滑动逻辑补充 | 橘色 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 在当前 ai 化的浪潮下，持续有看到竟品接入 agent or AI Based function 来优化整体交互逻辑，考虑到业务的智能画布局与外来发展出路，我们需更有野心的尝试有别于传统的编辑交互方案，以避免在这批求新的浪潮下掉队。
- 当前接入越来越多功能，层级越来越多，对于旧用户来说问题不大，但对于欧美新用户来说，交互就没有那么友善，考虑到 26 年目标持续提升 MAU 数量，优化整体交互体验为我们亟需进行的方向。
- 同时，由于 AB 内现有的用户年龄层偏大，虽付费状况良好，但整体使用习惯也预计偏保守，所以目前的 UI 风格，多以 2020 时期的风格为主，但考量到 26 年急迫的增量目标，当前交互风格无法明确吸引 genZ 用户，需在当前的基础上，拓展新的交互风格。

竞品情况：

| Facetune | Google Photo ||
| 1、智能主体识别

- 底部tab 切换选区
- 画布图片点击切换选区

2、不同选区下推荐不同的建议功能，与原编辑器功能操作一致，仅做选区交互上的逻辑调整。

 | 1、智能主体识别

- 画布图片点击、涂抹、圈选切换选区

2、不同选区下推荐不同的建议功能，与原编辑器功能操作一致，仅做选区交互上的逻辑调整。

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

| xxxx算法接口 | 人脸点实例分割模型 MTFACE_ENUM
 ||
| demo地址 | 待补 ||
| 算法对接人 | 林剑威 ||
| 效果设计师 | 
 ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| 

 | 
#### 功能入口
编辑器内画布区 - 顶部置中 - 智能编辑/经典编辑 切换toggle

#### 组件新增

- 新增画布区顶部置中悬浮 toggle
- Smart、Classic 切换
- 默认选中 Classic
- 进入三级子功能页面时不展示（与上一步、保存按钮 相同展示逻辑）
- 本期只支持单人图时展示toggle

#### 逻辑说明

- 点击 toggle 的 smart 按钮后，切到智能编辑器：
- 需以滑顺动画切换，具体交互由 UI 稿定义
- 若为小人脸图，画布需自动拉近聚焦人脸
- 默认选中 For you

- 在 smart 状态，点击 toggle 后回退到 classic模式
- 在classic模式内有「非人脸」的步骤记录时
- 在「有人脸」状态下，依然能进入smart模式 
- undo/redo 到「非人脸图」要弹出弹窗告知，再次点击得再次弹出。

| Func | Text ||
| Title & Body | Smart Mode currently only support single-face images. ||
| 按钮 | 
- Go Back to Previous Photo

- 回到有人脸的图片

- Switch to Classic Mode
- 点击切换模式

 ||

- undo 跳转无人脸图时，画布展示无人图弹出弹窗，点击&quot;Go Back&quot;后，回到上一張有人脸圖，undo依然高亮。

 ||
| 
 | **一级Tab**

- Suggestions、Face、Lips、Nose、Eyebrows、Eyes
- 未有mask的状态下（举例：缺少嘴唇），依然展示lips。不因局部人脸缺失而隐藏相关功能。

- 完整功能仅在单人脸且五官完整展示时生效。

- 在局部缺失或无人脸状态下，相关分类仍正常展示，但画布上不展示对应的 mask / 热区。

- 在无对应 mask 的状态下（例如：缺少嘴唇），点击对应子功能时，仍由子功能自身判断是否可进入；如果因缺少面部信息无法进入，则沿用原子功能的 toast 逻辑，toast key 复用。

- 如果用户在子功能编辑完成后变成无人脸图片，点击打勾返回编辑器后，重新检测结果为无人脸时，弹出 toast 提示：[缺少人脸导致功能缺失]。此时切换 tab 时仍展示相关分类，但不展示 mask，且无法通过主动点击画布区块切换 tab。

- 在无人脸状态下点击对应子功能时，仍由子功能自身判断是否可进入；如果因缺少面部信息无法进入，则沿用原子功能的 toast 逻辑，toast key 复用。

- 除了 Suggestions 在画布内无选区
- Face 展示 **全面部** 蒙层
- Lips 展示 **嘴巴** 蒙层
- Nose 展示 **鼻子** 蒙层
- Eyebrows 展示 **眉毛** 蒙层
- Eye 展示 **眼睛** 蒙层

- 可透过两种交互方式切换tab
- 滑动一级 tab 标签
- 画布交互
- 点击画布内相对应位置
- 涂抹画布内相对应位置（自动选取，占比涂抹范围内最大的选区）
- 圈选画布内相对应位置（自动选取，占比涂抹范围内最大的选区）
- 本期画布只支持点击画布内相对应位置

- 选中需呈现底色高亮态（高亮浮现后，800ms后渐隐），并展示对应的功能
- 分类不记忆滑动的位置，切换分类时，回到每个分类的第一位

| 图片类型 | 选区 | 功能排序 ||
| 大小人脸 Portrait

 | Suggestion | Reshape、Smooth、Magic、Dark Circles、Acne、Retouch、Skin Tone ||
| Face | Magic、Face、Smooth、Makeup、Acne、Retouch、Skin Tone ||
| Lips | Mouth、Lipsticks、Plumping、Features、Teeth ||
| Nose | Nose、Features、Blush、acne ||
| Eyebrows | Style、Eyebrows、Finetune、Features
 ||
| Eyes | Eyes、Eyeliner、Eyeshadow、Eye Color、Eye lashes、Features ||
| 多人图 Portrait | 本期不支持 | - ||
| 人物身体图 | 本期不支持 | - ||
| 多人身体图 | 本期不支持 | - ||
| 无人图片 | 本期不支持 | - ||

- 切换tab，若为功能载入中，需展示占位图标

- 点击功能后，连接对应 deeplink 进入对应位置
- 若为一键式功能，不自动投递，弹出弹窗询问是否直接开始

 ||
| 
 | **支持黑后台配置**
一级分类

- 分类命名
- 分类添加、删减
- 分类顺序移动

二级功能配置

- 功能命名
- 功能顺序
- 功能的添加、删减（对应分类下）

 ||

**详细对应跳转deeplink - **

| 一级分类 | Ename ||
| Suggestion | SmartSuggestion ||
| Face | SmartFace ||
| Lips | SmartLips ||
| Nose
 | SmartNose ||
| Eyebrows | SmartEyebrows ||
| Eyes | SmartEyes ||

| 一级分类 | 功能排序 | 二级功能 | 对应子功能 | Ename | is new | deeplink | Text (待翻译） ||
| Suggestion | Retouch、Skin、Relight、Magic、Smooth、Dark Circles、Acne、Skin Tone | Retouch | retouch - AI Retouch | SmartRetouch | 
 | 
 | Natural\nin One Tap
 ||
| Skin | retouch - Skin | SmartSkin | 
 | 
 | Smooth\nand Refine ||
| Relight | edit - relight | SmartRelight | 
 | 
 | Set the mode\nwith light
 ||
| Magic | retouch - magic | SmartMagic | 
 | 
 | A full glam\nlook
 ||
| Smooth | retouch - Skin - smooth | SmartSmooth | 
 | 
 | Soften\nand even out
 ||
| Dark Circles | retouch - skin - dark circle | SmartDarkCircles | 
 | 
 | Brighten\ntired eyes
 ||
| Acne | retouch - skin - acne | SmartAcne | 
 | 
 | Clear up\nblemishes
 ||
| Skin Tone | retouch - skin - skin tone | SmartSkintone | 
 | 
 | Balance\nyour complexion
 ||
| Face | Magic、Face、Smooth、Makeup、Acne、Retouch、Skin Tone | Magic | retouch - magic | SmartMagic | 
 | 
 | A full glam\nlook ||
| Face | retouch - face - width | FaceFace | 
 | 
 | Subtal\nadjust ||
| Smooth | retouch - skin - smooth | SmartSmooth | 
 | 
 | Soften\nand even out ||
| Reshape | retouch - Reshape - reshape | SmartReshape | 
 | 
 | 
 ||
| Makeup | retouch - makeup - looks | MakeupLooks | ✅ | 
 | 
 ||
| Acne | retouch - skin - acne | SmartAcne | 
 | 
 | 
 ||
| Retouch | retouch - retouch | SmartRetouch | 
 | 
 | 
 ||
| Skin Tone | retouch - skin - skin tone | SmartSkintone | 
 | 
 | 
 ||
| Lips | Mouth、Lipsticks、Plumping、Features、Teeth | Mouth | retouch - face - Mouth （选中upper） | FaceMouth | ✅ | 
 | 
 ||
| Lipsticks | retouch - makeup - lips（选中lipstick） | MakeupLips | ✅ | 
 | 
 ||
| Plumping | retouch - plumping - mouth | PlumpMouth | ✅ | 
 | 
 ||
| Features | retouch - retouch - features
(选中lips分类
none选中)
 | FeaturesLips | ✅ | 
 | 
 ||
| Teeth | retouch - teeth | SmartTeeth | 
 | 
 | 
 ||
| Nose | Nose、Features、Blush、acne | Nose | retouch - face - nose
（选中size） | FaceNose | ✅ | 
 | 
 ||
| Features | retouch - retouch - features
(选中nose分类
none选中)
 | FeaturesNose | ✅ | 
 | 
 ||
| Blush | retouch - makeup - blush | MakeupBlush | ✅ | 
 | 
 ||
| acne | retouch - skin - acne | SmartAcne | 
 | 
 | 
 ||
| Eyebrows | Style、Eyebrows、Refine、Features
 | Style | retouch - makeup - Eyebrows | MakeupEyebrows | ✅ | 
 | 
 ||
| Eyebrows | retouch - face - eyebrows（选中volume） | FaceEyebrows | ✅ | 
 | 
 ||
| Refine | retouch - reshape - Refine | Refine | ✅ | 
 | 
 ||
| Features | retouch - retouch - features
(选中eyebrows分类
none选中) | FeaturesEyebrows | ✅ | 
 | 
 ||
| Eyes | Eyes、Eyeliner、Eyeshadow、Eye Color、Eye lashes、Features | Eyes | retouch - face - eyes
(选中size) | FaceEyes | ✅ | 
 | 
 ||
| Eyeliner | retouch - makeup - eyeliner | MakeupEyeliner | ✅ | 
 | 
 ||
| Eyeshadow | retouch - makeup - eyeshadow | MakeupEyeshadow | ✅ | 
 | 
 ||
| Eye Color | retouch - makeup - eye color | MakeupEyecolor | ✅ | 
 | 
 ||
| Eye lashes | retouch - makeup - eye lashes | MakeupEyelashes | ✅ | 
 | 
 ||
| Features | retouch - retouch - features
(选中eyes分类
none选中) | FeaturesEyes | ✅ | 
 | 
 ||

3、实验需求
针对 「智能修图模式」 做如下AAB实验：

- 对照组：维持线上不变。
- 实验组：

- **新增智能模式**

**AAB实验信息：**

| 实验触发时机 | ** 进入主编辑器时** ||
| 对照 | 维持线上不变 ||
| 实验组AA | 维持线上不变
 ||
| 实验组B | 
- **新增智能模式**

 ||
| 实验观察指标 | P0: 打勾率、用户留存
 ||
| 流量控制 | 全区，对照组AA、实验组B 各33%流量 ||
| 测试周期 | 14天（看結果決定是否延長） ||

**「智能修图模式」 - AAB实验**

| 平台 | 对照组 | 实验组AA | 实验组B | 实验链接 ||
| iOS | 
 | 
 | 
 | 
 ||
| Android | 
 | 
 | 
 | 
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求

- toggle 点击
- 全局功能请求，新增编辑器模式 parameter
- 打勾、保存的 mod 
- 一级、二级的曝光/点击
- 三级、四级子功能内素材曝光（需要有办法区分智能模式）
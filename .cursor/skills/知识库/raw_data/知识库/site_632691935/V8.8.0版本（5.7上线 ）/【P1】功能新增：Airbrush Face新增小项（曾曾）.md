# 【P1】功能新增：Airbrush Face新增小项（曾曾）

**页面ID**: 679590961

**路径**: V8.8.0版本（5.7上线 ）/【P1】功能新增：Airbrush Face新增小项（曾曾）

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
complete
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

1214
complete
效果设计师

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
| 2026.5.06 | 曾曾 | jaw/nose tab增加小红点 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
从Q1整体收益表现来看，**Face相关能力在订阅转化和使用率上均表现最优**。同时，2025年AB对Face小项的一轮更新已验证能够带来显著的正向收益。
基于此，希望在现有能力基础上，进一步探索并补充**更符合欧美用户需求的高频刚需Face功能**，以持续提升MAU及订阅转化表现。

- **现状数据分析-分部位**

分功能看，下巴和鼻子是转化最高的，尤其**Nose size**单独一个子项的订阅转化能够比肩一个大分类，因此推测用户对于**缩小鼻子**，以及**鼻部立体度**有较强诉求（推测和前置的镜头畸变导致鼻子变大也有强关联），可考虑拓展更多鼻子缩小功能；Jaw单功能是face里面订阅最高的，其中去除双下巴使用率最高，反映了用户对脸型轮廓棱角感（轮廓清晰度与紧致度）的刚需，可考虑拓展更多下巴效果。

| Nose | Jaw ||
| 订阅（整体）

使用（单功能）

 | 订阅（整体）

使用（单功能）

 ||

- **现状分析-功能现状**

| Nose | Jaw | 其他 ||
| 
- 目前已有：鼻子尺寸、鼻翼宽度、鼻背宽度、鼻头大小、鼻子高低；
- ** 可快速增加：山根粗细（秀秀）**
- 需要重新研发：鼻尖塑形（针对欧美常见的鹰钩鼻或鼻尖下垂，做"抬高鼻尖"功能）

 | 
- 目前已有：下巴大小、下颌线、下颌角、下巴长短、去双下巴、方圆下巴；
- **可快速增加：双下巴pro（秀秀）**
- 需重新研发：侧面下巴前后调整（解决下巴后缩）

 | 面部表情调整（微笑）、美牙、去牙渍等 ||

- 其他功能数据分析：[https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNiG3XeXsOTyWonMgM?scode=ACIAJAeGAAgXD4LaxdAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNiG3XeXsOTyWonMgM?scode=ACIAJAeGAAgXD4LaxdAdUAnwaPAHA)

基于以上数据分析，本次需求主要集中在可快速增加的能力上，希望接入秀秀「山根调节、双下巴pro」能力，其他集团暂无的效果则通过TPM重新研发后增加补充

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

数据回收时间：5.28

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
**效果评估🔗：**[https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNdJ50A6YYRsCNG0ex?scode=ACIAJAeGAAgu1MH1uyAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNdJ50A6YYRsCNG0ex?scode=ACIAJAeGAAgu1MH1uyAdUAnwaPAHA)
**双下巴pro算法接口文档：**[https://insight-mtlab.meitu-int.com/doc/1004](**AI祛双下巴**)
**性能优化版本算法接口文档：**[https://insight-mtlab.meitu-int.com/doc/1063#%E6%8F%8F%E8%BF%B0](**AI祛双下巴（性能优化）**)

| 原型图 | 功能详情说明 ||
| 
 | 
- **功能入口**
- Retouch**-**Face-Nose-Root
- **排序：**Size、Width、**Root**、Nose Bridge、Nose Tip、Length

- Retouch**-**Face-Jaw-Double Chin Pro
- **排序：**Chin、Jawline、Jaw Angle、Length、Double Chin、**Double Chin Pro**、Jaw shape

- **素材默认程度值**
- Root：默认0，正负100
- Double Chin Pro：默认100

- **交互流程**
- Root：本地功能，交互流程Follow目前Face线上逻辑
- Double Chin Pro(AI效果）：
- 点击该效果则进入Loading流程，返回结果后用户可调节滑杆参数
- Double Chin Pro生成中点击取消，则默认无选中状态，只有生成成功后才是选中状态
- 不固化，只要还在Face页面中，切换Tab并返回该效果，仍然可以调节参数
- 当从A人脸使用过双下巴pro后，切换多人脸效果B，B人脸没有用过任何效果时，则默认选中jaw中的chin，默认参数为0（其他本地效果的切换，子项切换状态维持线上）

- **订阅策略**
- Root：免费（本地算法）
- Double Chin Pro（AI效果）：走策略2，会员免费，非会员可以预览，用户打勾时候拦截走策略一，非会员终身限免2次，会员每日限免30次

- **其他**
- Jaw、Nose Tab展示小红点，用户点击Tab后小红点消失
- Root、Double Chin Pro两个小项需要增加new角标，用户点击功能后消失
- 生效后的功能均显示小橙点
- Face 功能底tab组件使用最新组件（hair样式）

 ||

## 七、协议跳转
新增功能，需研发新增DL链接。按照功能结构补充至deeplink cf文档：
IOS🔗：
安卓🔗：

## 八、翻译

| 英文 | 中文 ||
| Root | 山根 ||
| Double Chin Pro/Sculpt Jaw | 去双下巴pro ||

## 九、埋点需求

| 功能 | 埋点 ||
| 山根调整 | 点击/打勾/保存/订阅的UV/PV ||
| 去双下巴pro | 点击/打勾/保存/订阅的UV/PV ||
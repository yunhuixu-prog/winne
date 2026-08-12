# 【P1】AB实验：Airbrush makeup眼妆合并（曾曾）

**页面ID**: 622565798

**路径**: V8.0.0版本（1_7上线）/【P1】AB实验：Airbrush makeup眼妆合并（曾曾）

---

#### JIRA地址：

| \模块
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
complete
前端

 | 

1209
incomplete
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
| 2025.12.17 | 曾曾 | 创建文档
 | 
 ||
| 2025.12.23 | 曾曾 | 1.修改眼妆tab切换逻辑，不可无极调节滑动
2.补充效果叠加/互斥逻辑
 | 
 ||
| 2025.12.26 | 曾曾 | 1.修改testb的记忆逻辑，按照用户最后打勾停留的tab来记忆 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Make up 作为AB人像功能中使用率最高的功能，交互体验存在一定问题需要优化，具体问题如：

- 一级分类过多和占位较大，导致寻找功能效率低，需要在底部多次滑动才能找到对应的功能，体验较差；
- 一级功能过于分散，眼妆作为相辅相成的妆容部分，拆成多个tab，用户需要来回寻找和搭配使用，体验较差；

**竞品分析**
AB 与 Hypic 的功能子项数量较多，层级较深，用户在查找与切换时的成本偏高，整体使用体验显得冗杂；相比之下，FaceApp 与 Facetune 保留更少的子项与层级，结构精简，操作流畅，使核心功能更易被快速触达。

| 
 | AB现状 | face app | facetun | Hypic ||
| 一级tab | Makeup（9个子项） | Makeup（无子项） | Makeup（7个子项） | Hypic（14个子项） ||
| 二级tab | looks、lipstick、blush、contouring、eyebrows、eyelashes、eyeliner、eyeshadow、eyecolor
 | 暂无素材妆容，仅整妆24个 | contour、blush、lipstick、eyeshadow、eyelashes、eyeliner、freckles | suit、lipstick、eyelashes、blush、contour、eyeliner、highlighter、eye shadow、eyebrow、pupil light、lying silkworm、mole、cosmetic contact lenses、double eyelids ||

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

| 

1189
incomplete
用户指标

 | 

299
incomplete
保存率

 | 
 | 
 ||
| 

280
incomplete
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

 | 
 | 
 ||

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

| 原型图 | 功能详情说明 ||
| 
 | **入口**
**Retouch- Make up**

- Looks
- Lipstick
- Blush
- Contouring
- Eyebrows
- Eye look（眼妆合并），顺序如下**
- Eyelashes-睫毛（默认）
- Eyeliner-眼线
- Eyecolor-美瞳
- Eyeshadow-眼影

**交互流程**

- 进入Retouch- Make up
- 默认进入到Looks
- 左滑底部Tab点击进入「Eyelook」
- 腰部展开眼妆tab「Eyelashes（默认）、Eyeliner、Eyecolor、Eyeshadow」
- 不支持左滑无极切换眼妆二级Tab

**记忆逻辑**

- TestA:每次进入eye-look默认选中睫毛
- TestB:每次进入eye-look默认按照用户最后打勾停留的tab来记忆

**素材叠加/互斥逻辑**

- 和整妆：互斥，整装和眼妆之间为互斥关系（维持线上逻辑）
- 和局部妆：叠加，眼妆子 tab 下，若已选中素材且素材效果程度＞0，均展示小黄点（在二级tab中显示）

**其他逻辑**

- 固化/多人脸等与线上保持一致

 ||

## 六、AB实验
本次实验目的为验证 将Make up眼妆模块交互进行优化**，**对用户点击、保存及订阅转化的影响

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上方案
 | 20%
 ||
| 实验组 | 目前线上方案 | 20% ||
| 实验组A | 本次新的需求方案-每次进入eye-look默认选中睫毛 | 20% ||
| 实验组B | 本次新的需求方案-每次进入eye-look默认按照用户最后打勾停留的tab来记忆 | 20% ||
| 实验触发时机
 | 升级后进入Make up则触发实验
 | / ||
| 目标用户
 | 全用户（**区分新老用户看数据**）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量，若有明显负反馈则停止实验
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 ||

## 七、协议跳转
兼容目前线上的deeplink

## 八、翻译

| 英文 | 中文 ||
| Eyelook | 眼妆 ||

## 九、埋点需求

| 埋点 ||
| Eyelook：曝光/点击进入/打勾保存的PV/UV ||
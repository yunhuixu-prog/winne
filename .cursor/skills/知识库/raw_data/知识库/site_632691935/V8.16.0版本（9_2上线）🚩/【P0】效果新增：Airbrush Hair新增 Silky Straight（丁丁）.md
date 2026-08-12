# 【P0】效果新增：Airbrush Hair新增 Silky Straight（丁丁）

**页面ID**: 710790906

**路径**: V8.16.0版本（9_2上线）🚩/【P0】效果新增：Airbrush Hair新增 Silky Straight（丁丁）

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

1215
incomplete
效果

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
 | 更改内容
 ||
| 2026.8.7 | 丁丁 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**发质发量**模块在用户使用量和满意度上具有压倒性优势，Top 4 全部被其占据，「柔发」以 3482.27 的保存 UV 断层领先，是第二名「水光发」的 1.55 倍。Top 20 中发质发量占 7 席、发色占 8 席、发型仅占 5 席，但若以头部集中度衡量，发质发量模块的少数几款素材贡献了绝大多数使用量，呈现&quot;少而精&quot;的特征；用户对于发质的优化需求更强，水光发、光泽、柔发的使用率高于发量功能。
ref: 
在此背景下，本次计划在发质发量模块中柔顺直发**，提升修图效率与成片质量。增强用户粘性，更能强化产品在头发修图领域的差异化竞争力，巩固并扩大现有优势。
现有发型Straight，归类属于发型，新上效果与其种类相似，属于直发+柔顺的类型，故AB测试，把入口放到Hairstyles和Hair Enrich对比收益。

效果对比：
[https://insight-mtlab.meitu-int.com/diff?id=34488&page=1&page_size=10](https://insight-mtlab.meitu-int.com/diff?id=34488&page=1&page_size=10)
对比线上效果，更直更柔顺，清晰度更高。

| Before | After | 线上直发效果 ||
| 
 | 
 | 
 ||
| 
 | 
 | 
 ||

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
incomplete
不提升复杂度

284
incomplete
化繁为简

285
complete
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

**功能数据目标（勾选对应指标）**

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
incomplete
5-20万

1143
complete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

## 二、预估投入工时

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

## 三、原型流程图

## 四、需求描述
算法接口文档：
文档： [https://insight-mtlab.meitu-int.com/doc/1920](https://insight-mtlab.meitu-int.com/doc/1920) 
demo：[https://insight-mtlab.meitu-int.com/viewer?id=2742](https://insight-mtlab.meitu-int.com/viewer?id=2742)
算法对接人：@郑伟鑫
设计师：杨倩

| 原型图 | 功能详情说明 ||
| B：

BB: 

 | 排序**

- 实验组B：Hair- Hair Enrich-Texture， **Silky Straight**- Fix Flyaways &rarr; Hydra Gloss &rarr; Shiny &rarr; Smooth &rarr; Oil Control
- 实验组BB：Hair- Hair Enrich-Texture， Fix Flyaways &rarr; Hydra Gloss &rarr;Silky Straight&rarr; **Shiny &rarr; Smooth &rarr; Oil Control
- 实验组BBB：Hair- Hairstyles-Female，Silky Straight (第一位）-Straight...**

交互流程：

- 首次进入HAIR

- 用户点击 Silky Straight- 即进入Generate流程:[https://www.figma.com/design/YaIwDzKdkSlP3d0VgLkGTS/Hair-Update?t=AHKZ3tz9UJtbFYH6-0](https://www.figma.com/design/YaIwDzKdkSlP3d0VgLkGTS/Hair-Update?t=AHKZ3tz9UJtbFYH6-0)
- Generate完成则返回结果图，undo / redo 和对比按钮高亮。
- 未Generate完取消/生成失败/网络错误，则选中上一个效果，若无上一个效果则选中none
- 互斥/叠加逻辑：同线上

其他调整：

- 实验组B hair enrich增加小红点, 实验组BB Hairstyles 增加小红点
- **Silky Straight**增加new，用户点击后消失

订阅策略：

- 非会员：生命周期10次限免，每日2次预览
- 会员：每日30次限免

 ||

3、AB 实验方案

| **组别 ** | **内容** | 流量 ||
| 对照组ａ（线上） | 线上不变 | 25%
 ||
| 实验组ｂ | Hair- Hair Enrich-Texture， **Silky Straight （第一位）**- Fix Flyaways &rarr; Hydra Gloss &rarr; Shiny &rarr; Smooth &rarr; Oil Control
 | 25% ||
| 实验组ｂｂ | Hair- Hairstyles-Female，**Silky Straight (第一位）-Straight...**
 | 25% ||
| 实验组ｂｂb | Hair- Hair Enrich-Texture， Fix Flyaways &rarr; Hydra Gloss &rarr; **Silky Straight** &rarr; Shiny &rarr; Smooth &rarr; Oil Control | 25% ||
| 实验触发时机
 | 升级后首次进入「**Hair**」
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率、原有子项的使用数据
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | / ||

## 五、订阅相关
无

## 六、协议跳转
七、翻译

## 八、埋点需求
新增 **Silky Straight** 的pv/uv，曝光/点击/打勾/保存/订阅转化
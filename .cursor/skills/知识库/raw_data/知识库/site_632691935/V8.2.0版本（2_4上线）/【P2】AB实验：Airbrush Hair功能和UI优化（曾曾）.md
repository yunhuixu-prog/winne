# 【P2】AB实验：Airbrush Hair功能和UI优化（曾曾）

**页面ID**: 633570589

**路径**: V8.2.0版本（2_4上线）/【P2】AB实验：Airbrush Hair功能和UI优化（曾曾）

---

#### JIRA地址：****

| 模块
 | 

1202
complete
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
complete
素材

 | 

1208
complete
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
| 2025.10.09 | 曾曾 | 创建文档 | 
 ||
| 2025.12.24 | 曾曾 | 
- 修改undo/redo逻辑为与线上保持一致
- 修改发质的多人脸支持逻辑为发质不支持多人脸

 | 
 ||
| 2026.1.16 | 曾曾 | 发色icon尺寸改为3:4 | 
 ||
| 2026.1.16 | 曾曾 | 实验内容变更 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
随着Hair功能和效果的持续增加和丰富，体验交互体验中的问题逐渐暴露，因此需要从交互流程、UI呈现等多个维度进行提升，为用户带来更流畅、更高质量的使用体验，让功能本身更具拓展性。具体问题如下：

| 视觉呈现 | 交互体验 ||
| 
- **缩略图视觉优化：**

发型缩略图外框形状为为方形，较多女士长发效果展示不齐，影响曝光&rarr;点击转化，因此需将发型缩略图从正方形更改为竖状长方形，以更好将发型效果展示完整。

 AB现状 Facetun
 | 
- **发色与发型分类优化**：
当前发色款式已超过 40 款，发型也在不断增加，涵盖多种男女款式及刘海。用户在浏览时需要频繁左滑查找，效率较低。为提升用户在款式查找、对比与选择过程中的体验，需对现有效果进行二级分类管理，帮助用户更快找到心仪样式。

- **头发优化功能整合**：
发质、发量均是针对原生头发的优化功能，目前拆成两个tab较为分散，建议其进行合并，提升使用效率。

- **胡须功能归类调整**：
胡须作为毛发类效果，目前放置在 AI Image 模块中，易造成定位混乱（facetun放在Hair模块），需将其调整回 Hair 模块，以使用户的查找与使用路径更加直观、统一。

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
complete
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
complete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
complete
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
需求内容分为4个feature：

- Hair模块调整为3个大模块，Color，Hair style，Hair enrich（Volume和Texture合并）
- 3大模块中分别增加二级Tab分类
- 缩略图由正方图调整为长方形竖图
- 胡须由原本的AI image调整至Hair style-Beard分类中

## 五、需求描述

| 原型图 | 功能详情说明 ||
| 
 | Hair模块调整为3个大模块，Color，Hair style，Hair enrich（Volume和Texture合并）

- Color：发色，提供换发色、染发、挑染等效果
- Hair style : 发型，提供换发型、换刘海、胡须等效果
- Hair enrich：头发细节，提供原生头发美化，提供发质、发量等美发效果

 ||
| 

 | 3大模块中增加二级Tab，将效果进行重新分类：
**1. Color：Natural自然色、Highlights挑染、Colorful彩色（默认Natural）**

- **Natural：**Chocolate、Jet black、Cool brown、Ginger、Raven、mocha、light blonde、platinum、Dirty blonde、bubblegum、red ginger、coral、champagne、copper1、galactic、ash、gray、Bella、mauve、taffy blonde
- **Highlights：**Honey、Icy sliver、Raspberry、Leopard、Copper2、Eclipse、Cobalt、Jade、Yinyang
- **Colorful：**icy white、Barbie、peacock、evergreen、Mint、bubblegum、sunset、lilac、twilight、unicorn、mermaid、rainbow

**2.Hair style : Female女士、Male男士、Bangs刘海、Beard胡须（默认Female）**

- **Female：**straight、beachy waves、blowout、French bob、pixie cut 、long hair、big wave、choppy bob、wolf cut、medium curls、tight curls
- **Male：**side part、curtains、buzz cut、dreadlocks
- **Bangs：**blunt bangs、thin bangs、side bangs1、side bangs2、middle part
- **Beard：**Shaved、Hipster、Full Beard、Goatee、Mustache、Petite Goatee、Circle Beard

**3.Hair enrich：Texture发质、Volume发量（默认Texture）**

- **Volume：**Volume、hairline、hair part
- **Texture：**shiny、smooth、oil control

交互流程

- 因新增了二级 Tab，在一级功能（如 Color）下，用户可以通过左滑无级浏览全部效果（Natural、Highlights、Colorful）；若直接点击二级 Tab，则直接跳转至对应分类下；

- "None" 功能调整为固定展示在二级 Tab 的最前位置；当用户切换一级或二级 Tab 时，"None"的位置保持不变，不随 Tab 切换而移动。

- 其他逻辑均与线上保持一致。

 ||
| 缩略图由正方图调整为长方形竖图

- **尺寸：**3:4，180*240px

 ||
| 功能叠加/互斥逻辑：
 1. 发型：各发型之间互斥，一次仅可选择一个发型，切换发型时，将覆盖前一个发型效果，在当前面板中（未打✅❌的情况下），已经loading过的效果不再重新加载，点击即应用。&mdash;&mdash;维持现逻辑
 2. 发色：各发色之间互斥，一次仅可选择一个发色，切换发色时，将覆盖前一个发色效果，在当前面板中（未打✅❌的情况下），已经loading过的效果不再重新加载，点击即应用。&mdash;&mdash;维持现逻辑
 3. 头发优化：该功能内包括「发量、发际线、发缝、去油、柔发、光泽」相互可叠加使用&mdash;&mdash;维持现逻辑
Undo / Redo / None逻辑：

- 维持线上逻辑

人脸识别逻辑：
1. 发型、头发优化：

- 仅对检测到人脸的图片生效（无人脸则不可使用）&mdash;&mdash;维持现逻辑
- 头发优化识别&mdash;&mdash;维持现逻辑
- Beard功能follow发型逻辑，仅支持单人脸&mdash;&mdash;新逻辑

2. 发色：需检测到头发区域（mask）方可使用，即使无人脸但有头发 mask 也可生效&mdash;&mdash;维持现逻辑
多人脸情况：

- 发型：仅支持单人（涵胡须）

- 发色：支持多人

- 头发优化
- 「发际线、发缝」支持多人
- 当用户用多人脸使用该功能时，默认给所有人上效果，并在效果加载完成后弹出toast：
- The effect has been applied to all detected portraits

- 「去油、柔发、发量、光泽」不支持多人
- 当用户使用多人脸图片点击「去油、柔发、光泽、发量」时，弹出toast，并默认选中上一个效果：
- This effect is only applicable to photos with a single person, please try another photo

 ||

3、订阅策略

- 维持原订阅策略

## 六、协议跳转

- 不涉及

## 七、翻译
翻译文档link

| 中文 | 英文 | 其他语言 ||
| 头发细节 | Hair enrich | 
 ||
| 自然色 | Natural | 已有 ||
| 挑染 | Highlights | 
 ||
| 彩色 | Colorful | 
 ||
| 女士 | Female | 
 ||
| 男士 | Male | 
 ||
| 刘海 | Bangs | 
 ||
| 胡须 | Beard | 
 ||
| 暂不支持集体照 | Not available for group photos
 | 
 ||
| 该效果已应用于所有检测到的人像 | The effect has been applied to all detected portraits
 | 
 ||

## 八、埋点需求

| 模块 | 埋点 ||
| Hair enrich
Natural
Highlights
Colorful
Female
Male
Bangs
Beard
 | 该Tab和效果的曝光/点击/保存/订阅转化埋点
 ||

## 九、AB实验
本次实验目的为验证 将Hair模块交互进行优化**，**对用户点击、保存及订阅转化的影响

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 
- 缩略图修改
- 二级tab新增
- 发质发量不合并

 | 20%
 ||
| 实验组aa | 
- 缩略图修改
- 二级tab新增
- 发质发量不合并

 | 20% ||
| 实验组b | 
- 缩略图修改
- 二级tab新增
- 发质发量合并

 | 20% ||
| 实验触发时机
 | 升级后首次进入编辑器
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
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
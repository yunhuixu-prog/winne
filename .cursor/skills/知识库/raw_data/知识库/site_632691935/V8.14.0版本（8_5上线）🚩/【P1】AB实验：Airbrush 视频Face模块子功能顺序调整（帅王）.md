# 【P1】AB实验：Airbrush 视频Face模块子功能顺序调整（帅王）

**页面ID**: 709003681

**路径**: V8.14.0版本（8_5上线）🚩/【P1】AB实验：Airbrush 视频Face模块子功能顺序调整（帅王）

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

更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2025.08.22 | 
 | 
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
AirBrush 接入视频中台后，视频编辑器**整体使用规模和商业化表现明显提升**。升级后进入 UV 增长 167%，保存 UV 增长 150%，订阅成功人数增长约 600%，说明视频场景**具备较强增长潜力**。
从升级后的功能表现看，**增长**主要由**基础美颜类能力**驱动，如 Smooth、Skin Tone、Whiten、Acne等功能兼具**较高使用量与较高打勾率**，是当前视频编辑中最稳定、用户认可度最高的能力群。
因此，本次计划基于**功能使用量、打勾率及订阅贡献**，**对视频美颜模块顺序进行调整**，优先曝光高价值、高满意度功能，提升用户快速找到核心美颜能力的效率，进一步带动保存与订阅转化。

**用户分析：**
视频编辑用户更偏向快速获得自然、稳定、可感知的美颜效果，核心需求集中在基础**皮肤优化和气色改善，包括磨皮、肤色调整、白牙、祛痘、黑眼圈、提亮等**。
从功能表现看，用户对**基础美颜能力的认可度**明显高于复杂强形变类能力。Whiten、Dark Circles、Brighten、Smooth 等功能打勾率均在 88% 以上，说明用户对"皮肤更干净、气色更好、状态更自然"的需求更强。

**数据支撑：**

##### ● **上升最多的模块**
**美颜类功能群**（smooth、skin tone、whiten、acne、darkcircles、Brighten）兼具较高使用量与较高打勾率，是升级后表现最稳定的功能群。
如下表所示：

| **模块**
 | **AB****进入 UV**
 | **AB****打勾 UV**
 | **AB****打勾转化率**
 | **Wink打勾转化**
 ||
| **Body**
 | 69,813
 | 34,053
 | 49%
 | 安卓：58.04%。iOS：48.37%
 ||
| **Smooth**
 | 62,859（刚需）
 | 55,300
 | 88%
 | 79.23%
 ||
| **Enhance**
 | 59,669
 | 28,349
 | 48%
 | 安卓：68.73%。iOS：81.42%
 ||
| **Makeup**
 | 54,849
 | 29,629
 | 54%
 | 78.99%
 ||
| **Face**
 | 51,422
 | 30,151
 | 59%
 | 76.70%
 ||
| **Retouch**
 | 34,863
 | 7,433
 | 21%
 | 50.48%
 ||
| **Skin****tone**
 | 30,748（刚需）
 | 25,061
 | 82%
 | 81.32%
 ||
| **Whiten**
 | 20,825（刚需）
 | 19,196
 | 92%
 | 85.49%
 ||
| **Acne**
 | 20,158（刚需）
 | 16,558
 | 82%
 | 83.81%
 ||
| **DarkCircles**
 | 18,913（高满意低曝光）
 | 16,983
 | 90%
 | 76.71%
 ||
| **Brighten**
 | 18,870（高满意低曝光）
 | 16,930
 | 90%
 | 76.71%
 ||
| **Filter**
 | 18,827
 | 6,800
 | 36%
 | 57.62%
 ||
| **Toning**
 | 18,536
 | 11,122
 | 60%
 | 78.40%
 ||
| **WrinkleRemove（Firm）**
 | 18,067
 | 12,823
 | 71%
 | 60.89%
 ||
| **Contour**
 | 14,346
 | 11,026
 | 77%
 | 54.86%
 ||
| **Concealer**
 | 10,857
 | 8,112
 | 75%
 | 60.89%
 ||
| **Reshape****（手动瘦脸）**
 | 18,117（跨帧形变，满意低）
 | 5,133
 | 28%
 | 74.09%
 ||
| **Eliminate****（消除）**
 | 8,618
 | 977
 | 11%
 | ● iOS 海外生成保存率 88%。 安卓海外生成保存率 62%
 ||
| **Matte**
 | 7,036
 | 5,067
 | 72%
 | 13.69%
 ||
| **Canvas**
 | 5,586
 | 2,076
 | 37%
 | 83.29%
 ||
| **HairColoring**
 | 5,373
 | 2,152
 | 40%
 | 68.60%
 ||
| **HairQuality**
 | 3,660
 | 1,486
 | 41%
 | 68.60%
 ||
| **Plump**
 | 5,305（高满意）
 | 4,486
 | 85%
 | 47.26%
 ||
| **Cut**
 | 5,286
 | 3,394
 | 64%
 | /
 ||
| **Speed**
 | 4,329
 | 3,694
 | 85%
 | /
 ||
| **Voice**
 | 1,786
 | 1,501
 | 84%
 | /
 ||
| **Edit**
 | 7,103
 | 19,780*
 | &mdash;
 | /
 ||

- **分模块看收益高的是哪些模块**

Face 模块订阅意向占总量过半，**美颜相关**（Face+Makeup+Concealer+Firm）合计约 75%，是**核心付费驱动力**，说明用户付费意愿主要集中在面部与皮肤美化能力。

**调整结论：**
本次排序调整原则为：**基础高频美颜能力前置，高满意度潜力功能前移，低转化/复杂 AI/强形变功能后置。**

| 排序 | 功能 | 数据表现 | 调整原因 ||
| 1 | Magic | 高频需求 | 一级入口，不变 ||
| 2 | Retouch | 高频需求 | 一级入口，不变 ||
| 3 | Face | 高频需求 | 一级入口，不变 ||
| 4 | Smooth | 62,859 进入 / 88% 打勾率 | 进入量最高，且满意度高，是视频美颜第一基础刚需 ||
| 5 | Skin Tone | 30,748 进入 / 82% 打勾率 | 高频肤色调整能力，用户对肤色自然、均匀需求明确 ||
| 6 | Whiten | 20,825 进入 / 92% 打勾率 | 打勾率最高，效果稳定，用户满意度强，适合前置 ||
| 7 | Acne | 20,158 进入 / 82% 打勾率 | 基础皮肤问题修复，进入量和满意度均较稳定 ||
| 8 | Plumping | 5,305 进入 / 85% 打勾率 | **虽进入量较低，但满意度高，**原位置也较靠前，保留在第二梯队继续验证曝光价值 ||
| 9 | Firm（去皱 | 18,067 进入 / 71% 打勾率 | 进入量不低，且具备订阅贡献，但满意度低于基础美颜，因此从前排后移至第二梯队 ||
| 10 | Reshape | 18,117 进入 / 28% 打勾率 | **进入量不低，但视频场景存在跨帧形变稳定性问题，打勾率偏低，因此后移**；考虑原位置靠前及订阅价值，未放至末尾 ||
| 11 | Dark Circles | 18,913 进入 / 90% 打勾率 | 打勾率高，属于高满意气色优化功能，保持中段曝光 ||
| 12 | Brighten | 18,870 进入 / 90% 打勾率 | 与 Dark Circles 同属气色优化，效果感知直观，保留在中段靠前 ||
| 13 | Concealer | 10857进入/ 75% 打勾率 | 数据表现亮眼，且订阅不错，从末位适度前移 ||
| 14 | Contour | 14,346 进入 / 77% 打勾率 | 欧美用户有修容需求，但属于进阶修饰功能，放在后段 ||
| 15 | Matte | 7,036 进入 / 72% 打勾率 | 进入量较低，需求相对垂直，调整至末位 ||

调整位置变化

| 功能 | 调整前位置 | 调整后位置 | 变化 ||
| Magic | 1 | 1 | 不变 ||
| Retouch | 2 | 2 | 不变 ||
| Face | 3 | 3 | 不变 ||
| Smooth | 4 | 4 | 不变 ||
| Skin Tone | 8 | 5 | 前移 3 位 ||
| Whiten | 10 | 6 | 前移 4 位 ||
| Acne | 9 | 7 | 前移 2 位 ||
| Plumping | 7 | 8 | 后移 1 位 ||
| Firm | 6 | 9 | 后移 3 位 ||
| Reshape | 5 | 10 | 后移 5 位 ||
| Dark Circles | 11 | 11 | 不变 ||
| Brighten | 12 | 12 | 不变 ||
| Concealer | 15 | 13 | 前移 2 位 ||
| Contour | 14 | 14 | 不变 ||
| Matte | 13 | 15 | 后移 2 位 ||

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
预计回收数据时间：xx月xx日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
complete
曝光提升10%

300
incomplete
留存提升**%

1215
complete
打勾率提升5%

1217
complete
订阅转化提升2%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
incomplete
不产生收入或者产生负向收入

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

五、需求描述
本次需求主要调整 **视频美颜模块内功能排序**，不涉及新增功能及效果逻辑变更。
综合 **进入 UV、打勾率、订阅价值、原有用户路径和视频效果稳定性** 做调整。
调整后优先曝光：
**Smooth、Skin Tone、Whiten、Acne、**
Plumping、Firm、Reshape等进阶功能保留，但后移至第二梯队，减少对首屏核心美颜路径的干扰
Dark Circles，Brighten保持不变
Matte进入量低后置，和Concealer互换位置
**调整前：**
Magic &rarr; Retouch &rarr; Face &rarr; Smooth &rarr; Reshape &rarr; Firm（去皱 &rarr; Plumping &rarr; Skin Tone &rarr; Acne &rarr; Whiten &rarr; Dark Circles &rarr; Brighten &rarr; Matte &rarr; Contour &rarr; Concealer
**调整后（实验组）：**
**Magic &rarr; Retouch &rarr; Face &rarr; Smooth &rarr; Skin Tone &rarr; Whiten &rarr; Acne &rarr;Plumping &rarr; Firm &rarr; Reshape &rarr; Dark Circles &rarr; Brighten &rarr; Concealer &rarr; Contour &rarr; Matte**

| 原型图 | 功能详情说明 ||
| 
 | 如左图所示，本次调整仅涉及视频美颜模块（Face-tab）底部功能栏的排列顺序，不涉及任何功能本身的交互或宽度队列。

- **调整前**：Magic &rarr; Retouch &rarr; Face &rarr; Smooth &rarr; Reshape &rarr; Firm &rarr; Plumping &rarr; Skin Tone &rarr; Acne &rarr; Whiten &rarr; Dark Circles &rarr; Brighten &rarr; Matte &rarr; Contour &rarr; Concealer

- **调整后**：Magic &rarr; Retouch &rarr; Face &rarr; Smooth &rarr; Skin Tone &rarr; Whiten &rarr; Acne &rarr; Plumping &rarr; Firm &rarr; Reshape &rarr; Dark Circles &rarr; Brighten &rarr; Concealer &rarr; Contour &rarr; Matte

 ||

*** ***

## 六. AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 33.3%
 ||
| 实验组A | 目前线上版本
 | 33.3% ||
| 实验组B | **只调整排序：**

- Magic &rarr; Retouch &rarr; Face &rarr; Smooth &rarr; Skin Tone &rarr; Whiten &rarr; Acne &rarr; Plumping &rarr; Firm &rarr; Reshape &rarr; Dark Circles &rarr; Brighten &rarr; Concealer &rarr; Contour &rarr; Matte

 | 33.3% ||
| 实验触发时机
 | app 启动完成分流**，进入视频美颜（Face）模块展示实验组排序，优先覆盖新用户观察冷启动表现
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
 | 实验组P0和P1数据或持平硬盘，P1数据无明显负向，后台无负反馈
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接
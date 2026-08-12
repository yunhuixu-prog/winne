# 【P2】AB实验：Airbrush Glowup排序调整（帅王）

**页面ID**: 705515511

**路径**: V8.13.0版本（7_22上线）🚩/【P2】AB实验：Airbrush Glowup排序调整（帅王）

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

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2025.08.22 | 
 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Glowup作为Retouch板块核心功能之一，**Plump 上线后位序后移，导致功能曝光与用户触达明显减少**。
虽然进入保存数据上涨，但整体订阅出现明显下降。次本希望通过恢复Glowup原有位序，提升曝光，有效改善订阅数据表现。

**用户分析：**
Glowup核心子功能包括Flawless / Natural Tan / Body Glow / Soft Glow / Sun-kissed等，其中Soft Glow、Natural Tan、Sun-kissed为订阅收入主力。
北美用户为AB付费Top 1用户群体，夏季是其高频使用Glowup的涨幅，当前与**需求高度匹配**，也具备更高曝光的价值。

**数据支撑：**
Glowup各功能**enter-save整体上涨**，说明功能本身效果满意度高，可以明显看到Glowup的**Enter to Save 及付费收入表现明显优于**Plump，所以更需要提高曝光。

整体订阅下降明显，与Plump上线后Glowup位序后移高度相关

综合来看，当前位序安排与功能实际价值不匹配，**Glowup 具备更强的优先级**。关键原因是位序后移导致整体曝光减少。
需要**恢复Glowup至第六板块位**，利用北美夏季高峰利用增益函数曝光与订阅转化。

不同国家数据分析

### 最终结论
从进入、打勾、保存及订阅数据综合看：
Glow Up 在美国、英国、巴西三大核心市场整体表现均优于 Plump，**暂未发现明显国家偏好差异，不需要按国家做差异化排序**。
Glow Up 在核心漏斗表现更优，尤其体现在：

- 更高的 Enter &rarr; Save 转化
- 更高的 打勾 &rarr; Save 转化
- 更优的订阅表现

巴西市场虽有个别日期 Plump 订阅人数略高（但样本较小，对整体结论影响有限），但整体数据仍是 Glowup 更优。巴西用户对 Plump 兴趣比英美高，但保存转化偏弱，后续可以优化效果。
**综合判断：**
Glow Up 在功能体验与商业化价值上均优于 Plump，更适合作为 Retouch 核心功能**前置曝光，建议**恢复Glowup原有排序。

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

301
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

## 五、需求描述
对 Retouch 模块第二屏功能位序进行调整，将 **Glow Up** 与 **Plumping** 的位置互换，提高 Glow Up 功能曝光，验证排序调整对功能使用及订阅表现的影响。
**当前顺序（对照组）**
Retouch 第二屏：
Plumping | **Glow Up** | Reshape | Resize | Stretch
**调整后顺序（实验组）**
Retouch 第二屏：
**Glow Up** | Plumping | Reshape | Resize | Stretch

**调整说明**

- Glow Up 前置至 Retouch 第二屏第 1 位
- Plumping 后移至第 2 位
- 其余功能顺序保持不变

 示意图

| 
 | 如左图所示，本次调整仅涉及 **Retouch 模块第二屏底部功能栏的排列顺序**，不涉及任何功能本身的交互、效果逻辑或功能宽度队列。
**调整前**：第二屏依次为 **Plumping / Glow Up / Reshape / Resize / Stretch**
**调整后**：第二屏依次为 **Glow Up / Plumping / Reshape / Resize / Stretch**
其余功能位序保持不变。

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
| 实验组B | **Glow Up前置**至第二屏第一个（位于Plumping前）
 | 33.3% ||
| 实验触发时机
 | **App 启动完成分流**，进入Retouch模块展示实验组排序，优先覆盖新用户观察冷启动表现
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
Figma链接：
# 【P1】AB实验：Airbrush Skin 功能顺序调整（Jamie）

**页面ID**: 701458884

**路径**: V8.11.5版本（小版本 7_1上线）🚩/【P1】AB实验：Airbrush Skin 功能顺序调整（Jamie）

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
| 2026.02.10 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：
Skin 第一屏头部子功能集中了模块的绝大部分流量，子功能的排序位置直接决定其曝光与进入量。当前部分高进入意图、高付费价值的子功能受排序靠后限制，曝光与触达不足：

- Skin 第一屏的头 5 个子功能占据 Skin 模块所有流量的 71%，排序即流量分配。
- Dark Circle（黑眼圈）用户进入意图位居前列，与第一档子功能（Smooth / Acne / Skin Tone）相当，但当前排序偏后，进入量被位置压制。
- Wrinkle（皱纹）进入意图较高，且与 Concealer、Brighten、Skin Tone、Matte 同为 Skin 模块订阅收入主力，排序靠后影响付费转化触达。
- **Dark Circle、Wrinkle 往前排序会带来立即收益；**且 Dark Circle、Concealer、Wrinkle 共同指向「气色优化」需求方向，前置有助于强化该心智。

综上，本次需求将 Skin 第一屏的子功能顺序进行调整，把 Dark Circle、Wrinkle 前移，并通过 AB 实验验证对进入、打勾、保存及订阅转化的提升。

文档：

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
1、需求内容
调整 Skin 模块第一屏子功能的展示顺序，将 Dark Circle（黑眼圈）、Wrinkle（皱纹）前移至第一屏靠前位置，以提升其曝光与进入量。本次仅调整排序，不涉及功能效果与交互改动。

- 调整范围：仅 Skin 模块第一屏子功能排序。
- 调整内容：将 Dark Circle、Wrinkle 往前排。
- 其余子功能顺序顺延不变。

| **位置**
 | **调整前（线上）**
 | **调整后（实验组**** B****）**
 ||
| **1**
 | Smooth
 | Smooth
 ||
| **2**
 | Acne
 | Acne
 ||
| **3**
 | Skin Tone
 | Skin Tone
 ||
| **4**
 | Concealer
 | Dark Circle &uarr;（原第 6 位）
 ||
| **5**
 | Brighten
 | Wrinkle &uarr;（原第 7 位）
 ||
| **6**
 | Dark Circle
 | Concealer
 ||
| **7**
 | Wrinkle
 | Brighten
 ||
| **8**
 | Eye Brighten
 | Eye Brighten
 ||
| **9**
 | Detail
 | Detail
 ||
| **10**
 | Contouring
 | Contouring
 ||
| **11**
 | Matte
 | Matte
 ||
| **12**
 | Texture
 | Texture
 ||

2、实验内容
针对 Skin 第一屏顺序调整做客户端 AAB 实验：

| **项目**
 | **描述**
 ||
| **实验类型**
 | 客户端 AAB 实验
 ||
| **实验方式**
 | 观察对比实验组与对照组的功能使用数据、转化差异
 ||
| **重点关注数据****
****（分析师评估）**
 | P0：Dark Circle、Wrinkle 的进入 UV/PV、打勾、保存；
P0：Skin 模块整体 进入 &rarr; 保存转化
 ||
| **实验命中条件**
 | 用户进入** Skin 模块**时
 ||
| **停止方式**
 | 根据结果决定关闭实验、继续扩大流量，或一键同步给当前版本所有用户
 ||
| **流量控制**
 | 线上组 A / 对照组 AA / 实验组 B，每组各 33%
 ||
| **实验周期**
 | 14&ndash;30 天
 ||
| **线上组**** A**
 | 保持目前线上子功能顺序
 ||
| **对照组**** AA**
 | 保持目前线上子功能顺序
 ||
| **实验组**** B**
 | 将 Dark Circle、Wrinkle 前移（见上方顺序对照表）
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
# 【P1】AB实验：Airbrush Makeup子分类排序调整-for巴西（思思）

**页面ID**: 710788404

**路径**: V8.16.0版本（9_2上线）🚩/【P1】AB实验：Airbrush Makeup子分类排序调整-for巴西（思思）

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
| 2026.08.5 | 徐娟 | 初版 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
洞察巴西地区用户makeup使用功能习惯，子功能的排序位置直接决定其曝光与进入量。当前部分高进入意图、高付费价值的子功能受排序靠后限制，曝光与触达不足，现对巴西进行差异化排序调整
**整体：**

- makeup巴西地区第一屏的头 4 个子功能占据makeup10个模块所有流量的 61.12%，排序即流量分配。
- **Eyebrows（眉毛）**当前第6，巴西用户进入意图位居第4，与第一屏子功能**【blush（腮红）/contouring（五官立体）】**相当，但当前排序在freckles（雀斑）之后，进入量被位置压制。
- **eyelashes（睫毛）**当前第7，曝光进入率为88%，进入打勾率为82%，订阅收入位居第3，排序靠后影响付费转化触达。
- **eye color（美瞳）**当前第10，但曝光进入率81%良好，进入打勾率78%处于中游，订阅收入第6位，该功能前置有助于满足巴西地区用户使用需求和促进订阅收益。
- **freckles（雀斑）**当前排序为第5位，但曝光进入率26%，进入打勾率61%，订阅收入1.46，曝光到进入、曝光到打勾、曝光到保存、进入打勾、点击保存、打勾到保存巴西地区全面倒数第一，结合化妆步骤习惯，（雀斑为化妆最后一步：绘制雀斑装饰）和巴西用户需求将此功能后置

**分新老：**眉毛、睫毛、美瞳巴西地区用户使用需求均在前五位

- **新用户：**曝光进入率排序：眉毛（第3位78%）、睫毛（第1位86%）、美瞳（第5位70%）

- **老用户：**曝光进入率排序：眉毛（第4位85%）、睫毛（第2位88%）、美瞳（第5位81%）

综上，本次需求将巴西地区makeup子功能顺序进行调整，
把**Eyebrows（眉毛）&larr;**、**eyelashes（睫毛）&larr;**、**eye color（美瞳）&larr;**前移
**freckles（雀斑）&rarr;**后置，
并通过巴西地区 AB 实验验证对进入、打勾、保存及订阅转化的提升。
对照组A：looks lipstick blush contouring freckles eyebrows eyelashes eyeliner eyeshadow eye color 
实验组B：looks lipstick blush contouring eyebrows eyelashes eye color eyeliner eyeshadow freckles 

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
预计回收数据时间：9月15日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
complete
曝光提升2%

300
incomplete
留存提升**%

1215
complete
打勾率提升2%

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
改前排序：looks lipstick blush contouring freckles eyebrows eyelashes eyeliner eyeshadow eye color 
改后排序：looks lipstick blush contouring eyebrows eyelashes eye color eyeliner eyeshadow freckles 
五、需求描述
调整巴西makeup模块功能的展示顺序
将**Eyebrows（眉毛）&larr;**、**eyelashes（睫毛）&larr;**前移1位、
**eye color（美瞳）&larr;**前移3位，以提升其曝光与进入量
**freckles（雀斑）&rarr;**后置至第10位，
本次调整仅涉及巴西地区makeup模块底部功能栏的排列顺序，不涉及任何功能本身的交互或宽度队列、功能效果改动。

| 
 | 调整前 | 调整后 | 备注 ||
| **1**
 | looks / 妆容 | looks / 妆容 | 
第一屏

 ||
| **2**
 | lipstick / 口红 | lipstick / 口红 ||
| **3**
 | blush / 腮红 | blush / 腮红 ||
| **4**
 | contouring / 五官立体 | contouring / 五官立体 ||
| **5**
 | freckles / 雀斑 | eyebrows / 眉毛 | 前进1位&uarr; ||
| **6**
 | eyebrows / 眉毛 | eyelashes / 睫毛 | 前进1位&uarr; ||
| **7**
 | eyelashes / 睫毛 | eye color / 美瞳 | 前进3位&uarr; ||
| **8**
 | eyeliner / 眼线 | eyeliner / 眼线 | 
 ||
| **9**
 | eyeshadow / 眼影 | eyeshadow / 眼影 | 
 ||
| **10**
 | eye color / 美瞳 | freckles / 雀斑 | 下降5位&darr; ||

## 六. AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 33.3%
 ||
| 对照组A | 目前线上版本
 | 33.3% ||
| 实验组B | **只调整排序：**

- looks/妆容** &rarr; **lipstick/口红** &rarr; **blush/腮红** &rarr; **contouring /五官立体** &rarr; **eyebrows/眉毛** &rarr; **eyelashes/睫毛** &rarr; **eye color /美瞳** &rarr; **eyeliner/眼线** &rarr; **eyeshadow/眼影** &rarr; **freckles/雀斑

 | 33.3% ||
| 实验触发时机
 | app 启动完成分流**，进入**Airb****rus****h**展示实验组排序
 | / ||
| 目标用户
 | 仅🇧🇷巴西地区
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量，若有明显负反馈则停止实验
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:曝光/进入/打勾/保存/订阅
P1:功能整体的留存率，巴西新老用户留存
 ||
| **实验预期**
 | P0和P1巴西地区数据进入保存有可信提升，留存率提升，
P1巴西地区数据无明显负向，后台无负反馈
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接
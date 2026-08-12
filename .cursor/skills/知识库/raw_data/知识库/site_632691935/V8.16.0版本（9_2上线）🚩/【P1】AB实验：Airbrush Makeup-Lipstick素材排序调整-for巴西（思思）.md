# 【P1】AB实验：Airbrush Makeup-Lipstick素材排序调整-for巴西（思思）

**页面ID**: 710789273

**路径**: V8.16.0版本（9_2上线）🚩/【P1】AB实验：Airbrush Makeup-Lipstick素材排序调整-for巴西（思思）

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
洞察巴西地区用户makeup-Lipstick模块使用偏好，走查子功能用户曝光、进入、点击、保存、订阅收入，子功能的排序位置直接决定其曝光与进入量。
当前部分高进入意图、高付费价值的子功能受排序靠后限制，曝光与触达不足，现对巴西进行差异化排序调
同时发现巴西用户对耗时比较敏感，✨Glaze、✨Matte Nude耗时较高的功能占用第一屏曝光流量，但实际曝光进入率13%、10%属于倒数水平（素材46个，曝光进入倒数第4和第2），进入打勾率21%、16%、中间水平（中位值16.8%）

- makeup-Lipstick子模块巴西地区第一屏的头 5个子功能占据Lipstick46个素材流量的1/3，排序即流量分配。
- Berry当前排序第5，巴西用户进入意图位居第5，曝光进入率素材中排第1（50%），进入打勾率第1（57%），属于巴西用户高需，高满意度效果素材，

- PK02当前排序第8，巴西用户进入意图第12位，订阅收入第2名，该功能前置有助于满足巴西地区用户使用需求和促进订阅收益。

综上，本次需求将巴西地区makeup-Lipstick模块子素材顺序进行调整，
把 Berry、PK02 和✨Glaze、✨Matte Nude耗时高、巴西曝光转化率低的功能进行调换
并通过巴西地区 AB 实验验证对进入、打勾、保存及订阅转化的提升。

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
原始排序：

改后排序：

五、需求描述
调整巴西makeup-Lipstick模块功能的展示顺序
Berry、PK02 和✨Glaze、✨Matte Nude进行调换
本次调整仅涉及巴西地区makeup-Lipstick模块底部功能栏的排列顺序，不涉及任何功能本身的交互或宽度队列、功能效果改动。

| 
 | 调整前 | 调整后 | 备注 | 
 ||
| 1 | ✨Glaze | Berry | 高需、高满意度（曝光进入率、进入打勾率第1） | 第一屏 ||
| 2 | ✨Matte Nude | PK02 | 高订阅收入（订阅收入第2） ||
| 3 | Dewy | 
 | （订阅收入第1） ||
| 4 | Nude Glow | 
 | 
 ||
| 5 | Berry | ✨Glaze | （曝光进入43位） ||
| 6 | Suede | 
 | 
 | 
 ||
| 7 | Lip Liner01 | 
 | 
 | 
 ||
| 8 | PK02 | ✨Matte Nude | （曝光进入46位） | 
 ||
| 后续排序不变 ||

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

- Berry &rarr; PK02 &rarr; Dewy &rarr; Nude Glow &rarr; ✨Glaze &rarr; Suede &rarr; Lip Liner01 &rarr; ✨Matte Nude &rarr; ND02 &rarr; Plum &rarr; RD02 &rarr; Glass &rarr; BR01 &rarr; Plump &rarr; Classic Red &rarr; Rose &rarr; Alluring &rarr; Lip Liner02 &rarr; Mulberry &rarr; Gloss &rarr; ND01 &rarr; ND03 &rarr; ND04 &rarr; ND05 &rarr; PK01 &rarr; PK03 &rarr; PK04 &rarr; PK05 &rarr; PK06 &rarr; PK07 &rarr; RD01 &rarr; RD03 &rarr; RD04 &rarr; RD05 &rarr; RD06 &rarr; RD07 &rarr; RD08 &rarr; OR01 &rarr; OR02 &rarr; OR03 &rarr; OR04 &rarr; BR02 &rarr; BR03 &rarr; VL01 &rarr; VL02 &rarr; VL03

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
P1:功能整体的留存率
 ||
| **实验预期**
 | 实验组P0和P1数据可信上升
P1数据无明显负向，后台无负反馈
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接
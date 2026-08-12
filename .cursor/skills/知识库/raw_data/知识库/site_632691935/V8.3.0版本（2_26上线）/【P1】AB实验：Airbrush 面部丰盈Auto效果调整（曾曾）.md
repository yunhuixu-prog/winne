# 【P1】AB实验：Airbrush 面部丰盈Auto效果调整（曾曾）

**页面ID**: 666092463

**路径**: V8.3.0版本（2_26上线）/【P1】AB实验：Airbrush 面部丰盈Auto效果调整（曾曾）

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
| 2026.01.28 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
基于用户洞察，欧美用户对面部丰盈与提拉效果存在显著需求。因此，AB在V.7.23版本已接入集团的面部丰盈能力，以提升人像的年轻饱满度，同时增强核心效果竞争力，进一步带动 AB 的使用频率与收入转化。
但需求上线后发现，与端内其他美化功能相比，plumping的打勾/保存转化率明显差于其他功能，因此，进行数据分析后推测由于auto效果较弱，用户感知较弱，因此希望从Auto效果上进行优化尝试。
数据分析文档：[https://cf.meitu.com/confluence/x/GrezJw](https://cf.meitu.com/confluence/x/GrezJw)

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
/

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
/

## 五、需求描述
**增加auto数值来强化效果表现，并增加苹果肌和眼窝默认值，让用户能够更明显感知效果带来的变化（AB 实验测试）**
**用户未点击auto，点击单个子项，默认值跟随auto的默认值**

| **部位**
 | Troughs
泪沟
 | Medial malar
苹果肌
 | Nasal base
鼻基底
 | Sockets
眼窝
 | Chin
下巴
 | Contour
轮廓
 | Forehead
额头
 | Eyes
眼周
 | Middle
面中
 | Mouth
口周
 ||
| **线上****auto**
 | 60
 | 0
 | 40
 | 0
 | 20
 | 60
 | 60
 | 35
 | 50
 | 40
 ||
| **新auto**
 | 80
 | 50
 | 60
 | 60
 | 55
 | 60
 | 80
 | 90
 | 90
 | 80
 ||
| **效果对比**

 | **原图/线上auto/新auto [https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCN0koDbGLQRXGGLggt?scode=ACIAJAeGAAgSMUBjlgAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCN0koDbGLQRXGGLggt?scode=ACIAJAeGAAgSMUBjlgAdUAnwaPAHA)**

 ||

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/

## 九、AB实验
本次实验目的为验证 将plumping模块进行效果优化**，**对用户点击、保存及订阅转化的影响

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上plumping | 20%
 ||
| 实验组aa | 目前线上plumping | 20% ||
| 实验组b | 本次调整auto强度值版本 | 20% ||
| 实验触发时机
 | 升级后首次进入plumping
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
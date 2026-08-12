# 【P1】AB实验：Airbrush 去眩光算法优化（Jamie）

**页面ID**: 644285600

**路径**: V8.1.0版本（1_21上线）/【P1】AB实验：Airbrush 去眩光算法优化（Jamie）

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
| 2025.12.29 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做:

- 用户图的眩光情况差异较两极化，多为 严重眩光 与 几乎无眩光 场景
- 当前算法针对轻度眩光图有最好的效果，针对两种场景无针对性调整，导致整体功能的打勾率不如预期。仅有16.91%。
- 严重眩光：仅能减弱眩光，生成结果不自然
- 几乎无眩光：无法侦测，反而有机会出现 bad case。

- 具体数据可参考：

需求内容:

- 升级去眩光算法，提升整体功能效能与生成结果，来提升功能的渗透与转化率。

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
complete
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
complete
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
1、涉及算法

| 算法接口 | [https://insight-mtlab.meitu-int.com/doc/992](https://insight-mtlab.meitu-int.com/doc/992)

参数：&quot;parameter&quot;: {
&quot;rsp_media_type&quot;: &quot;url&quot;,
&quot;mode&quot;: &quot;去眩光&quot;
} ||
| demo地址 | [https://insight-mtlab.meitu-int.com/doc/992](https://insight-mtlab.meitu-int.com/doc/992)
 ||
| 算法对接人 | 陈进山、张勇飞
 ||
| 效果设计师 | 杨倩 ||

线上算法配方：去眩光+ 画质修复v3
实验组算法配方：去眩光v2+ AI超清后处理

2、实验规划
针对 去眩光 算法替换 做如下AAB实验：

- 对照组：维持线上去眩光交互与算法不变。
- 实验组：

- **替换 去眩光为新版算法**
- 原交互、生成数量、订阅逻辑维持不变。

- 涉及的双入口都要进行替换
- Relight内的去眩光
- Adjust内的去眩光

**AAB实验信息：**

| 实验触发时机 | **进入Relight****功能、进入adjust功能时（同一个gid需为同一组）**
 ||
| 线上A | 维持线上去眩光交互与算法不变 ||
| 对照组AA | 维持线上去眩光交互与算法不变
 ||
| 实验组B | **替换 去眩光为新版算法**
 ||
| 实验观察指标 | P0: 打勾率、保存、用户留存
 ||
| 流量控制 | 全区，对照组AA、实验组B 各 33% 流量 ||
| 测试周期 | 14天（看結果決定是否延長） ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
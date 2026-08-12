# 【P1】AB实验：Airbrush Relight新增一级入口AB实验（可乐）

**页面ID**: 695514657

**路径**: V8.11.5版本（小版本 7_1上线）🚩/【P1】AB实验：Airbrush Relight新增一级入口AB实验（可乐）

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
| 2026.06.10 | 可乐 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
在上月Relight小火后，本月Relight继续带动Airbrush相继在 俄语圈+部分欧洲国家（德国、荷兰、意大利等）+马来 等地冲榜，带动MAU环比上月显著上涨。但从端内数据来看，该功能新老用户渗透都只有12%左右，且也存在由于功能入口较深，用户找入口存在一定成本的问题。故此希望在一级功能新增一个relight入口，放大功能曝光，看是否能提高功能渗透，极其对MAU的影响。
本次选择的目标位置是Hair后面，为什么选择这个位置：
1、以iPhone普通机型为例（机型占比大，机型尺寸小），首屏-一级功能中，hair的渗透是最低的，再往前一个filter渗透很高，不能轻易动
2、而relight功能渗透和功能满意度均高于hair，即这么调整是让使用量更大、满意度更高的功能有了更多曝光

PS：作为补充，新增了一组把位置放在hair后面，考虑点在于：Hair虽然渗透和满意度相对relight低但用户习惯了这个位置，万一relight这个位置实验不成功退而求其次，这个位置虽然普通iPhone无法首屏露出，但安卓机可以。

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
预计回收数据时间：7月15日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
complete
预计可带来新增10万

300
incomplete
留存提升**%

1215
incomplete
打勾率提升**%

301
incomplete
频次提升**%

1217
complete
功能渗透提升5%

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

## 四、原型图

## 五、需求描述

实验设置

| 项目 | 说明 ||
| 实验类型 | 客户端实验 ||
| 实验触发时机 | 用户进入主编辑器时 ||
| 实验停止方式 | 根据结果决定是关闭实验、继续扩大流量还是一键同步给当前版本所有用户 ||
| 

实验组说明
 | 对照组 | 当前线上状态
Edit\Retouch\Filters\Hair\Preset\Effect\AI image\Background\Text\My Kit
 ||
| 实验组A | Edit\Retouch\Filters\Relight\Hair\Preset\Effect\AI image\Background\Text\My Kit
 ||
| 实验组B | Edit\Retouch\Filters\Hair\Relight\Preset\Effect\AI image\Background\Text\My Kit
 ||
| 实验观察指标 | 1、Relight功能总渗透率，两个入口分别的渗透率变化
2、主编辑器保持率
3、订阅收入
 ||
| 流量控制 | 初始流量各33%，后续根据数据和反馈评估 ||
| 测试周期 | 实验开启14天后结合数据表现开放最优实验组33%流量，如果实验组有收益扩全量
 ||
| 目标用户 | 全体用户（需要分国家分新老用户看数据，国家分：美、英、巴、其他）
 ||
| 实验预期 | 主编辑器保持率、订阅收入无负向，Relight功能总渗透率显著提升 ||

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求
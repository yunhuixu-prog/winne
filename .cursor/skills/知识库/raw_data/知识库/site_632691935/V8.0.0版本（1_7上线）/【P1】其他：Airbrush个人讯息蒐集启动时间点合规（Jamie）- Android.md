# 【P1】其他：Airbrush个人讯息蒐集启动时间点合规（Jamie）- Android

**页面ID**: 650123548

**路径**: V8.0.0版本（1_7上线）/【P1】其他：Airbrush个人讯息蒐集启动时间点合规（Jamie）- Android

---

#### JIRA地址：

服务端：

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
incomplete
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
| 2025.08.11 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**背景**

- 根据内控部门发起的 2025 年合规整改专项之一，判定为中等风险性场景，不过罚责较大，年初协调过 **九月前 **完成。**但因改造项目过多，协调到Q4底前完成。**

- 当前问题: APP初始化阶段，第三方SDK即采集设备IDFA、地理位置等数据，早于隐私协议弹窗出现时间
- 需求要将第三方SDK即采集的初始化时间点，移至用户同意隐私之后。

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
complete
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
incomplete
高频

274
incomplete
中频

275
complete
低频但刚需

276
incomplete
低频非刚需

 | 

283
complete
不提升复杂度

284
complete
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

## 二、功能目标（勾选对应指标）

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

## 四、需求原型

## 五、需求描述
1、盘点涉及的SDK与更动复杂度，可以分批完成 @客户端

2、第三方SDK采集时机点更动

- 延后初始化：调整第三方SDK采集初始化逻辑，在APP初始化阶段，需等待到隐私协议弹窗出现且授权后。
- 用户按下**&quot;接受且继续&quot;**：初始化SDK，正常上报埋点
- 用户没按下**&quot;接受且继续&quot;，直接退出：**SDK未启动，不应有埋点上报。

- 改动后需验收第三方SDK数据采集是否正常，仅为延后时机点，采集数据点、数据量应维持相同。
- 埋点类SDK于隐私协议前的打点异动：
- 早于隐私弹窗前的埋点点位，需做延迟上报处理，上报必须于同意授权之后，具体点位数量 --数据史钰静盘点后补充

- 需改动的SDK清单 ： -- 客户端盘点后补充

| SDK List | 分类 ||
| firebase | 埋点SDK ||
| appsflyer | 埋点SDK ||
| applovin | 广告SDK ||
| 
 | 
 ||

- 后续接入的SDK，需以此【采集时间点逻辑】为设定依据。

## 六、协议跳转

## 七、翻译

## 八、埋点需求
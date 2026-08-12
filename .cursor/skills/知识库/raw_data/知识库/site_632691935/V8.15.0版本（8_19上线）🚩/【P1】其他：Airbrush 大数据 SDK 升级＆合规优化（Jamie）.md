# 【P1】其他：Airbrush 大数据 SDK 升级＆合规优化（Jamie）

**页面ID**: 710772695

**路径**: V8.15.0版本（8_19上线）🚩/【P1】其他：Airbrush 大数据 SDK 升级＆合规优化（Jamie）

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
| 2026.07.29 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 先前为符合欧盟 GDPR、美国加州 CCPA 合规要求，已上线「删除用户资料」按钮（历史需求：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=643464713](Airbrush 新增删除用户资料按钮&交互优化)）。当时为一期方案，采用服务端接口，由服务端自行处理删除任务。
- 本次大数据侧已提供正式的删除处置 SDK，接入后删除处置改由大数据 SDK 执行，并会自动生成一个全新的 gid。方案参考：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=646823174](大数据海外用户数据删除处置（PIX合规）)。
- 由于 gid 刷新后，绑定 gid 的免费次数会一并重置，存在用户高频触发删除来刷免费次数套利的风险。因此本次将删除**冷静期由 D+1 调整为 D+3**，并由服务端保存同一用户多次 gid 记录，用于滥用检测。

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
complete
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
1、SDK 信息

| SDK版本 | Android: 7.12.5
[https://meitu.feishu.cn/wiki/KqcrwilnSiU2ZNk4KKBc04jBnab](https://meitu.feishu.cn/wiki/KqcrwilnSiU2ZNk4KKBc04jBnab)

iOS: 7.14.0
[https://meitu.feishu.cn/wiki/IbuVw3nuyiymdJkpvLHcbzw2nHg](https://meitu.feishu.cn/wiki/IbuVw3nuyiymdJkpvLHcbzw2nHg)
 ||

2、需求内容

| 原型图 | 功能详情说明 ||
| 
 | **资料删除逻辑升级（接入大数据删除处置 SDK）**
方案参考：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=646823174](大数据海外用户数据删除处置（PIX合规）)，处置细节以大数据侧文档为准。

**交互调整**

- 入口与二次确认弹窗沿用现有交互（Setting - Personalization and Data - More Option - Delete my data）
- 二次确认后，弹窗提示已排定的执行时间：熔断期**由 D+1 调整为 D+3**，
- 实际上点击客户端的触发按钮，二次确认后就会直接执行gid重置＋服务端拉黑
- 二次确认后，展示完弹窗之后，弹窗展示已排定的执行时间＋重新启动

- 文案使用新的key「暂存会立即删除，云端资料预计在YYYY/MM/DD HH:00完成。现在需要重新启动app」
- 若为非0分0秒，自动进位到整点

- 点击弹窗的ok后，触发关闭app，重新进入。

- 客户端需要基于unique id （ex: device id) 去记录上次请求删除的时间点，若处在熔断期内：
- 熔断期内再次点击 Delete my data，沿用现有「已在队列中，Expected to complete by YYYY/MM/DD HH:00」toast 提示

- 熔断期目的：gid 刷新会重置绑定的免费次数，熔断期以提高灰黑产套利
- gid 刷新后的预期
- 绑定 gid 的免费次数随之刷新（预期行为，不主动告知）
- 其他对应的业务服务（云服务、客服、用户反馈等），一律改用全新的 gid
- 之前授权过的场景照旧，无需其他改动

 **服务端**

- 新增一张业务（app）自行维护的数据表，保存同一用户多次的 gid 记录（新旧 gid、触发时间等），用于检测是否有人透过滥用服务套利

 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
＊若现有删除资料 / 隐私授权弹窗已有对应埋点，沿用原事件名、补 source 参数即可，不用重复新建。
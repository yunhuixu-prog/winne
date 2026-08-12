# 【P1】其他：Zendesk迁移集团客服中台（Mia）

**页面ID**: 687599190

**路径**: V8.10.0版本（6_8上线）/【P1】其他：Zendesk迁移集团客服中台（Mia）

---

#### JIRA地址：

| 模块
 | 

1208
incomplete
前端

 | 

1215
complete
效果

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
| 2026.04.23 | Mia | 创建文档 | 
 ||
| 2026.5.21 | Mia | 修改文档： 拉取用户信息时，需"拉取用户日志"。 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 现有客服体系基于 Zendesk，存在以下问题：

- 客诉监控响应不够及时，暂不支持异常客诉自动同步及告警至企微
- 用户反馈存在"找不到客服入口"的问题
- 当前系统成本：Zendesk 年费用约 $10,140（AB & B+分摊），计划于 2026 年底停止续订 Zendesk

因此需要整体迁移至集团客服中台，实现：

- 客诉异常实时监控与企微告警
- 统一客服能力接入
- 降低长期系统成本与外部依赖

**需求定性**

| 

255
incomplete
用户反馈/调研

256
complete
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
complete
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
本需求将现有基于 Zendesk 的 Help Center 和反馈入口迁移接入至集团客服中台（覆盖 App 与 Web 端），并优化反馈入口展示位置（优化用户反馈找不到客服入口的问题），同时支持用户信息透传。

- 客服中台接入技术文档：[https://cf.meitu.com/confluence/x/iwSJE](https://cf.meitu.com/confluence/x/iwSJE)

需求内容：

- 帮助中心-Help Center 接入客服中台

| 
 | 当前 | 需求
 ||
| App端 | 

- 用户路径：App > Settings > Help Center > FAQ页面
- FAQ页面内包含反馈入口（右上角）
- 当前Help Center及反馈链路均接入 Zendesk

 | 

- 保留「Help Center」作为统一入口
- 将原 Zendesk Help Center 替换为集团客服中台能力
- FAQ 内容接入中台页面

 ||
| Web端 | 

- Web端（ABM / ABS / ABW）当前 Help Center 基于 Zendesk

 | 
- 替换为中台 Help Center 页面
- 涉及 FAQ 内容迁移与配置

 ||

2. 反馈入口调整

| 
 | 
 ||
| **现状：**

- 反馈入口位于 FAQ 页面右上角（Zendesk）
- 存在用户差评反馈：入口不明显，存在"找不到反馈入口"的问题。
- 

 | **需求：**

- 保留 Help Center 内统一结构（FAQ + Feedback 属于同一 Help Center）
- 将反馈入口从右上角调整至 FAQ 页面底部区域（更高可见度），可参考下图
- 入口文案统一为：
- Contact Support 

- 点击反馈入口后跳转至：/m/feedback/submit（中台反馈提交页）

- 

 ||

3. 用户信息获取

| 
 | 
 ||
| App进入反馈页时需拉取用户信息至客服中台，用于工单识别与分析。

- 拉取字段：
GID:
User ID:
Subscription status:（false/trure）
Platform: （iOS/Android）
App Version:
Device System:
Device Model:
Country:
Device ID:

- 需要拉取用户日志，用于问题排查。

 | 
 ||

## 四、影响范围/核对内容

| 影响范围 | 

 ||
| 需要产品验收内容 | 
 ||
| 需要效果验收内容 | 

 ||

## 五、订阅相关

## 六、协议跳转
如有变化需要在这个CF中增减记录：

七、翻译
反馈入口文案：

| 中文 | 英文 ||
| 联系客服 | Contact Support ||

## 八、埋点需求
与线上一致
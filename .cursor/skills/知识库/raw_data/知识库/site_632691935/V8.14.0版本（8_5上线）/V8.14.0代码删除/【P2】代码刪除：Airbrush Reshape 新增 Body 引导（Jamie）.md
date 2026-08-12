# 【P2】代码刪除：Airbrush Reshape 新增 Body 引导（Jamie）

**页面ID**: 709003896

**路径**: V8.14.0版本（8_5上线）/V8.14.0代码删除/【P2】代码刪除：Airbrush Reshape 新增 Body 引导（Jamie）

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
| 2026.06.30 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为了提升 Body 功能的入口曝光与进入转化，本次实验在 Reshape 完成有效调整后，于编辑器主画面新增 banner 引导用户进入 Body 功能，整体结论：

- **关键指标：**
- 对整体：保存率、留存率、订阅率无显著变化
- 对 Body：引导横幅带动 Body 进入率显著上涨 12%，保存率显著上涨 4%（24.73%->25.74%）；Body 订阅率无显著变化
- Body 引导横幅曝光率 62%，横幅曝光->点击率 11%
- 其他二级功能的进入保存无明显波动，分国家（美英巴）无明显差异

- 因此本次将**双端全量实验组**，本次需求删除相关实验代码。

变更实验结论和数据见：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=658379090](26年实验与分析汇总)

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
1、需求详述
历史需求：
实验连接：[https://qiming-voyager.pixocial.com/experiment/11409/result/status](https://qiming-voyager.pixocial.com/experiment/11409/result/status)
数据文档：见 [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=658379090](26年实验与分析汇总)（序号45）

停止实验，双端全量实验组（Reshape 完成有效调整后的 Body 引导 banner 成为线上正式功能），删除相关实验代码：

- 删除 AB 实验分流、分组判断相关代码，实验组逻辑转为默认逻辑
- banner 的触发条件、展示规则、交互流程、黑后台配置（全局/国家/版本开关、文案、频次上限）均维持原实验组逻辑不变
- 代码删除后功能表现与线上实验组一致，不产生任何用户可感知的变化

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有

- 原实验新增埋点全部保留（banner 曝光、banner 点击 CTA、banner 主动关闭、banner 自动消失、Body 进入来源 source=reshape_banner，以及由 banner 进入后 Body 内的打勾、保存、订阅相关行为按 source 维度拆分）
- 仅删除 AB 实验分组标识相关上报字段
- 删除实验代码后需回归验证以上埋点上报正常，不受代码删除影响
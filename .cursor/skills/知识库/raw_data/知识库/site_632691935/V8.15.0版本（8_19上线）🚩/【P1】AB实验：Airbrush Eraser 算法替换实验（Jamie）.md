# 【P1】AB实验：Airbrush Eraser 算法替换实验（Jamie）

**页面ID**: 705517653

**路径**: V8.15.0版本（8_19上线）🚩/【P1】AB实验：Airbrush Eraser 算法替换实验（Jamie）

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
complete
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
| 2026.06.30 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 在观察用户效果图时，发现当前消除模块的算法有明显的 ①小人脸、②图片细节保持、③涂抹残留等效果问题，考虑到AI消除为大量用户使用且转化极佳的刚需功能，期望是能提高模块的整体功能能力。

参考文档：

- 集团现有的填充算法对比线上的消除填充，对比起来优势明显：

- 纹理细节更真实自然
- 不易增生
- 消除人像无影子残留
- 部分场景下的修复效果更佳

👉 基本上能解决当前线上算法的所有痛点问题
参考文档： 

3. 因此，想针对 Eraser 当前模块做新算法的替换实验，期望能增加模块的功能转化率。

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
1、如涉及算法，注明算法相关信息

| xxxx算法接口 | **qwen版mask based消除算法**
/v1/mtimage_mask_rm_qw_async
 ||
| demo地址 | 涂抹消除：
[https://insight-mtlab.meitu-int.com/viewer?id=2486](https://insight-mtlab.meitu-int.com/viewer?id=2486)

平均耗时：8s

 ||
| 算法对接人 | 张玏 ||
| 效果设计师 | Cora ||

2、实验设置
主要目标：Eraser 的 填充算法替换

- 影响子功能：AI消除、路人消除、文字消除、杂物消除（除了：镜面去污）
- 产品进行实验验收
- 设计需涉入核对

- 子功能对应接口，调整成AIGC配方样式，以提供不用发版的调整弹性

- 原交互流程不改变。

针对 Eraser 功能做如下 AAB 实验：

| **实验类型**
 | 客户端 AAB 实验
 ||
| **实验方式**
 | 观察对比实验组与对照组在 Eraser 的曝光、进入、打勾、保存及付费差异
 ||
| **重点关注数据
****（分析师评估）**
 | P0：Eraser 的曝光 UV、进入 UV、进入打勾率、保存率、付费；
同时监控 Plump 后移后是否产生明显负向（曝光 / 进入 / 付费）
 ||
| **实验命中条件**
 | 用户进入 Eraser 板块时
 ||
| **停止方式**
 | 根据结果决定关闭实验、继续扩大流量，或一键同步给当前版本所有用户
 ||
| **流量控制**
 | 线上组 A / 对照组 AA / 实验组 B 每组各 15%
 ||
| **实验周期**
 | 30 天（看结果决定是否延长）
 ||
| **线上组 A / ****对照组 AA**
 | 保持目前线上填充算法
 ||
| **实验组 B**
 | 新的qwen版填充
 ||

| 
 | token_type | 现状 | 8.14.0升级 ||
| AI橡皮擦 | remove | 8001028（/v1/sd_async） | pre: 8000515
prod: 8001799 ||
| 
 | 
 | 
 | 
 ||
| 路人消除获取mask | remove | /v1/keyperson_async | 
 ||
| 路人消除 | remove | 8001027（/v1/sd_async） | pre: 8000516
prod: 8001798 ||
| 
 | 
 | 
 | 
 ||
| 杂物消除 | remove | /v1/mtimage_remove_flux_async (未使用配方请求)
pre: 8000520
prod: 8001794 | pre: 8000517
prod: 8001797 ||
| 杂物分割二期 | remove | /v1/img_sundries_segv2_async | 
 ||
| 
 | 
 | 
 | 
 ||
| 文字 图片 消除 | remove | /v1/text_remover_img_sd_async (未使用配方请求)
pre: 8000519
prod: 8001795 | pre: 8000518
prod: 8001796 ||
| 文字 图片 获取mask | remove | pre: 8000310
prod: 8001208（/v1/eraser_watermark_v2_async） | 
 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
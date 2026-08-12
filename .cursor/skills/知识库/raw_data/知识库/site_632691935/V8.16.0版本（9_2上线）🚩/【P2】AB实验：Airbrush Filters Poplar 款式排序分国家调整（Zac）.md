# 【P2】AB实验：Airbrush Filters Poplar 款式排序分国家调整（Zac）

**页面ID**: 710797071

**路径**: V8.16.0版本（9_2上线）🚩/【P2】AB实验：Airbrush Filters Poplar 款式排序分国家调整（Zac）

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

#### 更改记录：

| 2026.08.09 | Zac | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

- 巴西专项调研中发现，Filters 在巴西和美国均属于高使用模块：7/1-7/27 模块数据中，Filters 在巴西进入量 **164.6万，排名第 3**；在美国进入量 **73.4万，排名第 3**。进一步分析 filters popular 款式后发现，巴西和美国用户对滤镜的偏好存在差异，而线上排序仅有一种，没有根据美巴用户的喜好进行定制化。
- 因此本次希望结合**总打勾 uv 及点击-打勾的转化率**通过分国家排序 AB Test，验证按国家调整 popular 款式排序后，是否能提升热门 filters 的曝光承接、点击、打勾，并进一步带动保存和订阅转化。
- 排序逻辑：优先参考 **点击&rarr;打勾率**，**曝光&rarr;点击率** 仅作为素材吸引力的辅助指标。若两个素材点击&rarr;打勾接近，则优先选择打勾量更高的素材。

| 排名 | 当前线上排序 | 巴西建议排序 | 巴西曝光量 | 巴西打勾量 | 巴西曝光&rarr;点击 | 巴西点击&rarr;打勾 | 美国建议排序 | 美国曝光量 | 美国打勾量 | 美国曝光&rarr;点击 | 美国点击&rarr;打勾 ||
| 1 | Glow-4 | Glow-4 | 70.7万 | 7.6万 | 54.7% | 19.6% | Glow-4 | 29.5万 | 3.3万 | 52.4% | 21.5% ||
| 2 | FJ-1 | FJ-1 | 70.7万 | 6.5万 | 47.6% | 19.4% | Brighten | 17.3万 | 2.1万 | 64.5% | 19.2% ||
| 3 | iP 8 | Depth | 19.7万 | 2.3万 | 60.6% | 19.6% | FJ-1 | 29.5万 | 2.4万 | 44.7% | 18.3% ||
| 4 | Deep Azure | Brighten | 42.1万 | 4.6万 | 62.8% | 17.3% | Bora | 25.8万 | 1.5万 | 46.7% | 12.6% ||
| 5 | Bright White | Bora | 57.8万 | 4.9万 | 53.0% | 15.9% | iP 8 | 29.3万 | 1.6万 | 44.2% | 12.2% ||
| 6 | Bora | Maldives | 29.7万 | 2.2万 | 58.9% | 12.3% | Depth | 11.0万 | 0.8万 | 60.2% | 12.0% ||
| 7 | Ibiza | iP 8 | 70.5万 | 3.8万 | 45.8% | 11.7% | Maldives | 12.3万 | 0.8万 | 58.7% | 10.7% ||
| 8 | Brighten | Rosy | 17.4万 | 1.1万 | 59.8% | 10.8% | Rosy | 7.8万 | 0.4万 | 60.6% | 9.0% ||
| 9 | Dreamy | Deep Azure | 70.4万 | 2.1万 | 47.0% | 6.5% | Bright White | 29.3万 | 1.2万 | 47.9% | 8.2% ||
| 10 | Vintage-1 | Bright White | 70.4万 | 1.8万 | 47.9% | 5.4% | Deep Azure | 29.3万 | 1.1万 | 45.6% | 8.0% ||
| 11 | Classic | Vintage-1 | 36.7万 | 1.2万 | 60.8% | 5.4% | Vintage-1 | 15.2万 | 0.6万 | 61.4% | 6.3% ||

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
incomplete
基础型：必备，缺失会引起不满

294
complete
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

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
incomplete
5-20万

1143
complete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

预计数据回收时间：

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

| **组别 ** | **内容** | 流量 ||
| 对照组（线上） | Filters - Popular 款式 排序
FJ-1 > Glow-4 > Bright White > Deep Azure > iP 8 > Bora > Ibiza > Brighten > Dreamy > Vintage-1 > Classic
 | 33.3%
 ||
| Test A | Filters - Popular 款式 排序
Glow-4 > FJ-1 > Depth > Brighten > Bora > Maldives > iP 8 > Rosy > Deep Azure > Bright White > Vintage-1
 | 33.3% ||
| Test B | Filters - Popular 款式 排序
Glow-4 > Brighten > FJ-1 > Bora > iP 8 > Depth > Maldives > Rosy > Bright White > Deep Azure > Vintage-1
 | 33.3% ||
| 实验触发时机
 | 用户进入 Filters 模块时
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | / ||

## 六、协议跳转
/

## 七、翻译
/
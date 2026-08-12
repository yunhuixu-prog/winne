# 【P2】技术：Airbrush 图片EXIF保存信息优化（曾曾）

**页面ID**: 661768586

**路径**: V8.2.0版本（2_4上线）/V8.2.0技术需求/【P2】技术：Airbrush 图片EXIF保存信息优化（曾曾）

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
| 2025.1.16 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | ||

## 一、需求背景

- 当前 Airbrush 导出的图片在保存信息中，仅保留**位置信息**，**镜头信息**与**拍摄时间信息**未保留。

- 因此在用户反馈中，收到较多反馈关于这部分的负向反馈，并且表示希望可以在图片编辑保存后保留这部分信息。

- 

**竞品分析**

| 竞品和现状 ||
| 
- remini 镜头信息❌，位置信息☑️，时间☑️，最后一张❌

- faceapp 镜头信息☑️，位置信息☑️，时间❌，最后一张☑️

- facetune 镜头信息☑️，位置信息☑️，时间☑️，最后一张❌？

- 秀秀 镜头信息☑️，位置信息☑️，时间❌，最后一张☑️

- Airbrush 镜头信息❌，位置信息☑️，时间❌，最后一张☑️

- Airbrush （改动前） 镜头信息❌，位置信息（开关控制），时间（开关控制），最后一张（开关控制）

 ||

**需求定性**

| 

255
complete
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
complete
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
incomplete
期望型：做越多，用户越满意

295
complete
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

| 

1189
incomplete
用户指标

 | 

299
incomplete
保存率

 | 
 | 
 ||
| 

280
incomplete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
complete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 | 
 | 
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
/

## 五、需求描述
**需求目标**
在图片保存信息（EXIF）中，完整保留以下拍摄信息：

- ☑️ 镜头信息

- ☑️ 位置信息

- ☑️ 拍摄时间

**需求说明**
用户保存图片后，在系统相册或第三方应用中查看图片信息时，可正常读取镜头型号、拍摄地点及拍摄时间，保证图片信息的完整性与专业性。

3、订阅限免策略
/

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
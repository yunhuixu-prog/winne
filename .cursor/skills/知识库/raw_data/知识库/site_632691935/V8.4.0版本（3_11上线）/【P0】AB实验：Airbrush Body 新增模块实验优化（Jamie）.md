# 【P0】AB实验：Airbrush Body 新增模块实验优化（Jamie）

**页面ID**: 669675038

**路径**: V8.4.0版本（3_11上线）/【P0】AB实验：Airbrush Body 新增模块实验优化（Jamie）

---

#### JIRA地址： 

服务端：

| 模块 | 

1181
incomplete
**翻译**

 | 

1182
incomplete
**隐私整改**

 | 

1183
complete
 **UI**

 | 

1184
incomplete
**特效**

 | 

1185
incomplete
**AR**

 | 

1186
incomplete
**素材**

 | 

1187
incomplete
 **前端**

 | 

1188
incomplete
**服务端**

 | 

1194
complete
设计

 | 

1189
complete
**底层**

 | 

1190
complete
**iOS**

 | 

1191
complete
 **Android**

 | 

1192
complete
**测试**

 ||

# 前置项

| 前置项
 | 负责人 | 预计完成时间 | 状态
 | 备注（进展） ||
| | Jamie | 
 | 
 | 
 ||

**需求变更记录表**

| 更新时间
 | 更新内容
 | 变更发起人
 ||
| 2026/02/12 | 创建文档 | Jamie ||

# 一、需求背景

- body 新增模块实验对模块整体的「留存」和「订阅」没有显著影响，但「保存」、「进入」指标正负向参半。数据是判断实验组有可以优化的地方，建议先回滚然后调整实验组，继续实验

- 「保存下降」原因分析：
- 保存量Top子功能比如 Waist、Arms、Hips 的位置在实验组内被调后，曝光量下跌导致到整个模块的保存。
- 新上线其中四个功能为付费，带动Body人均进入次数上升，但由于需付费不打勾，没有带动使用渗透率。
- 观察到仅有5%用户会同时使用 body + stretch，本次实验组把Stretch放到首位，同时还因为底层无法兼容导致效果出现固化，整体体验不佳，推测是其中一个主因。

- 因此在本次需求中，调整实验组内容
① 移除Stretch （与body共同使用率低）
② 调整分组后的整体排序，依照进入量分成 主部位、细分部位，再照 保存量高的功能顺序往前排序（Slim、waist、hips、breast...）

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

# 二、相关文档

# 三、功能数据目标（勾选对应指标）

| **用户指标**
 | **保存率**
 ||
| 

280
complete
收入指标（如有）

 | 

1141
complete
20万以上

1142
incomplete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

# 四、预估投入工时

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

# 五、需求原型

# 六 、需求描述
**1**、需求详述**

| 需求描述 ||
| **body模块实验组优化**
＊依赖于前置需求：的实验组B

1、移除拉伸

- 移除拉伸分类
- 移除垂直拉伸、水平拉伸
- 取消原拉伸与body其他功能的固化逻辑

2、分类更改、重新排序

- shape 分类 
- auto、slim、waist、hips、breast、arm、legs、tummy、length
- waist (包含 S line)

- details 分类（新增）
- shoulder、head、buttock、neck、square shoulder、neck length、neck width

3、付费转免费

- neck length、neck width 转为免费功能

 ||

**2、实验详述**
AAB 实验 
实验触发时机：进入body功能时

| 组别 | 对照组A | 对照组AA | 实验组B ||
| 内容 | 线上版本 | 线上版本 | 此次调整 ||
| 流量 | 33% | 33% | 33% ||
| 实验周期 | 2 周 ||
| 对比数据 | 模块的打勾率、订阅情况 ||

# 七、协议跳转

# 无

# 八、翻译

| EN | CHS ||
| shape | 身形 ||
| features
details
 | 局部 ||

# 九、埋点需求
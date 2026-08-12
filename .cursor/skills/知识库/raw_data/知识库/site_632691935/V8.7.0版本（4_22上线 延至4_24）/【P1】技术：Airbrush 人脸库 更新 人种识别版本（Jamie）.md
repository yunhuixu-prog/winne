# 【P1】技术：Airbrush 人脸库 更新 人种识别版本（Jamie）

**页面ID**: 673238511

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P1】技术：Airbrush 人脸库 更新 人种识别版本（Jamie）

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
complete
底层

 | 

1211
incomplete
iOS

 | 

1212
incomplete
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
| 2026.03.05 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：
1、人脸库版本更新，迭代人种识别算法更新后的版本，降低以后在智能美颜需求的工作量。

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

## 三、需求描述
1.具体修改点/影响范围
2.技术重构需要提供目标框架

- 底层人脸库更新致 6.3.1.0 版本

[https://doc.weixin.qq.com/sheet/e3_ALsAJQYJABoMA92VZO8RXuV7pHxXy?scode=ACIAJAeGAAgXdRsy1DARQA8QZwACQ&tab=7gcg1q](https://doc.weixin.qq.com/sheet/e3_ALsAJQYJABoMA92VZO8RXuV7pHxXy?scode=ACIAJAeGAAgXdRsy1DARQA8QZwACQ&tab=7gcg1q)

## 四、影响范围/核对内容

| 影响范围 | 人脸库
 ||
| 需要产品验收内容 | 无，仅底层改造，功能逻辑与线上一致 ||
| 需要效果验收内容 | 人脸库升级会导致人脸点变动，人脸检测功能是否正常（跟线上版本对比一些图）
主要影响的功能：
编辑-打光
编辑-光斑虚化/虚化
美颜-美颜
美颜-美颜魔法
美颜-重塑
美颜-美妆
美颜-肌肤
美颜-面部丰盈
美颜-焕肤
美颜-塑型
美颜-增肌
美颜-表情修复
美颜-美牙-白牙
美颜-闪光
滤镜
头发
风格
特效

视频-各个美颜子项

相机-滤镜 / 美颜等效果是否正常，是否符合预期
 ||

## 五、埋点需求
新增人种埋点
# 【P0】体验优化：Airbrush云端功能文件大小优化（阿不）-- Android

**页面ID**: 652654889

**路径**: V8.0.0版本（1_7上线）/v8.0.0技术需求/【P0】体验优化：Airbrush云端功能文件大小优化（阿不）-- Android

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
| 
 | 
 | 
 | 
 ||
| 2025.11.27 | 阿不 | 创建文档
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

影响云处理性能的关键要素：上传耗时+算法耗时+下载耗时。
1. 文件上传耗时，文件上传耗时的几个影响因素：文件大小，上传策略，用户网络，服务链路。其中，用户网络和服务链路，一般我们可影响的空间较小。一般意义：文件越小上传时间越短。上传策略，技术也会不断优化。
2. 算法的处理耗时，算法的处理耗时一般跟图片尺寸影响最大。
3. 下载耗时，下行带宽都比较高，下载的耗时都会比较短，成功率也会比较高。当然下载文件大小也有相关性，由算法服务端决定。
影响文件大小的因素：
1. 分辨率，分辨率越大，文件越大。
2. 压缩算法，目前主流JPG，iOS还有HEIC。从兼容性和压缩性能来评估，目前还是JPG为主，影响JPG压缩率还有一个压缩因子，0-1，值越大文件越大。通常我们设置 0.95以上，肉眼感知不太出来。
建议标准：
1. 分辨率，对AI绘画类的行业现状一般是 1K或者2K，MD超高清4K。针对我们传统的基于原图修改的，我们上限建议是 4K。目前市面上的手机拍摄和对超高清的标准，还是4K。这个也会比较大影响算法耗时。
2. 对于部分算法，如果能够裁剪局部图上传的就尽量用局部图。
3. 上传文件格式统一为JPG，压缩因子设置 0.95 。
技术参数的调整，效果简单核对即可，此需求已经在美图秀秀落地一年以上，参考文档：[https://doc.weixin.qq.com/sheet/e3_AN0A1QbSAJwNvTbZuiTS6Cl5AOP05?scode=ACIAJAeGAAgTSmo6LkAN0A1QbSAJw&tab=BB08J2](https://doc.weixin.qq.com/sheet/e3_AN0A1QbSAJwNvTbZuiTS6Cl5AOP05?scode=ACIAJAeGAAgTSmo6LkAN0A1QbSAJw&tab=BB08J2)。

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
提升云端处理功能性能，当前为 93.2%，提升到 95%。

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

## 四、需求描述

对所有AI云端功能，进行统一梳理现状，[https://doc.weixin.qq.com/sheet/e3_AfwAcwbtAFsCNG1lzFq56TXi7EbO6?scode=ACIAJAeGAAgFFD6Ea5AN0A1QbSAJw&tab=BB08J2](https://doc.weixin.qq.com/sheet/e3_AfwAcwbtAFsCNG1lzFq56TXi7EbO6?scode=ACIAJAeGAAgFFD6Ea5AN0A1QbSAJw&tab=BB08J2) ，结合以下需求进行调整：
1. 分辨率，对AI绘画类的行业现状一般是 1K或者2K（AI Image和MagicStudio 根据素材配置在线调整）。针对我们传统的基于原图修改的，我们长边上限为 4096。
2. 对于部分算法，如果能够裁剪局部图上传的就尽量用局部图。
3. 上传文件格式统一为JPG，压缩因子设置 0.95 。

## 五、协议跳转
无

## 六、翻译
无

## 七、埋点需求
# 【P1】技术：Duffle素材接入Airbrush业务素材下发服务

**页面ID**: 674338876

**路径**: V8.5.0版本（3_25上线）/v8.5.0技术需求/【P1】技术：Duffle素材接入Airbrush业务素材下发服务

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

| **更新时间**
 | **更改人**
 | **更改内容（变更用不同颜色mark）**
 | **备注**
 ||
| **2025.03.09** | **冀木保** | **创建文档**
 | 
 ||
| 
 | 
 | 
 | 
 ||

#### **涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）**

| **涉及模块** | 
 ||
| **涉及第三方业务/APP** | 
 ||

## **一、需求背景**
业务后端服务，主要包括：Airbrush订阅运营系统（黑后台），Airbrush业务下发服务（素材、配置等）
Duffle正在逐步把素材迁移到素材中台，后续需要统一经过业务下发服务下发数据，方便后续中台融合做兼容等处理，并且现在双端接入还没统一。

- 存量素材：滤镜、字体、文字样式、背景、AI焕颜、妆容套装、风格化、人像预设、闪光、图片特效、表情、AI肖像、AI发型、AI预设、氛围光、纹身、染发、发质、发量、眉毛、睫毛、眼线、眼影、美瞳、腮红、口红、修容
- 安卓已接入：文字样式、背景、AI焕颜、闪光、表情、眉毛、睫毛、眼线、眼影、美瞳、腮红、口红、修容
- iOS已接入：滤镜、AI Retouch、纹身

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
/

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

统一使用以下域名接入素材：
beta：https://[http://test-airbrush-palette.pixocial.com](test-airbrush-)[https://airbrush-material.pixocial.com](material.pixocial.com)
prod：[https://airbrush-material.pixocial.com](https://airbrush-material.pixocial.com)
注意：[https://airbrush-palette.pixocial.com/v1/material](https://airbrush-palette.pixocial.com/v1/material)y也要替换；可以趁这次修改，梳理下哪些字段是端侧不解析，冗余下发的，可以去掉

## 六、翻译
翻译文档link

## 七、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
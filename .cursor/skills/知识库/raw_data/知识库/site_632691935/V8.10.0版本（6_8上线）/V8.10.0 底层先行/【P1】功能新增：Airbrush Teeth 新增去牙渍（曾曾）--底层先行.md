# 【P1】功能新增：Airbrush Teeth 新增去牙渍（曾曾）--底层先行

**页面ID**: 692590654

**路径**: V8.10.0版本（6_8上线）/V8.10.0 底层先行/【P1】功能新增：Airbrush Teeth 新增去牙渍（曾曾）--底层先行

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

1215
complete
效果

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
 | 更改内容
 ||
| 2026.4.16 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Teeth 模块作为端内高点击、高转化的核心功能，已较长时间未进行能力更新。数据显示，在巴西狂欢节、圣诞元旦等节日期间，Teeth 模块的保存率与渗透率均有明显提升，推测与节日期间用户拍摄更多笑容类照片、美牙需求增长有关。
基于 Teeth 模块良好的用户需求与转化表现，需进一步进行功能迭代升级，持续增强产品体验与功能壁垒，为用户带来更具惊喜感的效果体验。因此，本次计划新增云修「去牙渍」效果，进一步提升牙齿净白与整体笑容表现力。

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
incomplete
不提升复杂度

284
incomplete
化繁为简

285
complete
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
incomplete
不产生口碑传播

288
complete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

**功能数据目标（勾选对应指标）**

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
complete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

## 二、预估投入工时

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

## 三、原型流程图

## 四、需求描述
接口文档：
效果评估文档：[https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNdJ50A6YYRsCNG0ex?scode=ACIAJAeGAAga5lnyY2AUIAHwa6ABY](https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNdJ50A6YYRsCNG0ex?scode=ACIAJAeGAAga5lnyY2AUIAHwa6ABY)

| 原型图 | 需求描述 ||
| 
 | **功能入口：**Retouch-Teeth-**Stains**
**视觉**

- 新增去牙渍icon，排第三位，icon上方展示按钮开关，默认关

**交互流程**

- 首次展示「new」角标，点击后消失
- 点击Stains后进入loading流程（组件2无✖️）
- loading流程结束后返回效果，按钮开关高亮，再次点击可关闭

**叠加/互斥逻辑**

- 去牙渍效果可与白牙/整牙叠加使用
- 使用白牙/整牙后回到牙齿首页，在使用过的功能下应增加小黄点
- 牙齿检测逻辑维持线上
- 去牙渍不支持多人脸区分，识别到多人脸牙齿统一上效果

**固化/记忆逻辑**

- 不固化，进入整牙或白牙功能使用返回后，使用去牙渍，再次进入白牙/整牙仍可以调节，并记忆住上一次调节的参数
- 打勾/打✖️以后则不记忆

**其他**

- 牙齿首页底部的返回组件替换为打勾组件
- 白牙/整牙底部的组件替换为返回组件
- 牙齿首页增加对比按钮，点击对比按钮为原图和所有效果的对比
- 在美牙功能入口前置牙齿检测逻辑，若图片未检测到有效牙齿，则将「牙齿整齐」「去牙渍」功能入口置灰，避免用户进入功能后加载失败并退出。

 ||

## 五、订阅相关
订阅，非会员可不限次数预览不可打勾

## 六、协议跳转
新功能，需要新增dl链接🔗：
七、翻译

## 八、埋点需求
新增Stains功能的曝光/点击/打勾/保存的UV/PV
# 【P2】体验优化：Airbrush 新增公测用户弹窗（Jamie）- iOS

**页面ID**: 666088582

**路径**: V8.3.0版本（2_26上线）/【P2】体验优化：Airbrush 新增公测用户弹窗（Jamie）- iOS

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
| 2026.01.28 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 为了减少线上崩溃的发生和修复包的个数，考虑在 iOS 加上公测流程
- 公测期间，通过对线上用户下发拉新弹窗，引导用户下载 TestFlight，安装 App。 公测弹窗具体文案："xxxx"
- 公测弹窗下发时间：公测包发布之后发送。预计周二晚上。

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
incomplete
高频

274
incomplete
中频

275
complete
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
incomplete
基础型：必备，缺失会引起不满

294
incomplete
期望型：做越多，用户越满意

295
incomplete
惊喜型：缺失不会引起不满，一但具备会显著提升满意度

296
complete
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

**1、需求内容**

- 针对保存时的 iOS 用户弹窗针对性的弹窗，

- 客户端需要添加 isTestFlight 参数，用以标识用户是否为 TestFlight 包。

**2、弹窗位置**

- 保分页，非公测用户于保存时弹出

**3、弹窗策略**

- 需能通过后台配置控制弹框频率。
- 当前策略：
- 冷启动后首次保分页的状况下弹出
- 需排除公测用户
- 触发弹窗后，n 天不可再次弹出。（n 需为后台配置）
- 若满足公测用户数量后，即不再弹出。

**4、弹窗文案**

- **标题：**
- Be the First to Try Every New Update

- 按钮：**
- Join the Beta

- 点击后对应拉起 app store: testflight 连结，引导用户下载

- Maybe Later

- 点击后回到保分页

## 六、协议跳转

## 七、翻译

| EN | CHS ||
| 
- Be the First to Try Every New Update
- Join the Beta
- Maybe Later

 | 
- 抢先体验所有最新更新

- 加入抢先体验

- 以后再说

 ||

## 八、埋点需求
新增 isTestFlight 埋点
新增 testflight 弹窗曝光、点击埋点
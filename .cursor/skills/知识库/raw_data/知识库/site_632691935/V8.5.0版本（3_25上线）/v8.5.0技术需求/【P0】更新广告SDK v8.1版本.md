# 【P0】更新广告SDK v8.1版本

**页面ID**: 674359945

**路径**: V8.5.0版本（3_25上线）/v8.5.0技术需求/【P0】更新广告SDK v8.1版本

---

**JIRA地址： **

#### 前置项

| 模块 | 负责人 | 进度 | 备注 ||
| - | 
 | 
 | 
 ||

#### 更改记录：

| 日期 | 操作人 | 更新内容 | 备注 ||
| 2026.3.10 | 元龙 | 更新sdk | 
 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景：

- Airbrush展示小banner有裁切，需要按照固定尺寸来渲染banner。
- Airbrush激励视频填充不够，增加本地兜底逻辑，防止用户使用链路阻塞。

需求定性

| 

256
incomplete
用户反馈/调研

257
incomplete
公司/产品战略

258
incomplete
自己灵感/推演

259
incomplete
竞品跟进

260
incomplete
运营推广

261
incomplete
技术研发

262
incomplete
老板提的

263
incomplete
我党提的

264
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

### 2、需求说明
需求文档：

| 类别
 | 端
 | 需求类型
 | 需求负责人
 | 文档/URL
 | 依赖开发模块
 | 宿主是否开发
 | 需评跟进
 | 优先级
 | 计划进版
 | 备注
 ||
| 合规需求
 | 

 ||
| 1 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 广告需求
 | 
 | 
 | 
 | 
 ||
| 2 | 双端
 | 收入
 | 元龙
 | 

 | 前端、服务端、uve、数据、引擎 | 
 | 
 | P0 | 进 | 
 ||
| 3 | 双端
 | 优化
 | 元龙
 | 

 | 前端、服务端、uve | 
 | 范围要再定下，
技术评审定 | P0 | 进 | 
 ||
| 4 | 双端 | 优化 | 元龙 | 

 | uve | 
 | 
 | 
 | 
 | 
 ||
| 5 | 安卓
 | 优化
 | 耔霏
 | 

 | 
 | 
 | 
 | P0 | 进 | 
 ||
| 6 | ios | 优化 | 耔霏 | 

 | 前端、服务端 | 
 | 
 | P0 | 进 | 
 ||
| 7 | 双端 | 收入 | 丽娟 | 

 | 前端、服务端、uve | 
 | 
 | P0 | 进 | 
 ||
| 技术优化
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 8 | android
 | 折损优化专项
 | 友凤
 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 9 | android
 | 增收
 | 友凤
 | 
 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 10 | android | 折损优化专项 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 11 | android | 折损优化专项 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 12 | android | 折损优化专项 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 13 | android | 优化 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 14 | android | 优化 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 15 | android | 优化 | 何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 16 | iOS
 | 优化
 | 康剑全
 | [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=662856939]([iOS] 三方源崩溃拦截问题优化)

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 17 | iOS
 | 优化
 | 康剑全
 | [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=661766528]([iOS] 自渲染样式插屏自刷新逻辑优化)

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 18 | iOS
 | 优化
 | 康剑全
 | [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=661771749]([iOS] 首次安装setting请求优化&配置异常上报)

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 19 | iOS | 三方SDK维护和扩展 | 王文龙 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 20 | iOS | 历史问题修复 | 王文龙 | 

 | 
 | 
 | 
 | P1 | 待定 | 同测试沟通下 ||
| 21 | 双端 | 基础数据采集 | 王文龙/何昆 | 

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| 数据需求
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 22 | android
 | 
 | 
 | 开屏位置链路耗时上报（实验控制）

 | 
 | 
 | 
 | P1 | 进 | 
 ||
| BUG修复
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 23 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||

Tips：
1、需求提前一周通知收集，依赖服务端要注明：
2、大需求或长线需求，产品可单独约研发和测试需评；
3、版本需评前2天，增加需求预审环节；
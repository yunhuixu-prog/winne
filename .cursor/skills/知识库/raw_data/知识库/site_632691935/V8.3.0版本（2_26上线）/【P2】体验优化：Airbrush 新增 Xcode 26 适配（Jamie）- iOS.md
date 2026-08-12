# 【P2】体验优化：Airbrush 新增 Xcode 26 适配（Jamie）- iOS

**页面ID**: 662842490

**路径**: V8.3.0版本（2_26上线）/【P2】体验优化：Airbrush 新增 Xcode 26 适配（Jamie）- iOS

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

- 蘋果在 iOS26 推广玻璃UI，导致我们的应用在Xcode26打包的情况下会出现一些 UI 效果异常：
- 顶部NavigationBar
- 首页底部Tabbar
- 设置开关按钮
- 滑杆组件

- 當前是开启了UI兼容模式，但是这个方案苹果表示下个大版本（也就是明年的Xcode27）会移除，所以期望是在這些交互上替換成自制的控件，以避免 xcode 26 的整體影響。

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
1、需求需包含以下内容，具体格式不限制，只要规整易读即可
**需求内容**

- 针对 iOS 26 做 UI 的适配，除部分组件照线上替换组件样式更改之外，有几个额外列出的组件需照订制的样式更改。

**组件调整**

- 返回按钮 和 Toolbars
- 更改内容：iOS 26 和其他 iOS 版本样式不一致，需按照线上替换组件更改。
- 涉及页面＆模块：
- Magic Studio - AI Image
- Magic Studio - AI Portrait
- Magic Studio - History
- Magic Studio - My AI Avatar
- Magic Studio - Upload Photos
- Magic Studio - 结果页

- Tabbar
- 更改内容：有严重 Bug，导致 Tabbar 不可点，需另外定制自定义 Tabbar
- 涉及页面＆模块：
- HomePage

- Toggles
- 更改内容：iOS 26 和其他 iOS 版本样式不一致，且有样式 Bug，需另外定制自定义 Toggles
- 涉及页面＆模块：
- Settings 页面
- Personalization and Data 页面
- Retouch - Magic (背景保护)
- Retouch - Reshape (背景保护)
- Retouch - Resize (背景保护)
- Retouch - Face (背景保护)
- Retouch - Body (背景保护)
- Retouch - Plumping (auto)
- Manange My Kit (Set as default 按钮)

- List
- 更改内容：iOS 26 设备和其他设备列表圆角不统一，需另外定制自定义 List
- 涉及页面＆模块：
- Settings 页面
- Personalization and Data 页面
- Language 页面
- Clear Cache 页面
- About Airbrush 页面

- Keyboard
- 更改内容：页面有Bug，需另外定制。键盘底部区域添加色块，颜色和上层 input 组件背景保持一致

- 涉及页面＆模块：
- Text
- Tattoo
- AI Replace

详情请参考 UI 稿件。

## 六、协议跳转
-

## 七、翻译
-

## 八、埋点需求
-
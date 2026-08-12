# 【P2】AB实验：Airbrush Acne、Concealer 加入匀肤效果（帅王）

**页面ID**: 705516110

**路径**: V8.13.0版本（7_22上线）🚩/【P2】AB实验：Airbrush Acne、Concealer 加入匀肤效果（帅王）

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
| 2025.08.22 | 
 | 
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
当前 Skin 模块中：Smooth、Acne、Skin Tone长期属于**高点击、高打勾、高保存**功能，是用户**核心使用功能**。
其中：Smooth：全局磨皮、Acne：去除点状瑕疵（痘痘、痘印）Concealer：淡化片状瑕疵（暗沉、色斑）
虽然功能使用表现稳定，但 2026 年核心指标 **Enter to Save 出现 1~2% 下滑**，说明用户对现有效果的满意度存在下降趋势。
当前 Acne 和 Concealer 在面部瑕疵处理上仍存在能力缺口：

- **浅肤用户：泛红问题明显**
- **深肤用户：色沉问题明显**

现有功能对以上痛点覆盖不足。
因此希望通过引入 秀秀**匀肤（Even Skin Tone）技术**（**备注：因为祛痘手动是单独手动算法，所以祛痘暂时只加入自动，不加手动，低成本实验，Concealer是自动➕手动一起）**，增强 Acne 与 Concealer 对泛红、色沉的处理能力，提升功能效果表现。

**竞品分析**
****
****
**竞品对比**
从肤质能力来看：

| 能力 | AB | Facetune | FaceApp ||
| 磨皮 | 强 | 强 | 强 ||
| 祛痘 | 强 | 中 | 中 ||
| 匀肤 | 弱 | 中 | 中 ||
| 祛红 | 弱 | 中 | 中 ||
| 保留原肤色 | 强 | 中 | 弱 ||
| 可控性 | 强 | 强 | 弱 ||

**核心结论：**

- AB 在磨皮、祛痘能力上已有优势
- AB 在可控性与原图保留上优于竞品
- 竞品在祛红、祛色沉上也未形成绝对优势

说明：匀肤能力是 AirBrush 可以建立肤质护城河的重要机会点

秀秀效果展示（预计未来AB效果）
下方左图第二为最终效果展示，可以看到效果优于之前AB效果

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
预计回收数据时间：xx月xx日

| 提升指标 | 具体数值 ||
| 

1189
complete
用户指标

 | 

299
incomplete
预计可带来新增**万

300
complete
保存率提升3%

1215
complete
打勾率提升5%

301
incomplete
频次提升**%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
incomplete
不产生收入或者产生负向收入

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

## 五、需求描述
本次计划对 **AirBrush Skin 模块中的 Acne、Concealer 功能进行效果升级**，新增匀肤能力，用于增强面部泛红、色沉等块状肤色不均问题的处理效果，进一步提升肤质优化表现。
其中：

- **Acne**：在原有祛痘能力基础上，新增痘痘周边泛红抑制能力&mdash;&mdash;加入集团Fortuna能力
- **Concealer**：在原有遮瑕能力基础上，增强对色沉、泛红及块状瑕疵的优化能力&mdash;&mdash;加入集团Fortuna能力

本次调整仅涉及功能效果升级，不涉及功能入口、交互逻辑及功能位序调整。
设计师效果评估文档：[https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNcynsw3fWTuKfhOfj?scode=ACIAJAeGAAg4uof1jAAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNcynsw3fWTuKfhOfj?scode=ACIAJAeGAAg4uof1jAAdUAnwaPAHA)

## 六. AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 25%
 ||
| 实验组A | Acne加入匀肤效果 （备注：暂时只加入自动，不加手动）
 | 25% ||
| 实验组B
 | Concealer 加入匀肤效果 （备注：手动➕自动效果）
 | 25%

 ||
| 实验组C | Acne / Concealer 加入匀肤效果 （备注：Acne暂时只加入自动，不加手动） | 25% ||
| 实验触发时机
 | 用户进入Skin模块时触发，优先覆盖新用户观察冷启动表现
 | / ||
| 目标用户
 | 全用户（需分国家分新老用户看数据，国家分：美、巴、其他）
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量，若有明显负反馈则停止实验
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 ||
| **实验预期**
 | 实验组P0和P1数据或持平硬盘，P1数据无明显负向，后台无负反馈
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接
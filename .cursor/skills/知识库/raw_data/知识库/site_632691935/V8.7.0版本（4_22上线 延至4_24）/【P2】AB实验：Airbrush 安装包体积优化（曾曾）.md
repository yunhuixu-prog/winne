# 【P2】AB实验：Airbrush 安装包体积优化（曾曾）

**页面ID**: 671742130

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P2】AB实验：Airbrush 安装包体积优化（曾曾）

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
| **2025.03.03** | **曾曾** | **创建文档**
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
**行业现状**
**在 2018 年 Google I/O 上，Google 公布了 Google Play 平台安装包体积与下载转化率之间的关系：**
**随着 APK 体积增加，应用安装转化率呈明显下降趋势。****官方数据显示：**

- 每增加 6MB 安装包大小，安装转化率平均下降 1%～3%；

- 在（印度、巴西）等市场影响更为明显；

- 当安装包过大时，应用市场可能提示「需要 WiFi 下载」，进一步增加流失风险。

**从行业数据来看，安装包体积已经不仅是技术指标，而是直接影响增长效率的核心因素。**

| **2018 年 Google Play 上安装包体积与下载转化率关系**
 | **每增加 6MB 安装包大小，安装转化率平均下降 1%～3%**
 | **APK文件大小减少在印度和巴西的影响较大** ||
| ****
 | ****
 | ****
 ||
| [https://medium.com/googleplaydev/shrinking-apks-growing-installs-5d3fcba23ce2](https://medium.com/googleplaydev/shrinking-apks-growing-installs-5d3fcba23ce2) ||

**AB现状**
目前 AB 所有 AI 模型均内置在安装包内，随着功能扩展，模型数量持续增加，带来以下问题：

- **包体体积持续膨胀，影响安装转化率：**多模型同时内置，导致安装包体积显著增加，影响下载转化率与更新意愿，尤其在低网速或存储空间有限的设备上更为明显。
- **包体过大占用用户内存空间而导致卸载：**通过用户留存数据分析可以发现，用户会为了腾空间而卸载

竞品情况
**竞品中（IOS）:** Face App:123.7MB > Face Tun 464.6MB > Hypic: 449.9mb > Air brush :610.4mb
AB体积显著大于其他竞品

在功能持续扩张模型持续增加的背景下，现有"全量内置"模式已成为结构性负担，或也成为用户下载的阻碍因素，及卸载的原因之一，需进行包体瘦身，以提升安装转化。

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
**目标：**每减少 6MB 安装包大小，提升1-3%的安装转化率，降低1-3%的卸载率（根据Google官方数据预估）
**可能存在的影响：**

- Wi-Fi/5G情况下下载模型时间增加0.5-1s
- 4G情况下下载模型时间增加0.5-2s
- 弱网情况下下载模型时间增加1-5s

间接影响「升级版本用户」功能进入使用转化，对旧版本存量用户无影响。

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
[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=680773802](Android 模型内置改云端下载-优先级与落地表)：[https://cf.meitu.com/confluence/x/qsiTK](https://cf.meitu.com/confluence/x/qsiTK)
本次主要针对占用内存大+非用户最高频功能**「Relight」「Bokeh」「Background」「Blur」**进行模型接入智枢优化，先进行AB实验，验证是否会对用户打勾/保存/留存/使用造成影响，正向收益后，继续扩展至其他功能

| 原型图 | 功能详情说明 ||
| 
 | 核心高频功能的非AI功能**内置本地**，保证离线可用

- **功能list：**Reshape、Resize、Smooth、Magic、Acne、Face、Skin、Skin Tone、Body、 Dark Circles 、**Relight、Teeth、Makeup、Hair、Filters**
- **交互流程：**内置模型，用户无需下载/联网即可使用

Wi-Fi/流量**自动预下载**，下载后本地缓冲（素材、AI类、非高频）

- **功能list：**Presets、Plumping、Adjust、Eraser、Crop、Stretch、Effects、Bokeh、Stamp、Blur、Prism、background、Tattoo、Glitter、Text
- **交互流程**

- 除内置功能外，连接Wi-Fi/流量打开APP后，按照以上优先级排序依次下载功能模型（本次实验先做Relight、Bokeh、Blur、Background）
- 触发手动下载交互（自动下载未完成时）：
- 用户首次点击该功能，当前页面触发加载loading页
- 标题：Loading resources...
- 文案：This process only requires one time.该过程仅需一次"

- 并增加「转圈动画」
- 下载完成后进入该功能界面

AI类，**强制联网使用**

- **功能list：**AI retouch、Muscle、AI image、AI replace、Glow up、Face fix、Expression
- **交互流程**
- **正常有网络情况：**进入后联网使用（follow线上逻辑）
- **无网络情况：**功能不置灰，可进入功能，但不可使用**，**点击后提示"Internet connection required for first-time use.首次使用需要连接互联网"

 ||

## 六、AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 20%
 ||
| 实验组A | 「Relight」「Blur」「Bokeh」「Background」增加下载交互版本，加载时长1s
 | 20% ||
| 实验组B | 「Relight」「Blur」「Bokeh」「Background」增加下载交互版本，加载时长1s | 20% ||
| 实验触发时机
 | 升级后首次进入「Relight」「Blur」「Bokeh」「Background」
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
 | P0:功能整体的留存率
P1:打勾/保存/订阅
 ||
| **实验预期**
 | 实验组任意P0数据至少持平对照组，P1数据无明显负向，后台无负反馈
 ||

## 七、翻译
翻译文档link

## 八、埋点需求

- 分地区的用户下载模型的时长
- 下载模型的成功率
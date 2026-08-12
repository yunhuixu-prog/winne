# 【P2】AB实验：Glow Up 模块子功能排序调整（帅王）

**页面ID**: 705516123

**路径**: V8.15.0版本（8_19上线）/【P2】AB实验：Glow Up 模块子功能排序调整（帅王）

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

更改记录：

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
Glow Up 近几个月收入呈下滑趋势，子功能的排序位置直接决定其曝光与进入量，推测现有排序与实际功能用户价值存在错配。
当前线上排序：
Flawless（免费） | Matte（免费） | Shimmer（付费） | Sun-kissed（付费） | Soft Glow（付费） | Natural Tan（付费） | Tan Line（付费） | Body Glow（付费）**
目前第2、3位的 **Matte / Shimmer 曝光较高，但使用承接偏弱**；反而排序靠后的 **Natural Tan / Soft Glow / Body Glow** 在打勾、保存、人均使用或订阅表现上更好。

- **Flawless** 保持第一，继续承担免费体验入口，保障 Glow Up 使用和 MAU。
- **Natural Tan、Soft Glow、Body Glow** 使用、保存及商业化综合表现较好，**前移放大高价值效果曝光**。
- **Sun-kissed** 基础使用偏弱，但订阅成功表现突出，继续保留前排商业化位置。
- **Tan Line** 与 Sun-kissed 同属 Tan 类效果，调整至其后，**保证效果浏览和体验连续性**。
- **Shimmer、Matte** 当前曝光较高但综合承接偏弱，因此后移释放前排曝光。

**预期收益：**在不明显影响 MAU 的情况下，提升 Glow Up 整体打勾、保存及订阅转化.
**综上本次希望**：
在保证免费体验和 MAU 以及同时兼顾用户效果体验连续性的前提下，把前排曝光更多分配给高使用、高订阅价值效果，提升 Glow Up 整体使用效率和订阅转化。**

 glow up五月到七月整体呈收入下滑趋势
**为什么这样调整：**

| 功能 | 免费/付费 | 当前&rarr;调整后 | 核心数据 | 为什么调 | 预期作用 ||
| **Flawless** | 免费 | 1 &rarr; **1** | 保存45.87%；人均进入2.08；人均保存2.46 | 免费效果中使用、保存表现最好，适合作为首个体验效果 | **继续承担免费入口，保障 MAU** ||
| **Natural Tan**
**（前移）**
 | 付费 | 6 &rarr; **2** | 打勾**62.09%**最高；保存44.56%；耗时6.3s最低；订阅收入10,932最高 | 使用效率和商业价值双高，但当前曝光不足 | **提升使用 + 订阅转化** ||
| **Soft Glow（前移）** | 付费 | 5 &rarr; **3** | 打勾**53.55%**；保存40.63%；订阅成功1,238；收入10,821 | 使用和商业化表现都较强，适合核心前排 | **稳定提升使用及订阅规模** ||
| **Body Glow**
**（前移）**
 | 付费 | 8 &rarr; **4** | 打勾**49.93%**；保存36.26%；人均进入2.02；人均保存2.49最高 | 排第8仍有较强使用深度，真实需求较强但受排序压制 | **放大真实使用需求，同时带动订阅** ||
| **Sun-kissed**
**（后移）**
 | 付费 | 4 &rarr; **5** | 打勾20.5%；保存14.19%；订阅排第四，有放大潜力 | 基础使用偏弱，但商业化价值明确，同时作为 Tan 类效果承接后续浏览 | **保留前排订阅承接能力** ||
| **Tan Line****（前移）**
 | 付费 | 7 &rarr; **6** | 打勾27.88%；保存18.28%；人均保存2.00 | 与 Sun-kissed 同属 Tan 类效果，视觉和效果体验更连续，放在一起更符合用户浏览心智 | **提升同类效果浏览连续性，减少效果跳跃感** ||
| **Shimmer（后移）** | 付费 | 3 &rarr; **7** | 打勾20.5%；保存13.1%；订阅成功率15.4% | 当前第3曝光较高，但实际使用及付费承接偏弱；同时从效果体验上与前面的 Tan 类连续性较弱 | **释放前排曝光，保留一定商业化观察** ||
| **Matte（后移）** | 免费 | 2 &rarr; **8** | 打勾26.12%；保存20.30%；耗时43.6s最高 | 虽免费但整体使用效率偏低，且已有 Flawless 承担免费入口 | **释放第2位高价值曝光** ||

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
预计回收数据时间：9月5日

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
incomplete
曝光提升8%

1215
incomplete
打勾率提升3%

301
incomplete
频次提升**%

 ||
| 

280
complete
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
complete
收入正向，预计模块整体订阅提高3%

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

五、需求描述
调整 Glow Up 模块子功能的展示顺序：

| 位置 | 调整前（线上） | 调整后（实验组 B） ||
| **1** | Flawless | Flawless ||
| **2** | Matte | **Natural Tan &uarr;（原第6位）** ||
| **3** | Shimmer | **Soft Glow &uarr;（原第5位）** ||
| **4** | Sun-kissed | **Body Glow &uarr;（原第8位）** ||
| **5** | Soft Glow | Sun-kissed &darr;（原第4位） ||
| **6** | Natural Tan | Tan Line &uarr;（原第7位） ||
| **7** | Tan Line | Shimmer &darr;（原第3位） ||
| **8** | Body Glow | Matte &darr;（原第2位） ||

**当前顺序**
Flawless | Matte | Shimmer | Sun-kissed | Soft Glow | Natural Tan | Tan Line | Body Glow
**调整后顺序（实验组）**
Flawless | Natural Tan | Soft Glow | Body Glow | Sun-kissed | Tan Line | Shimmer | Matte

| 原型图 | 功能详情说明 ||
| 
 | 如左图所示，本次调整仅涉及glow up 模块内效果栏的排列顺序，不涉及任何功能本身的交互或宽度队列。

- **调整前**：Flawless | Matte | Shimmer | Sun-kissed | Soft Glow | Natural Tan | Tan Line | Body Glow

- **调整后**：Flawless | Natural Tan | Soft Glow | Body Glow | Sun-kissed | Tan Line | Shimmer | Matte

 ||

*** ***

## 六. AB实验

| **组别 **
 | **内容**
 | **流量**
 ||
| 对照组
 | 目前线上版本 | 33.3%
 ||
| 对照组 | 目前线上版本
 | 33.3% ||
| 实验组B | Flawless | Natural Tan | Soft Glow | Body Glow | Sun-kissed | Tan Line | Shimmer | Matte | 33.3% ||
| 实验触发时机
 | 用户进入app触发，优先覆盖新用户观察冷启动表现
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
 | 整体渗透率无负向，整体订阅有所提升
 ||

### 七、协议跳转

### 八.AB code

### 九.AB结论

### 十.埋点需求

### 十一.翻译需求

### 十二.UI
Figma链接
# 【P1】效果新增：Airbrush Skin新增Redness Fix（曾曾）

**页面ID**: 702258990

**路径**: V8.13.0版本（7_22上线）🚩/【P1】效果新增：Airbrush Skin新增Redness Fix（曾曾）

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
complete
素材

 | 

1208
complete
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
| 2026.6.10 | 曾曾 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

## **看自己**：Skin 模块是 Retouch 流量基本盘（进入打勾率 75%+），但 2026 年 Enter to Save 同比下滑 1-2%，Smooth、Skin Tone 等核心功能保存率下降，说明skin效果与用户预期已出现落差。
看用户/看竞品**：用户（70% 为 30-45 岁）对 "快速美肤" 诉求强烈，竞品（FaceAPP/Facetune）迭代一键 AI 美化，而 AB 当前缺少一键高效入口，且AB当前的算法效果暂未解决匀肤（色沉 / 泛红）核心痛点。
**看数据：**

- **子功能表现**：**Smooth/Acne/Skin Tone 为 "三高" 核心功能（Enter to Save 75%+），Dark Circles 有留存潜力，Wrinkle 是订阅收入 TOP1；Concealer/Brighten 进入量高但打勾率中等。
- **交互与一键化**：**当前操作需 6-15 步（点击 + Auto / 手动调试），即时性差；Magic 一键套组命中率 54%，虽低于手动，但能看出用户对 "快速出效果" 诉求明确。
- **能力缺口**：**匀肤（色沉 / 泛红）为未满足需求，深肤色（Black）气色类功能转化低（Wrinkle 66.8%，Acne 73.7%），竞品祛红 / 色沉也未彻底解决；集团已有匀肤技术储备。
- **族裔差异**：**Latin（50.9%）关注黑眼圈 / 色沉，White（27.6%）侧重抗老，Black（9.2%）需解决色沉，Asian（6.5%）关注肤色 / 眼周提亮。

**肤质模块数据和洞察：**[https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNSgnUTAlGSY0yfCX9?scode=ACIAJAeGAAggYma9GfAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_ARIAJQaaAGoCNSgnUTAlGSY0yfCX9?scode=ACIAJAeGAAggYma9GfAdUAnwaPAHA)
**Retouch模块数据和洞察：**[https://cf.meitu.com/confluence/x/EDLPKQ](https://cf.meitu.com/confluence/x/EDLPKQ)
**综合以上背景，计划针对AB skin能力进行优化升级：**
**1）效果上：**解决多族裔色沉/瑕疵祛除不干净/泛红问题，

- 接入「秀秀-祛斑祛痘-无暇模式」解决瑕疵不干净问题，并去黑眼圈、去皱能力，整合成一键式皮肤解决方案
- 接入匀肤，单独解决泛红问题

2）交互上：**针对用户快速出效果的诉求，新增用户友好的皮肤类一键式交互，将原本过多的交互步数压缩成一步，给到用户更快速切更好的skin效果体验。

| 原图 | AB（磨皮+祛痘+去黑眼圈）
 | 目标效果（无暇模式+去黑眼圈+去皱）
 ||
| 
 | 
 | 
 ||
| 
 | 
 | 
 ||
| 
 | 
 | 
 ||

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
匀肤接口：接入秀秀-皮肤美化-匀肤
算法对接人：林顺达
设计师：莫策、罗宇擎

| 原型图 | 需求描述 ||
| 
 | **入口：Retouch- Skin-Redness Fix**（第六位）**
**效果参数：**
[https://meitu.feishu.cn/wiki/EKtuwrWyei4QtVkHSlccqTKhnjf?from=from_copylink](https://meitu.feishu.cn/wiki/EKtuwrWyei4QtVkHSlccqTKhnjf?from=from_copylink)

**视觉：**

- 新增 **Redness** Fix **Icon
- Skin UI增加New角标，用户点击后消失
- Redness上方新增New角标，用户点击后消失

交互流程**

- 进入Skin，进入Redness Fix**，****进入三级页面，支持自动，手动，橡皮擦，默认手动（界面和交互方式follow smooth）

**固化逻辑**

- 打勾即固化

**多人脸/网络错误等其他逻辑**

- Follow skin线上

**其他-算法方案**

- 本地方案

**订阅方案**

- follow忻恬本地功能订阅逻辑：[https://cf.meitu.com/confluence/x/kLvbKQ](https://cf.meitu.com/confluence/x/kLvbKQ)

- 非订阅用户：
- 美英澳：终身限免**10**次
- 其他国家：终身限免**20**次
- 超过次数订阅横幅+打勾拦截

 ||

## 五、订阅相关

## 六、协议跳转
新功能，需要新的DL链接🔗：
七、翻译

## 八、埋点需求
**Redness Fix****的曝光/点击/打勾/保存/订阅的UV/PV埋点
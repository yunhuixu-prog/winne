# 【P1】功能新增：Airbrush Body新增 Upper Arms（丁丁）

**页面ID**: 710786320

**路径**: V8.16.0版本（9_2上线）🚩/【P1】功能新增：Airbrush Body新增 Upper Arms（丁丁）

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
| 2026.8.4 | 丁丁 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
**1. Body模块前6的数据：**
最终只保存了 12,710 人，超过一半的用户打勾后放弃了。对比 Waist 的 93.3%，Arm 进入UV排名第4，用量大、需求真实，但打勾&rarr;保存转化率仅 48.2%&mdash;&mdash;前6中低。说明用户能发现这个功能、也愿意试，但效果不够精准（整条手臂一起调），导致大量用户打勾后放弃保存。拆分「瘦大臂」提供更精细的调整能力，是低成本撬动转化率提升的最直接手段。

| 排名 | 功能 | 点击UV | 打勾UV | 保存UV | 打勾&rarr;保存 ||
| 1 | Slim | 92,489 | 49,715 | 29,358 | 58.8% ||
| 2 | Waist | 53,793 | 12,371 | 11,543 | **93.3%** ||
| 3 | Auto | 25,454 | 11,154 | 4,927 | 44.2% ||
| **4** | **Arm** | 24,475 | 26,351 | 12,710 | **48.2%** ||
| 5 | Breast | 23,758 | 9,602 | 4,437 | 46.2% ||
| 6 | Hips | 22,067 | 24,079 | 12,502 | 51.9% ||

2. **有成功的细分先例：Neck &rarr; Neck Width / Neck Length**
Neck 进入UV 3,630，Neck Width + Neck Length 合计进入 10,013，是 Neck 的 2.8 倍。细分后不仅使用量翻倍，转化率也更高。Arm 同样属于&quot;身体局部、用户有明确调整目标&quot;的功能，细分成「瘦大臂」「瘦小臂」完全符合已验证的模式。
**3. 用户场景明确且高频**
Bat Wings&quot;已是医美行业通用术语
美国整形外科学会（ASPS）官网有多篇专题文章直接使用 &quot;Bat Wings&quot; 来描述上臂皮肤松弛问题，和国内&quot;拜拜肉&quot;的叫法异曲同工&mdash;&mdash;说明这个痛点在海内外有高度一致的认知。YouTube / TikTok 上 &quot;flabby arms workout&quot;&quot;how to get rid of bat wings&quot; 类视频属于健身区的常青内容，各种频道反复产出，竞争激烈&mdash;&mdash;供给过剩本身就证明需求巨大。
4. 商业验证：竞品已有**
秀秀、美颜、醒图等竞品均已拆分大臂/小臂，说明这个细分方向已被市场验证。
效果文档：

| 原图 | 瘦手臂 | 瘦大臂 ||
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
complete
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
complete
人有我有（参考x产品）

267
complete
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
complete
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
瘦大臂接口：接入秀秀-身材塑形-瘦大臂
算法对接人：林顺达 
算法对接：李良耀
设计师：田梅琳

| 原型图 | 需求描述 ||
| 
 | **入口：Retouch- Body-Upper Arms（第六位）**
Shape-Auto-Slim-Waist-Arms-Upper Arms...
**视觉：**

- 新增 **Upper Arms**** **Icon
- Body UI增加New角标，用户点击后消失
- **Upper Arms**上方新增New角标，用户点击后消失

交互流程**

- 点击进入，进入**Upper Arms****，****进入三级页面，支持滑杆调节程度值，程度值-100-100。默认值具效果参数而定。

**固化逻辑**

- 打勾即固化

**背景保护**

- 支持背景保护

**多人脸逻辑**
功能置灰，点击后弹出Toast:Multi-person mode is not supported.
**无人脸逻辑，遵循线上**
**网络错误等其他逻辑。**

- Follow 线上

**其他-算法方案**

- 本地方案

**订阅策略：**

- follow忻恬本地功能订阅逻辑：

- 非订阅用户：
- 美英澳：终身限免**5**次
- 其他国家：终身限免**10**次
- 超过次数订阅横幅+打勾拦截

 ||

## 五、订阅相关

## 六、协议跳转
新功能，需要新的DL链接🔗：
七、翻译

## 八、埋点需求
**Upper Arms****的曝光/点击/打勾/保存/订阅的UV/PV埋点
# 【P2】体验优化：Airbrush 多语言展示UI视觉优化-一期（曾曾）

**页面ID**: 662839156

**路径**: V8.2.0版本（2_4上线）/【P2】体验优化：Airbrush 多语言展示UI视觉优化-一期（曾曾）

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
| 2025.1.19 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | ||

## 一、需求背景

- 当前 Airbrush 葡语/西班牙语主编辑器一级功能多语言展示，由于字数多等原因导致展示上存在较多问题，如视觉混乱，字号大小不一等问题，严重影响视觉观感，因此需进行优化。
- 

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
 | 

273
complete
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

## 二、功能目标

| 

1189
incomplete
用户指标

 | 

299
incomplete
保存率

 | 
 | 
 ||
| 

280
incomplete
收入指标（如有）

 | 

1141
complete
20万以上

1142
incomplete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 | 
 | 
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

| 原型图 | 需求描述 ||
| 
 | **总体原则**
保证 Icon + 文案在多语言、多长度场景下可读、不挤、保证UI视觉一致性
**核心策略**
1️⃣优先通过换行+断词解决
2️⃣其次通过字号缩放解决
2️⃣最后放不下则进行内容省略**（原则上尽量2行能够展示完整，实在无方案才考虑省略号**）
**具体规则**
1️⃣内容换行与断词规则

- 两个单词超过1行时：无需连接符，以空格作为断词链接
- 单个单词超过1行时：使用 - 作为连接符（如：Transforma-&ccedil;&atilde;o）
- 「中国、新加坡、马来西亚、日本、泰国、老挝、缅甸、柬埔寨、沙特阿拉伯、阿联酋、埃及、卡塔尔、摩洛哥、以色列、巴勒斯坦、印度、巴基斯坦、孟加拉国、蒙古国、尼泊尔语除外」

2️⃣行数限制规则

- 文本**最多支持 2 行展示**

- 超过 2 行时进入字号缩放逻辑，最小值10

3️⃣内容省略规则
当一下条件同时满足时，允许省略：

- 已达到最大 2 行

- 字号已缩小至最小值（10）仍展示不全

省略方式：

- 使用 ... 进行尾部省略
- 保留语义前缀，避免截断在无意义位置

**其他逻辑（不允许的情况）**

- ❌ 单字符孤立成行

- ❌ 不带连接符的生硬断词

- ❌ 同类 IconSet 中字号大小不一致

- ❌ 未执行完整适配流程直接省略内容

 ||

### 优化范围

| P0 本期优化 | P1 下期优化 ||
| **1️⃣AB内的一级和二级菜单栏（所有大分类的名字）**
**Edit**
**Retouch**
**2️⃣三级菜单栏（含菜单栏下的功能子项）**
**Retouch**

- Skin
- teeth

 | **1️⃣三级菜单栏（含菜单栏下的功能子项）**
**Edit**

- Adjust
- crop
- Eraser
- AI repair

**Retouch**

- Magic
- Face
- Reshape
- Body
- Muscle

**2️⃣My kit 主界面**
 ||

3、订阅限免策略
/

## 六、协议跳转
/

## 七、翻译
/

## 八、埋点需求
/
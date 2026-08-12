# 【P2】体验优化：Airbrush New角标/小红点展示逻辑优化（曾曾）

**页面ID**: 685219464

**路径**: V8.10.0版本（6_8上线）/【P2】体验优化：Airbrush New角标/小红点展示逻辑优化（曾曾）

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
incomplete
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
功能TAB中 NEW 角标/小红点 主要用于标识新上线功能或素材，引导用户关注与使用，是重要的曝光与引导手段，但当前存在以下问题：

- 当前Tab的New角标和红点仅支持一次性标记生效，生效条件为 "后台标记 + 用户未使用"。用户一旦点击 / 使用该素材，角标就会永久消失，无法二次触发。

导致不发版上线的新素材/内容，难以通过角标/红点获得新曝光，26 年整体目标聚焦用户增长与留存，需**进一步提升新内容的触达效率与曝光能力，放大优质内容的分发价值**。

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
incomplete
收入指标（如有）

 | 

1141
incomplete
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

| 原型图 | 功能详情说明 ||
| 
 | 该能力适用于不发版上新、运营二次推广、活动节点引流等场景。
重复上新与二次推广能力

- 支持后台对已有素材或功能 Tab 重复标记 NEW 角标 / 红点；
- 每次重新标记后，将重置角标曝光周期，且不受用户历史点击 / 使用行为影响；
- 周期设置：限时/不限时
- 限时：7天，15天，30天，自定义

### 其他

- 重复标记优先级**：同一功能的多次标记，以最新一次标记的配置为准，自动覆盖旧的曝光周期与展示规则；
- **New和小红点展示规则：**
- 新Tab增加：New角标
- 新效果增加：小红点

### **支持模块-一级/二级功能栏（黑后台）**

- **Face**
- head
- face
- jaw
- eyes
- nose
- mouth
- eyebrows

- **Retouch**
- Retouch
- Features

- **Relight**
- **Makeup**
- looks
- lipstick
- blush
- contouring
- freckles
- eyebrows
- eyelashes
- eyeliner
- eyeshadow
- eye color

- **Hair**
- hair styles
- color
- hair enrich

- **Filters**
- **Tattoo**
- **AI image**
- **Presets**
- **Effects**
- **backgrund**

### **------------------------------------------------------------------------------------------------------**

### **支持模块-三级素材管理栏（素材中台，标蓝色）**

- **Makeup**
- looks
- favorites、popular、natural、day、idol me、holiday、vibrant、night、classic

- **Hair**
- hair styles
- female、male、bangs、brard

- color
- natural、highlights、colorful

- hair enrich
- texture、volume

- **Filter**
- favorites、popular、basic、texture、sweet、camera、film、seasons、foodie、BW、retro、holiday、atmosphere、color、cosmic

- **AI image**
- trending、vibe、portrait、festival、anime

- **Presets**
- popular、glow、natural、smooth、stylized、aesthetic

素材中台配置字段：
后台新增一个角标字段，单选，选项有：无、新，红点，选择新或者红点时，再展示时间的配置
 ||

## 五、订阅相关
无

## 六、协议跳转
七、翻译

## 八、埋点需求
新增角标相关数据埋点，支持查看角标点击率
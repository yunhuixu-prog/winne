# 【P2】AB实验：Airbrush保分页Camera按钮调整为推荐位实验（小红）

**页面ID**: 679594277

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P2】AB实验：Airbrush保分页Camera按钮调整为推荐位实验（小红）

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

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026.03.26 | 小红 | 创建文档
 | 
 ||
| 2026.04.07 | 小红 | 修改文档 | 
 ||
| 2026.04.14 | 小红 | 修改文档 | 补充二级/一级功能详情 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
数据侧发现，

- 留存率&ge;50%的用户几乎都有reshape+另一种修饰功能：

- 近30天修图二级功能偏好top1：reshape、body、skin、adjust、makeup等

因此，为提高保分页效率，本次将做两件事：

- 对"保分页推荐逻辑"进行改造实验：调整原"camera"按钮为推荐位按钮，支持对照二级/一级功能配置保分页推荐banner和推荐按钮，实现精准推荐。
- 保存页UI样式更新：当前保存页面Edit more按钮、保分页banner "try now"按钮仍为旧主题色按钮，本次一并更新。

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
通过对应组合推荐，提升用户留存和保分页效率

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

## 四、需求描述
1、需求简述

| 
 | 
 ||
| 
 | **逻辑改造**

- 需要同时支持保分页的两个模块：
- 保分页banner
- 保分页功能按钮（新增，原camera按钮

- 支持所有二级功能可对应配置推荐，没有二级分类则支持一级分类。
- 推荐逻辑：按照用户使用的最后一个二级功能展示配置的推荐位banner/按钮，如无二级功能则对照一级功能，用户保存前，只要使用过对应的二级功能，则按配置展示对应保存页推荐位。
- 保分页显示逻辑：每个二级功能对应一组固定的banner和按钮 按照优先级依次展示，按顺序全部展示完毕后则从最高优再开始，循环。banner与按钮同理。
- more effect下面的推荐按钮、banner一定会有，兜底：
- 推荐按钮：filters兜底
- banner：兜底内容不变

 ||
| 
 | **UI改造**

- Edit more 按钮颜色调整
- banner "try now"按钮颜色调整
- AI image H5保存页面按钮颜色调整

 ||
| 
 | **服务端支持**

- 保分页banner、功能推荐按钮（新增）可对应二级功能配置
- 保分页按钮支持
- 文案配置：保分页Try now按钮文案配置（UI建议字符数）
- 开关配置：保分页banner是否显示按钮。
- 文案未配置、开关开启时，Try now作为兜底文案。

 ||

2、二级/一级功能
智能修图不参加保分也推荐实验/配置

| 功能层级 | 一级功能 | 二级功能 ||
| 功能名称 | Filters
hair
presets
effects
AI image
Background
Text
 | Adjust
Crop
Eraser
Relight
Al Repair V1
Al Expand
Blur V1
Bokeh
Blur
Al Repair
Al Expand V1
Al Replace
Al Expand V2
Stamp
Prism
Al Retouch
Magic
Face
Reshape V1
Makeup
Skin
Makeup V1
Plump
Glowup
Plump V1
Reshape
Resize
Stretch
Body
Al Tattoo
Muscle
Face Fix
Expression
Teeth
Glitter
 ||

3、实验组描述

| 修图场景 | 二级功能 | banner推荐（强） | 按钮推荐（弱） | banner推荐（可选） | 按钮推荐（可选） | 推荐参考 ||
| 人像结构精修 | Reshape | eraser

 | Relight

 | 任务型工具编辑：
relight
eraser
replace
expand
repair
 | 玩法尝试：
Hair

 | 
- 近30天修图二级功能偏好top1：reshape、body、skin、adjust、makeup等

 ||
| Face ||
| Body ||
| Muscle ||
| Stretch ||
| 自然轻修 | Skin | Body | relight

 ||
| Teeth ||
| Plump ||
| Makeup ||
| AI一键出片 | Magic | relight

 | Eraser

 | 玩法尝试：
hair

 | 人像结构精修：
Body
reshape
face
muscle
 ||
| AI Retouch ||
| Glow up ||
| Preset ||
| Expression ||
| 氛围出片 | Filters | skin-smooth

 | reshape

 | 人像结构精修：
Body
reshape
face
muscle

 | 自然轻修：
skin-smooth
teeth
makeup

 ||
| Relight ||
| Bokeh ||
| Prism ||
| Glitter ||
| Effect ||
| Adjust ||
| Crop ||
| Resize ||
| Blur ||
| 任务型工具编辑 | Eraser | reshape | makeup | 人像结构精修：
relight
Body
reshape
face
muscle

 | 自然轻修：
skin-smooth
teeth
makeup

 ||
| AI Replace ||
| expand ||
| Background ||
| AI Repair ||
| Stamp ||
| Face fix ||
| Text ||
| 玩法尝试 | hair | Body | reshape ||
| AI tattoo ||
| AI image ||

3、实验规划
针对 二级功能保分页推荐调整 做如下AAB实验：

- 对照组：维持线上不变。
- 实验组：

- **调整 保分页banner和按钮 推荐内容**
- 原订阅逻辑维持不变。

**AAB实验信息：**

| 实验触发时机 | **保存时** ||
| 对照 | 维持现有 保分页推荐逻辑和内容 ||
| 对照组AA | 维持现有 保分页推荐逻辑和内容
 ||
| 实验组B | 
- **调整 推荐逻辑**

 ||
| 实验观察指标 | P0: 点击率、推荐功能进入率、用户留存（需要分国家分新老用户看数据，国家分：美、英、巴、其他）
 ||
| 流量控制 | 全区，各33%流量 ||
| 测试周期 | 14天（看结果決定延长or全量） ||

## 五、协议跳转
保分页banner与按钮跳转逻辑与线上一致。

## 六、翻译
无

## 七、埋点需求
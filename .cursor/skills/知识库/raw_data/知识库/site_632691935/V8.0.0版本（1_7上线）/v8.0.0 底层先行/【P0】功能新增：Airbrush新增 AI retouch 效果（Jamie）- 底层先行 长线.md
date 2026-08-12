# 【P0】功能新增：Airbrush新增 AI retouch 效果（Jamie）- 底层先行 长线

**页面ID**: 649363164

**路径**: V8.0.0版本（1_7上线）/v8.0.0 底层先行/【P0】功能新增：Airbrush新增 AI retouch 效果（Jamie）- 底层先行 长线

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
 | 更改内容
 ||
| 2025.12.02 | 刘晓 | 创建文档 ||

#### 涉及业务

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
AI retouch 长期效果为更新，近期 tpm 研发完成匹配欧美审美风格两款。上线可给用户提供更好的效果体验
当前 AI retouch 内效数据量⬇️

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
incomplete
基础型：必备，缺失会引起不满

294
complete
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

| xxxx算法接口 | 
 ||
| demo地址 | 
 ||
| 算法对接人 | 
 ||
| 效果设计师 | ||

| 原型图 | 功能详情说明 ||
| 

 | AI retouch 新增 2项效果

- AI retouch 新增两项效果：chiselled（腮内缩）、glowy（光泽肌）
- AI retouch 效果位置顺序：clean、nature、smile、chiselled（腮内缩）、glowy（光泽肌）、sculpted、delicate、cute、model 
- 新增两项效果设置 new 角标（用户点击后，角标消失）
- 新增两款风格各配置一条滑杆，控制效果形变。（旧风格无滑杆）
- 新增效果与线上其他效果互斥

 ||

## 五、订阅相关

| 限免策略 | **新增两项效果 为收费功能**

- 走策略 1，非会员生命周期10次，会员每日30次（两个效果共享限免次数）
- 非会员限免使用后提示剩余次数，限免次数使用完后，不可再次请求效果。（请求效果展示兜底图）

 ||

## 六、协议跳转
有
七、翻译
中文：腮内缩、光泽肌
英文：chiselled、glowy

## 八、埋点需求
新增：chiselled、glowy 点击、使用、保存、滑杆埋点
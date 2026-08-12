# 【P1】体验优化：Airbrush Retouch 线上效果新增滑杆（Jamie）

**页面ID**: 685224134

**路径**: V8.8.0版本（5.7上线 ）/【P1】体验优化：Airbrush Retouch 线上效果新增滑杆（Jamie）

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

1215
incomplete
效果

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
| 2026.04.15 | Jamie | 创建文档 | 
 ||
| 2026.04.15 | Jamie | 补充本地实时渲染、duffle 开关粒度与关闭时行为；多人脸状态机改写并修正错别字「尚次&rarr;上次」；明确记忆作用域仅限本次编辑 session；每款效果默认滑杆值待填 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- Retouch 整个模块订阅转化率表现很好，但对于单款式的打勾率只有 35% 上下，对比retouch排序前列的功能约在 50%~80% 这个范围区间内，尚有很大的优化空间。
- 用户反馈中多次提到：期望在当前模块的效果内支持滑杆功能，让用户能够调整效果的强度，方便他们更好依照个人的需求来调整编辑。
- 新款效果（如glowy) 当前已经支持滑杆，但线上还有 7 款未支持。

竞品情况：

- Facetune 内的 AI Looks 功能，提供单款效果的滑杆，且能在画布内实时渲染后预览。
- Facetlab 内的 AI Beauty 功能，提供单款效果的滑杆，且也能在画布内进行实时的渲染后预览。

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
1、需求内容
AI Retouch 内的 7 款旧效果，支持滑杆滑动调整强弱

- 涉及效果：Clean、Natural、Cute、Smile、Sculpted、Delicate、Model

**【展示规则】**

- 滑杆出现时机：返回结果图后展示；若本次未成功请求到效果图，不展示滑杆
- 每款效果独立配置，只支持单滑杆（不拆分多参数）

**【默认值与开关（duffle 下发）】**

- 默认值：由 duffle 按效果独立下发，具体每款默认值见 [https://doc.weixin.qq.com/doc/w3_AUIAHwa6ABYCNiawamBiOTFmfxmtw?scode=ACIAJAeGAAgAtcfEYCARQA8QZwACQ](【效果评估】Retouch新增滑杆调试)

- 滑杆开关：duffle 支持 按效果 配置是否「开启」
- 开启：展示滑杆，用户可拖动调整
- 关闭：不展示滑杆，效果直接以 duffle 下发的默认强度渲染结果图

**【交互与渲染】**

- 拖动滑杆时，客户端本地实时渲染，画布内立即看到调整结果（不走云端二次请求，故无额外网络耗时）
- 松手后滑杆停留在当前位置，作为本次编辑的当前强度值

**【多人脸逻辑】**（本次编辑 session 内的状态机）

- 记忆作用域：仅本次 retouch 编辑内生效；退出 retouch 后清空，下次进入回到 duffle 默认值
- 人脸 A 首次应用效果 X &rarr; 使用 duffle 下发的默认滑杆值
- 人脸 A 已调整过，切换至人脸 B：
- 人脸 B 在本 session 内无该效果编辑记录 &rarr; 使用 duffle 默认值（不继承 A 的强度）
- 人脸 B 在本 session 内已有该效果编辑记录 &rarr; 恢复 B 上次调整的滑杆值

- 再切回人脸 A &rarr; 恢复 A 上次调整的滑杆值

2、涉及效果

| POC | 影响范围＆是否需要验收 ||
| 设计 | 
- Clean、Natural、Cute、Smile、Sculpted、Delicate、Model
- 需要验证滑杆强度调整时，是否有出现异常型变或是不自然过渡

 ||
| 产品 | 
- Clean、Natural、Cute、Smile、Sculpted、Delicate、Model

 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
新增打勾时的 **滑杆强度 **埋点
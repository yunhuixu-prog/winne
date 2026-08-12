# 【P1】AB实验：Airbrush  AI Repair 算法替换（Jamie）

**页面ID**: 652671252

**路径**: V8.2.0版本（2_4上线）/【P1】AB实验：Airbrush  AI Repair 算法替换（Jamie）

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
| 2025.11.10 | Jamie | 创建文档 | 
 ||
| 2025.12.24 | 富桂 | 补充文档 | 
 ||

## 一、需求背景
为什么要做:

- 编辑器内的 ai 修复的算法版本老旧，处理速度与竞品相差不大但生成效果有明显的落差，作为与编辑器内画质优化专项的并行项目，期望更新算法补足功能竞争力。
- 替换修复算法，提升交互体验与升级整体功能，来提升功能了渗透与转化率。
- 新增人像修复档位，在人像场景下支持效果更好的人像修复。
- 算法优化后耗时由原来的 12s 左右提升至 7s左右。
- 算法优化后多人种适配效果更自然，画质效果均有提升

| 原图 | 线上 | 优化版本
 ||
| 
 | 
 | 
 ||

市场情况：

- 过去半年用户中频反馈，注意到 app 内的修复效果与 web 版本有明显差距。

竞品情况：

- 主流竟品如 remini、picsart 均提供AI修复能力，且模型细节优于 AB 内线上版本。

| Remini | Picsart ||
| 
- 仅提供强度档位
- 使用的模型人像细节清楚

 | 
- 提供不同场景下的照片升级
- 背景模糊、背景提升、人像retouch、人像提升、颜色调整

 ||

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

| 算法接口 | /v2/image_restoration 
/v1/imagefacesr_async [https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](面部超清) ||
| demo地址 | 面部超清
[https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=835&type=preview)
 ||
| 算法对接人 | 陈进山 ||
| 效果设计师 | 孔宇琴 ||

#### 【需求概述】
1、算法替換

| AI repair 内子功能算法替換 ||
| 更新项：
 | 对应接口：
 | 参数： ||
| 
- Image Quality HD 超清

 | 
- /v2/image_restoration_async

 | &quot;parameter&quot;: {
 &quot;ir_mode&quot;: 4,
 &quot;use_hd_face_opt&quot;: 1
 } ||
| 
- Image Quality portrait 人像超清

 | 
- /v2/image_restoration_async + /v1/imagefacesr_async

 | &quot;parameter&quot;: {
 &quot;ir_mode&quot;: 4,
 }
加上面部超清 /v1/imagefacesr_async
 ||
| 
- Color Enhance 色彩增强

 | 
- /v3/bp/image_restoration_ai

 | 
- 解析度默認2K
- 去噪若選中，則傳參 medium
- 其餘邏輯照舊

 ||
| 
- Denoise 噪点消除

 | 
- /v2/image_restoration_async

 | &quot;parameter&quot;: {
 &quot;ir_mode&quot;: 4
 &quot;use_denoise&quot;: 0
 } ||
| 
- Colorize 着色

 | /v1/sdcolorization_async + /v2/image_restoration_async
 | &quot;parameter&quot;: {
 &quot;ir_mode&quot;: 4 }
 ||

用户场景与参数关系

| 序号 | Image Quality | 颜色增强 | 去噪 | 著色 | 调用算法(照顺序) | 画质修复参数 | 备注 ||
| 1 | ☑️ HD | 
 | ☑️ | ☑️ | 著色用旧算法/v1/sdcolorization_async＋
画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
&quot;use_denoise&quot;: 1
 | 黑白图 ||
| 2 | ☑️ HD | 
 | 
 | ☑️ | 著色用旧算法/v1/sdcolorization_async＋
画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
 | 黑白图 ||
| 3 | ☑️ Portrait | 
 | ☑️ | ☑️ | 著色用旧算法/v1/sdcolorization_async＋
画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4
&quot;use_denoise&quot;: 1
 | 黑白图 ||
| 4 | ☑️ Portrait | 
 | 
 | ☑️ | 著色用旧算法/v1/sdcolorization_async＋
画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4

 | 黑白图 ||
| 5 | ☑️ HD | ☑️ | ☑️ | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 黑白图 ||
| 6 | ☑️ HD | ☑️ | 
 | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
其他就照选中回传
 | 黑白图 ||
| 7 | ☑️ Portrait | ☑️ | ☑️ | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 黑白图 ||
| 8 | ☑️ Portrait | ☑️ | 
 | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
其他就照选中回传
 | 黑白图 ||
| 9 | 
 | ☑️ | ☑️ | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 黑白图 ||
| 10 | 
 | ☑️ | 
 | ☑️ | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
其他就照选中回传
 | 黑白图 ||
| 11 | 
 | 
 | ☑️ | ☑️ | 著色用旧算法/v1/sdcolorization_async
＋画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_denoise&quot;: 1
 | 黑白图 ||
| 12 | 
 | 
 | 
 | ☑️ | 著色用旧算法/v1/sdcolorization_async | 照选中回传 | 黑白图 ||
| 13 | ☑️ HD | 
 | ☑️ | - | 画质修复 /v2/image_restoration_async | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
&quot;use_denoise&quot;: 1
 | 
 ||
| 14 | ☑️ HD | 
 | 
 | - | 画质修复 /v2/image_restoration_async | &quot;ir_mode&quot;: 4
&quot;use_hd_face_opt&quot;: 1
 | 
 ||
| 15 | ☑️ Portrait | 
 | ☑️ | - | 画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4
&quot;use_denoise&quot;: 1
 | 
 ||
| 16 | ☑️ Portrait | 
 | 
 | - | 画质修复 /v2/image_restoration_async＋
面部超清/v1/imagefacesr_async
 | &quot;ir_mode&quot;: 4

 | 
 ||
| 17 | ☑️ HD | ☑️ | ☑️ | - | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 
 ||
| 18 | ☑️ HD | ☑️ | 
 | - | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
其他就照选中回传
 | 
 ||
| 19 | ☑️ Portrait | ☑️ | ☑️ | - | /v1/sdcolorization_async + /v3/image_restoration_async
 | 解析度：2k
去噪：medium
其他就照选中回传
 | 
 ||
| 20 | ☑️ Portrait | ☑️ | 
 | - | /v1/sdcolorization_async + /v3/image_restoration_async
 | 解析度：2k
其他就照选中回传
 | 
 ||
| 21 | 
 | ☑️ | ☑️ | - | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 
 ||
| 22 | 
 | ☑️ | 
 | - | /v1/sdcolorization_async + /v3/image_restoration_async | 解析度：2k
去噪：medium
其他就照选中回传
 | 
 ||
| 23 | 
 | 
 | ☑️ | - | 画质修复 /v2/image_restoration_async
 | &quot;ir_mode&quot;: 4
&quot;use_denoise&quot;: 0
 | 
 ||

2、需求內容

**Image Quality **

- 維持判斷邏輯：
- 若傳入圖為「無人圖」，只有 HD 一個檔位
- 若傳入含「人臉圖」，HD、Portrait 兩個檔位，選中 Portrait 檔

- HD 檔位：替換算法 /v2/image_restoration_async，傳參 &quot;ir_mode&quot;: 4,
 &quot;use_hd_face_opt&quot;: 1
- Portrait 檔位：替換算法 /v2/image_restoration_async + /v1/imagefacesr_async，傳參 &quot;ir_mode&quot;: 4

**分辨率**

- 移除圖標

**顏色增強**

- 若選中顏色增強，都強制使用原算法 /v3/image_restoration_async
- 解析度默認2K
- 去噪若選中，則傳參 medium
- 其餘邏輯照舊

**去噪**

- 強度調整為一個檔位
- 替換算法 /v2/image_restoration，傳參 &quot;ir_mode&quot;: 4, &quot;use_denoise&quot;: 0
- 單選去噪的情況下，/v2/image_restoration，傳參 &quot;ir_mode&quot;: 4, &quot;use_denoise&quot;: 0

**著色**

- 原工作流中替換增強算法為 /v2/image_restoration_async
- 顺序：
- 新算法（hd）：著色+超清
- 新算法（portrait）：著色+超清＋面部超清

**--对照实验都上--**
**Apply按钮样式调整**

- 调整成新的圆角样式，由UI定义

**Tips样式调整**

- 调整成新的去色样式，由UI定义

**Image Quality **

- 維持判斷邏輯：
- 若傳入圖為「無人圖」，只有 HD 一個檔位
- 若傳入含「人臉圖」，HD、Portrait 兩個檔位，選中 Portrait 檔

3、AB 实验
针对 AI Repair 算法替换 做如下AAB实验：

- 对照组：维持AI Repair 交互与算法不变。
- 实验组：

- **调整 AI Repair UI交互**
- 替换成画质修复v3与面部超清算法
- 原订阅逻辑维持不变。

| 组别 | 对照组A | 对照组aa | 实验组b ||
| 内容 | 目前线上版本 | 目前线上版本 | 本次需求方案 ||
| 流量 | 33% | 33% | 33% ||
| 实验周期 | 2 周 ||
| 对比数据 | 
- 模块的打勾率、订阅情况对比
- 更新 5 项子功能的 打勾率、订阅情况对比

 ||

## 六、协议跳转
无

## 七、翻译
无

## 八、埋点需求
全部子项的 点击、打勾、保存、取消
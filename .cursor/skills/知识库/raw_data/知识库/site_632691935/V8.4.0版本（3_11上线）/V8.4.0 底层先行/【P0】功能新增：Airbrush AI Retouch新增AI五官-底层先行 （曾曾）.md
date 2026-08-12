# 【P0】功能新增：Airbrush AI Retouch新增AI五官-底层先行 （曾曾）

**页面ID**: 670683364

**路径**: V8.4.0版本（3_11上线）/V8.4.0 底层先行/【P0】功能新增：Airbrush AI Retouch新增AI五官-底层先行 （曾曾）

---

#### 需求JIRA地址：
**接入素材中台Jira地址：**

| 模块
 | 

1202
complete
翻译需求

 | 

1203
incomplete
隐私整改

 | 

1204
complete
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
| 2025.12.24 | 曾曾 | 创建文档 | 
 ||
| 2025.2.1 | 曾曾 | 修改入口和功能逻辑 | 
 ||
| 2025.2.2 | 曾曾 | 修改多人脸底层逻辑 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景

#### **背景说明**
AI 五官特征是聚焦面部五官的 TPM 效果需求，由 AB/秀秀/美颜共研，支持眉毛、眼睛、鼻子、嘴唇等多部位的款式定制。考虑到算法模块的交付进度存在差异，该需求将分两期推进落地。
1️⃣期V8.1版本上线：欧美唇、小肉唇、丘比特唇、厌世眼、狐系眼、盒鼻、直鼻、小翘鼻
2️⃣期（待定）：野生眉、挑眉

**竞品分析**
竞品的面部微调主要聚焦在填充/提拉等年轻化功能上，五官功能则聚焦在眉毛/丰唇/下巴等。

- FaceApp*7：cheekbones➡️面颊凹陷+颧弓提拉、cupid&rsquo;s bow➡️眉弓提拉、dimples➡️酒窝、sharp chin➡️下巴整形+脸宽、long eyelashes➡️长睫毛、thick eyebrows➡️浓眉、thin eyebrows➡️细眉

- Facetune*5：refined➡️面颊凹陷+颧弓提拉、nose➡️缩小鼻子、lips➡️丰唇、eyes➡️眼部提拉、brows

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
incomplete
人有我有（参考x产品）

267
complete
人有我优（参考x产品）

268
complete
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
incomplete
基础型：必备，缺失会引起不满

294
incomplete
期望型：做越多，用户越满意

295
complete
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
1、算法相关

| 算法接口 | **实验室对接人**

- 眼睛/鼻子/眉毛：@周林鹏
- 唇部：@何恕预

**眼睛**

- 狐系眼： [https://insight-mtlab.meitu-int.com/doc/917](https://insight-mtlab.meitu-int.com/doc/917)
- 厌世眼：[https://insight-mtlab.meitu-int.com/doc/917](https://insight-mtlab.meitu-int.com/doc/917)

**鼻子**

- 直鼻/小翘鼻[https://insight-mtlab.meitu-int.com/doc/941](https://insight-mtlab.meitu-int.com/doc/941)
- 盒鼻：验收/接口准备中

**眉毛**

- 无眉/细眉：[https://insight-mtlab.meitu-int.com/doc/905](https://insight-mtlab.meitu-int.com/doc/905)
- 挑眉/野生眉：修图中

**唇形（采购）**

- 厚唇/小肉唇：[https://insight-mtlab.meitu-int.com/doc/950](https://insight-mtlab.meitu-int.com/doc/950)
- 丘比特唇：接口准备中

 ||
| demo地址 | **眼睛：** [https://insight-mtlab.meitu-int.com/viewer?id=1492](https://insight-mtlab.meitu-int.com/viewer?id=1492)**
**
**鼻子：**[https://insight-mtlab.meitu-int.com/viewer?id=1535](https://insight-mtlab.meitu-int.com/viewer?id=1535)
**眉毛：**[https://insight-mtlab.meitu-int.com/viewer?id=1469](https://insight-mtlab.meitu-int.com/viewer?id=1469)
**唇形：**[https://insight-mtlab.meitu-int.com/viewer?id=1556](https://insight-mtlab.meitu-int.com/viewer?id=1556)
 ||
| AB底层算法对接人 | ||
| 效果设计师 | ||

2、需求描述

| 原型图 | 功能详情说明 ||
| 一期-已交付「欧美唇、小肉唇、丘比特唇、盒鼻、直鼻、小翘鼻、厌世眼、狐系眼**」**
 ||
| 
 | 
- ****入口：Retouch-F****eatures**

- **Lips（3款）：**
- **欧美唇-Thick lips**
- **小肉唇-Chubby lips**
- **丘比特唇-Cupid's lip**

- **Eeybrows（3款，2期）**
- **野生眉-Wild brows**
- **挑眉-Arched brows**
- **无眉-No brows**

- **Nose（3款）：**
- **盒鼻-Boxy nose**
- **直鼻-Straight nose**
- **小翘鼻-Upturned nose**

- **Eyes（2款）：**

- **狐系眼-Fox eyes**
- **厌世眼-Cold eyes**

- **视觉呈现**
- 模特图样式,3:4
- 功能排序为
- lips
- eyebrows（二期）
- nose
- eye

- **交互流程**
- 首次进入：
- 进入Retouch，默认Tab 在Retouch
- Feature Tab首次展示小红点，点击后消失

- 选择效果与加载：

- 选择AI五官效果并触发loading流程（动画同AI Retouch）
- 用户取消则停留在当前页面，选中上一个效果
- 若用户是首次进入且无 "上一个效果"，则保持原始无选中状态

- loading结束后返回结果图，并显示滑杆
- 默认80%效果，0%=无效果(**待设计师确定默认值**)，对比按钮置灰

- **切换效果**
- **切换「同一分类」效果**（如 眼睛 - 厌世眼 &rarr; 眼睛 - 狐系眼）
- 同类型下不同效果为**替换**关系
- 不同效果的程度值独立记忆：再次切换回某一效果时，自动应用该效果上次使用时的程度值，而非默认值。

- **切换 不同分类 效果**（如 眼睛 - 狗狗眼&rarr; 鼻子 - 盒鼻）

- 不同类型下的效果为**叠加**关系
- 切换效果固化规则
- 未应用新效果，效果不固化，程度保持缓存参数
- 应用新效果后，效果固化，原效果取消选中态

- **切换「不同模块」效果**（如Ai Retouch &rarr; Features）
- 未应用新效果，效果不固化，程度保持缓存参数
- 应用新效果后，效果固化，原效果取消选中态

- **切换为「无」**
- 点击后针对「当前人脸」清除所有效果回到原图，收起档位滑杆
- 支持 undo；一旦在 undo 中途点 none，redo 栈会被清空

- **程度调节**
- 根据后台控制是否有滑杆（效果支持则有滑杆），滑杆默认程度
- 调节输入图与结果图融合，实时生效
- 强度调整为临时状态，切换效果或固化时会保存当前强度值，但该操作不计入 Undo/Redo 次数。

- **Undoredo**
- 使用任何效果后undoredo按钮高亮
- undo/redo可支持返回和前进各10次，达到次数限制则按钮置灰
- 切换tab 使用再点击undo时， 需要依次回到上个/上上个固化的结果-->回到原图

- undo/redo仅支持撤回每一步生成的效果，调整强度值不计入undo/redo次数
- undo 回退时只用户后一次调整停留在的强度值，再撤回则是上一步的结果图

- undoredo时的UI状态：
a. 当前 UI 是 undo 对应的效果
- 画面和UI一致，滑杆显示历史该历史节点的强度
b：当前 UI 不是 undo 对应的效果
- UI 不跳转，当前效果项取消选中态，用户点开对应效果，可以基于当前结果图继续编辑
- 多人脸场景下：
- undo / redo 仅回退画面对应的历史生成结果，不主动切换当前选中人脸。
- 若 undo 后画面对应的人脸与当前选中人脸不一致：
- 人脸选中态保持不变
- 效果列表不选中任何效果
- 用户需手动选择人脸及效果后继续编辑

- **对比按钮**
- 按下对比按钮后，始终是「当前效果」vs「原图效果」

- **多人脸逻辑**
- 至多支持5人脸（同AI Retouch 原逻辑）
- 进入界面默认选中面积最大人脸，多人脸icon高亮，用户可手动替换人脸（同AI Retouch 原逻辑）
- **效果生成规则**

- **同一tab下切换人脸：**从 A 人脸切换为 B 人脸并选择效果时，需重新跑服务端生成效果，但不固化 A 人脸当前效果，仍可以调整上个人脸的效果和参数
- **不同tab下切换人脸：**

- 切换人脸但不生成效果，切换回原tab仍可以调整上一个人脸的最后一次生成结果
- 切换人脸并生成效果，会固化上个tab下的结果

- 若切换 tab / 模式并生成效果导致效果固化，再次点击效果时，基于固化后的结果图重新上传生成

- 同一人脸在同一 tab 下切换效果时，已生成过的效果再次点击直接复用，无需重新跑服务端
- 所有多人脸效果需要能支持undo回原图

 ||

3、订阅方案
成本：0.0016$(0.01元)单张
走策略2：[https://cf.meitu.com/confluence/x/oli4Iw](https://cf.meitu.com/confluence/x/oli4Iw)
保留当前线上逻辑（会员才能打勾/保存），非会员可无限次数预览，同时预埋每天限免请求N次（覆盖98%用户的当天次数）
👉控制AI成本，避开极端用户（刷效果的）
Retouch 和 Features 的次数共用

## 六、协议跳转
新功能，所有新效果入口均在AI retouch中，需要研发创建新的的deeplink，点击deeplink即跳转至该效果并立即生效

## 七、翻译

| 中/英文 ||
| 
- 欧美唇-Thick lips
- 小肉唇-Chubby lips
- 丘比特唇-Cupid's lip
- 盒鼻-Boxy nose
- 直鼻-Straight nose
- 小翘鼻-Upturned nose
- 野生眉-Wild brows
- 挑眉-Arched brows
- 无眉-No brows
- 厌世眼-Bored eyes
- 狐系眼-Fox eyes

 ||

## 八、埋点需求

| 
- 欧美唇-Thick lips
- 小肉唇-Chubby lips
- 丘比特唇-Cupid's lip
- 盒鼻-Boxy nose
- 直鼻-Straight nose
- 小翘鼻-Upturned nose
- 野生眉-Wild brows
- 挑眉-Arched brows
- 无眉-No brows
- 厌世眼-Bored eyes
- 狐系眼-Fox eyes

 | 该Tab和效果的曝光/点击/程度值/保存/订阅转化埋点
（仅记录最后打勾时候保存的程度值）
 ||

## 九、素材中台配置
素材类型名称：AI Features
素材池

- 名称
- 缩略图
- 素材包

运营池
素材​

- 商品ID
- 素材缩略图（可配置动态和静态）
- 素材名称
- 素材的效果强度数值和交互
- 滑杆：0-100（默认50）
- 档位：0-3档（默认2）

- 所属分类
- 关联效果

- 自定义效果​

- 商品状态：启用 ○ 禁用​
- 环境：○ 预览 ○正式​
- 投放对象：​○ 图片编辑器 ○ 视频编辑器 ​
- 多平台：

☑ IOS ☑ Android ​

- 投放区域：○全部 ○ 启用 ○ 禁用​（需要国家列表+区域分类）
- 生效时间：​
- 付费类型：○ 否 ○ 是（付费效果打开时需默认配置角标）​
- 列表精选：○ 否 ○ 是​
- HOT 角标：○ 否 ○ 是​
- NEW 角标：○ 否 ○ 是 
- 人脸限制：○ 单人脸 ○ 双人脸 ○ 三人脸○ 四人脸○ 五人脸（默认）○ 八人脸 ○ 十人脸 ○ 无限制【需要客户端同步配置】
- 外露展示：○ 否 ○ 是​
- 下载方式：☑ 点击下载 ☑ Wi-Fi 自动下载 ☑ 自动下载​
- 是否展示：○ 是 ○ 否​
- 应用内置：○ 否 ○ 是​
- 发布版本：版本号
- 版本限制​：iOS / Android
- abcode配置（可选，默认空）：
- iOS：abcode，replace_m_id：&quot;素材id&quot;
- Android：abcode，replace_m_id：&quot;素材id&quot;

素材分类

- 分类名称
- 缩略图

- 商品状态：启用 ○ 禁用​
- 环境：○ 预览 ○正式​
- 投放对象：​○ 图片编辑器 ○ 视频编辑器 ​
- 多平台：

☑ IOS ☑ Android ​

- 投放区域：○全部 ○ 启用 ○ 禁用​（需要国家列表+区域分类）
- 生效时间：​
- 付费类型：○ 否 ○ 是（付费效果打开时需默认配置角标）​
- 列表精选：○ 否 ○ 是​
- HOT 角标：○ 否 ○ 是​
- NEW 角标：○ 否 ○ 是 
- 版本限制​：iOS / Android
- abcode配置（可选，默认空）：
- iOS：abcode，replace_m_id：&quot;素材id&quot;
- Android：abcode，replace_m_id：&quot;素材id&quot;
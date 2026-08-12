# 【P0】功能新增：Airbrush Body 新增 S Line 功能（Jamie）- 长线

**页面ID**: 666088535

**路径**: V8.3.0版本（2_26上线）/【P0】功能新增：Airbrush Body 新增 S Line 功能（Jamie）- 长线

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
| 2026.01.13 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- S Curve 在欧美文化里面，是长期存在的「性感、健康的曲线模版」，属于年轻女性刻意追求的身材风格。明确的身体流线与曲线起伏，年轻的女生用户甚至会特别练习摆 pose，来方便他们在照片中呈现这种感觉。

- 从社群、网路搜寻的状况来看，与S Curve的关键词长期在欧美持续存在：
- 美国：hourglass body、body curve、waist to hip ratio
- 巴西：corpo curvilineo, cintura marcada
- 且受众用户多以年轻女性为主，整体来看，这是一个覆盖面比想象中更广、但以 25&ndash;35 为核心的功能

- 功能效果
- 具体功能验收状况，可参考：
- 实验室效果：
- 集中实现上臀曲线，类似BBL的效果。
- 单、双人场景稳定
- 多人容易出现效果过度两极的状况

| 原图 | 效果图 | Hypic 效果图 | PrettyUp 效果图 ||
| 
 | 
 | 
 | ||
| 
 | 
 | 
 | 
 ||
| ****
 | 
 | 
 ||

竞品状况：

| Hypic | PrettyUp ||
| 
- 支持单人

- 有滑杆
- 底层算法实现

 | 
- 全身复合效果
- 双滑杆
- 云端效果

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
1、如涉及算法，注明算法相关信息

| xxxx算法接口 | /ai_figure_scurve_async
[https://insight-mtlab.meitu-int.com/document/editor?id=985&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=985&type=preview)

平均时长：20s (需另部属到海外pix集群，部属时提优化速度，期望是13s内)
成本：$0.03 rmb
 ||
| demo地址 | [https://insight-mtlab.meitu-int.com/document/editor?id=985&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=985&type=preview) ||
| 算法对接人 | 何恕预 ||
| 效果设计师 | Momo ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| 
 | **只需要实现在body功能新增实验组**

**Waist交互调整**

- Retouch - Body - Waist 调整为三级菜单
- 原 Waist 为单功能

- Waist 内子功能含：Waist (瘦腰)、Hourglass(沙漏腰)

**Body - Waist 新增功能**

- Retouch - Body - Waist 内新增 AI 功能 Hourglass
- Hourglass 展示 new 角标，点击后消失
- Hourglass 无滑杆，点击图标后投递
- 点击图标Hourglass时：
- 若有瘦腰效果，画布内还是展示瘦腰结果图（处理态的进度蒙层），直到返回结果图才覆盖
- 若弹起限免弹窗，图标选中hourglass：
- 取消、购买会员：都回退到前一个选中的图标（同线上逻辑）

**进入 Body - Waist 菜单交互**

- 用户进入 Waist 后默认选中 Waist，滑杆值为 0 (位置置中)
- 功能顺序为：无效果（none）、瘦腰（Waist）、沙漏腰（Hourglass）
- 功能的头 3 次进入，展示 tooltips。
- tooltips消隐条件：点击其他图标组件、离开功能即消隐

 ||
| 
 | **Waist ****菜单**

- 子项效果独立逻辑
- Waist 菜单 2 个子功能，效果相互独立。均在原图上生效效果（原图为进入 Waist 模块时的图片效果）
- 用户在 Waist 模块内的操作及滑杆/档位/效果 均记忆，退出 Waist 模块后不再记忆
- 子功能【瘦腰】需记忆用户滑杆操作及背景保护操作，用户使用后切换至其他子功能，再选中【瘦腰】，需显示用户在【瘦腰】内的最后一步操作
- 子功能【沙漏腰】若有返回结果图、涂抹需记忆（如果效果已请求，无需再次请求），用户使用后切换至其他子功能，在选中【沙漏腰】，需显示用户在【沙漏腰】内的最后一步操作

- 效果固化逻辑
- 【Waist】模块设计固化逻辑，瘦腰模块与【body】内的其他功能不可联调
- 用户从原图/其他功能 进入瘦腰，需对上一步操作进行固化（即上一步的操作为【瘦腰】模块的原图，）

- 用户进入【瘦腰】模块的功能后，需单独使用 ✅/❌ 来进行保存 or 放弃操作。
- **等同于丰胸模块逻辑**
- 用户打✅，保存瘦腰内的操作，并退出瘦腰功能，且返回 body 界面，不选中任何功能。 body 内的其他功能参数清空。
- 用户打❌，放弃瘦腰内的操作，并退出瘦腰功能，且返回 body 界面，不选中任何功能。 body 内的其他功能参数保留

- 背景保护
- 「瘦腰」内有「背景保护」
- 「瘦腰」与背景保护可同时使用
- 「沙漏腰」内无「背景保护」

**Hourglass 请求交互**

- 点击图标后即投递
- 首次使用需弹出云弹窗
- 投递loading采用loading组件四
- 返回结果图后

- 对比按钮高亮

**效果清除**

- body 内全部子功能设计重置按钮，点击重置，可清除当前功能参数恢复至 0（与线上逻辑一致）
- 点击 body 内的重置，不影响瘦腰内的效果
- 【瘦腰】菜单内设计清除按钮，瘦腰模块内，点击清重置即清除所有瘦腰效果（不包括背景保护），但需记忆【瘦腰】、【背景保护】的效果，用户再次重复相同操作 无需再次请求

**自动塑形与瘦腰**

- 用户点击塑形的自动选项，内置的瘦腰效果为瘦腰效果（与线上方案一致）
- 选用自动后，生效瘦腰效果，但瘦腰不展示小橙点

**通用逻辑**

- 用户退出 【Waist】菜单前，记录所有子功能的操作效果、档位效果，无需反复请求
- 云服务弹窗与线上逻辑一致
- 请求反馈与线上逻辑一致（无网络、无人体、请求失败）
- 【Waist】内无redo undo 

 ||

3、如涉及订阅限免策略调整，与订阅同学讨论后由订阅同学补充对应内容--订阅产品填写

| 限免策略 | **新增【沙漏腰】为收费功能，单独限免次数**

- 走策略一，非会员生命周期 3 次，会员每日 50 次
- 非会员限免使用后提示剩余次数，限免次数使用完后，不可再次请求效果。（请求效果展示兜底图）
- 可保存；无「分享 解锁效果」配置

 ||

## 六、协议跳转
新增 Body - Waist - Waist 
新增 Body - Waist - Hourglass 

## 七、翻译

| EN | CHS ||
| Hourglass | 沙漏腰 ||
| Get a Curvier S-Curve | 一键拥有 S 曲线 ||
| Takes 30s seconds,/n but worth it. | 花费30s秒等待，/n但相当值得
 ||

## 八、埋点需求
hourglass 的成本埋点
body - waist 点击
body - waist - waist 点击、使用、滑杆值、保存、取消
body - waist - hourglass 点击、使用、保存、取消
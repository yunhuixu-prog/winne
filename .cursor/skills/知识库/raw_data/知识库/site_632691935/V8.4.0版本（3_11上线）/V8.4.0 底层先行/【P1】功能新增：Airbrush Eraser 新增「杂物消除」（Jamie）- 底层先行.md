# 【P1】功能新增：Airbrush Eraser 新增「杂物消除」（Jamie）- 底层先行

**页面ID**: 669668573

**路径**: V8.4.0版本（3_11上线）/V8.4.0 底层先行/【P1】功能新增：Airbrush Eraser 新增「杂物消除」（Jamie）- 底层先行

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
| 2026.02.10 | Jamie | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 消除能力作為用量 top 的 AI 功能，有觀察到針對路人消除等剛需場景，使用量大且打勾率高。作為高訂閱的核心功能，需要持續完善拓展場景，有利於提昇收入和加深品牌心智。
- 观察歐美用戶在社媒上對於镜子脏污去除的需求場景具體且需求量级大，社群上也存在較多請求他人幫忙消除鏡子髒污的修圖請求，甚至願意為此支付$5-$10美金的小費。所以上新去鏡子脏污的一键消除能力，符合市场需求也有利于进一步拓展AB在消除的場景覆蓋。
- 同時間，也觀察到歐美用戶對於照片內雜物處理的動手能力極弱，社群上大多為付費處理的請求帖，因此雜物類型的消除場景，也值得一試，也有利於 AB 进一步新增智能消除應用場景，探索更多可能。
- 且當前已有集團算法支持，只需接入而無需額外開發，可作為 2026 年探索項目，先行接入後驗證有無明確的市場需求。

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
incomplete
基础优化

266
incomplete
人有我有（参考x产品）

267
incomplete
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

| 算法接口 | 杂物分割
/v1/img_sundries_seg_async

成本（待补充)：
 *需同步海外
/v1/img_mirror_dirt_rm_async
成本（待补充)：
 ||
| demo地址 | 镜面脏污：[https://insight-mtlab.meitu-int.com/document/editor?id=1002&type=preview](https://insight-mtlab.meitu-int.com/document/editor?id=1002&type=preview)
杂物消除：[https://insight-mtlab.meitu-int.com/viewer?id=1444](https://insight-mtlab.meitu-int.com/viewer?id=1444)
 ||
| 算法对接人 | 镜面脏污：张玏
杂物消除： 唐有赟
 ||
| 效果设计师 | 孔
 ||

2、需求需包含以下内容，具体格式不限制，只要规整易读即可

| 原型图 | 功能详情说明 ||
| **Edit - Eraser **

 | **Edit - Eraser 新增功能**

- Eraser 内新增 AI 功能：Objects

- Objects 展示 new 角标，点击后消失
- Objects 則需先請求**雜物分割算法**，返回選區，點擊應用後投遞**消除任務**

**进入 Edit - Eraser 交互**

- 用户进入 **Eraser** 后默认选中 **AI Eraser**，滑杆值为 50 (位置置中)
- 功能顺序为：AI Eraser、Spot Remover、Passerby、Mirror Stains、Objects

- 功能圖標bar：展示4.5個圖標，可左右滑動，滑到至最左或最右需實現力學反彈
- Objects 功能的头 3 次进入，展示 tooltips。
- tooltips消隐条件：点击其他图标组件、离开功能即消隐

- 若有结果图，切换不同图标时，以结果图继续编辑
- 此时点击撤销，画布内回到上一步，但选中图标维持在当前选中图标

 ||
| 

 | **Object 功能组件**

- 对比按钮
- 撤销重做
- 笔刷
- 橡皮擦
- （笔刷、橡皮擦任一高亮选中时）滑杆
- （有选区存在画布中）Remove按钮
- （首次使用）展示tooltips

**Object 功能交互**

- 点击图标后，请求**雜物分割算法**，返回選區。
- 投递 loading 采用 loading 组件二
- 选区呈现蚂蚁线＋打叉
- 笔刷、橡皮擦点击后高亮
- 展示滑柑，默认50，需记得在本次进入时的强度设置，下次进入功能时恢复默认

- 此时打勾隐藏，展示 remove 按钮
- 点击 remove 后即投递消除任务
- 首次使用需弹出云弹窗
- 投递 loading 采用 loading组件三
- 返回结果图后

- 对比按钮高亮
- 撤销按钮高亮
- Object 图标依然选中高亮
- 展示打勾

**通用逻辑**

- 云服务弹窗与线上逻辑一致
- loading组件与线上一致
- 请求反馈与线上逻辑一致（无网络、安审、请求失败）

 ||

3、如涉及订阅限免策略调整，与订阅同学讨论后由订阅同学补充对应内容--订阅产品填写

| 限免策略 | **新增【Mirror Stains、Objects】为收费功能，整个消除模块共用限免次数**

- 走策略二，非会员生命周期 xx 次，会员每日 xx 次
- 非会员限免使用后提示剩余次数，限免次数使用完后，不可再次请求效果。（请求效果展示兜底图）
- 不可保存；无「分享 解锁效果」配置

 ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议)
Eraser - Objects

## 七、翻译

| EN | CHS ||
| Objects | 杂物 ||
| 
 | 
 ||

## 八、埋点需求
除了常规埋点，注意确认成本相关埋点是否有
# 【P1】功能新增：Airbrush Face Head新增「畸变还原」功能（思思）-底层先行

**页面ID**: 709003618

**路径**: V8.14.0版本（8_5上线）🚩/V8.14.0底层先行/【P1】功能新增：Airbrush Face Head新增「畸变还原」功能（思思）-底层先行

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
| 2026.07.15 | 徐娟 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
人像修图场景中，自拍场景图的比例超过60%，其中自拍90%来自手机前置摄像头自拍：
主流智能手机前置摄像头的等效焦段，通常在 **22mm&ndash;28mm**之间，属于典型广角范围。
相比更接近人眼自然视角的** 50mm 标准焦段**，这类广角镜头在近距离拍摄时更容易产生明显的透视畸变和边缘畸变。
用户痛点
在实际自拍距离亚洲（手持约 30&ndash;50cm）欧州、北美、南美、非州、（手持约 30&ndash;70cm）
**镜头边缘极易产生畸变，**画面边缘区域易产生几何拉宽，导致脸部变形拉伸扭曲
多人场景畸变更显性，边缘人脸身体被严重拉宽

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
complete
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
incomplete
中频

275
complete
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
complete
不产生口碑传播

288
incomplete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
预计回收数据时间：8月19日

| 提升指标 | 具体数值 ||
| 

1189
incomplete
用户指标

 | 

299
incomplete
预计可带来新增**万

300
incomplete
留存提升**%

1215
incomplete
打勾率提升**%

301
complete
频次提升3%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
incomplete
不产生收入或者产生负向收入

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

| 接口对接人 | 卢运西（Yunxi Lu） | [https://insight-mtlab.meitu-int.com/doc/1815#%E8%AF%B7%E6%B1%82%E5%8F%82%E6%95%B0](https://insight-mtlab.meitu-int.com/doc/1815#%E8%AF%B7%E6%B1%82%E5%8F%82%E6%95%B0) ||
| 算法文档 | 
 | 
 ||
| 成本 | 0.010830元 | 
 ||
| 耗时信息 | ＜7.5s | 
 ||
| 算法对接人 | 林顺达（Shunda Lin） | 
 ||
| 设计师 | 孔宇琴（Kyra Kong）（Kyra） | 
 ||
| 畸变效果图栈
 | 卢运西（Yunxi Lu） | [https://insight-mtlab.meitu-int.com/diff?id=32865&page=1&page_size=10](https://insight-mtlab.meitu-int.com/diff?id=32865&page=1&page_size=10) ||

| 原型图 | 功能详细说明 ||
| 

 | 功能入口/功能排序：

- edit-crop-（vrop、rotate、prrspective、expand、Undistort）（第五位）

默认程度值

- Undistort：默认100

交互流程：
用户点击Undistort 模块选择Undistort 功能

- 小窗"加载中&hellip;xx%"显示进度（参考扩图）
- 加载完成后：对比按钮高亮，Undistort 按钮高亮
- 打钩打叉:用户可以选择&radic;，对Undistort效果进行确认，或者选择打x对Undistort 效果进行舍弃

固化逻辑：固化

- 选择剪裁/旋转/透视/扩图功能打勾后&rarr;进入Undistort：选用剪裁/旋转/透视/扩图功能打勾后图片作为Undistort输入图，
- 选择Undistort功能打勾后&rarr;剪裁/旋转/透视/扩图功能：选择Undistort打钩后效果作为输入图
- 如需撤销Undistort打钩后效果，需回到一级页面点击

新功能指引：

- 首次进入edit-crop模块edit、crop增加小红点 **&middot; **用户点击后消失
- Undistort有New角标
- 名称前需要加星（Undistort ）

其他：

- 人脸单选：不支持，
- 固化逻辑：打钩后固化，

互斥叠加逻辑：Undistort与其他功能固化叠加，
功能撤销：参考扩图功能
付费横幅：同线上
订阅策略**

- 非会员生命周期限免3次
- 会员每日限免50次
- 超过次数订阅横幅+打勾拦截：Toast：今日次数已用完 明天再来
No-vip: 3 times/ life circle
Vip: 50 times / day

 ||

### 五.协议跳转

### 六.AB code

### 七.AB结论

### 八.埋点需求
新增 Undistort 的pv/uv，曝光/点击/打勾/保存/订阅转化

### 九.翻译需求
Undistort的多语言翻译

### 十.TPM信息

| 能力类型 | 

22
complete
业务自研

 | 

26
incomplete
外采转自研

 | 

23
incomplete
接入

 | 

25
incomplete
外采

 ||
| Airbrush【面部畸变还原】TPM立项申请
[https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNoUhItPzPTpWEEvJq?scode=ACIAJAeGAAgwx0sFqgAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNoUhItPzPTpWEEvJq?scode=ACIAJAeGAAgwx0sFqgAdUAnwaPAHA)**
** | 
 ||
| 业务侧的功能入口 | 
 ||
| **从哪个业务接入（接入的需填写）** | 秀秀/wink/AB共研 ||

### 十一.UI
新增：Undistort功能ui和交互
Figma链接：
# 【P2】体验优化：Airbrush 弹窗组件优化（Jamie）

**页面ID**: 640792465

**路径**: V8.5.0版本（3_25上线）/【P2】体验优化：Airbrush 弹窗组件优化（Jamie）

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
| 2026.02.09 | Jamie | 创建文档 | 
 ||
| 2026.03.12 | Jamie | 新增编辑器内弹窗 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 产品功能目前现状：
- 目前 app 内整体设计样式老旧，色彩与现在 logo 主色有差异，同时间仍采用 2020 主流的 CTA 设计风格，与现今主流设计样式相比相对过时。当代设计多以半透明、去色、柔和圆角、按鈕扁平化来处理。

- 除此之外，针对文字的排列规则在多文本仍以置中处理，相对来说不易阅读。

- 新功能的 UI 组件目前多以新组件样式风格设计，与原有弹窗的设计语言有差异，全局统一性上体验比较差，当前存在新旧组件皆有的交互场景，风格整体调性有些许突兀。不利于形塑整体品牌。

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
1、需求需包含以下内容，具体格式不限制，只要规整易读即可

**需求内容：**
全局 App 内弹窗样式进行统一调整与优化。需替换当前 App 内各业务场景中使用的弹窗样式，统一为新样式规范。

**样式如下：**

| 原型图 | 功能详情说明 ||
| 

 | **文字弹窗**

- 优化短文本、长文本的两种排列规则

**短文本**

- **Icon**
- optional

- **标题**
- 置中对齐
- 最大行数 2 行

- **内文**
- 置中对齐
- 最大行数 2 行
- 如有配置内文，不可出现内文比标题短少的状况
- 如有配置内文，内文行数需 ≧ 标题行数

- **按钮**
- 支持 左右排列、上下排列
- 主按钮需强调主色

- **取消（右上角）**
- optional

- **图片**
- optional
- **支持多比例配置**

**长文本**

- **Icon**
- optional

- **标题**
- 置 **左 **对齐

- 内文
- 置 **左 **对齐
- 最小行数 3 行。

- 按钮
- 支持 左右排列、上下排列
- 主按钮需强调主色

- **取消（右上角）**
- optional
- 支持3:4, 1:1 等图片比例

 ||

**涉及功能范围：**
**iOS **

| 名字 ***灰底为首次打开app触发 | 触发条件 | 截图 | 备注 ||
| IDFA
 | iOS14.5以上系统
在设置页里开启了允许请求跟踪
首次安装打开app时触发
 | 
 | 无需调整 ||
| 权益变更提示弹窗
 | 
 | 
 | **需调整** ||
| 清缓存弹窗
 | 
 | 
 | **需调整** ||
| 相册权限弹窗
 | 首次安装打开app
 | 
 | 无需调整 ||
| 补偿方案弹窗1（登错账号类型）
 | **登错账号弹窗：**
**type:1 or 3**
**process:1**
(备注：弹窗触发条件依赖服务端接口返回结果，不区分是否首次打开APP)
 | 
 | **需调整** ||
| 补偿方案弹窗2（重复购买类型）
 | **重复购买弹窗：**
**type:2**
**process:1**
(备注：弹窗触发条件依赖服务端接口返回结果，不区分是否首次打开APP)
 | 
 | **需调整** ||
| TOS&PP 协议更新弹窗
 | 更新 pp & tos | 
 | **需调整** ||
| 新手弹窗
 | 
- 登陆测试账号为新用户
- 冷启动打开app
- 设置将手机时间调后几天后再次冷启动打开app

 | 
 | **需调整** ||
| 继续修图弹窗
 | 
- 图片编辑器使用了效果未保存图片
- 关闭app再次冷启动打开app

 | 
 | **需调整** ||
| 流失用户popup弹窗
 | 取消指定月订/年订时，在过期倒计时5分钟内重启app时触发[https://pixocial.feishu.cn/wiki/LyHFwT0jhitbEikjCHscf85SnBb](付费流失用户挽回策略)
 | 
 | 无需调整 ||
| Promotional offer弹窗
 | 
- 活动后台（airbrush 老后台）开启promotional offer的活动（测试环境Activity ID：111，Activity类型：promotional offer）

 目前仅针对订阅过以下sku的用户做召回：
com.magicv.AirBrush.sub.allAccess.1year.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.newus.fullPrice
com.magicv.AirBrush.sub.allAccess.1year.newus.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.newgeo10.fullPrice
com.magicv.AirBrush.sub.allAccess.1year.newgeo10.fullPrice

- 准备一个沙盒账号登陆在设备上，最后一笔订单是以上sku中的其中一个，已过期且不是通过订阅promotional offer生成的。
- 重启客户端等待弹出promotional offer弹窗：

关于弹出的周期：假设当前距离上一个周四是x天，
正式环境：收到promotional offer后，下次收到push的时间是【21-x】天之后，在此期间点击push/重启客户端可拉取到promotional offer。
测试环境：首次收到promotional offer后，TTL显示下次触发promotional offer的时间是【16-x】分钟之后，在此期间点击push/重启客户端可拉取到promotional offer。
备注：TTL就是距离下次promotional offer触发的倒计时。TTL清空时，可触发一次promotional offer，触发后TTL重新开始倒计时，直到TTL倒计时归0然后置空，才可再次触发promotional offer。添加测试设备到后台后，可查看到TTL，点击确认可以将TTL清空.
 | 
 | 无需调整 ||
| 俄罗斯用户广告解锁弹窗
 | 
- VPN 选择俄罗斯地区
- 满足firebase配置条件
- 冷启动打开app

 | 
 | **需调整** ||
| 新功能弹窗 | 
 | 
 | 无需调整 ||
| 旧功能弹窗 | 表情修复；
AI增肌；
图章；
增高塑形 | 
 | **需调整** ||
| AI 错误弹窗
 | 
 | 
 | **需调整** ||
| 云授权弹窗
 | 首次提交AI任务
 | 
 | **需调整** ||
| 网络异常弹窗
 | 提交AI任务时断网
 | 
 | **需调整** ||
| 肌肤内功能，无人脸弹窗
 | 1. 使用无人脸图片进入肌肤内的功能
 2. 点击自动按钮
 | 
 | **需调整** ||
| 魔法背景主体识别弹窗（仅Android）
 | 1. 进入魔法背景，点击添加人像
 2. 选择无人脸图片
 | | **需调整** ||
| 魔法背景人像区域识别
 | 1. 进入魔法背景，点击编辑选区
 2. 使用橡皮擦擦除所有区域后打钩
 | | **需调整** ||
| 仿制图章涂抹区域提示弹窗
 | 1. 进入仿制图章
 2. 涂抹区域后用橡皮擦擦除全部区域
 3. 点击下一步
 | | **需调整** ||
| 调整功能内闪光灯/去炫光/自动冲突提示弹窗
 | 1. 进入调整，使用自动
 2. 使用闪光灯或者去炫光
 | 
 | **需调整** ||
| 删除人像分身
 | 1. 进入Protrait页面
 2. 进入人像管理页
 3. 删除人像
 | 
 | **需调整** ||
| 删除MagicStudio任务
 | 1. 进入magicstudio任务管理页
 2. 进入批量编辑
 3. 删除任务
 | 
 | **需调整** ||
| 个性化数据开关关闭提示
 | 1. 进入设置页
 2. 进入个性化数据
 3. 关闭个性化广告体验等选项
 | 
 | **需调整** ||
| 联系客服退出页面
 | 1. 进入设置页
 2. 进入个性化数据
 3. 进入更多选项
 4. 点击联系我们
 5. 退出联系我们页面
 | 
 | **需调整** ||
| 移除广告提示弹窗
 | 1. 进入设置页
 2. 点击移除广告
 | 
 | **需调整** ||

**Android**

| 名字 ***灰底为首次打开app触发 | 触发条件 | 截图 | 备注 ||
| 相册权限弹窗
 | 首次安装打开app
 | 
 | 无需调整 ||
| 补偿方案弹窗1（登错账号类型）
 | **登错账号弹窗：**
**type:1 or 3**
**process:1**
(备注：弹窗触发条件依赖服务端接口返回结果，不区分是否首次打开APP)
 | 
 | **需调整** ||
| 补偿方案弹窗2（重复购买类型）
 | **重复购买弹窗：**
**type:2**
**process:1**
(备注：弹窗触发条件依赖服务端接口返回结果，不区分是否首次打开APP)
 | 
 | **需调整** ||
| 新手弹窗
 | 
- 登陆的Google账号必须为从未订阅过任何SKU的新账号

（meitutest59@[http://gmail.com](gmail.com))

- 首次安装前将系统时间设置为前几天启动app
- 将系统时间调回正常时间启动app

 | 
 | **需调整** ||
| 继续修图弹窗
 | 
- 图片编辑器使用了效果未保存图片
- 关闭app再次冷启动打开app

 | 
 | **需调整** ||
| 流失用户popup弹窗
 | 
- 活动后台（airbrush 老后台）开启promotional offer的活动（测试环境Activity ID：111，Activity类型：promotional offer）

 目前仅针对订阅过以下sku的用户做召回：
com.magicv.AirBrush.sub.allAccess.1year.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.newus.fullPrice
com.magicv.AirBrush.sub.allAccess.1year.newus.fullPrice
com.magicv.AirBrush.sub.allAccess.1month.newgeo10.fullPrice
com.magicv.AirBrush.sub.allAccess.1year.newgeo10.fullPrice

- 准备一个沙盒账号登陆在设备上，最后一笔订单是以上sku中的其中一个，已过期且不是通过订阅promotional offer生成的。
- 重启客户端等待弹出promotional offer弹窗：

关于弹出的周期：假设当前距离上一个周四是x天，
正式环境：收到promotional offer后，下次收到push的时间是【21-x】天之后，在此期间点击push/重启客户端可拉取到promotional offer。
测试环境：首次收到promotional offer后，TTL显示下次触发promotional offer的时间是【16-x】分钟之后，在此期间点击push/重启客户端可拉取到promotional offer。
备注：TTL就是距离下次promotional offer触发的倒计时。TTL清空时，可触发一次promotional offer，触发后TTL重新开始倒计时，直到TTL倒计时归0然后置空，才可再次触发promotional offer。添加测试设备到后台后，可查看到TTL，点击确认可以将TTL清空.
 | 
 | 无需调整 ||
| 俄罗斯用户付费解锁弹窗
 | 
- VPN 选择俄罗斯地区
- 满足firebase配置条件
- 冷启动打开app

 | 
 | 无需调整 ||
| 新功能弹窗 | 
 | 
 | 无需调整 ||
| **旧功能弹窗** | **表情修复；**
**AI增肌；**
**图章；**
**增高塑形** | **** | **需调整** ||
| AI 错误弹窗 | 
 | 
 | **需调整** ||
| 云授权弹窗
 | 首次提交AI任务
 | 
 | **需调整** ||
| 网络异常弹窗
 | 提交AI任务时断网
 | 
 | **需调整** ||
| 肌肤内功能，无人脸弹窗
 | 1. 使用无人脸图片进入肌肤内的功能
2. 点击自动按钮
 | 
 | **需调整** ||
| 魔法背景主体识别弹窗（仅Android）
 | 1. 进入魔法背景，点击添加人像
2. 选择无人脸图片
 | 
 | **需调整** ||
| 魔法背景人像区域识别
 | 1. 进入魔法背景，点击编辑选区
2. 使用橡皮擦擦除所有区域后打钩
 | 
 | **需调整** ||
| 仿制图章涂抹区域提示弹窗
 | 1. 进入仿制图章
2. 涂抹区域后用橡皮擦擦除全部区域
3. 点击下一步
 | 
 | **需调整** ||
| 调整功能内闪光灯/去炫光/自动冲突提示弹窗
 | 1. 进入调整，使用自动
2. 使用闪光灯或者去炫光
 | 
 | **需调整** ||
| 删除人像分身
 | 1. 进入Protrait页面
2. 进入人像管理页
3. 删除人像
 | 
 | **需调整** ||
| 删除MagicStudio任务
 | 1. 进入magicstudio任务管理页
2. 进入批量编辑
3. 删除任务
 | 
 | **需调整** ||
| 个性化数据开关关闭提示
 | 1. 进入设置页
2. 进入个性化数据
3. 关闭个性化广告体验等选项
 | 
 | **需调整** ||
| 联系客服退出页面
 | 1. 进入设置页
2. 进入个性化数据
3. 进入更多选项
4. 点击联系我们
5. 退出联系我们页面
 | 
 | **需调整** ||
| 移除广告提示弹窗
 | 1. 进入设置页
2. 点击移除广告
 | 
 | **需调整** ||

## 六、协议跳转

## 七、翻译
翻译文档link

## 八、埋点需求
-
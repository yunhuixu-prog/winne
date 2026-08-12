# 【P1】功能新增：AB 接入账号体系支持俄罗斯支付（Zac）

**页面ID**: 701444266

**路径**: V8.12.0版本（7_8上线）🚩/【P1】功能新增：AB 接入账号体系支持俄罗斯支付（Zac）

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

#### 更改记录：

| 2026.6.8 | Zac | 创建文档 | 
 ||
| 2026.6.14 | Zac | 内审后更新 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 前端、iOS/Android、服务端、中台、测试 ||
| 涉及第三方业务/APP | 支付服务商、三方登录、邮箱登录 ||

## 一、需求背景

- 为什么要做：
- 目前 Airbrush 在俄罗斯市场约有 40W MAU，且俄罗斯用户对 Airbrush 的耐心和忠诚度较高。为扩大俄罗斯市场商业化价值，本期计划接入俄罗斯本地支付能力。

- 由于俄罗斯本地支付需要明确用户身份，用于订单归属、权益绑定、恢复购买和客服查询，因此俄罗斯支付链路需要依赖账号体系。但 Airbrush 当前没有完整账号体系，因此本期需要先接入基础账号能力。

**需求定性**

| 

255
incomplete
用户反馈/调研

256
complete
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
预计回收数据时间：2026年9月

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
incomplete
频次提升**%

 ||
| 

280
complete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
complete
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

### 全用户登录

### 俄罗斯用户支付

### 账号管理

原型图 Figma：[https://www.figma.com/design/AbEqw9ZrHJ36ttuiblXSkv/AB-%E4%BC%9A%E5%91%98%E4%BD%93%E7%B3%BB?node-id=0-1&t=tD8vd49B8yNYwdv4-1](https://www.figma.com/design/AbEqw9ZrHJ36ttuiblXSkv/AB-%E4%BC%9A%E5%91%98%E4%BD%93%E7%B3%BB?node-id=0-1&t=tD8vd49B8yNYwdv4-1)

## 五、需求描述

### 概述
本期接入基础账号体系，并接入 Airbrush 俄罗斯地区本地支付能力。由于俄罗斯本地支付需要明确用户身份，用于订单归属、权益绑定、恢复购买及客服查询，因此俄罗斯用户在发起支付前需要先完成登录。
本期不做全局强制登录。用户正常使用 Airbrush 的修图、导出、浏览等功能时，不需要登录；仅在以下两个场景触发登录：

- 俄罗斯用户点击 Subscribe 发起支付前；
- 用户在 Settings 内主动进入账号登录或账号管理。

**本期核心流程分为三部分：**

- 登录：支持邮箱登录和三方账号登录；
- 支付：俄罗斯用户点击 Subscribe 后，登录后跳转第三方支付网页完成支付；
- Account：用户可在账号页连接其他平台账号、退出登录、删除账号。

### **大账号接入指南：[https://robohub.meitu-int.com/docs/account/connection-guide#%E4%BA%8C%E7%94%B3%E8%AF%B7%E8%B4%A6%E5%8F%B7%E5%BA%94%E7%94%A8](https://robohub.meitu-int.com/docs/account/connection-guide#%E4%BA%8C%E7%94%B3%E8%AF%B7%E8%B4%A6%E5%8F%B7%E5%BA%94%E7%94%A8)**

### **登录**

| 图示 | 描述 ||
| 
 | **登录触发场景**
登录有两个入口：

| 触发场景 | 入口位置 | 说明 ||
| 支付前登录 | Paywall / Subscribe | 俄罗斯用户点击 Subscribe，若未登录，需要先登录再支付 ||
| 主动登录 | Settings / Log in | 用户在设置页主动点击 Log in，进入登录流程 ||

除以上两个场景外，不主动弹登录，不影响用户正常使用修图、导出等功能。
 ||
| 
 | **Login 页面**
**6/14更新：Login 页面样式固定，由中台配置，但业务可以进行客制化。**
Login 页面包含以下内容：

- Email 输入框；
- Continue 按钮；
- Continue 按钮默认置灰

- Or log in with；
- 三方登录按钮：
- Sign in with Apple
- Sign in with Google
- Sign in with VKontakte

- Privacy Policy / Terms of Service 勾选项。
- Privacy Policy 和 Terms of Service 默认不勾选。
- 本次需求导致用户条款需更新，Privacy Policy / Terms of Service 需覆盖账号登录、第三方登录、信息采集、邮箱 OTP、俄罗斯支付及账号删除相关说明。

 ||
| 
 | **Terms & Conditions 同意逻辑**

- 用户在登录前必须同意 Privacy Policy 和 Terms of Service。

**触发条件**

- 当用户未勾选 Privacy Policy / Terms of Service 时，点击以下任一登录入口：
- 邮箱 Continue；
- Sign in with Apple；
- Sign in with Google；
- Sign in with VKontakte。

此时弹出 Terms of Use and Privacy Policy 弹窗。
**弹窗内容**

- 标题：
- Terms of Use and Privacy Policy

- 正文：
- I have read and agreed to the Privacy Policy and Terms of Service.

按钮：

- Cancel
- Log in

**点击 Cancel**

- 关闭弹窗，停留在 Login 页面。
- 不进入邮箱登录，不跳转三方验证。

**点击 Log in**

- 系统自动勾选 Privacy Policy 和 Terms of Service，并继续用户刚才选择的登录方式。

例如：

- 用户刚才点击 Apple，则继续跳转 Apple 验证；
- 用户刚才点击 Google，则继续跳转 Google 验证；
- 用户刚才点击 VKontakte，则继续跳转 VK 验证；
- 用户刚才点击邮箱 Continue，则继续邮箱登录流程。

用户点击 Privacy Policy / Terms of Service 文本链接时，打开对应协议页面；返回后仍停留 Login 页面，不自动勾选。
 ||
| 
 | **三方账号登录**
本期三方登录支持（与研发确认是否可以分区，即全球苹果谷歌fb，俄罗斯VK苹果谷歌）：

- Apple；
- Google；
- Facebook；
- VKontakte。

**交互流程**
用户点击三方登录

- 判断是否已同意 Privacy Policy / Terms of Service
- 若未同意，先展示 Terms 弹窗
- 用户同意后，跳转对应三方账号验证
- 三方验证成功
- 三方首次登录：创建新的 account_id
- 三方已绑定 account_id：直接登录

- 账号中台返回 account_id
- 拉取三方账号返回的用户名称
- 自动完成登录
- 根据来源返回对应页面

**登录成功后的昵称规则**
三方账号登录成功后：

- 优先使用三方账号返回的用户名称；
- 如果三方账号未返回名称，则使用默认昵称 ABUxxxxxx。

**三方账号重复登录逻辑：**

- 若该三方账号已绑定某个 account_id，则直接登录该账号；
- 不创建新账号；
- 不重新生成默认昵称。

**三方授权异常：**
1. 用户取消授权：返回 Login 页面，不登录；
2. 三方授权失败：提示登录失败，可重试；
3. 三方授权成功但 account_id 获取失败：视为登录失败，不进入支付流程。
 ||
| 
 | **邮箱登录**
**交互流程**
用户输入邮箱

- 若邮箱栏为空，Continue 按钮置灰，不可点击
- 用户输入邮箱后，Continue 按钮变为可点击
- 点击 Continue
- 校验邮箱格式
- 判断是否已同意 Privacy Policy / Terms of Service
- 若未同意，先展示 Terms 弹窗
- 用户同意后，服务端检查该邮箱是否已有账号
- 根据账号状态进入不同流程

| 已注册 | 未注册 ||
| 如果该邮箱已有账号：
用户输入邮箱
1. 服务端判断为已有账号
2. 发送 6 位 OTP
3. 进入验证码页
4. 用户输入 OTP
5. 校验成功
6. 登录原账号
已有账号不需要人机验证
 | 如果该邮箱是初次登录：
用户输入邮箱

- 服务端判断为新账号
- 弹出人机验证（与用户中台确认是否需要验证）
- 用户完成人机验证
- 发送 6 位 OTP
- 进入验证码页
- 用户输入 OTP
- 校验成功
- 创建账号
- 生成默认昵称 ABUxxxxxx

 ||

说明：

- x 为随机数字；
- 生成后的昵称需要服务端固化；
- 人机验证未通过时，不发送 OTP，不创建账号。

 ||
| 
 | **邮箱登录异常情况**

| 场景 | 处理方式 ||
| 邮箱栏为空 | Continue 按钮置灰，不可点击，不展示错误提示 ||
| 用户输入后又清空邮箱 | Continue 按钮恢复置灰；若已有错误提示，清除错误提示 ||
| 邮箱格式无效 | 不展示 Terms 弹窗，不请求服务端；输入框下方提示 "Invalid email format." ||
| 邮箱前后有空格 | 前端提交前自动去除前后空格后再校验 ||
| 邮箱大小写不一致 | 服务端按统一规则识别，避免同一邮箱因大小写生成多个账号 ||
| 人机验证失败 | 停留在人机验证弹窗，提示重新验证 ||
| 用户取消人机验证 | 返回邮箱输入页，保留已输入邮箱，不发送 OTP，不创建账号 ||

 ||
| 
 | **邮箱 OTP 验证码页**
**验证码页展示：**

- 标题：Log in with Email；
- 说明：Enter the 6-digit code we sent to [mailto:xxx@email.com](xxx@email.com) to continue.；
- 6 位验证码输入框；
- Resend 入口；
- 数字键盘。

**验证码规则：**

- OTP 为 6 位数字；
- 有效期建议为 5-10 分钟，具体由账号中台定义；
- 同一邮箱需要限制发送频率；
- 同一设备 / IP 需要限制发送次数；
- 连续输错验证码需要限制重试次数。

**Resend 逻辑：**

- 默认展示倒计时，如 Resend a code in 30s；
- 倒计时结束后展示 Resend；
- 用户点击 Resend 后重新发送 OTP，并重新开始倒计时。
- Resend 后旧验证码是否立即失效，以账号中台规则为准；前端以最新一次服务端校验结果为准。

 ||
| 
 | **OTP 验证异常情况**

| 场景 | 处理方式 ||
| OTP 发送失败 | 不进入验证码页，保留邮箱输入，提示 "Failed to send code. Please try again." ||
| OTP 输入未满 6 位 | 不请求校验接口 ||
| OTP 输入错误 | 停留验证码页，提示 "Wrong code. Please try again." ||
| OTP 连续错误次数过多 | 当前验证码失效，提示 "Too many incorrect attempts. Please request a new code." ||
| OTP 过期 | 提示 "This code has expired. Please request a new one." ||

 ||
| 
 | **登录成功后的返回（待确认）**
登录成功后，服务端需要返回：

- account_id；
- 登录 token；
- 用户昵称；
- 登录方式。

同时服务端需要建立当前 gid 与 account_id 的弱关联，用于后续支付权益查询和问题排查。
登录成功后的返回位置取决于登录来源：

| 登录来源 | 登录成功后返回 ||
| 支付前登录 | 返回支付链路，继续创建订单 ||
| Settings 主动登录 | 返回 Settings 已登录态 ||
| Connected Accounts 连接账号 | 返回 Connected Accounts 页面 ||

 ||

### 支付

| 图示 | 描述 ||
| 
 | **支付触发入口**

- 支付入口为 Paywall 页面中的 Subscribe / Continue 按钮。
- 用户点击后，系统先判断用户是否为俄罗斯用户。

 ||
| 
 | **非俄罗斯用户支付流程**
非俄罗斯用户点击 Subscribe / Continue 后，保持现有支付链路。
流程：

- 用户进入 Paywall
- 点击 Subscribe / Continue
- 判断为非俄罗斯用户
- 进入现有商城 / IAP 支付链路
- 完成支付
- 按现有逻辑下发权益

本期不改变非俄罗斯用户的支付、登录和恢复购买逻辑。
 ||
| 
 | **俄罗斯用户支付流程**
俄罗斯用户点击 Subscribe 时，如果当前未登录，需要先登录再支付。
流程：

- 俄罗斯用户进入 Paywall
- 点击 Subscribe / Continue
- 判断为俄罗斯用户
- 判断当前未登录
- 进入 Login 页面
- 用户完成登录
- 返回支付链路
- 创建俄罗斯支付订单
- 跳转第三方支付网页
- 用户完成支付
- 第三方网页拉回 App
- App 查询订单状态和权益状态
- 展示支付结果弹窗

若俄罗斯用户已登录，则跳过第 5-7 步，直接创建俄罗斯支付订单。
 ||
| **创建俄罗斯支付订单**
俄罗斯用户登录成功后，服务端创建支付订单。
创建订单时建议携带以下字段（**待确定）**：

| 字段 | 说明 ||
| account_id | 当前登录账号 ID ||
| gid | 当前设备匿名 ID ||
| product_id | 商品 ID ||
| price | 商品价格 ||
| currency | RUB ||
| region | RU ||
| payment_channel | DukPay ||
| platform | iOS / Android ||
| app_version | App 版本 ||
| redirect_url | 支付完成后回跳 App ||
| callback_url | 支付服务商回调地址 ||
| client_trace_id | 客户端链路追踪 ID ||
| order_no | 商户订单号 ||

创建订单成功后，服务端返回 checkoutUrl。
客户端拿到 checkoutUrl 后，跳转第三方支付网页。
如果创建订单失败，不跳转支付网页，提示用户稍后重试。
 ||
| **第三方支付网页**
俄罗斯支付跳转第三方支付网页。
AirBrush App 内只展示统一的俄罗斯本地支付入口，不拆分展示多个支付方式。具体支付方式由第三方支付网页展示。
P0 需要确认 DukPay / 支付服务商是否支持以下方式：

- Mir Card；
- SBP / FPS；
- SberPay；
- YooMoney / YooKassa；
- T-Pay / Tinkoff Pay。

最终支付方式以服务商 method list 为准。
 ||
| 
 | **支付完成后拉回 App**
支付完成后，第三方支付网页通过 redirect_url 拉回 Airbrush。
App 被拉回后，不直接根据 redirect 参数判断支付成功，而是立即请求服务端查询：

- 订单状态；
- 权益状态。

**异常情况**：

- 如果 redirect 回 App 时缺少 order_no，App 使用当前 account_id + gid 查询最近一笔未完成订单。若查不到订单，则展示无法确认支付的弹窗。
- 如果用户支付完成后未回到 App，服务端仍应根据 callback 更新订单和权益。用户下次打开 App 时，App 查询 account_id / gid 权益并刷新 Premium 状态。

 ||
| 
 | **支付结果反馈**
本期不做独立支付结果页。支付网页拉回 App 后，在当前页面上展示支付结果弹窗。
优先承载页面：

- 如果用户从 Paywall 发起支付，则回到 Paywall 后展示弹窗；
- 如果 App 被拉起到其他页面，也需要优先展示支付结果弹窗；
- 支付结果弹窗展示期间，不展示其他营销弹窗或订阅促销弹窗。

**状态一：支付成功且权益已到账**
触发条件：

- 订单状态为 paid；
- 权益已生效。

弹窗文案：
标题：Payment successful
正文：Your Premium is active now.
按钮：Start using Premium
点击后：

- 关闭弹窗；
- 刷新订阅状态；
- Settings / Paywall 展示 Premium 已生效。

 ||
| 
 | **状态二：支付成功但权益确认中**
触发条件：

- 订单状态为 pending；
- callback 尚未完成；
- 订单已支付但权益尚未下发；
- 权益系统返回处理中。

弹窗文案：
标题：Payment is being confirmed
正文：Your Premium will be activated shortly.
按钮：Refresh status / Contact support
点击 Refresh status：

- 重新查询订单和权益状态；
- 若权益到账，切换为成功弹窗；
- 若仍未到账，继续展示确认中；
- 若查询失败，提示网络异常。

点击 Contact support：

- 进入客服 / feedback 入口；
- 客服需要能通过 order_no、account_id、gid 查询订单和权益状态。

 ||
| 
 | 状态三：支付失败
触发条件：

- 订单状态为 failed；
- 支付服务商明确返回失败。

弹窗文案：
标题：Payment wasn&rsquo;t completed
正文：Please try again or choose another payment method.
按钮：Try again / Back to plans
点击 Try again：

- 关闭弹窗；
- 回到 Paywall；
- 用户可重新点击 Subscribe；
- 重新创建订单，不复用失败订单。

 ||
| 
 | **状态四：用户取消支付**
触发条件：

- 用户在第三方支付网页取消；
- 支付服务商返回 canceled。

弹窗文案：
标题：Payment was canceled
正文：You can try again anytime.
按钮：Back to plans
点击后：

- 关闭弹窗；
- 回到 Paywall；
- 不下发权益。

 ||
| 
 | **状态五：查询失败 / 网络异常**
触发条件：

- redirect 回 App 后，订单状态查询失败；
- 权益查询失败；
- 网络异常；
- 服务端超时。

弹窗文案：
标题：Unable to confirm payment
正文：Please check your connection and refresh the status.
按钮：Confirm
点击 Confirm：

- 关闭弹窗；

 ||

### Account 管理账号

| 图示 | 描述 ||
| 
 | **Settings 已登录态**
用户登录成功后，Settings 页面中的 Log in 行替换为账号信息行。
展示内容：

- 默认头像或账号头像；
- 用户昵称，例如 ABU354621；
- 右侧箭头。

用户点击账号信息行后，进入 Account 页面。
如果用户拥有 Premium 权益，Settings 顶部展示 Airbrush Premium 状态。
 ||
| 
 | **Premium 卡片优化
**优化现 Premium 卡片信息展示，隐藏 My Coins 入口并移入 Premium 页中。缩小 Premium 卡片。 ||
| 
 | **Account 页面**
入口：
Settings

- 点击账号信息行
- Account 页面

页面展示：

- 当前账号信息；
- Connected Accounts；
- Log out；
- Delete Account。

 ||
| 
 | **Account / Profile 页面**
入口：
Settings

- Account 页面
- 点击 Account 按钮进入Profile 页面

用户登录后，可在 Account 中进入 Profile 页面，查看和编辑个人资料。

- Profile 信息不在注册 / 登录流程中强制填写。用户首次登录后，系统可使用默认昵称；Name、Gender、Birthday 均为可选信息，用户可后续在 Profile 中自行补充或修改

 ||
| **Profile 页面****展示逻辑**
Profile 页面展示以下字段：

- Name

- Gender

- Birthday

默认展示规则：

- Name：默认展示

- 系统生成昵称，例如 ABU354621；

- 三方账号登录拉回昵称；

- Gender：若用户未填写，展示 Unknown；

- Birthday：若用户未填写，展示 Unknown。

每一项右侧展示箭头，点击后进入对应编辑页面。
**点击交互**
用户点击 Name，进入 Edit Name 页面。
用户点击 Gender，进入 Edit Gender 页面。
用户点击 Birthday，进入 Edit Birthday 页面。
**具体反馈**
如果 Profile 信息加载失败，页面展示错误提示，并提供 Retry。
提示文案：
Something went wrong. Please try again.
 ||
| 
 | **Account / Profile / Edit Name**
入口：Profile &rarr; Name
**展示逻辑**
进入 Edit Name 页面后，页面展示：

- 顶部标题：Edit Name；
- 返回按钮；
- 右上角 Save；
- Name 输入框；
- 字符数提示；
- 输入规则说明。

**默认状态：**

- 输入框内展示当前 Name；
- 若用户未修改内容，Save 置灰，不可点击；
- 若用户修改内容且符合规则，Save 高亮，可点击。

**输入规则：**

- Name 长度为 2-24 个字符；
- 不支持特殊字符，如 @、<、>、/、\ 等；
- 不允许只输入空格；
- 前后空格提交前自动去除；
- 字符数需实时展示。

**点击交互**

- 用户进入 Edit Name 页面
- 修改 Name
- 前端实时校验字符长度和非法字符
- 校验通过后 Save 高亮
- 用户点击 Save
- 服务端保存 Name
- 保存成功后返回 Profile 页面
- Profile 页面展示更新后的 Name

- **具体反馈**
用户未修改 Name 时，Save 置灰，不可点击。
- Name 少于 2 个字符时，Save 不可点击，并提示：Enter 2-24 characters。
- Name 超过 24 个字符时，Save 不可点击，或限制继续输入。
- Name 包含非法字符时，Save 不可点击，并提示输入规则。
- Name 只包含空格时，Save 不可点击。
用户点击返回且未保存时，返回 Profile 页面，不保存修改。
- 保存失败时，停留当前页，并提示：Something went wrong. Please try again.

 ||
| 
 | **Account / Profile / Edit Gender**
入口：Profile &rarr; Gender
**展示逻辑**
进入 Edit Gender 页面后，页面展示：

- 顶部标题：Edit Gender；
- 返回按钮；
- 右上角 Save；
- Gender 选项列表。

**选项包括：**

- Male
- Female
- Non-binary
- Prefer not to say

**默认状态：**

- 若用户未填写 Gender，Profile 页面展示 Unknown；
- 进入 Edit Gender 页面后，默认不选中任何选项；
- Save 置灰，不可点击。

如果用户已有已保存的 Gender，进入页面时需展示当前选中项。
**点击交互**
用户进入 Edit Gender 页面

- 选择 Gender
- 被选中的选项右侧展示选中状态
- Save 高亮
- 用户点击 Save
- 服务端保存 Gender
- 保存成功后返回 Profile 页面
- Profile 页面展示更新后的 Gender

**具体反馈**

- 用户未选择 Gender 时，Save 置灰，不可点击。
- 用户选择内容与当前已保存内容一致时，Save 可保持置灰，避免重复提交。
- 用户选择后点击返回，返回 Profile 页面，不保存修改。
- 保存失败时，停留当前页，并提示：Something went wrong. Please try again.
- 服务端返回字段异常时，不更新本地展示，并提示稍后重试。

 ||
| 
 | **Account / Profile / Edit Birthday**
入口：Profile &rarr; Birthday
**展示逻辑**
进入 Edit Birthday 页面后，页面展示：

- 顶部标题：Edit Birthday；
- 返回按钮；
- 右上角 Save；
- Birthday 行；
- 日期选择器。

**默认状态：**

- 若用户未填写 Birthday，Profile 页面展示 Unknown；
- Edit Birthday 页面中 Birthday 行展示为空或默认占位；
- Save 置灰，不可点击。

用户点击 Birthday 行后，底部弹出日期选择器。
**日期选择器展示：**

- Cancel；
- Select birth date；
- Save；
- 年 / 月 / 日选择器。

**点击交互**
用户进入 Edit Birthday 页面

- 点击 Birthday 行
- 底部弹出日期选择器
- 用户选择日期
- 点击日期选择器内的 Save
- Birthday 行展示所选日期
- 页面右上角 Save 高亮
- 用户点击右上角 Save
- 服务端保存 Birthday
- 保存成功后返回 Profile 页面
- Profile 页面展示更新后的 Birthday

**具体反馈**

- Birthday 为选填项，不影响登录、支付和权益恢复。
- 用户未选择日期时，Save 置灰，不可点击。
- 用户点击日期选择器 Cancel 时，关闭日期选择器，不更新 Birthday。
- 用户选择未来日期时，不允许保存，并提示选择有效日期。
- 用户选择日期后点击返回，返回 Profile 页面，不保存修改。
- 保存失败时，停留当前页，并提示：Something went wrong. Please try again.
- 日期格式按客户端当前展示规则处理，例如 YYYY/MM/DD。
- 如果后续需要展示年龄，年龄由 Birthday 计算得出，不由用户手动输入。

 ||
| 
 | **Account / Connected Accounts 页面**
入口：Account &rarr; Connected Accounts
页面展示当前支持连接的平台账号：

- Apple；
- Google；
- VKontakte。

每一行展示：

- 平台 icon；
- 平台名称；
- 右侧箭头；
- 若已连接，可展示 Connected 状态。

**连接流程**
用户点击某个平台：

- 检查当前登录态是否有效；
- 若登录态有效，跳转对应三方授权；
- 用户完成三方验证；
- 服务端校验该三方账号是否已绑定其他 Airbrush 账号；
- 若未绑定，则绑定到当前 account_id；
- 返回 Connected Accounts 页面；
- 对应平台展示 Connected。

**绑定冲突**
如果该三方账号已绑定到其他 account_id：
弹窗提示：
This account is already connected to another Airbrush account.
按钮：
OK：点击 OK 后停留在 Connected Accounts 页面，不完成绑定。
**解绑逻辑**

- 仅支持连接其他平台账号，不支持解绑 connected account。

 ||
| 
 | **Log out**
入口：
Account 页面底部 Log out。
**点击后展示二次确认弹窗**：
标题：Log out
正文：Your subscription is linked to your account. You can log in again to restore your benefits.
按钮：Cancel / Log out
**Log out 后：**

- 清除本地登录 token
- 清除本地 account_id
- 保留 gid
- 返回未登录态
- Settings 页面账号信息行恢复为 Log in
- 刷新权益状态

**刷新权益状态：**

- account_id 绑定的俄罗斯支付权益不再通过账号展示
- 用户重新登录同一账号后，可恢复俄罗斯支付权益。

若 Log out 请求失败，保留当前登录态，提示用户稍后重试。
 ||
| 
 | **Delete Account（需与法务确认与「清除账号数据」按钮的关系）**
入口：
Account 页面底部 Delete Account。
**点击后进入二次确认流程：**
标题：Delete account?
正文：Deleting your account will remove your account profile and connected login methods.
按钮：Cancel / Continue

最终确认后，服务端需要先校验：

- 当前登录态是否有效；
- 当前账号是否存在有效俄罗斯支付权益；
- 是否存在 pending 支付订单；
- 是否存在退款 / 撤销中的订单；
- 是否存在未处理完成的权益下发任务。

**如果账号存在有效俄罗斯支付权益，建议阻止删除。**
提示：
You have an active subscription linked to this account. Please cancel or wait until it expires before deleting your account.
如果无有效权益和未完成订单，则允许删除。
**删除成功后：**

- account_id 标记为 deleted；
- 删除或匿名化账号资料；
- 解绑 connected accounts；
- 清除登录 token；
- 保留必要订单记录，用于财务、风控、客服和合规；
- gid 不删除，继续作为设备匿名 ID 使用；
- 客户端回到 Settings 未登录态。

成功文案：
Account deleted.
删除账号后同一邮箱是否允许重新注册、是否生成新的 account_id，需账号中台确认。
 ||

### 权益与恢复购买
**权益查询时机**
权益查询时机App 在以下场景需要查询权益：

- App 启动；
- 用户进入 Paywall；
- 用户登录成功后；
- 支付网页拉回 App 后；
- 用户点击 Refresh status；
- 用户点击 Restore Purchase。

**Restore Purchase 逻辑**
Restore Purchase 逻辑Restore Purchase 可以保持一个入口，但底层分渠道处理。

| 渠道 | 恢复逻辑 ||
| App Store / Google Play | 保持现有平台恢复购买逻辑 ||
| 俄罗斯支付 | 用户登录后，通过 account_id 查询权益 ||

### 五.协议跳转
如有变化需要在这个CF中增减记录：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=599276365](0. AB路由协议-弃用)

### 六.AB code

### 七.AB结论

### 八.埋点需求

### 九.翻译需求

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
| **TPM项目名称
(可附上jira链接)** | 举例：TPM-演唱会场景画质修复 ||
| 业务侧的功能入口 | 举例：演唱会神器-超清现场 ||
| **从哪个业务接入（接入的需填写）** | 说明：只有存在接入的，才需要填写，此时，填写的是接入功能的归属方 ||

### 十一.UI
Figma链接：
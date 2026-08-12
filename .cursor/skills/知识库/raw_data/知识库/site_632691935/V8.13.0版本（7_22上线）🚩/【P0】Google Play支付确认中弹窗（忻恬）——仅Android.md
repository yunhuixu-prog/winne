# 【P0】Google Play支付确认中弹窗（忻恬）——仅Android

**页面ID**: 707421066

**路径**: V8.13.0版本（7_22上线）🚩/【P0】Google Play支付确认中弹窗（忻恬）——仅Android

---

**JIRA地址：待补充**

#### 前置项

| 模块 | 负责人 | 进度 | 备注 ||
| 
 | 
 | 
 | 
 ||
| 
 | 
 | 
 | 
 ||

#### 更改记录：

| 更新时间 | 更新人 | 说明 | 备注 ||
| 2026.07.10 | 忻恬 | 初版：补充 Google Play 支付确认中弹窗逻辑与示意图 | 
 ||
| 2026.07.13 | 忻恬 | 补充待确认状态下购买 CTA 不再调起 Google Play 支付，统一展示支付确认中弹窗 | 
 ||

### 1、需求背景：
巴西用户通过 Google Play 收银台内的 Pix 完成支付后，Google Play 订单可能先处于待确认状态，或订单已确认但 Airbrush 中台会员权益尚未及时返回。用户视角会感知为"已付款但会员没到账"，容易产生困惑、客服投诉和差评风险。
本需求先不改 Google Play 收银台内的支付前提示，因为 Pix 支付方式展示和付款说明发生在 Google Play 收银台内，Airbrush 客户端不可直接干预。Airbrush 侧只处理支付后回流、会员页进入、恢复购买/刷新状态这几个可控触点。
参考约束：

- Google Play Billing pending 状态下不应发放正式权益，需要等 purchase state 变为 PURCHASED 后再发放。
- Google Play Brazil Pix 支付说明中提到，付款后可能需要一些时间处理，购买内容才会可用。

### 2、功能目标：

- 用户完成 Pix / Google Play 支付后，如果权益没有立即到账，明确告知"Google Play 正在确认支付"，降低用户误解。
- 引导用户等待 Google Play 确认，并提供"刷新状态 / 恢复购买"的可操作路径。
- 客户端和中台对 PENDING 与"支付成功但权益未同步"做统一前端承接，但内部状态仍需分开记录，便于排查。
- 当同一账号仍存在待确认订单时，避免用户再次进入 Google Play 支付流程，降低误触套餐变更或重复付费感知。

### 3、需求说明：

#### 一、触发条件
满足以下任一条件时，客户端展示支付确认中弹窗：

| 场景 | 判断条件 | 前端承接 ||
| Google Play 返回待确认 | 购买结果或查询结果为 PENDING | 展示弹窗，记录待确认订单 ||
| 支付已成功但权益未到账 | Google Play 侧已返回成功/可查到订单，但中台会员权益仍未变为有效 | 展示弹窗，并触发权益刷新 ||

客户端不需要向用户区分以上内部状态，用户侧统一看到"Google Play 正在确认支付"。

#### 二、弹窗内容

| 示意图 | 位置 | 中文文案 | English UI Copy ||
| 
 | 标题 / Title | Google Play正在确认支付 | Google Play is confirming your payment ||
| 正文 / Body | 我们正在等待Google Play确认你的支付。确认完成后，会员权益会自动开通，请勿重复支付。 | We're waiting for Google Play to confirm your payment. Once confirmed, your Pro membership will activate automatically. Please do not pay again. ||
| 灰底提示 / Hint | 你可以稍后在当前页面右下角点击「Restore」查看结果。 | You can come back later and tap Restore in the bottom-right corner of this page to check the result. ||
| 左按钮 / Secondary CTA | 稍后查看 | Later ||
| 右按钮 / Primary CTA | 刷新状态 | Refresh status ||

#### 三、展示策略

| 入口 | 展示规则 ||
| 支付后回流 | 命中触发条件时立即展示弹窗。每个订单首次命中必须展示一次。 ||
| 用户进入会员页 | 如果仍存在待确认订单，每次进入会员页都展示弹窗。原因：会员状态下会隐藏会员入口，用户能进入会员页时大概率是在主动查看支付/权益状态。 ||
| 待确认状态下点击购买 CTA | 每次点击都展示支付确认中弹窗，不进入 Google Play 支付流程；确认状态清除后才恢复正常购买。 ||

#### 四、按钮交互

| 操作 | 预期逻辑 ||
| 稍后查看 | 关闭弹窗，停留在当前页面；本次页面会话内不再自动弹出；用户下次主动进入会员页且订单仍待确认时，再次展示弹窗。 ||
| 刷新状态 | 触发客户端 queryPurchasesAsync / Restore Purchase 能力，并请求中台刷新会员权益。 ||
| 待确认状态下点击购买 CTA | 不调起 Google Play 支付，直接展示支付确认中弹窗；引导用户点击弹窗主按钮（Refresh status），也可以点击当前页面右下角 Restore 查看结果。 ||
| 刷新后已到账 | 关闭弹窗，刷新会员状态，用户进入 Pro 有效态。 ||
| 刷新后仍待确认 | 保持弹窗或展示轻提示：Still processing. Please check again later.；继续保留待确认状态承接。 ||
| 查询失败 | 展示轻提示：Unable to refresh. Please try again later.；保留待确认状态入口。 ||

#### 五、状态承接和再次购买处理
当识别到同一账号存在待确认 Google Play 订单时：

- 订阅页可继续展示，但所有购买 CTA点击后不再调起 Google Play 支付。
- 购买 CTA 点击后统一展示"Google Play 正在确认支付"弹窗。只有刷新后确认订单状态已清除，或确认用户没有待处理订单时，才恢复正常购买流程。

### 4、统计需求：

### 5、翻译需求：
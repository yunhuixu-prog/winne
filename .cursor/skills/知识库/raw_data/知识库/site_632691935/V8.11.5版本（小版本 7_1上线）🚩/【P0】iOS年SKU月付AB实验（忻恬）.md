# 【P0】iOS年SKU月付AB实验（忻恬）

**页面ID**: 700368653

**路径**: V8.11.5版本（小版本 7_1上线）🚩/【P0】iOS年SKU月付AB实验（忻恬）

---

**JIRA地址： 待补充**

#### 前置项

| 模块 | 负责人 | 进度 | 备注 ||
| | 谢骏豪 | 6.11可接入 | 
 ||

#### 更改记录：

| 更新时间 | 更新人 | 说明 | 备注 ||
| 2026.6.6 | 忻恬 | 创建需求初稿，补充 SKU 策略、页面文案、实验逻辑、埋点和验收。 | 初稿 ||
| 2026.6.10 | 忻恬 | 调整分期支付 SKU 不上线免费试用。 | 调整 ||
| 2026.6.11 | 忻恬 | 统一两个年 SKU 展示名称，新增实验组 2，并补充价格展示建议。 | 内审调整 ||

### 1、需求背景：

- Apple 在 2026 年 4 月推出 Monthly Subscriptions with a 12-Month Commitment，即"年承诺 + 月付"的订阅付费方式。用户按月付款，但承诺完整 12 期；用户可以取消下一轮承诺续期，但当前 12 期内剩余付款仍会继续完成。
- 该模式当前不支持美国和新加坡，但可以在其他支持地区配置和测试。本需求中的美元价格作为 Airbrush 价格体系参考，不代表美区可实际购买。
- Airbrush 当前主力价格为 yearly $54.99、monthly $12.99。年付总价优势明显，但一次性支付门槛较高；月付门槛低但价格感知偏贵。年 SKU 月付适合测试"低月费 + 年承诺"的新转化空间。
- 竞品/行业参考：Adobe 长期使用 **Annual, billed monthly** 结构，并在 Lightroom 等价格页同时展示 Free trial；Facetune、Picsart、Canva 等竞品在长期订阅上常用 Save xx% / billed monthly / billed annually 解释价格优势。Airbrush 本期只参考年承诺月付结构和价格说明方式，分期支付 SKU 不上线免费试用。
- Apple 官方说明：该模式可在 App Store Connect 配置和 Xcode 测试；用户可在 Apple Account 中查看已完成和剩余付款；Billing Grace Period 不适用于 monthly subscriptions with a 12 month commitment。参考：[https://developer.apple.com/news/?id=agq42lxe](Apple Developer News)、[https://developer.apple.com/documentation/storekit/supporting-monthly-subscriptions-with-a-12-month-commitment](StoreKit Documentation)、[https://www.adobe.com/products/photoshop-lightroom/compare-plans.html](Adobe Lightroom Plans)、[https://www.facetuneapp.com/pricing](Facetune Pricing)、[https://support.picsart.com/hc/en-us/articles/35102132133149-Picsart-Subscription-Plans-Explained-Monthly-vs-Yearly-Options](Picsart Plans)、[https://www.canva.com/pricing/](Canva Pricing)。

### 2、功能目标：

- 在 Airbrush paywall 中新增 Yearly（billed monthly）SKU，首次上线通过 AB 实验验证用户接受度。
- 目标提升订阅按钮点击率和付费转化率，重点观察 yearly 一次性付费犹豫用户是否会转向年承诺月付。
- 实验不以替代 prepaid yearly 为目标，prepaid yearly 仍保留最低总价心智；Yearly（billed monthly）用于测试更低首期支付门槛。

### 3、需求说明：
本期作为 AB 实验接入，实验组展示 3 个 SKU：Yearly（prepaid）、Yearly（billed monthly）、Monthly。

| 对照组
线上SKU
 | 实验组 1
prepaid Yearly 主推
 | 实验组 2
默认选中分期 Yearly
 ||
| 
- 沿用当前线上订阅页商品结构：Yearly / Monthly 的价格、试用开关、支付说明均保持线上逻辑。
- 用于对比实验组新增年承诺月付后的转化、付费结构和投诉风险。

 | 
- 两个年 SKU 均展示为 **Yearly**。
- prepaid Yearly 主价格按线上逻辑展示 **$4.58/mo**，并展示 **Save 65%**。
- Yearly（billed monthly）仅作为备选，展示 **Billed monthly**，不展示 Save 角标。

 | 
- 两个年 SKU 均展示为 **Yearly**。
- prepaid Yearly 不展示角标，展示全年价格 **$54.99/yr**。
- Yearly（billed monthly）展示 **Save 46%**，并默认选中。

 ||

#### 实验组详细说明：

#### 一、实验组 SKU 命名和价格策略

| 商品展示名 | 付费方案 | 展示价格（美元为例）
 | 价格下方说明文案 | 角标文案 | 用户实际理解 ||
| Yearly
实验组 1 默认选中
 | prepaid 连续包年 | 实验组 1：$4.58/mo
（按线上月均价展示）
实验组 2：$54.99/yr
（展示全年扣费金额）
 | 实验组 1：$54.99/year
实验组 2：$4.58/mo
 | 实验组 1：Save 65%
实验组 2：不展示
 | 一次性支付全年，最低总价 ||
| Yearly
实验组 2 默认选中
 | billed monthly 分期月付 | $6.99/mo
（展示订阅中台配置的分期价格，本次暂不调整）
 | 实验组 1：12 payments
实验组 2：Billed monthly
 | 实验组 1：Billed monthly
实验组 2：Save 46%
 | 12 期月付，总承诺金额 $83.88 ||
| Monthly | 连续包月 | $12.99/mo
（同线上）
 | 不展示 | 不展示 | 无年承诺，灵活性最高 ||

定价理由：$6.99/mo 相比 monthly $12.99 便宜约 46%，有明显低月费吸引力；相比 yearly $54.99，总额高 $28.89，用于换取用户无需一次性支付的便利。Airbrush 属于照片编辑工具，用户存在阶段性使用需求，不能把年承诺月付定得太接近 monthly，否则承诺感太重；也不能太接近 yearly 的 $4.58/mo，否则会明显稀释年付价值。
价格展示建议：实验组 1 的目标是主推 prepaid Yearly，因此 prepaid 延续线上月均价展示 $4.58/mo，并通过卡片下方和底部商品说明披露 $54.99/year；Yearly（billed monthly）仅作为低首期备选，不展示 Save，避免抢 prepaid Yearly 的主推心智。实验组 2 的目标是主推 Yearly（billed monthly），因此 prepaid Yearly 展示 $54.99/yr 并去掉角标，Yearly（billed monthly）默认选中并保留 Save 46%。本次不调整分期价格，仍按 $6.99/mo 展示，后续价格方案待数据分析确认。
**二、Yearly（billed monthly）SKU展示前提：**

- 分期不是新商品类型，而是在既有 yearly auto-renewable subscription 上增加 monthly billing plan；订阅中台按「付费方案」区分预付和分期。
- 订阅产品会在 airbrush.paywall.newuser、airbrush.paywall.olduser 的常态入口&对应的用户分层入口配置该实验SKU，且仅在【非美国】地区的入口配置。
- 命中用户分层后，预选 SKU 按实验组配置：实验组 1 保持 prepaid Yearly 默认选中，实验组 2 默认选中 Yearly（billed monthly）。

- 分期月付SKU仅在Xcode版本>=26.5的版本展示，因此需要在这些版本给订阅中台【是否支持分期】接口传 True 标识（订阅中台对接）：
- 字段没有传 True 标识的版本，即使在入口内配置了分期月付SKU，也会不展示（订阅中台过滤）。
- 字段传了 True 标识的版本，即使入口地区覆盖了美国或者新加坡，在这些地区也不会展示分期月付SKU（订阅中台过滤）。
- 即：分期月付SKU仅在该字段传了 True 标识的版本、除了美国和新加坡以外的地区才会展示。其他地区展示常态的年+月/年+周SKU。

#### 三、试用策略

- 分期月付 SKU 首次上线不配置 7-day free trial，仅配置无试用的 Yearly billing plan（分期月付）。
- 用户选中 Yearly（分期月付）时，不展示 7-Day Free Trial 开关；CTA 固定展示 **Continue**。
- Yearly / Monthly 沿用线上试用逻辑，不因本实验调整。

#### 四、**Yearly（billed monthly）SKU商品说明文案**

| 状态 | CTA文案 | 商品说明文案 ||
| 无试用 | Continue | $XX/mo for 12 payments. Renews automatically, cancel any time. ||
| 有试用
（本期虽不上线试用，但预埋文案）
 | Try for Free | $XX/mo for 12 payments. Renews automatically after trial, cancel any time. ||

**五、审核期间逻辑**

- 审核期间不展示分期月付SKU，仅展示无试用年+周/月SKU。

实验：本期希望不要用本地实验。走客户端/服务端实验，否则无法实现线上流量的调整。

### 4、统计需求：
# 【P0】Onboarding订阅页优化AB实验（忻恬）

**页面ID**: 691207138

**路径**: V8.10.0版本（6_8上线）/【P0】Onboarding订阅页优化AB实验（忻恬）

---

**JIRA地址： **

#### 前置项

| 模块 | 负责人 | 进度 | 备注 ||
| 例如：UI | 
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
| 2020.5.21 | xxx | 细节补充：广告不在本需求调整范围内（红色字体标注） | 举例说明 ||
| 
 | 
 | 
 | 
 ||

### 1、需求背景：

- onboarding收入占比全站收入13%，影响力大。在上一期[https://pixocial.feishu.cn/docx/PBPudRyeNoVRrcxQRkJcLcFwnXg](新用户onboaring优化实验)中，通过对onbording页面进行精简权益文案、突出免费试用、价格信息弱化的方式实现了页面订阅成功人数+12.3%，订阅收入+5.8%。本期希望通过交互更新，更突出0元试用信息，提升该页面的订阅转化从而提升GMV。
- 竞品参考：
- 

| Facetune | Remini | FaceLab ||
| 
 | 
 | 
 ||

### 2、功能目标：

- 通过更新onboarding视觉、更突出0元试用信息，提升该页面的订阅转化从而提升GMV。

### 3、需求说明：
对onboarding订阅页做改版AB实验：

| 对照组
线上onboarding订阅页
 | 实验组
本期改版onboarding订阅页
 ||
| 
 | 
 ||

**实验组onboarding页面详细逻辑：**

#### 一、非促销期间（下发常态入口情况下）
****
1、页面视觉升级：进行视觉更新升级，符合当前app内最新主题色。
2、顶部banner区：

- 更新banner。本期期望banner为一个循环播放3-5s左右的B/A视频物料（客户端内置）

3、权益文案区：

- 此处权益文案部分和订阅页同步（内置，同当前订阅页会员权益文案&支持黑后台配置）

4、试用开关区：

- 仅在用户有免费试用资格时才展示该区域，否则隐藏。
- 支持用户切换试用开关状态。默认状态为开。
- 当开关为开，文案：Free Trial Enabled。开关为关，文案：Enable Free Trial

5、支付按钮：

- 当试用开关为开，文案：Try for $0.00
- 针对有小数展示的货币，统一展示货币符号与0.00的组合；不支持小数展示的货币，统一展示货币符号和0。不支持小数展示的货币：日本（JPY）、韩国（KRW）、印尼（IDR）、越南（VND）、伊朗（IRR）
- 点击按钮，调起带试用商品年SKU

- 当使用开关为关，或者用户无试用资格时，文案：Unlock Pro。点击按钮，调起无试用商品年SKU（组合商品）

6、价格说明文案：

- 在主按钮正下方，使用小字号、低对比度灰色展示：
- 带试用SKU：then $XX/year ($XX/week), cancel any time.（文案同当前onboarding页）
- 无试用SKU：Auto-renews at $XX/year ($XX/week), cancel any time.

7、Show all plans：点击进入常态订阅页
8、底部展示Terms of Use | Privacy Policy | Restore。顺序同当前线上订阅页一致。

#### 二、促销期间（下发活动入口情况下）

1、当前时段存在生效的营销活动配置（活动入口生效时），onboarding页面商品取促销年SKU。并且页面UI结构整体调整：

- 在促销状态下，不展示试用开关，替换为折扣横幅。横幅读取包含运营黑后台配置的折扣信息，包含活动title（必填）、subtitle（选填）、describe（选填）字段，以及活动的倒计时。

2、针对促销商品的配置，以及用户是否具备试用资格，促销区进行以下4种逻辑分发：
2.1逻辑分支A：活动商品配置的是试用SKU，且用户有试用资格情况下：

- 订阅按钮文案：Try for $0.00，点击吊起年订阅支付

- 价格说明文案：then $XX/year ($XX/week), cancel any time.

2.2逻辑分支B：活动商品配置的是试用SKU，但用户没有试用资格情况下

- 订阅按钮文案：Unlock Pro，点击吊起年订阅支付

- 价格说明文案：Auto-renews at $XX/year ($XX/week), cancel any time.

2.3逻辑分支C：活动商品配置的是首期优惠SKU，且用户有优惠资格情况下

- 订阅按钮文案：Claim Offer，点击吊起年订阅支付

- 价格说明文案：The first year is $XX ($XX/week), then $XX/year, cancel any time.

2.4逻辑分支D：活动商品配置的是首期优惠SKU，但用户没有优惠资格情况下

- 订阅按钮文案：Unlock Pro，点击吊起年订阅支付

- 价格说明文案：Auto-renews at $XX/year ($XX/week), cancel any time.

#### 三、审核期间逻辑
审核期间按照用户无试用资格样式处理，但价格说明文案不换算为周价格：Auto-renews at $XX/year, cancel any time.。点击支付按钮，调起无试用商品年SKU。

#### 四、弱网弹窗调整

- 线上、实验组状况都做
- 现况：拉起订阅页时，若是 无网、弱网环境，立即弹出一个网路问题弹窗，体验观感不佳。
- 调整内容：
- **分阶段执行状态告知逻辑，针对全 app 内的订阅页都修改**
- 头 2s 为 loading 状态
- 3s 时弹出 toast: Connecting, please wait...
- 6s 时再谈网路问题弹窗

### 4、统计需求：

### 5、翻译需求：
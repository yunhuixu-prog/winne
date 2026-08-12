# 【P1】精细化分层优惠——已过期会员AB实验（忻恬）

**页面ID**: 691177413

**路径**: V8.11.0版本（6_17 端午版本）🚩/V8.11.0上期遗留需求/【P1】精细化分层优惠——已过期会员AB实验（忻恬）

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

- 当前DAU中，历史订阅过但已过期用户的占比达12%（日均9万）。该部分用户在过期30日内复购订阅率达8%，过期90日后订阅率跌至2%。因此本期上线针对订阅过期人群的精细化分层促销，通过优惠尽快挽留他们。
- 针对已过期人群的复购在竞品中也为常见手段（截图为CapCut）：
- 

### 2、功能目标：

- 针对订阅已过期人群下发分层优惠，提升该部分人群的复购率及GMV。

### 3、需求原型：

### 4、需求说明：
一、实验范围：**

- 地区：全球
- 平台：iOS + Google
- 人群：过期会员（历史有订阅过会员、且当前会员状态已失效的非会员用户），分层code = 10006、10007、10008
- 涉及页面：首页、订阅页、编辑器Pro横幅、保分页

**二、实验内容**
1、对照组：过期会员无特殊优惠
2、实验组：过期会员根据上一单过期的SKU，下发相同周期的优惠SKU

- 用户上一单过期的是年SKU，则本次推荐：年SKU（首期8折）&mdash;&mdash;10006
- 用户上一单过期的是月SKU，则本次推荐：月SKU（首期8折）&mdash;&mdash;10007
- 用户上一单过期的是周SKU，则本次推荐：周SKU（首期8折）&mdash;&mdash;10008

优惠商品信息：

| 端 | 年优惠SKU
首年优惠
 | 月优惠SKU
首月优惠
 | 周优惠SKU
首周优惠
 ||
| iOS | com.meitu.airbrush.autorenew.vip8 | com.meitu.airbrush.autorenew.vip14 | com.meitu.airbrush.autorenew.vip15
 ||
| Google | com.meitu.airbrush.subscription.vip17 | com.meitu.airbrush.subscription.vip19 | com.meitu.airbrush.subscription.vip20 ||

**三、实验组具体方案：**
针对满足条件的用户，在订阅页下发对应优惠商品；并且配合在首页、订阅页、编辑器Pro横幅、保分页进行对应的营销。
1、满足以下所有条件的用户可触发：

- 历史有订阅过会员、且当前会员状态已失效的非会员用户
- 有分层入口里优惠商品的推介优惠/促销优惠资格
- 非运营促销活动期间可触发（判断是否有运营促销活动可通过对应地区的同个入口类型是否有生效中的活动入口判定）

2、分层触发时机：满足条件用户，在启动app后触发。
3、分层优惠时效：从触发分层开始计算，24小时后/或用户转化成会员后，优惠失效。首页、订阅页、编辑器Pro横幅、保分页恢复常规通用状态；订阅半窗内不再展示对应分层优惠商品。
4、分层触发频次控制：用户命中优惠后，30天内不再重复命中该过期会员分层优惠。
5、触发分层优惠后端内效果：

| 营销区域 | 说明 ||
| 
 | **1、首页弹窗：**

- 命中分层的用户，启动app后弹出优惠弹窗（通用优惠弹窗）。弹窗内容：
- 优惠券：优惠SKU的优惠价、划线价、总价（仅年SKU）、倒计时（24小时）
- 标题：Welcome Back!
- 副标题：We missed you. Here's an exclusive return gift to unlock all Pro features again.
- CTA按钮：Claim My X% OFF. X=优惠商品折扣百分比（优惠商品与比价商品对比获得）。点击后调起对应分层入口优惠SKU（默认选中的SKU）的IAP/IAB收银台。
- 点击右上角X关闭弹窗

- 弹窗频率：单次分层内在首页仅弹一次。
- 弹窗优先级：针对该启动就命中分层的场景，优先弹优惠弹窗，再弹启动场景订阅页

**2、首页左上角订阅页入口：**

- 触发分层后，展示对应的折扣&分层优惠有效期倒计时

 ||
| 
 | **1、订阅页下发分层入口商品**

- 分层有效期间进入订阅页，展示优惠信息：

- 标题：Welcome Back Exclusive
- 主标题：Claim Your X% OFF
- 倒计时：分层优惠有效期倒计时

- 商品角标：优惠商品上固定展示角标文案Return Gift

**2、订阅页流失挽留弹窗**

- 触发时机：用户在分层订阅页未完成支付转化，点击左上角X尝试离开页面时触发。
- 弹窗内容：
- 主标题：Wait! Before you go...
- 副标题：Your exclusive X% OFF return offer is about to expire. Lock in this deal now to keep editing without limits.
- 主按钮：Keep Pro & Save X%。点击后调起对应分层入口优惠SKU（默认选中的SKU）的IAP/IAB收银台。
- 底部商品辅助文本（变量需与实际优惠SKU对齐）：
- 年优惠商品：Just $XX/mo (billed annually at $XX). Cancel anytime.
- 月优惠商品：Just $XX for your first month (then $YY/mo). Cancel anytime.
- 周优惠商品：Just $XX for your first week (then $YY/week). Cancel anytime.

- 点击右上角X关闭弹窗
- 弹窗频率：挽留弹窗单次分层内在订阅页仅弹一次。

 ||
| 
 | **编辑器Pro横幅**
1、触发分层后，编辑器的Pro横幅文案修改：

- 主文案：Welcome Back!
- 副文案：Claim X% OFF to unlock Pro again.
- 右侧按钮：倒计时。点击进入分层订阅页。

 ||
| 
 | 保分页订阅入口
1、触发分层后，保分页中的订阅页入口文案展示：Get Your Return Gift
 ||

### 5、统计需求：

### 6、翻译需求：
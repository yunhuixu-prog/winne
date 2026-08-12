-- 每一行代表一个订单
select pay_date
    ,notify_pay_id -- 通知表订单号(续期为合约号，非续期为订单号)
    ,order_id -- 订单ID，新增订单及后续的续订订单id均不同
    ,contract_id -- 合约ID，新增订单及后续的续订都为一个合约号
    ,device_type as os_type
    ,nvl(country_name,'未知') country_code
    ,period_type -- 订单周期类型
    ,pay_date -- 支付日期
    ,ord_amt -- 分成后收入（人民币）
    ,ord_before_amt -- 分成前收入（人民币）
    ,ord_amt_usd -- 分成后收入（美元）
    ,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd -- 分成前收入（美元）
    ,gid -- 用户标识id
    ,pay_status -- 支付状态,6代表已退款，日常仅算退款数据时需要使用该字段
    ,cur_pay_stage -- 当前订单代扣期数(包含试用单)
    ,cur_pay_withhold_stage -- 当前订单代扣期数(不包含试用单)
    ,invalid_date -- 订单失效日期，一般用来计算当前订阅有效期人数
    ,pay_status
    -- 以下为退款字段
    ,refund_date -- 退款日期，计算退款数据时需要使用该字段
    ,-refund_amt -- 分成后退款收入（人民币）
    ,-refund_before_amt -- 分成前退款收入（人民币）
    ,-refund_amt_usd -- 分成后退款收入（美元）
    ,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) refund_before_amt_usd -- 分成前退款收入（美元）
from stat_vip.paid_oda_all_order_summary
where app_id_p IN (7329803307041000000) -- 应用，此为必须字段
    and pay_date between ${start_time} and ${end_time} -- 支付日期
    and product_sub_line = 'AirBrush' -- 产品子线，此为必须字段
    and is_subscribe='订阅' -- 是否订阅，此为必须字段

;

-- 订阅来源归因
-- 来源未拆，一次进入一行
select date_p
    ,gid
    ,SUM(CASE WHEN event_id = 'w_subscription_enter' THEN 1 ELSE 0 END) AS enter_cnt
    ,MAX(CASE WHEN event_id = 'sub_suc' THEN 1 ELSE 0 END) AS has_success
    ,MAX(CASE WHEN event_id = 'sub_suc' and is_paid=1 THEN 1 ELSE 0 END) AS has_success_to_paid
    ,MAX(CASE WHEN event_id = 'sub_suc' and is_paid=1 THEN paid_ord_amt ELSE 0 END) AS has_success_to_paid_ord_amt
from stat_ab.filing_onz_sub_source_event_detail
where
    date_p between ${start_time} and ${end_time}
    and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
GROUP BY date_p,gid
;
-- 拆成多个来源，即若一次进入多个来源，拆成多个行
select
    date_p -- 归因日期，如果1.1试用，1.8付费，则归因日期为1.1
    ,gid
    ,country -- 国家
    ,is_new -- 是否新用户
    ,is_ua -- 是否UA用户
    ,app_version -- 应用版本
    ,event_id -- sub_enter:订阅页进入，sub_click:订阅页点击，sub_suc:订阅成功（包括试用）
    ,is_paid -- 仅event_id=sub_suc时有效，当前订单是否付费
    ,event_time -- 事件时间
    ,duration -- 订单周期类型
    ,sku -- 订阅SKU
    ,first_source,second_source,third_source,fourth_source -- 层级来源归因
    ,devide_paid_ord_amt -- 分摊后订阅毛利（美元）
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between ${start_time} and ${end_time}

;
-- 解约信息
SELECT  contract_id -- 合约id，用来和订单表的contract_id关联
        ,dismiss_time -- 解约时间
        ,CAST(dismiss_date AS BIGINT)  as dismiss_date -- 解约日期（bigint类型）
FROM stat_vip.paid_oda_vip_tb_contract
WHERE date_p =${now_time}
        and app_id_p not in(-1)
        AND dismiss_date>=${start_time}
        AND contract_status = 3
        and commodity_id_P not in (-1)
group by contract_id,dismiss_time,dismiss_date

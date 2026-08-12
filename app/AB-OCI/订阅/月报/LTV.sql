-- 月没改好
select subscription_period
     ,count(uuid) uv
     ,round(sum(payment)/count(uuid),2) payment
     ,round((sum(order_num_af+1))/count(uuid),2) order_num_365
     ,round((sum(payment)+sum(payment_af_30))/count(uuid),2) payment_30
     ,round((sum(payment)+sum(payment_af_365))/count(uuid),2) payment_365
     ,round((sum(same_order_num_af+1))/count(uuid),2) same_order_num_365
     ,round((sum(payment)+sum(same_payment_af))/count(uuid),2) same_payment_365
from
(

--     select a.standard_order_date,a.subscription_period,a.uuid,a.payment_price_usd
--         ,b.standard_order_date standard_order_date_af
--         ,b.subscription_period subscription_period_af
--         ,b.subscription_user_type subscription_user_type_af
--         ,b.payment_price_usd payment_price_usd_af
    select a.standard_order_date,a.subscription_period,a.uuid
        ,max(a.payment_price_usd) payment
        ,sum(case when b.standard_order_date between date_add(a.standard_order_date,interval 1 day) and date_add(a.standard_order_date,interval 29 day) then
            b.payment_price_usd end) payment_af_30
        ,sum(b.payment_price_usd) payment_af_365
        ,count(distinct b.order_id) order_num_af
        ,sum(case when b.subscription_period=a.subscription_period then b.payment_price_usd end) same_payment_af
        ,count(distinct case when b.subscription_period=a.subscription_period then b.order_id end) same_order_num_af
    from
    (
        SELECT  contract_id
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end as os_type
                   ,nvl(country_name,'未知') as country_code
                   ,period_type
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}               -- 历史分区可能有问题，用最新分区
                  and pay_date<=20260331
                  and substr(invalid_time,1,8) between 20260101 and 20260331
                  and cur_pay_withhold_stage=1 -- 新增订单
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and app_id_p IN (7329803307041000000)
                  and commodity_id_P not in (-1)
                  and country_name='美国'
    ) a
    left join
    (
        SELECT  contract_id
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end as os_type
                   ,nvl(country_name,'未知') as country_code
                   ,period_type
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}               -- 历史分区可能有问题，用最新分区
                --   and pay_date<=20260331   -- 月应续费看板上限制了前一个月之前的订单，非当月的
                  and substr(pay_date,1,6)<substr(invalid_time,1,6)
                  and substr(invalid_time,1,8) between 20260101 and 20260331
                  and cur_pay_withhold_stage>=1 
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and app_id_p IN (7329803307041000000)
                  and commodity_id_P not in (-1)
                  and country_name='美国'
    ) b
    on a.contract_id=b.contract_id and b.standard_order_date between date_add(a.standard_order_date,interval 1 day) and date_add(a.standard_order_date,interval 364 day)
    group by 1,2,3
)
where order_num_af<20
group by 1



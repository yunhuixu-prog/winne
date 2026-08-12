-- 初始订单日，订单数，续订1期数，续订2期数，续订3期数，续订4期数
select order_start_date
--         ,country,platform
        ,count(distinct o_original_order_id) order_num
        ,count(distinct case when order_num>=2 then o_original_order_id end) order_num_1
        ,count(distinct case when order_num>=3 then o_original_order_id end) order_num_2
        ,count(distinct case when order_num>=4 then o_original_order_id end) order_num_3
        ,count(distinct case when order_num>=5 then o_original_order_id end) order_num_4
--         ,round(sum(payment_usd),2) payment_usd
from
    (select o_original_order_id,subscription_period,sku
--            ,case when country in ('United States','Brazil','United Kingdom') then country else 'other' end country
--            , platform
           , min(standard_order_date)        order_start_date
           , count(distinct order_id)        order_num
           , max(standard_order_expire_date) standard_order_expire_date
           , sum(payment_price_usd)          payment_usd
      from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
      where app_id='AirBrush'
        and subscription_period = '1-week'
        and standard_order_date >= '2026-01-08'
        and payment_price_usd>0
      -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
      group by 1,2,3
    )
-- where sku='beautyplus.subs.week1.func00.lev00.v1'
group by 1
order by 1
;

-- 初始订单日，订单数，续订1期数，续订2期数，续订3期数，续订4期数
select order_start_date,country,platform
        ,count(distinct o_original_order_id) order_num
        ,count(distinct case when order_num>=2 then o_original_order_id end) order_num_1
        ,count(distinct case when order_num>=3 then o_original_order_id end) order_num_2
        ,count(distinct case when order_num>=4 then o_original_order_id end) order_num_3
        ,count(distinct case when order_num>=5 then o_original_order_id end) order_num_4
--         ,round(sum(payment_usd),2) payment_usd
from
    (select o_original_order_id,subscription_period,sku
           ,case when country in ('United States','Brazil','United Kingdom') then country else 'other' end country
           , platform
           , min(standard_order_date)        order_start_date
           , count(distinct order_id)        order_num
           , max(standard_order_expire_date) standard_order_expire_date
           , sum(payment_price_usd)          payment_usd
      from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
      where app_id='AirBrush'
        and subscription_period = '1-week'
        and standard_order_date >= '2026-01-08'
        and payment_price_usd>0
      -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
      group by 1,2,3,4,5
    )
-- where sku='beautyplus.subs.week1.func00.lev00.v1'
group by 1,2,3
order by 1,2,3






-- 初始订单日，订单数，续订1期数，续订2期数，续订3期数，续订4期数
select order_start_date,sku
        ,count(distinct original_order_id) order_num
        ,count(distinct case when order_num>=2 then original_order_id end) order_num_1
        ,count(distinct case when order_num>=3 then original_order_id end) order_num_2
        ,count(distinct case when order_num>=4 then original_order_id end) order_num_3
        ,count(distinct case when order_num>=5 then original_order_id end) order_num_4
        ,round(sum(payment_usd),2) payment_usd
from
    (select original_order_id
           , min(standard_order_date)        order_start_date
           , count(distinct order_id)        order_num
           , max(order_id)                   max_order
           , max(standard_order_expire_date) standard_order_expire_date
           , sum(payment_price_usd)          payment_usd
           , max(sku)                         sku
      from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
      where app_id='BeautyPlus'
        and subscription_period='1-week'
      -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
      group by 1
    )
-- where sku='beautyplus.subs.week1.func00.lev00.v1'
group by 1,2
order by 1,2


-- 寻找例子
select original_order_id,count(distinct order_id)
from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
where app_id='BeautyPlus'
  and subscription_period='1-week'
  -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
group by original_order_id
having count(distinct order_id)=1


-- test1:续订的例子
select order_date,standard_order_date
    ,original_order_id,order_id
    ,order_expire_date,standard_order_expire_date
    ,next_order_date,next_sku_continue,next_order_id
    ,platform,order_status
    ,sku,payment_price_usd,sku_price
from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
where app_id='BeautyPlus'
  and subscription_period='1-week'
  and original_order_id='GPA.3384-0925-0196-27320'
  -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
order by standard_order_date

-- test2:未续订的例子，next_sku_continue似乎计算方式不对
select *
from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
where app_id='BeautyPlus'
  and subscription_period='1-week'
  and original_order_id='GPA.3374-4979-6177-72435'
  -- and sku in ('beautyplus.subs.week1.func00.lev00.v0','beautyplus.subs.week1.func00.lev00.v1')
  -- and next_sku_continue=0
order by standard_order_date


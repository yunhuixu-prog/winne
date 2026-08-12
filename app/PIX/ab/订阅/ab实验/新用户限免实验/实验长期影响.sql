
-- 实验长期影响，付费天数的变化
with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  abcode
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-07',cast(date_add('2025-07-25',interval 31 day) as string),'airbrush',false)
where
    event_name in ('w_subscription_success')
)
,enter as (
select
    distinct
    date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date
    ,user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-07','2025-07-25','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
)

,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(abcode),b.abcode,b.enter_abtest_date
    from eves a
    join enter b on a.device_id= b.device_id
    where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,subscription_period,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date between '2025-04-07' and date_add('2025-07-25',interval 31+7 day)
        and order_status in (0,1,2)
)
,ads as (
    select
        event_date
        ,user_pseudo_id
        ,platform
        ,sum(max_impression_pv) max_impression_pv
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
    and event_date between '2025-04-07' and date_add('2025-07-25',interval 31 day)
   group by 1,2,3
)
,ads_ab as (
    -- 取进入实验的用户在进入后每天的付费情况
    select
        ad.*
        ,e.abcode,e.enter_abtest_date
    from  ads ad
    join
       enter e
    ON e.user_pseudo_id = ad.user_pseudo_id and e.enter_abtest_date <= ad.event_date
    where e.user_pseudo_id is not null
)

-- 先不考虑广告
select
    abcode
    ,enter_abtest_date
    ,standard_order_date
    ,date_diff(standard_order_date,enter_abtest_date,day) days
    ,subscription_period types
    ,count(distinct device_id) sub_success_uv
    ,count(distinct case when order_status in (1,2) then device_id
                when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
    ,sum(case when order_status in (1,2) then payment_price_usd
        when order_status= 0 and next_standard_order_date is not null then next_payment_price_usd
        else 0 end) gmv
from
(
    select
        a.enter_abtest_date,a.abcode,a.device_id
        ,b.standard_order_date,b.original_order_id,b.sku,b.order_status,b.subscription_period
        ,b.payment_price_usd
        ,next_standard_order_date
        ,next_payment_price_usd
    from fe a
    join paid b on a.order_id = b.order_id and a.sku = b.sku
)
where standard_order_date >= enter_abtest_date
group by 1,2,3,4,5

--     union all
--
--     select
--         abcode
--         ,event_date date
--         ,'ads' types
-- --         ,count(distinct device_id) sub_success_uv
-- --         ,count(distinct case when order_status in (1,2) then device_id
-- --                     when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
--         ,sum(max_revenue) gmv
--     from ads_ab
--     group by 1,2,3


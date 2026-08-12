-- 实验周期选择：最好选择较为稳定的一段时间，不要从最开始取
-- 修改实验abcode：批量替换 '11369','11371','11372','11373'
DECLARE mDATE_ABTEST_START DATE DEFAULT '2025-08-22';
DECLARE mDATE_ABTEST_END DATE DEFAULT '2025-09-10';

drop table if exists `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau_1`;
create table if not exists `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau_1` as
with enter_pre as (
select
    distinct
    date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date
    ,user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
   ,event_timestamp
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_ABTEST_START as string),cast(mDATE_ABTEST_END as string),'airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11369','11371','11372','11373')
--     and _table_suffix between date_sub(mDATE_ABTEST_SRART,interval 1 day) and date_add(mDATE_ABTEST_END,interval 1 day)
--     and date(timestamp_micros(event_timestamp),'Asia/Singapore') between mDATE_ABTEST_START and mDATE_ABTEST_END
)
,act as (
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between mDATE_ABTEST_START and mDATE_ABTEST_END
        and  app_name = 'AirBrush'
)
-- 进入实验且当天活跃
select *
from
(
    select
        e.device_id,e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.uuid,fa.is_new enter_new
        ,row_number() over(partition by e.device_id order by event_timestamp) ranks
    from  act fa
    join
       enter_pre e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
    where e.user_pseudo_id is not null
)
where ranks=1
--   and enter_new=1
;

with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  abcode
from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_ABTEST_START as string),cast(mDATE_ABTEST_END as string),'airbrush',false)
where
    event_name in ('w_subscription_success')
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(abcode),b.abcode,b.enter_abtest_date
    from eves a
    join `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau_1` b
    on a.device_id= b.device_id
    where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,subscription_period,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 14 day)
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
    and event_date between mDATE_ABTEST_START and mDATE_ABTEST_END
   group by 1,2,3
)
,ads_ab as (
    -- 取进入实验的用户在进入后每天的付费情况
    select
        ad.*
        ,e.abcode,e.enter_abtest_date
    from  ads ad
    join
       (select user_pseudo_id,abcode,min(enter_abtest_date) enter_abtest_date from `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau_1` group by 1,2) e
    ON e.user_pseudo_id = ad.user_pseudo_id and e.enter_abtest_date <= ad.event_date
    where e.user_pseudo_id is not null
)

select * from
(
    select
        abcode
        ,standard_order_date date
        ,subscription_period types
--         ,count(distinct device_id) sub_success_uv
--         ,count(distinct case when order_status in (1,2) then device_id
--                     when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
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
    group by 1,2,3

    union all

    select
        abcode
        ,event_date date
        ,'ads' types
--         ,count(distinct device_id) sub_success_uv
--         ,count(distinct case when order_status in (1,2) then device_id
--                     when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
        ,sum(max_revenue) gmv
    from ads_ab
    group by 1,2,3
)
order by 1,2,3

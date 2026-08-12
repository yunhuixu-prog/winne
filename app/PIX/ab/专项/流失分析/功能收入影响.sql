drop table if exists `dataintegration-265403.temp.new_user_function_sub_analysis_winne`;
create table if not exists `dataintegration-265403.temp.new_user_function_sub_analysis_winne` as

with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'trace_info').string_value as trace_info
    ,func.getParams(event_params,'first_func').string_value as first_func
    ,func.getParams(event_params,'second_func').string_value as second_func
    ,func.getParams(event_params,'third_func').string_value as third_func
    ,func.getParams(event_params,'prf_first_func').string_value as prf_first_func
    ,func.getParams(event_params,'prf_second_func').string_value as prf_second_func
    ,func.getParams(event_params,'prf_third_func').string_value as prf_third_func
    ,func.getParams(event_params,'prf_material_type').string_value as prf_material_type
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
    ,func.getParams(event_params,'SKU').string_value as sku
    ,func.getParams(event_params,'order_id').string_value as order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-13','2025-07-26','airbrush',true)
where
    event_name in ('edit_enter','edit_save','w_subscription_enter','w_subscription_click','w_subscription_success'
    ,'first_func_enter','second_func_enter','third_func_enter','first_func_use','second_func_use','third_func_use'
    )
--     and _table_suffix between '20250719' and '20250727'
--    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-07-13' and'2025-07-26'
)
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
  --  ,event_timestamp
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-13','2025-07-26','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11075','11076')
--       and _table_suffix between '20250719' and '20250727'
--    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-07-13' and'2025-07-26'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code),b.ab_code,b.date enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
         join enter_test b on a.user_pseudo_id= b.user_pseudo_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,active as
(
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-07-13' and'2025-07-26'
        and  app_name = 'AirBrush'
)

select f.*,a.uuid,a.is_new,af.is_new enter_abtest_is_new
from fe f
join active a on f.date = a.event_date_hk and f.user_pseudo_id = a.user_pseudo_id
join active af on f.enter_abtest_date = af.event_date_hk and f.user_pseudo_id = af.user_pseudo_id
;

with paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2025-07-13'
    and order_status in (0,1,2)
)
,sub_to_paid as
(
    select
        a.date,a.user_pseudo_id,a.event_name,a.event_timestamp,b.standard_order_date, b.original_order_id ,b.sku,b.order_status
        ,b.payment_price_usd
        ,next_standard_order_date
        ,next_payment_price_usd
    from
        (
        select
        *
        from `dataintegration-265403.temp.new_user_function_sub_analysis_winne`
        where event_name = 'w_subscription_success'
        )a
        join paid b on a.order_id = b.order_id and a.sku = b.sku
)

select
    a.platform,a.ab_code
    ,'All' types
    ,'All' source_module
    ,'All' source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_function_sub_analysis_winne` a
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7 and a.enter_abtest_is_new=1
group by 1,2,3,4,5,6

union all

select
    a.platform,a.ab_code
    ,'module' types
    ,coalesce(a.source_module,'unknown') source_module
    ,'All' source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_function_sub_analysis_winne` a
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7 and a.enter_abtest_is_new=1
group by 1,2,3,4,5,6


union all

select
    a.platform,a.ab_code
    ,'source0' types
    ,coalesce(a.source_module,'unknown') source_module
    ,coalesce(s0,'others') source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_function_sub_analysis_winne` a,unnest(split(coalesce(source_0,'others'),',')) s0 --,unnest(split(coalesce(source_1,'others'),',')) s1
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7 and a.enter_abtest_is_new=1
group by 1,2,3,4,5,6


union all

select
    a.platform,a.ab_code
    ,'source1' types
    ,coalesce(a.source_module,'unknown') source_module
    ,coalesce(s0,'others') source_0
    ,coalesce(s1,'others') source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_function_sub_analysis_winne` a,unnest(split(coalesce(source_0,'others'),',')) s0,unnest(split(coalesce(source_1,'others'),',')) s1
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7 and a.enter_abtest_is_new=1
group by 1,2,3,4,5,6




-- 显著性计算
-- 订阅收入、人均保存次数
with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,case
        when event_name in ('edit_enter', 'camera_enter','video_start_edit') then 'enter'
        when event_name in ('edit_save', 'camera_save','video_save') then  'save'
        else event_name
    end event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('edit_enter','edit_save', 'camera_enter','camera_save','video_start_edit','video_save','w_subscription_enter'
    ,'w_subscription_click','w_subscription_success' )
    and _table_suffix between'20250821' and '20250914'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-09-10'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
)
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11369','11371','11372','11373')
      and _table_suffix between '20250821' and '20250914'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-09-10'
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-08-22' and '2025-09-10'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    ,case when ab_code in ('11369','11372') then '对照组'
          when ab_code in ('11371','11373') then '实验组'
          end code
    from
    (
        select
            e.device_id,e.platform,e.ab_code,e.enter_abtest_date
            ,row_number() over(partition by e.device_id order by event_timestamp) ranks
        from  act fa
        join
           enter_test e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code,country)
        ,c.is_new,c.country
        ,b.ab_code,b.code,b.enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
    join enter b
    on a.device_id= b.device_id
    join act c on a.user_pseudo_id= c.user_pseudo_id and a.date=c.event_date_hk
    where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2025-08-22'
    and order_status in (0,1,2)
)
,fe_sub as
(
    select
        a.device_id
        ,round(sum(case when b.order_status in (1,2) then b.payment_price_usd
            when  b.order_status= 0 and b.next_standard_order_date is not null then  b.next_payment_price_usd
            else 0 end ),2) value
        from
        (
        select
        *
        from fe
        where event_name = 'w_subscription_success'
        )a
        join paid b on a.order_id = b.order_id and a.sku = b.sku
--     where a.platform='ANDROID'
    group by 1
)
,fe_save as
(
    select
        date,code,device_id,sum(pv) value
    from fe
    where event_name ='save'
--     and platform='ANDROID'
    group by 1,2,3
)

select a.code,'sub' types
     ,count(distinct a.device_id) computer_uv,sum(b.value) total
     ,round(AVG(coalesce(b.value,0)),6) mean,round(STDDEV(coalesce(b.value,0)),4) std
from (select distinct device_id,code from enter) a  -- where platform='ANDROID'
left join fe_sub b
on a.device_id=b.device_id
group by 1,2

union all

select b.code,'save' types
     ,count(b.device_id) computer_uv,0 total
     ,round(AVG(coalesce(b.value,0)),6) mean,round(STDDEV(coalesce(b.value,0)),4) std
from fe_save b
group by 1,2

order by 2,1

;
-- 广告收入
with ads as (
    select
        event_date
        ,user_pseudo_id
        ,platform
        ,sum(max_impression_pv  ) max_impression_pv
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
    and event_date between  '2025-08-22' and '2025-09-10'
   group by 1,2,3
)
,enter_test as (
select
    distinct
    date(timestamp_micros(event_timestamp),'Asia/Singapore') enter_abtest_date,  user_pseudo_id
    ,geo.country country
    ,platform
   ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
   ,event_timestamp
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`( '2025-08-22' ,'2025-09-10','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11369','11371','11372','11373')
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-08-22' and '2025-09-10'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date
            ,row_number() over(partition by e.user_pseudo_id order by event_timestamp) ranks
        from  act fa
        join
           enter_test e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)
,
ads_ab as
(
    select
        a.abcode,
        a.user_pseudo_id
      ,sum(max_revenue) value
    from
        enter a join ads  b on a.user_pseudo_id = b.user_pseudo_id and a.platform = b.platform
    where  b.event_date >= a.enter_abtest_date
--     and a.platform='ANDROID'
    group by 1,2
)

select case when a.abcode in ('11369','11372') then '对照组'
          when a.abcode in ('11371','11373') then '实验组'
          end code
     ,count(distinct a.user_pseudo_id) computer_uv,sum(b.value) total
     ,round(AVG(coalesce(b.value,0)),6) mean,round(STDDEV(coalesce(b.value,0)),4) std
from (select distinct user_pseudo_id,abcode from enter) a -- where platform='ANDROID'
left join ads_ab b
on a.user_pseudo_id=b.user_pseudo_id
group by 1
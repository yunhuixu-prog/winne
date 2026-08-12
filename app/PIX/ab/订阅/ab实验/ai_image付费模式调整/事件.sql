with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
--     ,,timestamp_micros(event_timestamp) times
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,coalesce(func.getParams(event_params,'SKU').string_value,func.getParams(event_params,'sku').string_value) sku
    ,func.getParams(event_params,'first_func').string_value first_func
    ,func.getParams(event_params,'is_create_task').string_value is_create_task
    ,func.getParams(event_params,'is_success').string_value is_success
    ,func.getParams(event_params,'material_type').string_value material_type
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success'
        ,'ai_func_delivery','ai_func_use_result','material_exposure','material_click')
    and _table_suffix between '20260205' and '20260316'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between '2026-02-27' and'2026-03-05'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
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
    and func.getParams(event_params,'current_abcode').string_value in  ('28653','28654')
      and _table_suffix between '20260205' and '20260316'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between '2026-02-27' and'2026-03-05'
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2026-02-27' and'2026-03-05'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.device_id,e.platform,e.ab_code,e.enter_abtest_date,e.event_timestamp,e.user_pseudo_id
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
        ,b.ab_code,b.enter_abtest_date
    from
        (select * from eves
        where case when event_name='ai_func_delivery' then first_func='ai_filter' and is_create_task='1'
                   when event_name='ai_func_use_result' then first_func='ai_filter'
                   when event_name in ('material_exposure','material_click') then material_type='ai_image'
        else 1=1 end
        )a
    join enter b
    on a.device_id= b.device_id
    join act c on a.user_pseudo_id= c.user_pseudo_id and a.date=c.event_date_hk
--     where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
    where b.event_timestamp <= a.event_timestamp

    union all

    select distinct enter_abtest_date date
    ,b.platform,c.user_pseudo_id
    ,'enter_abtest' event_name
    ,b.device_id
    ,b.event_timestamp
    ,cast(null as string) source_module
    ,cast(null as string) source_0
    ,cast(null as string) source_1
    ,cast(null as string) duration
    ,cast(null as string) sku
    ,cast(null as string) first_func
    ,cast(null as string) is_create_task
    ,cast(null as string) is_success
    ,cast(null as string) material_type
    ,1 pv
    ,c.is_new,c.country
    ,b.ab_code,b.enter_abtest_date
    from enter b
    join act c on b.user_pseudo_id= c.user_pseudo_id and b.enter_abtest_date=c.event_date_hk
)

select
--     a.date,
    a.platform
    ,case when ab_code in ('28653') then '对照组'
         when ab_code in ('28654') then '实验组'
        end code
--     ,a.enter_abtest_date
    -- 付费
    --分层
--     ,a.duration
--     ,a.is_new
--     ,case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
    ,a.event_name
    ,'null' is_success
    ,count(distinct a.device_id) uv
    ,sum(pv) pv
from fe a
group by 1,2,3,4

union all

select
--     a.date,
    a.platform
    ,case when ab_code in ('28653') then '对照组'
         when ab_code in ('28654') then '实验组'
        end code
--     ,a.enter_abtest_date
    -- 付费
    --分层
--     ,a.duration
--     ,a.is_new
--     ,case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
    ,a.event_name
    ,a.is_success
--     ,a.is_success
    ,count(distinct a.device_id) uv
    ,sum(pv) pv
from fe a
where event_name='ai_func_use_result'
group by 1,2,3,4
;
select *
from (select distinct date,ab_code,device_id from fe where event_name='material_click') a
left join (select distinct date,ab_code,device_id from fe where event_name='ai_func_delivery') b
on a.date=b.date and a.device_id=b.device_id
where b.device_id is null

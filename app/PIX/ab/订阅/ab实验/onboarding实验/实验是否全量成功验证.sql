-- 是否还有进入实验的-只有少量进入的
select
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,count(distinct user_pseudo_id) uv
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11374','11375','11376','11377')
      and _table_suffix between '20250821' and '20251006'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-10-05'
group by 1,2


-- 是否看到的是正常的订阅页
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
    ,func.getParams(event_params,'type_id').string_value type_id
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success' )
    and _table_suffix between'20250821' and '20251006'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-10-05'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
)

select
    a.date
    ,case when a.source_0 in ('p_update_first_launch') then 'p_update_first_launch' else 'else' end source_0
    ,case when a.source_0 in ('p_update_first_launch') then source_1 else 'else' end source_1
    ,type_id
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct case when a.event_name ='w_subscription_success' then a.user_pseudo_id  end) sub_success_uv

    ,count(case when a.event_name ='w_subscription_enter' then 1  end) sub_enter_pv

from eves a
group by 1,2,3,4

union all

select
    a.date
    ,case when a.source_0 in ('p_update_first_launch') then 'p_update_first_launch' else 'else' end source_0
    ,'All' source_1
    ,type_id
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct case when a.event_name ='w_subscription_success' then a.user_pseudo_id  end) sub_success_uv

    ,count(case when a.event_name ='w_subscription_enter' then 1  end) sub_enter_pv

from eves a
group by 1,2,3,4

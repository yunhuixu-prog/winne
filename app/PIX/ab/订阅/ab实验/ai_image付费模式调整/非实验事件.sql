with eves as (
select
    event_date
    ,platform,user_pseudo_id
    ,geo.country country
    ,case when geo.country in ('Russia','United States','Brazil','United Kingdom') then geo.country
          when geo.country is null then geo.country
    else 'others' end country_label
    ,app_info.version
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,coalesce(func.getParams(event_params,'SKU').string_value,func.getParams(event_params,'sku').string_value) sku
    ,func.getParams(event_params,'first_func').string_value first_func
    ,func.getParams(event_params,'is_create_task').string_value is_create_task
    ,func.getParams(event_params,'is_success').string_value is_success
    ,func.getParams(event_params,'material_type').string_value material_type
    ,func.getParams(event_params,'prf_material_type').string_value prf_material_type
    ,func.getParams(event_params,'pop_name').string_value pop_name
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2026-02-27','2026-03-05','airbrush',false)
where
    event_name in ('ai_func_delivery','ai_func_use_result','material_exposure','material_click','material_check'
                  ,'w_subscription_enter','w_subscription_click','w_subscription_success'
                  ,'first_func_enter','edit_save','popup_show','popup_click')
)
,user_info as
(
    select
        distinct event_date
        ,is_paying
        ,user_pseudo_id
    from
        dataintegration-265403.temp.winne_temp_day_type_2
    where
        event_date between '2026-02-27' and '2026-03-05'
)

select e.event_date,e.platform,u.is_paying,e.country_label
     ,e.event_name,count(distinct e.user_pseudo_id) uv,count(1) pv
from eves e
left join user_info u
on e.event_date=u.event_date and e.user_pseudo_id=u.user_pseudo_id
where case when event_name='ai_func_delivery' then first_func='ai_filter' -- and is_create_task='1'
           when event_name in ('ai_func_use_result') then first_func='ai_filter'
           when event_name in ('material_exposure','material_click','material_check') then material_type='ai_image'
           when event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success') then source_module='AIGC' and source_0='ai_filter'
           when event_name in ('first_func_enter') then first_func='ai_image'
           when event_name in ('edit_save') then prf_material_type like '%ai_image%'
           when event_name in ('popup_show','popup_click') then first_func='ai_filter' and pop_name='no_free_delivery_popup'
else 1=1 end
group by 1,2,3,4,5

union all

select e.event_date,e.platform,u.is_paying,e.country_label
     ,'ai_func_delivery_more_5' event_name,count(distinct e.user_pseudo_id) uv,count(1) pv
from
(
    select event_date,platform,user_pseudo_id,country_label,count(1) pv
    from eves
    where event_name='ai_func_delivery' and first_func='ai_filter'
    group by 1,2,3,4
) e
left join user_info u
on e.event_date=u.event_date and e.user_pseudo_id=u.user_pseudo_id
where e.pv>5
group by 1,2,3,4,5

union all

select e.event_date,e.platform,u.is_paying,e.country_label
     ,'ai_func_delivery_suc' event_name,count(distinct e.user_pseudo_id) uv,count(1) pv
from eves e
left join user_info u
on e.event_date=u.event_date and e.user_pseudo_id=u.user_pseudo_id
where event_name='ai_func_delivery' then first_func='ai_filter' and is_create_task='1'
group by 1,2,3,4,5
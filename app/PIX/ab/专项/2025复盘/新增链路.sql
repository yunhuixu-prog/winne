select date_trunc(event_date, month) event_date,platform
     ,case when country in ('Brazil', 'United States', 'United Kingdom') then country
        else 'else'
        end country
     ,is_new,is_ua,is_paying,install_days_type
    ,sum(uv) uv
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_click_uv) sub_click_uv
    ,sum(sub_uv) sub_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,sum(sub_month_uv) sub_month_uv
    ,sum(sub_year_uv) sub_year_uv
    ,sum(sub_to_paid_month_uv) sub_to_paid_month_uv
    ,sum(sub_to_paid_year_uv) sub_to_paid_year_uv
    ,round(sum(revenue),2) revenue
from
(
    select event_date
         ,platform
         ,country
         ,is_new,is_ua
         ,is_paying
         ,case when install_days<=1 then '1:1'
               when install_days<=30 then '2:2~30'
               when install_days<=180 then '3:31~180'
               when install_days<=365 then '4:181~365'
               else '5:365+'
         end install_days_type
         ,count(distinct user_pseudo_id) uv
         ,count(distinct case when is_sub_enter=1 then user_pseudo_id end) sub_enter_uv
         ,count(distinct case when is_sub_click=1 then user_pseudo_id end) sub_click_uv
         ,count(distinct case when is_sub=1 then user_pseudo_id end) sub_uv
         ,count(distinct case when is_sub_to_paid=1 then user_pseudo_id end) sub_to_paid_uv
         ,count(distinct case when is_trial=1 then user_pseudo_id end) trial_uv
         ,count(distinct case when is_trial_to_paid=1 then user_pseudo_id end) trial_to_paid_uv
         ,count(distinct case when is_sub_month=1 then user_pseudo_id end) sub_month_uv
         ,count(distinct case when is_sub_year=1 then user_pseudo_id end) sub_year_uv
         ,count(distinct case when is_sub_to_paid_month=1 then user_pseudo_id end) sub_to_paid_month_uv
         ,count(distinct case when is_sub_to_paid_year=1 then user_pseudo_id end) sub_to_paid_year_uv
         ,sum(revenue) revenue
    from dataintegration-265403.temp.winne_temp_day_type_2
    where event_date between '2023-01-01' and '2025-12-31'
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6,7


;
drop table if exists `dataintegration-265403.temp.winne_temp_enter_sub_page_event`;
create table if not exists `dataintegration-265403.temp.winne_temp_enter_sub_page_event` as

with eves_pre as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01','2025-12-31','airbrush',false)
where
    event_name in ('w_subscription_enter')
)
,user_info as
(
    select
        event_date
         ,platform
         ,country
         ,is_new,is_ua
         ,is_paying
        ,user_pseudo_id
    from
        dataintegration-265403.temp.winne_temp_day_type_2
    where
        event_date between '2023-01-01' and '2025-12-31'
        and app_name = 'AirBrush'
)

select u.*,count(e.event_timestamp) sub_enter_pv
from user_info u
left join eves_pre e
on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date and e.platform=u.platform
group by 1,2,3,4,5,6,7
;

select date_trunc(event_date, month) event_date,platform
     ,case when country in ('Brazil', 'United States', 'United Kingdom') then country
        else 'else'
        end country
     ,is_new,is_ua,is_paying
     ,case when coalesce(sub_enter_pv,0)<=5 then coalesce(sub_enter_pv,0) else 999 end sub_enter_pv
     ,sum(uv) uv
from
(
    select event_date,platform,country
            ,is_new,is_ua
            ,is_paying
            ,case when coalesce(sub_enter_pv,0)<=5 then coalesce(sub_enter_pv,0) else 999 end sub_enter_pv
            ,count(distinct user_pseudo_id) uv
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6,7



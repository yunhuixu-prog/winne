-- 首页整体看板
drop table if exists `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`; 
create table if not exists `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` as
with event as 
(
  select
    *
  from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-07-01','2023-12-31', 'beautyplus', false)
)
,
user_info as 
(
    select 
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        event_date_hk between '2023-07-01' and '2023-12-31'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
) 

select
  event_date,
  event_name,
  module_positon,
  module_type,
  module_id,
  content_type,
  content_id,
  time,
  b.platform,
  b.country,
  version,
  is_UA,
  case
    when b.is_new = 1 then 'New'
    else 'Old'
  end as is_new,
  case
    when b.country in ('South Korea', 'Thailand', 'Japan', 'United States') then b.country
    else 'general'
  end as region,
  a.user_pseudo_id,
  pv
from
  (
    select
      event_date
      ,event_name
      ,coalesce(`dataintegration-265403.func`.getParams(event_params,'模块位置').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'模块位置').int_value as string)) module_positon
      ,a.user_pseudo_id
      ,app_info.version
      ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value as module_type
      ,`dataintegration-265403.func`.getParams(event_params,'模块id').string_value as module_id
      ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value as content_type
      ,`dataintegration-265403.func`.getParams(event_params,'内容id').string_value as content_id
      ,coalesce(`dataintegration-265403.func`.getParams(event_params,'time').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'time').int_value as string)) time
      ,count(1) pv
    from
      event a
    where
      event_name in ('home_content_clk_bd','home_content_show_f_bd','homepageappr_bd','home_second_page_appr_bd','home_page_time_bd')
    group by 1,2,3,4,5,6,7,8,9,10
      
  ) a
  join user_info b on a.user_pseudo_id = b.user_pseudo_id and a.event_date = b.event_date_hk

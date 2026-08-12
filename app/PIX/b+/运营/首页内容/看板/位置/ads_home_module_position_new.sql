delete from
  beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new
where
  event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into
  beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new 
(
  app_name,
  event_date,
  event_name,
  module_positon,
  module_type,
  content_type,
  platform,
  is_pay,
  country,
  version,
  is_UA,
  is_new,
  region,
  tab_name,
  uv,
  pv
)
-- drop table if exists `beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new`;
-- create table `beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new` as 

select
  app_name,
  event_date,
  event_name,
  module_positon,
  module_type,
  content_type,
  platform,
  is_pay,
  country,
  version,
  is_UA,
  is_new,
  region,
  cast(tab_name as string) tab_name,
  count(distinct user_pseudo_id) as uv,
  count(*) as pv
from
  beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where
  cast(module_positon as int) > 0
  -- and cast(module_positon as int) < 10
  and event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
  and event_name in ('home_module_show_f_bd','home_content_clk_bd','home_content_show_f_bd')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14

  union all 

  select
  app_name,
  event_date,
  event_name,
  cast(null as string) module_positon,
  'all' module_type,
  'all' content_type,
  platform,
  is_pay,
  country,
  version,
  is_UA,
  is_new,
  region,
  cast(null as STRING) tab_name,
  count(distinct user_pseudo_id) as uv,
  count(*) as pv
from
  beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where
  event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
  and event_name in ('homepageappr_bd', 'home_second_page_appr_bd','discover_second_page_appr_bd','tabbar_clk_bd')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14


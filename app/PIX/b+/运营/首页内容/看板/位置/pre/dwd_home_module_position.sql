delete from
  beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position
where
  event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into
  beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position

-- drop table if exists `beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new`;
-- create table `beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new` as 

with event as (
  select
    *
  from
--     `beautyplus-bc0ed.analytics_153890292.events_*`
--     where  _TABLE_SUFFIX >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y%m%d") }}'
    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)
  )
select
  event_date,
  event_name,
  module_positon,
  module_type,
  content_type,
  platform,
  is_pay,
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
  a.user_pseudo_id
from
  (
    select
      a.event_date as event_date,
      event_name,
      coalesce(func.getParams(event_params,'模块位置').string_value,cast(func.getParams(event_params,'模块位置').int_value as string)) module_positon,
      func.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay,
      geo.country,
      a.user_pseudo_id,
      a.platform,
      version,
      func.getParams(event_params,'模块类型').string_value as module_type,
      func.getParams(event_params,'内容类型').string_value as content_type
    from
      event a
    where
      event_name in ('home_module_show_f_bd','home_content_clk_bd','home_content_show_f_bd','homepageappr_bd','home_second_page_appr_bd')
      
  ) a
  left join (
    select
      user_pseudo_id,
      event_date_hk,
      country,
      is_UA,
      is_new
    from
      `dataintegration-265403.stat.stat_active_advice_detail_d` a
    where
      app_name = 'BeautyPlus'
  ) b on a.user_pseudo_id = b.user_pseudo_id
  and a.event_date = b.event_date_hk

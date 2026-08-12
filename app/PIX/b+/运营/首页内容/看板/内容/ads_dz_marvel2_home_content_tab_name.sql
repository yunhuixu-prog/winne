delete from
  beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name
where
  event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into
  beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name

-- drop table if exists `beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name`;
-- create table `beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name` as

with event as (
  select
    *
  from
--     `beautyplus-bc0ed.analytics_153890292.events_*`
--     where  _TABLE_SUFFIX >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y%m%d") }}'
    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)
  where version>='7.7.114' and platform='IOS'
        and event_name in ('home_template_tab_appr_bd','home_template_tab_clk_bd','home_template_tab_second_page_appr_bd','home_content_clk_bd','home_content_show_f_bd')
  )

select
  event_date,
  event_name,
  tab_name,
  platform,
  version,
  is_UA,
  case
    when b.is_new = 1 then 'New'
    else 'Old'
  end as is_new,
  case when country in ('South Korea','Thailand','Japan','United States') then country
        when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        else 'WW'
  end as region,
  count(distinct a.user_pseudo_id) uv,
  count(1) pv
from
  (
    select
      a.event_date as event_date,
      event_name,
      func.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay,
      a.user_pseudo_id,
      a.platform,
      version,
      func.getParams(event_params,'tab_name').string_value as tab_name,
      func.getParams(event_params,'模块类型').string_value as module_type,
      func.getParams(event_params,'模块ID').string_value as module_id,
      func.getParams(event_params,'内容类型').string_value as content_type
    from
      event a
    where
      case when event_name in ('home_content_clk_bd','home_content_show_f_bd') then func.getParams(event_params,'模块类型').string_value not in ('推荐功能','横幅')
           else 1=1
      end
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
group by 1,2,3,4,5,6,7,8
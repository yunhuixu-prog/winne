with event_pre as
(
  select
    event_date
      ,event_name
      ,user_pseudo_id
      ,app_info.version
      ,geo.country
      ,platform
      ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value as module_type
      ,`dataintegration-265403.func`.getParams(event_params,'模块id').string_value as module_id
      ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value as content_type
      ,`dataintegration-265403.func`.getParams(event_params,'内容id').string_value as content_id
  from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-30','2024-06-18', 'beautyplus', false)
  where event_name in ('home_content_clk_bd','home_content_show_f_bd') and app_info.version>='7.7.110' and platform='IOS'
)
,
user_info as
(
    select
        event_date event_date_hk
        ,platform
--         ,case when country in ('South Korea','Thailand','Japan','United States') then country
--           when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
--           else 'WW'
--         end as country
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        event_date between '2024-05-30' and '2024-06-18'
    group by 1,2,3,4
)

select a.event_date,coalesce(material_name,module_type) material
        ,count(distinct case when event_name='home_content_show_f_bd' then a.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name='home_content_clk_bd' then a.user_pseudo_id end) click_uv
        ,sum(case when event_name='home_content_show_f_bd' then pv end) exposure_pv
        ,sum(case when event_name='home_content_clk_bd' then pv end) click_pv
from
  (
    select
      event_date
      ,event_name
      ,user_pseudo_id
      ,version
      ,platform
      ,module_type
      ,module_id
      ,content_type
      ,content_id
      ,count(1) pv
    from
      event_pre
    where module_type='推荐功能'
    group by 1,2,3,4,5,6,7,8,9
  ) a
  join user_info b on a.user_pseudo_id = b.user_pseudo_id and a.event_date = b.event_date_hk and a.platform = b.platform
  left join dataintegration-265403.temp.dwd_da_homepage_topbar_mapping d
  on a.content_type=d.material_id
group by 1,2
order by 1,2

--BQ跑行为
drop table if exists `beautyplus-bc0ed.temp.dwd_dz_inapp_pop_event`;
create table `beautyplus-bc0ed.temp.dwd_dz_inapp_pop_event` as
with
event as
(
SELECT * FROM
`dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-18', '2023-12-31', 'beautypluscam', false)
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
        event_date_hk between '2023-12-18' and '2023-12-31'
        and app_name='Beauty Plus Cam'
    group by 1,2,3,4,5
)

select m.event_date as event_date_hk,
    m.platform,
    m.event_name,
    m.key_name,
    m.value_name,
    m.user_pseudo_id,
    u.is_new,
    u.is_UA,
    u.country,
    m.pv
from
(
SELECT event_date,
          platform,
          event_name,
          h.key as key_name,
          h.value.string_value as value_name,
          user_pseudo_id,
          count(1) as pv
   FROM event m,
        UNNEST(event_params) as h
--and n.module in ('修图')
   where m.event_name in ('home_page_pop_appr_bd')
     and h.key in ('pop_id')
   group by 1, 2, 3, 4, 5, 6

   union all
   SELECT event_date,
          platform,
          event_name,
          'pop_id' as key_name,
          func.getParams(event_params, 'pop_id').string_value as value_name,
          user_pseudo_id,
          count(1) as pv
   FROM event m --, UNNEST(event_params) as h
--and n.module in ('修图')
   where m.event_name in ('home_page_pop_clk_bd')
     and (func.getParams(event_params, 'type').string_value in ('try_it'))
   group by 1, 2, 3, 4, 5, 6
) m
join user_info u on m.event_date = u.event_date_hk and m.platform=u.platform and m.user_pseudo_id=u.user_pseudo_id



select
    a.event_date_hk,
    a.platform,
    case when a.country in ('South Korea','Thailand','Japan','United States') then country
        when a.country in ('Türkiye','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        else 'WW'
    end as country_label,
    -- a.is_new,
    -- a.is_UA,
    a.key_name,
    a.value_name,
    count(distinct case when event_name in ('home_page_pop_appr_bd') then a.user_pseudo_id end) as exposure_uv,
    sum(case when event_name in ('home_page_pop_appr_bd') then a.pv end) as exposure_pv,
    count(distinct case when event_name in ('home_page_pop_clk_bd') then a.user_pseudo_id end) as click_uv,
    sum(case when event_name in ('home_page_pop_clk_bd') then a.pv end) as click_pv
FROM `beautyplus-bc0ed.temp.dwd_dz_inapp_pop_event` a
group by 1,2,3,4,5
order by 1,2,3,4,5





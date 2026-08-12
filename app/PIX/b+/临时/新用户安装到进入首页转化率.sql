-- 看起来卸载用户似乎都没有活跃数据哎
with a as (
  select
distinct event_date,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-01', '2023-12-31', 'beautyplus', false)
where event_name ='first_open'
),
b as (
  select
distinct event_date,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-01', '2023-12-31', 'beautyplus', false)
where event_name ='homepageappr_bd'
)
select sum(first_open_uv),sum(enter_home_uv),sum(enter_home_uv)/sum(first_open_uv)
from
(
select
a.event_date,count(distinct a.user_pseudo_id) first_open_uv,count(distinct b.user_pseudo_id) enter_home_uv
from a left join b
on a.user_pseudo_id = b.user_pseudo_id and a.event_date=b.event_date
group by 1
)



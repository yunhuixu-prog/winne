

with app_event as
(
    select
        date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) date
        ,case when device.operating_system='Android' then 'ANDROID' else device.operating_system end platform
        ,app_info.version app_version
        ,event_name
        ,user_pseudo_id
        ,count(1) as pv
    from
        -- `beauty-cam-new.analytics.ods_dz_events_tv`('2023-05-01','2023-05-18') a
        -- `beauty-cam-new.analytics.ods_dz_events_tv`('2022-10-01',date_sub(current_date,interval'1'day)) a
--         `beauty-cam-new.analytics.ods_dz_events_tv`('2023-12-26', '2023-12-27') a
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-01', '2023-12-27', 'beautypluscam', false) a
    where
        event_name in ('app_remove')
    group by
        1,2,3,4,5
)
,
user_info as
(
    select
        user_pseudo_id
        ,is_new
        ,is_UA
        ,user_type
        ,country
        ,event_date_hk
        ,platform
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d` u
    where
        -- u.event_date_hk between date'2023-05-01' and date'2023-05-18'
        -- u.event_date_hk between date'2022-10-01' and date_sub(current_date,interval'1'day)
        u.event_date_hk>='2023-12-01'
        and u.event_date_hk<='2023-12-27'
)

select event_date,if(user_pseudo_id_active is null,'null','not null'),count(distinct user_pseudo_id) num
from
(
select
    a.date event_date
    ,a.platform
    ,a.app_version
    ,a.event_name
    ,a.user_pseudo_id
    ,u.user_pseudo_id user_pseudo_id_active
    ,u.is_new
    ,u.is_UA
    ,u.country
    ,a.pv
from
    app_event a
    left join user_info u on    a.user_pseudo_id=u.user_pseudo_id
                                and a.date=u.event_date_hk
                                and a.platform=u.platform
)
group by 1,2
order by 1,2



-- 看起来卸载用户似乎都没有活跃数据哎
with user_en as (
  select
distinct user_pseudo_id
  from `beauty-cam-new.analytics.ods_dz_events_tv`('2023-12-01', '2023-12-27')
where event_name ='user_engagement'
),
app as (
  select
distinct user_pseudo_id
  from `beauty-cam-new.analytics.ods_dz_events_tv`('2023-12-01', '2023-12-27')
where event_name ='app_remove'
)
select
app.event_date,count(1)
from app left join user_en
on app.user_pseudo_id = user_en.user_pseudo_id
where user_en.user_pseudo_id  is null
group by 1









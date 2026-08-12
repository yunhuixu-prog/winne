
select
    a.event_date_hk
    ,count(distinct case when a.is_new=1 then a.user_pseudo_id end) new_users
    ,count(distinct case when a.is_new=0 and b.user_pseudo_id is not null then a.user_pseudo_id end) retention_users
    ,count(distinct case when a.is_new=0 and b.user_pseudo_id is null then a.user_pseudo_id end) retain_users
from
(
    select
        event_date_hk, user_pseudo_id, platform, is_new
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2022-01-01' and '2024-12-31'
        and app_name = 'AirBrush'
) a
left join
(
    select
        event_date_hk, user_pseudo_id, platform, is_new
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date_sub('2022-01-01',interval 1 day) and '2024-12-31'
        and app_name = 'AirBrush'
) b
on date_sub(a.event_date_hk,interval 1 day)=b.event_date_hk and a.user_pseudo_id=b.user_pseudo_id
group by 1
order by 1
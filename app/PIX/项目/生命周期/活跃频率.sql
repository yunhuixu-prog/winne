
-- 流失天数定义
with interval_day as
(
    select event_date_hk,app_name,user_pseudo_id
         ,coalesce(date_diff(next_event_date_hk,event_date_hk,day),999) interval_days
         ,if(next_event_date_hk is null or date_diff(next_event_date_hk,event_date_hk,day)>364,1,0) is_leaving
    from
    (
        select event_date_hk,app_name,user_pseudo_id
             ,lead(event_date_hk) over(partition by app_name,user_pseudo_id order by event_date_hk) next_event_date_hk
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk >= '2024-01-01'
            and app_name in ('BeautyPlus')
    )
    where event_date_hk between '2024-01-01' and '2024-06-30'
)


select a.days
     ,count(distinct case when is_leaving=0 then user_pseudo_id end) retention_uv
     ,count(distinct user_pseudo_id) uv
from
(
    SELECT days
    FROM UNNEST(GENERATE_ARRAY(1, 90)) AS days
) a
cross join interval_day b
where b.interval_days>=a.days
group by 1
order by 1
;

select app_name,interval_days,count(user_pseudo_id) uv
from interval_day
where interval_days!=999
group by 1,2
order by 1,2

;

-- 每月/周活跃天数
    select event_date_hk,app_name,user_pseudo_id,is_new
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2024-01-01' and '2024-06-30'
        and app_name in ('BeautyPlus')



;
with active_day as
(
    select a.event_date_hk event_date_start,a.app_name,a,is_new,a.user_pseudo_id
        ,b.event_date_hk event_date
        ,date_diff(b.event_date_hk,a.event_date_hk,day) days
    from
    (
        select event_date_hk,app_name,user_pseudo_id,is_new
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2024-01-01' and '2024-06-30'
            and app_name in ('BeautyPlus')
            and is_new=1
    ) a
    join
    (
        select event_date_hk,app_name,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2024-01-01' and date_add('2024-06-30',interval 364 day)
            and app_name in ('BeautyPlus')
    ) b
    on a.app_name=b.app_name and a.user_pseudo_id=b.user_pseudo_id
    where b.event_date_hk between date_add(a.event_date_hk,interval 0 day) and date_add(a.event_date_hk,interval 364 day)
)

select app_name,user_pseudo_id,
from active_day




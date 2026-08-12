select
    case when event_date_hk between '2025-05-04' and '2025-05-10' then '0504-0510'
         when event_date_hk between '2025-05-11' and '2025-05-17' then '0511-0517'
    end week
    ,country
    ,count(distinct user_pseudo_id) dnu
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where app_name = 'BeautyPlus' and event_date_hk between '2025-05-04' and '2025-05-17'
    and is_new=1
group by 1,2
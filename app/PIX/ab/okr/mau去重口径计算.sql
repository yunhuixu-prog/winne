with
dau as
(select
date_trunc(event_date_hk, month) as event_month,event_date_hk
, user_pseudo_id, max(country) country
, max(is_new) as is_new, max(is_ua) as is_ua
from (
select
     event_date_hk
           , user_pseudo_id,uuid
           ,  platform
           , country
           ,  is_new
           , user_type
           ,  is_ua
           , user_source
from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk>='2025-11-01'
      and event_date_hk<='2026-01-31'
      and app_name='AirBrush'
)t
group by 1,2,3
),
mau as (select event_month as event_date_hk,user_pseudo_id,country,max(is_new) is_new ,max(is_ua) is_ua
from dau
where event_date_hk between '2025-12-01' and '2026-01-31'
group by 1,2,3
),
pre_mau as (
select DATE_ADD(event_month, INTERVAL 1 MONTH) as event_date_hk,user_pseudo_id,max(is_new) is_new ,max(is_ua) is_ua
from dau
group by 1,2
)

select months
     ,sum(mau) mau
     ,sum(mnu) mnu
     ,sum(mau_non_organic) mau_non_organic
     ,sum(mau_organic) mau_organic
     ,sum(mnu_non_organic) mnu_non_organic
     ,sum(mnu_organic) mnu_organic
     ,sum(pre_mnu_non_organic) pre_mnu_non_organic
     ,sum(pre_mnu_organic) pre_mnu_organic
     ,sum(pre_mou) pre_mou
     ,sum(huiliu) huiliu
from
(
SELECT
    d.event_date_hk months
    ,d.country
    ,COUNT(DISTINCT d.user_pseudo_id) AS mau
    ,COUNT(DISTINCT CASE WHEN d.is_new=1 THEN d.user_pseudo_id END) AS mnu
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' THEN d.user_pseudo_id END) AS mau_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' THEN d.user_pseudo_id END) AS mau_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' and d.is_new=1 THEN d.user_pseudo_id END) AS mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' and d.is_new=1 THEN d.user_pseudo_id END) AS mnu_organic

    ,COUNT(DISTINCT CASE WHEN d.is_new=0 and pre.is_ua='non-Organic' and pre.is_new=1 THEN d.user_pseudo_id END) AS pre_mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new=0 and pre.is_ua='Organic' and pre.is_new=1 THEN d.user_pseudo_id END) AS pre_mnu_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new=0 and pre.is_new=0 THEN d.user_pseudo_id END) AS pre_mou
    ,COUNT(DISTINCT CASE WHEN d.is_new=0 and pre.user_pseudo_id is null THEN d.user_pseudo_id END) AS huiliu
FROM mau d
LEFT JOIN pre_mau pre
ON d.user_pseudo_id = pre.user_pseudo_id and d.event_date_hk = pre.event_date_hk
GROUP BY 1,2
)
GROUP BY 1

;
-- 仅看mau和mnu
select event_month,sum(mau) mau,sum(mnu) mnu
from (
select
     date_trunc(event_date_hk, month) as event_month,country
           , count(distinct user_pseudo_id) mau
           , count(distinct case when is_new=1 then user_pseudo_id end) mnu
from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk>='2025-12-01'
      and event_date_hk<='2026-01-31'
      and app_name='AirBrush'
group by 1,2)
group by 1
;
select
     date_trunc(event_date_hk, month) as event_month
           , count(distinct user_pseudo_id) mau
           , count(distinct case when is_new=1 then user_pseudo_id end) mnu
           , count(distinct case when is_ua='non-Organic' then user_pseudo_id end) mau_non_organic
           , count(distinct case when is_ua='Organic' then user_pseudo_id end) mau_organic
from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk>='2025-12-01'
      and event_date_hk<='2026-01-31'
      and app_name='AirBrush'
group by 1
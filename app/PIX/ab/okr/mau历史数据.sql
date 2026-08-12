--  between '2025-10-01' and '2026-02-28'
select Date,country
    ,sum(MAU) MAU
    ,sum(the_month_ua_new) the_month_ua_new
    ,sum(the_month_or_new) the_month_or_new
    ,sum(last_month_ua_new_retain) last_month_ua_new_retain
    ,sum(last_month_or_new_retain) last_month_or_new_retain
    ,sum(last_month_old_retain) last_month_old_retain
    ,sum(the_month_return) the_month_return
    ,sum(the_month_old_ua) the_month_old_ua
    ,sum(the_month_old_or) the_month_old_or
    ,round(sum(cost),2) cost
from
(
select event_date_hk Date,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
    ,sum(MAU) MAU
    ,sum(the_month_ua_new) the_month_ua_new
    ,sum(the_month_or_new) the_month_or_new
    ,sum(last_month_ua_new_retain) last_month_ua_new_retain
    ,sum(last_month_or_new_retain) last_month_or_new_retain
    ,sum(last_month_old_retain) last_month_old_retain
    ,sum(the_month_old)-sum(last_month_old_retain)-sum(last_month_ua_new_retain)-sum(last_month_or_new_retain) the_month_return
    ,0 the_month_old_ua
    ,0 the_month_old_or
    ,0 cost
from dataintegration-265403.active_retention.ads_dz_mau_part
where event_date_hk >= '2020-01-01' and app_name='AirBrush'
group by 1,2

union all

select event_date_hk Date,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
    ,0 MAU
    ,0 the_month_ua_new
    ,0 the_month_or_new
    ,0 last_month_ua_new_retain
    ,0 last_month_or_new_retain
    ,0 last_month_old_retain
    ,0 the_month_return
    ,sum(case when is_ua='non-Organic' and is_new='Old user' then active_user end) the_month_old_ua
    ,sum(case when is_ua='Organic' and is_new='Old user' then active_user end) the_month_old_or
    ,0 cost
from dataintegration-265403.active_retention.ads_dz_active_retention
where event_date_hk >= '2020-01-01' and app_name='AirBrush' and data='MAU'
group by 1,2

union all

select date_trunc(attributed_date, month) Date,case when first_country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then first_country else 'Others' end country
    ,0 MAU
    ,0 the_month_ua_new
    ,0 the_month_or_new
    ,0 last_month_ua_new_retain
    ,0 last_month_or_new_retain
    ,0 last_month_old_retain
    ,0 the_month_return
    ,0 the_month_old_ua
    ,0 the_month_old_or
    ,sum(amount) cost
from `dataintegration-265403.view.dws_dz_roas_dashboard_monthly_v6`
where attributed_date >= '2020-01-01' and app_name='AirBrush' and attributed_id_type='ua' and is_app=1 and is_skan=0
group by 1,2
)
group by 1,2





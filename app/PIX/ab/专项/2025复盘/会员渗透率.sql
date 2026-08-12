select date_trunc(event_date_hk, month) event_date
    ,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
--     ,country
    ,sum(active_user) dau
    ,sum(case when is_paying='Paying' then active_user end) paying_dau
from dataintegration-265403.active_retention.ads_dz_active_retention
where data='ispaying_dau'
    and app_name='AirBrush'
    and event_date_hk>='2023-01-01'
group by 1,2

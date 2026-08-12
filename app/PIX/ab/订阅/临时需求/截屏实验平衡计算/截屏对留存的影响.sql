
select EXTRACT(YEAR FROM event_date_hk) year
     ,EXTRACT(MONTH FROM event_date_hk) month
     ,platform
     ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
     ,sum(active_user) active_user
     ,sum(retention_user) retention_user
from dataintegration-265403.active_retention.ads_dz_active_retention
where data='ispaying_dau' and app_name='AirBrush' and event_date_hk between '2021-01-01' and '2025-09-30'
group by 1,2,3,4


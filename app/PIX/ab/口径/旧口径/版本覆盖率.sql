select event_date_hk,platform
        ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.16.1') then 'new'
        else 'old' end as version
        ,sum(dau) dau
--         ,sum(retention_dau) retention_dau
--         ,round(sum(retention_dau)/sum(dau),4) retention_ratio
  from dataintegration-265403.active_retention.ads_dz_appversion_dau_rentention
  where event_date_hk>='2025-09-10'
      and app_name in ('AirBrush') --and is_new in ('New user') --and app_version >= '7.1.070'
group by 1,2,3
order by 1,2,3


select
--     attributed_date
    date_trunc(attributed_date, month) event_date
    ,case when first_country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then first_country else 'Others' end country
    ,round(sum(amount),4) amount
--     ,sum(install_uv) install_uv
    ,sum(dnu_next_month_10) dnu_next_month_10
from `dataintegration-265403.view.dws_dz_roas_dashboard_monthly_v6`
where attributed_date >= '2021-01-01' and app='AirBrush' and attributed_id_type='ua'
    and is_app=1 and is_skan=0
group by 1,2
order by 1,2
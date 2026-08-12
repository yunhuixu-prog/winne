-- 24年11月年付费转化率猛降低了一波，暂时不知道为啥；月订阅占比持续上涨的原因：主要来自ios端老用户，分国家分投放都是类似趋势，推测是由于平台资深老用户的占比变高，资深老用户更倾向于订阅月sku
select EXTRACT(YEAR FROM event_date) year
     ,EXTRACT(MONTH FROM event_date) month
     ,platform
     ,is_new
     ,is_ua
     ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
     ,sum(case when sku_type='Monthly' then sub_success_uv end) month_sub_success_uv
     ,sum(case when sku_type='Yearly' then sub_success_uv end) year_sub_success_uv
     ,sum(case when sku_type='Monthly' then sub_to_paid_uv end) month_sub_to_paid_uv
     ,sum(case when sku_type='Yearly' then sub_to_paid_uv end) year_sub_to_paid_uv
from airbrush-1324.stat.dws_airbrush_sub_sku_demension_view
where event_date between '2023-01-01' and '2025-09-30'
group by 1,2,3,4,5,6
;

select event_date
     ,sum(case when sku_type='Monthly' then sub_to_paid_uv end) month_sub_to_paid_uv
     ,sum(case when sku_type='Yearly' then sub_to_paid_uv end) year_sub_to_paid_uv
from airbrush-1324.stat.dws_airbrush_sub_sku_demension_view
where event_date between '2023-01-01' and '2025-09-30'
group by 1
order by 1
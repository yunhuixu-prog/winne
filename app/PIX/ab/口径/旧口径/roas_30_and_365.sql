-- roas30:取投放日期到观测日期差30天的roas
select
--     attributed_date,
  sum(amount) cost
  ,sum(revenue) total_bookings -- 订阅+单购+广告
  ,sum(sub_revenue) sub_revenue -- 订阅
  ,sum(consumables_revenue) consumables_revenue -- 单购
  ,sum(ads_revenue) ads_revenue -- 广告
  ,sum(forecast_revenue) bookings_365 -- 订阅预测365
  ,round((sum(sub_revenue)+sum(consumables_revenue))/sum(amount),2) roas
  ,round((sum(forecast_revenue)+sum(consumables_revenue))/sum(amount),2) roas_365
from dataintegration-265403.view.dws_dz_roas_dashboard_daily_v6
where app_name='AirBrush'
    and date_diff(look_date,attributed_date,day)=30
--     and attributed_date between '2025-01-01' and '2025-06-30'
    and attributed_date between '2024-01-01' and '2024-06-30'
    and attributed_id_type='ua'
-- group by 1
-- order by 1 desc

-- roas365:取最新一天的roas365，这样没到365天的预测是最新的，到了365天的无预测部分了
select
--     attributed_date,
  sum(amount) cost
  ,sum(revenue) total_bookings -- 订阅+单购+广告
  ,sum(sub_revenue) sub_revenue -- 订阅
  ,sum(consumables_revenue) consumables_revenue -- 单购
  ,sum(ads_revenue) ads_revenue -- 广告
  ,sum(forecast_revenue) bookings_365 -- 订阅预测365
  ,round((sum(sub_revenue)+sum(consumables_revenue))/sum(amount),2) roas
  ,round((sum(forecast_revenue)+sum(consumables_revenue))/sum(amount),2) roas_365
from dataintegration-265403.view.dws_dz_roas_dashboard_daily_v6
where app_name='AirBrush'
    and look_date='2025-08-12'
--     and date_diff(look_date,attributed_date,day)=365
--     and attributed_date between '2025-01-01' and '2025-06-30'
    and attributed_date between '2024-01-01' and '2024-06-30'
    and attributed_id_type='ua'
-- group by 1
-- order by 1 desc
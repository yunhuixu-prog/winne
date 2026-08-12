select order_date,sum(revenue),sum(forecast_revenue),round(sum(revenue)/sum(amount),2) roas,round(sum(forecast_revenue)/sum(amount),2) roas_365
from `dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2`
where  user_type ='ua_roas' and Data = 'Daily Report V5'
-- and order_date='2023-12-31'
and Date='2023-01-01' and order_date>Date  -- Date:投放日期，order_date：归因截止日期
and App_Name='BeautyPlus'
group by 1
order by 1


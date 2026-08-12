
select Date,country
    ,round(sum(Bookings),2) Bookings
    ,sum(MAU) MAU
    ,sum(New_paid_users) New_paid_users
    ,round(sum(New_paid_revenue),2) New_paid_revenue
    ,sum(MAU_non_org) MAU_non_org
    ,sum(New_paid_users_non_org) New_paid_users_non_org
    ,round(sum(New_paid_revenue_non_org),2) New_paid_revenue_non_org
    ,sum(MAU_org) MAU_org
    ,sum(New_paid_users_org) New_paid_users_org
    ,round(sum(New_paid_revenue_org),2) New_paid_revenue_org
    ,round(sum(Renew_paid_revenue),2) Renew_paid_revenue

    ,sum(year_Paid_users) year_Paid_users
    ,round(sum(year_Paid_Revenue),2) year_Paid_Revenue
    ,sum(year_New_paid_users) year_New_paid_users
    ,round(sum(year_New_Paid_Revenue),2) year_New_Paid_Revenue
    ,sum(year_Renew_paid_users) year_Renew_paid_users
    ,round(sum(year_Renew_paid_Revenue),2) year_Renew_paid_Revenue
    ,sum(month_Paid_users) month_Paid_users
    ,round(sum(month_Paid_Revenue),2) month_Paid_Revenue
    ,sum(month_New_paid_users) month_New_paid_users
    ,round(sum(month_New_Paid_Revenue),2) month_New_Paid_Revenue
    ,sum(month_Renew_paid_users) month_Renew_paid_users
    ,round(sum(month_Renew_paid_Revenue),2) month_Renew_paid_Revenue

    ,sum(year_prepare_renew_users) year_prepare_renew_users
    ,sum(year_retention_users) year_retention_users
    ,sum(month_prepare_renew_users) month_prepare_renew_users
    ,sum(month_retention_users) month_retention_users
from
(
select Date,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
    ,sum(VAS) Bookings
    ,sum(MAU) MAU
    ,sum(coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0)) New_paid_users
    ,sum(coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0)) New_paid_revenue
--     ,round(sum(New_paid_users)/sum(MAU),4) New_paid_rate
--     ,round(sum(New_paid_revenue)/sum(New_paid_users),2) New_paid_arppu
    ,sum(case when is_UA='non-Organic' then MAU end) MAU_non_org
    ,sum(case when is_UA='non-Organic' then coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0) end) New_paid_users_non_org
    ,sum(case when is_UA='non-Organic' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) New_paid_revenue_non_org
--     ,round(sum(case when is_UA='non-Organic' then New_paid_users end)/sum(case when is_UA='non-Organic' then MAU end),4) New_paid_rate_non_org
--     ,round(sum(case when is_UA='non-Organic' then New_paid_revenue end)/sum(case when is_UA='non-Organic' then New_paid_users end),2) New_paid_arppu_non_org
    ,sum(case when is_UA='Organic' then MAU end) MAU_org
    ,sum(case when is_UA='Organic' then coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0) end) New_paid_users_org
    ,sum(case when is_UA='Organic' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) New_paid_revenue_org
--     ,round(sum(case when is_UA='Organic' then New_paid_users end)/sum(case when is_UA='Organic' then MAU end),4) New_paid_rate_non_org
--     ,round(sum(case when is_UA='Organic' then New_paid_revenue end)/sum(case when is_UA='Organic' then New_paid_users end),2) New_paid_arppu_org
    ,sum(Renew_paid_revenue) Renew_paid_revenue
    ,0 year_Paid_users
    ,0 year_Paid_Revenue
    ,0 year_New_paid_users
    ,0 year_New_Paid_Revenue
    ,0 year_Renew_paid_users
    ,0 year_Renew_Paid_Revenue
    ,0 month_Paid_users
    ,0 month_Paid_Revenue
    ,0 month_New_paid_users
    ,0 month_New_Paid_Revenue
    ,0 month_Renew_paid_users
    ,0 month_Renew_Paid_Revenue
    ,0 year_prepare_renew_users
    ,0 year_retention_users
    ,0 month_prepare_renew_users
    ,0 month_retention_users
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where Date >= '2020-01-01' and App='AirBrush' and (country!='All' or country is null)
group by 1,2

union all

select Date,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
    ,0 Bookings
    ,0 MAU
    ,0 New_paid_users
    ,0 New_paid_revenue
    ,0 MAU_non_org
    ,0 New_paid_users_non_org
    ,0 New_paid_revenue_non_org
    ,0 MAU_org
    ,0 New_paid_users_org
    ,0 New_paid_revenue_org
    ,0 Renew_paid_revenue
    ,sum(case when Subscription_Period='Yearly' then Paid_users end) year_Paid_users
    ,sum(case when Subscription_Period='Yearly' then Vas end) year_Paid_Revenue
    ,sum(case when Subscription_Period='Yearly' then coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0) end) year_New_paid_users
    ,sum(case when Subscription_Period='Yearly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) year_New_Paid_Revenue
    ,sum(case when Subscription_Period='Yearly' then Renew_paid_users end) year_Renew_paid_users
    ,sum(case when Subscription_Period='Yearly' then Renew_paid_revenue end) year_Renew_Paid_Revenue
--     ,round(sum(case when Subscription_Period='Yearly' then Vas end)/sum(case when Subscription_Period='Yearly' then Paid_users end),2) year_paid_arppu
    ,sum(case when Subscription_Period='Monthly' then Paid_users end) month_Paid_users
    ,sum(case when Subscription_Period='Monthly' then Vas end) month_Paid_Revenue
    ,sum(case when Subscription_Period='Monthly' then coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0) end) month_New_paid_users
    ,sum(case when Subscription_Period='Monthly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) month_New_Paid_Revenue
    ,sum(case when Subscription_Period='Monthly' then Renew_paid_users end) month_Renew_paid_users
    ,sum(case when Subscription_Period='Monthly' then Renew_paid_revenue end) month_Renew_Paid_Revenue
--     ,round(sum(case when Subscription_Period='Monthly' then Vas end)/sum(case when Subscription_Period='Monthly' then Paid_users end),2) month_paid_arppu
    ,0 year_prepare_renew_users
    ,0 year_retention_users
    ,0 month_prepare_renew_users
    ,0 month_retention_users
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where Date >= '2020-01-01' and App='AirBrush'
group by 1,2

union all

select month Date,case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country else 'Others' end country
    ,0 Bookings
    ,0 MAU
    ,0 New_paid_users
    ,0 New_paid_revenue
    ,0 MAU_non_org
    ,0 New_paid_users_non_org
    ,0 New_paid_revenue_non_org
    ,0 MAU_org
    ,0 New_paid_users_org
    ,0 New_paid_revenue_org
    ,0 Renew_paid_revenue
    ,0 year_Paid_users
    ,0 year_Paid_Revenue
    ,0 year_New_paid_users
    ,0 year_New_Paid_Revenue
    ,0 year_Renew_paid_users
    ,0 year_Renew_Paid_Revenue
    ,0 month_Paid_users
    ,0 month_Paid_Revenue
    ,0 month_New_paid_users
    ,0 month_New_Paid_Revenue
    ,0 month_Renew_paid_users
    ,0 month_Renew_Paid_Revenue
    ,sum(case when subscription_period='Yearly' then prepare_renew_users end) year_prepare_renew_users
    ,sum(case when subscription_period='Yearly' then retention_users end) year_retention_users
    ,sum(case when Subscription_Period='Monthly' then prepare_renew_users end) month_prepare_renew_users
    ,sum(case when Subscription_Period='Monthly' then retention_users end) month_retention_users
from `dataintegration-265403.view.paid_retention_v`
where month >= '2020-01-01' and app_id='AirBrush' and report='monthly' and offer_method='normal'
group by 1,2
)
group by 1,2

;
select date_trunc(standard_order_date, month) month
  ,sum(case when subscription_period='1-year' then payment_price_usd end) revenue_year
  ,sum(case when subscription_period='1-month' then payment_price_usd end) revenue_month
from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
where event_date_hk='2025-11-23'  and order_status= 3 and app_id='AirBrush'
and standard_order_date between '2021-01-01' and '2025-11-30'
  and date_diff(standard_refund_date,standard_order_date,day) <=10
group by 1
order by 1


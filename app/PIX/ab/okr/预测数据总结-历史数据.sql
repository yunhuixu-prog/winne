select Date,country,platform
    ,round(sum(Bookings),2) Bookings
    ,sum(MAU) MAU
    ,round(sum(New_paid_revenue),2) New_paid_revenue
    ,round(sum(Renew_paid_revenue),2) Renew_paid_revenue
    ,round(sum(Bookings_2),2) Bookings_2

    ,sum(year_Paid_users) year_Paid_users
    ,round(sum(year_Paid_Revenue),2) year_Paid_Revenue
    ,round(sum(year_New_paid_revenue),2) year_New_paid_revenue
    ,round(sum(year_Renew_paid_Revenue),2) year_Renew_paid_Revenue
    ,sum(month_Paid_users) month_Paid_users
    ,round(sum(month_Paid_Revenue),2) month_Paid_Revenue
    ,round(sum(month_New_paid_revenue),2) month_New_paid_revenue
    ,round(sum(month_Renew_paid_Revenue),2) month_Renew_paid_Revenue
from
(
select Date,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
    ,platform
    ,sum(VAS) Bookings
    ,sum(MAU) MAU
    ,sum(coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0)) New_paid_revenue
    ,sum(Renew_paid_revenue) Renew_paid_revenue
    ,0 Bookings_2
    ,0 year_Paid_users
    ,0 year_Paid_Revenue
    ,0 year_New_paid_revenue
    ,0 year_Renew_Paid_Revenue
    ,0 month_Paid_users
    ,0 month_Paid_Revenue
    ,0 month_New_paid_revenue
    ,0 month_Renew_Paid_Revenue
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where Date >= '2020-01-01' and App='AirBrush' and (country!='All' or country is null)
group by 1,2,3

union all

select Date,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
    ,platform
    ,0 Bookings
    ,0 MAU
    ,0 New_paid_revenue
    ,0 Renew_paid_revenue
    ,sum(coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0)+coalesce(Renew_paid_revenue,0)) Bookings_2
    ,sum(case when Subscription_Period='Yearly' then Paid_users end) year_Paid_users
    ,sum(case when Subscription_Period='Yearly' then Vas end) year_Paid_Revenue
    ,sum(case when Subscription_Period='Yearly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) year_New_paid_revenue
    ,sum(case when Subscription_Period='Yearly' then Renew_paid_revenue end) year_Renew_Paid_Revenue
    ,sum(case when Subscription_Period='Monthly' then Paid_users end) month_Paid_users
    ,sum(case when Subscription_Period='Monthly' then Vas end) month_Paid_Revenue
    ,sum(case when Subscription_Period='Monthly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end) month_New_paid_revenue
    ,sum(case when Subscription_Period='Monthly' then Renew_paid_revenue end) month_Renew_Paid_Revenue
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where Date >= '2020-01-01' and App='AirBrush'
group by 1,2,3
)
group by 1,2,3
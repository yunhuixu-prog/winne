-- 月表
select Date,platform,is_UA,country
    ,sum(Bookings) Bookings
    ,sum(New_paid_revenue) New_paid_revenue
    ,sum(Renew_paid_revenue) Renew_paid_revenue
    ,sum(Bookings_Monthly) Bookings_Monthly
    ,sum(Bookings_Yearly) Bookings_Yearly
    ,sum(New_Bookings_Monthly) New_Bookings_Monthly
    ,sum(New_Bookings_Yearly) New_Bookings_Yearly
    ,sum(Renew_Bookings_Monthly) Renew_Bookings_Monthly
    ,sum(Renew_Bookings_Yearly) Renew_Bookings_Yearly
from
(
select
    Date
    ,platform
    ,is_UA
    ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country  -- ,'Mexico','Spain','Canada','Australia'
    ,round(sum(VAS),2) Bookings
    ,round(sum(coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0)),2) New_paid_revenue
    ,round(sum(Renew_paid_revenue),2) Renew_paid_revenue
    ,0 Bookings_Monthly
    ,0 Bookings_Yearly
    ,0 New_Bookings_Monthly
    ,0 New_Bookings_Yearly
    ,0 Renew_Bookings_Monthly
    ,0 Renew_Bookings_Yearly
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where Date >= '2023-01-01' and App='AirBrush' and (country!='All' or country is null)
group by 1,2,3,4
union all
select
    Date
    ,platform
    ,is_UA
    ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
    ,0 Bookings
    ,0 New_paid_revenue
    ,0 Renew_paid_revenue
    ,round(sum(case when Subscription_Period='Monthly' then Vas end),2) Bookings_Monthly
    ,round(sum(case when Subscription_Period='Yearly' then Vas end),2) Bookings_Yearly
    ,round(sum(case when Subscription_Period='Monthly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end),2) New_Bookings_Monthly
    ,round(sum(case when Subscription_Period='Yearly' then coalesce(New_paid_revenue,0)+coalesce(Promotional_paid_revenue,0) end),2) New_Bookings_Yearly
    ,round(sum(case when Subscription_Period='Monthly' then Renew_paid_revenue end),2) Renew_Bookings_Monthly
    ,round(sum(case when Subscription_Period='Yearly' then Renew_paid_revenue end),2) Renew_Bookings_Yearly
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where Date >= '2023-01-01' and App='AirBrush'
group by 1,2,3,4
)
group by 1,2,3,4



-- 日表
select Date,platform,is_UA,country
    ,sum(Bookings) Bookings
    ,sum(New_paid_revenue) New_paid_revenue
    ,sum(Renew_paid_revenue) Renew_paid_revenue
    ,sum(Bookings_Monthly) Bookings_Monthly
    ,sum(Bookings_Yearly) Bookings_Yearly
    ,sum(New_Bookings_Monthly) New_Bookings_Monthly
    ,sum(New_Bookings_Yearly) New_Bookings_Yearly
    ,sum(Renew_Bookings_Monthly) Renew_Bookings_Monthly
    ,sum(Renew_Bookings_Yearly) Renew_Bookings_Yearly
from
(
select
    date_trunc(Date, month) Date
    ,platform
    ,is_UA
    ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
    ,round(sum(VAS),2) Bookings
    ,round(sum(coalesce(New_paid_revenue,0)+coalesce(New_return_revenue,0)+coalesce(Promotional_paid_revenue,0)),2) New_paid_revenue
    ,round(sum(Renewal_revenue),2) Renew_paid_revenue
    ,0 Bookings_Monthly
    ,0 Bookings_Yearly
    ,0 New_Bookings_Monthly
    ,0 New_Bookings_Yearly
    ,0 Renew_Bookings_Monthly
    ,0 Renew_Bookings_Yearly
from dataintegration-265403.subscription.ads_subscription_overview_daily
where Date >= '2023-01-01' and App='AirBrush'
group by 1,2,3,4
union all
select
    date_trunc(Date, month) Date
    ,platform
    ,is_UA
    ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
    ,0 Bookings
    ,0 New_paid_revenue
    ,0 Renew_paid_revenue
    ,round(sum(case when SKU_type='Monthly' then Revenue_cnt end),2) Bookings_Monthly
    ,round(sum(case when SKU_type='Yearly' then Revenue_cnt end),2) Bookings_Yearly
    ,round(sum(case when SKU_type='Monthly' and
                    Subscription_user_type in ('First time paying','First time return paying','Promotional paying') then Revenue_cnt end),2) New_Bookings_Monthly
    ,round(sum(case when SKU_type='Yearly' and
                    Subscription_user_type in ('First time paying','First time return paying','Promotional paying') then Revenue_cnt end),2) New_Bookings_Yearly
    ,round(sum(case when SKU_type='Monthly' and
                    Subscription_user_type in ('Return renewal','Normal renewal') then Revenue_cnt end),2) Renew_Bookings_Monthly
    ,round(sum(case when SKU_type='Yearly' and
                    Subscription_user_type in ('Return renewal','Normal renewal') then Revenue_cnt end),2) Renew_Bookings_Yearly
from dataintegration-265403.subscription.ads_subscription_revenue_daily_02
where Date >= '2023-01-01' and App='AirBrush'
group by 1,2,3,4
)
group by 1,2,3,4

-- 订阅归因表




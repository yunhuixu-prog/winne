select Date
    ,case when Country in ('United States','Brazil','United Kingdom') then Country else 'other' end country
    ,sum(case when Subscription_Period='Yearly' then Paid_users end) paid_users_year
    ,sum(case when Subscription_Period='Yearly' then New_paid_users end) new_paid_users_year
    ,sum(case when Subscription_Period='Yearly' then Renew_paid_users end) renew_paid_users_year
    ,sum(case when Subscription_Period='Monthly' then Paid_users end) paid_users_month
    ,sum(case when Subscription_Period='Monthly' then New_paid_users end) new_paid_users_month
    ,sum(case when Subscription_Period='Monthly' then Renew_paid_users end) renew_paid_users_month
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where Date between '2024-01-01' and '2026-02-01'
    and App='AirBrush'
group by 1,2

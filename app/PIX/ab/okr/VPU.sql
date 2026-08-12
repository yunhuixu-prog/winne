select Date,case when Country in ('United States','Brazil','United Kingdom','All') then country else 'Others' end country
    ,sum(Valid_paid_users) Valid_paid_users
    ,sum(Active_valid_paid_users) Active_valid_paid_users
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where App='AirBrush' and Date>='2022-01-01'
group by 1,2
order by 2,1
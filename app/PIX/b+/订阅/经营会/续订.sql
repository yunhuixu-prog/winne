
select month event_date,subscription_period,platform,country
       ,sum(prepare_renew_users) prepare_renew_users
       ,sum(retention_users) retention_users
from `dataintegration-265403.view.paid_retention_v`
where month between '2025-04-01' and '2025-05-31' and app_id='BeautyPlus'
       and subscription_period in ('Yearly','Monthly') and report='monthly' and offer_method='normal'
group by 1,2,3,4


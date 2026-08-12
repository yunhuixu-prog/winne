
select Date
    ,case when Date between '2024-08-01' and '2024-09-01' then 'p3:24.8-24.9'
          when Date between '2024-05-01' and '2024-06-01' then 'p2:24.5-24.6'
          when Date between '2023-08-01' and '2023-09-01' then 'p1:23.8-23.9'
          when Date between '2023-10-01' and '2023-11-01' then 'p1.5:23.10-23.11'
          when Date between '2024-10-01' and '2024-11-01' then 'p4:24.10-24.11'
    end compare_d
    ,'New' types,platform,is_UA,Subscription_Period
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sum(New_paid_users) paid_users
    ,round(sum(New_paid_revenue)) paid_revenue
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where App='BeautyPlus'
  and Date between '2023-08-01' and '2025-04-01'
  and country!='All'
group by 1,2,3,4,5,6,7

union all

select Date
    ,case when Date between '2024-08-01' and '2024-09-01' then 'p3:24.8-24.9'
          when Date between '2024-05-01' and '2024-06-01' then 'p2:24.5-24.6'
          when Date between '2023-08-01' and '2023-09-01' then 'p1:23.8-23.9'
          when Date between '2023-10-01' and '2023-11-01' then 'p1.5:23.10-23.11'
          when Date between '2024-10-01' and '2024-11-01' then 'p4:24.10-24.11'
    end compare_d
    ,'Renew' types,platform,is_UA,Subscription_Period
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sum(Renew_paid_users) paid_users
    ,round(sum(Renew_paid_revenue)) paid_revenue
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where App='BeautyPlus'
  and Date between '2023-08-01' and '2025-04-01'
  and country!='All'
group by 1,2,3,4,5,6,7

union all

select Date
    ,case when Date between '2024-08-01' and '2024-09-01' then 'p3:24.8-24.9'
          when Date between '2024-05-01' and '2024-06-01' then 'p2:24.5-24.6'
          when Date between '2023-08-01' and '2023-09-01' then 'p1:23.8-23.9'
          when Date between '2023-10-01' and '2023-11-01' then 'p1.5:23.10-23.11'
          when Date between '2024-10-01' and '2024-11-01' then 'p4:24.10-24.11'
    end compare_d
    ,'Promotional' types,platform,is_UA,Subscription_Period
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sum(Promotional_paid_users) paid_users
    ,round(sum(Promotional_paid_revenue)) paid_revenue
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where App='BeautyPlus'
  and Date between '2023-08-01' and '2025-04-01'
  and country!='All'
group by 1,2,3,4,5,6,7

union all

select Date
    ,case when Date between '2024-08-01' and '2024-09-01' then 'p3:24.8-24.9'
          when Date between '2024-05-01' and '2024-06-01' then 'p2:24.5-24.6'
          when Date between '2023-08-01' and '2023-09-01' then 'p1:23.8-23.9'
          when Date between '2023-10-01' and '2023-11-01' then 'p1.5:23.10-23.11'
          when Date between '2024-10-01' and '2024-11-01' then 'p4:24.10-24.11'
    end compare_d
    ,'All' types,platform,is_UA,Subscription_Period
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sum(Paid_users) Paid_users
    ,round(sum(VAS)) paid_revenue
from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
where App='BeautyPlus'
  and Date between '2023-08-01' and '2025-04-01'
  and country!='All'
group by 1,2,3,4,5,6,7

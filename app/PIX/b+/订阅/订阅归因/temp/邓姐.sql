--日报
SELECT  date,sum(AU)DAU,SUM(NU)DNU,SUM(AU_Next_Day_Retention)Next_Day_Retention,SUM(NU_Next_Day_Retention)NU_Next_Day_Retention,round(SUM(sub_gmv),2)sub_gmv
FROM `dataintegration-265403.view.ads_overview_v1`
where App='BeautyPlus Cam'
and date between '2024-01-01'and '2024-12-31'
and report='daily'
group by 1
order by 1


--月报
SELECT  date,
sum(AU)DAU,SUM(NU)DNU,SUM(AU_Next_Day_Retention)Next_Day_Retention,SUM(NU_Next_Day_Retention)NU_Next_Day_Retention,round(SUM(sub_gmv),2)sub_gmv
FROM `dataintegration-265403.view.ads_overview_v1`
where App='BeautyPlus Cam'
and date between '2024-01-01'and '2024-12-31'
and report='monthly'
group by 1
order by 1


select platform
    ,case   when country in ('Japan','United States','South Korea','Vietnam','Thailand','Philippines','Malaysia','Cambodia','Singapore','Laos','Indonesia') then country
            else 'others'
            end country
    ,case   when country in ('Japan','United States','South Korea') then country
            when country in ('Vietnam','Thailand','Philippines','Malaysia','Cambodia','Singapore','Laos','Indonesia') then 'Southeast Asian'
            else 'others'
            end country_group
    ,module
    ,sum(case when event_name in ('Sub enter') then  uv end) sub_enter
    ,sum(case when event_name in ('Sub click') then  uv end) sub_click
    ,sum(case when event_name in ('Sub success') then  uv end) sub_success
    ,sum(case when event_name in ('Sub success to paid') then uv end) sub_success_to_paid
    ,round(sum(case when event_name in ('Sub success to paid') then  Share_Revenue end),2) subscription_bookings
from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_module`
where date between '2024-01-01' and '2024-12-31'
-- where date between '2024-12-31' and '2024-12-31'
    and module != '_'
group by 1,2,3,4
order by 1,2,3,4


select platform
    ,case   when country in ('Japan','United States','South Korea','Vietnam','Thailand','Philippines','Malaysia','Cambodia','Singapore','Laos','Indonesia') then country
            else 'others'
            end country
    ,case   when country in ('Japan','United States','South Korea') then country
            when country in ('Vietnam','Thailand','Philippines','Malaysia','Cambodia','Singapore','Laos','Indonesia') then 'Southeast Asian'
            else 'others'
            end country_group
    ,Category1_sub,Category2_sub
    ,sum(case when event_name in ('Sub enter') then  uv end) sub_enter
    ,sum(case when event_name in ('Sub click') then  uv end) sub_click
    ,sum(case when event_name in ('Sub success') then  uv end) sub_success
    ,sum(case when event_name in ('Sub success to paid') then uv end) sub_success_to_paid
    ,round(sum(case when event_name in ('Sub success to paid') then  Share_Revenue end),2) subscription_bookings
from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_category2`
where date between '2024-01-01' and '2024-12-31'
-- where date between '2024-12-31' and '2024-12-31'
    and edition = 'V5.0'
    and module = 'All'
    and Category1_sub in ('Beauty','Edit','Makeup','Creative Material','Advance')
group by 1,2,3,4,5
order by 1,2,3,4,5



delete from `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4` where user_type ='ua_roas'  ;
insert into `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4`

with result as (
select
 'ua_roas' user_type
 ,'Daily Report V3' data
, App_Name, Platform, Country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID
 , Date, order_date
 , amount, install_uv
 , install_first_time_sub_uv, install_first_time_sub_to_paid_uv
 , install_first_time_sub_to_standard_paid_uv, install_first_sub_is_trial_uv
 , install_first_sub_is_trial_to_paid_uv
 ,install_first_time_trial_to_standard_paid_uv
 , install_first_sub_is_promotional_uv

 , install_first_sub_is_promotional_to_paid_uv
 , install_first_sub_is_promotional_to_standard_paid_uv
 , install_first_sub_is_standard_uv
 , promotional_paid_revenue, standard_paid_revenue
 , sub_revenue, forecast_revenue

 , install_first_consumables_paid_uv
 , consumables_revenue
 , install_first_purchase_uv
 , install_first_paid_uv
 , revenue
from `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4`

union all

select
 'ua_roas' user_type
 ,'Weekly Report V3' data
 , App_Name, Platform, Country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID
 , Date, order_date
 , amount, install_uv
 , install_first_time_sub_uv, install_first_time_sub_to_paid_uv
 , install_first_time_sub_to_standard_paid_uv, install_first_sub_is_trial_uv
 , install_first_sub_is_trial_to_paid_uv
 ,install_first_time_trial_to_standard_paid_uv
 , install_first_sub_is_promotional_uv

 , install_first_sub_is_promotional_to_paid_uv
 , install_first_sub_is_promotional_to_standard_paid_uv
 , install_first_sub_is_standard_uv
 , promotional_paid_revenue, standard_paid_revenue
 , sub_revenue, forecast_revenue

 , install_first_consumables_paid_uv
 , consumables_revenue
 , install_first_purchase_uv
 , install_first_paid_uv
 , revenue
from `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4` a
    join
    (
    select
    Date as date_s,
    IF (DATE_ADD(Date, INTERVAL 8 DAY)<max(order_date) ,DATE_ADD(Date, INTERVAL 8 DAY),max(order_date))  as order_date_r
    FROM
      `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4`
    group by 1
    )b
    on a.Date=b.date_s and a.order_date=b.order_date_r

union all

select
 'ua_roas' user_type
 ,'Monthly Report V3' data
 , App_Name, Platform, Country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID
 , Date, order_date
 , amount, install_uv
 , install_first_time_sub_uv, install_first_time_sub_to_paid_uv
 , install_first_time_sub_to_standard_paid_uv, install_first_sub_is_trial_uv
 , install_first_sub_is_trial_to_paid_uv
 ,install_first_time_trial_to_standard_paid_uv
 , install_first_sub_is_promotional_uv

 , install_first_sub_is_promotional_to_paid_uv
 , install_first_sub_is_promotional_to_standard_paid_uv
 , install_first_sub_is_standard_uv
 , promotional_paid_revenue, standard_paid_revenue
 , sub_revenue, forecast_revenue

 , install_first_consumables_paid_uv
 , consumables_revenue
 , install_first_purchase_uv
 , install_first_paid_uv
 , revenue
from `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4` a
    join
    (
    select
    Date as date_s,
    IF (Date(FORMAT_DATE("%Y-%m-10",DATE_ADD(Date ,INTERVAL 1 MONTH)))<max(order_date) ,Date(FORMAT_DATE("%Y-%m-10",DATE_ADD(Date ,INTERVAL 1 MONTH))),max(order_date))  as order_date_r
    FROM
      `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4`
    group by 1
    )b
    on a.Date=b.date_s and a.order_date=b.order_date_r
)




select
 user_type
 ,data
, App_Name, Platform, Country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID
 , Date, order_date
 , amount, install_uv
 , install_first_time_sub_uv, install_first_time_sub_to_paid_uv
 , install_first_time_sub_to_standard_paid_uv, install_first_sub_is_trial_uv
 , install_first_sub_is_trial_to_paid_uv
 ,install_first_time_trial_to_standard_paid_uv
 , install_first_sub_is_promotional_uv

 , install_first_sub_is_promotional_to_paid_uv
 , install_first_sub_is_promotional_to_standard_paid_uv
 , install_first_sub_is_standard_uv
 , promotional_paid_revenue, standard_paid_revenue
 , sub_revenue, forecast_revenue

 , install_first_consumables_paid_uv
 , consumables_revenue
 , install_first_purchase_uv
 , install_first_paid_uv
 , revenue
from result
where ( 
  CONCAT(App_Name,'-',Platform,'-',Media_Source,'-',Campaign)  not IN (
  SELECT
    CONCAT(App_Name,'-',Platform,'-',Media_Source,'-',Campaign)
  FROM
   `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_only_IOS14`
  GROUP BY
  CONCAT(App_Name,'-',Platform,'-',Media_Source,'-',Campaign) )
or Media_Source is null or Campaign is null
)

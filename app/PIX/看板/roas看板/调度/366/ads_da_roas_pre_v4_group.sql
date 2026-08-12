delete from `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4_group` where 1=1  ;
insert into `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4_group`


--1. 到活动粒度
select
  user_type, REPLACE(data,'V3','V5') as data, App_Name, Platform, Country, Media_Source, Campaign, Date, order_date,
  sum(amount) as amount,
  sum(install_uv) as install_uv,
  sum(install_first_time_sub_uv) as install_first_time_sub_uv,
  sum(install_first_time_sub_to_paid_uv) as install_first_time_sub_to_paid_uv,
  sum(install_first_time_sub_to_standard_paid_uv) as install_first_time_sub_to_standard_paid_uv,
  sum(install_first_sub_is_trial_uv) as install_first_sub_is_trial_uv,
  sum(install_first_sub_is_trial_to_paid_uv) as install_first_sub_is_trial_to_paid_uv,
  sum(install_first_time_trial_to_standard_paid_uv) as install_first_time_trial_to_standard_paid_uv,
  sum(install_first_sub_is_promotional_uv) as install_first_sub_is_promotional_uv,
  sum(install_first_sub_is_promotional_to_paid_uv) as install_first_sub_is_promotional_to_paid_uv,
  sum(install_first_sub_is_promotional_to_standard_paid_uv) as install_first_sub_is_promotional_to_standard_paid_uv,
  sum(install_first_sub_is_standard_uv) as install_first_sub_is_standard_uv,
  sum(promotional_paid_revenue) as promotional_paid_revenue,
  sum(standard_paid_revenue) as standard_paid_revenue,
  sum(sub_revenue) as sub_revenue,
  sum(forecast_revenue) as forecast_revenue,
  null as Campaign_ID,
  null as Ad_Group,
  null as Ad_Group_ID,
  null as Keywords,
  null as Keyword_ID,
  sum(install_first_consumables_paid_uv) as install_first_consumables_paid_uv,
  sum(consumables_revenue) as consumables_revenue,
  sum(install_first_purchase_uv) as install_first_purchase_uv,
  sum(install_first_paid_uv) as install_first_paid_uv,
  sum(revenue) as revenue
from `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4`
where user_type = 'ua_roas'
 group by 1,2,3,4,5,6,7,8,9

 union all

--2. 到关键词粒度
select user_type, REPLACE(data,'V3','V5_keyword') as data, App_Name, Platform, Country, Media_Source, Campaign, Date, order_date,
  amount, install_uv
 , install_first_time_sub_uv, install_first_time_sub_to_paid_uv
 , install_first_time_sub_to_standard_paid_uv, install_first_sub_is_trial_uv
 , install_first_sub_is_trial_to_paid_uv
 ,install_first_time_trial_to_standard_paid_uv
 , install_first_sub_is_promotional_uv

 , install_first_sub_is_promotional_to_paid_uv
 , install_first_sub_is_promotional_to_standard_paid_uv
 , install_first_sub_is_standard_uv
 , promotional_paid_revenue, standard_paid_revenue
 , sub_revenue, forecast_revenue,
  Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID

 , install_first_consumables_paid_uv
 , consumables_revenue
 , install_first_purchase_uv
 , install_first_paid_uv
 , revenue
from `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4`
where user_type = 'ua_roas'


/*
union all


select
  user_type, data, App_Name, Platform, Country, Media_Source, Campaign, Date, order_date,
  sum(amount) as amount,
  sum(install_uv) as install_uv,
  sum(install_first_time_sub_uv) as install_first_time_sub_uv,
  sum(install_first_time_sub_to_paid_uv) as install_first_time_sub_to_paid_uv,
  sum(install_first_time_sub_to_standard_paid_uv) as install_first_time_sub_to_standard_paid_uv,
  sum(install_first_sub_is_trial_uv) as install_first_sub_is_trial_uv,
  sum(install_first_sub_is_trial_to_paid_uv) as install_first_sub_is_trial_to_paid_uv,
  sum(install_first_time_trial_to_standard_paid_uv) as install_first_time_trial_to_standard_paid_uv,
  sum(install_first_sub_is_promotional_uv) as install_first_sub_is_promotional_uv,
  sum(install_first_sub_is_promotional_to_paid_uv) as install_first_sub_is_promotional_to_paid_uv,
  sum(install_first_sub_is_promotional_to_standard_paid_uv) as install_first_sub_is_promotional_to_standard_paid_uv,
  sum(install_first_sub_is_standard_uv) as install_first_sub_is_standard_uv,
  sum(promotional_paid_revenue) as promotional_paid_revenue,
  sum(standard_paid_revenue) as standard_paid_revenue,
  sum(sub_revenue) as sub_revenue,
  sum(forecast_revenue) as forecast_revenue,
  null as Campaign_ID,
  null as Ad_Group,
  null as Ad_Group_ID,
  null as Keywords,
  null as Keyword_ID
  from `dataintegration-265403.roas_dataset_v3.ads_da_roas_pre_v3`
where user_type = 'new_roas'
group by  user_type, data, App_Name, Platform, Country, Media_Source, Campaign, Date, order_date
*/
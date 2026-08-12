delete from  `dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2` where user_type = 'new_roas' ;
insert into  `dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2`

select

 user_type,
 Data,
 case when App_Name in ('AirVid') then 'AirBrush Video' when App_Name in ('BeautyPlus Story') then 'Vmake' else App_Name end App_Name,
 Platform, Country, Media_Source, Campaign, Date, order_date, amount, install_uv,
 sub_revenue, forecast_revenue, install_first_time_sub_uv,

install_first_time_sub_to_paid_uv,install_first_time_sub_to_standard_paid_uv,install_first_sub_is_trial_uv,install_first_sub_is_trial_to_paid_uv,install_first_time_trial_to_standard_paid_uv,
install_first_sub_is_promotional_uv,install_first_sub_is_promotional_to_paid_uv,install_first_sub_is_promotional_to_standard_paid_uv,install_first_sub_is_standard_uv,promotional_paid_revenue,standard_paid_revenue,
Campaign_ID,Ad_Group,Ad_Group_ID,Keywords,Keyword_ID
 , 0 as install_first_consumables_paid_uv
 , 0 as consumables_revenue
 , install_first_time_sub_uv as install_first_purchase_uv
 , install_first_time_sub_to_paid_uv as install_first_paid_uv
 , sub_revenue as revenue
from
(select
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
  'null' as Campaign_ID,
  'null' as Ad_Group,
  'null' as Ad_Group_ID,
  'null' as Keywords,
  'null' as Keyword_ID
  from `dataintegration-265403.roas_dataset_v3.ads_da_roas_pre_v3`
where user_type = 'new_roas'
and  App_Name  in ('AirBrush','AirVid','Beauty Plus Cam','BeautyPlus','BeautyPlus Story','ThemeU','VCUS')
group by  user_type, data, App_Name, Platform, Country, Media_Source, Campaign, Date, order_date
)

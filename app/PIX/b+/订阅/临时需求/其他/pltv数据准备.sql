-- 投放用户付费的太少了，50000条拉不到多少付费的，单拉有付费行为的
-- select AppsFlyer_ID,Attributed_Touch_Date_hk date,1 is_active,0.0 value
-- from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
-- where App_Name in ('BeautyPlus','AirBrush')
--   and Attributed_Touch_Date_hk between date_sub('2024-11-26',interval 210 day) and date_sub('2024-11-26',interval 180 day)
--
-- union all

select AppsFlyer_ID user_id,standard_order_date timestamp,0 is_activation,payment_price_usd value
from `dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v`
where app_id in ('BeautyPlus','AirBrush')
--   and projuct='subscription'
  and Attributed_Touch_Time between date_sub('2024-11-26',interval 210 day) and date_sub('2024-11-26',interval 180 day)

union all

select distinct AppsFlyer_ID user_id,Attributed_Touch_Time timestamp,1 is_activation,0.0 value
from `dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v`
where app_id in ('BeautyPlus','AirBrush')
--   and projuct='subscription'
  and Attributed_Touch_Time between date_sub('2024-11-26',interval 210 day) and date_sub('2024-11-26',interval 180 day)



select uuid user_id,standard_order_date timestamp,0 is_activation,payment_price_usd value
from `dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v`
where app_id in ('BeautyPlus','AirBrush')
--   and projuct='subscription'
  and Attributed_Touch_Time between date_sub('2024-11-26',interval 210 day) and date_sub('2024-11-26',interval 180 day)

union all

select distinct uuid user_id,Attributed_Touch_Time timestamp,1 is_activation,0.0 value
from `dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v`
where app_id in ('BeautyPlus','AirBrush')
--   and projuct='subscription'
  and Attributed_Touch_Time between date_sub('2024-11-26',interval 210 day) and date_sub('2024-11-26',interval 180 day)


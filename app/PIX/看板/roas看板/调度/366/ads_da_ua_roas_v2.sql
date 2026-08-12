-- DS展示表，非iOS14.5以上渠道和新用户数据

delete from  `dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2`  where  user_type ='ua_roas' and Data like '%V5%';
insert into  `dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2`
select
    user_type,
    Data,
    case /*when App_Name in ('AirVid') then 'AirBrush Video' */ when App_Name in ('BeautyPlus Story') then 'BeautyPlus Video' else App_Name end App_Name,
    Platform, Country, Media_Source, Campaign, Date, order_date, amount, install_uv,
    sub_revenue, forecast_revenue, install_first_time_sub_uv,

    install_first_time_sub_to_paid_uv,install_first_time_sub_to_standard_paid_uv,install_first_sub_is_trial_uv,install_first_sub_is_trial_to_paid_uv,install_first_time_trial_to_standard_paid_uv,
    install_first_sub_is_promotional_uv,install_first_sub_is_promotional_to_paid_uv,install_first_sub_is_promotional_to_standard_paid_uv,install_first_sub_is_standard_uv,promotional_paid_revenue,standard_paid_revenue,
    Campaign_ID,Ad_Group,Ad_Group_ID,Keywords,Keyword_ID
    , install_first_consumables_paid_uv
    , consumables_revenue
    , install_first_purchase_uv
    , install_first_paid_uv
    , revenue
from
    `dataintegration-265403.roas_dataset_v4.ads_da_roas_pre_v4_group`
where
    Date>='2020-08-01'
    and App_Name in ('AirBrush','AirVid','Beauty Plus Cam','BeautyPlus','BeautyPlus Story','ThemeU','VCUS','SnapID','AirBrush Video')


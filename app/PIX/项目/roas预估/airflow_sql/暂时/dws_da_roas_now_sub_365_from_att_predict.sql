
-- create or replace table   `dataintegration-265403.temp.dws_dz_roas_now_sub_365_from_att_predict` as

DECLARE mDATE_START DATE DEFAULT '2023-01-01';
DECLARE mDATE_END DATE DEFAULT '2023-01-31';

delete

from    `dataintegration-265403.temp.dws_dz_roas_now_sub_365_from_att_predict`
where date between mDATE_START and mDATE_END;

insert into   `dataintegration-265403.temp.dws_dz_roas_now_sub_365_from_att_predict`
with fore as (

select
    'new' types,app_id,platform,country,is_UA
  /*  ,Media_Source, Campaign, Keywords
    ,Site_ID, IOS_OS_Version*/
    ,install_date
    ,order_date
    ,subscription_period
    ,case
        when subscription_period =  '1-month' then date_add(order_date,interval 1 month)
        when subscription_period =  '3-month' then date_add(order_date,interval 3 month)
        when subscription_period =  '1-week' then date_add(order_date,interval 1 week)
         -- 若未来有新的sku，需要再补
    end end_order_date
    ,sku_is_trial
    ,order_status
    ,a.order_id
    ,b.uuid
    ,a.payment_price_usd
    ,a.num_cr
    ,a.agg_rate
    ,a.revenue
from
 `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_id_v4` a
left join dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v b
on a.order_id=b.order_id and a.order_date=b.order_date
where install_date between date_sub(mDATE_START,interval 365 day) and mDATE_END
)

select
   app_id,platform,country,is_UA
    /*,Media_Source,Campaign,Keywords,Site_ID,IOS_OS_Version*/
    ,install_date ,order_date2 date,sub_event
    ,subscription_period,sku_is_trial
    ,uv,revenue

from
(
    select
    app_id,platform,country,is_UA
   /* ,Media_Source,Campaign,Keywords,Site_ID,IOS_OS_Version*/
    ,install_date,order_date,sub_event
    ,subscription_period,sku_is_trial,uv,revenue
    ,case
        when subscription_period =  '1-month' then date_add(order_date,interval 1 month)
        when subscription_period =  '3-month' then date_add(order_date,interval 3 month)
        when subscription_period =  '1-week' then date_add(order_date,interval 1 week)
         -- 若未来有新的sku，需要再补
    end end_order_date
from   fore
/*
where
    install_date = '2021-11-20'
    and app_id ='AirBrush'
   and country = 'United States (the)'
   and Platform = 'IOS'
   and  subscription_period = '1-month'*/
)t,unnest(generate_date_array(order_date,date_sub(end_order_date,interval 1 day))) as order_date2
where order_date2  < current_date
 and  order_date2 < date_add(install_date,interval 365 day)  -- 当order_date  小于  install date +1 年时 ,取上述；当 大于 install date +1 年时 ，没有预测365收入




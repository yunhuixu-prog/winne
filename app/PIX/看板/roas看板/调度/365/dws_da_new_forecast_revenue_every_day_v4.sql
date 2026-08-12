
-- create or replace table   `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4` as


delete

from    `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4`
where 1=1;

insert into   `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4`
with fore as (

select
    app_id,platform,country,is_UA
  /*  ,Media_Source, Campaign, Keywords
    ,Site_ID, IOS_OS_Version*/
    ,install_date
    ,order_date
    ,'forecast_revenue' sub_event
    ,subscription_period
    ,sku_is_trial
    ,count(distinct original_order_id )uv  --包含trial + 付费的用户数
    ,sum(revenue)revenue
from
 `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_id_v4`
 group by 1,2,3,4,5,6,7,8,9

)

select
   app_id,platform,country,is_UA
    /*,Media_Source,Campaign,Keywords,Site_ID,IOS_OS_Version*/
    ,install_date,order_date2 order_date,sub_event
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
 and  order_date2 < date_add(install_date,interval 1 year)  -- 当order_date  小于  install date +1 年时 ,取上述；当 大于 install date +1 年时 ，没有预测365收入




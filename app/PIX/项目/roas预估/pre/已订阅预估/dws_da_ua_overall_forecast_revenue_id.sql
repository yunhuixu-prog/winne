with LTV as
(
    -- 不区分观测日期，更新时间都是最新调度时间
    select original_order_id,max(LTV365_actual_forecast) LTV365_actual_forecast,max(LTV_actual_forecast) LTV_actual_forecast
    from `dataintegration-265403.user_ltv.dws_dz_new_ltv_id`
    group by 1
)
,
forecast_LTV as
(
    select app_id,country,platform,subscription_period --,subscription_user_type
--          ,round(sum(LTV365_actual_forecast)/count(distinct uuid),4) LTV365_actual_forecast  -- 订单开始之后的365天，不是投放后的365天
         ,round(sum(LTV_actual_forecast)/count(1),4) LTV_actual_forecast
    from `dataintegration-265403.user_ltv.dws_dz_new_ltv_id`
    where date between DATE_SUB('2024-04-01', INTERVAL 90 DAY) and '2024-04-01'
            and is_UA='non-Organic'  -- new roas看板这里要注释掉
    group by 1,2,3,4
)


-- select subscription_user_type,count(1),count(case when LTV_actual_forecast=0 then 1 end)
-- -- select *
-- from
-- (
select a.*
     ,num_cr*coalesce(t.LTV_actual_forecast,0) LTV_actual_forecast
from `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4` a
join LTV t
on a.original_order_id = t.original_order_id

union all

-- 匹配不上original_order_id的取相同国家平台订阅期限
select a.*
     ,num_cr*coalesce(f.LTV_actual_forecast,0) LTV_actual_forecast
from `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4` a
left join LTV t
on a.original_order_id = t.original_order_id
left join forecast_LTV f
on a.app_id=f.app_id and a.platform=f.platform and a.country=f.country
--        and a.subscription_user_type=f.subscription_user_type -- 续费的话肯定匹配不上
       and a.subscription_period=f.subscription_period
where t.original_order_id is null

-- 匹配不上相同国家平台订阅期限的算了先这样吧
-- )
-- where LTV_actual_forecast = 0
-- group by 1




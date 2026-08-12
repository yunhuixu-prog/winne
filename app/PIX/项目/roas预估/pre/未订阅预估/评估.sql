select Attributed_Touch_Date,date,sub_status
        ,sum(user_num) user_num
        ,sum(sub_365_user_num) sub_365_user_num
        ,round(sum(sub_revenue_365),2) sub_revenue_365
        ,round(sum(sub_revenue_now),2) sub_revenue_now
        ,round(sum(future_forest_revenue),2) future_forest_revenue_365
        ,round((sum(future_forest_revenue)+sum(sub_revenue_now)),2) sub_forest_revenue_365
from
(
    select Attributed_Touch_Date,cast(date as date) date
         ,case when sub_now>0 and is_sub_now=1 then '当前正订阅'
               when sub_now>0 and is_sub_now=0 then '订阅过但当前未订阅'
               when sub_now=0 then '未订阅'
         end sub_status
         ,count(distinct user_pseudo_id) user_num
         ,count(distinct case when sub_365>0 then user_pseudo_id end) sub_365_user_num
         ,sum(sub_revenue_365) sub_revenue_365
         ,sum(sub_revenue_now) sub_revenue_now
         ,0.0 future_forest_revenue
--     from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
--     from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all
    where Attributed_Touch_Date between '2023-01-01' and '2023-02-20'
    group by 1,2,3

    union all
    -- 当前预测值-ua
    select install_date Attributed_Touch_Date,order_date date,'当前正订阅' sub_status
            ,0 user_num
            ,0 sub_365_user_num
            ,0.0 sub_revenue_365
            ,0.0 sub_revenue_now
            ,sum(revenue) future_forest_revenue
    from `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_every_day_v4`
    where sub_event='forecast_revenue'
      and app_id='BeautyPlus'
      and subscription_period not in ('inapp')
      and install_date between '2023-01-01' and '2023-02-20'
      and order_date>=install_date
    group by 1,2,3
)
where Attributed_Touch_Date='2023-01-01'
group by 1,2,3
-- having sum(user_num)>0
order by 1,2,3
;
select days,sub_status
        ,round(sum(user_num)/count(distinct Attributed_Touch_Date),2) user_num
        ,round(sum(sub_365_user_num)/count(distinct Attributed_Touch_Date),2) sub_365_user_num
        ,round(sum(sub_revenue_365)/count(distinct Attributed_Touch_Date),2) sub_revenue_365
        ,round(sum(sub_revenue_now)/count(distinct Attributed_Touch_Date),2) sub_revenue_now
        ,round(sum(future_forest_revenue_365)/count(distinct Attributed_Touch_Date),2) future_forest_revenue_365
        ,round(sum(sub_forest_revenue_365)/count(distinct Attributed_Touch_Date),2) sub_forest_revenue_365
from
(
    select Attributed_Touch_Date,date_diff(date,Attributed_Touch_Date,DAY) days,sub_status
            ,sum(user_num) user_num
            ,sum(sub_365_user_num) sub_365_user_num
            ,round(sum(sub_revenue_365),2) sub_revenue_365
            ,round(sum(sub_revenue_now),2) sub_revenue_now
            ,round(sum(future_forest_revenue),2) future_forest_revenue_365
            ,round((sum(future_forest_revenue)+sum(sub_revenue_now)),2) sub_forest_revenue_365
    from
    (
        select Attributed_Touch_Date,cast(date as date) date
             ,case when sub_now>0 and is_sub_now=1 then '当前正订阅'
                   when sub_now>0 and is_sub_now=0 then '订阅过但当前未订阅'
                   when sub_now=0 then '未订阅'
             end sub_status
             ,count(distinct user_pseudo_id) user_num
             ,count(distinct case when sub_365>0 then user_pseudo_id end) sub_365_user_num
             ,sum(sub_revenue_365) sub_revenue_365
             ,sum(sub_revenue_now) sub_revenue_now
             ,0.0 future_forest_revenue
    --     from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    --     from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre
        from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all
        where Attributed_Touch_Date between '2023-01-01' and '2023-02-20'
        group by 1,2,3

        union all
        -- 当前预测值-ua
        select install_date Attributed_Touch_Date,order_date date,'当前正订阅' sub_status
                ,0 user_num
                ,0 sub_365_user_num
                ,0.0 sub_revenue_365
                ,0.0 sub_revenue_now
                ,sum(revenue) future_forest_revenue
        from `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_every_day_v4`
        where sub_event='forecast_revenue'
          and app_id='BeautyPlus'
          and subscription_period not in ('inapp')
          and install_date between '2023-01-01' and '2023-02-20'
          and order_date>=install_date
        group by 1,2,3
    )
    group by 1,2,3
    -- having sum(user_num)>0
)
where user_num>0
group by 1,2
order by 1,2





-- 当前预测值-new
select install_date,order_date,sum(revenue)
from `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4`
where sub_event='forecast_revenue'
  -- and app_id='BeautyPlus'
  and subscription_period not in ('inapp')
  -- and install_date between '2023-01-01' and '2023-02-20'
  and install_date = '2023-01-31' and order_date>=install_date
group by 1,2
order by 1,2



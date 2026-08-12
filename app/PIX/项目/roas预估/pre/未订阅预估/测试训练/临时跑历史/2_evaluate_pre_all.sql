DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-01-03');
DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-01-31');

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all as


delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all


with goal_users as
(
    select App_Name,Platform,Attributed_Touch_Date,AppsFlyer_ID,max(user_pseudo_id) user_pseudo_id,max(region) region
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users
    group by 1,2,3,4
)
,
sub_event as
(
    select a.Attributed_Touch_Date,a.user_pseudo_id,a.region,a.Platform,b.standard_order_date,b.product,b.order_id,b.payment_price_usd,b.standard_order_expire_date,b.order_status
    from goal_users a
    left join dataintegration-265403.temp.temp_roi_predict_sub_lable_pre b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.AppsFlyer_ID=a.AppsFlyer_ID
)

select a.date,b.Attributed_Touch_Date
--          ,a.AppsFlyer_ID
     ,b.user_pseudo_id
    ,max(b.region) region
    ,max(b.Platform) platform
    ,count(distinct case when b.standard_order_date<=a.date and product='subscription' then b.order_id end) sub_now  -- 截止目前用户是否有过订阅（包括试用）
    ,IFNULL(round(sum(case when b.standard_order_date<=a.date and product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_now  -- 截止目前用户订阅收入
    ,max(case when b.standard_order_date<=a.date and standard_order_expire_date>=a.date and b.product='subscription' then 1 else 0 end) is_sub_now  -- 当前用户是否订阅状态（包括试用）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.order_id end) sub_365  -- 投放一年内是否有过订阅行为（包括试用）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,interval 1 year) and b.order_status!=0 and b.product='subscription' then b.order_id end) sub_no_trial_365  -- 投放一年内是否有过订阅行为（不包括试用）
    ,IFNULL(round(sum(case when b.standard_order_date < date_add(b.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_365
from (select distinct event_date_hk date from `dataintegration-265403.stat.stat_active_advice_detail_d` where event_date_hk between mDATE_START and mDATE_END) a
cross join sub_event b
where a.date>=b.Attributed_Touch_Date
group by 1,2,3







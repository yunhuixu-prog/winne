DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub as


delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub


with goal_users as
(
    select types,App_Name,Platform,Attributed_Touch_Date,id,max(user_pseudo_id) user_pseudo_id,max(region) region
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    group by 1,2,3,4,5
)
,
sub_event as
(
    select a.types,a.Attributed_Touch_Date,a.user_pseudo_id,a.region,a.Platform,b.standard_order_date,b.product,b.order_id,b.payment_price_usd,b.standard_order_expire_date,b.order_status,b.subscription_period
    from goal_users a
    left join dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.AppsFlyer_ID=a.id
    where types='ua'

    union all

    select a.types,a.Attributed_Touch_Date,a.user_pseudo_id,a.region,a.Platform,b.standard_order_date,b.product,b.order_id,b.payment_price_usd,b.standard_order_expire_date,b.order_status,b.subscription_period
    from goal_users a
    left join dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.uuid=a.id
    where types='new' and (b.Attributed_Touch_Time=a.Attributed_Touch_Date or b.Attributed_Touch_Time is null)  -- 以uuid为口径的新用户
--     where types='new' and (b.standard_order_date>=a.Attributed_Touch_Date or b.standard_order_date is null)
)

select b.types,a.date,b.Attributed_Touch_Date
--          ,a.AppsFlyer_ID
     ,b.user_pseudo_id
    ,max(b.region) region
    ,max(b.Platform) platform
    ,count(distinct case when b.standard_order_date<=a.date and product='subscription' then b.order_id end) sub_now  -- 截止目前用户是否有过订阅（包括试用）
    ,IFNULL(round(sum(case when b.standard_order_date<=a.date and product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_now  -- 截止目前用户订阅收入
    ,max(case when b.standard_order_date<=a.date and standard_order_expire_date>=a.date and b.product='subscription' then 1 else 0 end) is_sub_now  -- 当前用户是否订阅状态（包括试用）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.product='subscription' then b.order_id end) sub_365  -- 投放一年内是否有过订阅行为（包括试用）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.order_status!=0 and b.product='subscription'  then b.order_id end) sub_no_trial_365  -- 投放一年内是否有过订阅行为（不包括试用）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.order_status!=0 and b.product='subscription' and b.subscription_period='1-year' then b.order_id end) sub_no_trial_year_365  -- 投放一年内是否有过订阅行为（不包括试用）（限制年订阅）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.order_status!=0 and b.product='subscription' and b.subscription_period='1-month' then b.order_id end) sub_no_trial_month_365  -- 投放一年内是否有过订阅行为（不包括试用）（限制月订阅）
    ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.order_status!=0 and b.product='subscription' and b.subscription_period not in ('1-year','1-month') then b.order_id end) sub_no_trial_other_365  -- 投放一年内是否有过订阅行为（不包括试用）（限制其他订阅）
    ,IFNULL(round(sum(case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 365 DAY) and b.product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_365
from
(
    select distinct event_date_hk date
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
) a
cross join sub_event b
where a.date between b.Attributed_Touch_Date and DATE_ADD(Attributed_Touch_Date, INTERVAL 364 DAY)
group by 1,2,3,4







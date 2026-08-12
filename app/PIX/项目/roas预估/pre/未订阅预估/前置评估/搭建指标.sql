
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input as

delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input where date='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input

-- 0:目标用户(限制投放当天活跃，后续用户id维表出来了就没有这个限制了)
-- dataintegration-265403.temp.temp_roi_predict_sub_lable_pre，后续改个名字规划一下

with goal_users as
(
    select a.App_Name,UPPER(a.Platform) Platform,a.Attributed_Touch_Date,a.AppsFlyer_ID,s.user_pseudo_id,s.uuid
        ,max(case when country in ('United States','Japan','United Kingdom','South Korea','Thailand') then country else 'else' end) region  -- 换成全量表后可以再决定需不需要
    from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info` a
    join `dataintegration-265403.stat.stat_active_advice_detail_d` s  -- 后续变为用户id维表，注意时间要不要改
        on s.app_name=a.App_Name
          AND s.platform=UPPER(a.Platform)
          AND s.AppsFlyer_ID=a.AppsFlyer_ID
          and s.event_date_hk=a.Attributed_Touch_Date
    where a.App_Name='BeautyPlus' and a.Attributed_Touch_Date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and a.Attributed_Touch_Date>=date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 1 year)
    group by 1,2,3,4,5,6
)
,
is_sub as
(
    select a.Attributed_Touch_Date
--          ,a.AppsFlyer_ID
         ,a.user_pseudo_id
        ,max(a.region) region
        ,max(a.Platform) platform
        ,count(distinct case when b.standard_order_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' and product='subscription' then b.order_id end) sub_now  -- 截止目前用户是否有过订阅（包括试用）
        ,IFNULL(round(sum(case when b.standard_order_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' and product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_now  -- 截止目前用户订阅收入
        ,max(case when b.standard_order_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' and standard_order_expire_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' and b.product='subscription' then 1 else 0 end) is_sub_now  -- 当前用户是否订阅状态（包括试用）
        ,count(distinct case when b.standard_order_date < date_add(a.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.order_id end) sub_365  -- 投放一年内是否有过订阅行为（包括试用）
        ,count(distinct case when b.standard_order_date < date_add(a.Attributed_Touch_Date,interval 1 year) and b.order_status!=0 and b.product='subscription' then b.order_id end) sub_no_trial_365  -- 投放一年内是否有过订阅行为（不包括试用）
        ,IFNULL(round(sum(case when b.standard_order_date < date_add(a.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_365
    from goal_users a
    left join dataintegration-265403.temp.temp_roi_predict_sub_lable_pre b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.AppsFlyer_ID=a.AppsFlyer_ID
          and b.uuid=a.uuid
    group by 1,2
)
,
-- 1:用户画像指标及firebase汇总
-- with user_profile as
-- (
--     select
--     from `dataintegration-265403.stat.stat_active_advice_detail_d`  -- 后续换成全量表
--     where event_date_hk='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
-- )
-- ,
-- 2:素材指标搭建及其他行为指标
other as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave
    where date ='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
-- 3:行为指标构建
behave as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_behave
    where date ='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)

select cast('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' as date) as date
    ,i.*
--     ,u.*except(user_pseudo_id)
    ,c.*except(user_pseudo_id,date,Attributed_Touch_Date)
    ,o.*except(user_pseudo_id,date,Attributed_Touch_Date)
from is_sub i
-- left join user_profile u
-- on i.user_pseudo_id=u.user_pseudo_id
left join other c
on i.user_pseudo_id=c.user_pseudo_id and i.Attributed_Touch_Date=c.Attributed_Touch_Date
left join behave o
on i.user_pseudo_id=o.user_pseudo_id and i.Attributed_Touch_Date=o.Attributed_Touch_Date

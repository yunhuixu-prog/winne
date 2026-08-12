DECLARE mDATE_START DATE DEFAULT '2024-05-01';
DECLARE mDATE_END DATE DEFAULT '2024-05-01';

-- drop table if exists beautyplus-bc0ed.temp.temp_age_gender_user_behave_and_sub;
-- create table beautyplus-bc0ed.temp.temp_age_gender_user_behave_and_sub as
delete from beautyplus-bc0ed.temp.temp_age_gender_user_behave_and_sub where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.temp_age_gender_user_behave_and_sub

with
event_pre_raw as
(
   select
        app_name
        ,event_date
        ,user_pseudo_id
        ,`dataintegration-265403.func`.getParams(event_params,'年龄').string_value age
        ,`dataintegration-265403.func`.getParams(event_params,'性别').string_value gender
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-01', '2024-05-01', 'beautyplus', false)
    where event_name in ('selfie_userproperties_bd'
                        )
)
,
uuid_firebase_id as
(
    select key,uuid
    from `dataintegration-265403.stat.dmi_dz_idmapping`
)
,
goal_users as
(
    select distinct app_name,event_date event_date_hk,user_pseudo_id,uuid,age,gender
    from
    (
        select app_name,event_date,user_pseudo_id,max(age) age,max(gender) gender
        from event_pre_raw
        group by 1,2,3
    ) gu
    left join uuid_firebase_id uu
    on gu.user_pseudo_id=uu.key
)
,
his_sub_event as
(
    -- 该死这个表2024年之前没有数
    select event_date_hk,app_id app_name,uuid,if(current_trial_day is not null,1,0) is_current_trial
            ,current_trial_day
            ,is_current_subscription_cancelled
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times
            ,cancel_subscription_times
            ,refund_subscription_times
            ,promotional_paying_times
    from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
    where event_date_hk>='2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus')

    union all

    select event_date_hk,app_id app_name,uuid,if(current_trial_day is not null,1,0) is_current_trial
            ,current_trial_day
            ,is_current_subscription_cancelled
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times
            ,cancel_subscription_times
            ,refund_subscription_times
            ,promotional_paying_times
    from `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp`
    where event_date_hk<'2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus')
)
,
sub_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 90 day)  -- 最多预测未来一年
        and app_id in('BeautyPlus')
        and order_status in (1,2)
    group by 1,2,3
)
,
future_sub_pay as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) sub_90  -- 90天内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then 1 end) sub_30  -- 30天内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) sub_7  -- 7天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then sub_revenue end) sub_revenue_90  -- 90天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then sub_revenue end) sub_revenue_30  -- 30天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then sub_revenue end) sub_revenue_7  -- 7天内是否有过订阅付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join sub_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY)
    group by 1,2,3
)
,
future_active as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.user_pseudo_id
        ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) active_90  -- 90天内是否有过活跃
        ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then 1 end) active_30  -- 30天内是否有过活跃
        ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) active_7  -- 7天内是否有过活跃
        ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 1 DAY) then 1 end) active_1  -- 1天内是否有过活跃
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join `dataintegration-265403.stat.stat_active_advice_detail_d` b
    where b.app_name = 'BeautyPlus' and b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY)
    group by 1,2,3
)

select date,app_name,age,gender
    ,count(distinct user_pseudo_id) uv
    ,count(distinct case when is_current_pay=1 then user_pseudo_id end) pay_uv
    ,count(distinct case when sub_90>0 then user_pseudo_id end) sub_pay_90_uv
    ,count(distinct case when active_7>0 then user_pseudo_id end) active_7_uv
    ,count(distinct case when active_1>0 then user_pseudo_id end) active_1_uv
from
(
select g.event_date_hk date,g.app_name,g.user_pseudo_id
        -- g
        ,max(age) age
        ,max(gender) gender
        ,max(is_current_trial) is_current_trial
        ,max(current_trial_day) current_trial_day
        ,max(is_current_subscription_cancelled) is_current_subscription_cancelled
        ,max(is_current_pay) is_current_pay
        ,max(past_sub_times) past_sub_times
        ,max(trial_times) trial_times
        ,max(cancel_subscription_times) cancel_subscription_times
        ,max(refund_subscription_times) refund_subscription_times
        ,max(promotional_paying_times) promotional_paying_times
        -- 预测指标
        ,max(sub_90) sub_90
        ,max(sub_30) sub_30
        ,max(sub_7) sub_7
        ,max(sub_revenue_90) sub_revenue_90
        ,max(sub_revenue_30) sub_revenue_30
        ,max(sub_revenue_7) sub_revenue_7
        ,sum(fac.active_90) active_90,sum(fac.active_30) active_30,sum(fac.active_7) active_7,sum(fac.active_1) active_1
from
(
    select g.event_date_hk,g.app_name,g.user_pseudo_id,g.uuid,g.age,g.gender
         ,coalesce(is_current_trial,0) is_current_trial
         ,current_trial_day
         ,is_current_subscription_cancelled
         ,coalesce(is_current_pay,0) is_current_pay
         ,coalesce(past_sub_times,0) past_sub_times
         ,coalesce(trial_times,0) trial_times
         ,coalesce(cancel_subscription_times,0) cancel_subscription_times
         ,coalesce(refund_subscription_times,0) refund_subscription_times
         ,coalesce(promotional_paying_times,0) promotional_paying_times
         -- 预测指标
         ,coalesce(sub_90,0) sub_90
         ,coalesce(sub_30,0) sub_30
         ,coalesce(sub_7,0) sub_7
         ,coalesce(sub_revenue_90,0) sub_revenue_90
         ,coalesce(sub_revenue_30,0) sub_revenue_30
         ,coalesce(sub_revenue_7,0) sub_revenue_7
    from goal_users g
    left join his_sub_event hs
    on g.event_date_hk=hs.event_date_hk and g.app_name=hs.app_name and g.uuid=hs.uuid
    left join future_sub_pay fs
    on g.event_date_hk=fs.event_date_hk and g.app_name=fs.app_name and g.uuid=fs.uuid
) g
left join future_active fac
on g.event_date_hk=fac.event_date_hk and g.app_name=fac.app_name and g.user_pseudo_id=fac.user_pseudo_id
group by 1,2,3
)
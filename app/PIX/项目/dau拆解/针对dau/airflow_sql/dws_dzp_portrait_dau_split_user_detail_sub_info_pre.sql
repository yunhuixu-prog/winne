-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=365+14)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

drop table if exists dataintegration-265403.temp.dws_dzp_portrait_dau_split_user_detail_sub_info_pre;
create table dataintegration-265403.temp.dws_dzp_portrait_dau_split_user_detail_sub_info_pre as

with goal_users as
(
    select event_date_hk,app_name,user_pseudo_id,uuid,max(country) country,max(is_UA) is_UA,max(is_new) is_new,max(app_version) app_version
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4
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
    where event_date_hk>='2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus','AirBrush')

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
    where event_date_hk<'2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus','AirBrush')
)
,
sub_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)
        and app_id in('BeautyPlus','AirBrush')
        and order_status in (1,2)
    group by 1,2,3
)
,
credit_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) credit_revenue
    from `dataintegration-265403.purchase.dwd_da_purchase_daily`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)
        and app_id in('BeautyPlus','AirBrush')
        and order_status in (1,2)
    group by 1,2,3
)
,
ad_event as
(
    -- 仅2024开始有数
    select event_date,app_name,user_pseudo_id,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where event_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)
        and event_date>='2024-01-01'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3
)
,
future_sub_pay as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) sub_365  -- 一年内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) sub_90  -- 90天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then sub_revenue end) sub_revenue_365  -- 一年内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then sub_revenue end) sub_revenue_90  -- 90天内是否有过订阅付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join sub_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
,
future_credit_pay as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) credit_365  -- 一年内是否有过积分付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) credit_90  -- 90天内是否有过积分付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then credit_revenue end) credit_revenue_365  -- 一年内是否有过积分付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then credit_revenue end) credit_revenue_90  -- 90天内是否有过积分付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join credit_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
,
future_ad_revenue as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.user_pseudo_id
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) max_365  -- 一年内是否有过广告收入
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) max_90  -- 90天内是否有过广告收入
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then max_revenue end) max_revenue_365  -- 一年内是否有过广告收入
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then max_revenue end) max_revenue_90  -- 90天内是否有过广告收入
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join ad_event  b
    where b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
,
current_sub as
(
    select u.app_name,u.event_date_hk,u.user_pseudo_id,max(sub_revenue) sub_revenue
    from goal_users u
    join
    (
        select
            app_id,uuid,standard_order_date,payment_price_usd sub_revenue
            ,case when subscription_period ='lifetime' then mDATE_END else standard_order_expire_date end standard_order_expire_date
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where
            app_id in('AirBrush','BeautyPlus')
            and order_status in (1,2)
    ) p
    on u.uuid = p.uuid and u.event_date_hk >= p.standard_order_date  and u.event_date_hk <= p.standard_order_expire_date
    and u.app_name=p.app_id
    group by 1,2,3
)
-- ,
-- sub_predict as
-- (
--     select 'BeautyPlus' app_name,date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
--         ,max(case when sub_type='else' then predit_sub_365_proba*0.05
--                    when sub_type='trial_now' then predit_sub_365_proba*1
--                    when sub_type='sub_his' then predit_sub_365_proba*0.95
--                    when sub_type='trial_his' then predit_sub_365_proba*0.35
--                 end) predit_sub_365_proba_adjust
--     from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
--     where date between mDATE_START and mDATE_END
--     group by 1,2,3
--
--     union all
--
--     select 'AirBrush' app_name,date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
--         ,max(case when sub_type='else' then predit_sub_365_proba*0.2
--                    when sub_type='trial_now' then predit_sub_365_proba*1
--                    when sub_type='sub_his' then predit_sub_365_proba*1
--                    when sub_type='trial_his' then predit_sub_365_proba*0.6
--                 end) predit_sub_365_proba_adjust
--     from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
--     where date between mDATE_START and mDATE_END
--     group by 1,2,3
-- )

select g.event_date_hk date,g.app_name,g.user_pseudo_id
        -- info
        ,country,is_UA,is_new,app_version
        -- past
        ,g.is_current_trial,g.current_trial_day,g.is_current_subscription_cancelled
        ,g.is_current_pay,g.past_sub_times,g.trial_times
        ,g.cancel_subscription_times,g.refund_subscription_times,g.promotional_paying_times
        -- now
        ,if(c.user_pseudo_id is not null,1,0) is_current_sub
        ,coalesce(c.sub_revenue,0.0) current_sub_revenue
        ,g.is_current_consume,g.current_consume_revenue
        ,if(ad.user_pseudo_id is not null,1,0) is_current_ad
        ,coalesce(ad.max_revenue,0.0) current_ad_revenue
        -- future
        ,g.future_sub_365,g.future_sub_90,g.future_sub_revenue_365,g.future_sub_revenue_90
        ,g.future_credit_365,g.future_credit_90,g.future_credit_revenue_365,g.future_credit_revenue_90
        ,fa.max_365 future_max_365,fa.max_90 future_max_90,fa.max_revenue_365 future_max_revenue_365,fa.max_revenue_90 future_max_revenue_90
--         ,g.predit_sub_365_proba,g.predit_sub_365_proba_adjust
from
(
    select g.event_date_hk,g.app_name,g.user_pseudo_id
         ,max(country) country
         ,max(is_UA) is_UA
         ,max(is_new) is_new
         ,max(app_version) app_version
         ,coalesce(max(is_current_trial),0) is_current_trial
         ,max(current_trial_day) current_trial_day
         ,max(is_current_subscription_cancelled) is_current_subscription_cancelled
         ,coalesce(max(is_current_pay),0) is_current_pay
         ,coalesce(sum(past_sub_times),0) past_sub_times
         ,coalesce(sum(trial_times),0) trial_times
         ,coalesce(sum(cancel_subscription_times),0) cancel_subscription_times
         ,coalesce(sum(refund_subscription_times),0) refund_subscription_times
         ,coalesce(sum(promotional_paying_times),0) promotional_paying_times
         -- 当前指标
         ,coalesce(max(if(c.uuid is not null,1,0)),0) is_current_consume
         ,coalesce(sum(c.credit_revenue),0) current_consume_revenue
         -- 未来指标
         ,coalesce(sum(sub_365),0) future_sub_365
         ,coalesce(sum(sub_90),0) future_sub_90
         ,coalesce(sum(sub_revenue_365),0) future_sub_revenue_365
         ,coalesce(sum(sub_revenue_90),0) future_sub_revenue_90
         ,coalesce(sum(credit_365),0) future_credit_365
         ,coalesce(sum(credit_90),0) future_credit_90
         ,coalesce(max(credit_revenue_365),0) future_credit_revenue_365
         ,coalesce(max(credit_revenue_90),0) future_credit_revenue_90
--          -- 预测指标
--          ,max(predit_sub_365_proba) predit_sub_365_proba
--          ,max(predit_sub_365_proba_adjust) predit_sub_365_proba_adjust
    from goal_users g
    left join his_sub_event hs
    on g.event_date_hk=hs.event_date_hk and g.app_name=hs.app_name and g.uuid=hs.uuid
    left join credit_event c
    on g.event_date_hk=c.standard_order_date and g.app_name=c.app_name and g.uuid=c.uuid
    left join future_sub_pay fs
    on g.event_date_hk=fs.event_date_hk and g.app_name=fs.app_name and g.uuid=fs.uuid
    left join future_credit_pay fc
    on g.event_date_hk=fc.event_date_hk and g.app_name=fc.app_name and g.uuid=fc.uuid
--     left join sub_predict sp
--     on g.event_date_hk=sp.date and g.app_name=sp.app_name and g.uuid=sp.uuid
    group by 1,2,3
) g
left join current_sub c
on g.event_date_hk=c.event_date_hk and g.app_name=c.app_name and g.user_pseudo_id=c.user_pseudo_id
left join future_ad_revenue fa
on g.event_date_hk=fa.event_date_hk and g.app_name=fa.app_name and g.user_pseudo_id=fa.user_pseudo_id
left join ad_event ad
on g.event_date_hk=ad.event_date and g.app_name=ad.app_name and g.user_pseudo_id=ad.user_pseudo_id

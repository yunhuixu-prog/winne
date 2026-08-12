-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑
DECLARE mDATE_START DATE DEFAULT '2023-01-01';
DECLARE mDATE_END DATE DEFAULT '2023-03-31';

-- DECLARE mDATE_START DATE DEFAULT '2023-12-01';
-- DECLARE mDATE_END DATE DEFAULT '2024-01-15';

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave as

delete from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave

with goal_users as
(
    select event_date_hk,app_name,user_pseudo_id,uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
        and app_name in ('BeautyPlus')  -- 'AirBrush',
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
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)  -- 最多预测未来一年
        and app_id in('BeautyPlus')
        and order_status in (1,2)
    group by 1,2,3
)
,
credit_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) credit_revenue
    from `dataintegration-265403.purchase.dwd_da_purchase_daily`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)  -- 最多预测未来一年
        and app_id in('BeautyPlus')
        and order_status in (1,2)  -- 这个确认下
    group by 1,2,3
)
,
ad_event as
(
    -- 仅2024开始有数
    select event_date,app_name,user_pseudo_id,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where event_date between '2024-01-01' and DATE_ADD(mDATE_END,interval 365 day)
        and app_name in ('BeautyPlus')
    group by 1,2,3
)
,
behave_event as
(
    select 'BeautyPlus' app_name,*
    from beautyplus-bc0ed.temp.dws_dz_dau_split_user_behave_v2
    where date between mDATE_START and mDATE_END

--     union all
--
--     select 'AirBrush' app_name,*
--     from airbrush-1324.temp.dws_dz_dau_split_user_behave
--     where date between mDATE_START and mDATE_END
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
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) max_365  -- 一年内是否有过订阅付费行为
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) max_90  -- 90天内是否有过订阅付费行为
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then max_revenue end) max_revenue_365  -- 一年内是否有过订阅付费行为
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then max_revenue end) max_revenue_90  -- 90天内是否有过订阅付费行为
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
dau_type as
(
    select app_name,event_date event_date_hk,user_pseudo_id
        ,max(is_paying) is_paying,max(is_consum) is_consum
        ,max(sub_revenue) sub_revenue,max(consum_revenue) consum_revenue,max(revenue) revenue
    from `dataintegration-265403.temp.dau_type`
    where app_name in ('BeautyPlus')
    group by 1,2,3
)

select g.event_date_hk date,g.app_name,g.user_pseudo_id
        ,g.*except(event_date_hk,app_name,user_pseudo_id)
        ,b.*except(date,app_name,user_pseudo_id)
        ,d.is_paying,d.is_consum,d.sub_revenue,d.consum_revenue,d.revenue
        ,fa.max_365,fa.max_90,fa.max_revenue_365,fa.max_revenue_90
from
(
    select g.event_date_hk,g.app_name,g.user_pseudo_id
         ,coalesce(max(is_current_trial),0) is_current_trial
         ,max(current_trial_day) current_trial_day
         ,max(is_current_subscription_cancelled) is_current_subscription_cancelled
         ,coalesce(max(is_current_pay),0) is_current_pay
         ,coalesce(max(past_sub_times),0) past_sub_times
         ,coalesce(max(trial_times),0) trial_times
         ,coalesce(max(cancel_subscription_times),0) cancel_subscription_times
         ,coalesce(max(refund_subscription_times),0) refund_subscription_times
         ,coalesce(max(promotional_paying_times),0) promotional_paying_times
         -- 当前指标
--          ,coalesce(max(if(c.uuid is not null,1,0)),0) is_current_consume
--          ,coalesce(max(c.credit_revenue),0) current_credit_revenue
         -- 预测指标
         ,coalesce(max(sub_365),0) sub_365
         ,coalesce(max(sub_90),0) sub_90
         ,coalesce(sum(sub_revenue_365),0) sub_revenue_365
         ,coalesce(sum(sub_revenue_90),0) sub_revenue_90
         ,coalesce(max(credit_365),0) credit_365
         ,coalesce(max(credit_90),0) credit_90
         ,coalesce(max(credit_revenue_365),0) credit_revenue_365
         ,coalesce(max(credit_revenue_90),0) credit_revenue_90
    from goal_users g
    left join his_sub_event hs
    on g.event_date_hk=hs.event_date_hk and g.app_name=hs.app_name and g.uuid=hs.uuid
--     left join credit_event c
--     on g.event_date_hk=c.standard_order_date and g.app_name=c.app_name and g.uuid=c.uuid
    left join future_sub_pay fs
    on g.event_date_hk=fs.event_date_hk and g.app_name=fs.app_name and g.uuid=fs.uuid
    left join future_credit_pay fc
    on g.event_date_hk=fc.event_date_hk and g.app_name=fc.app_name and g.uuid=fc.uuid
    group by 1,2,3
) g
left join behave_event b
on g.event_date_hk=b.date and g.app_name=b.app_name and g.user_pseudo_id=b.user_pseudo_id
left join dau_type d
on g.event_date_hk=d.event_date_hk and g.app_name=d.app_name and g.user_pseudo_id=d.user_pseudo_id
left join future_ad_revenue fa
on g.event_date_hk=fa.event_date_hk and g.app_name=fa.app_name and g.user_pseudo_id=fa.user_pseudo_id


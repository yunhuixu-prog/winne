-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=365+14)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info;
-- create table dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info as

delete from dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info where date between mDATE_START and mDATE_END;
insert into dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info

with
goal_users as
(
    select event_date_hk,app_name,user_pseudo_id,uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4
)
,
pre as
(
    select *
    from dataintegration-265403.temp.dws_dzp_portrait_dau_split_user_detail_sub_info_pre
    where date between mDATE_START and mDATE_END
)
,
sub_predict as
(
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

    select app_name,date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
        ,max(case when sub_type='else' then predit_sub_365_proba*0.05
                   when sub_type='trial_now' then predit_sub_365_proba*1
                   when sub_type='sub_his' then predit_sub_365_proba*0.95
                   when sub_type='trial_his' then predit_sub_365_proba*0.35
                end) predit_sub_365_proba_adjust
    from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
    where date between mDATE_START and mDATE_END and app_name='BeautyPlus'
    group by 1,2,3

    union all

    select app_name,date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
        ,max(case when sub_type='else' then predit_sub_365_proba*0.2
                   when sub_type='trial_now' then predit_sub_365_proba*1
                   when sub_type='sub_his' then predit_sub_365_proba*1
                   when sub_type='trial_his' then predit_sub_365_proba*0.6
                end) predit_sub_365_proba_adjust
    from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
    where date between mDATE_START and mDATE_END and app_name='AirBrush'
    group by 1,2,3
)

select g.event_date_hk date,g.app_name,g.user_pseudo_id
        -- info
        ,country,is_UA,is_new,app_version
        -- past
        ,p.is_current_trial,p.current_trial_day,p.is_current_subscription_cancelled
        ,p.is_current_pay,p.past_sub_times,p.trial_times
        ,p.cancel_subscription_times,p.refund_subscription_times,p.promotional_paying_times
        -- now
        ,p.is_current_sub
        ,p.current_sub_revenue
        ,p.is_current_consume,p.current_consume_revenue
        ,p.is_current_ad
        ,p.current_ad_revenue
        -- future
        ,p.future_sub_365,p.future_sub_90,p.future_sub_revenue_365,p.future_sub_revenue_90
        ,p.future_credit_365,p.future_credit_90,p.future_credit_revenue_365,p.future_credit_revenue_90
        ,p.future_max_365,p.future_max_90,p.future_max_revenue_365,p.future_max_revenue_90
        ,g.predit_sub_365_proba,g.predit_sub_365_proba_adjust
from
(
    select g.event_date_hk,g.app_name,g.user_pseudo_id
         -- 预测指标
         ,max(predit_sub_365_proba) predit_sub_365_proba
         ,max(predit_sub_365_proba_adjust) predit_sub_365_proba_adjust
    from goal_users g
    left join sub_predict sp
    on g.event_date_hk=sp.date and g.app_name=sp.app_name and g.uuid=sp.uuid
    group by 1,2,3
) g
left join pre p
on g.event_date_hk=p.date and g.app_name=p.app_name and g.user_pseudo_id=p.user_pseudo_id

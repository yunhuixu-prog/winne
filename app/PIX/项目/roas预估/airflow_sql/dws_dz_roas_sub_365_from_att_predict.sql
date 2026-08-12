
-- DECLARE mDATE_START DATE DEFAULT '2023-01-01';
-- DECLARE mDATE_END DATE DEFAULT '2023-01-01';

DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- 如果是回溯历史的数据，记得predict_sub_revenue的评估日期要改，记住！！！！！！！
-- drop table if exists dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict;
-- create table dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict as


delete from dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict where date between mDATE_START and mDATE_END;
insert into dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict

with goal_users as
(
    select app_name,types,date,Attributed_Touch_Date,days,sub_type,platform,permanent_country
        ,uuid
        ,sub_att_365,sub_revenue_att_365
        ,sub_att_365_to_now,sub_revenue_att_365_to_now
        ,sub_att_365_from_now,sub_revenue_att_365_from_now
    from dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid
    where date between mDATE_START and mDATE_END
)
,
sub_365_predict as
(
--     select 'BeautyPlus' app_name,date,uuid
--         ,max(install_days_type) install_days_type
--         ,max(case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end) predit_sub_365_proba
--     from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
--     where date between mDATE_START and mDATE_END
--     group by 1,2,3
--
--     union all
--
--     select 'AirBrush' app_name,date,uuid
--         ,max(install_days_type) install_days_type
--         ,max(case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end) predit_sub_365_proba
--     from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
--     where date between mDATE_START and mDATE_END
--     group by 1,2,3

    select app_name,date,uuid
        ,max(install_days_type) install_days_type
        ,max(case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end) predit_sub_365_proba
    from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
    where date between mDATE_START and mDATE_END
    group by 1,2,3
)
,
predict_sub_revenue as
(
    -- 记得历史的要更新
    select app_name,types,days,sub_type,platform,permanent_country,count(uuid) sample
        ,round(sum(sub_revenue_att_365_from_now)/count(uuid),2) sub_revenue_att_365_from_now_avg
    from dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid a
    where date between date_sub(mDATE_START,interval 365+180+3 day) and date_sub(mDATE_START,interval 365+3 day) and sub_att_365_from_now>0 and sub_att_365<20  -- 限制异常订单数巨大的uuid
--     where date between '2023-01-01' and '2023-06-30' and sub_att_365_from_now>0 and sub_att_365<20  -- 限制异常订单数巨大的uuid
    group by 1,2,3,4,5,6
    having count(uuid)>1000
)
,
predict_sub_revenue_no_country as
(
    -- 记得历史的要更新
    select app_name,types,days,sub_type,platform,count(uuid) sample
        ,round(sum(sub_revenue_att_365_from_now)/count(uuid),2) sub_revenue_att_365_from_now_avg
    from dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid a
    where date between date_sub(mDATE_START,interval 365+180+3 day) and date_sub(mDATE_START,interval 365+3 day) and sub_att_365_from_now>0 and sub_att_365<20  -- 限制异常订单数巨大的uuid
--     where date between '2023-01-01' and '2023-06-30' and sub_att_365_from_now>0 and sub_att_365<20  -- 限制异常订单数巨大的uuid
    group by 1,2,3,4,5
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
    where event_date_hk>='2024-01-01' and event_date_hk between mDATE_START and mDATE_END
        and app_id in ('BeautyPlus','AirBrush')

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
    where event_date_hk<'2024-01-01' and event_date_hk between mDATE_START and mDATE_END
        and app_id in ('BeautyPlus','AirBrush')
)
,
order_id as
(
    select 'ua' types,app_id,platform,uuid,Attributed_Touch_Time Attributed_Touch_Date,order_date2 date
        ,order_id,order_status,subscription_period,sku_is_trial,standard_order_date,standard_order_expire_date,end_order_date
    from
    (
        select *,case
                when subscription_period =  '1-month' then date_add(standard_order_date,interval 1 month)
                when subscription_period =  '3-month' then date_add(standard_order_date,interval 3 month)
                when subscription_period =  '1-week' then date_add(standard_order_date,interval 1 week)
                when subscription_period =  '1-year' then date_add(standard_order_date,interval 1 year)
                 -- 若未来有新的sku，需要再补
            end end_order_date
        from dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v
    ),unnest(generate_date_array(standard_order_date,date_sub(end_order_date,interval 1 day))) as order_date2
    where order_date2 between mDATE_START and mDATE_END
        and  order_date2 between Attributed_Touch_Time and date_add(Attributed_Touch_Time,interval 364 day)
        and app_id in ('BeautyPlus','AirBrush') and product='subscription'

    union all

    select 'new' types,app_id,platform,uuid,Attributed_Touch_Time Attributed_Touch_Date,order_date2 date
        ,order_id,order_status,subscription_period,sku_is_trial,standard_order_date,standard_order_expire_date,end_order_date
    from
    (
        select *,case
                when subscription_period =  '1-month' then date_add(standard_order_date,interval 1 month)
                when subscription_period =  '3-month' then date_add(standard_order_date,interval 3 month)
                when subscription_period =  '1-week' then date_add(standard_order_date,interval 1 week)
                when subscription_period =  '1-year' then date_add(standard_order_date,interval 1 year)
                 -- 若未来有新的sku，需要再补
            end end_order_date
        from dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v
    ),unnest(generate_date_array(standard_order_date,date_sub(end_order_date,interval 1 day))) as order_date2
    where order_date2 between mDATE_START and mDATE_END
        and  order_date2 between Attributed_Touch_Time and date_add(Attributed_Touch_Time,interval 364 day)
        and app_id in ('BeautyPlus','AirBrush') and product='subscription'
)
,
forecast_order_id as
(
    select oi.types,oi.app_id app_name,oi.uuid,oi.Attributed_Touch_Date,oi.date
        ,max(order_status) order_status
        ,sum(revenue) revenue
    from order_id oi
    left join
    (
        select attributed_id_type, order_id, install_date, payment_price_usd, num_cr, agg_rate, revenue
        from `dataintegration-265403.roas.dws_dzp_roas_forecast_order`
    ) fo
    on oi.order_id=fo.order_id and oi.types=fo.attributed_id_type
    group by 1,2,3,4,5
)


select *except(predict_sub_att_365_from_now,predict_sub_revenue_att_365_from_now)
        ,case when types='ua' and app_name='BeautyPlus' and sub_type='else' then predict_sub_att_365_from_now*0.015
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_now' then predict_sub_att_365_from_now*0.85
                       when types='ua' and app_name='BeautyPlus' and sub_type='sub_his' then predict_sub_att_365_from_now*0.2
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_his' then predict_sub_att_365_from_now*0.1

                       when types='ua' and app_name='AirBrush' and sub_type='else' then predict_sub_att_365_from_now*0.024
                       when types='ua' and app_name='AirBrush' and sub_type='trial_now' then predict_sub_att_365_from_now*0.6
                       when types='ua' and app_name='AirBrush' and sub_type='sub_his' then predict_sub_att_365_from_now*0.2
                       when types='ua' and app_name='AirBrush' and sub_type='trial_his' then predict_sub_att_365_from_now*0.25
              when types='new' and app_name='BeautyPlus' and sub_type='else' then predict_sub_att_365_from_now*0.025
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_now' then predict_sub_att_365_from_now*0.9
                       when types='new' and app_name='BeautyPlus' and sub_type='sub_his' then predict_sub_att_365_from_now*0.5
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_his' then predict_sub_att_365_from_now*0.2

                       when types='new' and app_name='AirBrush' and sub_type='else' then predict_sub_att_365_from_now*0.045
                       when types='new' and app_name='AirBrush' and sub_type='trial_now' then predict_sub_att_365_from_now*0.8
                       when types='new' and app_name='AirBrush' and sub_type='sub_his' then predict_sub_att_365_from_now*0.6
                       when types='new' and app_name='AirBrush' and sub_type='trial_his' then predict_sub_att_365_from_now*0.3
        end predict_sub_att_365_from_now
        ,case when types='ua' and app_name='BeautyPlus' and sub_type='else' then predict_sub_revenue_att_365_from_now*0.015
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_now' then predict_sub_revenue_att_365_from_now*0.85
                       when types='ua' and app_name='BeautyPlus' and sub_type='sub_his' then predict_sub_revenue_att_365_from_now*0.2
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_his' then predict_sub_revenue_att_365_from_now*0.1

                       when types='ua' and app_name='AirBrush' and sub_type='else' then predict_sub_revenue_att_365_from_now*0.024
                       when types='ua' and app_name='AirBrush' and sub_type='trial_now' then predict_sub_revenue_att_365_from_now*0.6
                       when types='ua' and app_name='AirBrush' and sub_type='sub_his' then predict_sub_revenue_att_365_from_now*0.2
                       when types='ua' and app_name='AirBrush' and sub_type='trial_his' then predict_sub_revenue_att_365_from_now*0.25
              when types='new' and app_name='BeautyPlus' and sub_type='else' then predict_sub_revenue_att_365_from_now*0.025
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_now' then predict_sub_revenue_att_365_from_now*0.9
                       when types='new' and app_name='BeautyPlus' and sub_type='sub_his' then predict_sub_revenue_att_365_from_now*0.5
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_his' then predict_sub_revenue_att_365_from_now*0.2

                       when types='new' and app_name='AirBrush' and sub_type='else' then predict_sub_revenue_att_365_from_now*0.045
                       when types='new' and app_name='AirBrush' and sub_type='trial_now' then predict_sub_revenue_att_365_from_now*0.8
                       when types='new' and app_name='AirBrush' and sub_type='sub_his' then predict_sub_revenue_att_365_from_now*0.6
                       when types='new' and app_name='AirBrush' and sub_type='trial_his' then predict_sub_revenue_att_365_from_now*0.3
        end predict_sub_revenue_att_365_from_now
from
(
    select g.types,g.app_name,g.date,g.Attributed_Touch_Date attributed_touch_date,g.days
         ,g.uuid
         -- 从投放日开始一年内的订阅情况
         ,g.sub_att_365
         ,g.sub_revenue_att_365
         -- 从投放日期至观测日期的订阅情况
         ,g.sub_att_365_to_now
         ,g.sub_revenue_att_365_to_now
         -- 从观测日期至投放一年的订阅情况
         ,g.sub_att_365_from_now
         ,g.sub_revenue_att_365_from_now

         -- 一下指标仅与date有关，与投放日期无关
         ,coalesce(h.is_current_trial,0) is_current_trial
         ,coalesce(h.is_current_pay,0) is_current_pay
         ,coalesce(h.past_sub_times,0) past_sub_times
         ,coalesce(h.trial_times,0) trial_times
         ,g.sub_type
         ,g.platform
         ,g.permanent_country
         ,o.install_days_type

         ,oi.order_status
         ,oi.revenue predict_order_revenue

         ,o.predit_sub_365_proba
         -- 以下指标涉及投放日期与观测日期差值
         -- 用户从观测日期至投放一年的订阅概率，采用对数分布
         ,round(LN(EXP(1)-(EXP(1)-1)/364*g.days)*case when g.days>=61 and g.sub_type='else' then o.predit_sub_365_proba*2 else o.predit_sub_365_proba end,4) predict_sub_att_365_from_now
         -- 如果用户订阅了，预测付费的金额
         ,coalesce(r.sub_revenue_att_365_from_now_avg,rn.sub_revenue_att_365_from_now_avg) sub_revenue_att_365_from_now_avg
         -- 用户预测收入：订阅概率*付费金额
         ,round(LN(EXP(1)-(EXP(1)-1)/364*g.days)*case when g.days>=61 and g.sub_type='else' then o.predit_sub_365_proba*2 else o.predit_sub_365_proba end*coalesce(r.sub_revenue_att_365_from_now_avg,rn.sub_revenue_att_365_from_now_avg),4) predict_sub_revenue_att_365_from_now

    from goal_users g
    left join sub_365_predict o
    on g.uuid=o.uuid and g.app_name=o.app_name and g.date=o.date
    left join predict_sub_revenue r
    on g.app_name=r.app_name and g.days=r.days and g.types=r.types
           and g.sub_type=r.sub_type and g.platform=r.platform and g.permanent_country=r.permanent_country
    left join predict_sub_revenue_no_country rn
    on g.app_name=rn.app_name and g.days=rn.days and g.types=rn.types
           and g.sub_type=rn.sub_type and g.platform=rn.platform
    left join his_sub_event h
    on g.uuid=h.uuid and g.app_name=h.app_name and g.date=h.event_date_hk
    left join forecast_order_id oi
    on g.uuid=oi.uuid and g.app_name=oi.app_name and g.date=oi.date and g.Attributed_Touch_Date=oi.Attributed_Touch_Date and g.types=oi.types
)
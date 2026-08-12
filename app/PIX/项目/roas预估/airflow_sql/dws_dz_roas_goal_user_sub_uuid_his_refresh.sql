-- 还要有一版一年前的数据更新的
-- DECLARE mDATE_START DATE DEFAULT '2023-01-01';
-- DECLARE mDATE_END DATE DEFAULT '2023-12-31';
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=365+3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=365)).strftime("%Y-%m-%d") }}';

-- drop table if exists dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid;
-- create table dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid as

delete from dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid where date between mDATE_START and mDATE_END;
insert into dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid

with goal_users_pre as
(
    select distinct 'ua' types,App_Name app_name
        ,UPPER(Platform) Platform,Attributed_Touch_Date_hk Attributed_Touch_Date,AppsFlyer_ID id
    from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
    where App_Name in ('BeautyPlus','AirBrush') and Attributed_Touch_Date_hk between date_sub(mDATE_START,interval 365 day) and mDATE_END

    union all

    select 'new' types,app_name,upper(Platform) as Platform,Attributed_Touch_Date,uuid id
    from
    (
        SELECT app_name,uuid
              ,max(Platform) Platform
              ,min(event_date_hk) as Attributed_Touch_Date
        FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
        where app_name in ('BeautyPlus','AirBrush') and is_new = 1 -- 限制新增用户
        group by 1,2
    )
    where Attributed_Touch_Date between date_sub(mDATE_START,interval 365 day) and mDATE_END
)
,
uuid_firebase_id as
(
    select key,uuid
    from `dataintegration-265403.stat.dmi_dz_idmapping`
)
,
goal_users_uuid as
(
    select distinct types,app_name,Attributed_Touch_Date,uu.uuid
    from goal_users_pre gu
    left join uuid_firebase_id uu
    on gu.id=uu.key
    where gu.types='ua'

    union all

    select distinct types,app_name,Attributed_Touch_Date,id uuid
    from goal_users_pre gu
    where gu.types='new'
)
,
goal_users as
(
    select b.app_name,b.types,a.date,b.Attributed_Touch_Date
        ,b.uuid
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join goal_users_uuid b
    where a.date between b.Attributed_Touch_Date and date_add(b.Attributed_Touch_Date,interval 364 day)
    group by 1,2,3,4,5
)
,
sub_event as
(
    select
        'ua' types,app_id app_name,uuid,standard_order_date,order_status,sum(payment_price_usd) sub_revenue
    from dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v
    where standard_order_date between date_sub(mDATE_START,interval 365 day) and DATE_ADD(mDATE_END,interval 365 day)
        and app_id in('BeautyPlus','AirBrush') and product='subscription' and order_status in (1,2)
    group by 1,2,3,4,5

    union all

    select
         'new' types,app_id app_name,uuid,standard_order_date,order_status,sum(payment_price_usd) sub_revenue
    from dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v
    where standard_order_date between date_sub(mDATE_START,interval 365 day) and DATE_ADD(mDATE_END,interval 365 day)
        and app_id in('BeautyPlus','AirBrush') and product='subscription' and order_status in (1,2)
    group by 1,2,3,4,5
)
,
future_sub_pay as
(
    select g.types,g.date,g.Attributed_Touch_Date
        ,g.app_name
        ,g.uuid
        ,count(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY) then 1 end) sub_att_365  -- 投放一年内是否有过订阅行为（不包括试用）
        ,count(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY)
                        and s.standard_order_date <= g.date then 1 end) sub_att_365_to_now  -- 至目前是否有过订阅行为（不包括试用）
        ,count(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY)
                        and s.standard_order_date > g.date then 1 end) sub_att_365_from_now  -- 观测日至投放一年内是否有过订阅行为（不包括试用）

        ,round(sum(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY) then s.sub_revenue end),2) sub_revenue_att_365
        ,round(sum(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY)
                        and s.standard_order_date <= g.date then s.sub_revenue end),2) sub_revenue_att_365_to_now
        ,round(sum(case when s.standard_order_date < date_add(g.Attributed_Touch_Date,INTERVAL 365 DAY)
                        and s.standard_order_date > g.date then s.sub_revenue end),2) sub_revenue_att_365_from_now
    from goal_users g
    join sub_event s on g.uuid=s.uuid and g.app_name=s.app_name and g.types=s.types
    where (s.standard_order_date between g.Attributed_Touch_Date and DATE_ADD(g.Attributed_Touch_Date, INTERVAL 364 DAY))
    group by 1,2,3,4,5
)
,
other_info as
(
    select 'BeautyPlus' app_name,date,uuid,permanent_country,platform
        ,case when is_current_trial = 1 then 'trial_now'
             when past_sub_times-trial_times>0 then 'sub_his'
             when trial_times>0 then 'trial_his'
             else 'else'
        end sub_type
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
    where date between mDATE_START and mDATE_END

    union all

    select 'AirBrush' app_name,date,uuid,permanent_country,platform
        ,case when is_current_trial = 1 then 'trial_now'
             when past_sub_times-trial_times>0 then 'sub_his'
             when trial_times>0 then 'trial_his'
             else 'else'
        end sub_type
    from airbrush-1324.temp.dws_dz_his_split_final_user_behave
    where date between mDATE_START and mDATE_END
)

select g.types,g.app_name,g.date,g.Attributed_Touch_Date
     ,date_diff(g.date,g.Attributed_Touch_Date,DAY) days
     ,g.uuid
     ,coalesce(f.sub_att_365,0) sub_att_365
     ,coalesce(f.sub_revenue_att_365,0) sub_revenue_att_365
     ,coalesce(f.sub_att_365_to_now,0) sub_att_365_to_now
     ,coalesce(f.sub_revenue_att_365_to_now,0) sub_revenue_att_365_to_now
     ,coalesce(f.sub_att_365_from_now,0) sub_att_365_from_now
     ,coalesce(f.sub_revenue_att_365_from_now,0) sub_revenue_att_365_from_now
     ,o.permanent_country,o.platform,o.sub_type
from goal_users g
left join future_sub_pay f
on g.uuid=f.uuid and g.app_name=f.app_name and g.date=f.date and g.Attributed_Touch_Date=f.Attributed_Touch_Date and g.types=f.types
left join other_info o
on g.uuid=o.uuid and g.app_name=o.app_name and g.date=o.date



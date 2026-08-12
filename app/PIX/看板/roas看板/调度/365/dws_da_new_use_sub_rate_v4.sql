-- 可用的预测续订率
-- 可以与 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily` 直接left join
/*
create or replace table `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`  as
*/
delete
from `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`
where 1=1;

insert into `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`

with forecast_re as (
    -- 续订率：全部使用预测的续订率
    -- 只有收入：有实际用实际，没有实际用预测
    -- 1week,1m,3m
        select
            distinct  date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
            ,cast(period as int) period
            ,period_rate

        from
           `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
        where
            (subscription_period = '1-week' and period <= 51 ) or
            (subscription_period = '1-month' and period <= 11 ) or
            (subscription_period = '3-month' and period <= 3)

    union all
    -- 用于非正价付费，和试用的续订率
    select
        date,app_id,country,platform,is_UA,'new_paid' subscription_user_type
        ,subscription_period
        ,cast(period as int) period
        ,avg(period_rate)period_rate
    from
      `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
        where
            (subscription_period = '1-week' and period <= 51 ) or
            (subscription_period = '1-month' and period <= 11 ) or
            (subscription_period = '3-month' and period <= 3)
    group by 1,2,3,4,5,6,7,8

-- 放弃6个月的续订率，看了一下 有R1 的仅2人
)

,sub as (
    select
        distinct standard_order_date ,app_id,fix_firebase_en_name country,is_UA,platform,subscription_period,subscription_user_type
        --  非正价付费的类型，均使用first time+ first return time 的均值
        ,case
            when offer_method <> 'normal' then 'new_paid'
            when  subscription_user_type  in( 'repeated_renewal') then 'first_time_subscription'  -- 这种情况使用 'first_time_subscription' 的预测续订率
            when  subscription_user_type  in('return_renewal')  then 'first_time_return_subscription' -- 这种情况使用 'first_time_return_subscription' 的预测续订率
            else  subscription_user_type
        end subscription_user_type_1
    from
    (
    select *
    from
         `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where
        standard_order_date  >='2020-08-01'
        and subscription_period	 not in ('inapp','lifetime','1-year','6-month') -- 这些sku 不需要续订率
        and order_status in (0,1,2)
    )a left join (select distinct key, fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.country = b.key

     --   and app_id in ('AirBrush','BeeutyPlus','VCUS')
)

select
 -- 去重是因为必然导致重复
   distinct  a.standard_order_date ,a.app_id,a.country,a.is_UA,a.platform,a.subscription_user_type,a.subscription_period--,subscription_user_type_1
    ,coalesce(b.period,c.period,d.period) period
    ,coalesce(b.period_rate,c.period_rate,d.period_rate) period_rate

from
    sub a
left join forecast_re b on  a.standard_order_date  = b.date and a.app_id = b.app_id and a.platform = b.platform
            and a.is_UA = b.is_UA and  coalesce(a.country,'-')= coalesce(b.country,'-')
            and a.subscription_period = b.subscription_period and a.subscription_user_type_1 = b.subscription_user_type
left join
    (   -- 剔除国家的影响
        select *
        from forecast_re
        where country = 'others'
    )c on  a.standard_order_date  = c.date and a.app_id = c.app_id and a.platform = c.platform
            and a.is_UA = c.is_UA
            and a.subscription_period = c.subscription_period and a.subscription_user_type_1 = c.subscription_user_type
left join
    (
        select *
        from forecast_re
        where
            country = 'all'
            and platform ='all'
            and is_UA = 'all'

    )d on  a.standard_order_date  = d.date and a.app_id = d.app_id
            and a.subscription_period = d.subscription_period and a.subscription_user_type_1 = d.subscription_user_type

-- where coalesce(b.period_rate,c.period_rate,d.period_rate) > 0   -- -- 比如 1 week 有些生命周期到25周，第26周开始 续订率就小于0 了，因此需要剔除
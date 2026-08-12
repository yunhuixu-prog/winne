-- 新增first_time_subscription，新增回流first_time_return_subscription，在27行替换
DECLARE mDATE_START DATE DEFAULT '2024-10-19';
DECLARE mDATE_END DATE DEFAULT '2024-12-29';

select standard_order_date date
    ,case when subscription_period='1-month' then 'month'
          when interval_days=7 then '7-trial'
          when interval_days=3 then '3-trial'
          when sku_is_trial='no_trial' then 'no_trial'
--           when interval_days is not null then 'x-trial'
    else 'else' -- 优惠价转付费，sku为试用但实际无试用
    end order_type
    ,count(1) uv
    ,round(sum(payment_price_usd)) bookings
-- select *
from
(
    select a.*,date_diff(a.standard_order_date,b.standard_order_date,day) interval_days
            ,b.standard_order_date standard_order_date_pre,b.subscription_user_type subscription_user_type_pre
            ,row_number() over(partition by a.original_order_id,a.uuid order by b.standard_order_date desc) orders
    from
    (
        select original_order_id,uuid,standard_order_date,subscription_period,payment_price_usd,sku,sku_is_trial,country,is_ua
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between mDATE_START and mDATE_END
            and app_id in('BeautyPlus')
            and subscription_user_type in ('first_time_subscription') --'first_time_return_subscription'
            and platform='IOS'
    ) a
    left join
    (
        select original_order_id,uuid,standard_order_date,subscription_user_type
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between date_sub(mDATE_START,interval 30 day) and mDATE_END
            and app_id in('BeautyPlus')
            and subscription_user_type in ('intro_trial','trial')  --intro pay as you go
            and platform='IOS'
    ) b
    on a.original_order_id=b.original_order_id and a.uuid=b.uuid and a.standard_order_date>=date_sub(b.standard_order_date,interval 30 day)
)
where orders=1
--     and subscription_period!='1-month'
--     and ((interval_days!=7 and interval_days!=3) or interval_days is null)
--     and subscription_period!='1-month'
--     and interval_days is null and sku_is_trial='has_trial'
--     and sku in ('beautyplus_auto_renewing_1y_sd30off_all')
group by 1,2
order by 1,2


-- 试用用户是哪天取消订阅的

DECLARE mDATE_START DATE DEFAULT '2025-01-27';
DECLARE mDATE_END DATE DEFAULT '2025-03-02';

with new_trial_order as
(
    -- next_order_date不适合用
    select standard_order_date start_date,standard_order_expire_date end_date,original_order_id,order_id,uuid
        ,next_order_date,subscription_period,platform,sku,country
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and mDATE_END
        and app_id in('BeautyPlus')
            and subscription_user_type in ('intro_trial','trial')
)

select date,case
        when next_order_date is not null then '1.试用付费' -- 这不对
        when is_cancell=0 or (is_cancell=1 and cancel_end_days<0) then '3.其他（主要指进入宽限期）'
--         when is_cancell=1 and start_cancel_days<=0 then '2-1.后台主动取消续订-当天'
        when is_cancell=1 then '2.后台主动取消续订'
  end cancel_period
  ,count(distinct original_order_id) expired_order_num
from
(
    select
        a.start_date date,a.end_date,a.order_id,a.original_order_id,a.uuid
        ,a.platform,a.subscription_period,a.sku,a.country,a.next_order_date
        ,if(b.order_id is not null,1,0) is_cancell,standard_cancel_date
        ,DATE_DIFF(standard_cancel_date, start_date, day) start_cancel_days
        ,DATE_DIFF(end_date, standard_cancel_date, day) cancel_end_days
    from new_trial_order a
    -- 取消续订
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='BeautyPlus'
    --             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
)
group by 1,2



DECLARE mDATE_START DATE DEFAULT '2025-01-27';
DECLARE mDATE_END DATE DEFAULT '2025-03-02';

with new_trial_order as
(
--     select
--         date,standard_order_date,uuid,user_pseudo_id,platform,country,sku_type,sku,original_order_id,order_id,purchase_date,payment_price_usd
--     from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
--     where date between mDATE_START and mDATE_END
--         and event_name in ('subscription_try_suc') and standard_order_date is not null
--         and sub_success_offer_type in ('trial','intro_trial','promotion_trial')

    select sub_success_server_date start_date,sub_success_to_paid_date purchase_date
        ,sub_success_order_id original_order_id,curr_order_id order_id,uuid
    from `dataintegration-265403.subscription.dwd_dz_sub_union_order`
    where sub_success_server_date between mDATE_START and mDATE_END
        and sub_success_offer_type in ('intro_trial','trial','promotion_trial')
        and sub_success_server_date is not null
        and app_name='BeautyPlus'
)

select start_date date,case
        when purchase_date is not null then '1.试用付费'
        when is_cancell=0 then '3.其他（主要指进入宽限期）'
        when is_cancell=1 then '2.后台主动取消续订'
  end cancel_period
  ,count(distinct original_order_id) expired_order_num
from
(
    select
        a.start_date,a.order_id,a.original_order_id,a.purchase_date
        ,if(b.order_id is not null,1,0) is_cancell,standard_cancel_date
        ,DATE_DIFF(standard_cancel_date, start_date, day) start_cancel_days
    from new_trial_order a
    -- 取消续订
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='BeautyPlus'
    --             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
)
group by 1,2



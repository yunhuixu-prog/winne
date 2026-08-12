DECLARE mDATE_START DATE DEFAULT '2025-01-10';
DECLARE mDATE_END DATE DEFAULT '2025-03-09';

-- 订阅中间表能不能对上

select 'union_order' type,sub_success_to_paid_date purchase_date
    ,case when sku_type='1-month' then '1m'
          when sub_success_offer_type not in ('trial','intro_trial','promotion_trial') and sku_type='1-year' then '12m_no_trial'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' and date_diff(sub_success_to_paid_date,sub_success_server_date,day)=7 then '12m_has_trial_7days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' and date_diff(sub_success_to_paid_date,sub_success_server_date,day)=3 then '12m_has_trial_3days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' then '12m_has_trial_others'
    else 'others'
    end sku_has_trial
    ,count(distinct user_pseudo_id) as uv
    ,round(sum(sub_success_to_paid_revenue),2) value
--      ,sub_success_server_date start_date,sub_success_order_id original_order_id,curr_order_id order_id,uuid
from `dataintegration-265403.subscription.dwd_dz_sub_union_order`
where sub_success_to_paid_date between mDATE_START and mDATE_END
    and sub_success_server_date is not null and sub_success_to_paid_date is not null
    and app_name='BeautyPlus'
    and country='United States'
group by
    1,2,3

union all

select
    'abtest' type,purchase_date
    ,case when sku_type='1m' then '1m'
          when sub_success_offer_type not in ('trial','intro_trial','promotion_trial') and sku_type='12m' then '12m_no_trial'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' and date_diff(purchase_date,standard_order_date,day)=7 then '12m_has_trial_7days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' and date_diff(purchase_date,standard_order_date,day)=3 then '12m_has_trial_3days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' then '12m_has_trial_others'
    else 'others'
    end sku_has_trial
    ,count(distinct user_pseudo_id) as uv
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    purchase_date between mDATE_START and mDATE_END
    and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and country='United States'
group by
    1,2,3









DECLARE mDATE_START DATE DEFAULT '2025-01-10';
DECLARE mDATE_END DATE DEFAULT '2025-03-09';

-- orderid校验
-- select a.standard_order_date date
--     ,a.order_id,a.uuid
--     ,a.country country_a
--     ,a.payment_price_usd
--     ,a.standard_order_date_pre,a.order_id_pre,a.interval_days
--     ,case when subscription_period='1-month' then 'month'
--           when subscription_user_type_pre in ('intro_trial','trial') and interval_days=7 then '7-trial'
--           when subscription_user_type_pre in ('intro_trial','trial') and interval_days=3 then '3-trial'
--           when sku_is_trial='no_trial' then 'no_trial'
-- --           when interval_days is not null then 'x-trial'
--     else 'else' -- 优惠价转付费，sku为试用但实际无试用或者间隔时间很久了
--     end order_type
--     ,b.start_date,b.start_order_id,b.start_order_id
--     ,b.purchase_date,b.purchase_order_id,b.payment_price_usd
--     ,b.country country_b
select a.standard_order_date date
        ,round(sum(case when subscription_user_type='first_time_subscription' then a.payment_price_usd end),2) value_1_first_time_subscription
        ,round(sum(case when subscription_user_type='first_time_subscription' then b.payment_price_usd end),2) value_2_first_time_subscription
        ,round(sum(case when subscription_user_type='first_time_return_subscription' then a.payment_price_usd end),2) value_1_first_time_return_subscription
        ,round(sum(case when subscription_user_type='first_time_return_subscription' then b.payment_price_usd end),2) value_2_first_time_return_subscription
from
(
    select a.*,date_diff(a.standard_order_date,b.standard_order_date,day) interval_days
            ,b.standard_order_date standard_order_date_pre,b.subscription_user_type subscription_user_type_pre
            ,b.order_id order_id_pre
            ,b.sku sku_pre
            ,row_number() over(partition by a.original_order_id,a.uuid order by b.standard_order_date desc) orders
    from
    (
        select original_order_id,o_original_order_id,order_id,uuid,standard_order_date,subscription_user_type
            ,subscription_period,payment_price_usd,sku,sku_is_trial,country,is_ua,last_offer_method
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between mDATE_START and mDATE_END
            and app_id in('BeautyPlus')
            and subscription_user_type in ('first_time_return_subscription','first_time_subscription') --'first_time_return_subscription','first_time_subscription'
            -- and platform='IOS'
            and country='United States'
    ) a
    left join
    (
        select original_order_id,o_original_order_id,order_id,uuid,standard_order_date,subscription_user_type,sku
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between date_sub(mDATE_START,interval 380 day) and mDATE_END
            and app_id in('BeautyPlus')
--             and subscription_user_type in ('intro_trial','trial')  --intro pay as you go
            -- and platform='IOS'
    ) b
    on a.o_original_order_id=b.o_original_order_id and a.uuid=b.uuid
        and a.standard_order_date>b.standard_order_date
--         and a.standard_order_date>=date_sub(b.standard_order_date,interval 30 day)
) a
left join
(
    select sub_success_server_date start_date
        ,sub_success_order_id original_order_id,curr_order_id start_order_id
        ,sub_success_to_paid_date purchase_date
        ,sub_success_to_paid_order_id as purchase_order_id
        ,sub_success_to_paid_revenue as payment_price_usd
        ,uuid,user_pseudo_id,country
        ,case when sku_type='1-month' then '1m'
              when sub_success_offer_type not in ('trial','intro_trial','promotion_trial') and sku_type='1-year' then '12m_no_trial'
              when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' and date_diff(sub_success_to_paid_date,sub_success_server_date,day)=7 then '12m_has_trial_7days'
              when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' and date_diff(sub_success_to_paid_date,sub_success_server_date,day)=3 then '12m_has_trial_3days'
              when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='1-year' then '12m_has_trial_others'
        else 'others'
        end sku_has_trial
    from `dataintegration-265403.subscription.dwd_dz_sub_union_order`
    where sub_success_to_paid_date between date_sub(mDATE_START,interval 10 day) and mDATE_END
--         and sub_success_server_date is not null and sub_success_to_paid_date is not null
        and app_name='BeautyPlus'
--         and country='United States'
) b
on a.order_id = b.purchase_order_id
where a.orders=1 -- and b.purchase_order_id is null
group by 1
order by 1

;
select sub_success_server_date start_date
        ,sub_success_order_id original_order_id,curr_order_id start_order_id
        ,sub_success_to_paid_date purchase_date
        ,sub_success_to_paid_order_id as purchase_order_id
        ,sub_success_to_paid_revenue as payment_price_usd
        ,uuid,user_pseudo_id,country,platform,app_name,sku_type,sub_success_offer_type
from `dataintegration-265403.subscription.dwd_dz_sub_union_order`
where uuid='241534175' and app_name='BeautyPlus'
order by sub_success_server_date

select app_id,original_order_id,o_original_order_id,order_id,uuid,standard_order_date,subscription_user_type
    ,subscription_period,payment_price_usd,sku_is_trial,country,is_ua,last_offer_method
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where uuid='241534175' and app_id in('BeautyPlus')
order by standard_order_date


-- 有意思的id
808330844,
退款问题？
问一下军成吧哎头大
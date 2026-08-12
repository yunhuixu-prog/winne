-- 到用户粒度的数据，主要取用户类型
select
    case when  event_name in ('page_event') then '1:sub enter'
         when  event_name in ('subscription_try_suc') then '2:sub click'
    end as event_name
    ,date
    ,platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct user_pseudo_id) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between '2025-05-01' and '2025-06-17'
    and event_name in ('page_event','subscription_try_suc')
    and sub_user_type in ('1','2','4')
group by
    1,2,3,4,5

union all

select
    '3:sub suc' event_name
    ,date
    ,platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct user_pseudo_id) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between '2025-05-01' and '2025-06-17'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
    and sub_user_type in ('1','2','4')
group by
    1,2,3,4,5

union all

select
    '4:sub to paid' event_name
    ,date
    ,platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct user_pseudo_id) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between '2025-05-01' and '2025-06-17'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null and purchase_date is not null
    and sub_user_type in ('1','2','4')
group by
    1,2,3,4,5

union all

select
    '5:sub to paid bookings' event_name
    ,date
    ,platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between '2025-05-01' and '2025-06-17'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null and purchase_date is not null
    and sub_user_type in ('1','2','4')
group by
    1,2,3,4,5


;
-- sku
select
    date
    ,platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,sku
    ,count(distinct user_pseudo_id) uv
    ,round(sum(payment_price_usd),2) bookings
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between '2025-05-01' and '2025-06-17'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null and purchase_date is not null
    and sub_user_type in ('1','2','4')
group by
    1,2,3,4,5



select
    case when  event_name in ('page_event') then '1:sub enter'
         when  event_name in ('subscription_try_suc') then '2:sub click'
    end as event_name
    ,a.date
    ,case when a.date between '2025-06-13' and '2025-06-19' then '0613-0619'
          when a.date between '2025-06-21' and '2025-06-27' then '0621-0627'
    end period
    ,a.platform
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct a.user_pseudo_id) value
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2025-05-31' and '2025-07-06'
    and u.event_date_hk between '2025-05-31' and '2025-07-06'
    and u.app_name = 'BeautyPlus'
    and a.event_name in ('page_event','subscription_try_suc')
    and a.sub_user_type in ('1','2','4')
    and a.country='Türkiye'
group by
    1,2,3,4,5,6,7

union all

select
    '3:sub suc' event_name
    ,a.date
    ,case when a.date between '2025-06-13' and '2025-06-19' then '0613-0619'
          when a.date between '2025-06-21' and '2025-06-27' then '0621-0627'
    end period
    ,a.platform
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct a.user_pseudo_id) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2025-05-31' and '2025-07-06'
    and u.event_date_hk between '2025-05-31' and '2025-07-06'
    and u.app_name = 'BeautyPlus'
    and a.event_name in ('subscription_try_suc')
    and a.standard_order_date is not null
    and a.sub_user_type in ('1','2','4')
    and a.country='Türkiye'
group by
    1,2,3,4,5,6,7

union all

select
    '4:sub to paid' event_name
    ,a.date
    ,case when a.date between '2025-06-13' and '2025-06-19' then '0613-0619'
          when a.date between '2025-06-21' and '2025-06-27' then '0621-0627'
    end period
    ,a.platform
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sku_type
    ,count(distinct a.user_pseudo_id) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2025-05-31' and '2025-07-06'
    and u.event_date_hk between '2025-05-31' and '2025-07-06'
    and u.app_name = 'BeautyPlus'
    and a.event_name in ('subscription_try_suc')
    and a.standard_order_date is not null and purchase_date is not null
    and a.sub_user_type in ('1','2','4')
    and a.country='Türkiye'
group by
    1,2,3,4,5,6,7

union all

select
    '5:sub to paid bookings' event_name
    ,a.date
    ,case when a.date between '2025-06-13' and '2025-06-19' then '0613-0619'
          when a.date between '2025-06-21' and '2025-06-27' then '0621-0627'
    end period
    ,a.platform
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
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
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2025-05-31' and '2025-07-06'
    and u.event_date_hk between '2025-05-31' and '2025-07-06'
    and u.app_name = 'BeautyPlus'
    and a.event_name in ('subscription_try_suc')
    and a.standard_order_date is not null and purchase_date is not null
    and a.sub_user_type in ('1','2','4')
    and a.country='Türkiye'
group by
    1,2,3,4,5,6,7
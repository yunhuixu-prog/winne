with subscription_event as
(
    select
          a.*except(sku_has_trial,country,sub_user_type)
          ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
               else 'no_trial'
          end sku_has_trial
          ,case when sub_user_type='1' then '新用户'
                when sub_user_type='2' then '普通用户'
                when sub_user_type='3' then '耐用型商品单项购买用户'
                when sub_user_type='4' then '再订阅用户'
                when sub_user_type='5' then '试用期用户'
                when sub_user_type='6' then '付费期用户'
                else sub_user_type
                end sub_user_type
          ,case when date between '2025-02-11' and '2025-02-17' then '25 情人节 2025.02.11 - 2025.02.17'
                when date between '2025-02-04' and '2025-02-10' then '25 情人节Benchmark  2025.02.04 - 2025.02.10'
                when date between '2025-01-28' and '2025-02-03' then '25 春节 2025.01.28 - 2025.02.03'
                when date between '2025-01-21' and '2025-01-27' then '25 Benchmark 2025.01.21 - 2025.01.27'
                when date between '2024-02-09' and '2024-02-15' then '24 情人/狂欢/春节 2024.02.09 - 2024.02.15'
                when date between '2024-02-02' and '2024-02-08' then '24 Benchmark 2024.02.02 - 2024.02.08'
                when date between '2023-01-21' and '2023-01-27' then '23 春节 2023.01.21 - 2023.01.27'
                when date between '2023-01-14' and '2023-01-20' then '23 Benchmark 2023.01.14 - 2023.01.20'
                end date_label
          ,case when u.country in  ('Japan','South Korea','United States','Thailand','Indonesia','Vietnam') then u.country else 'other countries' end as country
          ,case when u.country in ('South Korea','Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '春节'
                when u.country in ('Mexico','Guatemala','Honduras','El Salvador','Nicaragua','Costa Rica','Panama','Cuba'
                    ,'Haiti','Dominican Republic','Jamaica','Trinidad & Tobago','Barbados','Grenada','St. Lucia'
                    ,'St. Kitts & Nevis','St. Vincent & Grenadines','Argentina','Bolivia','Brazil','Chile'
                    ,'Colombia','Ecuador','Guyana','Paraguay','Peru','Suriname','Uruguay','Venezuela','Belize'
                    ,'Dominica','Antigua & Barbuda','Bahamas') then '狂欢节'
                else '情人节' end as country_holiday
          ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
          ,u.is_UA
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
    join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
    on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
    WHERE
        ((a.date between '2025-02-11' and '2025-02-17') -- 本次七夕活动时间窗口
        or (date between '2025-02-04' and '2025-02-10')  -- 本次七夕活动Benchmark时间窗口
        or (date between '2025-01-28' and '2025-02-03')  -- 本次春节时间窗口：除夕-初六
        or (a.date between '2025-01-21' and '2025-01-27') -- 本次春节Benchmark时间窗口
        or (a.date between '2024-02-09' and '2024-02-15') -- 去年春节时间窗口：除夕-初六，实际春节活动窗口2.9-2.14，包含情人节2.14，狂欢节2.10-2.15，其中春节开放韩国东南亚，情人节开放除韩国东南亚拉美，狂欢节开放拉美，无试用+8折(东南亚75折)
        or (a.date between '2024-02-02' and '2024-02-08') -- 去年活动Benchmark时间窗口
        or (a.date between '2023-01-21' and '2023-01-27') -- 前年春节时间窗口：除夕-初六，推测实际春节活动窗口1.20-1.26
        or (a.date between '2023-01-14' and '2023-01-20') -- 前年活动Benchmark时间窗口
        )
    and u.app_name = 'BeautyPlus'
)

SELECT
--     a.event_date_hk as date,
    case
        when event_date_hk between '2025-02-11' and '2025-02-17' then '25 情人节 2025.02.11 - 2025.02.17'
        when event_date_hk between '2025-02-04' and '2025-02-10' then '25 情人节Benchmark  2025.02.04 - 2025.02.10'
        when event_date_hk between '2025-01-28' and '2025-02-03' then '25 春节 2025.01.28 - 2025.02.03'
        when event_date_hk between '2025-01-21' and '2025-01-27' then '25 Benchmark 2025.01.21 - 2025.01.27'
        when event_date_hk between '2024-02-09' and '2024-02-15' then '24 情人/狂欢/春节 2024.02.09 - 2024.02.15'
        when event_date_hk between '2024-02-02' and '2024-02-08' then '24 Benchmark 2024.02.02 - 2024.02.08'
        when event_date_hk between '2023-01-21' and '2023-01-27' then '23 春节 2023.01.21 - 2023.01.27'
        when event_date_hk between '2023-01-14' and '2023-01-20' then '23 Benchmark 2023.01.14 - 2023.01.20'
        end date_label,
    a.platform,
    case when is_new=1 then 'New-user' else 'Old-user' end as is_new,
    is_UA,
    case when country in  ('Japan','South Korea','United States','Thailand','Indonesia','Vietnam') then country else 'other countries' end as country,
    case when country in ('South Korea','Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '春节'
        when country in ('Mexico','Guatemala','Honduras','El Salvador','Nicaragua','Costa Rica','Panama','Cuba'
            ,'Haiti','Dominican Republic','Jamaica','Trinidad & Tobago','Barbados','Grenada','St. Lucia'
            ,'St. Kitts & Nevis','St. Vincent & Grenadines','Argentina','Bolivia','Brazil','Chile'
            ,'Colombia','Ecuador','Guyana','Paraguay','Peru','Suriname','Uruguay','Venezuela','Belize'
            ,'Dominica','Antigua & Barbuda','Bahamas') then '狂欢节'
        else '情人节' end as country_holiday,
    'null' sku_type,
    'null' sku_has_trial,
    'null' sub_user_type,
    '0:dau' as event_name,
    count(distinct a.user_pseudo_id) value
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`  a
where
    ((a.event_date_hk between '2025-02-11' and '2025-02-17') -- 本次七夕活动时间窗口
        or (event_date_hk between '2025-02-04' and '2025-02-10')  -- 本次七夕活动Benchmark时间窗口
        or (event_date_hk between '2025-01-28' and '2025-02-03')  -- 本次春节时间窗口：除夕-初六
        or (a.event_date_hk between '2025-01-21' and '2025-01-27') -- 本次春节Benchmark时间窗口
        or (a.event_date_hk between '2024-02-09' and '2024-02-15') -- 去年春节时间窗口：除夕-初六，实际春节活动窗口2.9-2.14，包含情人节2.14，狂欢节2.10-2.15，其中春节开放韩国东南亚，情人节开放除韩国东南亚拉美，狂欢节开放拉美，无试用+8折(东南亚75折)
        or (a.event_date_hk between '2024-02-02' and '2024-02-08') -- 去年活动Benchmark时间窗口
        or (a.event_date_hk between '2023-01-21' and '2023-01-27') -- 前年春节时间窗口：除夕-初六，推测实际春节活动窗口1.20-1.26
        or (a.event_date_hk between '2023-01-14' and '2023-01-20')) -- 前年活动Benchmark时间窗口
    and a.app_name = 'BeautyPlus'
group by 1,2,3,4,5,6,7,8,9,10 --,11

union all
SELECT
--     date,
    date_label,
    platform,
    is_new,
    is_UA,
    country,
    country_holiday,
    sku_type,
    sku_has_trial,
    sub_user_type,
    case when  event_name in ('page_event') then '1:sub enter'
         when  event_name in ('subscription_clk_try') then '2:sub click'
         end as event_name,
    count(distinct user_pseudo_id) value
FROM subscription_event
where event_name in ('page_event','subscription_clk_try')
group by 1,2,3,4,5,6,7,8,9,10 --,11

union all
SELECT
--     date,
    date_label,
    platform,
    is_new,
    is_UA,
    country,
    country_holiday,
    sku_type,
    sku_has_trial,
    sub_user_type,
    '3:sub suc' event_name,
    count(distinct user_pseudo_id) value
FROM subscription_event
where event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3,4,5,6,7,8,9,10 --,11

union all
SELECT
--     date,
    date_label,
    platform,
    is_new,
    is_UA,
    country,
    country_holiday,
    sku_type,
    sku_has_trial,
    sub_user_type,
    '4:sub suc to paid' event_name,
    count(distinct user_pseudo_id) value
FROM subscription_event
where event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
group by 1,2,3,4,5,6,7,8,9,10 --,11

union all
SELECT
--     date,
    date_label,
    platform,
    is_new,
    is_UA,
    country,
    country_holiday,
    sku_type,
    sku_has_trial,
    sub_user_type,
    '5:sub suc to paid revenue' event_name,
    round(sum(payment_price_usd),2) value
FROM subscription_event
where event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
group by 1,2,3,4,5,6,7,8,9,10 --,11

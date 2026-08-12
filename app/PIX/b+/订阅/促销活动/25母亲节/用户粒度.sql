-- 到用户粒度的数据，主要取用户类型
select
    case when event_name='page_event' then '1:sub_enter'
         when event_name='subscription_clk_try' then '2:sub_click'
    end event_name
    ,date
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,a.platform
    ,u.is_UA
    ,sku_type
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
       else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('Japan','Thailand','South Korea','United States') then u.country else 'other countries' end as country
    ,case   when u.country in ('Indonesia', 'Philippines', 'Brazil', 'Turkey', 'South Korea') then '实验国家'
            else '正常活动国家'
            end country_holiday
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,count(distinct a.user_pseudo_id) uv
    ,0.0 revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
on  a.sku=s.product_id
    and a.platform=s.platform
    and (s.product_type='subscription'
        and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    ((date between '2025-05-09' and '2025-05-13') -- 本次活动时间窗口，周五-周二
    or (date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-10' and '2024-05-14') -- 上次活动时间窗口，实际未做促销
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and u.app_name = 'BeautyPlus'
    and event_name in ('page_event','subscription_clk_try')
group by
    1,2,3,4,5,6,7,8,9,10

union all

select
    '3:sub_suc' event_name
    ,date
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,a.platform
    ,u.is_UA
    ,sku_type
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
       else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('Japan','Thailand','South Korea','United States') then u.country else 'other countries' end as country
    ,case   when u.country in ('Indonesia', 'Philippines', 'Brazil', 'Turkey', 'South Korea') then '实验国家'
            else '正常活动国家'
            end country_holiday
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,count(distinct a.user_pseudo_id) uv
    ,0.0 revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
on  a.sku=s.product_id
    and a.platform=s.platform
    and (s.product_type='subscription'
        and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    ((date between '2025-05-09' and '2025-05-13') -- 本次活动时间窗口，周五-周二
    or (date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-10' and '2024-05-14') -- 上次活动时间窗口，实际未做促销
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and u.app_name = 'BeautyPlus'
    and event_name='subscription_try_suc' and standard_order_date is not null --and purchase_date is not null
group by
    1,2,3,4,5,6,7,8,9,10

union all

select
    '4:sub_suc_to_paid' event_name
    ,date
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,a.platform
    ,u.is_UA
    ,sku_type
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
       else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('Japan','Thailand','South Korea','United States') then u.country else 'other countries' end as country
    ,case   when u.country in ('Indonesia', 'Philippines', 'Brazil', 'Turkey', 'South Korea') then '实验国家'
            else '正常活动国家'
            end country_holiday
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,count(distinct a.user_pseudo_id) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
on  a.sku=s.product_id
    and a.platform=s.platform
    and (s.product_type='subscription'
        and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    ((date between '2025-05-09' and '2025-05-13') -- 本次活动时间窗口，周五-周二
    or (date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-10' and '2024-05-14') -- 上次活动时间窗口，实际未做促销
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and u.app_name = 'BeautyPlus'
    and event_name='subscription_try_suc' and standard_order_date is not null and purchase_date is not null
group by
    1,2,3,4,5,6,7,8,9,10

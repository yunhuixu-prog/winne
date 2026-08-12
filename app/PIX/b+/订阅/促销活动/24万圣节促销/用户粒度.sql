-- 到用户粒度的数据，主要取用户类型
select
    event_name
    ,date
    ,case   when date between '2024-10-26' and '2024-11-01' then '24 万圣节: 2024.10.26 - 2024.11.01'
            when date between '2024-10-19' and '2024-10-25' then '24 Benchmark: 2024.10.19 - 2024.10.25'
            when date between '2023-10-27' and '2023-11-02' then '23 万圣节: 2023.10.27 - 2023.11.02'
            end date_label
    ,a.platform
    ,case when country in ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sku_type
    ,sku_has_trial
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,price
    ,sku
    ,count(distinct user_pseudo_id) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
    left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
    on  a.sku=s.product_id
        and a.platform=s.platform
        and (s.product_type='subscription'
            and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    ((date between '2024-10-26' and '2024-11-01') -- 本次活动时间窗口
    or (date between '2024-10-19' and '2024-10-25') -- 本次活动Benchmark时间窗口
    or (date between '2023-10-27' and '2023-11-02')) -- 上次活动时间窗口
    and standard_order_date is not null and purchase_date is not null
group by
    1,2,3,4,5,6,7,7,8,9,10
-- 可以分国家，分订阅sku
select
    event_name
    ,date
    ,case   when date between '2025-02-11' and '2025-02-17' then '25 情人节 2025.02.11 - 2025.02.17'
            when date between '2025-02-04' and '2025-02-10' then '25 Benchmark 2025.02.04 - 2025.02.10'
            when date between '2024-02-09' and '2024-02-15' then '24 情人/狂欢/春节 2024.02.09 - 2024.02.15'
            when date between '2024-02-02' and '2024-02-08' then '24 Benchmark 2024.02.02 - 2024.02.08'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,case when country in ('South Korea','Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '春节'
                when country in ('Mexico','Guatemala','Honduras','El Salvador','Nicaragua','Costa Rica','Panama','Cuba'
                    ,'Haiti','Dominican Republic','Jamaica','Trinidad & Tobago','Barbados','Grenada','St. Lucia'
                    ,'St. Kitts & Nevis','St. Vincent & Grenadines','Argentina','Bolivia','Brazil','Chile'
                    ,'Colombia','Ecuador','Guyana','Paraguay','Peru','Suriname','Uruguay','Venezuela','Belize'
                    ,'Dominica','Antigua & Barbuda','Bahamas') then '狂欢节'
                else '情人节' end as country_holiday
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
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
    left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
    on  a.sku=s.product_id
        and a.platform=s.platform
        and (s.product_type='subscription'
            and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    ((date between '2025-02-11' and '2025-02-17') -- 本次活动时间窗口：周二-周一，实际活动13-17
    or (date between '2025-02-04' and '2025-02-10') -- 本次活动Benchmark时间窗口：周二-周一
    or (date between '2024-02-09' and '2024-02-15') -- 上次活动时间窗口：周五-周四
    or (date between '2024-02-02' and '2024-02-08')) -- 上次活动Benchmark时间窗口：周五-周四
    and data_type='event_and_sku' and event_name in ('dau','enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid')
group by
    1,2,3,4,5,6,7,7,8,9,10,11,12,13
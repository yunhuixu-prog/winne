-- 可以分国家，分订阅sku
select
    event_name
    ,date
    ,case   when date between '2025-04-18' and '2025-04-21' then '25 复活节 2025.04.18 - 2025.04.21'
            when date between '2025-04-11' and '2025-04-14' then '25 Benchmark 2025.04.11 - 2025.04.14'
            when date between '2024-03-29' and '2024-04-01' then '24 复活节 2024.03.29 - 2024.04.01'
            when date between '2024-03-22' and '2024-03-25' then '24 Benchmark 2024.03.22 - 2024.03.25'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,case   when country in ('United States','Canada') then '北美洲'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧盟' --'欧盟国家'
            when country in ('Mexico', 'Brazil', 'Argentina', 'Colombia', 'Peru') then '拉丁美洲'
            when country in ('Australia', 'New Zealand') then '大洋洲'
            when country in ('Philippines', 'Lebanon') then '亚洲'
            else '非活动国家'
            end country_holiday
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
    ((date between '2025-04-18' and '2025-04-21') -- 本次活动时间窗口
    or (date between '2025-04-11' and '2025-04-14') -- 本次活动Benchmark时间窗口
    or (date between '2024-03-29' and '2024-04-01') -- 上次活动时间窗口，真实窗口：3.31-4.1
    or (date between '2024-03-22' and '2024-03-25')) -- 上次活动Benchmark时间窗口
    and data_type='event_and_sku' and event_name in ('dau','enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid')
group by
    1,2,3,4,5,6,7,7,8,9,10,11,12,13
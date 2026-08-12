-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2025-04-18' and '2025-04-21' then '25 复活节 2025.04.18 - 2025.04.21'
            when date between '2025-04-11' and '2025-04-14' then '25 Benchmark 2025.04.11 - 2025.04.14'
            when date between '2024-03-29' and '2024-04-01' then '24 复活节 2024.03.29 - 2024.04.01'
            when date between '2024-03-22' and '2024-03-25' then '24 Benchmark 2024.03.22 - 2024.03.25'
            end date_label
    ,a.platform
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
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
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2025-04-18' and '2025-04-21') -- 本次活动时间窗口
    or (date between '2025-04-11' and '2025-04-14') -- 本次活动Benchmark时间窗口
    or (date between '2024-03-29' and '2024-04-01') -- 上次活动时间窗口，真实窗口：3.31-4.1
    or (date between '2024-03-22' and '2024-03-25')) -- 上次活动Benchmark时间窗口
    and data_type= 'event'
group by
    1,2,3,4,5,6
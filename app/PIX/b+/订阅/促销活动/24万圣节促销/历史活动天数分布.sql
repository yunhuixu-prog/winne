-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-10-26' and '2024-11-01' then '24 万圣节: 2024.10.26 - 2024.11.01'
            when date between '2023-10-27' and '2023-11-02' then '23 万圣节: 2023.10.27 - 2023.11.02'
            when date between '2023-12-22' and '2023-12-26' then '23 圣诞节: 2023.12.22 - 2023.12.26'
            when date between '2023-12-29' and '2024-01-03' then '24 新年: 2023.12.29 - 2024.01.03'
            when date between '2024-02-09' and '2024-02-14' then '24 春节等: 2024.02.09 - 2024.02.14'
            when date between '2024-03-08' and '2024-03-10' then '24 妇女节: 2024.03.08 - 2024.03.10'
            end date_label
    ,case   when date between '2024-10-26' and '2024-11-01' then date_diff(date,'2024-10-26',day)
            when date between '2023-10-27' and '2023-11-02' then date_diff(date,'2023-10-27',day)
            when date between '2023-12-22' and '2023-12-26' then date_diff(date,'2023-12-22',day)
            when date between '2023-12-29' and '2024-01-03' then date_diff(date,'2023-12-29',day)
            when date between '2024-02-09' and '2024-02-14' then date_diff(date,'2024-02-09',day)
            when date between '2024-03-08' and '2024-03-10' then date_diff(date,'2024-03-08',day)
            end days
--     ,a.platform
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-10-26' and '2024-11-01') -- 24万圣节
    or (date between '2023-10-27' and '2023-11-02') -- 23万圣节
    or (date between '2023-12-22' and '2023-12-26') -- 23圣诞节
    or (date between '2023-12-29' and '2024-01-03') -- 24新年
    or (date between '2024-02-09' and '2024-02-14') -- 24春节/情人节/狂欢节
    or (date between '2024-03-08' and '2024-03-10')) -- 24妇女节
    and data_type= 'event'
group by
    1,2,3,4
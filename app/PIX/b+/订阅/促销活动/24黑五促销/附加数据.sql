-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-11-29' and '2024-12-03' then '6 24 黑五 2024.11.29 - 2024.12.03'
            when date between '2024-11-22' and '2024-11-26' then '5 24 Benchmark 2024.11.22 - 2024.11.26'
            when date between '2023-11-24' and '2023-11-28' then '2 23 黑五 2023.11.24 - 2023.11.28'
            when date between '2023-11-17' and '2023-11-21' then '1 23 Benchmark 2023.11.17 - 2023.11.21'
            when date between '2024-10-25' and '2024-10-29' then '4 24 万圣节 2024.10.25 - 2024.10.29'
            when date between '2024-10-18' and '2024-10-22' then '3 24 Benchmark 2024.10.18 - 2024.10.22'
            end date_label
    ,a.platform
    ,is_ua
--     ,is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sum(uv) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-11-29' and '2024-12-03') -- 本次活动时间窗口
    or (date between '2024-11-22' and '2024-11-26') -- 本次活动Benchmark时间窗口
    or (date between '2023-11-24' and '2023-11-28') -- 上次活动时间窗口：实际窗口11.24～11.27
    or (date between '2023-11-17' and '2023-11-21')
    or (date between '2024-10-25' and '2024-10-29')
    or (date between '2024-10-18' and '2024-10-22'))
    and data_type= 'user_type'
--     and data_type= 'event'
    and sub_user_type='1'
    and event_name in ('dau','sub_suc','sub_to_paid')
group by
    1,2,3,4,5,6,7


union all

select
    'sub_to_paid revenue' event_name
    ,date
    ,case   when date between '2024-11-29' and '2024-12-03' then '6 24 黑五 2024.11.29 - 2024.12.03'
            when date between '2024-11-22' and '2024-11-26' then '5 24 Benchmark 2024.11.22 - 2024.11.26'
            when date between '2023-11-24' and '2023-11-28' then '2 23 黑五 2023.11.24 - 2023.11.28'
            when date between '2023-11-17' and '2023-11-21' then '1 23 Benchmark 2023.11.17 - 2023.11.21'
            when date between '2024-10-25' and '2024-10-29' then '4 24 万圣节 2024.10.25 - 2024.10.29'
            when date between '2024-10-18' and '2024-10-22' then '3 24 Benchmark 2024.10.18 - 2024.10.22'
            end date_label
    ,a.platform
    ,is_ua
--     ,is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-11-29' and '2024-12-03') -- 本次活动时间窗口
    or (date between '2024-11-22' and '2024-11-26') -- 本次活动Benchmark时间窗口
    or (date between '2023-11-24' and '2023-11-28') -- 上次活动时间窗口：实际窗口11.24～11.27
    or (date between '2023-11-17' and '2023-11-21')
    or (date between '2024-10-25' and '2024-10-29')
    or (date between '2024-10-18' and '2024-10-22'))
    and data_type= 'user_type'
--     and data_type= 'event'
    and event_name in ('sub_to_paid')
    and sub_user_type='1'
group by
    1,2,3,4,5,6,7

union all

-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-11-29' and '2024-12-03' then '6 24 黑五 2024.11.29 - 2024.12.03'
            when date between '2024-11-22' and '2024-11-26' then '5 24 Benchmark 2024.11.22 - 2024.11.26'
            when date between '2023-11-24' and '2023-11-28' then '2 23 黑五 2023.11.24 - 2023.11.28'
            when date between '2023-11-17' and '2023-11-21' then '1 23 Benchmark 2023.11.17 - 2023.11.21'
            when date between '2024-10-25' and '2024-10-29' then '4 24 万圣节 2024.10.25 - 2024.10.29'
            when date between '2024-10-18' and '2024-10-22' then '3 24 Benchmark 2024.10.18 - 2024.10.22'
            end date_label
    ,a.platform
    ,is_ua
--     ,is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,sum(uv) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-11-29' and '2024-12-03') -- 本次活动时间窗口
    or (date between '2024-11-22' and '2024-11-26') -- 本次活动Benchmark时间窗口
    or (date between '2023-11-24' and '2023-11-28') -- 上次活动时间窗口：实际窗口11.24～11.27
    or (date between '2023-11-17' and '2023-11-21')
    or (date between '2024-10-25' and '2024-10-29')
    or (date between '2024-10-18' and '2024-10-22'))
--     and data_type= 'user_type'
    and data_type= 'event'
    and event_name in ('dau')
group by
    1,2,3,4,5,6,7

union all

select 'dau' event_name
    ,event_date_hk date
    ,case   when event_date_hk between '2024-11-29' and '2024-12-03' then '6 24 黑五 2024.11.29 - 2024.12.03'
            when event_date_hk between '2024-11-22' and '2024-11-26' then '5 24 Benchmark 2024.11.22 - 2024.11.26'
            when event_date_hk between '2023-11-24' and '2023-11-28' then '2 23 黑五 2023.11.24 - 2023.11.28'
            when event_date_hk between '2023-11-17' and '2023-11-21' then '1 23 Benchmark 2023.11.17 - 2023.11.21'
            when event_date_hk between '2024-10-25' and '2024-10-29' then '4 24 万圣节 2024.10.25 - 2024.10.29'
            when event_date_hk between '2024-10-18' and '2024-10-22' then '3 24 Benchmark 2024.10.18 - 2024.10.22'
            end date_label
    ,platform
    ,is_ua
--     ,is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,'' sub_user_type
    ,count(distinct user_pseudo_id) value
from beautyplus-bc0ed.temp.temp_new_users_three
where
    ((event_date_hk between '2024-11-29' and '2024-12-03') -- 本次活动时间窗口
    or (event_date_hk between '2024-11-22' and '2024-11-26') -- 本次活动Benchmark时间窗口
    or (event_date_hk between '2023-11-24' and '2023-11-28') -- 上次活动时间窗口：实际窗口11.24～11.27
    or (event_date_hk between '2023-11-17' and '2023-11-21')
    or (event_date_hk between '2024-10-25' and '2024-10-29')
    or (event_date_hk between '2024-10-18' and '2024-10-22'))
group by
    1,2,3,4,5,6,7

;
drop table if exists beautyplus-bc0ed.temp.temp_new_users_three;
create table beautyplus-bc0ed.temp.temp_new_users_three as

select bb.*
from
(
    select a.date event_date_hk,b.user_pseudo_id
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2023-10-01' and '2024-12-10'
    ) a
    cross join
    (
        select user_pseudo_id,event_date_hk
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between DATE_SUB('2023-10-01', INTERVAL 2 DAY) and '2024-12-10'
           and app_name in ('BeautyPlus') and is_new=1
    ) b
    where b.event_date_hk between DATE_SUB(a.date, INTERVAL 2 DAY) and a.date
    group by 1,2
) aa
join
(
    select user_pseudo_id,event_date_hk,platform,is_ua,country
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-10-01' and '2024-12-10'
       and app_name in ('BeautyPlus')
) bb
on aa.event_date_hk=bb.event_date_hk and aa.user_pseudo_id=bb.user_pseudo_id




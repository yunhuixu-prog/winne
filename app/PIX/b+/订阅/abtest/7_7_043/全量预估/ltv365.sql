with
abcode as
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as device_id
    , country_id
    , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        (date_p>='2024-01-18' and date_p<='2024-02-08')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
subscription_event_temp as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        (date>='2024-01-18' and date<='2024-02-08')
        and device_id is not null
        -- and source2<>'OnboardingPage'
)
,
subscription_event as
(
    select *except(country),case when country in ('United States','Japan','Vietnam','South Korea','Thailand') then country else 'else' end country
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        (date>='2023-01-01' and date<='2024-03-05')
        and standard_order_date is not null and purchase_date is not null
            and event_name in ('subscription_try_suc')
--         (date>='2024-01-18' and date<='2024-02-14')
--         and device_id is not null
        -- and source2<>'OnboardingPage'
)
,
user_user_tag as
(
    select
        m.platform,
        m.device_id ,
        min_by(sub_user_type,date) sub_user_type
    from
        subscription_event_temp m
    join abcode a on m.device_id=a.device_id  and m.platform=a.platform and m.date>=a.date_p
    group by
        1,2
)
,
ab_sub_event as
(
select distinct
    a.platform,
    a.country,
    case
       when u.code in ('10493') then '对照组'
       when u.code in ('10494') then '实验组A'
       when u.code in ('10495') then '实验组B'
    end as code,
    a.sku_type,
    a.sku_has_trial,
    a.sku,
    a.sku_tag,
    t.sub_user_type,
--     a.user_pseudo_id,
--     a.device_id,
    a.payment_price_usd,
    a.original_order_id,
--     purchase_date,
--     standard_order_date
    from
        (SELECT *
        FROM
            subscription_event
        where (date>='2024-01-18' and date<='2024-02-08')
            and device_id is not null
        )a
    --关联实验时机
    join abcode u
    on a.device_id=u.device_id  and a.event_timestamp>=u.timestamp-15000000
    left join user_user_tag t on a.device_id=t.device_id and a.platform=t.platform
)
,
sku as
(
    select s.platform,s.country,s.sku_type,s.sku_has_trial,s.sku,s.sub_user_type,s.original_order_id
    from subscription_event s
    join (select distinct sku from ab_sub_event) a on s.sku=a.sku
)
,
sku_type as
(
    select s.platform,s.country,s.sku_type,s.sku_has_trial,s.sku,s.sub_user_type,s.original_order_id
    from subscription_event s
)
,
renewal_uv as
(
    select original_order_id
       , min(standard_order_date)        order_start_date
       , count(distinct order_id)        order_num
       , min(order_id)                   min_order
       , max(order_id)                   max_order
       , max(standard_order_expire_date) standard_order_expire_date
       , sum(payment_price_usd)          payment_usd
       , sum(case when date_diff(standard_order_date,original_order_date,DAY)<=365 then payment_price_usd end) payment_usd_365
       , max(platform)                   platform
       , max(country)                    country
       , min(sku)                        min_sku
       , max(sku)                        max_sku
    from
    (
        select *,min(standard_order_date) over(partition by original_order_id) original_order_date
        from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
        where app_id='BeautyPlus'
        and order_status in (1,2)
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
    )
    group by 1
)
,
-- 实验订单续费率
order_id_renewal as
(
    select r.order_start_date, r.standard_order_expire_date, r.original_order_id
           , s.code
           , s.platform, s.country, s.sku_type
           , s.sku_has_trial, s.sku, s.sub_user_type
           , r.order_num, r.min_order, r.max_order, r.payment_usd, r.min_sku, r.max_sku
    from ab_sub_event s
    join renewal_uv r on s.original_order_id=r.original_order_id
)
,
-- 历史sku订单续费率
sku_renewal as
(
    select r.order_start_date, r.standard_order_expire_date, r.original_order_id
           , s.platform, s.country, s.sku_type
           , s.sku_has_trial, s.sku, s.sub_user_type
           , r.order_num, r.min_order, r.max_order, r.payment_usd, r.payment_usd_365, r.min_sku, r.max_sku
    from sku s
    join renewal_uv r on s.original_order_id=r.original_order_id
)
,
sku_type_renewal as
(
    select r.order_start_date, r.standard_order_expire_date, r.original_order_id
           , s.platform, s.country, s.sku_type
           , s.sku_has_trial, s.sku, s.sub_user_type
           , r.order_num, r.min_order, r.max_order, r.payment_usd, r.payment_usd_365, r.min_sku, r.max_sku
    from sku_type s
    join renewal_uv r on s.original_order_id=r.original_order_id
)

-- -- 实验订单和单价
-- select *except(payment_price_usd),round(payment_price_usd,2) payment_price
-- from ab_sub_event;
--
-- -- 对数
-- select code,sub_user_type,round(sum(payment_price_usd),2)
-- from ab_sub_event
-- group by 1,2
-- order by 1,2;

-- -- 续费率
-- -- 新SKU现有续费率
-- select code,sku_type,sku_has_trial,sub_user_type
--         ,count(distinct original_order_id) order_num
--         ,count(distinct case when order_num>=2 then original_order_id end) renewal_1
-- --         ,round(sum(payment_usd)/count(distinct original_order_id),2) payment_usd
--         ,round(sum(payment_usd)/sum(order_num),2) price
-- from order_id_renewal
-- where code in ('实验组A','实验组B','对照组')
-- and order_start_date<='2024-02-04'
-- and sub_user_type in ('1','2') and sku_type='1m'
-- group by 1,2,3,4
-- order by 1,2,3,4;

-- -- 历史sku续费率
-- select
--         sku_type,sku_has_trial,sku,sub_user_type --,min(order_start_date)
-- --         ,platform,country
--         ,count(distinct original_order_id) order_num
--         ,count(distinct case when order_num>=2 then original_order_id end) renewal_1
--         ,count(distinct case when order_num>=3 then original_order_id end) renewal_2
--         ,count(distinct case when order_num>=4 then original_order_id end) renewal_3
--         ,count(distinct case when order_num>=5 then original_order_id end) renewal_4
--         ,count(distinct case when order_num>=6 then original_order_id end) renewal_5
--         ,count(distinct case when order_num>=7 then original_order_id end) renewal_6
--         ,round(sum(payment_usd)/sum(order_num),2) price
-- --         ,count(distinct case when order_num>=8 then original_order_id end) renewal_7
-- --         ,count(distinct case when order_num>=9 then original_order_id end) renewal_8
-- --         ,count(distinct case when order_num>=10 then original_order_id end) renewal_9
-- --         ,count(distinct case when order_num>=11 then original_order_id end) renewal_10
-- --         ,count(distinct case when order_num>=12 then original_order_id end) renewal_11
-- --         ,round(sum(payment_usd)/count(distinct original_order_id),2) payment_usd
-- --         ,round(sum(payment_usd_365)/count(distinct original_order_id),2) payment_usd_365
-- from sku_renewal
-- where platform='IOS'
-- and order_start_date between '2023-01-01' and '2023-09-04'
-- and sub_user_type in ('1','2') and sku_type='1m'
-- group by 1,2,3,4
-- order by 1,2,3,4;


-- -- 历史sku类续费率
-- select
--         sku_type,sku_has_trial,sub_user_type
-- --         ,platform,country
--         ,count(distinct original_order_id) order_num
--         ,count(distinct case when order_num>=2 then original_order_id end) renewal_1
--         ,count(distinct case when order_num>=3 then original_order_id end) renewal_2
--         ,count(distinct case when order_num>=4 then original_order_id end) renewal_3
--         ,count(distinct case when order_num>=5 then original_order_id end) renewal_4
--         ,count(distinct case when order_num>=6 then original_order_id end) renewal_5
--         ,count(distinct case when order_num>=7 then original_order_id end) renewal_6
-- --         ,round(sum(payment_usd)/sum(order_num),2) price
-- --         ,count(distinct case when order_num>=8 then original_order_id end) renewal_7
-- --         ,count(distinct case when order_num>=9 then original_order_id end) renewal_8
-- --         ,count(distinct case when order_num>=10 then original_order_id end) renewal_9
-- --         ,count(distinct case when order_num>=11 then original_order_id end) renewal_10
-- --         ,count(distinct case when order_num>=12 then original_order_id end) renewal_11
-- --         ,round(sum(payment_usd)/count(distinct original_order_id),2) payment_usd
-- --         ,round(sum(payment_usd_365)/count(distinct original_order_id),2) payment_usd_365
-- from sku_type_renewal
-- where platform='IOS' and order_start_date between '2023-01-01' and '2023-09-04'
-- --   and sub_user_type in ('1','2')
--   and sku_type='1m'
-- group by 1,2,3
-- order by 1,2,3;


-- LTV365预估
select code,platform,country,sku_type,sub_user_type
        ,count(distinct original_order_id) order_num
        ,round(sum(payment_price_usd),2) payment_price
        ,round(sum(payment_price_usd),2) renewal_365
from ab_sub_event
where sku_type!='1m'
group by 1,2,3,4,5

union all

select a.code,a.platform,a.country,sku_type,a.sub_user_type
       ,count(distinct original_order_id) order_num
       ,round(sum(payment_price_usd),2) payment_price
       ,round(sum(payment_price_usd*coalesce(renewal,1)),2) payment_price_365
from
(
    select code,platform,country,sku_type,sku_has_trial,sku,sub_user_type
         ,original_order_id,payment_price_usd
         ,case when sku='beautyplus.subs.month1.func00.lev00.ver27' then 4.474001505
               when sku='beautyplus.subs.month1.func00.lev00.ver28' then 4.455887658
               when sku='beautyplus.subs.month1.func00.lev00.ver29' then 4.527727654
               when sku='beautyplus.subs.month1.func00.lev00.ver30' then 2.971673049
               when sku='beautyplus.subs.month1.func00.lev00.ver31' then 3.580801505
               when sku='beautyplus.subs.month1.func00.lev00.ver32' then 4.004959964
               when code='对照组' and sku_has_trial='no_trial' and sub_user_type='1' then 3.358529199
               when code='对照组' and sku_has_trial='no_trial' and sub_user_type='2' then 4.562587658
               when code='实验组A' and sku_has_trial='no_trial' and sub_user_type='1' then 2.209521396
               when code='实验组A' and sku_has_trial='no_trial' and sub_user_type='2' then 2.686629789
               when code='实验组B' and sku_has_trial='no_trial' and sub_user_type='1' then 2.176170129
               when code='实验组B' and sku_has_trial='no_trial' and sub_user_type='2' then 3.480406773
        end renewal
    from ab_sub_event
    where sku_type='1m'
) a
group by 1,2,3,4,5



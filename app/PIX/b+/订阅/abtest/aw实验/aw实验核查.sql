with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11096,11098) then '对照组'
               when ab_code in (11097,11099) then '实验组A'
        end code
        ,field device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,device_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.device_id
    where
        date_p between '2025-05-09' and '2025-05-14' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11096','11097','11098','11099')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,sub as (
     select
     a.date
    ,a.platform,a.user_pseudo_id,a.event_timestamp,case when s.category2='OnboardingPage' then 'OnboardingPage' else 'else' end source
    ,a.event_name,a.device_id,CAST(standard_order_date AS STRING FORMAT 'YYYYMMDD') standard_order_date,CAST(purchase_date AS STRING FORMAT 'YYYYMMDD') purchase_date
    ,payment_price_usd value,sku,case when u.is_new=1 then 'new user' else 'old user' end as is_new,u.country
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,unnest(agg) as s
    join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
    on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
    where date between '2025-05-09' and '2025-05-14'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.date,a.platform,a.event_name,a.device_id,a.source,a.standard_order_date,a.purchase_date,a.value,a.sku
           ,b.abcode,b.code,a.is_new,a.country
    from
        (
--         select * from eves
--         union all
        select * from sub
        )a
         join enter_test b on a.device_id= b.device_id
    where a.event_timestamp>=b.timestamp-15000000

    union all

    select
        a.date,a.platform,a.event_name,a.device_id,a.source,a.standard_order_date,a.purchase_date,a.value,a.sku
           ,null abcode,'未进入实验' code,a.is_new,a.country
    from
        (
--         select * from eves
--         union all
        select * from sub
        )a
        left join (select distinct s.device_id from sub s join enter_test e on s.device_id= e.device_id where s.event_timestamp>=e.timestamp-15000000) b
        on a.device_id= b.device_id
    where b.device_id is null

--     union all
--
--     select
--         a.date,a.platform,a.event_name,a.device_id,a.standard_order_date,a.purchase_date,a.value,a.sku
--            ,null abcode,'先有订阅行为后进入实验' code,a.is_new,a.country
--     from
--         (
-- --         select * from eves
-- --         union all
--         select * from sub
--         )a
--         join enter_test b on a.device_id= b.device_id
--     where a.event_timestamp<b.timestamp-15000000

    union all

    select event_date as date
        ,platform,'enter_abtest' event_name,device_id,cast(null as string) source
        ,'' standard_order_date,'' purchase_date,0 value,cast(null as string) sku
        ,abcode,code,is_new,country
    from enter_test
)

select
    a.date,a.platform,a.abcode,a.code,a.is_new
    ,case   when country in ('Indonesia','Philippines','Brazil','South Korea','Türkiye') then country
            else '其他'
            end country_group
    ,a.sku,a.source
    ,count(distinct case when a.event_name ='enter_abtest' then a.device_id end) enter_abtest_uv
    -- 付费
    ,count(distinct case when a.event_name ='page_event' then a.device_id end) sub_enter_uv
    ,count(distinct case when a.event_name ='subscription_clk_try' then a.device_id end) sub_click_uv
    ,count(distinct case when event_name= 'subscription_try_suc' and standard_order_date is not null then a.device_id end) sub_success_uv
    ,count(distinct case when event_name= 'subscription_try_suc' and standard_order_date is not null and  purchase_date is not null then a.device_id end) sub_success_to_paid_uv
    ,round(sum(case when event_name= 'subscription_try_suc' and standard_order_date is not null and  purchase_date is not null then value end),2) sub_success_to_paid_gmv

from fe a

group by 1,2,3,4,5,6,7,8





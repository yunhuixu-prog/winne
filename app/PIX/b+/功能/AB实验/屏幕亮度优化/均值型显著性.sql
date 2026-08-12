-- 显著性计算
-- 订阅收入、人均保存次数
with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11116,11118) then '对照组'
               when ab_code in (11117,11119) then '实验组A'
        end code
        ,field device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
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
        date_p between '2025-06-11' and '2025-06-24' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11116','11117','11118','11119')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,eves as (
select
     event_date_hk as date
    ,platform,user_pseudo_id,event_timestamp
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-06-11', '2025-06-24', 'BeautyPlus', false)
where
    event_name in (
--                 'beautifysave_bd',
--                 'puzzle_save_bd',
                'selfiesave_bd',
                'movecheck_save_bd',
                'arvideosave_bd',
--                 'video_edit_save_bd',
                'iphone_mode_save_bd',
                'stamp_cam_save_bd' ,
                'glow_cam_save_bd',
                'film_cam_save_bd')
)
,sub as (
     select
     date
    ,platform,user_pseudo_id,event_timestamp
    ,event_name,device_id
    ,payment_price_usd
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`--,unnest(agg) as s
    where date between '2025-06-11' and '2025-06-24'
        and event_name= 'subscription_try_suc' and standard_order_date is not null and  purchase_date is not null
)
-- ,act AS
-- (
--     SELECT distinct event_date_hk
--            , case when platform='IOS' then 'iOS' when platform='ANDROID' then 'Android' end platform
--            , real_device_id device_id, is_new, country --,user_pseudo_id
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
--     WHERE event_date_hk between '2025-06-11' and '2025-06-24'
--         AND app_name = 'BeautyPlus'
-- )
-- ,rs AS (
--
--     select
--         distinct fa.event_date_hk,fa.device_id,e.code
--     from act fa  -- 活跃天
--     join enter_test e  -- 进入实验当天
--     ON e.device_id = fa.device_id and e.event_date <= fa.event_date_hk
-- )
,fe_sub as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select b.device_id,sum(payment_price_usd) value
    from sub a
    join enter_test b on a.device_id= b.device_id
    where a.event_timestamp>=b.timestamp-15000000
        and a.platform='IOS'
    group by 1
)
,fe_save as ( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select a.date,b.code,b.device_id,count(1) value
    from eves a
    join enter_test b on a.device_id= b.device_id
    where a.event_timestamp>=b.timestamp-15000000
        and a.platform='IOS'
    group by 1,2,3
)

select a.code,'sub' types
     ,count(distinct a.device_id) computer_uv
     ,round(AVG(coalesce(b.value,0)),6) mean,round(STDDEV(coalesce(b.value,0)),4) std
from (select distinct device_id,code from enter_test) a
left join fe_sub b
on a.device_id=b.device_id
group by 1,2

union all

select b.code,'save' types
     ,count(b.device_id) computer_uv
     ,round(AVG(coalesce(b.value,0)),6) mean,round(STDDEV(coalesce(b.value,0)),4) std
from fe_save b
group by 1,2

order by 2,1

;
-- 广告收入
with enter_test as
(
    select
        date_p date
        ,ab_code abcode
        ,case when ab_code in (11116,11118) then '对照组'
               when ab_code in (11117,11119) then '实验组A'
        end code
        ,field user_pseudo_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,user_pseudo_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.user_pseudo_id
    where
        date_p between '2025-06-11' and '2025-06-24' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11116','11117','11118','11119')
        and field_type = 1  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
ads_revenue_pre as -- 仅包含 MAX 数据，Admob需要到`dataintegration-265403.advertisement.dws_dzp_ad_placement_info`取
(
    select
        user_pseudo_id
        ,sum(revenue) revenue
    from
        `dataintegration-265403.dwd.dwd_dzp_advertisement_max_user_detail` a
        join enter_test b on a.firebase_id = b.user_pseudo_id and timestamp_micros(b.timestamp) < timestamp(event_time)
    where
        event_date between '2025-06-11' and '2025-06-24' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and app_name='BeautyPlus'
        -- and placement in ('inter__album_portrait')
    group by
        1
)

select a.code,count(distinct a.user_pseudo_id) computer_uv,round(AVG(coalesce(b.revenue,0)),6) mean,round(STDDEV(coalesce(b.revenue,0)),4) std
from (select distinct user_pseudo_id,code from enter_test) a
left join ads_revenue_pre b
on a.user_pseudo_id=b.user_pseudo_id
group by 1



;
-- 过去7/30天内的人均活跃天数(基于的样本量和上面不太一样)
with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11116,11118) then '对照组'
               when ab_code in (11117,11119) then '实验组A'
        end code
        ,field user_pseudo_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,user_pseudo_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.user_pseudo_id
    where
        date_p between '2025-06-11' and '2025-06-24' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11116','11117','11118','11119')
        and field_type = 1  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,mact as (
    -- 取进入实验之后的每个日期
    select
        distinct a.event_date_hk,b.user_pseudo_id,b.abcode,b.code,b.min_event_date enter_abtest_date,b.platform,b.is_new,b.country
    from
    (
        select distinct event_date_hk
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2025-06-11' and '2025-06-24'
    ) a
    left join (select user_pseudo_id,abcode,code,min(event_date) min_event_date,min(platform) platform,min(is_new) is_new,min(country) country from enter_test group by 1,2,3) b
    on 1=1
    where b.min_event_date <= a.event_date_hk
)
,act as (
    -- 限制活跃用户的人为进入实验的人，，不需要限制进入实验后的日期，因为需要计算实验开始前几天再往前推的活跃天数
    select
        distinct a.platform,a.user_pseudo_id
        ,a.event_date_hk
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`a
    join enter_test b
    on a.user_pseudo_id = b.user_pseudo_id
    where a.app_name='BeautyPlus'
        and a.event_date_hk >= date_sub('2025-06-11',interval 30 day)
)

select
    code
    ,count(user_pseudo_id) computer_uv
    ,round(AVG(coalesce(days_7,0)),4) days_7_mean,round(STDDEV(coalesce(days_7,0)),4) days_7_std
    ,round(AVG(coalesce(days_30,0)),4) days_30_mean,round(STDDEV(coalesce(days_30,0)),4) days_30_std
from
  (
      select
         a.event_date_hk,a.enter_abtest_date,a.platform,a.is_new,a.user_pseudo_id,a.country,a.abcode,a.code
           ,count(distinct case when b.event_date_hk
                    between date_sub(a.event_date_hk,interval 6 day)
                    and a.event_date_hk then b.event_date_hk end) days_7
           ,count(distinct b.event_date_hk) days_30
      from mact a
      left join act b on a.user_pseudo_id = b.user_pseudo_id
      where
          b.event_date_hk between date_sub(a.event_date_hk,interval 29 day) and a.event_date_hk
      group by 1,2,3,4,5,6,7,8
  )
-- where event_date_hk='2025-06-24'  -- 是否要限制观测日期
where platform='iOS'
group by 1
ORDER BY 1
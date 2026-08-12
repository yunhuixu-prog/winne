-- 过去7天内的人均活跃天数
with enter_test as (
    -- 进入实验的人
    SELECT date_p event_date, cast(ab_code as string) abcode
        , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform
        ,receive_time as timestamp
        ,field as user_pseudo_id
    FROM `dataintegration-265403.abtest.abtest_odz_flow` --2.第一次进入实验用户
    WHERE
        date_p>='2025-03-11' and date_p<='2025-03-13'
        and cast(ab_code as string) in ('11050','11051','11052')
        and field_type = 1 --field是1 user_pseudo_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,mact as (
    -- 取进入实验之后的每个日期
    select
        distinct a.event_date_hk,b.user_pseudo_id,b.abcode,b.min_event_date enter_abtest_date,b.platform
    from
    (
        select distinct event_date_hk
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2025-03-11' and '2025-03-13'
    ) a
    left join (select user_pseudo_id,abcode,min(event_date) min_event_date,min(platform) platform from enter_test group by 1,2) b
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
        and a.event_date_hk >= date_sub('2025-03-11',interval 30 day)
)
select
     event_date_hk,abcode
        ,sum(uv) uv
        ,round(sum(uv*days_7)/sum(uv),2) days_7_avg
        ,round(sum(uv*days_30)/sum(uv),2) days_30_avg
from
(
    select
        event_date_hk,platform,abcode
        ,days_7,days_30
        ,count(distinct user_pseudo_id ) uv
    from
      (
          select
             a.event_date_hk,a.enter_abtest_date,a.platform,a.user_pseudo_id,a.abcode
               ,count(distinct case when b.event_date_hk
                        between date_sub(a.event_date_hk,interval 6 day)
                        and a.event_date_hk then b.event_date_hk end) days_7
               ,count(distinct b.event_date_hk) days_30
          from mact a
          left join act b on a.user_pseudo_id = b.user_pseudo_id
          where
              b.event_date_hk between date_sub(a.event_date_hk,interval 29 day) and a.event_date_hk
          group by 1,2,3,4,5
      )
    group by 1,2,3,4,5
)
group by 1,2
order by 1,2
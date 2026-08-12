

-- 护栏指标-留存
WITH ab_users AS (
    select
        date_p event_date
        ,ab_code ab_code
        ,case when ab_code in (11050,11053) then '对照组'
               when ab_code in (11051,11054) then '实验组A'
               when ab_code in (11052,11055) then '实验组B'
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
        date_p between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11050','11051','11052','11053','11054','11055')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
),
act AS
(
    SELECT event_date_hk, user_pseudo_id, platform,real_device_id device_id
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    WHERE event_date_hk between '2025-03-10' and date_add('2025-03-23',interval 7 day) -- 这里如果需要观测的留存天数多的话要修改
        AND app_name = 'BeautyPlus'
)

SELECT
    n.event_date,
    n.platform,
    n.ab_code,
    n.code,
    n.is_new,
    case   when n.country in ('Japan') then '日本'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  n.country in ('United States','South Korea','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧美韩' --'欧盟国家'
            when n.country in ('India') then '印度'
            when n.country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group,
    COUNT(DISTINCT n.device_id) AS enter_abtest_uv,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS re0,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) AS re1,
--     COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) / COUNT(DISTINCT n.device_id) AS d1_retain_rate,

    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS d1_retain_rate,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 7 THEN n.device_id END) AS re7,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 7 THEN n.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS d7_retain_rate
FROM ab_users n
LEFT JOIN act a ON n.device_id = a.device_id AND a.event_date_hk >= n.event_date
GROUP BY 1,2,3,4,5,6
ORDER BY 1,2,3,4,5,6

;


-- 过去7/30天内的人均活跃天数
with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11050,11053) then '对照组'
               when ab_code in (11051,11054) then '实验组A'
               when ab_code in (11052,11055) then '实验组B'
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
        date_p between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11050','11051','11052','11053','11054','11055')
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
        where event_date_hk between '2025-03-10' and '2025-03-23'
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
        and a.event_date_hk >= date_sub('2025-03-10',interval 30 day)
)

select
    event_date_hk,platform,is_new,abcode,code
    ,case   when country in ('Japan') then '日本'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('United States','South Korea','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧美韩' --'欧盟国家'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
    ,count(user_pseudo_id) uv
    ,sum(days_7) days_7_all
    ,sum(days_30) days_30_all
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
group by 1,2,3,4,5,6
ORDER BY 1,2,3,4,5,6









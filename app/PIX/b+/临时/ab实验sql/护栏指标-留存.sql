WITH ab_users AS (
    SELECT date_p event_date, cast(ab_code as string) abcode
        , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform
        ,receive_time as timestamp
        ,field as device_id
    FROM `dataintegration-265403.abtest.abtest_odz_flow` --2.第一次进入实验用户
    WHERE
        date_p>='2025-03-11' and date_p<='2025-03-13'
        and cast(ab_code as string) in ('11050','11051','11052')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
),
act AS
(
    SELECT event_date_hk, user_pseudo_id, platform,real_device_id device_id
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    WHERE event_date_hk between '2025-03-11' and date_add('2025-03-13',interval 7 day) -- 这里如果需要观测的留存天数多的话要修改
        AND app_name = 'BeautyPlus'
)

SELECT
    n.event_date,
    n.platform,
    n.abcode,
    COUNT(DISTINCT n.device_id) AS enter_abtest_uv,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS re0,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) AS re1,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) / COUNT(DISTINCT n.device_id) AS d1_retain_rate,

    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 1 THEN n.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS d1_retain_rate,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 7 THEN n.device_id END) AS re7,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 7 THEN n.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, n.event_date, DAY) = 0 THEN n.device_id END) AS d7_retain_rate
FROM ab_users n
LEFT JOIN act a ON n.device_id = a.device_id AND a.event_date_hk >= n.event_date
GROUP BY 1,2,3
ORDER BY 1,2,3

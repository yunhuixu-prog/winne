  -- 历史活跃过的login_id与gid的关系
WITH idmapping AS (
  SELECT
   *
   from `dataintegration-265403.stat.dmi_dz_idmapping`
   where length(key) in (8,9,10)
   and REGEXP_CONTAINS(key, r'^\d+$')),
   -- 活跃的登录id,通过他的gid去idmapping找所有gid
  active_login_id AS (
  SELECT
    login_id,
    ARRAY_AGG( gid
    ORDER BY
      max_active_date ASC) `活跃日期升序排列gid`,
      max(max_active_date) as  max_active_date
  FROM (
    -- gid根据idmappin找所有gid
    select 
      logingid.login_id,logingid.uuid,idmapping2.key as gid,active_gid.last_active_date as max_active_date
      from  (
          select 
          distinct logingid.login_id,idmapping.uuid
            from (
          SELECT
            login_id,
            gid,
            MAX(event_date) AS active_event_date
          FROM
            `dataintegration-265403.dwd.dwd_dzp_login_platform_active`
          WHERE
            gid IS NOT NULL
          GROUP BY
            1,
            2 
          ) logingid join idmapping on logingid.gid=idmapping.key
        )logingid
    join idmapping as idmapping2 on logingid.uuid = idmapping2.uuid
    join (
      select
        gid,max(last_active_date) as last_active_date
      from `airbrush-1324.dim.dim_dzp_portrait_gid_user` 
      where event_date_hk='2025-11-03'
      group by 1
    ) active_gid
    on idmapping2.key = active_gid.gid
      ) 
  GROUP BY
    login_id
--   having max_active_date>='2025-01-01'
  ),
  -- 目前还处在订阅有效期
  sub_login_id AS (
  SELECT
    appuserid AS login_id
  FROM
    `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
  WHERE
    event_date_hk = "2025-11-03"
    AND app_id IN ('AirBrush')
    AND appuserid LIKE '%|%'
    AND valid_order_end_date>='2025-10-31'--处于有效期
  GROUP BY
    appuserid )
    -- 历史活跃且处在有效期的login_id对应gid组
SELECT
  sub_login_id.login_id,active_login_id.`活跃日期升序排列gid`,active_login_id.max_active_date as `最新gid活跃日期`
FROM
  sub_login_id
JOIN
  active_login_id
ON
  sub_login_id.login_id = active_login_id.login_id
order by `最新gid活跃日期` desc
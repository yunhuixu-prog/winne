-- 只能通过idmapping表找
WITH
  idmapping AS (
  SELECT
   *
   from `dataintegration-265403.stat.dmi_dz_idmapping`),
   -- 判断出为gid的key,并关联gid维表获取最近活跃日期
   gid_idmapping as (
    select
    k.uuid,array_agg( active_gid.gid order by active_gid.last_active_date asc) as `活跃日期升序排列的gid`,max(active_gid.last_active_date) `最后活跃日期`
    from (
    SELECT
   key,uuid
   from `dataintegration-265403.stat.dmi_dz_idmapping`
   where length(key) in (8,9,10)
   and REGEXP_CONTAINS(key, r'^\d+$')
    ) k join
    (
      select
        gid,max(last_active_date) as last_active_date
      from `airbrush-1324.dim.dim_dzp_portrait_gid_user`
      where event_date_hk='2025-11-03'
      group by 1
    ) active_gid on
    k.key = active_gid.gid
    group by 1
   ),
  -- 目前还处在订阅有效期
  saas AS (
  SELECT
    appuserid AS saasid
  FROM
    `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
  WHERE
    event_date_hk = "2025-11-03"
    AND app_id IN ('AirBrush')
    AND lower(appuserid) LIKE 'saas%'
    AND valid_order_end_date>='2025-10-31'--处于有效期
  GROUP BY
    appuserid )
    -- 历史活跃且处在有效期的login_id对应gid组
SELECT
  saas.saasid,idmapping.uuid as `设备映射中间关系`,gid_idmapping.`活跃日期升序排列的gid`,gid_idmapping.`最后活跃日期`
FROM
  saas
JOIN
  idmapping
ON
  saas.saasid = idmapping.key
join gid_idmapping
on idmapping.uuid = gid_idmapping.uuid


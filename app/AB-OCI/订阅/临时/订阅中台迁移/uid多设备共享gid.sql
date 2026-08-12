-- 268253 个otid
-- login_id对应的otid与对应日期
with t1 as (
 SELECT
    appuserid AS login_id,o_original_order_id as otid,platform,max(date(timestamp_millis(original_purchase_date_ms),'Asia/Singapore')) as otid_date
  FROM
    `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
  WHERE
    event_date_hk = "2025-11-29"
    AND app_id IN ('AirBrush')
    AND appuserid LIKE '%|%'
    AND valid_order_end_date>='2025-11-29'--处于有效期
  GROUP BY
    1,2,3
),
-- 原始otid的gid
sub as (
  select origin_order_id as otid,appuserid as gid from `dataintegration-265403.aw_v2.stage_aw_order_log`
  where REGEXP_CONTAINS(appuserid, r'^\d+$')
  qualify row_number()over(partition by origin_order_id order by created_at asc) =1
),
-- 登陆id在设备的活跃日期
loginid_gid_event as (

   SELECT
distinct   login_id,
            gid,
            platform,
            event_date
          FROM
            `dataintegration-265403.dwd.dwd_dzp_login_platform_active`
            where gid is not null
),
-- 1. 直接去订单表捞归属gid,能找到24.3w个
find_gid1 as (
select
login_id,t1.otid,t1.platform,t1.otid_date,sub.gid
from t1
left join sub
on t1.otid = sub.otid
),
-- 2. 通过otid日期在登陆活跃表中找到对应日期的gid,能找到6w个, 与第一步合并后总共找到25.9w 归属gid ,剩下找不到的直接捞最近5笔活跃gid
find_gid2 as (
select
find_gid1.login_id,find_gid1.otid,find_gid1.platform,find_gid1.otid_date,find_gid1.gid as aw_gid,loginid_gid_event.gid as login_gid,coalesce(find_gid1.gid,loginid_gid_event.gid) as belong_gid
from find_gid1
left join loginid_gid_event
on find_gid1.login_id = loginid_gid_event.login_id
and find_gid1.otid_date =loginid_gid_event.event_date
and find_gid1.platform = loginid_gid_event.platform
)
-- 3. 最近5笔活跃

select
find_gid2.login_id,otid,otid_date, belong_gid,array_agg(idmapping.key ignore nulls order by active_gid.last_active_date desc limit 5) as active_gid_5,
from find_gid2
left join
-- 获取uuid
(SELECT
   key,uuid
   from `dataintegration-265403.stat.dmi_dz_idmapping` ) idmapping1
   on find_gid2.otid = idmapping1.key
left join -- 获取uuid 所有gid key
(
  SELECT
   key,uuid,event_date_hk
   from `dataintegration-265403.stat.dmi_dz_idmapping`
   where length(key) in (8,9,10)
   and REGEXP_CONTAINS(key, r'^\d+$')
) idmapping
on idmapping1.uuid = idmapping.uuid
left join (
      select
        gid,max(last_active_date) as last_active_date
      from `airbrush-1324.dim.dim_dzp_portrait_gid_user`
      where event_date_hk='2025-11-29'
      group by 1
    ) active_gid
    on idmapping.key = active_gid.gid
group by 1,2,3,4
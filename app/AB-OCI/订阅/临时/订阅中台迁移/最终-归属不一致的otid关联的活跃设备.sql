DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

delete from  `dataintegration-265403.temp.not_same_otid_mapping_gid` where event_date between mDATE_START and mDATE_END;
insert into `dataintegration-265403.temp.not_same_otid_mapping_gid`

with users as (
    select *
    from (
    select rank() over(partition by event_date,gid,otid order by event_timestamp desc) as rank
            ,event_date,otid,gid,is_platform_vip,is_tripartite_vip,event_timestamp
        from (
            SELECT event_date
                ,func.getParams(event_params,'gid').string_value as gid
                ,func.getParams(event_params,'otid').string_value as otid
                ,func.getParams(event_params,'is_platform_vip').string_value as is_platform_vip
                ,func.getParams(event_params,'is_tripartite_vip').string_value as is_tripartite_vip
                ,event_timestamp
            FROM `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_START as string), cast(mDATE_END as string),'airbrush',false)
            WHERE
                event_name in ('user_vip_status')
                -- and func.getParams(event_params,'gid').string_value='2742367095'
        )
    )
    where rank=1 and is_platform_vip not in ('1','true') and is_tripartite_vip in ('1','true')
),
-- 原始otid的gid
-- sub as (
--   select origin_order_id as otid,appuserid as gid from `dataintegration-265403.aw_v2.stage_aw_order_log`
--   where REGEXP_CONTAINS(appuserid, r'^\d+$')
--   qualify row_number()over(partition by origin_order_id order by created_at asc) =1
-- ),
-- -- 登陆id在设备的活跃日期
-- loginid_gid_event as (
--
--    SELECT
-- distinct   login_id,
--             gid,
--             platform,
--             event_date
--           FROM
--             `dataintegration-265403.dwd.dwd_dzp_login_platform_active`
--             where gid is not null
-- ),
-- -- 1. 直接去订单表捞归属gid,能找到24.3w个
-- find_gid1 as (
-- select
-- login_id,t1.otid,t1.platform,t1.otid_date,sub.gid
-- from t1
-- left join sub
-- on t1.otid = sub.otid
-- ),
-- -- 2. 通过otid日期在登陆活跃表中找到对应日期的gid,能找到6w个, 与第一步合并后总共找到25.9w 归属gid ,剩下找不到的直接捞最近5笔活跃gid
-- find_gid2 as (
-- select
-- find_gid1.login_id,find_gid1.otid,find_gid1.platform,find_gid1.otid_date,find_gid1.gid as aw_gid,loginid_gid_event.gid as login_gid,coalesce(find_gid1.gid,loginid_gid_event.gid) as belong_gid
-- from find_gid1
-- left join loginid_gid_event
-- on find_gid1.login_id = loginid_gid_event.login_id
-- and find_gid1.otid_date =loginid_gid_event.event_date
-- and find_gid1.platform = loginid_gid_event.platform
-- ),
-- 3. 刨除归属gid外的最近活跃
active_five as (
    select t1.event_date
        ,t1.otid
        ,array_agg(active_gid.last_active_date ignore nulls order by active_gid.last_active_date desc) as active_day
        ,array_agg(idmapping.key order by active_gid.last_active_date desc) as active_gid
--         ,array_agg(idmapping.key ignore nulls order by active_gid.last_active_date desc limit 5) as active_gid_5
    from (
        select distinct u.event_date,o otid
        from users u,unnest(split(otid,',')) o
    ) t1
    left join
    -- 获取uuid
    (
        SELECT key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) idmapping1
    on t1.otid = idmapping1.key
    left join -- 获取uuid 所有gid key
    (
        SELECT key,uuid,event_date_hk
        from `dataintegration-265403.stat.dmi_dz_idmapping`
        where length(key) in (8,9,10)
        and REGEXP_CONTAINS(key, r'^\d+$')
    ) idmapping
    on idmapping1.uuid = idmapping.uuid
    left join
    (
        select
            event_date_hk,gid,max(last_active_date) as last_active_date
        from `airbrush-1324.dim.dim_dzp_portrait_gid_user`
        where event_date_hk between mDATE_START and mDATE_END
        group by 1,2
    ) active_gid
    on idmapping.key = active_gid.gid and t1.event_date=active_gid.event_date_hk
    where active_gid.last_active_date between date_sub(t1.event_date,interval 30 day) and t1.event_date
    group by 1,2
)

select *
from active_five

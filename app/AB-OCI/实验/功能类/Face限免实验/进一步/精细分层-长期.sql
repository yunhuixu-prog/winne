-- 长期量级核算
select 
    os_p,coalesce(active_days_30d,0) active_days_30d,count(a.gid) uv
from
-- T+1的活跃用户
(
    select
        server_id as gid,os_p
    from stat_sdk.sdk_odz_active
    where date_p >= ${day+1}
    and date_p <= ${day+1}
    and os_p > '0'
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and nvl(server_id,'0') <> '0'
    group by server_id,os_p
) a
LEFT JOIN (
    SELECT final_id AS gid,count(distinct date_p) active_days_30d
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${day_30} AND ${day}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
    group by final_id
) c
ON a.gid = c.gid
group by os_p,coalesce(active_days_30d,0)
;

select 
    coalesce(active_days_30d,0) active_days_30d,count(a.gid) uv
from
-- T+1的活跃用户
(
    select
        server_id as gid
    from stat_sdk.sdk_odz_active
    where date_p >= ${day+1}
    and date_p <= ${day+1}
    and os_p > '0'
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and nvl(server_id,'0') <> '0'
    group by server_id
) a
join 
(
    -- ${day}:统计日期
    select 
        a.gid
    from
    -- base：近365天有活跃
    (
        select
            server_id as gid
        from stat_sdk.sdk_odz_active
        where date_p >= ${day_365}
        and date_p <= ${day}
        and os_p > '0'
        and app_key_p in (
            '7F7023B6CEC7CDED'                -- Airbrush: Android
            -- , 'C851ED7164B6DF0F'              -- Airbrush: ios
        )
        and nvl(server_id,'0') <> '0'
        group by server_id
    ) a
    left join 
    -- 1、是否是会员。定义:时间周期内会员有效即算作会员。
    (
        -- 当前仍是会员的用户
        select gid
        from stat_vip.paid_sda_vip_membership_user
        where date_p = ${day}
        and app_id = 7329803307041000000          -- AirBrush
        and nvl(gid,'0') <> '0'
        and replace(to_date(from_unixtime(
            cast(substring(invalidate_time,0,10) as bigint),
            'yyyy-MM-dd HH:mm:ss')),'-','') >= ${day}
        group by gid
    ) b 
    on a.gid = b.gid
    where b.gid is null
) b 
on a.gid = b.gid
LEFT JOIN (
    SELECT final_id AS gid,count(distinct date_p) active_days_30d
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${day_30} AND ${day}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
    group by final_id
) c
ON a.gid = c.gid
group by coalesce(active_days_30d,0)
;
-- 实验中的长期：目前样本量太少了，需要找原因



-- ${day}:统计日期；${day_30}：统计日期-29；${day_365}：统计日期-365

-- Android口径：所有未订阅用户
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

;

-- iOS口径：近30天有活跃，且历史从不是会员，且激活天数大于30天。
select 
    a.gid
from
-- 0、近30天有活跃
(
    select
        server_id as gid
    from stat_sdk.sdk_odz_active
    where date_p >= ${day_30}
    and date_p <= ${day}
    and os_p > '0'
    and app_key_p in (
        -- '7F7023B6CEC7CDED'                -- Airbrush: Android
        'C851ED7164B6DF0F'              -- Airbrush: ios
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
-- 2、历史是否会员。 定义：当前不是会员但历史上曾订阅过会员。
left join
(
    select gid
    from stat_vip.paid_sda_vip_membership_user
    where date_p = ${day}
    and app_id = 7329803307041000000          -- AirBrush
    and nvl(gid,'0') <> '0'
    group by gid
) c
on a.gid = c.gid
-- 3、Airbrush激活天数。定义: 设备首次启动距今天数。(如果有多次启动日期取最早日期)。
left join 
(
    select
        server_id as gid,
        max(meitu_datediff(${day}, first_launch_date)) as first_active_days
    from stat_sdk.sdk_oda_all_device_info
    where os_p in ('ios', 'android')
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and date_p = ${day}
    and server_id > 0
    group by server_id
) d 
on a.gid = d.gid
-- 选取当前不是会员且历史上未订阅过，激活天数大于30天，且近30天活跃天数大于1天的用户。
where b.gid is null and c.gid is null and d.first_active_days>30 

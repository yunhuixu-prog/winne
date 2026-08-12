-- ${day}:统计日期；${day_365}：统计日期-365
-- 历史未订阅过＋安装30天以上+Android全国家/iOS排除美国、英国、澳大利亚、加拿大、德国、西班牙、以色列
select 
    a.gid
from
-- base：近365天有活跃 且 Android全国家/iOS排除美国、英国、澳大利亚、加拿大、德国、西班牙、以色列
(
    select distinct aa.gid
    from  
    (
        select
            server_id as gid,country_id,os_p
        from stat_sdk.sdk_odz_active
        where date_p >= ${day_365}
        and date_p <= ${day}
        and os_p > '0'
        and app_key_p in (
            '7F7023B6CEC7CDED'                -- Airbrush: Android
            , 'C851ED7164B6DF0F'              -- Airbrush: ios
        )
        and nvl(server_id,'0') <> '0'
        group by server_id,country_id,os_p
    ) aa
    left join 
    (
        SELECT DISTINCT id, name
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) bb
    on aa.country_id = bb.id
    where aa.os_p = 'android' 
        or (aa.os_p = 'ios' and bb.name not in ('美国','英国','澳大利亚','加拿大','德国','西班牙','以色列'))
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
-- 选取当前不是会员且历史上未订阅过，激活天数大于30天的用户
where b.gid is null and c.gid is null and d.first_active_days>30 

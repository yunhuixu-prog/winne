-- 问题gid
select *
from stat_ab.filing_ona_temp_otid_gid
where gid in ('2812355164','2659357531','2821373054','2590884736')
-- 2659357531,2590884736
select sdk_type,otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count between 2 and 3 and otid!='无' and otid!=''
-- 事件
SELECT
    sdk_type
    ,date_p
    ,gid
    ,params['otid'] otids
    ,params['is_platform_vip'] is_platform_vip
    ,params['is_tripartite_vip'] is_tripartite_vip
    ,`time`
    -- ,rank() over(partition by date_p,gid,params['otid'] order by `time` desc) as rn
FROM stat_sdk.sdk_odz_source_data
WHERE date_p between 20260406 and 20260506 -- 近一个月
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND event_id in  ('user_vip_status') -- 启动app时上报
    and gid in ('2812355164','2659357531','2821373054','2590884736')


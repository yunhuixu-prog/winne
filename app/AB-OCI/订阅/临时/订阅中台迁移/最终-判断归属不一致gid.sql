SELECT date_p,sdk_type,case when is_platform_vip in ('1','true') and is_tripartite_vip in ('1','true') then '平台和三方会员'
                when is_tripartite_vip in ('1','true') and is_platform_vip not in ('1','true') then '仅三方会员'
                when is_tripartite_vip not in ('1','true') and is_platform_vip in ('1','true') then '仅平台会员'
                when is_platform_vip not in ('1','true') and is_tripartite_vip not in ('1','true') then '无会员'
            end as vip_type
            ,count(distinct gid) uv
    FROM (
        SELECT *
        FROM (
            -- 归属不一致 otid
            SELECT
                sdk_type
                ,date_p
                ,gid
                ,params['otid'] otids
                ,params['is_platform_vip'] is_platform_vip
                ,params['is_tripartite_vip'] is_tripartite_vip
                ,`time`
                ,rank() over(partition by date_p,gid,params['otid'] order by `time` desc) as rn
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260401 and 20260507 -- 近一个月
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id in  ('user_vip_status') -- 启动app时上报
        ) t_rn
        WHERE t_rn.rn = 1
    ) t
    group by date_p,sdk_type,case when is_platform_vip in ('1','true') and is_tripartite_vip in ('1','true') then '平台和三方会员'
                when is_tripartite_vip in ('1','true') and is_platform_vip not in ('1','true') then '仅三方会员'
                when is_tripartite_vip not in ('1','true') and is_platform_vip in ('1','true') then '仅平台会员'
                when is_platform_vip not in ('1','true') and is_tripartite_vip not in ('1','true') then '无会员'
            end
;

-- 用户粒度排查
select
    date_p,`time`
    ,params['is_platform_vip'] is_platform_vip
    ,params['is_tripartite_vip'] is_tripartite_vip
    ,gid
    ,params['otid'] otid
from stat_sdk.sdk_odz_source_data
where date_p between 20260501 and 20260507 -- 近一个月
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('user_vip_status') -- 启动app时上报
    and params['is_platform_vip'] not in ('1','true')
    and params['is_tripartite_vip'] in ('1','true')
    -- and gid='2817297705'
;
select otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count=1 and otid!='无' and otid!=''
    and gid!=receiver_gid
    -- and and cast(gid as string)!=receiver_gid
    and otid in ('GPA.3355-2987-8906-75010','GPA.3302-7765-3396-90032','GPA.3352-5365-9757-88084')
;
select sdk_type,otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count between 2 and 3 and otid!='无' and otid!=''
    and otid in ('380002134632939')


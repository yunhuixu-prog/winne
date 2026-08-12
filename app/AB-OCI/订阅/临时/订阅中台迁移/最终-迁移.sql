INSERT OVERWRITE TABLE stat_ab.filing_ona_temp_otid_gid

select v.sdk_type
     ,v.otid  -- 归属不一致otid
     ,w.gid -- 该otid关联到的活跃gid
     ,w.gid_count -- 该otid关联到的活跃gid数量
     ,c.contract_id -- 该otid关联到的最新合约id
     ,c.receiver_gid -- 该otid关联到的最新归属gid
from (
    SELECT DISTINCT sdk_type, otid
    FROM (
        SELECT *
        FROM (
            -- 归属不一致 otid
            SELECT
                sdk_type
                ,date_p
                ,params['otid'] otids
                ,params['is_platform_vip'] is_platform_vip
                ,params['is_tripartite_vip'] is_tripartite_vip
                ,`time`
                ,rank() over(partition by gid,params['otid'] order by `time` desc) as rn
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260501 and 20260601 -- 近一个月
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id in  ('user_vip_status') -- 启动app时上报
        ) t_rn
        WHERE t_rn.rn = 1
          AND t_rn.is_platform_vip NOT IN ('1','true')
          AND t_rn.is_tripartite_vip IN ('1','true')
    ) t
    LATERAL VIEW explode(SPLIT(COALESCE(otids,'无'), ',')) t0 AS otid
) v
left join (
    -- 取otid关联到的活跃gid
    SELECT
        gid,
        otid,
        COUNT(gid) OVER (PARTITION BY otid) AS gid_count
    FROM (
        SELECT DISTINCT gid, otid
        FROM (
            -- 活跃gid
            select
                date_p
                ,gid
                ,params['otid'] otids
            from stat_sdk.sdk_odz_source_data
            where date_p between 20260501 and 20260601 -- 近一个月
                and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                and event_id in  ('user_vip_status') -- 启动app时上报
        ) t
        LATERAL VIEW explode(SPLIT(COALESCE(otids,'无'), ',')) t0 AS otid
    ) t_distinct
) w
on v.otid=w.otid
-- 关联最新合约id和归属gid
left join (
    SELECT  a.pay_channel
           ,if(a.pay_channel = 'google',split(a.partner_pay_id,'\\.\\.')[0],a.partner_contract_id) AS partner_contract_id
           ,a.contract_id
           ,a.last_order_id
           ,a.buyer_gid -- 开始时的gid
           ,a.receiver_gid -- 最新的gid
    FROM
    (
        SELECT  *
        FROM
        (
            SELECT  a.pay_channel
                   ,a.partner_contract_id
                   ,a.contract_id
                   ,a.last_order_id
                   ,a.buyer_gid -- 开始时的gid
                   ,a.receiver_gid -- 最新的gid
                   ,b.partner_pay_id
                   ,ROW_NUMBER() over(PARTITION BY a.pay_channel,a.partner_contract_id ORDER BY  b.pay_time DESC) AS rn
            FROM
            (
                SELECT  pay_channel
                       ,partner_contract_id
                       ,contract_id
                       ,last_order_id
                       ,buyer_gid -- 开始时的gid
                       ,receiver_gid -- 最新的gid
                FROM stat_vip.paid_sda_vip_tb_contract -- 合约
                WHERE date_p = 20260601
                AND app_id IN (7329803307041000000) -- 7329803307041000000 AB 7329803307042000000 B+

            ) a
            INNER JOIN
            (
                SELECT  contract_id
                       ,partner_pay_id
                       ,order_id
                       ,pay_time
                FROM stat_vip.paid_sda_vip_tb_order
                WHERE date_p = 20260601
                AND app_id IN (7329803307041000000)
                AND order_type = 2 -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                AND contract_id <> 0
                AND order_status > 100
            ) b
            ON a.contract_id = b.contract_id
        ) a
        WHERE rn = 1
    ) a
    GROUP BY  a.pay_channel
             ,if(a.pay_channel = 'google',split(a.partner_pay_id,'\\.\\.')[0],a.partner_contract_id)
             ,a.contract_id
             ,a.last_order_id
             ,a.buyer_gid -- 开始时的gid
             ,a.receiver_gid
) c
on v.otid=c.partner_contract_id
;

select sdk_type,otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count between 2 and 3 and otid!='无' and otid!=''
;
select otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count=1 and sdk_type='iOS' and otid!='无' and otid!=''
    and cast(gid as string)!=receiver_gid
;
select otid,gid,contract_id,receiver_gid
from stat_ab.filing_ona_temp_otid_gid
where gid_count=1 and sdk_type='Android' and otid!='无' and otid!=''
    and cast(gid as string)!=receiver_gid



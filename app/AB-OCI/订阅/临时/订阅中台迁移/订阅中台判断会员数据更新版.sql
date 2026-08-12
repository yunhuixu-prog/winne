
-- 中台无会员三方有会员明细
with vip_status as
(
    select
        sdk_type,
        date_p,`time`,gid
        ,params['uid'] uid
        ,params['saasid'] saasid
        ,params['gid'] gid_order
        ,params['otid'] otid
        ,params['reason'] reason
        ,params['tripartite_time'] tripartite_time
        ,params['platform_time'] platform_time
    from stat_sdk.sdk_odz_source_data
    where date_p between 20260120 and 20260120
        and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and event_id in  ('user_vip_status')
        and app_version>='7.22.0'
        and params['is_platform_vip'] not in ('1','true')
        and params['is_tripartite_vip'] in ('1','true')
)
-- ,
-- pop as
-- (
--     select
--         sdk_type,gid,
--         min(case when event_id = 'restore_purchase_popup_show' then date_p end) first_pop_date,
--         max(case when event_id = 'restore_purchase_popup_click' then 1 else 0 end) is_pop_click,
--         max(case when event_id = 'restore_purchase_click' then 1 else 0 end) is_restore_click,
--         max(case when event_id = 'restore_purchase_success' then 1 else 0 end) is_restore_success
--     from stat_sdk.sdk_odz_source_data
--     where date_p between 20251029 and 20260106
--         and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
--         and (
--                 (event_id='restore_purchase_popup_show' and params['type']='恢复购买提醒')
--                     or
--                 (event_id='restore_purchase_popup_click' and params['button']='continue' and params['type']='恢复购买提醒')
--                     or
--                 event_id in ('restore_purchase_click','restore_purchase_success')
--             )
--         and app_version>='7.19.0'
--     group by sdk_type,gid
-- )
select
    -- v.date_p event_date,
	case when v.sdk_type='iOS' then 'iap'
	     when v.sdk_type='Android' then 'google'
	end sdk_type,
    -- v.`time` `time`,
    FROM_UNIXTIME(CAST(v.`time`/1000 AS bigint)) `time`
--     ,v.gid gid
    ,v.uid uid
    ,v.saasid saasid
    ,v.gid_order gid_order
    ,v.otid otid
    ,FROM_UNIXTIME(CAST(v.tripartite_time/1000 AS bigint)) tripartite_time
    ,FROM_UNIXTIME(CAST(v.platform_time/1000 AS bigint)) platform_time
    -- ,v.first_otid
    ,c.partner_pay_id tid
    ,v.reason reason
-- 	,if(p.first_pop_date is NULL,0,1) is_pop
--     ,p.first_pop_date first_pop_date
--     ,nvl(p.is_restore_click,0) is_restore_click
--     ,nvl(p.is_restore_success,0) is_restore_success
from (select *,SPLIT(COALESCE(vip_status.otid,'无'), ',')[0] first_otid from vip_status) v
-- left join (select * from pop) p
-- on v.gid=p.gid and v.sdk_type=p.sdk_type
-- where vip_status.gid is not NULL and vip_status.original_order_id is not NULL
-- otid取最新tid
left join (
    select distinct aa.partner_contract_id,bb.partner_pay_id
    from
    (
        select partner_contract_id,contract_id,last_order_id
        from stat_vip.paid_sda_vip_tb_contract
        WHERE date_p=20260120
            and app_id IN (7329803307041000000, 7329803307042000000)
    ) aa
    left join
    (
        select contract_id,partner_pay_id,order_id
        from stat_vip.paid_sda_vip_tb_order
        WHERE date_p=20260120
            and app_id IN (7329803307041000000, 7329803307042000000)
            and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
            and contract_id<>0
    ) bb
    on aa.contract_id=bb.contract_id and aa.last_order_id=bb.order_id
) c
on v.first_otid=c.partner_contract_id
-- order by v.date_p,v.gid




-- 测试
select partner_contract_id,contract_id,last_order_id
        from stat_vip.paid_sda_vip_tb_contract
        WHERE date_p=20251204
            and partner_contract_id = 'GPA.3370-5468-7646-99723'
            and partner_contract_id like '%GPA.%'
            and app_id IN (7329803307041000000, 7329803307042000000)
limit 100

;
select contract_id,partner_pay_id,order_id
        from stat_vip.paid_sda_vip_tb_order
        WHERE date_p=20251204
            and app_id IN (7329803307041000000, 7329803307042000000)
            and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
            and contract_id<>0
            and contract_id='7385307908042921831'
            and order_id='7394732424326311363'
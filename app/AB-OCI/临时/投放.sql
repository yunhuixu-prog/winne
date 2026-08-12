SELECT gid, SUM(sess_sec)  dur_sec
FROM (
SELECT gid, session_id, (MAX(`time`) - MIN(`time`)) / 1000.0 AS sess_sec
FROM stat_sdk.sdk_odz_source_data
WHERE app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
AND date_p = '20260711'
AND session_id IS NOT NULL
GROUP BY gid, session_id
) sess
GROUP BY gid
;

SELECT
gid,
COUNT(1) AS save_pv
FROM stat_sdk.sdk_odz_source_data
WHERE app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
AND date_p = '${date}'
AND event_id = 'edit_save'
GROUP BY gid
;


-- 用户试用期内 3 天未取消，单次上报，3天内统计
SELECT  t1.gid ,order_id,pay_amount,money_unit,pay_time,pay_date,app_id
FROM
(     
        select gid ,order_id,pay_amount,money_unit,pay_time,pay_date,app_id,contract_id
        from 
        stat_vip.paid_ora_vip_all_order
        WHERE
        app_id_p=7329803307041000000
        and commodity_id_p>'0'
        and os_type in ('ios','android')
        and cur_pay_withhold_stage = 0 -- '试用'
        and pay_date>=20260716  
) t1
INNER JOIN
(
        SELECT  DISTINCT contract_id
                ,confirm_time
                ,receiver_gid AS gid
        FROM stat_vip.paid_sha_vip_tb_contract 
        WHERE date_p = ${date_0}
        AND contract_status IN (2, 3) -- 合约状态(1:未签约 2:已签约 3:解约、4:暂停)
        AND promotion_status IN (1, 2) -- 促销状态,0=无,1=首期优惠,2=免费试用
        AND confirm_time - dismiss_time > 3 * 24 * 60 * 60 * 1000 -- 未解约或已解约且解约时间大于3天
        AND from_unixtime(floor(confirm_time / 1000), 'yyyyMMddHH') BETWEEN ${date_h_144} AND ${date_h_73} -- 7天前至3天前签约

) t3
ON t1.contract_id = t3.contract_id    
;


-- 用户的每一笔真实付费，终身数据，每次上报，事件次数不变 ，终身统计
-- 全订阅付费，全量小时表无分区
select gid ,pay_time,ord_before_amt
from 
stat_vip.paid_ora_vip_all_order
WHERE
app_id_p=7329803307041000000
and commodity_id_p>'0'
and os_type in ('ios','android')
and cur_pay_withhold_stage  >=1
and pay_date>=20260715
;
-- 用户的每一笔新增订阅付费，包括直接付费订阅、试用转付费成功订阅，每次上报，事件次数不变 ，终身统计
select gid ,order_id,pay_amount,money_unit,pay_time,pay_date,app_id
from 
stat_vip.paid_ora_vip_all_order
WHERE
app_id_p=7329803307041000000
and commodity_id_p>'0'
and os_type in ('ios','android')
and cur_pay_withhold_stage = 1
and pay_date>=20260715
;
-- 每一笔用户续订的真实收入，每次上报，事件次数不变 ，终身统计
select gid ,order_id,pay_amount,money_unit,pay_time,pay_date,app_id
from 
stat_vip.paid_ora_vip_all_order
WHERE
app_id_p=7329803307041000000
and commodity_id_p>'0'
and os_type in ('ios','android')
and cur_pay_withhold_stage > 1
and pay_date>=20260715
;
-- 用户首次开启订阅试用，包括年订阅和月订阅，仅上报一次，终身统计
-- 试用订单
select gid ,order_id,pay_amount,money_unit,pay_time,pay_date,app_id
from 
stat_vip.paid_ora_vip_all_order
WHERE
app_id_p=7329803307041000000
and commodity_id_p>'0'
and os_type in ('ios','android')
and cur_pay_withhold_stage =0
and pay_date>=20260715
;
-- 用户订阅已经失效后，每一次重新订阅并成功产生真实扣款，每次上报
-- 重新订阅：本单 stage=1，且该 gid 在本单之前已有过真实付费(stage>=1)
select
    a.gid,
    a.order_id,
    a.pay_amount,
    a.money_unit,
    a.pay_time,
    a.pay_date,
    a.app_id
from
    stat_vip.paid_ora_vip_all_order a
inner join (
    select
        gid,
        min(pay_time) as first_paid_time
    from
        stat_vip.paid_ora_vip_all_order
    where
        app_id_p in (7329803307041000000)
        and commodity_id_p > '0'
        and os_type in ('ios', 'android')
        and cur_pay_withhold_stage >= 1
    group by
        gid
) f
    on a.gid = f.gid
   and a.pay_time > f.first_paid_time
where
    a.app_id_p in (7329803307041000000)
    and a.commodity_id_p > '0'
    and a.os_type in ('ios', 'android')
    and a.cur_pay_withhold_stage = 1
    and a.pay_date >= 20260715
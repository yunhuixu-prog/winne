-- 查事故的几个方面
-- 收入
select pay_date,substr(pay_time,9,2) pay_time
         ,sum(ord_amt_usd) amt_usd
         ,sum(case when pay_status=6 then refund_amt_usd end) refund_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260203
        and pay_date BETWEEN 20260122 AND 20260129
        and substr(create_time,1,8)<=pay_date -- 保证每天分区一致
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
group by pay_date,substr(pay_time,9,2)


-- 退款（当时退款）
select substr(refund_time,1,8) refund_date,substr(refund_time,9,2) refund_time
         ,sum(refund_amt_usd) refund_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260203
        and substr(refund_time,1,8) BETWEEN 20260122 AND 20260129
        and substr(create_time,1,8)<=substr(refund_time,1,8) -- 保证每天分区一致
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
group by substr(refund_time,1,8),substr(refund_time,9,2)



-- 试用转付费
select  t1.pay_date,t1.pay_time
     ,sum(t2.ord_amt_usd) ord_amt_usd
from
  (
      select   contract_id
              ,gid
              ,pay_date,substr(pay_time,9,2) pay_time
      from stat_vip.paid_oda_vip_all_order
      WHERE date_p=20260205
            and pay_date BETWEEN 20260122 AND 20260129
            and substr(create_time,1,8)<=pay_date -- 保证每天分区一致
            and app_id_p IN (7329803307041000000)
            and commodity_id_P not in (-1)
            and cur_pay_withhold_stage=0 -- 取试用订单
            and cur_pay_stage=1
            and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
            and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
  )t1
left join
  (select  contract_id,max(ord_amt_usd) ord_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260205
          and cur_pay_withhold_stage=1   -- 当前订单代扣期数(不包含试用单)
          and commodity_id_P not in (-1)
          and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
          and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
          and app_id_p IN (7329803307041000000)
  group by contract_id
  )t2
on t1.contract_id=t2.contract_id
group by t1.pay_date,t1.pay_time

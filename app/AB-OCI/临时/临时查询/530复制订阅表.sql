set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table stat_ab.filing_oda_vip_all_order_copy PARTITION(date_p,app_id_p,commodity_id_p)

select *
from stat_vip.paid_oda_vip_all_order
WHERE date_p=20260530
    -- and pay_date BETWEEN 20230101 AND 20251231
    -- and substr(create_time,1,8)<=20251231
    and app_id_p IN (7329803307041000000)
    and commodity_id_P not in (-1)

;

SELECT  SUM(ord_amt),SUM(ord_amt_usd) ord_amt_usd
    -- FROM stat_vip.paid_oda_vip_all_order
    FROM stat_ab.filing_oda_vip_all_order_copy
    WHERE date_p=20260530
    AND app_id_p IN (7329803307041000000)
    AND pay_date >= 20260101
    AND pay_date <= 20260525
    and substr(create_time,1,8)<=20260525
    AND pay_channel IN ('google', 'iap')
    and commodity_id_P not in (-1)
;


-- 下面两个废了,不要用了（后面记得把这个表删了）
-- 5.31的分区
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table stat_ab.filing_oda_all_order_summary_copy PARTITION(app_id_p)

select *
from stat_vip.paid_oda_all_order_summary
WHERE app_id_p IN (7329803307041000000)
;
SELECT  SUM(ord_amt) ord_amt,SUM(ord_amt_usd) ord_amt_usd
-- FROM stat_vip.paid_oda_all_order_summary
FROM stat_ab.filing_oda_all_order_summary_copy
WHERE  app_id_p IN (7329803307041000000)
    AND pay_date >= 20260101
    AND pay_date <= 20260525
    and create_date<=20260525
    AND pay_channel IN ('google', 'iap')



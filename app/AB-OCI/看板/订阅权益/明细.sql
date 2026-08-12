set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;

WITH
sub_event AS
(
    SELECT distinct date_p,DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
        ,event_id
        ,sdk_type os_type,gid,app_version
        ,case when params['duration']='annual' then '年'
              when params['duration']='1month' then '月'
              when params['duration']='weekly' then '周'
              when params['duration']='billed_12month' then '年'
              when params['duration']='3month' then '季'
              when params['duration'] is null then '未知'
        else '其他'
        end duration
        ,params['source_module'] source_module
        ,params['source_0'] source_0
        ,params['source_1'] source_1
        ,params['mids_material_id'] mids_material_id
        ,params['mids_category_id'] mids_category_id
        ,params['SKU'] sku
        ,params['sale_status'] sale_status
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between ${start_time} and ${end_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('w_subscription_enter','w_subscription_click','w_subscription_success')
        AND app_version>='7.19.0'
)
,dau AS
(
    SELECT
        a.date_p,
        case
            when a.os_p='ios' then 'iOS'
            when a.os_p='android' then 'Android'
        end os_type,
        a.final_id gid,
        max(c.name) AS country,
        max(a.is_ua) is_ua,
        max(CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END) AS is_new
    FROM
    (
        SELECT date_p, os_p, country_id, final_id, is_ua
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_time} AND ${end_time}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) a
    LEFT JOIN
    (
        SELECT DISTINCT id, name
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) c
    ON a.country_id = c.id
    LEFT JOIN
    (
        SELECT final_id, date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p = ${start_time}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) new_device
    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
    group by a.date_p,a.os_p,a.final_id
)
,pay as
(
    select  t1.pay_date,t1.pay_time
           ,case when t1.os_type='android' then 'Android'
                 when t1.os_type='ios' then 'iOS'
                 when t1.os_type is null then '未知'
            else '其他'
            end os_type
           ,t1.country
           ,t1.period_type
           ,t1.source_module
           ,t1.source_0
           ,t1.source_1
           ,t1.mids_material_id
           ,t1.mids_category_id
           ,t1.contract_id
           ,t1.gid
           ,t1.third_product_id sku
           ,case when t1.cur_pay_withhold_stage = 1 then t1.pay_date
                 when t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL then t2.pay_date
            end paid_date
           ,case when t1.cur_pay_withhold_stage = 1 or (t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL) then 1
                 else 0
            end is_paid
           ,case when t1.cur_pay_withhold_stage = 1 then t1.ord_amt
                 when t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL then t2.ord_amt
                 else 0
            end paid_ord_amt
           ,case when t1.cur_pay_withhold_stage = 1 then t1.ord_before_amt
                 when t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL then t2.ord_before_amt
                 else 0
            end paid_ord_before_amt

           ,if(t1.cur_pay_withhold_stage = 1,1,0) is_direct_paid
           ,if(t1.cur_pay_withhold_stage = 1,t1.ord_amt,0) direct_paid_ord_amt
           ,if(t1.cur_pay_withhold_stage = 1,t1.ord_before_amt,0) direct_paid_ord_before_amt
           ,if(t1.cur_pay_withhold_stage = 0,1,0) is_trial
           ,if(t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL,1,0) is_trial_to_paid
           ,if(t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL,t2.ord_amt,0) trial_to_paid_ord_amt
           ,if(t1.cur_pay_withhold_stage = 0 and t2.contract_id IS NOT NULL,t2.ord_before_amt,0) trial_to_paid_ord_before_amt
   from
      (
          select   contract_id
                  ,gid
                  ,os_type
                  ,country_name country
                  ,period_type
                  ,pay_date,pay_time
                  ,cur_pay_withhold_stage
--                   ,ord_amt,ord_before_amt
                  ,ord_amt_usd ord_amt,round(ord_amt_usd*ord_before_amt/ord_amt,3) ord_before_amt
                  ,third_product_id
                  ,get_json_object(big_data,'$.source_module') source_module
                  ,get_json_object(big_data,'$.source_0') source_0
                  ,get_json_object(big_data,'$.source_1') source_1
                  ,get_json_object(big_data,'$.mids_material_id') mids_material_id
                  ,get_json_object(big_data,'$.mids_category_id') mids_category_id
          from stat_vip.paid_oda_vip_all_order
          WHERE date_p=${now_time}
                and pay_date BETWEEN ${start_time} AND ${end_time}
                and app_id_p IN (7329803307041000000)
                and commodity_id_P not in (-1)
--                 and cur_pay_withhold_stage=0
                and cur_pay_stage=1
                and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
      )t1
   left join
      (select  contract_id,min(pay_date) pay_date
--             ,max(ord_amt) ord_amt,max(ord_before_amt) ord_before_amt
            ,max(ord_amt_usd) ord_amt,max(round(ord_amt_usd*ord_before_amt/ord_amt,3)) ord_before_amt
        from stat_vip.paid_oda_vip_all_order
        WHERE date_p=${now_time}
              and cur_pay_withhold_stage=1   -- 当前订单代扣期数(不包含试用单)
              and commodity_id_P not in (-1)
              and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
              and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
              and app_id_p IN (7329803307041000000)
      group by contract_id
      )t2
   on t1.contract_id=t2.contract_id
)

insert overwrite table stat_ab.filing_onz_sub_source_event_detail PARTITION(date_p)

SELECT
    COALESCE(s.os_type,'未知') AS os_type,
    COALESCE(d.country,'未知') AS country,
    COALESCE(d.is_new,'未知') AS is_new,
    COALESCE(d.is_ua,'未知') AS is_ua,
    s.app_version,s.sale_status,
    s.gid,
    s.event_id,s.duration,s.sku,
    s.source_module,s.source_0,s.source_1,s.mids_material_id,s.mids_category_id,
    null contract_id,null paid_date,null is_paid,null paid_ord_amt,null paid_ord_before_amt,
    null is_direct_paid,null direct_paid_ord_amt,null direct_paid_ord_before_amt,
    null is_trial,null is_trial_to_paid,null trial_to_paid_ord_amt,null trial_to_paid_ord_before_amt,
    CAST(s.event_time AS bigint) event_time,
    d.date_p
FROM (select * from dau) d
join (select * from sub_event) s
on d.date_p=s.date_p and d.os_type=s.os_type and d.gid=s.gid

union all

SELECT
    COALESCE(p.os_type,'未知') AS os_type,
    COALESCE(d.country,'未知') AS country,
    COALESCE(d.is_new,'未知') AS is_new,
    COALESCE(d.is_ua,'未知') AS is_ua,
    null app_version,null sale_status,
    p.gid,
    'sub_suc' event_id,p.period_type duration,p.sku,
    p.source_module,p.source_0,p.source_1,p.mids_material_id,p.mids_category_id,
    p.contract_id,p.paid_date,p.is_paid,p.paid_ord_amt,p.paid_ord_before_amt,
    p.is_direct_paid,p.direct_paid_ord_amt,p.direct_paid_ord_before_amt,
    p.is_trial,p.is_trial_to_paid,p.trial_to_paid_ord_amt,p.trial_to_paid_ord_before_amt,
    p.pay_time event_time,
    p.pay_date date_p
FROM (select * from pay) p
left join (select * from dau) d
on p.pay_date=d.date_p and p.os_type=d.os_type and p.gid=d.gid
;


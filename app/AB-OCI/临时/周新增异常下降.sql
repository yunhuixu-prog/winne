-- select a.date_p,a.gid
--     ,b.os_type,b.country,b.period_type,b.cur_pay_stage,b.ord_amt
select a.date_p,a.duration,count(distinct a.gid) uv
    ,count(distinct case when b.gid is not null then a.gid end) uv_order
    ,count(distinct case when b.gid is not null and b.cur_pay_stage=1 then a.gid end) uv_order_new
from (
  	SELECT date_p
        ,event_id,gid
  		,params['order_id'] order_id
        ,params['duration'] duration
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260501 and 20260720
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('w_subscription_success')
        AND app_version>='7.19.0'
  		-- AND params['duration']='weekly'
  		-- AND sdk_type='iOS'
) a
left join (
  	select   gid
            ,os_type
            ,country_name country
            ,period_type
            ,pay_date
            ,cur_pay_stage
            ,ord_amt_usd ord_amt
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260720
        and pay_date BETWEEN 20260501 and 20260720
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        -- and cur_pay_stage=1
        and order_type=2
        and contract_id<>0
        -- and period_type='周'
) b 
on a.date_p=b.pay_date and a.gid=b.gid
group by a.date_p,a.duration
-- where b.cur_pay_stage!=1

;
-- 事例
-- 2813512160,2722712739(中间间隔了),2704882272(中间间隔了但是价格也不一样),2737004411,2644281174(中间间隔了但是之前都是算新单的)
select   gid
            ,os_type
            ,country_name country
            ,period_type
            ,pay_date
            ,cur_pay_stage
            ,ord_amt_usd ord_amt
            ,contract_id
            ,get_json_object(big_data,'$.source_0') source_0
            ,get_json_object(big_data,'$.source_1') source_1
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260720
        and pay_date BETWEEN 20260101 and 20260720
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        -- and cur_pay_stage=1
        and order_type=2
        and contract_id<>0
        and period_type='周'
        and gid='2813512160'
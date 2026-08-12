with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,event_name
    ,func.getUserprop(user_properties,'hwgid').string_value hwgid
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'is_open_trial').string_value is_open_trial
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'sale_status').string_value sale_status
    ,func.getUserprop(user_properties,'device_id').string_value device_id
    ,func.getUserprop(user_properties,'appsflyer_id').string_value appsflyer_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-10-29','airbrush',false)
where
    event_name in ('w_subscription_success')
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_order_date
        ,lead(order_status) over(partition by original_order_id,sku order by standard_order_date) as next_order_status
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2025-10-01'
    and order_status in (0,1,2)
)

select
    c.standard_order_date,
    case when  c.order_status in (1,2) then  c.standard_order_date
              when c.order_status = 0 and c.next_order_status in (1,2) then  c.next_order_date
                  end as purchase_date,
    case when  c.order_status in (1,2) then c.payment_price_usd
        when c.order_status = 0 and c.next_order_status in (1,2) then c.next_payment_price_usd
            end as payment_price_usd
    ,e.*
from eves e
left join paid c on e.order_id = c.order_id and e.sku = c.sku


;


select DATE_FORMAT(FROM_UNIXTIME(create_time/1000), 'yyyyMMdd') create_date,
	DATE_FORMAT(FROM_UNIXTIME(pay_time/1000), 'yyyyMMdd') pay_date,
    create_time,pay_time,last_update_time,
    pay_status,promotion_status,
	order_id,sub_period,sub_period_duration,
    price,pay_amount,amount,money_unit
    ,get_json_object(big_data,'$.source_module') AS source_module
    ,get_json_object(big_data,'$.source_0') AS source_0
    ,get_json_object(big_data,'$.source_1') AS source_1
    ,get_json_object(big_data,'$.sale_status') AS sale_status
    ,get_json_object(big_data,'$.mids_material_id') AS mids_material_id
    ,get_json_object(big_data,'$.mids_category_id') AS mids_category_id
    ,get_json_object(big_data,'$.ad_id') AS ad_id
    ,get_json_object(big_data,'$.adjust_id') AS adjust_id
    ,get_json_object(big_data,'$.firebase_id') AS firebase_id
 -- date_format(from_utc_timestamp(from_unixtime(floor(a.pay_time/1000)),'Asia/Shanghai'),'yyyyMMdd')  AS utc8_date
 FROM stat_vip.paid_sda_vip_tb_order a
    WHERE date_p = 20251105
    AND app_id NOT IN (7029803307008000000)
    AND supplier_id = 1 -- 会员中心
    AND order_status > 100 -- 已发货
    AND order_type IN (2) -- 订阅续期1非续期2
    AND sandbox = 0 -- 正常数据
    AND app_id IN (7329803307041000000, 7329803307042000000)
    AND platform in (2,3) -- 3:android 2:ios
    -- 删选新订阅中台的数据
--     AND nvl(get_json_object(base_data, '$.migrate_pay'), '') <> 'true'
    AND nvl(get_json_object(base_data, '$.migrate_contract'), '') <> 'true'
    AND nvl(get_json_object(base_data, '$.migrate_order'), '') <> 'true'
    AND oper_system != 0
    and buyer_gid='2570687813'
;


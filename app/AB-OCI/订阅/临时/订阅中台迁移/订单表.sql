-- 老表口径
select standard_order_date,platform,case when subscription_user_type in ('intro pay as you go','pay up front') then 'promotional'
            when subscription_user_type in ('return_renewal','repeated_renewal') then 'renewal'
            when subscription_user_type in ('first_time_subscription') then 'first_time'
            when subscription_user_type in ('first_time_return_subscription') then 'first_time_return'
        end types
        ,sku
        ,count(distinct original_order_id) uv
        ,round(sum(payment_price_usd)) bookings
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2025-10-20' and '2025-11-10'
    and app_id in('AirBrush')
group by 1,2,3,4
;
select count(1) pv
    ,count(case when func.getParams(event_params,'source_module').string_value is not null then 1 end) as source_module
    ,count(case when func.getParams(event_params,'source_0').string_value is not null then 1 end) as source_0
    ,count(case when func.getParams(event_params,'source_1').string_value is not null then 1 end) as source_1
    ,count(case when func.getParams(event_params,'mids_material_id').string_value is not null then 1 end) as mids_material_id
    ,count(case when func.getParams(event_params,'mids_category_id').string_value is not null then 1 end) as mids_category_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-11-04','airbrush',false)
where
    event_name = 'w_subscription_success'
;
select func.getParams(event_params,'source_module').string_value source_module
     ,func.getParams(event_params,'source_0').string_value source_0
     ,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-11-05','airbrush',false)
where
    event_name = 'w_subscription_success'
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
group by 1,2

-- 新表口径


select -- platform,count(*)
    order_id,big_data
    ,get_json_object(big_data,'$.otid') AS otid
    ,get_json_object(big_data,'$.createdAt') AS createdAt
    ,get_json_object(big_data,'$.ad_id') AS adId
    ,get_json_object(big_data,'$.adjust_id') AS adjustId
    ,get_json_object(big_data,'$.firebase_id') AS firebaseId
    ,partner_pay_id,buyer_gid,contract_id,platform,create_time
 -- date_format(from_utc_timestamp(from_unixtime(floor(a.pay_time/1000)),'Asia/Shanghai'),'yyyyMMdd')  AS utc8_date
 FROM stat_vip.paid_sda_vip_tb_order a
    WHERE date_p between 20251020 and 20251110
    AND app_id NOT IN (7029803307008000000)
    AND supplier_id = 1 -- 会员中心
    AND order_status > 100 -- 已发货
    AND order_type IN (1, 2) -- 订阅续期非续期
    AND sandbox = 1 -- 沙盒账号测试新版本订单
    AND app_id IN (7329803307041000000, 7329803307042000000)
    AND nvl(get_json_object(base_data, '$.migrate_pay'), '') <> 'true'
    -- and platform = 2 -- ios
    and platform = 3 -- android
    order by create_time asc
  --  and promotion_status=2
--    limit 10

-- 透传数据确认
with order_info as
(
select -- platform,count(*)
    date_p,order_id,platform,amount
    ,get_json_object(big_data,'$.source_module') AS source_module
    ,get_json_object(big_data,'$.source_0') AS source_0
    ,get_json_object(big_data,'$.source_1') AS source_1
    ,get_json_object(big_data,'$.sale_status') AS sale_status
    ,get_json_object(big_data,'$.mids_material_id') AS mids_material_id
    ,get_json_object(big_data,'$.mids_category_id') AS mids_category_id
    ,get_json_object(big_data,'$.ad_id') AS ad_id
    ,get_json_object(big_data,'$.adjust_id') AS adjust_id
    ,get_json_object(big_data,'$.firebase_id') AS firebase_id
    ,partner_pay_id,buyer_gid,contract_id,create_time
    ,DATE_FORMAT(FROM_UNIXTIME(create_time/1000), 'yyyyMMdd') create_date
 -- date_format(from_utc_timestamp(from_unixtime(floor(a.pay_time/1000)),'Asia/Shanghai'),'yyyyMMdd')  AS utc8_date
 FROM stat_vip.paid_sda_vip_tb_order a
    WHERE date_p = 20251104
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
  --  and promotion_status=2
--    limit 10
)
-- select create_date,platform
--     ,count(1) pv
--     ,count(case when source_module is not null then 1 end) pv_source_module
--     ,count(case when source_0 is not null then 1 end) pv_source_0
--     ,count(case when source_1 is not null then 1 end) pv_source_1
--     ,count(case when sale_status is not null then 1 end) pv_sale_status
--     ,count(case when mids_material_id is not null then 1 end) pv_mids_material_id
--     ,count(case when mids_category_id is not null then 1 end) pv_mids_category_id
--     ,count(case when ad_id is not null then 1 end) pv_ad_id
--     ,count(case when adjust_id is not null then 1 end) pv_adjust_id
--     ,count(case when firebase_id is not null then 1 end) pv_firebase_id
-- from order_info
-- group by create_date,platform

select source_module,source_0
    ,count(1) pv
from order_info
group by source_module,source_0

;


select -- platform,count(*)
    order_id,platform
    ,get_json_object(big_data,'$.source_module') AS source_module
    ,big_data,base_data
    ,DATE_FORMAT(FROM_UNIXTIME(create_time/1000), 'yyyyMMdd') create_date
 -- date_format(from_utc_timestamp(from_unixtime(floor(a.pay_time/1000)),'Asia/Shanghai'),'yyyyMMdd')  AS utc8_date
 FROM stat_vip.paid_sda_vip_tb_order a
    WHERE date_p = 20251105
    AND app_id NOT IN (7029803307008000000)
    AND supplier_id = 1 -- 会员中心
    AND order_status > 100 -- 已发货
    AND order_type IN (1, 2) -- 订阅续期非续期
    AND sandbox = 0 -- 正常数据
    AND app_id IN (7329803307041000000, 7329803307042000000)
    AND platform in (2,3) -- 3:android 2:ios
    -- 删选新订阅中台的数据
    AND nvl(get_json_object(base_data, '$.migrate_order'), '') <> 'true'
    AND nvl(get_json_object(base_data, '$.migrate_contract'), '') <> 'true'
    AND oper_system != 0
;

-- 订单汇总表
select
	product_line,
	product_sub_line,
	date_p,
	app_id_p,
	commodity_id_p
from
	stat_vip.paid_oda_vip_all_order
where
	date_p = 20251104
    and app_id_p IN (7329803307041000000, 7329803307042000000)
    and order_type in (1,2)
--     and big_data is not null
limit 100



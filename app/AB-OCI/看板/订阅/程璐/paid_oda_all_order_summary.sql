set hive.exec.dynamic.partition.mode = nonstrict;
INSERT OVERWRITE TABLE stat_vip.paid_oda_all_order_summary partition(app_id_p)
SELECT  a.product_line             AS product_line
       ,a.product_sub_line         AS product_sub_line
       ,a.order_id                 AS order_id
       ,a.platform                 AS platform
       ,a.os_type                  AS os_type
       ,a.device_type              AS device_type
       ,a.gid                      AS gid
       ,a.uid                      AS uid
       ,a.pay_channel              AS pay_channel
       ,a.pay_date                 AS pay_date
       ,a.pay_status               AS pay_status
       ,a.ord_amt                  AS ord_amt
       ,a.ord_before_amt           AS ord_before_amt
       ,substr(a.refund_time,1,8)  AS refund_date
       ,a.refund_amt               AS refund_amt
       ,a.refund_before_amt        AS refund_before_amt
       ,'订阅'                       AS is_subscribe
       ,substr(a.invalid_time,1,8) AS invalid_date
       ,a.country_code             AS country_code
       ,'订阅'                       AS rights_name
       ,a.country_name             AS country_name
       ,a.continent_name           AS continent_name
       ,a.geographic_subdivision   AS geographic_subdivision
       ,a.cur_pay_withhold_stage   AS cur_pay_withhold_stage
       ,a.period_type              AS period_type
       ,a.partner_pay_id           AS partner_pay_id
       ,a.third_product_id         AS iap_product_id
       ,substr(a.create_time,1,8)  AS create_date
       ,a.device_id                AS device_id
       ,a.notify_pay_id            AS notify_pay_id
       ,a.buyer_gid                AS buyer_gid
       ,a.extro_info               AS extro_info
       ,a.order_type               AS order_type
       ,a.promotion_status         AS promotion_status
       ,a.cur_pay_stage            AS cur_pay_stage
       ,a.product_id               AS product_id
       ,a.product_name             AS product_name
       ,a.channel_fee_ratio        AS channel_fee_ratio
       ,a.big_data                 AS big_data
       ,a.ord_period_length        AS ord_period_length
       ,a.ord_amt_usd              AS ord_amt_usd
       ,a.refund_amt_usd           AS refund_amt_usd
       ,a.app_id_p                 AS app_id_p
FROM stat_vip.paid_oda_vip_all_order a
WHERE date_p = ${date_p}
AND app_id_p NOT IN (-1)
UNION ALL
SELECT  a.product_line            AS product_line
       ,a.product_sub_line        AS product_sub_line
       ,a.order_id                AS order_id
       ,a.platform                AS platform
       ,a.os_type                 AS os_type
       ,a.device_type             AS device_type
       ,a.gid                     AS gid
       ,a.uid                     AS uid
       ,a.pay_channel             AS pay_channel
       ,a.pay_date                AS pay_date
       ,a.pay_status              AS pay_status
       ,a.ord_amt                 AS ord_amt
       ,a.ord_before_amt          AS ord_before_amt
       ,a.refund_date             AS refund_date
       ,a.refund_amt              AS refund_amt
       ,a.refund_before_amt       AS refund_before_amt
       ,'单购'                      AS is_subscribe
       ,a.pay_date                AS invalid_date
       ,a.country_code            AS country_code
       ,a.rights_name             AS rights_name
       ,a.country_name            AS country_name
       ,a.continent_name          AS continent_name
       ,a.geographic_subdivision  AS geographic_subdivision
       ,1                         AS cur_pay_withhold_stage
       ,'单购'                      AS period_type
       ,a.partner_pay_id          AS partner_pay_id
       ,a.iap_product_id          AS iap_product_id
       ,substr(a.create_time,1,8) AS create_date
       ,a.device_id               AS device_id
       ,a.order_id                AS notify_pay_id
       ,a.gid                     AS buyer_gid
       ,map('','')                AS extro_info
       ,order_type                AS order_type
       ,0                         AS promotion_status
       ,1                         AS cur_pay_stage
       ,a.product_id              AS product_id
       ,a.product_name            AS product_name
       ,a.channel_fee_ratio       AS channel_fee_ratio
       ,a.big_data                AS big_data
       ,1                         AS ord_period_length
       ,a.ord_amt_usd             AS ord_amt_usd
       ,a.refund_amt_usd          AS refund_amt_usd
       ,a.app_id_p                AS app_id_p
FROM stat_vip.paid_oda_single_purchase_order a
WHERE date_p = ${date_p}
AND pay_channel IN ('iap', 'alipay', 'weixin', 'google', 'stripe')
AND app_id_p NOT IN (-1)
UNION ALL
SELECT  app.app_name                                                  AS product_line
       ,app.app_name                                                  AS product_sub_line
       ,a.id                                                          AS order_id
       ,CASE WHEN a.os_type IN ('windows','linux','mac','web') THEN 4
             WHEN a.os_type IN ('android','androidpad') THEN 1
             WHEN a.os_type IN ('ios','ipad') THEN 2 END              AS platform
       ,a.os_type                                                     AS os_type
       ,CASE WHEN a.os_type IN ('android','androidpad') THEN 'android'
             WHEN a.os_type IN ('ios','ipad') THEN 'ios'
             WHEN a.os_type IN ('windows','linux','mac') THEN 'pc'
             WHEN a.os_type IN ('web') THEN 'web'  ELSE 'unknown' END AS device_type
       ,a.gid                                                         AS gid
       ,a.uid                                                         AS uid
       ,'meidou'                                                      AS pay_channel
       ,a.create_date                                                 AS pay_date
       ,if(a.pay_rollback_amt > 0,6,3)                                AS pay_status
       ,a.pay_consume_amt                                             AS ord_amt
       ,a.pay_consume_amt                                             AS ord_before_amt
       ,substr(a.pay_rollback_time,1,8)                               AS refund_date
       ,a.pay_rollback_amt                                            AS refund_amt
       ,a.pay_rollback_amt                                            AS refund_before_amt
       ,'单购'                                                          AS is_subscribe
       ,a.create_date                                                 AS invalid_date
       ,a.country_code                                                AS country_code
       ,a.biz_sub_type                                                AS rights_name
       ,country.country_name                                          AS country_name
       ,country.continent_name                                        AS continent_name
       ,country.geographic_subdivision                                AS geographic_subdivision
       ,1                                                             AS cur_pay_withhold_stage
       ,'单购'                                                          AS period_type
       ,a.out_trade_no                                                AS partner_pay_id
       ,null                                                          AS iap_product_id
       ,a.create_date                                                 AS create_date
       ,a.device_id                                                   AS device_id
       ,a.id                                                          AS notify_pay_id
       ,a.gid                                                         AS buyer_gid
       ,map('','')                                                    AS extro_info
       ,4                                                             AS order_type
       ,0                                                             AS promotion_status
       ,1                                                             AS cur_pay_stage
       ,null                                                          AS product_id
       ,null                                                          AS product_name
       ,null                                                          AS channel_fee_ratio
       ,a.big_data                                                    AS big_data
       ,1                                                             AS ord_period_length
       ,a.pay_consume_amt_usd                                         AS ord_amt_usd
       ,a.pay_rollback_amt_usd                                        AS refund_amt_usd
       ,a.app_id                                                      AS app_id_p
FROM
(
    SELECT  a.*
    FROM stat_vip.paid_oda_virtual_consume_record a
    WHERE date_p = ${date_p}
    AND consumption_type = 3
    AND a.pay_consume_amt > 0
) a
LEFT JOIN
(
    SELECT  country_code
           ,country_name
           ,continent_name
           ,geographic_subdivision
           ,date_p
    FROM
    (
        SELECT  sdk_country_name                                                     AS country_name
               ,sdk_country_code                                                     AS country_code
               ,continent_name                                                       AS continent_name
               ,geographic_subdivision                                               AS geographic_subdivision
               ,date_p                                                               AS date_p
               ,ROW_NUMBER() over(PARTITION BY date_p,sdk_country_code ORDER BY  id) AS rn
        FROM stat_sdk.dim_rna_ip_location
        WHERE date_p = ${date_p}
        AND level = 1
        AND length(sdk_country_code) = 2
    ) a
    WHERE rn = 1
) country
ON a.country_code = country.country_code
LEFT JOIN
(
    SELECT  app_id
           ,app_name
    FROM stat_vip.paid_oda_vip_iap_app
) app
ON a.app_id = app.app_id
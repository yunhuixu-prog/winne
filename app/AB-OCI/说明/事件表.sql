SELECT 
    date_p
    ,`time` -- 事件时间戳
    ,DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
    ,event_id -- 事件id
    ,sdk_type as os_type -- 操作系统类型
    ,gid -- 用户标识id
    ,app_version -- 应用版本
    -- 以下为事件id对应的key，需要和埋点表对应
    ,params['source_module'] source_module
    ,params['source_0'] source_0
    ,params['source_1'] source_1
FROM stat_sdk.sdk_odz_source_data
WHERE date_p between ${start_date} and ${end_date}
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED') -- 应用key，此为必须字段
    AND event_id IN  ('w_subscription_enter','w_subscription_click','w_subscription_success') -- 事件id，需要和埋点表对应

-- iOS 订阅页商品加载时长：load_product_result 的 time_product / time_otid
-- 引擎：Presto（不行切换 hive）
-- 依据：口径/埋点验收.sql、订阅/临时/订阅中台迁移/订阅事件.sql、事件参数清单
-- 事件：load_product_result
--   time_product  拉取商品信息耗时（int，单位一般 ms）
--   time_otid     拉取 OTID 耗时（int，单位一般 ms；仅 iOS）

select
    sdk_type
    ,params['is_success'] is_success
    ,count(1) pv
    ,count(distinct gid) uv
    -- time_product
    ,round(avg(cast(params['time_product'] as double)), 2) avg_time_product
    -- time_otid（iOS）
    ,round(avg(cast(params['time_otid'] as double)), 2) avg_time_otid
from stat_sdk.sdk_odz_source_data
where date_p between 20260701 and 20260731
    and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id = 'load_product_result'
    and sdk_type = 'iOS'
    and params['time_product'] is not null
    and params['time_otid'] is not null
group by
    sdk_type
    ,params['is_success']

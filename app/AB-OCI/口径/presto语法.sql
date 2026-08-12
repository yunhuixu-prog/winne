-- 一行变多行
-- 仅看展开的列
select
        explode(SPLIT(source_0, ',')) t_0
    from
        bigdata_test.test_onz_sub_detail_1
    where
        date_p between 20251102 and 20251202
        and gid='2803002759'
-- 还要看其他不展开的列
select
        gid,source_module,source_0,source_1,s_0
    from
    (
        select gid,source_module,source_0,source_1
        from bigdata_test.test_onz_sub_detail_1
        where date_p between 20251102 and 20251202
            and gid='2727176124'
    ) t
    LATERAL VIEW explode(SPLIT(source_0, ',')) t0 AS s_0

-- 不行切换hive试下
-- 变为时间
DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
-- 变为日期
date_format(from_unixtime(unix_timestamp(CAST(pay_date AS STRING), 'yyyyMMdd')),'yyyy-MM-dd')
-- 字符串变为时间
from_unixtime(unix_timestamp(concat(substr(date_p,1,6),'01'), 'yyyyMMdd'))
-- 加减月份
add_months(from_unixtime(unix_timestamp(concat(substr(date_p,1,6),'01'), 'yyyyMMdd')),1)
CAST(date_format(date_add(from_unixtime(unix_timestamp(cast(date_p as string), 'yyyyMMdd')), 8), 'yyyyMMdd') AS BIGINT)
-- 加减日期
date_add(from_unixtime(unix_timestamp(cast(date_p as string), 'yyyyMMdd')), 8) -- 这个要用hive
CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT)
-- 提取年月 1.字符串直接提取 2.日期提取年月
substr(date_p,1,6)
date_format(date_p, 'yyyyMM')
-- 专属函数
meitu_datediff(date_p, first_launch_date) -- 计算两个日期之间的天数差,日期格式就是yyyyMMdd

-- 字符串用；分隔
split(params['prf_jaw_mod'],'\073')

-- 版本号>=7.17.1
-- 1. 主版本号大于 7
CAST(split(app_version, '\\.')[0] AS INT) > 7
-- 2. 或者主版本号等于 7，且次版本号大于 17
OR (
    CAST(split(app_version, '\\.')[0] AS INT) = 7
    AND CAST(split(app_version, '\\.')[1] AS INT) > 17
)
-- 3. 或者主版本等于 7，次版本等于 17，且修订版本大于 1
OR (
    CAST(split(app_version, '\\.')[0] AS INT) = 7
    AND CAST(split(app_version, '\\.')[1] AS INT) = 17
    AND CAST(split(app_version, '\\.')[2] AS INT) >= 1
)

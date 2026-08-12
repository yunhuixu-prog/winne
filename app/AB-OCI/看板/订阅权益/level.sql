SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;
insert overwrite table stat_ab.filing_mnz_sub_source_event_detail_level PARTITION(date_p)

select
        '一级' level,os_type,country,is_new,is_ua,app_version,
        '整体' duration,'整体' sku,first_source,'整体' second_source,'整体' third_source,'整体' fourth_source,
        sub_enter_uv,
        sub_click_uv,
        sub_suc_uv,
        sub_paid_uv,
        sub_paid_ord_amt,
        sub_paid_ord_before_amt,
        sub_trial_uv,
        sub_trial_paid_uv,
        sub_trial_paid_ord_amt,
        sub_trial_paid_ord_before_amt,
        sub_direct_paid_uv,
        sub_direct_paid_ord_amt,
        sub_direct_paid_ord_before_amt,
        date_p
from
(
    select
        nvl(os_type, '整体') as os_type,
        nvl(country, '整体') as country,
        nvl(is_new, '整体') as is_new,
        nvl(is_ua, '整体') as is_ua,
        nvl(app_version, '整体') as app_version,
        nvl(first_source, '整体') as first_source,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
--         sum(sub_suc_order_uv) sub_suc_order_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        sum(sub_paid_ord_amt) sub_paid_ord_amt,
        sum(sub_paid_ord_before_amt) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        sum(sub_trial_paid_ord_amt) sub_trial_paid_ord_amt,
        sum(sub_trial_paid_ord_before_amt) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        sum(sub_direct_paid_ord_amt) sub_direct_paid_ord_amt,
        sum(sub_direct_paid_ord_before_amt) sub_direct_paid_ord_before_amt,
        date_p
    from
    (
        select
            nvl(os_type,'未知') AS os_type,
            nvl(country,'未知') AS country,
            nvl(is_new,'未知') AS is_new,
            nvl(is_ua,'未知') AS is_ua,
            nvl(app_version,'未知') AS app_version,
--             nvl(sale_status,'未知') AS sale_status,
--             nvl(duration,'未知') AS duration,
--             nvl(sku,'未知') AS sku,
            nvl(first_source,'未知') AS first_source,
--             nvl(second_source,'未知') AS second_source,
--             nvl(third_source,'未知') AS third_source,
--             nvl(fourth_source,'未知') AS fourth_source,
            count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
            count(distinct case when event_id='sub_click' then gid end) sub_click_uv,
    --         count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
            count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv,
            count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_paid_ord_before_amt,
            -- 试用
            count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv,
            count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_paid_uv,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_paid_ord_before_amt,
            -- 直接付费
            count(distinct case when event_id='sub_suc' and is_direct_paid=1 then gid end) sub_direct_paid_uv,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_amt end) sub_direct_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_before_amt end) sub_direct_paid_ord_before_amt,

            date_p
        from stat_ab.filing_onz_sub_source_event_detail_level
        where date_p between ${start_time} and ${end_time}
        group by os_type,country,is_new,is_ua,app_version,first_source,date_p
    ) aa
    group by os_type,country,is_new,is_ua,app_version,first_source,date_p GROUPING SETS (
        (os_type,country,is_new,is_ua,app_version,first_source,date_p),
        -- 5维度
        (os_type, country, is_new, is_ua, first_source, date_p),
        (os_type, country, is_new, app_version, first_source, date_p),
        (os_type, country, is_ua, app_version, first_source, date_p),
        (os_type, is_new, is_ua, app_version, first_source, date_p),
        (country, is_new, is_ua, app_version, first_source, date_p),
        -- 4维度
        (os_type, country, is_new, first_source, date_p),
        (os_type, country, is_ua, first_source, date_p),
        (os_type, country, app_version, first_source, date_p),
        (os_type, is_new, is_ua, first_source, date_p),
        (os_type, is_new, app_version, first_source, date_p),
        (os_type, is_ua, app_version, first_source, date_p),
        (country, is_new, is_ua, first_source, date_p),
        (country, is_new, app_version, first_source, date_p),
        (country, is_ua, app_version, first_source, date_p),
        (is_new, is_ua, app_version, first_source, date_p),
        -- 3维度
        (os_type, country, first_source, date_p),
        (os_type, is_new, first_source, date_p),
        (os_type, is_ua, first_source, date_p),
        (os_type, app_version, first_source, date_p),
        (country, is_new, first_source, date_p),
        (country, is_ua, first_source, date_p),
        (country, app_version, first_source, date_p),
        (is_new, is_ua, first_source, date_p),
        (is_new, app_version, first_source, date_p),
        (is_ua, app_version, first_source, date_p),
        -- 2维度
        (os_type, first_source, date_p),
        (country, first_source, date_p),
        (is_new, first_source, date_p),
        (is_ua, first_source, date_p),
        (app_version, first_source, date_p),
        -- 1维度
        (first_source, date_p)
      )
) a

union all

select
        '二级' level,os_type,country,is_new,is_ua,app_version,
        '整体' duration,'整体' sku,first_source,second_source,'整体' third_source,'整体' fourth_source,
        sub_enter_uv,
        sub_click_uv,
        sub_suc_uv,
        sub_paid_uv,
        sub_paid_ord_amt,
        sub_paid_ord_before_amt,
        sub_trial_uv,
        sub_trial_paid_uv,
        sub_trial_paid_ord_amt,
        sub_trial_paid_ord_before_amt,
        sub_direct_paid_uv,
        sub_direct_paid_ord_amt,
        sub_direct_paid_ord_before_amt,
        date_p
from
(
    select
        nvl(os_type, '整体') as os_type,
        nvl(country, '整体') as country,
        nvl(is_new, '整体') as is_new,
        nvl(is_ua, '整体') as is_ua,
        nvl(app_version, '整体') as app_version,
        nvl(first_source, '整体') as first_source,
        nvl(second_source, '整体') as second_source,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
--         sum(sub_suc_order_uv) sub_suc_order_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        sum(sub_paid_ord_amt) sub_paid_ord_amt,
        sum(sub_paid_ord_before_amt) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        sum(sub_trial_paid_ord_amt) sub_trial_paid_ord_amt,
        sum(sub_trial_paid_ord_before_amt) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        sum(sub_direct_paid_ord_amt) sub_direct_paid_ord_amt,
        sum(sub_direct_paid_ord_before_amt) sub_direct_paid_ord_before_amt,
        date_p
    from
    (
        select
            nvl(os_type,'未知') AS os_type,
            nvl(country,'未知') AS country,
            nvl(is_new,'未知') AS is_new,
            nvl(is_ua,'未知') AS is_ua,
            nvl(app_version,'未知') AS app_version,
--             nvl(sale_status,'未知') AS sale_status,
--             nvl(duration,'未知') AS duration,
--             nvl(sku,'未知') AS sku,
            nvl(first_source,'未知') AS first_source,
            nvl(second_source,'未知') AS second_source,
--             nvl(third_source,'未知') AS third_source,
--             nvl(fourth_source,'未知') AS fourth_source,
            count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
            count(distinct case when event_id='sub_click' then gid end) sub_click_uv,
    --         count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
            count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv,
            count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_paid_ord_before_amt,
            -- 试用
            count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv,
            count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_paid_uv,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_paid_ord_before_amt,
            -- 直接付费
            count(distinct case when event_id='sub_suc' and is_direct_paid=1 then gid end) sub_direct_paid_uv,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_amt end) sub_direct_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_before_amt end) sub_direct_paid_ord_before_amt,

            date_p
        from stat_ab.filing_onz_sub_source_event_detail_level
        where date_p between ${start_time} and ${end_time}
        group by os_type,country,is_new,is_ua,app_version,first_source,second_source,date_p
    ) aa
    group by os_type,country,is_new,is_ua,app_version,first_source,second_source,date_p GROUPING SETS (
        (os_type,country,is_new,is_ua,app_version,first_source,second_source,date_p),
        -- 5维度
        (os_type, country, is_new, is_ua, first_source, second_source, date_p),
        (os_type, country, is_new, app_version, first_source, second_source, date_p),
        (os_type, country, is_ua, app_version, first_source, second_source, date_p),
        (os_type, is_new, is_ua, app_version, first_source, second_source, date_p),
        (country, is_new, is_ua, app_version, first_source, second_source, date_p),
        -- 4维度
        (os_type, country, is_new, first_source, second_source, date_p),
        (os_type, country, is_ua, first_source, second_source, date_p),
        (os_type, country, app_version, first_source, second_source, date_p),
        (os_type, is_new, is_ua, first_source, second_source, date_p),
        (os_type, is_new, app_version, first_source, second_source, date_p),
        (os_type, is_ua, app_version, first_source, second_source, date_p),
        (country, is_new, is_ua, first_source, second_source, date_p),
        (country, is_new, app_version, first_source, second_source, date_p),
        (country, is_ua, app_version, first_source, second_source, date_p),
        (is_new, is_ua, app_version, first_source, second_source, date_p),
        -- 3维度
        (os_type, country, first_source, second_source, date_p),
        (os_type, is_new, first_source, second_source, date_p),
        (os_type, is_ua, first_source, second_source, date_p),
        (os_type, app_version, first_source, second_source, date_p),
        (country, is_new, first_source, second_source, date_p),
        (country, is_ua, first_source, second_source, date_p),
        (country, app_version, first_source, second_source, date_p),
        (is_new, is_ua, first_source, second_source, date_p),
        (is_new, app_version, first_source, second_source, date_p),
        (is_ua, app_version, first_source, second_source, date_p),
        -- 2维度
        (os_type, first_source, second_source, date_p),
        (country, first_source, second_source, date_p),
        (is_new, first_source, second_source, date_p),
        (is_ua, first_source, second_source, date_p),
        (app_version, first_source, second_source, date_p),
        -- 1维度
        (first_source, second_source, date_p)
      )
) a

union all

select
        '三级' level,os_type,country,is_new,is_ua,app_version,
        '整体' duration,'整体' sku,first_source,second_source,third_source,'整体' fourth_source,
        sub_enter_uv,
        sub_click_uv,
        sub_suc_uv,
        sub_paid_uv,
        sub_paid_ord_amt,
        sub_paid_ord_before_amt,
        sub_trial_uv,
        sub_trial_paid_uv,
        sub_trial_paid_ord_amt,
        sub_trial_paid_ord_before_amt,
        sub_direct_paid_uv,
        sub_direct_paid_ord_amt,
        sub_direct_paid_ord_before_amt,
        date_p
from
(
    select
        nvl(os_type, '整体') as os_type,
        nvl(country, '整体') as country,
        nvl(is_new, '整体') as is_new,
        nvl(is_ua, '整体') as is_ua,
        nvl(app_version, '整体') as app_version,
        nvl(first_source, '整体') as first_source,
        nvl(second_source, '整体') as second_source,
        nvl(third_source, '整体') as third_source,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
--         sum(sub_suc_order_uv) sub_suc_order_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        sum(sub_paid_ord_amt) sub_paid_ord_amt,
        sum(sub_paid_ord_before_amt) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        sum(sub_trial_paid_ord_amt) sub_trial_paid_ord_amt,
        sum(sub_trial_paid_ord_before_amt) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        sum(sub_direct_paid_ord_amt) sub_direct_paid_ord_amt,
        sum(sub_direct_paid_ord_before_amt) sub_direct_paid_ord_before_amt,
        date_p
    from
    (
        select
            nvl(os_type,'未知') AS os_type,
            nvl(country,'未知') AS country,
            nvl(is_new,'未知') AS is_new,
            nvl(is_ua,'未知') AS is_ua,
            nvl(app_version,'未知') AS app_version,
--             nvl(sale_status,'未知') AS sale_status,
--             nvl(duration,'未知') AS duration,
--             nvl(sku,'未知') AS sku,
            nvl(first_source,'未知') AS first_source,
            nvl(second_source,'未知') AS second_source,
            nvl(third_source,'未知') AS third_source,
--             nvl(fourth_source,'未知') AS fourth_source,
            count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
            count(distinct case when event_id='sub_click' then gid end) sub_click_uv,
    --         count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
            count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv,
            count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_paid_ord_before_amt,
            -- 试用
            count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv,
            count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_paid_uv,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_paid_ord_before_amt,
            -- 直接付费
            count(distinct case when event_id='sub_suc' and is_direct_paid=1 then gid end) sub_direct_paid_uv,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_amt end) sub_direct_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_before_amt end) sub_direct_paid_ord_before_amt,

            date_p
        from stat_ab.filing_onz_sub_source_event_detail_level
        where date_p between ${start_time} and ${end_time}
        group by os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,date_p
    ) aa
    group by os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,date_p GROUPING SETS (
        (os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,date_p),
        -- 5维度
        (os_type, country, is_new, is_ua, first_source, second_source, third_source, date_p),
        (os_type, country, is_new, app_version, first_source, second_source, third_source, date_p),
        (os_type, country, is_ua, app_version, first_source, second_source, third_source, date_p),
        (os_type, is_new, is_ua, app_version, first_source, second_source, third_source, date_p),
        (country, is_new, is_ua, app_version, first_source, second_source, third_source, date_p),
        -- 4维度
        (os_type, country, is_new, first_source, second_source, third_source, date_p),
        (os_type, country, is_ua, first_source, second_source, third_source, date_p),
        (os_type, country, app_version, first_source, second_source, third_source, date_p),
        (os_type, is_new, is_ua, first_source, second_source, third_source, date_p),
        (os_type, is_new, app_version, first_source, second_source, third_source, date_p),
        (os_type, is_ua, app_version, first_source, second_source, third_source, date_p),
        (country, is_new, is_ua, first_source, second_source, third_source, date_p),
        (country, is_new, app_version, first_source, second_source, third_source, date_p),
        (country, is_ua, app_version, first_source, second_source, third_source, date_p),
        (is_new, is_ua, app_version, first_source, second_source, third_source, date_p),
        -- 3维度
        (os_type, country, first_source, second_source, third_source, date_p),
        (os_type, is_new, first_source, second_source, third_source, date_p),
        (os_type, is_ua, first_source, second_source, third_source, date_p),
        (os_type, app_version, first_source, second_source, third_source, date_p),
        (country, is_new, first_source, second_source, third_source, date_p),
        (country, is_ua, first_source, second_source, third_source, date_p),
        (country, app_version, first_source, second_source, third_source, date_p),
        (is_new, is_ua, first_source, second_source, third_source, date_p),
        (is_new, app_version, first_source, second_source, third_source, date_p),
        (is_ua, app_version, first_source, second_source, third_source, date_p),
        -- 2维度
        (os_type, first_source, second_source, third_source, date_p),
        (country, first_source, second_source, third_source, date_p),
        (is_new, first_source, second_source, third_source, date_p),
        (is_ua, first_source, second_source, third_source, date_p),
        (app_version, first_source, second_source, third_source, date_p),
        -- 1维度
        (first_source, second_source, third_source, date_p)
      )
) a

union all

select
        '四级' level,os_type,country,is_new,is_ua,app_version,
        '整体' duration,'整体' sku,first_source,second_source,third_source,fourth_source,
        sub_enter_uv,
        sub_click_uv,
        sub_suc_uv,
        sub_paid_uv,
        sub_paid_ord_amt,
        sub_paid_ord_before_amt,
        sub_trial_uv,
        sub_trial_paid_uv,
        sub_trial_paid_ord_amt,
        sub_trial_paid_ord_before_amt,
        sub_direct_paid_uv,
        sub_direct_paid_ord_amt,
        sub_direct_paid_ord_before_amt,
        date_p
from
(
    select
        nvl(os_type, '整体') as os_type,
        nvl(country, '整体') as country,
        nvl(is_new, '整体') as is_new,
        nvl(is_ua, '整体') as is_ua,
        nvl(app_version, '整体') as app_version,
        nvl(first_source, '整体') as first_source,
        nvl(second_source, '整体') as second_source,
        nvl(third_source, '整体') as third_source,
        nvl(fourth_source, '整体') as fourth_source,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
--         sum(sub_suc_order_uv) sub_suc_order_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        sum(sub_paid_ord_amt) sub_paid_ord_amt,
        sum(sub_paid_ord_before_amt) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        sum(sub_trial_paid_ord_amt) sub_trial_paid_ord_amt,
        sum(sub_trial_paid_ord_before_amt) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        sum(sub_direct_paid_ord_amt) sub_direct_paid_ord_amt,
        sum(sub_direct_paid_ord_before_amt) sub_direct_paid_ord_before_amt,
        date_p
    from
    (
        select
            nvl(os_type,'未知') AS os_type,
            nvl(country,'未知') AS country,
            nvl(is_new,'未知') AS is_new,
            nvl(is_ua,'未知') AS is_ua,
            nvl(app_version,'未知') AS app_version,
--             nvl(sale_status,'未知') AS sale_status,
--             nvl(duration,'未知') AS duration,
--             nvl(sku,'未知') AS sku,
            nvl(first_source,'未知') AS first_source,
            nvl(second_source,'未知') AS second_source,
            nvl(third_source,'未知') AS third_source,
            nvl(fourth_source,'未知') AS fourth_source,
            count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
            count(distinct case when event_id='sub_click' then gid end) sub_click_uv,
    --         count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
            count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv,
            count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_paid_ord_before_amt,
            -- 试用
            count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv,
            count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_paid_uv,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_paid_ord_before_amt,
            -- 直接付费
            count(distinct case when event_id='sub_suc' and is_direct_paid=1 then gid end) sub_direct_paid_uv,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_amt end) sub_direct_paid_ord_amt,
            sum(case when event_id='sub_suc' and is_direct_paid=1 then devide_direct_paid_ord_before_amt end) sub_direct_paid_ord_before_amt,

            date_p
        from stat_ab.filing_onz_sub_source_event_detail_level
        where date_p between ${start_time} and ${end_time}
        group by os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,fourth_source,date_p
    ) aa
    group by os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,fourth_source,date_p GROUPING SETS (
        (os_type,country,is_new,is_ua,app_version,first_source,second_source,third_source,fourth_source,date_p),
        -- 5维度
        (os_type, country, is_new, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, country, is_new, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, country, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_new, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_new, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        -- 4维度
        (os_type, country, is_new, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, country, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, country, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_new, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_new, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_new, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_new, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (is_new, is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        -- 3维度
        (os_type, country, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_new, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (os_type, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_new, first_source, second_source, third_source, fourth_source, date_p),
        (country, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (country, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (is_new, is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (is_new, app_version, first_source, second_source, third_source, fourth_source, date_p),
        (is_ua, app_version, first_source, second_source, third_source, fourth_source, date_p),
        -- 2维度
        (os_type, first_source, second_source, third_source, fourth_source, date_p),
        (country, first_source, second_source, third_source, fourth_source, date_p),
        (is_new, first_source, second_source, third_source, fourth_source, date_p),
        (is_ua, first_source, second_source, third_source, fourth_source, date_p),
        (app_version, first_source, second_source, third_source, fourth_source, date_p),
        -- 1维度
        (first_source, second_source, third_source, fourth_source, date_p)
      )
) a
;

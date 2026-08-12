SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;
insert overwrite table stat_ab.filing_mnz_sub_source_event_sku_level PARTITION(date_p)

select
        'SKU' level,os_type,country,is_new,is_ua,app_version,
        duration,sku,'整体' first_source,'整体' second_source,'整体' third_source,'整体' fourth_source,
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
        nvl(duration, '整体') as duration,
        nvl(sku, '整体') as sku,
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
            nvl(duration,'未知') AS duration,
            nvl(sku,'未知') AS sku,
--             nvl(first_source,'未知') AS first_source,
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
        group by os_type,country,is_new,is_ua,app_version,duration,sku,date_p
    ) aa
    group by os_type,country,is_new,is_ua,app_version,duration,sku,date_p GROUPING SETS (
        (os_type,country,is_new,is_ua,app_version,duration,date_p),

        (os_type, country, is_new, is_ua, duration, date_p),
        (os_type, country, is_new, app_version, duration, date_p),
        (os_type, country, is_ua, app_version, duration, date_p),
        (os_type, is_new, is_ua, app_version, duration, date_p),
        (country, is_new, is_ua, app_version, duration, date_p),

        (os_type, country, is_new, duration, date_p),
        (os_type, country, is_ua, duration, date_p),
        (os_type, country, app_version, duration, date_p),
        (os_type, is_new, is_ua, duration, date_p),
        (os_type, is_new, app_version, duration, date_p),
        (os_type, is_ua, app_version, duration, date_p),
        (country, is_new, is_ua, duration, date_p),
        (country, is_new, app_version, duration, date_p),
        (country, is_ua, app_version, duration, date_p),
        (is_new, is_ua, app_version, duration, date_p),

        (os_type, country, duration, date_p),
        (os_type, is_new, duration, date_p),
        (os_type, is_ua, duration, date_p),
        (os_type, app_version, duration, date_p),
        (country, is_new, duration, date_p),
        (country, is_ua, duration, date_p),
        (country, app_version, duration, date_p),
        (is_new, is_ua, duration, date_p),
        (is_new, app_version, duration, date_p),
        (is_ua, app_version, duration, date_p),

        (os_type, duration, date_p),
        (country, duration, date_p),
        (is_new, duration, date_p),
        (is_ua, duration, date_p),
        (app_version, duration, date_p),
        (duration, date_p),

        (os_type,country,is_new,is_ua,app_version,duration,sku,date_p),

        (os_type, country, is_new, is_ua, duration, sku, date_p),
        (os_type, country, is_new, app_version, duration, sku, date_p),
        (os_type, country, is_ua, app_version, duration, sku, date_p),
        (os_type, is_new, is_ua, app_version, duration, sku, date_p),
        (country, is_new, is_ua, app_version, duration, sku, date_p),

        (os_type, country, is_new, duration, sku, date_p),
        (os_type, country, is_ua, duration, sku, date_p),
        (os_type, country, app_version, duration, sku, date_p),
        (os_type, is_new, is_ua, duration, sku, date_p),
        (os_type, is_new, app_version, duration, sku, date_p),
        (os_type, is_ua, app_version, duration, sku, date_p),
        (country, is_new, is_ua, duration, sku, date_p),
        (country, is_new, app_version, duration, sku, date_p),
        (country, is_ua, app_version, duration, sku, date_p),
        (is_new, is_ua, app_version, duration, sku, date_p),

        (os_type, country, duration, sku, date_p),
        (os_type, is_new, duration, sku, date_p),
        (os_type, is_ua, duration, sku, date_p),
        (os_type, app_version, duration, sku, date_p),
        (country, is_new, duration, sku, date_p),
        (country, is_ua, duration, sku, date_p),
        (country, app_version, duration, sku, date_p),
        (is_new, is_ua, duration, sku, date_p),
        (is_new, app_version, duration, sku, date_p),
        (is_ua, app_version, duration, sku, date_p),

        (os_type, duration, sku, date_p),
        (country, duration, sku, date_p),
        (is_new, duration, sku, date_p),
        (is_ua, duration, sku, date_p),
        (app_version, duration, sku, date_p),

        (duration, sku, date_p)
      )
) a
;
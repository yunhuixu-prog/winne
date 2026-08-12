-- pix（看历史数据）
select EXTRACT(YEAR FROM event_date) year
    ,platform,country,is_new,is_ua
    ,round(sum(dau)/count(distinct event_date),0) dau
    -- ,round(sum(sub_enter_uv)/count(distinct event_date),0) sub_enter_uv
    -- ,round(sum(sub_click_uv)/count(distinct event_date),0) sub_click_uv
    ,round(sum(sub_success_uv)/count(distinct event_date),0) sub_success_uv
    -- ,round(sum(sub_success_to_paid_uv)/count(distinct event_date),0) sub_success_to_paid_uv
    -- ,round(sum(sub_success_to_paid_gmv)/count(distinct event_date),0) sub_success_to_paid_gmv
    ,round(sum(sub_trial_uv)/count(distinct event_date),0) sub_trial_uv
    ,round(sum(sub_trial_to_paid_uv)/count(distinct event_date),0) sub_trial_to_paid_uv
    -- ,round(sum(sub_trial_to_paid_gmv)/count(distinct event_date),0) sub_trial_to_paid_gmv
from (
    select event_date
        ,platform
        ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country
        ,is_new
        ,is_ua
        ,count(distinct case when event_name ='DAU' then user_pseudo_id end) dau
        ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name ='w_subscription_click' then user_pseudo_id end) sub_click_uv
        ,count(distinct case when event_name ='sub_suc' then user_pseudo_id end) sub_success_uv
        ,count(distinct case when event_name ='sub_to_paid' then user_pseudo_id end) sub_success_to_paid_uv
        ,sum(case when event_name = 'sub_to_paid' then payment_price_usd else 0 end) sub_success_to_paid_gmv

        ,count(distinct case when event_name ='trial' then user_pseudo_id end) sub_trial_uv
        ,count(distinct case when event_name ='trial_to_paid' then user_pseudo_id end) sub_trial_to_paid_uv
        ,sum(case when event_name = 'trial_to_paid' then payment_price_usd else 0 end) sub_trial_to_paid_gmv
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module = 'all'
    and event_date between '2024-01-01' and '2026-04-30'
    group by 1,2,3,4,5
)
group by 1,2,3,4,5
;



select EXTRACT(YEAR FROM event_date) year,first,second,third
    ,round(sum(sub_success_uv)/count(distinct event_date),0) sub_success_uv
    ,round(sum(sub_trial_uv)/count(distinct event_date),0) sub_trial_uv
    ,round(sum(sub_trial_to_paid_uv)/count(distinct event_date),0) sub_trial_to_paid_uv
from (
select event_date
        -- ,platform,country
        -- ,is_new,is_ua
        ,first,second,third
        ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name ='w_subscription_click' then user_pseudo_id end) sub_click_uv
        ,count(distinct case when event_name ='sub_suc' then user_pseudo_id end) sub_success_uv
        ,count(distinct case when event_name ='sub_to_paid' then user_pseudo_id end) sub_success_to_paid_uv
        ,sum(case when event_name = 'sub_to_paid' then payment_price_usd else 0 end) sub_success_to_paid_gmv

        ,count(distinct case when event_name ='trial' then user_pseudo_id end) sub_trial_uv
        ,count(distinct case when event_name ='trial_to_paid' then user_pseudo_id end) sub_trial_to_paid_uv
        ,sum(case when event_name = 'trial_to_paid' then payment_price_usd else 0 end) sub_trial_to_paid_gmv
    from `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
    where event_date between '2024-01-01' and '2026-04-30'
        and category='Third Source'
        -- and first!='A' and second!='A' and (third!='A' or third is null) and fourth='A'
    group by 1,2,3,4
)
group by 1,2,3,4



;

-- oci
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
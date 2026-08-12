-- 明细表（两种收入差异gid）：订单表比埋点多8%左右，看明细有些订单是真的没有上报
select a.date_p,a.gid gid_maidian,b.date_p date_p_1,b.gid gid_order
select count(distinct a.gid) gid_maidian,count(distinct b.gid) gid_order
     ,count(distinct case when a.gid is not null and b.gid is not null then a.gid end) gid_all
     ,count(distinct case when a.gid is not null and b.gid is null then a.gid end) gid_only_maidian
     ,count(distinct case when a.gid is null and b.gid is not null then b.gid end) gid_only_order
from
(
    select distinct date_p,gid
    from stat_ab.filing_onz_sub_source_event_detail
    where date_p between 20260101 and 20260101
        and event_id='w_subscription_success'
) a
full join
(
    select distinct date_p,gid
    from stat_ab.filing_onz_sub_source_event_detail
    where date_p between 20260101 and 20260101
        and event_id='sub_suc'
) b
on a.date_p=b.date_p and a.gid=b.gid
where a.gid is null or b.gid is null
;

-- 明细层级表验收（两种收入口径gap）
select
    date_p,
    count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
    count(distinct case when event_id='sub_click' then gid end) sub_click_uv,

    count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
    count(distinct case when event_id='sub_suc_order' and is_paid=1 then gid end) sub_order_paid_uv,
    sum(case when event_id='sub_suc_order' and is_paid=1 then devide_paid_ord_before_amt end) sub_order_paid_ord_before_amt,

    count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv,
    count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv,
--     sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
    sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_paid_ord_before_amt
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20260101 and 20260118
group by date_p
;
-- 最终的汇总表验收
select level,date_p,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        round(sum(sub_paid_ord_amt),2) sub_paid_ord_amt,
        round(sum(sub_paid_ord_before_amt),2) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        round(sum(sub_trial_paid_ord_amt),2) sub_trial_paid_ord_amt,
        round(sum(sub_trial_paid_ord_before_amt),2) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        round(sum(sub_direct_paid_ord_amt),2) sub_direct_paid_ord_amt,
        round(sum(sub_direct_paid_ord_before_amt),2) sub_direct_paid_ord_before_amt
from stat_ab.filing_anz_sub_source_event_show
where date_p between 20260101 and 20260101
    and os_type='整体'
    and country='整体'
    and is_new='整体'
    and is_ua='整体'
    and app_version='整体'
group by level,date_p




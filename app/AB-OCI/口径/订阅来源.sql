-- 明细层(订阅收入需要再关联下，建议用层级表)
select
    date_p
    ,count(case when event_id='w_subscription_enter' then 1 end) sub_enter_pv
    ,count(case when event_id='w_subscription_click' then 1 end) sub_click_pv
    ,count(case when event_id='w_subscription_success' then 1 end) sub_suc_pv
    ,count(case when event_id='sub_suc' then 1 end) sub_suc_pv_1
    ,count(case when event_id='sub_suc' and is_paid=1 then 1 end) sub_suc_to_paid_pv
    ,round(sum(case when event_id='sub_suc' and is_paid=1 then paid_ord_amt end),2) sub_suc_to_paid_gmv

    ,count(case when event_id='w_subscription_enter' and
        (source_module in ('p_onboarding','p_update_first_launch')
            or source_0 in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021')) then 1 end) force_sub_enter_pv
    ,count(case when event_id='w_subscription_enter' and
        (source_module in ('p_edit')
            and source_0 not in ('hpp','hbr','sub_to_guide','new_free_saves')) then 1 end) edit_sub_enter_pv
from stat_ab.filing_onz_sub_source_event_detail
where date_p between ${start_date} and ${end_date_add_7}
    and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
group by date_p

-- 层级层
select
    date_p,gid
    ,MAX(case when event_id='sub_enter' then 1 end) is_sub_enter
    ,COUNT(case when event_id='sub_enter' then 1 end) sub_enter_pv
    ,MAX(case when event_id='sub_suc' then 1 end) is_sub
    ,MAX(case when event_id='sub_suc' and is_paid=1 then 1 end) is_sub_to_paid
    ,SUM(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between ${start_time} and ${end_time}
group by date_p,gid

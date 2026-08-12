with paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` 
    where app_id ='AirBrush'
    and standard_order_date >= '2025-04-02' 
    and order_status in (0,1,2)
)
,sub_to_paid as
(
    select
        a.date,a.user_pseudo_id,a.event_name,a.event_timestamp,b.standard_order_date, b.original_order_id ,b.sku,b.order_status
        ,b.payment_price_usd
        ,next_standard_order_date
        ,next_payment_price_usd
    from
        (
        select
        *
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        where event_name = 'w_subscription_success'
        )a
        join paid b on a.order_id = b.order_id and a.sku = b.sku
)

select 
    a.platform,a.ab_code
    ,'All' types
    ,'All' source_module
    ,'All' source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd  
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_behavior_analysis` a
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6

union all

select
    a.platform,a.ab_code
    ,'module' types
    ,coalesce(a.source_module,'unknown') source_module
    ,'All' source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_behavior_analysis` a
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6


union all

select
    a.platform,a.ab_code
    ,'source0' types
    ,coalesce(a.source_module,'unknown') source_module
    ,coalesce(s0,'others') source_0
    ,'All' source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_behavior_analysis` a,unnest(split(coalesce(source_0,'others'),',')) s0 --,unnest(split(coalesce(source_1,'others'),',')) s1
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6


union all

select
    a.platform,a.ab_code
    ,'source1' types
    ,coalesce(a.source_module,'unknown') source_module
    ,coalesce(s0,'others') source_0
    ,coalesce(s1,'others') source_1
    -- 付费
    ,count(distinct case when a.event_name ='w_subscription_enter' then a.user_pseudo_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.user_pseudo_id  end) sub_click_uv
    ,count(distinct c.user_pseudo_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.user_pseudo_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.user_pseudo_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv
from `dataintegration-265403.temp.new_user_behavior_analysis` a,unnest(split(coalesce(source_0,'others'),',')) s0,unnest(split(coalesce(source_1,'others'),',')) s1
    left join sub_to_paid c
    on c.date = a.date and c.user_pseudo_id = a.user_pseudo_id and c.event_name = a.event_name and c.event_timestamp = a.event_timestamp
where date_diff(a.date,a.enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6
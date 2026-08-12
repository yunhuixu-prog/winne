drop table if exists `dataintegration-265403.temp.winne_temp_sub_LTV_value`;
create table if not exists `dataintegration-265403.temp.winne_temp_sub_LTV_value` as

with sub_eves as (
select distinct
      event_date,
      platform,
      country,
      is_new,is_ua,
      sku_type,
      sku_has_trial,
      sku,
      duration,
--       source_module,source_00,sale_status,source_11, -- 会算多
      user_pseudo_id,new_uuid uuid,
      payment_price_usd,
      standard_order_date,purchase_date
from `airbrush-1324.stat.dws_airbrush_trial_sub_sku_info`
where standard_order_date is not null and purchase_date is not null
    and event_date >= '2021-10-01'
    and event_date <= '2025-09-15'
)
,
paid as
(
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd,subscription_user_type,uuid
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2021-10-01'
    and order_status in (1,2)
)
,
LTV as
(
    select date(s.event_date) event_date
        ,date(s.standard_order_date) standard_order_date,date(s.purchase_date) purchase_date
        ,s.user_pseudo_id,s.uuid,s.payment_price_usd
        ,s.duration,s.sku,s.country,s.platform,s.is_new,s.is_ua

        ,date(p.standard_order_date) future_pay_date
        ,p.payment_price_usd future_bookings
        ,p.subscription_user_type future_subscription_type
        ,p.sku future_sku
    from sub_eves s
    join paid p
    on s.uuid=p.uuid and p.standard_order_date>=s.purchase_date
)

select a.*
from LTV a
left join
(
    select event_date,user_pseudo_id,count(1) order_num,sum(future_bookings) bookings
    from LTV
    where future_pay_date between purchase_date and date_add(purchase_date,interval 365 day)
    group by 1,2
    having count(1) > 30 or sum(future_bookings)>400
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
where b.user_pseudo_id is null

;
select *
from `dataintegration-265403.temp.winne_temp_sub_LTV_value`
where uuid='435157'
order by event_date,future_pay_date
;
select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd,subscription_user_type,uuid
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2021-10-01'
    and order_status in (0,1,2)
    and uuid='435157'
order by 1
;
-- 分年月看下
select s.event_date,
    sum(case when purchase_date=future_pay_date then 1 end) n_0,
    sum(case when purchase_date=future_pay_date then future_bookings end) bookings_0,
    sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then 1 end) n_366,
    sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then future_bookings end) bookings_366
from `dataintegration-265403.temp.winne_temp_sub_LTV_value` s
where duration='annual' --1month
group by 1
order by 1
;
select s.event_date,user_pseudo_id,uuid,
    sum(case when purchase_date=future_pay_date then 1 end) n_0,
    sum(case when purchase_date=future_pay_date then future_bookings end) bookings_0,
    sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then 1 end) n_366,
    sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then future_bookings end) bookings_366
from `dataintegration-265403.temp.winne_temp_sub_LTV_value` s
group by 1,2,3
having n_366>40
;






drop table if exists `dataintegration-265403.temp.winne_temp_sub_add_LTV_value`;
create table if not exists `dataintegration-265403.temp.winne_temp_sub_add_LTV_value` as

with sub_event as
(
    select event_date,user_pseudo_id,event_name,payment_price_usd
        ,max(country)country
        ,max(platform)platform
        ,max(app_version)app_version
        ,max(is_new)is_new
        ,max(is_ua)is_ua
        ,max(duration)duration
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module = 'all'
    and event_date >= '2021-10-01'
    and event_date <= '2025-09-15'
    group by 1,2,3,4
)

select event_date,country,platform,is_new,is_ua,duration
        ,sum(enter_uv) enter_uv
        ,sum(click_uv) click_uv
        ,sum(sub_success_uv) sub_success_uv
        ,sum(DAU) DAU
        ,sum(trial_uv) trial_uv
        ,sum(sub_to_paid_uv) sub_to_paid_uv
        ,sum(trial_to_paid_uv) trial_to_paid_uv
        ,sum(sub_to_paid_revenue) sub_to_paid_revenue
        ,sum(bookings_0) bookings_0
        ,sum(pay_uv_366) pay_uv_366
        ,sum(renewal_pay_uv_366) renewal_pay_uv_366
        ,sum(return_pay_uv_366) return_pay_uv_366
        ,sum(pay_pv_366) pay_pv_366
        ,sum(renewal_pay_pv_366) renewal_pay_pv_366
        ,sum(return_pay_pv_366) return_pay_pv_366
        ,sum(bookings_366) bookings_366
        ,sum(renewal_bookings_366) renewal_bookings_366
        ,sum(return_bookings_366) return_bookings_366
        ,sum(pay_uv_731) pay_uv_731
        ,sum(renewal_pay_uv_731) renewal_pay_uv_731
        ,sum(return_pay_uv_731) return_pay_uv_731
        ,sum(pay_pv_731) pay_pv_731
        ,sum(renewal_pay_pv_731) renewal_pay_pv_731
        ,sum(return_pay_pv_731) return_pay_pv_731
        ,sum(bookings_731) bookings_731
        ,sum(renewal_bookings_731) renewal_bookings_731
        ,sum(return_bookings_731) return_bookings_731
from
(
    select s1.event_date,s1.country,s1.platform,s1.is_new,
        if(s1.is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(s1.is_ua = 'Organic','Organic',null)) is_ua,
        s1.duration,
        count(distinct if(s1.event_name = 'w_subscription_enter' and s1.duration is null,s1.user_pseudo_id,null)) enter_uv,
        count(distinct if(s1.event_name = 'w_subscription_click',s1.user_pseudo_id,null)) click_uv,
        count(distinct if(s1.event_name = 'sub_suc',s1.user_pseudo_id,null)) sub_success_uv,
        count(distinct if(s1.event_name = 'DAU',s1.user_pseudo_id,null)) DAU,
        count(distinct if(s1.event_name = 'trial',s1.user_pseudo_id,null)) trial_uv,
        count(distinct if(s1.event_name = 'sub_to_paid',s1.user_pseudo_id,null)) sub_to_paid_uv,
        count(distinct if(s1.event_name = 'trial_to_paid',s1.user_pseudo_id,null)) trial_to_paid_uv,
        sum(if(s1.event_name = 'sub_to_paid',s1.payment_price_usd,0))sub_to_paid_revenue,
        0.0 bookings_0,
        0 pay_uv_366,
        0 renewal_pay_uv_366,
        0 return_pay_uv_366,
        0 pay_pv_366,
        0 renewal_pay_pv_366,
        0 return_pay_pv_366,
        0.0 bookings_366,
        0.0 renewal_bookings_366,
        0.0 return_bookings_366,
        0 pay_uv_731,
        0 renewal_pay_uv_731,
        0 return_pay_uv_731,
        0 pay_pv_731,
        0 renewal_pay_pv_731,
        0 return_pay_pv_731,
        0.0 bookings_731,
        0.0 renewal_bookings_731,
        0.0 return_bookings_731
    from sub_event s1
    group by 1,2,3,4,5,6

    union all

    select s.event_date,s.country,s.platform,s.is_new,
        if(s.is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(s.is_ua = 'Organic','Organic',null)) is_ua,
        s.duration,
        0 enter_uv,
        0 click_uv,
        0 sub_success_uv,
        0 DAU,
        0 trial_uv,
        0 sub_to_paid_uv,
        0 trial_to_paid_uv,
        0 sub_to_paid_revenue,
        sum(case when purchase_date=future_pay_date then future_bookings end) bookings_0,
        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then user_pseudo_id end) pay_uv_366,
        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then user_pseudo_id end) renewal_pay_uv_366,
        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then user_pseudo_id end) return_pay_uv_366,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then 1 end) pay_pv_366,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then 1 end) renewal_pay_pv_366,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then 1 end) return_pay_pv_366,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day) then future_bookings end) bookings_366,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then future_bookings end) renewal_bookings_366,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 366 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then future_bookings end) return_bookings_366,

        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day) then user_pseudo_id end) pay_uv_731,
        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then user_pseudo_id end) renewal_pay_uv_731,
        count(distinct case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then user_pseudo_id end) return_pay_uv_731,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day) then 1 end) pay_pv_731,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then 1 end) renewal_pay_pv_731,
        count(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then 1 end) return_pay_pv_731,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day) then future_bookings end) bookings_731,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('repeated_renewal','return_renewal') then future_bookings end) renewal_bookings_731,
        sum(case when future_pay_date between date_add(purchase_date,interval 1 day) and date_add(purchase_date,interval 731 day)
                        and future_subscription_type in ('first_time_subscription','first_time_return_subscription') then future_bookings end) return_bookings_731
    from `dataintegration-265403.temp.winne_temp_sub_LTV_value` s
    group by 1,2,3,4,5,6
)
group by 1,2,3,4,5,6

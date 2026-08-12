drop table if exists `dataintegration-265403.temp.winne_temp_enter_sub_page_event`;
create table if not exists `dataintegration-265403.temp.winne_temp_enter_sub_page_event` as

with eves_pre as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-10-31','airbrush',false)
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success')
--     and func.getParams(event_params,'source_0').string_value='sub_to_guide'
)
,user_info as
(
    select
        event_date_hk
        ,platform
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(country) country
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-10-01' and '2025-10-31'
        and app_name = 'AirBrush'
    group by 1,2,3
)
,eves as (
    select e.*,u.is_new,u.is_UA,u.country
    from eves_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_order_date
        ,lead(order_status) over(partition by original_order_id,sku order by standard_order_date) as next_order_status
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2025-10-01'
    and order_status in (0,1,2)
)


select *,null purchase_date,0.0 payment_price_usd
from eves
where event_name in ('w_subscription_enter','w_subscription_click')

union all

select e.*,
    case when  c.order_status in (1,2) then  c.standard_order_date
              when c.order_status = 0 and c.next_order_status in (1,2) then  c.next_order_date
                  end as purchase_date,
    case when  c.order_status in (1,2) then c.payment_price_usd
        when c.order_status = 0 and c.next_order_status in (1,2) then c.next_payment_price_usd
            end as payment_price_usd
from eves e
left join paid c on e.order_id = c.order_id and e.sku = c.sku
where e.event_name='w_subscription_success'
;






-- 订阅的用户当天曝光了多少次
select platform,is_new,is_UA,country
     ,case when pv>20 then 999 else pv end pv
     ,sum(uv) uv,sum(pay_uv) pay_uv,sum(pay_bookings) pay_bookings
from
(
select date,platform
  ,is_new,is_UA
  ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
  ,pv
  ,count(distinct user_pseudo_id) uv
  ,count(distinct case when purchase_date is not null then user_pseudo_id end) pay_uv
  ,round(sum(payment_price_usd),2) pay_bookings
from
(
    select a.date,a.platform,a.user_pseudo_id,a.purchase_date,a.payment_price_usd,a.is_new,a.is_UA,a.country
        ,count(1) pv
    from
    (
        select distinct date,platform,user_pseudo_id,event_timestamp,purchase_date,payment_price_usd,is_new,is_UA,country
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_success'
            and date between '2025-10-01' and '2025-10-31'
    ) a
    left join
    (
        select date,platform,user_pseudo_id,event_timestamp
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_enter'
--         group by 1,2,3,4
    ) b
    on a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and b.event_timestamp<a.event_timestamp
    and b.date=a.date
    group by 1,2,3,4,5,6,7,8
)
group by 1,2,3,4,5,6
)
group by 1,2,3,4,5
;

select platform,is_new,is_UA,country,pv,sum(uv) uv,sum(retention_uv) retention_uv
from
(
select e.event_date_hk date,e.platform
    ,e.is_new,e.is_UA
    ,case   when e.country in ('Brazil', 'United States', 'United Kingdom') then e.country
            else 'else'
            end country
    ,coalesce(a.pv,0) pv
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct b.user_pseudo_id) retention_uv
from
(
    select distinct event_date_hk,platform,user_pseudo_id,is_new,is_UA,country
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-10-01' and '2025-10-31'
        and app_name='AirBrush'
) e
left join
(
    select date,platform,user_pseudo_id,count(1) pv
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    where event_name='w_subscription_enter' and date between '2025-10-01' and '2025-10-31'
    group by 1,2,3
) a
on e.event_date_hk=a.date and e.user_pseudo_id=a.user_pseudo_id
left join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.user_pseudo_id=b.user_pseudo_id and e.event_date_hk=date_sub(b.event_date_hk,interval 1 day)
group by 1,2,3,4,5,6
)
group by 1,2,3,4,5

;

select event_date,platform
    ,func.getParams(event_params,'is_open_trial').string_value as is_open_trial
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-10-31','airbrush',false)
where
    event_name = 'w_subscription_success'
group by 1,2,3


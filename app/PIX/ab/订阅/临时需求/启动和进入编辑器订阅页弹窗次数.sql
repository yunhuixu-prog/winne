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
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-01','2025-09-30','airbrush',false)
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success')
    and func.getParams(event_params,'source_0').string_value='sub_to_guide'
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
        event_date_hk between '2025-07-01' and '2025-09-30'
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
    and standard_order_date >= '2025-07-01'
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






-- 订阅的用户当天、过去7/30天曝光了多少次
select source_module,date,platform,pv_0,pv_7,pv_30
  ,count(distinct user_pseudo_id) uv
  ,count(distinct case when purchase_date is not null then user_pseudo_id end) pay_uv
  ,round(sum(payment_price_usd),2) pay_bookings
from
(
    select a.source_module,a.date,a.platform,a.user_pseudo_id,a.purchase_date,a.payment_price_usd
        ,count(case when b.date=a.date then 1 end) pv_0
        ,count(case when b.date between date_sub(a.date,interval 6 day) and a.date then 1 end) pv_7
        ,count(case when b.date between date_sub(a.date,interval 29 day) and a.date then 1 end) pv_30
    from
    (
        select distinct date,source_module,platform,user_pseudo_id,event_timestamp,purchase_date,payment_price_usd
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_success'
            and date between '2025-07-01' and '2025-09-30'
    ) a
    left join
    (
        select date,platform,source_module,user_pseudo_id,event_timestamp
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_enter'
--         group by 1,2,3,4
    ) b
    on a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and a.source_module=b.source_module and b.event_timestamp<a.event_timestamp
    where b.date between date_sub(a.date,interval 29 day) and a.date
    group by 1,2,3,4,5,6
)
group by 1,2,3,4,5,6

union all

select 'All' source_module,date,platform,pv_0,pv_7,pv_30
  ,count(distinct user_pseudo_id) uv
  ,count(distinct case when purchase_date is not null then user_pseudo_id end) pay_uv
  ,round(sum(payment_price_usd),2) pay_bookings
from
(
    select a.date,a.platform,a.user_pseudo_id,a.purchase_date,a.payment_price_usd
        ,count(case when b.date=a.date then 1 end) pv_0
        ,count(case when b.date between date_sub(a.date,interval 6 day) and a.date then 1 end) pv_7
        ,count(case when b.date between date_sub(a.date,interval 29 day) and a.date then 1 end) pv_30
    from
    (
        select distinct date,platform,user_pseudo_id,event_timestamp,purchase_date,payment_price_usd
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_success'
            and date between '2025-07-01' and '2025-09-30'
    ) a
    left join
    (
        select distinct date,platform,user_pseudo_id,event_timestamp
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_enter'
--         group by 1,2,3,4
    ) b
    on a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and b.event_timestamp<a.event_timestamp
    where b.date between date_sub(a.date,interval 29 day) and a.date
    group by 1,2,3,4,5
)
group by 1,2,3,4,5,6
;

select date,platform
  ,case when coalesce(pv_0_homepage,0)<=5 then pv_0_homepage else 999 end pv_0_homepage
  ,case when coalesce(pv_0_edit,0)<=5 then pv_0_edit else 999 end pv_0_edit
  ,count(distinct user_pseudo_id) uv
  ,count(distinct case when purchase_date is not null then user_pseudo_id end) pay_uv
  ,round(sum(payment_price_usd),2) pay_bookings
from
(
    select a.date,a.platform,a.user_pseudo_id,a.purchase_date,a.payment_price_usd
        ,count(case when b.date=a.date and source_module='p_homepage' then 1 end) pv_0_homepage
        ,count(case when b.date=a.date and source_module='p_edit' then 1 end) pv_0_edit
    from
    (
        select distinct date,platform,user_pseudo_id,event_timestamp,purchase_date,payment_price_usd
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_success'
            and date between '2025-07-01' and '2025-09-30'
    ) a
    left join
    (
        select date,platform,source_module,user_pseudo_id,event_timestamp
        from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
        where event_name='w_subscription_enter'
--         group by 1,2,3,4
    ) b
    on a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and b.event_timestamp<a.event_timestamp
    where b.date between date_sub(a.date,interval 29 day) and a.date
    group by 1,2,3,4,5
)
group by 1,2,3,4
;




select e.source_module,e.event_date_hk date,e.platform
    ,coalesce(a.pv,0) pv
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct b.user_pseudo_id) retention_uv
from
(
    select distinct 'p_homepage' source_module,event_date_hk,platform,user_pseudo_id
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-07-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'

    union all

    select distinct 'p_edit' source_module,event_date_hk,platform,user_pseudo_id
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-07-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'
) e
left join
(
    select date,platform,source_module,user_pseudo_id,count(1) pv
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    where event_name='w_subscription_enter' and date between '2025-07-01' and '2025-09-30'
    group by 1,2,3,4
) a
on e.event_date_hk=a.date and e.user_pseudo_id=a.user_pseudo_id and e.source_module=a.source_module
left join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.user_pseudo_id=b.user_pseudo_id and e.event_date_hk=date_sub(b.event_date_hk,interval 1 day)
group by 1,2,3,4

union all

select 'All' source_module,e.event_date_hk date,e.platform
    ,coalesce(a.pv,0) pv
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct b.user_pseudo_id) retention_uv
from
(
    select distinct event_date_hk,platform,user_pseudo_id
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-07-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'
) e
left join
(
    select date,platform,user_pseudo_id,count(1) pv
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    where event_name='w_subscription_enter' and date between '2025-07-01' and '2025-09-30'
    group by 1,2,3
) a
on e.event_date_hk=a.date and e.user_pseudo_id=a.user_pseudo_id
left join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.user_pseudo_id=b.user_pseudo_id and e.event_date_hk=date_sub(b.event_date_hk,interval 1 day)
group by 1,2,3,4
;


select e.event_date_hk date,e.platform
    ,case when coalesce(pv_homepage,0)<=5 then coalesce(pv_homepage,0) else 999 end pv_homepage
    ,case when coalesce(pv_edit,0)<=5 then coalesce(pv_edit,0) else 999 end pv_edit
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct b.user_pseudo_id) retention_uv
from
(
    select distinct event_date_hk,platform,user_pseudo_id
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-07-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'
) e
left join
(
    select date,platform,user_pseudo_id
        ,count(case when source_module='p_homepage' then 1 end) pv_homepage
        ,count(case when source_module='p_edit' then 1 end) pv_edit
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    where event_name='w_subscription_enter' and date between '2025-07-01' and '2025-09-30'
    group by 1,2,3
) a
on e.event_date_hk=a.date and e.user_pseudo_id=a.user_pseudo_id
left join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.user_pseudo_id=b.user_pseudo_id and e.event_date_hk=date_sub(b.event_date_hk,interval 1 day)
group by 1,2,3,4
;



-- 60%以上用户不弹出弹窗的原因
select source_module,platform,operating_system_version,app_version,is_new
    ,sum(uv) uv,sum(enter_uv) enter_uv
from
(
select e.source_module,e.event_date_hk date,e.platform,e.operating_system_version,e.app_version,e.is_new
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct a.user_pseudo_id) enter_uv
from
(
    select distinct 'p_homepage' source_module,event_date_hk,platform,user_pseudo_id,operating_system_version,app_version,is_new
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-09-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'

    union all

    select distinct 'p_edit' source_module,event_date_hk,platform,user_pseudo_id,operating_system_version,app_version,is_new
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2025-09-01' and '2025-09-30'
        and platform='ANDROID' and app_name='AirBrush'
) e
left join
(
    select date,platform,source_module,user_pseudo_id,count(1) pv
    from `dataintegration-265403.temp.winne_temp_enter_sub_page_event`
    where event_name='w_subscription_enter' and date between '2025-09-01' and '2025-09-30'
    group by 1,2,3,4
) a
on e.event_date_hk=a.date and e.user_pseudo_id=a.user_pseudo_id and e.source_module=a.source_module
group by 1,2,3,4,5,6
)
group by 1,2,3,4,5


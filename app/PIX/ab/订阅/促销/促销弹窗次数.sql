drop table if exists `dataintegration-265403.temp.winne_temp_cuxiao_pop_sub`;
create table if not exists `dataintegration-265403.temp.winne_temp_cuxiao_pop_sub` as

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
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-10-28','2025-01-07','airbrush',false)
    where
        event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success')
        and func.getParams(event_params,'source_module').string_value='p_homepage'
        and func.getParams(event_params,'source_0').string_value='hpp'
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
        event_date_hk between '2024-10-28' and '2025-01-07'
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
    and standard_order_date >= '2024-10-28'
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


drop table if exists `dataintegration-265403.temp.winne_temp_cuxiao_pop_exp`;
create table if not exists `dataintegration-265403.temp.winne_temp_cuxiao_pop_exp` as

with pop_eves_pre as
(
    select
        date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
        ,platform,user_pseudo_id,event_name
        ,func.getUserprop(user_properties,'device_id').string_value as device_id
        ,event_timestamp
        ,func.getParams(event_params,'pop_id').string_value pop_id
        ,func.getParams(event_params,'pop_name').string_value pop_name
        ,func.getParams(event_params,'page_name').string_value page_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-10-28','2025-01-07','airbrush',false)
    where
        event_name in ('popup_show','popup_click')
        and func.getParams(event_params,'pop_id').string_value in ('AB_POP_00001517','AB_POP_00001515','AB_POP_00001509'
                                                                  ,'AB_POP_00001521','AB_POP_00001522','AB_POP_00001523','AB_POP_00001524'
                                                                  ,'AB_POP_00001526','AB_POP_00001527','AB_POP_00001529','AB_POP_00001528')
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
        event_date_hk between '2024-10-28' and '2025-01-07'
        and app_name = 'AirBrush'
    group by 1,2,3
)

select e.*,u.is_new,u.is_UA,u.country
from pop_eves_pre e
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform

;
select date,source_1,count(distinct user_pseudo_id) uv
from  `dataintegration-265403.temp.winne_temp_cuxiao_pop_sub`
where event_name='w_subscription_enter' and source_1='AB_POP_00001526'
group by 1,2
;
select date,pop_id,count(distinct user_pseudo_id) uv
from  `dataintegration-265403.temp.winne_temp_cuxiao_pop_exp`
where event_name='popup_show' and pop_id='AB_POP_00001526'
group by 1,2
;



-- 订阅的用户曝光了多少次
select pop_type,date,platform,pv,count(distinct user_pseudo_id) uv
from
(
    select a.pop_type,a.date,a.platform,a.user_pseudo_id
--         ,count(case when b.date=a.date then 1 end) pv_0
        ,count(case when b.date is not null then 1 end) pv
    from
    (
        select distinct date,source_1,platform,user_pseudo_id,event_timestamp
            ,case when source_1 in ('AB_POP_00001509') then '万圣节'
                  when source_1 in ('AB_POP_00001515','AB_POP_00001517') then '黑五'
                  when source_1 in ('AB_POP_00001521','AB_POP_00001522','AB_POP_00001523','AB_POP_00001524') then '圣诞'
                  when source_1 in ('AB_POP_00001526','AB_POP_00001527','AB_POP_00001529','AB_POP_00001528') then '新年'
            end pop_type
        from `dataintegration-265403.temp.winne_temp_cuxiao_pop_sub`
        where event_name='w_subscription_success'
    ) a
    left join
    (
        select date,platform,pop_id,user_pseudo_id,event_timestamp
            ,case when pop_id in ('AB_POP_00001509') then '万圣节'
                  when pop_id in ('AB_POP_00001515','AB_POP_00001517') then '黑五'
                  when pop_id in ('AB_POP_00001521','AB_POP_00001522','AB_POP_00001523','AB_POP_00001524') then '圣诞'
                  when pop_id in ('AB_POP_00001526','AB_POP_00001527','AB_POP_00001529','AB_POP_00001528') then '新年'
            end pop_type
        from `dataintegration-265403.temp.winne_temp_cuxiao_pop_exp`
        where event_name='popup_show'
--         group by 1,2,3,4
    ) b
    on a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id
        and a.pop_type=b.pop_type
        and b.event_timestamp<a.event_timestamp
    group by 1,2,3,4
)
group by 1,2,3,4
;





select pop_type,a.platform,pv
    ,count(distinct a.user_pseudo_id) uv
from
(
    select platform,user_pseudo_id
         ,case when pop_id in ('AB_POP_00001509') then '万圣节'
                  when pop_id in ('AB_POP_00001515','AB_POP_00001517') then '黑五'
                  when pop_id in ('AB_POP_00001521','AB_POP_00001522','AB_POP_00001523','AB_POP_00001524') then '圣诞'
                  when pop_id in ('AB_POP_00001526','AB_POP_00001527','AB_POP_00001529','AB_POP_00001528') then '新年'
          end pop_type
         ,count(1) pv
    from `dataintegration-265403.temp.winne_temp_cuxiao_pop_exp`
    where event_name='popup_show' and date between '2024-10-28' and '2025-01-07'
    group by 1,2,3
) a
group by 1,2,3

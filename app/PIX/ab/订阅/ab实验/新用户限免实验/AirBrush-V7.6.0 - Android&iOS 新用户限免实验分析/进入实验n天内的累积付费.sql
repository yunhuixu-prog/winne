with eves as (
select  
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country 
    , event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id 
   -- ,event_timestamp
    ,func.getParams(event_params,'source_module').string_value source_module 
    ,func.getParams(event_params,'source_0').string_value source_0 
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*` 
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动 
where 
    event_name= 'w_subscription_success' 
    and _table_suffix >='20250402' 
   --and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-05-08'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
)
,enter_test as (
    -- 进入实验的用户 
select 
  distinct 
    date(timestamp_micros(event_timestamp),'Asia/Singapore')  date, user_pseudo_id
    ,geo.country country
    ,platform 
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
  --  ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*` 
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test' 
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
      and _table_suffix between '20250402' and '20250509'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-05-08'
) 

 ,fe as(  select 
        a.*except(ab_code),b.ab_code
        ,b.date enter_test_date  -- 进入实验日期
    from
        eves a
         join enter_test b on a.device_id= b.device_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
 )
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` 
    where app_id ='AirBrush'
    and standard_order_date >= '2025-04-02' 
    and order_status in (0,1,2)
)

,pre as (
    -- 进入实验的用户在进入后第n 天的付费
select 
    enter_test_date 
    ,a.platform,a.ab_code
    ,date_diff(a.date,enter_test_date,day) enter_days
    -- 付费
    ,count(distinct c.device_id) sub_success_uv 
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.device_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.device_id end )  sub_success_to_paid_uv 
    ,sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd  
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd  
        else 0 end )  sub_success_to_paid_bookings


from fe a 
    left join 
    (   select 
            a.device_id,event_name,b.standard_order_date, b.original_order_id ,b.sku,b.order_status 
            ,b.payment_price_usd
            ,next_standard_order_date
            ,next_payment_price_usd
        from 
            (
            select 
            *
            from fe
            where event_name = 'w_subscription_success'
            )a 
            join paid b on a.order_id = b.order_id and a.sku = b.sku
    ) c on c.device_id = a.device_id   and c.event_name = a.event_name  and c.sku = a.sku
group by 1,2,3,4
)
, inserted_rows as (
    select 
        distinct enter_test_date 
    ,platform,ab_code,id
    from pre cross join UNNEST(GENERATE_ARRAY(0,50)) as id
)
,pref as (
select 
    coalesce( a.enter_test_date , b.enter_test_date )enter_test_date 
    ,coalesce( a.platform ,b.platform  ) platform 
    ,coalesce( a.ab_code , b.ab_code )ab_code 
    ,coalesce( enter_days,id ) enter_days 
    ,coalesce(sub_success_to_paid_uv,0) sub_success_to_paid_uv
    ,coalesce(sub_success_to_paid_bookings,0) sub_success_to_paid_bookings
from pre b  
full join inserted_rows a  on a.enter_test_date = b.enter_test_date and a.platform= b.platform and a.ab_code=b.ab_code  and cast (a.id as string) = cast(enter_days  as string)
)

select 
    enter_test_date 
    ,platform,ab_code
    ,enter_days
    ,sum(sub_success_to_paid_uv) over (partition by  enter_test_date,platform,ab_code order by enter_days ) sub_success_to_paid_uv_agg 
    ,sum(sub_success_to_paid_bookings)over (partition by  enter_test_date,platform,ab_code order by enter_days ) sub_success_to_paid_bookings_agg
from  pref
where enter_days <= 50 

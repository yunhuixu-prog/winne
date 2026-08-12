with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,case
        when event_name in ('edit_enter', 'camera_enter','video_start_edit') then 'enter'
        when event_name in ('edit_save', 'camera_save','video_save') then  'save'
        else event_name
    end event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
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
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success' )
    and _table_suffix between'20250621' and '20250817'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-06-22' and'2025-08-17'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
)
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11159','11160','11161','11162','11163','11164')
      and _table_suffix between '20250621' and '20250817'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-06-22' and'2025-08-17'
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-06-22' and '2025-08-17'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.device_id,e.platform,e.ab_code,e.enter_abtest_date
            ,row_number() over(partition by e.device_id order by event_timestamp) ranks
        from  act fa
        join
           enter_test e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code,country)
        ,c.is_new,c.country
        ,b.ab_code,b.enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
    join enter b
    on a.device_id= b.device_id
    join act c on a.user_pseudo_id= c.user_pseudo_id and a.date=c.event_date_hk
    where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期

    union all

    select distinct enter_abtest_date date
    ,b.platform,c.user_pseudo_id
    ,'enter_abtest' event_name
    ,b.device_id
    ,null event_timestamp
    ,cast(null as string) source_module
    ,cast(null as string) source_0
    ,cast(null as string) source_1
    ,cast(null as string) duration
    ,cast(null as string) sku
    ,cast(null as string) order_id
    ,null pv
    ,c.is_new,c.country
    ,b.ab_code,b.enter_abtest_date
    from enter b
    join act c on b.device_id= c.device_id and b.enter_abtest_date=c.event_date_hk
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date >= '2025-06-22'
    and order_status in (0,1,2)
)

select
--     a.date,
    a.platform
    ,case when ab_code in ('11159','11162') then '对照组'
         when ab_code in ('11160','11163') then '实验组A'
         when ab_code in ('11161','11164') then '实验组B'
        end code
    ,a.ab_code
--     ,a.enter_abtest_date
    -- 付费
    --分层
    ,a.duration
    ,a.is_new
    ,case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
    ,a.sku
    ,case when a.sku in ('airbrush.subs.1mo.2025.func00.lev00.n1','airbrush.subs.12mo.2025.func00.lev00.n1'
                    ,'airbrush.subs.1mo.2025.func00.lev00.o1','airbrush.subs.12mo.2025.func00.lev00.o1'
                    ,'airbrush_subs_1mo_2025_func00_lev00_n1','airbrush_subs_12mo_2025_func00_lev00_n1_ver1','airbrush_subs_12mo_2025_func00_lev00_n1_ver2') then 'new sku'
          when a.sku in ('airbrush.subs_1mo_2024.func00','airbrush.subs_12mo_2024.func01'
                    ,'com.meitu.airbrush.subs_1mo','com.meitu.airbrush.subs_12mo_1'
                    ,'airbrush.subs.mongth1.func00.lev00.standard.ver1','airbrush.subs.mongth12.func00.lev00.standard.ver1','airbrush.subs.mongth12.func00.lev00.standard.ver2'
                    ,'com.magicv.AirBrush.sub.allAccess.1month.newgeo10.fullPrice','airbrush.subs.month12.func00.lev00.campaign.subtest.ver1','com.magicv.AirBrush.sub.allAccess.1year.newgeo10.fullPrice') then 'old sku'
    else 'other sku' end sku_type
    ,case when source_module='p_onboarding' then source_module else 'else' end source
    ,count(distinct case when a.event_name ='enter_abtest' then a.device_id  end) enter_abtest
--     ,count(distinct case when a.event_name ='w_subscription_enter' then a.device_id  end) sub_enter_uv
    ,count(distinct case when a.event_name ='w_subscription_click' then a.device_id  end) sub_click_uv
    ,count(distinct c.device_id)  sub_success_uv
    ,count(distinct case when (a.event_name = 'w_subscription_success' and c.order_status in (1,2)) then c.device_id
                when  ( a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null ) then  c.device_id end )  sub_success_to_paid_uv
    ,round(sum(case when a.event_name = 'w_subscription_success' and c.order_status in (1,2) then c.payment_price_usd
        when  a.event_name = 'w_subscription_success' and c.order_status= 0 and c.next_standard_order_date is not null then  c.next_payment_price_usd
        else 0 end ),2)  sub_success_to_paid_gmv

    ,sum(case when a.event_name ='w_subscription_enter' then pv end) sub_enter_pv
    ,sum(case when a.event_name ='w_subscription_click' then pv  end) sub_click_pv
from fe a
    left join
    (   select
            a.device_id,a.user_pseudo_id,a.event_timestamp,event_name,b.standard_order_date, b.original_order_id ,b.sku,b.order_status
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
    ) c on c.user_pseudo_id = a.user_pseudo_id   and c.event_name = a.event_name  and c.event_timestamp = a.event_timestamp
group by 1,2,3,4,5,6,7,8,9

--    create table  `dataintegration-265403.temp.dau_type`
--    partition by event_date as
   delete from `dataintegration-265403.temp.dau_type` where event_date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 6 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
   insert into `dataintegration-265403.temp.dau_type`
   --活跃用户是否处于订阅有效期
   with dau_type as(
    select distinct app_name,event_date,user_pseudo_id,if(p.uuid is not null,'paying','un-Paying') is_paying,sub_revenue,cast(null as string) as is_consum,null as consum_revenue
    from
    ( select app_name,
        event_date_hk event_date
        ,platform
        ,user_pseudo_id
        ,uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
       event_date_hk between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 6 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and
        app_name in('AirBrush','BeautyPlus')
    group by 1,2,3,4,5
    )u left join
    (select
        app_id,uuid,standard_order_date,order_id,payment_price_usd sub_revenue
        ,case when subscription_period ='lifetime' then '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' else standard_order_expire_date end standard_order_expire_date
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where
        app_id in('AirBrush','BeautyPlus')
        and order_status in (1,2)
    group by 1,2,3,4,5,6
    )p on u.uuid = p.uuid and u.event_date >= p.standard_order_date  and u.event_date <= p.standard_order_expire_date
    and u.app_name=p.app_id

union all
--活跃用户是否单购
    select distinct app_name,event_date,user_pseudo_id, cast(null as string) is_paying,null as sub_revenue,if(p.uuid is not null,'consumables','un-consumable') is_consum, consum_revenue
    from
    ( select app_name,
        event_date_hk event_date
        ,platform
        ,user_pseudo_id
        ,uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 6 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and
        app_name in('AirBrush','BeautyPlus')
    group by 1,2,3,4,5
    )u left join
    (select
        app_id,uuid,standard_order_date,order_id,payment_price_usd consum_revenue
  from `dataintegration-265403.purchase.dwd_da_purchase_daily`
    where
        app_id in('AirBrush','BeautyPlus')
        and order_status in (1,2)
        and standard_order_date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 6 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2,3,4,5
    )p on u.uuid = p.uuid
    and u.event_date=p.standard_order_date
    and u.app_name=p.app_id
   )

   select r.*,COALESCE(r.sub_revenue, 0) + COALESCE(r.consum_revenue, 0) as revenue
   from(
    select app_name,event_date,user_pseudo_id, max(is_paying) is_paying,max(sub_revenue) sub_revenue,max(is_consum) is_consum,max(consum_revenue) consum_revenue
    from dau_type
    group by 1,2,3)r


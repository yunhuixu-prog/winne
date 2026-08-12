-- create table `dataintegration-265403.user_ltv.ltv_renewal_predict_first_order`  as
-- 该表需要全量刷新，因为需要计算 LTV ，终身付费
DECLARE start INT64 DEFAULT 0;
delete from `dataintegration-265403.temp.ltv_renewal_predict_first_order`
where
 date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+90 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day ) ;
insert into`dataintegration-265403.temp.ltv_renewal_predict_first_order`

drop table if exists `dataintegration-265403.temp.ltv_renewal_predict_first_order`;
create table `dataintegration-265403.temp.ltv_renewal_predict_first_order` as

with subscription as (
     select
        a.*except(country),fix_firebase_en_name country
     from
     (
        select
            *
        from
            `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` --10/17 改为temp
        where
           standard_order_date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+90 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
     )a
     left join (select distinct key, fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.country = b.key

)
,first_paid as (
    select
         distinct
        app_id,country,platform,is_UA
        ,subscription_period -- ,sku
        ,subscription_user_type,order_id,sku -- 订单
        ,original_order_id ,uuid  -- 用户id
        ,payment_price_usd -- 金额
        ,standard_order_date,standard_order_expire_date
        ,date_add(standard_order_date,interval 365 day) standard_365_date
        ,case
            when subscription_period = '1-month' then date_diff('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',standard_order_date,day)/30.458  --365.5/12
            when subscription_period = '3-month' then date_diff('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',standard_order_date,day)/91.375 --365.5/4
            when subscription_period = '1-week' then  date_diff('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',standard_order_date,day)/7 --一周7天
            else 0 -- 其他的sku不需要 续订率
        end start_period -- 计算 LTV365 用 ，需+1
        ,case
            when subscription_period = '1-month' then 11
            when subscription_period = '3-month' then 3
            when subscription_period = '1-week' then 51
            else 0  -- 其他的sku不需要 续订率
        end end_period  -- 计算 LTV365 用，
    from
        subscription
    where
        subscription_user_type in ('first_time_subscription','first_time_return_subscription')
)
,renewal as (
    -- 续费
    select
        distinct
        app_id,country,platform,is_UA
        ,subscription_period -- ,sku
        ,case
            when subscription_user_type = 'repeated_renewal' then 'first_time_subscription'
            when subscription_user_type = 'return_renewal' then 'first_time_return_subscription'
        end subscription_type   -- 用来跟first paid 进行连接
        ,original_order_id,order_id,sku ,uuid  -- 用户id
        ,payment_price_usd -- 金额
        ,standard_order_date
    from
        subscription
    where
        order_status in (1,2)
        and  subscription_user_type in ('repeated_renewal','return_renewal')
)
,real_paid as (
        select
                f.standard_order_date date
                ,f.app_id,f.country,f.platform,f.is_UA
                ,f.subscription_period
                ,f.subscription_user_type
                ,f.original_order_id,f.uuid,f.order_id
                ,sum(coalesce(l.payment_price_usd,0)) LTV_real_renewal   -- 计算 LTV 用的真实续费金额  LTV_real_Rn
                ,sum(case when l.standard_order_date <= standard_365_date and l.payment_price_usd is not null  then l.payment_price_usd else 0 end  ) LTV365_real_renewal    -- 计算LTV365  用的真实续费金额LTV365_real_Rn
        from
                first_paid  f
            left join
                    renewal l on f.app_id = l.app_id and coalesce(f.country,'-')= coalesce(l.country,'-') and f.platform = l.platform and f.is_UA = l.is_UA
                                    and f.subscription_period = l.subscription_period and f.subscription_user_type =  l.subscription_type
                              and f.original_order_id = l.original_order_id and  coalesce(f.uuid,'-') =  coalesce(l.uuid,'-')  -- 不连order id  是需要计算续费
                              and f.sku = l.sku
        where f.standard_order_date < l.standard_order_date -- 续费应该大于首次付费
        group by 1,2,3,4,5,6,7,8,9,10
)
,forecast_re as (
    select * from  `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
    where date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+90 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
)
,agg_re as (
        select
            a.date,a.app_id,a.country,a.platform,a.is_UA
            ,a.subscription_period,a.subscription_user_type
           ,LT,max_LT
            ,original_order_id ,order_id,uuid
            ,payment_price_usd
            ,sum(case when a.period between 1 and end_period then  period_rate else 0 end) LTV365_agg_re --计算LT365 需要的累计续订率 ，全部为预测
            ,sum(case when (a.period between trunc(start_period)+1 and end_period )and  start_period < end_period then period_rate else 0 end) LTV365_agg_rep -- LTV365 需要去预测的部分的累计续订率，开始时间点的不同，是LTV365_agg_re  的一部分
            --  start_period < end_period -- 如果开始的period 大于等于 end_period ，其实一年已经过完了，无需再使用预测值

           -- ,sum(case when a.period between 1 and trunc(LT) then  period_rate else 0 end) LTV_agg_re --计算 LT 需要的累计续订率，全部为预测
            , sum(case when (a.period between trunc(start_period)+1 and trunc(max_LT)) and  start_period < trunc(max_LT) then period_rate else 0 end)  LTV_agg_rep -- LTV 需要去预测的部分的累计续订率，开始时间点的不同，是LTV_agg_re  的一部分


        from
        (
        select
        -- 去重是因为必然导致重复
         distinct    a.date,a.app_id,a.country,a.platform,a.is_UA,a.subscription_period,a.subscription_user_type
            ,start_period,end_period
             , original_order_id ,order_id,uuid
             ,payment_price_usd
            ,coalesce(b.period,c.period,f.period) period
            ,coalesce(b.period_rate,c.period_rate,f.period_rate) period_rate
            ,coalesce(b.LT,c.LT,f.LT) LT
                ,coalesce(b.max_LT,c.max_LT,f.max_LT) max_LT
            --,coalesce(b.max_period,c.max_period,f.max_period) max_period
        from
            (select
               distinct standard_order_date date
                ,app_id,country,platform,is_UA
                ,subscription_period,subscription_user_type
                ,start_period,end_period  -- 分期来看收入和人数
                ,original_order_id ,order_id,uuid
                ,payment_price_usd
            from
                first_paid

            ) a
            left join forecast_re b on  a.app_id = b.app_id and coalesce(a.country,'-')= coalesce(b.country,'-') and a.platform = b.platform and a.is_UA = b.is_UA
                                    and a.subscription_period = b.subscription_period
                                    and a.subscription_user_type = b.subscription_user_type
                                    and a.date = b.date
            left join  (
                -- 剔除国家的影响
                select *
                from forecast_re
                where country = 'others'
            )c  on a.app_id = c.app_id and  a.platform = c.platform and a.is_UA = c.is_UA
                                    and a.subscription_period = c.subscription_period
                                    and a.subscription_user_type = c.subscription_user_type
                                    and a.date = c.date
           left join
            (
                -- 剔除国家、platform isua 的影响
                select *
                from forecast_re
                where
                    country = 'all'
                    and platform ='all'
                    and is_UA =   'all'
            )f   on a.app_id = f.app_id  and a.subscription_period = f.subscription_period
                                    and a.subscription_user_type = f.subscription_user_type
                                    and a.date = f.date


        )a
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13

)

select
    a.date,a.app_id,a.country,a.platform,a.is_UA
    ,a.subscription_period,a.subscription_user_type
    ,a.original_order_id ,a.order_id,a.uuid
    ,payment_price_usd
    ,LT
    ,LTV365_agg_re -- LT365 需要的累计续订率 ，全部为预测
    ,LTV365_agg_rep -- LTV365 需要去预测的部分的累计续订率，
    ,coalesce(LTV365_real_renewal ,0) LTV365_real_renewal  -- 计算LTV365  用的真实续费金额LTV365_real_Rn
    , payment_price_usd*(1+LTV365_agg_re)   LTV365_pure_forecast    --纯预测的 LTV365
    , payment_price_usd*(1+LTV365_agg_rep)+coalesce(LTV365_real_renewal ,0)  LTV365_actual_forecast   -- 有实际付费+预测LTV 365

    ,case when coalesce(LT)-1<0 then 0 else coalesce(LT)-1 end LTV_agg_re --计算 LT 需要的累计续订率，全部为预测
    ,LTV_agg_rep -- LTV 需要去预测的部分的累计续订率
    ,coalesce(LTV_real_renewal,0) LTV_real_renewal   -- 计算 LTV 用的真实续费金额  LTV_real_Rn
    ,payment_price_usd*coalesce(LT,0)  LTV_pure_forecast    -- 纯预测的 LTV
    , payment_price_usd*(1+LTV_agg_rep)+coalesce(LTV_real_renewal,0)   LTV_actual_forecast   -- 有实际付费+预测LTV
     ,max_LT



from
    agg_re a
    left join real_paid b on a.date = b.date and  a.app_id = b.app_id and coalesce(a.country,'-')= coalesce(b.country,'-') and a.platform = b.platform and a.is_UA = b.is_UA
                            and a.subscription_period = b.subscription_period and a.subscription_user_type = b.subscription_user_type
                            and a.original_order_id = b.original_order_id and  coalesce(a.uuid,'-') =  coalesce(b.uuid,'-') and a.order_id = b.order_id


-- 预测函数 生成续订率

 -- create table `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`  as
DECLARE start INT64 DEFAULT 0;
delete from `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
where
    date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day ) ;

insert into `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
with forecast_type as (

    -- 给每个留存率函数，生成生命周期内的续订期数行
    -- 比如 3 month ,一年内有R3,生成3行
        select
           distinct date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,period
        from
        (
        select
            distinct  cast(date as date) date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
            ,1 start_period
           /* ,case
                when subscription_period = '1-week' then 51
                when subscription_period = '1-month' then 11
                when subscription_period = '3-month' then 3
               else 1 -- 如果不写的话，forecast_retention  里面将没有 1- year 的sku
            end end_period*/
            ,max_LT
            ,trunc(max_LT) max_period -- 取整
        from
             `dataintegration-265403.user_ltv.dws_forecast_new_retention_function_daily`
        where
          cast(date as date) between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
          and max_LT < 1000 -- 限制LT无限大的情况
        )t,unnest(generate_array(start_period,max_period)) as period

    )
    ,LT as (
            select
              distinct cast(date as date)  date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
              ,popt_a,popt_b,max_LT
            from
                 `dataintegration-265403.user_ltv.dws_forecast_new_retention_function_daily`
            where
            cast(date as date) between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
              )
    ,rate as (
      -- 计算预测的续订率
        select *
        from
        (
            select
                p.*
                ,popt_a*ln(p.period)+popt_b period_rate
                ,max_LT
            from LT f
                left join forecast_type p  on
                    p.date =f.date and p.app_id = f.app_id and p.country = f.country and p.platform=f.platform and p.is_UA = f.is_UA
                    and p.subscription_user_type = f.subscription_user_type and p.subscription_period = f.subscription_period
        )t
        where period_rate >=0
    )

     select
            p.date,p.app_id,p.country,p.platform,p.is_UA,p.subscription_user_type
            ,p.subscription_period,period,period_rate
            ,agg_re+1 LT -- 平均生命周期
            ,max_LT -- 平均最长生命周期
        from
            rate p
        left join
        (
            select
                date,app_id,country,platform,is_UA,subscription_user_type
                ,subscription_period
                ,sum(case when period between 1 and trunc(max_LT) then period_rate else 0 end ) agg_re -- 最长生命周期内的累计续订率
            from rate
                group by 1,2,3,4,5,6,7
        ) f on  p.date =f.date and p.app_id = f.app_id and p.country = f.country and p.platform=f.platform and p.is_UA = f.is_UA
                    and p.subscription_user_type = f.subscription_user_type and p.subscription_period = f.subscription_period



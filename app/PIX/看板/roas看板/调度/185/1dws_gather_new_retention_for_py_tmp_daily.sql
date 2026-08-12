DECLARE start INT64 DEFAULT 0;
/*
create  or replace table  `dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`
as */
-- to do 3 py 预测对数函数
-- 在这之前删除下py 将要计算得到的预测模型
-- py 每次都算t-12~t-1,过去1年的数据，因此也删除掉过去半年的数据


delete  from  `dataintegration-265403.user_ltv.dws_forecast_new_retention_function_daily`
where
 date between cast(date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day ) as string )and cast (date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day) as string);

delete  from   `dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`
where
  1=1;
insert into `dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`

with re as (
    -- 去掉只有一期的预测数据
   select *
  from  `dataintegration-265403.user_ltv.dws_gather_new_retention_daily`
 /*   select
        a.*
    from
    (
    select
        *
    from
    `dataintegration-265403.user_ltv.dws_gather_new_retention_daily`

    )a
    join
    (
    select
        date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,count(distinct period) n
    from
         `dataintegration-265403.user_ltv.dws_gather_new_retention_daily`
    group by date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
    having n> 1
    )b on a.date = b.date and a.app_id= b.app_id and coalesce(a.country,'-')=coalesce(b.country,'-') and a.platform = b.platform
    and a.is_UA =  b.is_UA and a.subscription_user_type =b.subscription_user_type and a.subscription_period = b.subscription_period
*/
)

  ,pre as(      select
              date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,period ,period_0,period_num,period_rate
        from
            re
        where
           date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day ) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
          -- 使用
           and date >= '2020-08-15'
            and period_0 is not null


       --日期在2020-08-01～2021-11-30之间的数据，由于没有这么多的数据量，因此直接使用全集

        union all

        select
            date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,period ,period_0,period_num,period_rate
        from
            re
        where
            date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day ) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
            and date between  '2020-08-03' and '2020-08-15'

            and period_0 is not null
            and country = 'all'
            and platform ='all'
            and is_UA = 'all'
        union all

        select
            date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,period
            ,avg(period_0)period_0
            ,avg(period_num) period_num
            ,avg(period_rate) period_rate
        from
           re
        where
            date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day ) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
            and date between  '2020-08-01' and '2020-08-02'

            and period_0 is not null
            and country = 'all'
            and platform ='all'
            and is_UA ='all'
        group by 1,2,3,4,5,6,7,8

  )

   select
        a.*
    from
    (
    select
        *
    from
   pre

    )a
    join
    (
    select
        date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,count(distinct period) n
    from
        pre
    group by date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
    having n> 1
    )b on a.date = b.date and a.app_id= b.app_id and coalesce(a.country,'-')=coalesce(b.country,'-') and a.platform = b.platform
    and a.is_UA =  b.is_UA and a.subscription_user_type =b.subscription_user_type and a.subscription_period = b.subscription_period

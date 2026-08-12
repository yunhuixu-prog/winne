--  Airflow 里面设置的时候，执行天数0 ' 注意 本表替换日期应该为 '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
DECLARE start INT64 DEFAULT 0;
--create or replace table  `dataintegration-265403.user_ltv.dws_gather_new_retention_daily` as
-- 删除本次生成的表
delete  from   `dataintegration-265403.user_ltv.dws_gather_new_retention_daily`
where
    date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+60 day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day) ;

WHILE start <=60 DO

    insert into `dataintegration-265403.user_ltv.dws_gather_new_retention_daily`
    with retention_rate as (
        select
          app_id,platform,is_ua,first_day, subscription_period,subscription_user_type
          ,period_0,period_1,period_2,period_3,period_4,period_5,period_6,period_7,period_8,period_9,period_10,period_11,period_12
          ,period_13,period_14,period_15,period_16,period_17,period_18,period_19,period_20,period_21,period_22,period_23,period_24
          ,vcus_retention.period_25 ,vcus_retention.period_26, vcus_retention.period_27, vcus_retention.period_28
  , vcus_retention.period_29 ,vcus_retention.period_30, vcus_retention.period_31,vcus_retention.period_32,vcus_retention.period_33
 ,vcus_retention.period_34,vcus_retention.period_35,vcus_retention.period_36,vcus_retention.period_37
 ,vcus_retention.period_38,vcus_retention.period_39,vcus_retention.period_40,vcus_retention.period_41
 ,vcus_retention.period_42,vcus_retention.period_43,vcus_retention.period_44,vcus_retention.period_45,vcus_retention.period_46
 ,vcus_retention.period_47,vcus_retention.period_48,vcus_retention.period_49,vcus_retention.period_50
 ,vcus_retention.period_51,vcus_retention.period_52
 ,fix_firebase_en_name country
        from
        (
            select * from `dataintegration-265403.subscription.ads_subscription_retention_rate_report`
    )a left join (select distinct key, fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.country = b.key

    )
    ,top_country as (
    -- 重点国家的选择
    -- t-6～t-1，过去半年的来选择
        with a as (
        select
            app_id
            ,country
            ,platform
            ,is_UA
            ,subscription_user_type
            ,subscription_period
            ,first_paid_uv
            ,row_number() over(partition by app_id,platform,is_UA,subscription_user_type,subscription_period order by first_paid_uv desc) row_n
        from
        (
        select
            app_id
            ,country
            ,platform
            ,is_UA
            ,subscription_user_type
            ,subscription_period
            ,sum(period_0) first_paid_uv
        from
            retention_rate
        where
            first_day between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+153 day ) and   date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day )
            -- 30*5+3 假设最大有3个月是31天
           -- date_trunc(first_day,month) between date_sub(date_trunc(current_date,month),interval start+5 month ) and date_sub(date_trunc(current_date,month),interval start month )
            and subscription_period not in ('lifetime','inapp')
           -- and app_id in ('VCUS', 'BeautyPlus', 'AirBrush','AirVid')
            group by 1,2,3,4,5,6
        )t
        )

    select
        distinct
        app_id,platform,is_UA,subscription_user_type,subscription_period,country
    from a
    where
    --  订阅 uv >=200 且订阅 uv 排名<= 15 的国家
        row_n <=15 and first_paid_uv >=200

    -- 未来若有别的产品，需要判断 first_paid_uv 应该为几才能是重点国家
    )
    ,col_to_row as (

    -- 将一期为一列的多列续订用户数，转化为2列，一列位期数，一列卫续订用户数
            select
                app_id
                ,country
                ,platform
                ,is_UA
                ,subscription_user_type
                ,subscription_period
                ,cast(split(period,'_')[safe_offset(1)] as int64)  period
                ,first_day,period_num
            from
            (
            select
                a.* except(country)
                ,case when t.country is null then 'others' else t.country end country

            from
            (
                -- 1month & 1week 用过去半年的数据预测
            select
                *
            from  retention_rate
            where
                first_day between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+183 day ) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+28 day )
                --最低是2月有27天，30*6+3
                -- 日前选择的逻辑，可看到最近距离 date_sub(date_trunc(current_date,month),interval start month)的一次R1
                and subscription_period in ('1-month','1-week')

            union all
            -- 3month 使用过去 [T0-3个Q , T0-1个Q] 的续订率
            select
                *
            from retention_rate
            where
                -- 9*30+4 274；28+30*2 88
                first_day between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+274 day ) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start+88 day )
                and subscription_period = '3-month'
               --  and app_id in ('VCUS', 'BeautyPlus', 'AirBrush','AirVid')


           /* union all
            -- 分天来看的不需要 年的预测，缺失值太多

           -- 1 year 使用过去 [T0-3年 , T0-1年]的续订率
                select
                * except(vcus_retention) ,vcus_retention.*
            from  retention_rate
            where
                -- 366*2 ；最低 365
                first_day between date_sub(current_date,interval start+732 day) and date_sub(current_date,interval start+365 day )
                and subscription_period = '1-year'*/

            )a left join
            -- 限制top 国家
            top_country t on  a.app_id=t.app_id and a.platform = t.platform and a.is_UA=t.is_UA and
                    a.subscription_user_type =t.subscription_user_type and  a.subscription_period =t.subscription_period
                    and a.country = t.country
            )a
            unpivot
            (
                period_num for period in
                (
                    period_0,period_1,period_2,period_3,period_4,period_5,period_6,period_7,period_8,period_9
                    ,period_10,period_11,period_12,period_13,period_14,period_15,period_16,period_17,period_18,period_19
                    ,period_20,period_21,period_22,period_23,period_24,period_25,period_26,period_27,period_28,period_29
                    ,period_30,period_31,period_32,period_33,period_34,period_35,period_36,period_37,period_38,period_39
                    ,period_40,period_41,period_42,period_43,period_44,period_45,period_46,period_47,period_48,period_49
                    ,period_50,period_51,period_52
                )
            )
            -- 限制每个sku 预测都用相同的Rn
              where
              (subscription_period = '1-week' and cast(split(period,'_')[safe_offset(1)] as int64)<= 26 )
                or ( subscription_period ='1-month'and cast(split(period,'_')[safe_offset(1)] as int64) <= 6)
                or ( subscription_period ='3-month' and cast(split(period,'_')[safe_offset(1)] as int64)<= 3)
                or(subscription_period ='1-year' and  cast(split(period,'_')[safe_offset(1)] as int64)<= 2)

    )
    ,gather as (
    /*
    剔除掉不满订阅期的续订值，比如对于21年-9月的留存，有R1 但是R2 还不满期限
    转化成 app_id,platform,is_UA,subscription_user_type,subscription_period,country（分重点国家和 Other ） 维度的数据，每个月分别一行
    */

    select
        -- 每天的真实续订率值
        first_day first_date
        --date_trunc(first_day,month) first_date
         -- 按每月计算首次订阅用户数和续订用户数，如果使用累计值，会导致越大的Rn 越小
        ,app_id
        ,country
        ,platform
        ,is_UA
        ,subscription_user_type
        ,subscription_period
        ,period
        ,sum(coalesce(period_num,0)) period_num
    from
    (
    select
            app_id
                ,country
                ,platform
                ,is_UA
                ,subscription_user_type
                ,subscription_period
                , period
                ,period_num
                ,first_day
                ,case
                    when subscription_period = '1-week' then date_add(first_day,interval  period week)
                    when subscription_period = '1-month' then  date_add(first_day,interval  period month)
                    when subscription_period = '3-month' then  date_add(first_day,interval  period quarter)
                    when subscription_period = '1-year' then  date_add(first_day,interval  period year)
                end first_date_add_period
    from col_to_row
    )t
    where
       first_date_add_period < date_trunc(current_date,month)  -- 限制小于14天不行，还是有脏数据，还是需要限制一个月
         -- first_date_add_period <=   date_sub(current_date,interval 14 day)
         --first_day 日期+ n 个续订期，如果小于等于今天，说明是满续订期的续订值，若否则剔除掉不满订阅期的续订值
         -- 订阅宽限期一般是14天

    group by 1,2,3,4,5,6,7,8

    )

        -- 组合成 peirod,period_num,peirod_rate 的形式
    select
        date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start day ) date -- 以下续订率均作为date 的日期来预测模型
        ,a.app_id
        ,a.country
        ,a.platform
        ,a.is_UA
        ,a.subscription_user_type
        ,a.subscription_period
      --  ,a.first_date  -- 每个月的续订情况如下
        ,a.period
        ,avg(b.period_num) period_0
        ,avg(a.period_num) period_num
        ,avg(a.period_num/b.period_num)  period_rate -- 续订率
    from
    (
        -- 汇总以及平均 用来预估的一段时期内数据
    select
        first_date,app_id,country ,platform,is_UA,subscription_user_type,subscription_period, period
      --  ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
        ,sum(coalesce(period_num,0))period_num  -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7,8

    union all

    -- 计算一个仅分app_id
    select
        first_date,app_id,'all'country ,'all' platform,'all' is_UA,subscription_user_type,subscription_period, period
      --  ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
         ,sum(coalesce(period_num,0))period_num  -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7,8


    union all
    -- 计算一个仅分app_id和 Platform 的
      select
        first_date,app_id,'all'country ,platform,'all' is_UA,subscription_user_type,subscription_period, period
       -- ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
         ,sum(coalesce(period_num,0))period_num  -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7,8

    union all
    -- 计算一个仅分app_id，is_UA
    select
       first_date, app_id,'all'country ,'all' platform,is_UA,subscription_user_type,subscription_period, period
       -- ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
        , sum(coalesce(period_num,0))period_num  -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7 ,8

   /* union all
    -- 计算一个仅分app_id,subscription_user_type
    select
        app_id,'all'country ,'all' platform,'all'is_UA,subscription_user_type,subscription_period, period
        ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
        ,avg(coalesce(period_num,0)) period_num  -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7 */

     union all
    -- 计算一个仅分app_id,country
    select
       first_date, app_id,country ,'all' platform,'all'is_UA,subscription_user_type,subscription_period, period
       --,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
        ,sum(coalesce(period_num,0)) period_num   -- 计算的
    from
        gather
    where period <> 0
    group by 1,2,3,4,5,6,7 ,8

    )a
    left join
    (

    select
         first_date,  app_id,country ,platform,is_UA,subscription_user_type,subscription_period, period
       -- ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
       ,sum(coalesce(period_num,0))period_num

    from
        gather
    where period = 0
      group by 1,2,3,4,5,6,7 ,8

     union all

    -- 计算一个仅分app_id
    select
        first_date,  app_id,'all'country ,'all' platform,'all' is_UA,subscription_user_type,subscription_period, period
        --,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
            ,sum(coalesce(period_num,0))period_num
    from
        gather
    where period = 0
    group by 1,2,3,4,5,6,7,8


    union all
    -- 计算一个仅分app_id和 Platform 的
      select
         first_date, app_id,'all'country ,platform,'all' is_UA,subscription_user_type,subscription_period, period
       -- ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
             ,sum(coalesce(period_num,0))period_num
    from
        gather
    where period  = 0
    group by 1,2,3,4,5,6,7,8

    union all
    -- 计算一个仅分app_id，is_UA
    select
         first_date, app_id,'all'country ,'all' platform,is_UA,subscription_user_type,subscription_period, period
       -- ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
           ,sum(coalesce(period_num,0))period_num
    from
        gather
    where period  = 0
    group by 1,2,3,4,5,6,7 ,8

    /* union all
    -- 计算一个仅分app_id,subscription_user_type
    select
        app_id,'all'country ,'all' platform,'all'is_UA,subscription_user_type,subscription_period, period
        ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
        ,avg(coalesce(period_num,0)) period_num  -- 计算的
    from
        gather
    where period  = 0
    group by 1,2,3,4,5,6,7 */

     union all
    -- 计算一个仅分app_id,country
    select
         first_date, app_id,country ,'all' platform,'all'is_UA,subscription_user_type,subscription_period, period
      --  ,sum(coalesce(period_num,0)) agg_period_num -- 计算的用来预估时期内的累计值，如 1-month 就是6个月的累计值
            ,sum(coalesce(period_num,0))period_num
    from
        gather
    where period  = 0
    group by 1,2,3,4,5,6,7,8

    )b on a.app_id = b.app_id and a.country =b.country and a.platform = b.platform and a.is_UA =b.is_UA
            and a.subscription_user_type=b.subscription_user_type and a.subscription_period =b.subscription_period
            and a.first_date = b.first_date
        /*

  where
    a.app_id ='AirBrush'
    and a.country= 'United States (the)'
    and a.platform	 ='all'
    and a.is_UA ='all'
    and a.subscription_period = '1-month'
    */
    group by 1,2,3,4,5,6,7,8


    ;
    set start = start + 1;
end while;

DECLARE OBSERVE_DATE_START DATE DEFAULT '2023-01-01';
DECLARE OBSERVE_DATE_END DATE DEFAULT '2023-01-31';

DECLARE OBSERVE_DATE DATE DEFAULT OBSERVE_DATE_start;

WHILE OBSERVE_DATE >= OBSERVE_DATE_START AND OBSERVE_DATE <= OBSERVE_DATE_END DO

delete from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv where date = OBSERVE_DATE;
insert into dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv


-- DECLARE OBSERVE_DATE DATE DEFAULT '2023-01-01';
-- drop table if exists `dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv`;
-- create table `dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv` as


with
first_paid as (
    select
         distinct
        app_id,fix_firebase_en_name country,platform,is_UA
        ,subscription_period -- ,sku
        ,subscription_user_type,order_id,sku -- 订单
        ,original_order_id ,uuid  -- 用户id
        ,payment_price_usd -- 金额
        ,standard_order_date,standard_order_expire_date
        ,date_add(standard_order_date,interval 365 day) standard_365_date
        ,case
            when subscription_period = '1-year' then  cast(trunc(date_diff(OBSERVE_DATE,standard_order_date,day)/365.5) as int64)
            when subscription_period = '1-month' then cast(trunc(date_diff(OBSERVE_DATE,standard_order_date,day)/30.458) as int64)  --365.5/12
            when subscription_period = '3-month' then cast(trunc(date_diff(OBSERVE_DATE,standard_order_date,day)/91.375) as int64) --365.5/4
            when subscription_period = '6-month' then cast(trunc(date_diff(OBSERVE_DATE, standard_order_date, day)/182.75) as int64) --365.5/2
            when subscription_period = '1-week' then  cast(trunc(date_diff(OBSERVE_DATE,standard_order_date,day)/7) as int64)
            else 0
        end observe_period
    from
        `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
    left join (select distinct key, fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.country = b.key
    where
        subscription_user_type in ('first_time_subscription','first_time_return_subscription')
        and standard_order_date between '2021-01-01' and OBSERVE_DATE
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
        ,original_order_id,a.order_id,sku ,uuid  -- 用户id
        ,payment_price_usd -- 金额
        ,standard_order_date
        ,first_order_day
    from
        `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
    left join (select order_id,first_order_day from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv`) c on a.order_id = c.order_id
    where
        order_status in (1,2)
        and  subscription_user_type in ('repeated_renewal','return_renewal')
        and standard_order_date >= '2021-01-01'
)
,real_paid as
(
    select
            f.standard_order_date
            ,f.app_id,f.country,f.platform,f.is_UA
            ,f.subscription_period
            ,f.subscription_user_type
            ,f.original_order_id,f.uuid,f.order_id
            ,count(distinct l.order_id) LT_real_renewal
            ,count(distinct case when l.standard_order_date <= OBSERVE_DATE then l.order_id end) by_observe_LT_real_renewal
            ,count(distinct case when l.standard_order_date > OBSERVE_DATE then l.order_id end) observe_to_now_LT_real_renewal
            ,sum(coalesce(l.payment_price_usd,0)) LTV_real_renewal
            ,sum(case when l.standard_order_date <= OBSERVE_DATE then l.payment_price_usd end) by_observe_LTV_real_renewal
            ,sum(case when l.standard_order_date > OBSERVE_DATE then l.payment_price_usd end) observe_to_now_LTV_real_renewal
    from
            first_paid f
    left join renewal l
    on f.app_id = l.app_id --and coalesce(f.country,'-')= coalesce(l.country,'-') and f.platform = l.platform and f.is_UA = l.is_UA
            and f.subscription_period = l.subscription_period --and f.subscription_user_type =  l.subscription_type
            and f.original_order_id = l.original_order_id and coalesce(f.uuid,'-') =  coalesce(l.uuid,'-')
            and f.sku = l.sku
    where f.standard_order_date < l.standard_order_date -- 选取之后的续费订单
    group by 1,2,3,4,5,6,7,8,9,10
)
,order_real_paid as
(
    select
            f.standard_order_date
            ,f.app_id,f.country,f.platform,f.is_UA
            ,f.subscription_period
            ,f.subscription_user_type
            ,f.original_order_id,f.uuid,f.order_id
            ,count(distinct l.order_id) LT_real_renewal
            ,count(distinct case when l.standard_order_date <= OBSERVE_DATE then l.order_id end) by_observe_LT_real_renewal
            ,count(distinct case when l.standard_order_date > OBSERVE_DATE then l.order_id end) observe_to_now_LT_real_renewal
            ,sum(coalesce(l.payment_price_usd,0)) LTV_real_renewal
            ,sum(case when l.standard_order_date <= OBSERVE_DATE then l.payment_price_usd end) by_observe_LTV_real_renewal
            ,sum(case when l.standard_order_date > OBSERVE_DATE then l.payment_price_usd end) observe_to_now_LTV_real_renewal
    from
            first_paid f
    left join renewal l
    on f.app_id = l.app_id --and coalesce(f.country,'-')= coalesce(l.country,'-') and f.platform = l.platform and f.is_UA = l.is_UA
            and f.subscription_period = l.subscription_period --and f.subscription_user_type =  l.subscription_type
            and f.original_order_id = l.original_order_id and coalesce(f.uuid,'-') =  coalesce(l.uuid,'-')
            and f.sku = l.sku
            and f.standard_order_date = l.first_order_day
    where f.standard_order_date < l.standard_order_date -- 选取之后的续费订单
    group by 1,2,3,4,5,6,7,8,9,10
)
,observe_order as
(
    select original_order_id,first_order_day
        ,standard_order_date,app_id,country,platform,is_UA,subscription_period,subscription_user_type
        ,order_id,uuid,by_period
        ,LT_real_renewal,LTV_real_renewal,predict1_LT,predict2_LT
    from
    (
        select *
            ,row_number() over (partition by original_order_id,first_order_day order by standard_order_date desc) ranks
        from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv`
        where standard_order_date between '2021-01-01' and OBSERVE_DATE
    )
    where ranks=1
)
,forecast_re as (
    select * from  `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
    where date between '2021-01-01' and OBSERVE_DATE
)
,agg_re as (
        select
            a.date standard_order_date,a.app_id,a.country,a.platform,a.is_UA
            ,a.subscription_period,a.subscription_user_type
            ,observe_period,LT
            ,original_order_id ,order_id,uuid
            ,payment_price_usd
            , sum(case when (a.period between observe_period+1 and trunc(max_LT)) and  observe_period < trunc(max_LT) then period_rate else 0 end)  LT_agg_rep -- LTV 需要去预测的部分的累计续订率，开始时间点的不同，是LT_agg_re  的一部分
            , sum(case when (a.period between observe_period+1 and trunc(max_LT)) and  observe_period < trunc(max_LT) then period_rate else 0 end)
                    /if(sum(case when a.period=observe_period then period_rate else 0 end)=0,1,sum(case when a.period=observe_period then period_rate else 0 end)) LT_agg_rep_c -- LTV 需要去预测的部分的累计续订率，开始时间点的不同，是LT_agg_re  的一部分

        from
        (
        select
        -- 去重是因为必然导致重复
         distinct    a.date,a.app_id,a.country,a.platform,a.is_UA,a.subscription_period,a.subscription_user_type
            ,observe_period
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
                ,observe_period
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

select OBSERVE_DATE date --观测日期
    ,a.standard_order_date original_order_day,a.app_id,a.country,a.platform,a.is_UA
    ,a.subscription_period,a.subscription_user_type
    ,a.original_order_id
    ,payment_price_usd
    -- 至观测日期订单状态
    ,o.standard_order_date by_observe_order_date,o.order_id by_observe_order_id,o.by_period by_observe_order_period
    ,a.observe_period,case when a.observe_period > o.by_period then 1 else 0 end is_expired

    -- 真实数据
    ,coalesce(b.LT_real_renewal,0) LT_real_renewal_all   -- 真实续费期数 订单开始至今(不包括首笔)
    ,coalesce(b.by_observe_LT_real_renewal,0) by_observe_LT_real_renewal_all   -- 真实续费期数 订单开始至观测日
    ,coalesce(b.observe_to_now_LT_real_renewal,0) observe_to_now_LT_real_renewal_all   -- 真实续费期数 观测日至今
    ,coalesce(b.LTV_real_renewal,0)+payment_price_usd LTV_real_renewal_all   -- 真实续费金额 订单开始至今(包括首笔)
    ,coalesce(b.by_observe_LTV_real_renewal,0) by_observe_LTV_real_renewal_all   -- 真实续费金额 订单开始至观测日
    ,coalesce(b.observe_to_now_LTV_real_renewal,0) observe_to_now_LTV_real_renewal_all   -- 真实续费金额 观测日至今
    -- 真实数据之限制该首笔订单下
    ,coalesce(c.LT_real_renewal,0) LT_real_renewal   -- 真实续费期数 订单开始至今(不包括首笔)
    ,coalesce(c.by_observe_LT_real_renewal,0) by_observe_LT_real_renewal   -- 真实续费期数 订单开始至观测日
    ,coalesce(c.observe_to_now_LT_real_renewal,0) observe_to_now_LT_real_renewal   -- 真实续费期数 观测日至今
    ,coalesce(c.LTV_real_renewal,0)+payment_price_usd LTV_real_renewal   -- 真实续费金额 订单开始至今(包括首笔)
    ,coalesce(c.by_observe_LTV_real_renewal,0) by_observe_LTV_real_renewal   -- 真实续费金额 订单开始至观测日
    ,coalesce(c.observe_to_now_LTV_real_renewal,0) observe_to_now_LTV_real_renewal   -- 真实续费金额 观测日至今

    -- 预测方案一
    ,case when coalesce(LT)-1<0 then 0 else coalesce(LT)-1 end predict0_LT_fi --预测累积续订率，订单开始日期至终(不包括首笔)
    ,payment_price_usd*coalesce(LT,0)  predict0_LTV_fi    -- 纯预测的 LTV(包括首笔)

    ,LT_agg_rep predict0_LT_reg -- 预测累积续订率，观测日期至终
    ,payment_price_usd*LT_agg_rep predict0_LTV_reg -- 预测累积续订收入，观测日期至终
    ,payment_price_usd*(1+LT_agg_rep)+coalesce(b.by_observe_LTV_real_renewal,0)  predict0_LTV_all   -- 有实际付费+预测LTV(包括当笔)
    ,payment_price_usd*(1+LT_agg_rep)+coalesce(c.by_observe_LTV_real_renewal,0)  predict0_LTV   -- 有实际付费+预测LTV(包括当笔)

    ,LT_agg_rep_c predict0_c_LT_reg -- 预测累积续订率，观测日期至终
    ,payment_price_usd*LT_agg_rep_c predict0_c_LTV_reg -- 预测累积续订收入，观测日期至终
    ,payment_price_usd*(1+LT_agg_rep_c)+coalesce(b.by_observe_LTV_real_renewal,0)  predict0_c_LTV_all   -- 有实际付费+预测LTV(包括当笔)
    ,payment_price_usd*(1+LT_agg_rep_c)+coalesce(c.by_observe_LTV_real_renewal,0)  predict0_c_LTV   -- 有实际付费+预测LTV(包括当笔)

    -- 预测方案二
    ,predict1_LT-1 predict1_LT_reg,predict2_LT-1 predict2_LT_reg -- 预测累积续订率，观测日期至终
    ,payment_price_usd*(predict1_LT-1) predict1_LTV_reg -- 预测累积续订收入，观测日期至终
    ,payment_price_usd*(predict2_LT-1) predict2_LTV_reg -- 预测累积续订收入，观测日期至终
    ,payment_price_usd*(predict1_LT)+coalesce(b.by_observe_LTV_real_renewal,0)  predict1_LTV_all   -- 有实际付费+预测LTV(包括当笔)
    ,payment_price_usd*(predict2_LT)+coalesce(b.by_observe_LTV_real_renewal,0)  predict2_LTV_all   -- 有实际付费+预测LTV(包括当笔)
    ,payment_price_usd*(predict1_LT)+coalesce(c.by_observe_LTV_real_renewal,0)  predict1_LTV   -- 有实际付费+预测LTV(包括当笔)
    ,payment_price_usd*(predict2_LT)+coalesce(c.by_observe_LTV_real_renewal,0)  predict2_LTV   -- 有实际付费+预测LTV(包括当笔)

from
    agg_re a
left join observe_order o
on a.standard_order_date=o.first_order_day and a.original_order_id=o.original_order_id
left join real_paid b on a.standard_order_date = b.standard_order_date and  a.app_id = b.app_id and coalesce(a.country,'-')= coalesce(b.country,'-') and a.platform = b.platform and a.is_UA = b.is_UA
                        and a.subscription_period = b.subscription_period and a.subscription_user_type = b.subscription_user_type
                        and a.original_order_id = b.original_order_id and  coalesce(a.uuid,'-') =  coalesce(b.uuid,'-') and a.order_id = b.order_id
left join order_real_paid c on a.standard_order_date = c.standard_order_date and  a.app_id = c.app_id and coalesce(a.country,'-')= coalesce(c.country,'-') and a.platform = c.platform and a.is_UA = c.is_UA
                        and a.subscription_period = c.subscription_period and a.subscription_user_type = c.subscription_user_type
                        and a.original_order_id = c.original_order_id and  coalesce(a.uuid,'-') =  coalesce(c.uuid,'-') and a.order_id = c.order_id


;
SET OBSERVE_DATE = DATE_ADD(OBSERVE_DATE, INTERVAL 1 DAY);

END WHILE;


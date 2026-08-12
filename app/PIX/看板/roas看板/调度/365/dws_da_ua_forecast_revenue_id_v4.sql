
-- 预测范围，install date \today \instal+365,[today,install+365]
--2023/2/16 新增 Campaign_ID，Keyword_ID，Ad_Group，Ad_Group_ID
-- create or replace table `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4`  as

delete
from  `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4`

where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4`

--
with forecast_re as (
select
    *
from
     `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`
where
    is_UA = 'non-Organic'
    and period_rate  >= 0
)
,cr as
(  -- 使用上个月的，试用促销到正价转化率
    -- 使用上个月的，试用促销到正价转化率
    select
        date_add(date_month,interval 1 month)date_month1,date_month ,app_id,platform,country,subscription_period
        ,'only_trial' cr_type
        ,case when install_first_trial_uv = 0  then 0 else install_first_trial_to_standard_paid_uv/install_first_trial_uv end cr

    from
        `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`

    union all

    select
         date_add(date_month,interval 1 month) date_month1,date_month,app_id,platform,country,subscription_period
        ,'mix_trial' cr_type
        ,case when install_first_mix_trial_uv = 0  then 0 else install_first_mix_trial_to_standard_paid_uv/install_first_mix_trial_uv end cr
     from
        `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`

    union all

    select
         date_add(date_month,interval 1 month) date_month1,date_month,app_id,platform,country,subscription_period
        ,'promotional' cr_type

        ,case when install_first_promotional_uv = 0  then 0 else install_first_promotional_to_standard_paid_uv/install_first_promotional_uv end cr
    from
        `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`
)

,price as (
   -- 当试用和优惠时，使用当月,app_id,country,platform，sku,payment_price_usd下的该sku 正价均值作为试用的价格
    select
        date_trunc(standard_order_date,month) date_month,app_id
        ,platform, country -- 不同国家、platform价格不一样
        ,subscription_period,sku
        ,avg(payment_price_usd)  avg_sku_price
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where
        order_status in (1,2) and offer_method = 'normal' -- 限制正价付费
        and standard_order_date >='2020-08-01'
        and is_UA = 'non-Organic'
        and subscription_period  not in ('inapp','lifetime','1-year','6-month','consumables') -- 这些sku 不需要预测
    group by 1,2,3,4,5,6
    -- 该国家没有人买过该sku
    union all
     select
        date_trunc(standard_order_date,month) date_month,app_id
        ,platform, 'all' country
        ,subscription_period,sku
        ,avg(payment_price_usd)  avg_sku_price
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where
        order_status in (1,2) and offer_method = 'normal' -- 限制正价付费
        and standard_order_date >='2020-08-01'
        and is_UA = 'non-Organic'
        and subscription_period  not in ('inapp','lifetime','1-year','6-month','consumables') -- 这些sku 不需要预测
    group by 1,2,3,4,5,6

    -- 若没有该sku 的价格 ，使用subscription_period 平均价格

    union all
     select
        date_trunc(standard_order_date,month) date_month,app_id
        ,platform, 'all' country
        ,subscription_period,'all'sku

        ,avg(payment_price_usd)  avg_sku_price  -- 每一笔order_id 的价格

    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where
         order_status in (1,2) and offer_method = 'normal' -- 限制正价付费
        and standard_order_date >='2020-08-01'
        and is_UA = 'non-Organic'
        and subscription_period  not in ('inapp','lifetime','1-year','6-month','consumables') -- 这些sku 不需要预测
    group by 1,2,3,4,5,6


)
,new_sub as (
    select
        a.app_id,a.platform,a.country
        ,Media_Source, Campaign, Campaign_ID,Keywords,Keyword_ID,Ad_Group,Ad_Group_ID
        ,Site_ID, IOS_OS_Version
        ,Attributed_Touch_Time as install_date -- 新增日期
        ,a.standard_order_date,a.standard_order_expire_date
        ,a.original_order_id,a.order_id,a.payment_price_usd --,a.uuid
        ,a.subscription_period,a.sku,a.sku_is_trial
        ,a.subscription_user_type,a.offer_method,a.order_status
        ,date_month
        ,first_time_sub_date -- 新增用户新增后的 'first_time_subscription'日期
        ,cr_type
        ,min(first_time_return_sub_date) first_time_return_sub_date
        -- 新增用户新增后的 'first_time_subscription'日期-- first return time 有多个，取新增后最小的一个
    from
    ( -- 剔除触发归因前已经是在订阅状态
    select
        distinct * except(offer_params)
        ,concat(offer_params.offer_duration,offer_params.offer_unit) as offer_period
        ,offer_params.numberOfPeriods as offer_times
        ,date_trunc(standard_order_date,month) date_month
        ,case
            when order_status = 0  and offer_method = 'trial' then 'only_trial'
            when  order_status = 0  and offer_method like '%mix%' then 'mix_trial'
            when order_status in (1,2)and offer_method <> 'normal' then 'promotional'
            else 'no_cr' -- 不需要有cr 的状态
        end cr_type
    from
        `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4`
    where
        standard_order_date < date_add(Attributed_Touch_Time,interval 1 year)   -- 订阅日期要距离新增日期小于1年
         and subscription_period   not in ('inapp','lifetime','1-year','6-month','consumables')
    )a
    left join
        (
            -- 用户首次付费的日期
            select
               distinct standard_order_date first_time_sub_date,app_id,platform,country,original_order_id,subscription_period,sku
            from
                 `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4`
            where standard_order_date  >='2020-08-01'
            and subscription_period  not in ('inapp','lifetime','1-year','6-month','consumables') -- 这些sku 不需要预测
            and subscription_user_type = 'first_time_subscription'
        )c on a.app_id =  c.app_id and a.platform = c.platform and coalesce(a.country,'-') = coalesce(c.country ,'-')
            and a.sku=c.sku and a.original_order_id = c.original_order_id
    left join
        (
            -- 用户首次回流付费的日期
            select
               distinct  standard_order_date first_time_return_sub_date,app_id,platform,country,original_order_id,subscription_period,sku
            from
                 `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4`
            where standard_order_date  >='2020-08-01'
              and subscription_period  not in ('inapp','lifetime','1-year','6-month','consumables') -- 这些sku 不需要预测
              and subscription_user_type = 'first_time_return_subscription'

        )d on a.app_id =  d.app_id and a.platform = d.platform and coalesce(a.country,'-') = coalesce(d.country ,'-')
            and a.sku=d.sku and a.original_order_id = d.original_order_id
   group by
        a.app_id,a.platform,a.country
       ,Media_Source, Campaign, Campaign_ID,Keywords,Keyword_ID,Ad_Group,Ad_Group_ID
        ,Site_ID, IOS_OS_Version
        ,Attributed_Touch_Time
        ,a.standard_order_date,a.standard_order_expire_date
        ,a.original_order_id,a.order_id,a.payment_price_usd --,a.uuid
        ,a.subscription_period,a.sku,a.sku_is_trial
        ,a.subscription_user_type,a.offer_method,a.order_status
        ,date_month
        ,first_time_sub_date ,cr_type

)
,sub as (
    -- first time（return） sub date 不为空时，也就是可以计算出 start_period 和  end_period
    select
        distinct  a.app_id
        ,a.country --为了下一步国家和cr else 的部分连接的铺垫
        ,a.platform
        ,a.Media_Source, a.Campaign, a.Campaign_ID,a.Keywords,a.Keyword_ID,a.Ad_Group,a.Ad_Group_ID
        ,a.Site_ID,a.IOS_OS_Version
        ,install_date  -- 新增日期
        ,a.standard_order_date order_date -- 付费日期
        ,case
        --  'repeated_renewal' 计算距离 first time paid 的期数
            when a.subscription_period = '1-month' and a.subscription_user_type = 'repeated_renewal' and first_time_sub_date is not null  and date_diff(a.standard_order_date,first_time_sub_date,day) >=0
                then date_diff(a.standard_order_date,first_time_sub_date,day)/30.458  --365.5/12
         --  'return_renewal' 计算距离 first time return paid 的期数
            when a.subscription_period = '1-month' and a.subscription_user_type = 'return_renewal'and first_time_return_sub_date is not null  and date_diff(a.standard_order_date,first_time_return_sub_date,day) >=0
                then date_diff(a.standard_order_date,first_time_return_sub_date,day)/30.458  --365.5/12'

            when  a.subscription_period = '1-week' and a.subscription_user_type = 'repeated_renewal' and first_time_sub_date is not null and date_diff(a.standard_order_date,first_time_sub_date,day)>=0
                then date_diff(a.standard_order_date,first_time_sub_date,day)/7 --一周7天
            when  a.subscription_period = '1-week' and a.subscription_user_type = 'return_renewal' and first_time_return_sub_date is not null and date_diff(a.standard_order_date,first_time_return_sub_date,day)>=0
                then date_diff(a.standard_order_date,first_time_return_sub_date,day)/7 --一周7天
            when  a.subscription_period = '3-month' and a.subscription_user_type = 'repeated_renewal' and first_time_sub_date is not null  and date_diff(a.standard_order_date,first_time_sub_date,day)>=0
                then date_diff(a.standard_order_date,first_time_sub_date,day)/91.375 --365.5/4
            when  a.subscription_period = '3-month' and a.subscription_user_type = 'return_renewal' and first_time_return_sub_date is not null and  date_diff(a.standard_order_date,first_time_return_sub_date,day) >=0
                then date_diff(a.standard_order_date,first_time_return_sub_date,day)/91.375 --365.5/4
            else 0      -- 以下情况均为第一期
            end start_period -- 计算累计续订率时，需要计算从该期+1开始
            /*
           -- 以下情况均为第一期
                -- 首次付费
            when  a.subscription_user_type in ('first_time_return_subscription','first_time_subscription')
                --试用或者促销
                  or a.order_status = 0 or (a.order_status in (1,2) and a.offer_method <> 'normal')
                then 0
                    -- 以下是找不到 first time 的情况
            when  first_time_sub_date is  null  or  first_time_return_sub_date is  null  then 0
              -- first time 日期晚于付费日期
            when date_diff(a.standard_order_date,first_time_sub_date,day) <0 then 0
            when  date_diff(a.standard_order_date,first_time_return_sub_date,day)  <0 then 0
       */
        ,case
            when a.subscription_period = '1-month' and a.subscription_user_type in( 'repeated_renewal','first_time_subscription') and first_time_sub_date is not null  and date_diff(a.standard_order_date,first_time_sub_date,day) >=0
                then date_diff(date_add(a.install_date,interval 365 day),first_time_sub_date,day)/30.458
         --  'return_renewal' 计算距离 first time return paid 的期数
            when a.subscription_period = '1-month' and a.subscription_user_type in ('return_renewal','first_time_return_subscription') and first_time_return_sub_date is not null and date_diff(a.standard_order_date,first_time_return_sub_date,day) >=0
                then date_diff(date_add(a.install_date,interval 365 day),first_time_return_sub_date,day)/30.458

            when  a.subscription_period = '1-week' and a.subscription_user_type in( 'repeated_renewal','first_time_subscription')  and first_time_sub_date is not null  and date_diff(a.standard_order_date,first_time_sub_date,day) >=0
                then date_diff(date_add(a.install_date,interval 365 day),first_time_sub_date,day)/7
            when  a.subscription_period = '1-week' and a.subscription_user_type in ('return_renewal','first_time_return_subscription')and first_time_return_sub_date is not null and date_diff(a.standard_order_date,first_time_return_sub_date,day) >=0
                 then date_diff(date_add(a.install_date,interval 365 day),first_time_return_sub_date,day)/7

            when  a.subscription_period = '3-month' and a.subscription_user_type in ( 'repeated_renewal','first_time_subscription') and first_time_sub_date is not null  and date_diff(a.standard_order_date,first_time_sub_date,day) >=0
                then date_diff(date_add(a.install_date,interval 365 day),first_time_sub_date,day)/91.375
            when  a.subscription_period = '3-month' and a.subscription_user_type in ('return_renewal','first_time_return_subscription') and first_time_return_sub_date is not null and date_diff(a.standard_order_date,first_time_return_sub_date,day) >=0
                 then date_diff(date_add(a.install_date,interval 365 day),first_time_return_sub_date,day)/91.375

        -- 试用/优惠价/找不到 first time/ 首次日期还晚于付费日期 的情况
            when a.subscription_period = '1-month' --and  ( a.cr_type <> 'no_cr' or first_time_sub_date is  null  or  first_time_return_sub_date is null or date_diff(a.standard_order_date,first_time_sub_date,day)<0 or date_diff(a.standard_order_date,first_time_return_sub_date,day)<0)
                then  date_diff(date_add(a.install_date,interval 365 day),a.standard_order_date,day)/30.458
            when a.subscription_period = '1-week' --and   ( a.cr_type <> 'no_cr' or first_time_sub_date is  null  or  first_time_return_sub_date is null or date_diff(a.standard_order_date,first_time_sub_date,day)<0 or date_diff(a.standard_order_date,first_time_return_sub_date,day)<0)
                then  date_diff(date_add(a.install_date,interval 365 day),a.standard_order_date,day)/7
            when a.subscription_period = '3-month' --and  ( a.cr_type <> 'no_cr' or first_time_sub_date is  null  or  first_time_return_sub_date is null or date_diff(a.standard_order_date,first_time_sub_date,day)<0 or date_diff(a.standard_order_date,first_time_return_sub_date,day)<0)
                then  date_diff(date_add(a.install_date,interval 365 day),a.standard_order_date,day)/91.375

        end end_period -- 计算累计续订率时，需要计算从start 期+1开始,到end_period期 结束
        ,a.subscription_period
        ,a.sku_is_trial
        ,a.original_order_id -- ,a.uuid

     -- 试用/优惠时使用平均价格
        ,case
            when  a.cr_type <> 'no_cr'  and c.avg_sku_price is not null then c.avg_sku_price
            when  a.cr_type <> 'no_cr' and c.avg_sku_price is null and e.avg_sku_price is not null then e.avg_sku_price
            when   a.cr_type <> 'no_cr'  and c.avg_sku_price is null and  e.avg_sku_price is null then d.avg_sku_price
            else a.payment_price_usd
        end payment_price_usd --
        ,a.standard_order_expire_date  order_expire_date
        ,a.order_id
        ,a.order_status ,a.subscription_user_type,a.offer_method
        ,a.date_month

        ,first_time_sub_date
        ,first_time_return_sub_date
        ,cr_type
    from
       (
        select
            * except(first_time_sub_date,first_time_return_sub_date)
            -- 限制first time sub date 必须大于install_date ,避免脏数据
            ,case
                when first_time_sub_date < install_date then null
                else first_time_sub_date
            end first_time_sub_date
            ,case
                when first_time_return_sub_date < install_date then null
                else first_time_return_sub_date
            end first_time_return_sub_date
        from new_sub
        ) a
    left join (
        -- 对于trial的订单使用 平均每单价格
        select
            *
        from price
        where sku <> 'all'
    )c on a.date_month = c.date_month and a.app_id = c.app_id and  a.platform = c.platform
        and coalesce(a.country,'-')=coalesce(c.country,'-') and a.subscription_period =c.subscription_period and a.sku = c.sku
    left join (
        select
            *
        from price
        where  country ='all' and sku <> 'all'
    )e on a.date_month = e.date_month and a.app_id = e.app_id and  a.platform = e.platform
        and a.subscription_period =e.subscription_period and a.sku = e.sku
    left join (
        -- 对于trial且当月没有该sku的订单使用 subscription_period 平均每单价格
        select
            *
        from price
        where sku = 'all'
    )d on a.date_month = d.date_month and a.app_id = d.app_id and  a.platform = d.platform
        and a.subscription_period =d.subscription_period
)


    select
        app_id,platform,country
       ,Media_Source, Campaign, Campaign_ID,Keywords,Keyword_ID,Ad_Group,Ad_Group_ID
        ,Site_ID, IOS_OS_Version
        ,install_date
        ,order_date
        ,order_id -- 订单
        ,order_status ,subscription_user_type,offer_method
        ,subscription_period
        ,sku_is_trial
        ,original_order_id
        ,payment_price_usd
        ,num_cr
        ,agg_rate
        ,payment_price_usd*num_cr*agg_rate revenue
    from
(
select
    a.app_id,a.platform,a.country
     ,a.Media_Source, a.Campaign, a.Campaign_ID,a.Keywords,a.Keyword_ID,a.Ad_Group,a.Ad_Group_ID
     , a.Site_ID, a.IOS_OS_Version
    ,a.install_date
    ,a.order_date
    ,a.order_id ,a.order_status ,a.subscription_user_type,a.offer_method
    ,a.subscription_period
    ,a.sku_is_trial
    ,a.original_order_id
    ,a.payment_price_usd -- 价格

   ,case
        when a.cr_type = 'no_cr' then 1
        when a.cr_type <> 'no_cr' and c.cr <> 0 then c.cr
        when a.cr_type <> 'no_cr' and c2.cr <> 0 then c2.cr
        when a.cr_type <> 'no_cr' and c3.cr <> 0 then c3.cr

        else 0
    end num_cr

    ,sum(case when b.period between trunc(start_period)+1 and trunc(end_period) then b.period_rate else 0 end ) agg_rate

from
    sub a
   left join forecast_re b on a.order_date  = b.standard_order_date and a.app_id = b.app_id and a.platform = b.platform and coalesce(a.country,'-') = coalesce(b.country,'-')
         and a.subscription_period = b.subscription_period and a.subscription_user_type = b.subscription_user_type

    left join cr c on a.date_month  =  c.date_month1 and a.app_id = c.app_id and a.platform = c.platform
        and coalesce(a.country,'-') = coalesce(c.country,'-') and a.subscription_period = c.subscription_period
        and c.cr_type = a.cr_type
    left join
    (
        select
            *
        from cr
        where country = 'else'

    )c2 on a.date_month =  c2.date_month1 and a.app_id = c2.app_id and a.platform =  c2.platform
        and a.subscription_period = c2.subscription_period and c2.cr_type = a.cr_type
    left join
    -- 当优惠首次出现时，上个月无该cr,使用当月的cr；此种情况可能一开始转化率较小，但随着时间的推移会变大
    (
        select
            *
        from cr
        where country = 'else'

    ) c3 on a.date_month  =  c3.date_month and a.app_id = c3.app_id and a.platform = c3.platform
         and a.subscription_period = c3.subscription_period
        and c3.cr_type = a.cr_type


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
)t0

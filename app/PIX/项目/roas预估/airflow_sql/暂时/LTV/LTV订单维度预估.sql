DECLARE mDATE_START DATE DEFAULT '2021-01-01';
DECLARE mDATE_END DATE DEFAULT '2021-12-31';


drop table if exists `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre`;
create table `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` as

select '1-1' types,date,app_id,platform,subscription_period,country,subscription_user_type,is_ua
        ,by_period
--             ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--             ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample) and sum(sample)>1000

union all

select '1-2' types,date,app_id,platform,subscription_period,'All' country,subscription_user_type,is_ua
        ,by_period
--             ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--             ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample) and sum(sample)>1000

union all

select '1-3' types,date,app_id,'All' platform,subscription_period,'All' country,subscription_user_type,'All' is_ua
        ,by_period
--             ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--             ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample)

union all

select '2-1' types,date,app_id,platform,subscription_period,country,subscription_user_type,is_ua
        ,-99999 by_period
--         ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--         ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample) and sum(sample)>1000

union all

select '2-2' types,date,app_id,platform,subscription_period,'All' country,subscription_user_type,is_ua
        ,-99999 by_period
--         ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--         ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample) and sum(sample)>1000

union all

select '2-3' types,date,app_id,'All' platform,subscription_period,'All' country,subscription_user_type,'All' is_ua
        ,-99999 by_period
--         ,sum(sample) sample_expire,sum(renewal_num) sample_renewal
--         ,sum(renewal_num)/sum(sample) sample_renewal_ratio
        ,1/(1-sum(renewal_num)/sum(sample)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
where date between mDATE_START and mDATE_END
group by 1,2,3,4,5,6,7,8,9
having sum(renewal_num)<sum(sample)
;


delete from dataintegration-265403.temp.temp_dws_dz_order_id_ltv where standard_order_date between mDATE_START and mDATE_END;
insert into dataintegration-265403.temp.temp_dws_dz_order_id_ltv

-- drop table if exists `dataintegration-265403.temp.temp_dws_dz_order_id_ltv`;
-- create table `dataintegration-265403.temp.temp_dws_dz_order_id_ltv` as

with subscription as (
     select
        a.*except(country),fix_firebase_en_name country,date_add(standard_order_date,interval 365 day) standard_365_date
     from
     (
        select
            *
        from
            `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where
           standard_order_date between mDATE_START and mDATE_END
           and order_status in (1,2)
     ) a
     left join (select distinct key, fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.country = b.key
)
,
first_date as
(
    select
        a.app_id, a.subscription_period, a.original_order_id, a.order_id
--         , date(a.standard_order_date) as standard_order_date
        ,min(date(b.standard_order_date)) as first_order_day
        ,max(case when a.subscription_period = '1-year' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), year)
              when a.subscription_period = '1-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month)
              when a.subscription_period = '1-week' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), week)
              when a.subscription_period = '3-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), quarter)
              when a.subscription_period = '6-month' then cast(safe_divide(DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month), 6) as int64)
              end) as by_period

    from
    (
        select app_id, subscription_period, original_order_id, order_id,  standard_order_date
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    ) a
    left join
    (
        select distinct app_id, subscription_period, original_order_id, standard_order_date,
                    ifnull(lead(standard_order_date) over(partition by app_id, original_order_id,subscription_period order by standard_order_date), '2099-12-31') as next_interval
        from  `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where  subscription_user_type in ('first_time_subscription','first_time_return_subscription')
    ) b
    on a.app_id = b.app_id and a.original_order_id=b.original_order_id and a.subscription_period = b.subscription_period
    where a.standard_order_date >= b.standard_order_date and a.standard_order_date < b.next_interval
    group by 1,2,3,4
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
            ,count(distinct case when l.standard_order_date <= f.standard_365_date then l.order_id end) LT365_real_renewal
            ,sum(coalesce(l.payment_price_usd,0)) LTV_real_renewal   -- 计算 LTV 用的真实续费金额  LTV_real_Rn
            ,sum(case when l.standard_order_date <= f.standard_365_date and l.payment_price_usd is not null  then l.payment_price_usd else 0 end) LTV365_real_renewal    -- 计算LTV365  用的真实续费金额LTV365_real_Rn
    from
            subscription  f
    left join
    (
        select * from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
                and standard_order_date>=mDATE_START
    ) l on f.app_id = l.app_id --and coalesce(f.country,'-')= coalesce(l.country,'-') and f.platform = l.platform and f.is_UA = l.is_UA
            and f.subscription_period = l.subscription_period --and f.subscription_user_type =  l.subscription_type
            and f.original_order_id = l.original_order_id and coalesce(f.uuid,'-') =  coalesce(l.uuid,'-')
            and f.sku = l.sku
    where f.standard_order_date < l.standard_order_date -- 选取之后的续费订单
    group by 1,2,3,4,5,6,7,8,9,10
)


select s.standard_order_date,s.app_id,s.country,s.platform,s.is_UA,s.subscription_period,s.subscription_user_type
     ,s.original_order_id,s.uuid,s.order_id,f.by_period,f.first_order_day
     ,coalesce(LT_real_renewal,0) LT_real_renewal
     ,coalesce(LT365_real_renewal,0) LT365_real_renewal
     ,coalesce(LTV_real_renewal,0) LTV_real_renewal
     ,coalesce(LTV365_real_renewal,0) LTV365_real_renewal

     ,coalesce(p1_1.predict_LT,p1_2.predict_LT,p1_3.predict_LT) predict1_LT
     ,coalesce(p2_1.predict_LT,p2_2.predict_LT,p2_3.predict_LT) predict2_LT
from subscription s
left join real_paid r
on s.standard_order_date=r.standard_order_date and s.app_id=r.app_id
    and s.subscription_period=r.subscription_period and s.order_id=r.order_id
-- 当前续订第几期
left join first_date f
on s.order_id=f.order_id and s.app_id=f.app_id and s.subscription_period=f.subscription_period

left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='1-1') p1_1
on s.standard_order_date=p1_1.date and s.app_id=p1_1.app_id and s.subscription_period=p1_1.subscription_period
    and s.subscription_user_type=p1_1.subscription_user_type and coalesce(f.by_period,-99999)=coalesce(p1_1.by_period,-99999)
    and s.platform=p1_1.platform and s.is_ua=p1_1.is_ua
    and s.country=p1_1.country
left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='1-2') p1_2
on s.standard_order_date=p1_2.date and s.app_id=p1_2.app_id and s.subscription_period=p1_2.subscription_period
    and s.subscription_user_type=p1_2.subscription_user_type and coalesce(f.by_period,-99999)=coalesce(p1_2.by_period,-99999)
    and s.platform=p1_2.platform and s.is_ua=p1_2.is_ua
--     and s.country=p1_2.country
left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='1-3') p1_3
on s.standard_order_date=p1_3.date and s.app_id=p1_3.app_id and s.subscription_period=p1_3.subscription_period
    and s.subscription_user_type=p1_3.subscription_user_type and coalesce(f.by_period,-99999)=coalesce(p1_3.by_period,-99999)
--     and s.platform=p1_3.platform and s.is_ua=p1_3.is_ua
--     and s.country=p1_3.country

left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='2-1') p2_1
on s.standard_order_date=p2_1.date and s.app_id=p2_1.app_id and s.subscription_period=p2_1.subscription_period
    and s.subscription_user_type=p2_1.subscription_user_type
    and s.platform=p2_1.platform and s.is_ua=p2_1.is_ua
    and s.country=p2_1.country
left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='2-2') p2_2
on s.standard_order_date=p2_2.date and s.app_id=p2_2.app_id and s.subscription_period=p2_2.subscription_period
    and s.subscription_user_type=p2_2.subscription_user_type
    and s.platform=p2_2.platform and s.is_ua=p2_2.is_ua
--     and s.country=p2_2.country
left join (select * from `dataintegration-265403.temp.temp_dws_dz_order_id_ltv_pre` where types='2-3') p2_3
on s.standard_order_date=p2_3.date and s.app_id=p2_3.app_id and s.subscription_period=p2_3.subscription_period
    and s.subscription_user_type=p2_3.subscription_user_type
--     and s.platform=p2_3.platform and s.is_ua=p2_3.is_ua
--     and s.country=p2_3.country


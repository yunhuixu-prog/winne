-- 当前订阅数/退订数
DECLARE mDATE_START DATE DEFAULT '2024-07-19';
DECLARE mDATE_END DATE DEFAULT '2024-09-13';

DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund where date = mDATE;
insert into beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund

-- DECLARE mDATE DATE DEFAULT '2024-07-18';
-- drop table if exists beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund;
-- create table beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund as


with renewal_uv as
(
    select
        s.end_date,
        s.app_id,s.country,
        s.platform,s.subscription_period,s.is_ua,
        s.original_order_id,s.order_id,s.uuid,s.sku,
        if(next_start_date > start_date
        and next_start_date <= date_add(end_date,interval 1 day) and subscription_period = next_subscription_period,s.original_order_id,null)id1,
        if(next_start_date2 > start_date
        and next_start_date2 <= date_add(end_date,interval 1 day),s.original_order_id,null)id2
    from
    (
        select
            s1.standard_order_date start_date,
            s1.standard_order_expire_date end_date,
            lead(s1.standard_order_date) over(partition by s1.original_order_id order by s1.standard_order_date) as next_start_date,
            lead(s1.standard_order_date) over(partition by s1.uuid order by s1.standard_order_date) as next_start_date2,
            lead(s1.subscription_period) over(partition by s1.original_order_id order by s1.standard_order_date) as next_subscription_period,
            s1.original_order_id,
            s1.order_id,
            s1.uuid,
            s1.platform,
            s1.is_ua,
            s1.app_id,
            s1.subscription_period,
            s1.sku,
            s1.country
        from
        (select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
        and app_id='BeautyPlus'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
--         and sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2'
--                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31'
--                     ,'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
--                     ,'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32'
--
--                     ,'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4'
--                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27'
--                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
--                     ,'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
--                     )
        )s1
    )s
)
,
first_date as
(
    select
        a.app_id, a.subscription_period, a.original_order_id, a.order_id
--         , date(a.standard_order_date) as standard_order_date
--         , date(b.standard_order_date) as first_day
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


select date,platform,subscription_period,sku,country_label,by_period
    ,sum(vpu) vpu
    ,sum(refund_order_num) refund_order_num
    ,sum(refund_status_order_num) refund_status_order_num
    ,sum(expired_order_num) expired_order_num
    ,sum(renewal_order_num) renewal_order_num
    ,sum(has_cancelled_expired_order_num) has_cancelled_expired_order_num
    ,sum(has_cancelled_renewal_order_num) has_cancelled_renewal_order_num
    ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),2) end renewal_ratio
from
(
    select
        mDATE date,a.platform,a.subscription_period,a.sku
    --     ,case when country in ('United States') then 'Tier1'
    --            when country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
    --                     , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
    --                     , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
    --                     /* 'United Kingdom',*/
    --                     ) then 'Tier2'
    --            when country in ('Japan','South Korea') then 'Tier3'
    --            when country in ('Indonesia','Thailand') then 'Tier4'
    --            when country in ('India') then 'Tier5'
    --            when country in ('Brazil') then 'Tier6'
    --            else 'Tier7'
    --     end Tier
        ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
          end country_label
    --      ,country
        ,f.by_period
        ,count(distinct a.original_order_id) vpu
        ,count(distinct case when b.order_id is not null and standard_cancel_date = mDATE then a.order_id end) refund_order_num
        ,count(distinct case when b.order_id is not null then a.order_id end) refund_status_order_num
        ,0 expired_order_num
        ,0 renewal_order_num
        ,0 has_cancelled_expired_order_num
        ,0 has_cancelled_renewal_order_num
    from
    (
        select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
            and app_id='BeautyPlus'
            and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
            and offer_method = 'normal'
            and standard_order_date<=mDATE
            and (standard_order_expire_date>=mDATE or subscription_period ='lifetime')
            and order_id not in (select order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in('BeautyPlus') and order_status in (3))
    ) a
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='BeautyPlus'
--             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
    left join first_date f
    on a.order_id=f.order_id and a.app_id=f.app_id and a.subscription_period=f.subscription_period
    group by 1,2,3,4,5,6

    union all

    select end_date date,a.platform,a.subscription_period,a.sku
         ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
          end country_label
         ,f.by_period
         ,0 vpu
         ,0 refund_order_num
         ,0 refund_status_order_num
         ,count(distinct a.original_order_id) expired_order_num
         ,count(distinct id1) renewal_order_num
         ,count(distinct case when b.order_id is not null then a.original_order_id end) has_cancelled_expired_order_num
         ,count(distinct case when b.order_id is not null then a.id1 end) has_cancelled_renewal_order_num
    from renewal_uv a
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='BeautyPlus'
--             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
    left join first_date f
    on a.order_id=f.order_id and a.app_id=f.app_id and a.subscription_period=f.subscription_period
    where end_date = mDATE
    --     and platform='IOS'
    --     and subscription_period='1-year'
    group by 1,2,3,4,5,6
)
group by 1,2,3,4,5,6
;
SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;




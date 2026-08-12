
-- 当前订阅数/退订数
DECLARE mDATE_START DATE DEFAULT '2024-08-10';
DECLARE mDATE_END DATE DEFAULT '2024-08-18';

DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund where date = mDATE;
insert into beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund

-- DECLARE mDATE DATE DEFAULT '2024-08-04';
-- drop table if exists beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund;
-- create table beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund as


with renewal_uv as
(
    select
        s.end_date,
        s.app_id,s.country,
        s.platform,s.subscription_period,s.is_ua,
        s.original_order_id,s.sku,
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


select date,platform,subscription_period,sku,country_label
    ,sum(vpu) vpu
    ,sum(refund_order_num) refund_order_num
    ,sum(refund_status_order_num) refund_status_order_num
    ,sum(expired_order_num) expired_order_num
    ,sum(renewal_order_num) renewal_order_num
    ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),2) end renewal_ratio
from
(
    select
        mDATE date,platform,subscription_period,sku
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

        ,count(distinct a.original_order_id) vpu
        ,count(distinct case when b.order_id is not null and standard_cancel_date = mDATE then a.order_id end) refund_order_num
        ,count(distinct case when b.order_id is not null then a.order_id end) refund_status_order_num
        ,0 expired_order_num
        ,0 renewal_order_num
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
    group by 1,2,3,4,5

    union all

    select end_date date,platform,subscription_period,sku
         ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
          end country_label
         ,0 vpu
         ,0 refund_order_num
         ,0 refund_status_order_num
         ,count(distinct original_order_id) expired_order_num,count(distinct id1) renewal_order_num
    from renewal_uv
    where end_date = mDATE
    --     and platform='IOS'
    --     and subscription_period='1-year'
    group by 1,2,3,4,5
)
group by 1,2,3,4,5
;
SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;

;
select date,platform,subscription_period,sku
    ,case when country_label in ('Japan','United States','South Korea','Thailand','European Union') then country_label else 'other' end country_label
    ,sum(vpu) vpu
    ,sum(refund_order_num) refund_order_num
--     ,sum(refund_status_order_num) refund_status_order_num
    ,sum(expired_order_num) expired_order_num
    ,sum(renewal_order_num) renewal_order_num
    ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),2) end renewal_ratio
from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
where date >= date_sub('2024-08-02',interval 13 day)
    and sku in (
--                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
--                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                    'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
--                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

--                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
--                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                    'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
--                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                    )
group by 1,2,3,4,5
order by 1,2,3,4,5
;

-- 整体
select *
from (
select '0:整体' type
     ,a.renewal_ratio as renewal_ratio_pre,b.renewal_ratio as renewal_ratio_af,c.renewal_ratio as renewal_ratio_effect
     ,if(a.renewal_ratio=0,0.0,round(b.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio
     ,if(a.renewal_ratio=0,0.0,round(c.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio_effect
     ,a.refund_ratio as refund_ratio_pre,b.refund_ratio as refund_ratio_af,c.refund_ratio as refund_ratio_effect
     ,if(a.refund_ratio=0,0.0,round(b.refund_ratio/a.refund_ratio-1,4)) refund_ratio
     ,if(a.refund_ratio=0,0.0,round(c.refund_ratio/a.refund_ratio-1,4)) refund_ratio_effect
from
(
    select
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between date_sub('2024-08-02',interval 13 day) and '2024-08-02'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
--     group by 1
) a
left join
(
    select
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-03' and '2024-08-30'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
--     group by 1
) b
on 1=1
left join
(
    select
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-31' and '2024-09-13'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
--     group by 1
) c
on 1=1

union all
-- 分sku
select case when a.subscription_period='1-year' then '1-1:年sku'
            when a.subscription_period='1-month' then '1-2:月sku'
     end type
     ,a.renewal_ratio as renewal_ratio_pre,b.renewal_ratio as renewal_ratio_af,c.renewal_ratio as renewal_ratio_effect
     ,if(a.renewal_ratio=0,0.0,round(b.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio
     ,if(a.renewal_ratio=0,0.0,round(c.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio_effect
     ,a.refund_ratio as refund_ratio_pre,b.refund_ratio as refund_ratio_af,c.refund_ratio as refund_ratio_effect
     ,if(a.refund_ratio=0,0.0,round(b.refund_ratio/a.refund_ratio-1,4)) refund_ratio
     ,if(a.refund_ratio=0,0.0,round(c.refund_ratio/a.refund_ratio-1,4)) refund_ratio_effect
from
(
    select subscription_period,
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between date_sub('2024-08-02',interval 13 day) and '2024-08-02'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) a
left join
(
    select subscription_period,
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-03' and '2024-08-30'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) b
on a.subscription_period=b.subscription_period
left join
(
    select subscription_period,
        sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-31' and '2024-09-13'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) c
on a.subscription_period=c.subscription_period

union all
-- 分国家
select case when a.country_label='United States' then '2-1:美国'
            when a.country_label='Japan' then '2-2:日本'
            when a.country_label='South Korea' then '2-3:韩国'
            when a.country_label='Thailand' then '2-4:泰国'
            when a.country_label='European Union' then '2-5:欧盟'
            when a.country_label='other' then '2-6:其他国家'
     end type
     ,a.renewal_ratio as renewal_ratio_pre,b.renewal_ratio as renewal_ratio_af,c.renewal_ratio as renewal_ratio_effect
     ,if(a.renewal_ratio=0,0.0,round(b.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio
     ,if(a.renewal_ratio=0,0.0,round(c.renewal_ratio/a.renewal_ratio-1,4)) renewal_ratio_effect
     ,a.refund_ratio as refund_ratio_pre,b.refund_ratio as refund_ratio_af,c.refund_ratio as refund_ratio_effect
     ,if(a.refund_ratio=0,0.0,round(b.refund_ratio/a.refund_ratio-1,4)) refund_ratio
     ,if(a.refund_ratio=0,0.0,round(c.refund_ratio/a.refund_ratio-1,4)) refund_ratio_effect
from
(
    select case when country_label in ('Japan','United States','South Korea','Thailand','European Union') then country_label else 'other' end country_label
        ,sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between date_sub('2024-08-02',interval 13 day) and '2024-08-02'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) a
left join
(
    select case when country_label in ('Japan','United States','South Korea','Thailand','European Union') then country_label else 'other' end country_label
        ,sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-03' and '2024-08-30'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) b
on a.country_label=b.country_label
left join
(
    select case when country_label in ('Japan','United States','South Korea','Thailand','European Union') then country_label else 'other' end country_label
        ,sum(vpu) vpu
        ,sum(refund_order_num) refund_order_num
    --     ,sum(refund_status_order_num) refund_status_order_num
        ,sum(expired_order_num) expired_order_num
        ,sum(renewal_order_num) renewal_order_num
        ,case when sum(expired_order_num)=0 then 0.0 else round(sum(renewal_order_num)/sum(expired_order_num),6) end renewal_ratio
        ,case when sum(vpu)=0 then 0.0 else round(sum(refund_order_num)/sum(vpu),6) end refund_ratio
    from beautyplus-bc0ed.temp.push_sku_renewal_vpu_refund
    where date between '2024-08-31' and '2024-09-13'
        and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                        'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
    --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',

    --                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
    --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
                        'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                        )
    group by 1
) c
on a.country_label=c.country_label
)
order by 1





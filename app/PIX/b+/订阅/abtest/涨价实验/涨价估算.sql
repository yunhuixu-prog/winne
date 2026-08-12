-- 当前订阅状态的sku分布及在一周/月等的续订人数
DECLARE mDATE DATE DEFAULT '2024-07-28';
select
    app_id,standard_order_date,subscription_period,standard_order_expire_date,order_id,uuid,payment_price_usd sub_revenue,sku,sku_price
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where
    app_id in('BeautyPlus')
    and order_status in (1,2)
    and (standard_order_expire_date>=mDATE or subscription_period ='lifetime')
    and standard_order_date<=mDATE
;

DECLARE mDATE DATE DEFAULT '2024-08-04';
drop table if exists beautyplus-bc0ed.temp.sku_renewal_vpu;
create table beautyplus-bc0ed.temp.sku_renewal_vpu as

-- select *,     ,sum(renewal_14) over(partition by subscription_period) renewal_14_sku_period
--      ,sum(renewal_31) over(partition by subscription_period) renewal_31_sku_period
--      ,sum(renewal_14) over(partition by platform) renewal_14_platform
--      ,sum(renewal_31) over(partition by platform) renewal_31_platform
-- from
-- (
select
    sku,sku_price,sku_currency
    ,case when sku in ('beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver27','beautyplus.subs.month12.func00.lev00.v15','beautyplus.subs.month12.func00.lev00.v16','beautyplus.subs.month12.func00.lev00.v17','beautyplus.subs.month12.func00.lev00.ver28','beautyplus.subs.month12.func00.lev00.ver29','beautyplus.subs.month12.func00.lev00.ver31','beautyplus.subs.month12.func00.lev00.ver30','beautyplus.subs.month12.func00.lev00.ver32','beautyplus.subs.month12.func00.lev00.ver33','beautyplus.subs.month12.func00.lev00.v18','beautyplus.subs.month12.func00.lev00.v21','beautyplus.subs.month12.func00.lev00.v19','beautyplus.subs.month12.func00.lev00.v20','beautyplus.subs.month12.func00.lev00.v22','beautyplus.subs.month12.func00.lev00.v23','beautyplus.subs.month12.func00.lev00.ver40','beautyplus.subs.month12.func00.lev00.ver40','beautyplus.subs.month12.func00.lev00.v30','beautyplus.subs.month12.func00.lev00.v30','beautyplus.subs.month1.func00.lev00.ver27','beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver29','beautyplus.subs.month1.func00.lev00.v14','beautyplus.subs.month1.func00.lev00.v15','beautyplus.subs.month1.func00.lev00.v16','beautyplus.subs.month1.func00.lev00.ver30','beautyplus.subs.month1.func00.lev00.ver31','beautyplus.subs.month1.func00.lev00.ver33','beautyplus.subs.month1.func00.lev00.ver32','beautyplus.subs.month1.func00.lev00.ver34','beautyplus.subs.month1.func00.lev00.ver35','beautyplus.subs.month1.func00.lev00.v14','beautyplus.subs.month1.func00.lev00.v14','beautyplus.subs.month1.func00.lev00.v15','beautyplus.subs.month1.func00.lev00.v16','beautyplus.subs.month1.func00.lev00.v15','beautyplus.subs.month1.func00.lev00.v16','beautyplus.subs.month1.func00.lev00.ver42','beautyplus.subs.month1.func00.lev00.ver42','beautyplus.subs.month1.func00.lev00.v14','beautyplus.subs.month1.func00.lev00.v14') then '线上' else '下线' end sku_label
    ,sku_is_trial,subscription_period,platform
    ,case when country in ('United States') then 'Tier1'
           when country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    /* 'United Kingdom',*/
                    ) then 'Tier2'
           when country in ('Japan','South Korea') then 'Tier3'
           when country in ('Indonesia','Thailand') then 'Tier4'
           when country in ('India') then 'Tier5'
           when country in ('Brazil') then 'Tier6'
           else 'Tier7'
    end Tier
--     ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
--            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
--                     , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
--                     , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
--                     /* 'United Kingdom',*/
--                     ) then 'European Union'
--            else 'other'
--       end country_label
     ,country

    ,count(distinct original_order_id) order_num
    ,round(sum(payment_price_usd),2) order_revenue
    ,count(distinct case when standard_order_expire_date between mDATE and date_add(mDATE,interval 14 day) then original_order_id end) renewal_14
    ,count(distinct case when standard_order_expire_date between mDATE and date_add(mDATE,interval 30 day) then original_order_id end) renewal_30
    ,count(distinct case when standard_order_expire_date between mDATE and date_add(mDATE,interval 60 day) then original_order_id end) renewal_60
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where
    app_id in('BeautyPlus')
    and order_status in (1,2)
    and (standard_order_expire_date>=mDATE or subscription_period ='lifetime')
    and standard_order_date<=mDATE
    and order_id not in (select order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in('BeautyPlus') and order_status in (3))
--     and sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2'
--                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31'
--                     ,'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
--                     ,'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32'
--
--                     ,'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4'
--                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27'
--                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
--                     ,'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
--                     )
group by 1,2,3,4,5,6,7,8,9
-- )
order by 10 desc



with renewal_uv as
(
    select
        substr(cast(s.end_date as string),1,7) month,
        s.app_id,
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
            s1.sku
        from
        (select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
        and app_id='BeautyPlus'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
--         and sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier2','beautyplus.subs.month12.func00.lev00.ver3'
--                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.tier2','beautyplus.subs.month1.func00.lev00.ver5')
        and sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2'
                    ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
                    ,'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32'

                    ,'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4'
                    ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
                    ,'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                    )
        )s1
    )s
)

select month,platform,app_id,subscription_period,sku,count(distinct original_order_id),count(distinct id2)
from renewal_uv
where month = '2024-07' and platform='IOS'
group by 1,2,3,4,5
order by 1,2,3,4,5

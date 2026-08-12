-- 新增first_time_subscription，新增回流first_time_return_subscription，在27行替换
DECLARE mDATE_START DATE DEFAULT '2025-01-10';
DECLARE mDATE_END DATE DEFAULT '2025-03-09';

select standard_order_date date
    ,case when subscription_period='1-month' then 'month'
          when subscription_user_type_pre in ('intro_trial','trial') and interval_days=7 then '7-trial'
          when subscription_user_type_pre in ('intro_trial','trial') and interval_days=3 then '3-trial'
          when sku_is_trial='no_trial' then 'no_trial'
--           when interval_days is not null then 'x-trial'
    else 'else' -- 优惠价转付费，sku为试用但实际无试用或者间隔时间很久了
    end order_type
    ,count(1) uv
    ,round(sum(payment_price_usd)) bookings
-- select standard_order_date date,subscription_user_type_pre,count(1) uv,round(sum(payment_price_usd)) bookings
from
(
    select a.*,date_diff(a.standard_order_date,b.standard_order_date,day) interval_days
            ,b.standard_order_date standard_order_date_pre,b.subscription_user_type subscription_user_type_pre,b.sku sku_pre
            ,row_number() over(partition by a.original_order_id,a.uuid order by b.standard_order_date desc) orders
    from
    (
        select original_order_id,o_original_order_id,uuid,standard_order_date,subscription_period,payment_price_usd,sku,sku_is_trial,country,is_ua,last_offer_method
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between mDATE_START and mDATE_END
            and app_id in('BeautyPlus')
            and subscription_user_type in ('first_time_return_subscription') --'first_time_return_subscription','first_time_subscription'
            -- and platform='IOS'
            and country='United States'
    ) a
    left join
    (
        select original_order_id,o_original_order_id,uuid,standard_order_date,subscription_user_type,sku
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between date_sub(mDATE_START,interval 380 day) and mDATE_END
            and app_id in('BeautyPlus')
--             and subscription_user_type in ('intro_trial','trial')  --intro pay as you go
            -- and platform='IOS'
    ) b
    on a.o_original_order_id=b.o_original_order_id and a.uuid=b.uuid
        and a.standard_order_date>b.standard_order_date
--         and a.standard_order_date>=date_sub(b.standard_order_date,interval 30 day)
)
where orders=1
--     and case when subscription_period='1-month' then 'month'
--           when subscription_user_type_pre in ('intro_trial','trial') and interval_days=7 then '7-trial'
--           when subscription_user_type_pre in ('intro_trial','trial') and interval_days=3 then '3-trial'
--           when sku_is_trial='no_trial' then 'no_trial'
-- --           when interval_days is not null then 'x-trial'
--     else 'else' -- 优惠价转付费，sku为试用但实际无试用
--     end = 'else'

--     and subscription_period!='1-month'
--     and ((interval_days!=7 and interval_days!=3) or interval_days is null)
--     and subscription_period!='1-month'
--     and interval_days is null and sku_is_trial='has_trial'
--     and sku in ('beautyplus_auto_renewing_1y_sd30off_all')
group by 1,2
order by 1,2




-- 分维度
select
    case when event_name='dau' then '0:dau'
         when event_name='enter_subscription_page' then '1:sub enter'
         when event_name='subscription_clk_try' then '2:sub click'
         when event_name='sub_suc' then '3:sub success'
         when event_name='sub_to_paid' then '4:sub success to paid'
         when event_name='trial' then '6:trial'
         when event_name='trial_to_paid' then '7:trial to paid'
    end event_name
    ,date
--     ,case   when date between '2025-01-27' and '2025-02-02' then '0127-0202'
--             when date between '2025-02-24' and '2025-03-02' then '0224-0302'
--             end date_label
    ,case   when date between '2025-02-18' and '2025-02-23' then '0218-0223'
            when date between '2025-02-25' and '2025-03-02' then '0225-0302'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then country
          else 'WW'
    end as country
    ,sum(uv) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    ((date between '2025-02-18' and '2025-02-23')
    or (date between '2025-02-25' and '2025-03-02'))
    and data_type= 'event'
    and event_name in ('trial','trial_to_paid','enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid','dau')
group by
    1,2,3,4,5,6,7

union all

select
    '5:sub success to paid bookings' event_name
    ,date
--     ,case   when date between '2025-01-27' and '2025-02-02' then '0127-0202'
--             when date between '2025-02-24' and '2025-03-02' then '0224-0302'
--             end date_label
    ,case   when date between '2025-02-18' and '2025-02-23' then '0218-0223'
            when date between '2025-02-25' and '2025-03-02' then '0225-0302'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then country
          else 'WW'
    end as country
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    ((date between '2025-02-18' and '2025-02-23')
    or (date between '2025-02-25' and '2025-03-02'))
    and data_type= 'event'
    and event_name in ('sub_to_paid')
group by
    1,2,3,4,5,6,7

;

select
    case when event_name='dau' then '0:dau'
         when event_name='enter_subscription_page' then '1:sub enter'
         when event_name='subscription_clk_try' then '2:sub click'
         when event_name='sub_suc' then '3:sub success'
         when event_name='sub_to_paid' then '4:sub success to paid'
         when event_name='trial' then '6:trial'
         when event_name='trial_to_paid' then '7:trial to paid'
    end event_name
    ,date
--     ,case   when date between '2025-01-27' and '2025-02-02' then '0127-0202'
--             when date between '2025-02-24' and '2025-03-02' then '0224-0302'
--             end date_label
    ,case   when date between '2025-03-04' and '2025-03-09' then '0304-0309'
            when date between '2025-02-25' and '2025-03-02' then '0225-0302'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,a.sku_has_trial
    ,a.sku_type
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then country
          else 'WW'
    end as country
    ,sum(uv) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    ((date between '2025-03-04' and '2025-03-09')
    or (date between '2025-02-25' and '2025-03-02'))
    and data_type= 'event_and_sku'
    and event_name in ('subscription_clk_try','sub_suc','sub_to_paid')
    and sku_has_trial='no_trial'
group by
    1,2,3,4,5,6,7,8,9

union all

select
    '5:sub success to paid bookings' event_name
    ,date
--     ,case   when date between '2025-01-27' and '2025-02-02' then '0127-0202'
--             when date between '2025-02-24' and '2025-03-02' then '0224-0302'
--             end date_label
    ,case   when date between '2025-03-04' and '2025-03-09' then '0304-0309'
            when date between '2025-02-25' and '2025-03-02' then '0225-0302'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,a.sku_has_trial
    ,a.sku_type
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then country
          else 'WW'
    end as country
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    ((date between '2025-03-04' and '2025-03-09')
    or (date between '2025-02-25' and '2025-03-02'))
    and data_type= 'event_and_sku'
    and event_name in ('sub_to_paid')
    and sku_has_trial='no_trial'
group by
    1,2,3,4,5,6,7,8,9

;
select
    a.date
    ,a.platform
    ,case when sku_type='1m' then '1m'
          when sub_success_offer_type not in ('trial','intro_trial','promotion_trial') and sku_type='12m' then '12m_no_trial'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' and date_diff(purchase_date,standard_order_date,day)=7 then '12m_has_trial_7days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' and date_diff(purchase_date,standard_order_date,day)=3 then '12m_has_trial_3days'
          when sub_success_offer_type in ('trial','intro_trial','promotion_trial') and sku_type='12m' then '12m_has_trial_others'
    else 'others'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,u.is_new
    ,count(distinct a.user_pseudo_id) as uv
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
--     ((date between '2025-01-27' and '2025-02-02')
--     or (date between '2025-02-24' and '2025-03-02'))
    a.date between '2025-01-27' and '2025-03-09'
    and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and u.country='United States'
group by
    1,2,3,4,5

;
-- 分sku
select case   when standard_order_date between '2025-03-04' and '2025-03-09' then '0304-0309'
            when standard_order_date between '2025-02-25' and '2025-03-02' then '0225-0302'
            end date_label
     ,sku,count(distinct uuid) as uv,round(sum(payment_price_usd),2) value
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2025-02-25' and '2025-03-09'
    and app_id in('BeautyPlus')
    and subscription_user_type in ('first_time_return_subscription','first_time_subscription') --'first_time_return_subscription','first_time_subscription'
    -- and platform='IOS'
    and country='United States'
group by 1,2


select
    case   when date between '2025-02-25' and '2025-03-02' then '0225-0302'
            when date between '2025-02-18' and '2025-02-23' then '0218-0223'
            end date_label
    ,u.is_new
    ,sku
    ,count(distinct a.user_pseudo_id) as sub_uv
    ,count(distinct case when purchase_date is not null then a.user_pseudo_id end) as sub_pay_uv
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    ((a.date between '2025-02-25' and '2025-03-02')
    or (a.date between '2025-02-18' and '2025-02-23'))
--     date between '2025-01-27' and '2025-03-09'
    and event_name in ('subscription_try_suc') and standard_order_date is not null
    and u.country='United States'
group by
    1,2,3



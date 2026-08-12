drop table if exists `dataintegration-265403.temp.temp_first_install_day_to_sub`;
create table `dataintegration-265403.temp.temp_first_install_day_to_sub` as

select f.standard_order_date date,f.uuid,f.platform,f.country,f,subscription_period,f.original_order_id,f.order_id
--      ,date_diff(f.standard_order_date,b.first_active_date,day) first_active_days
     ,date_diff(f.standard_order_date,c.Attributed_Touch_Date,day) install_days -- 缺失的当成30天以上安装的吧
     ,a.date order_start_date
     ,a.user_pseudo_id
     ,category1,category2
from
(
    select standard_order_date,original_order_id,order_id,is_ua,uuid,country,subscription_period,platform
    from `dataintegration-265403.subscription.dwd_subscription_user_segment_monthly_new`
    where app_id in ('BeautyPlus') and standard_order_date between '2022-01-01' and '2023-08-31'
        and subscription_user_type  in ('first_time_subscription')
) f
left join
(
--     select 'sub_suc' as event_name,platform,country,date,new_uuid uuid,original_order_id,order_id,user_pseudo_id,agg,sku_type,sku_has_trial,sub_user_type
--     from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
--     where date >= '2024-07-30'
--         and event_name in ('subscription_try_suc')
--         and standard_order_date is not null
--
--     union all

    select 'sub_to_paid' as event_name,platform,country,date,new_uuid uuid,original_order_id,order_id,user_pseudo_id,a.category1,a.category2
           ,sku_type,sku_has_trial,sub_user_type
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) a
    where date between '2021-12-01' and '2023-09-10'
        and event_name in ('subscription_try_suc')
        and standard_order_date is not null and purchase_date is not null
) a
on f.order_id=a.order_id
-- left join
-- (
--     select first_active_date,user_pseudo_id
--     from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
--     where event_date_hk = '2024-01-01'
-- ) b
-- on a.user_pseudo_id=b.user_pseudo_id
left join
(
    SELECT uuid
          ,min(event_date_hk) as Attributed_Touch_Date
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where app_name in ('BeautyPlus') and is_new = 1 -- 限制新增用户
    group by 1
) c
on f.uuid=c.uuid

;


select platform
       ,case when first_active_days<=30 then '0-30days' when first_active_days>30 then '30+days' end type1
       ,case when install_days<=30 then '0-30days' else '30+days' end type2
       ,category1
       ,count(distinct original_order_id) users
       ,count(distinct order_id) orders
from `dataintegration-265403.temp.temp_first_install_day_to_sub`
group by 1,2,3,4

select date_trunc(date,month)  event_month
       ,platform
       ,category1
       ,count(distinct case when install_days<=30 then original_order_id end) users_0_30
       ,count(distinct original_order_id) users
from `dataintegration-265403.temp.temp_first_install_day_to_sub`
group by 1,2,3

-- select platform
--        ,date_diff(date,order_start_date,day) order_to_paid_days
--        ,count(distinct original_order_id) users
--        ,count(distinct order_id) orders
-- from `dataintegration-265403.temp.temp_first_install_day_to_sub`
-- group by 1,2


-- select *
-- from `dataintegration-265403.temp.temp_first_install_day_to_sub`
-- where user_pseudo_id is null
--
-- select *
-- from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) a
-- where date >= '2024-07-01'
--     and event_name in ('subscription_try_suc')
--     and order_id=''


-- 实验周期选择：最好选择较为稳定的一段时间，不要从最开始取
-- 修改实验abcode：批量替换 '28450','28451','28452'
-- 部分参数修改：84-86有一些样本量级的参数限制，可以修改
DECLARE mDATE_ABTEST_START DATE DEFAULT '2025-11-14';
DECLARE mDATE_ABTEST_END DATE DEFAULT '2025-12-03';

-- step1：计算留存率
WITH enter_pre AS (
    SELECT
        DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp), 'Asia/Singapore') AS enter_abtest_date,  -- 进入实验日期
        user_pseudo_id,
        geo.country AS country,
        platform,
        func.getUserprop(user_properties, 'device_id').string_value AS device_id,
        func.getParams(event_params, 'current_abcode').string_value AS abcode,
       event_timestamp
 FROM `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_ABTEST_START as string),cast(mDATE_ABTEST_END as string),'airbrush', false) -- 此处用false 速度会更快
    WHERE event_name = 'abcode_enter_test'
        AND func.getParams(event_params, 'current_abcode').string_value IN ('28450','28451','28452')
    )
,act as (
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 365 day)
        and  app_name = 'AirBrush'
)
,enter as (
    select *
    from
    (
        select
            e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.is_new enter_new
            ,row_number() over(partition by e.user_pseudo_id order by event_timestamp) ranks
        from  act fa
        join
           enter_pre e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
--         and enter_new=1
)
,rs AS (
    -- 取活跃用户中有进入实验的用户
    select
        fa.*
        ,e.abcode,e.enter_abtest_date,e.enter_new
    from  act fa
    join
       enter e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date <= fa.event_date_hk
    where e.user_pseudo_id is not null

)

select
    a.enter_abtest_date,
    b.active_date,
    a.abcode,
    b.lcx,
    b.week_day,
    a.control_active0,
    b.control_activex,
    round(control_activex/control_active0,4) retention_rate
from
(
    select
        enter_abtest_date,
        abcode,
        platform,
        COUNT(DISTINCT user_pseudo_id) AS control_active0
    from enter
    group by 1,2,3
) a
join
(
    SELECT
        enter_abtest_date,
        event_date_hk active_date,
        abcode,
        platform,
        date_diff(event_date_hk,enter_abtest_date,day) lcx,
        MOD(EXTRACT(DAYOFWEEK FROM event_date_hk) + 5, 7) + 1 week_day,
        COUNT(DISTINCT user_pseudo_id) AS control_activex
    FROM rs
    GROUP BY 1,2,3,4,5,6
) b
on a.enter_abtest_date=b.enter_abtest_date and a.abcode=b.abcode and a.platform=b.platform
where control_active0>1000  -- 进入实验过少的天数过滤(可调整)
    and control_activex>100  --过滤样本量太小的行数(可调整)
    and lcx>0 --and lcx<=31 --过滤样本量太小的天数(可调整)
ORDER BY 3,1,2,4
;





-- step2:计算对照组单用户价值(包括订阅+广告),取实验期间（考虑到存在7天试用，多算7天）
drop table if exists `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau`;
create table if not exists `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` as
with enter_pre as (
select
    distinct
    date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date
    ,user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
   ,event_timestamp
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_ABTEST_START as string),cast(mDATE_ABTEST_END as string),'airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('28450','28451','28452')
--     and _table_suffix between date_sub(mDATE_ABTEST_SRART,interval 1 day) and date_add(mDATE_ABTEST_END,interval 1 day)
--     and date(timestamp_micros(event_timestamp),'Asia/Singapore') between mDATE_ABTEST_START and mDATE_ABTEST_END
)
,act as (
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between mDATE_ABTEST_START and mDATE_ABTEST_END
        and  app_name = 'AirBrush'
)

-- 进入实验且当天活跃
select *
from
(
    select
        e.device_id,e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.uuid,fa.is_new enter_new
        ,row_number() over(partition by e.device_id order by event_timestamp) ranks
    from  act fa
    join
       enter_pre e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
    where e.user_pseudo_id is not null
)
where ranks=1
--   and enter_new=1
;

with
act as (
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 7 day)
        and  app_name = 'AirBrush'
)
,active_ab AS (
    -- 取活跃用户中有进入实验的用户
    select
        fa.*
        ,e.abcode,e.enter_abtest_date
    from  act fa
    join
       (select user_pseudo_id,abcode,min(enter_abtest_date) enter_abtest_date from `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` group by 1,2) e
    ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date <= fa.event_date_hk
    where e.user_pseudo_id is not null
)
,paid as (
    -- 付费表
    select
        standard_order_date,uuid,original_order_id,order_id,sku,order_status,payment_price_usd
--         ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
--         ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 7 day)
    and order_status in (0,1,2)
)
,paid_ab as (
    -- 取进入实验的用户在进入后每天的付费情况
    select
        pa.*
        ,e.abcode,e.enter_abtest_date
    from  paid pa
    join
--        `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` e
       (select uuid,abcode,min(enter_abtest_date) enter_abtest_date from `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` group by 1,2) e
    ON e.uuid = pa.uuid and e.enter_abtest_date <= pa.standard_order_date
    where e.uuid is not null
)
,ads as (
    select
        event_date
        ,user_pseudo_id
        ,platform
        ,sum(max_impression_pv) max_impression_pv
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
    and event_date between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 7 day)
   group by 1,2,3
)
,ads_ab as (
    -- 取进入实验的用户在进入后每天的付费情况
    select
        ad.*
        ,e.abcode,e.enter_abtest_date
    from  ads ad
    join
--        `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` e
       (select user_pseudo_id,abcode,min(enter_abtest_date) enter_abtest_date from `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` group by 1,2) e
    ON e.user_pseudo_id = ad.user_pseudo_id and e.enter_abtest_date <= ad.event_date
    where e.user_pseudo_id is not null
)

select abcode,sum(active_users) active_dau
     ,sum(sub_bookings)+sum(ad_bookings) bookings
     ,round((sum(sub_bookings)+sum(ad_bookings))/sum(active_users),4) arpdau
from
(
    SELECT
        event_date_hk date,
        abcode,
        COUNT(DISTINCT user_pseudo_id) AS active_users,
        0.0 sub_bookings,
        0.0 ad_bookings
    FROM active_ab
    GROUP BY 1,2

    union all

    SELECT
        standard_order_date date,
        abcode,
        0 AS active_users,
        sum(payment_price_usd) sub_bookings,
        0.0 ad_bookings
    FROM paid_ab
    GROUP BY 1,2

    union all

    SELECT
        event_date date,
        abcode,
        0 AS active_users,
        0.0 sub_bookings,
        sum(max_revenue) ad_bookings
    FROM ads_ab
    GROUP BY 1,2
)
GROUP BY 1
ORDER BY 1
;




-- step3:计算推全的影响
with
act as (
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between mDATE_ABTEST_START and mDATE_ABTEST_END
        and  app_name = 'AirBrush'
)
,active_ab AS (
    -- 取活跃用户中有进入实验的用户
    select
        fa.*
        ,e.abcode,e.enter_abtest_date
    from  act fa
    join
       `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` e
    ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date <= fa.event_date_hk
    where e.user_pseudo_id is not null
)

select
    b.abcode
    ,sum(abtest_dau)/sum(dau) abtest_ratio
from
(
    select
        platform,
        COUNT(DISTINCT user_pseudo_id) AS dau
    from act
    group by 1
) a
join
-- cross join
(
    SELECT
        platform,
        abcode,
        COUNT(DISTINCT user_pseudo_id) AS abtest_dau
    FROM active_ab
    GROUP BY 1,2
) b
on a.platform=b.platform
group by 1
order by 1
;
-- YAU
select platform
    ,count(distinct user_pseudo_id) YAU
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
where
    event_date_hk between date_sub(mDATE_ABTEST_END,interval 365 day) and mDATE_ABTEST_END
    and  app_name = 'AirBrush'
group by 1
;




-- step4:计算每天的新增收入的增量
with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'SKU').string_value sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'current_abcode').string_value  abcode
from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_ABTEST_START as string),cast(mDATE_ABTEST_END as string),'airbrush',false)
where
    event_name in ('w_subscription_success')
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(abcode),b.abcode,b.enter_abtest_date
    from eves a
    join `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` b
    on a.device_id= b.device_id
    where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,paid as (
    select
        standard_order_date,original_order_id,order_id,sku,subscription_period,order_status,payment_price_usd
        ,lead(standard_order_date) over(partition by original_order_id,sku order by standard_order_date) next_standard_order_date
        ,lead(payment_price_usd) over(partition by original_order_id,sku order by standard_order_date) next_payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where app_id ='AirBrush'
    and standard_order_date between mDATE_ABTEST_START and date_add(mDATE_ABTEST_END,interval 14 day)
        and order_status in (0,1,2)
)
,ads as (
    select
        event_date
        ,user_pseudo_id
        ,platform
        ,sum(max_impression_pv) max_impression_pv
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
    and event_date between mDATE_ABTEST_START and mDATE_ABTEST_END
   group by 1,2,3
)
,ads_ab as (
    -- 取进入实验的用户在进入后每天的付费情况
    select
        ad.*
        ,e.abcode,e.enter_abtest_date
    from  ads ad
    join
       (select user_pseudo_id,abcode,min(enter_abtest_date) enter_abtest_date from `dataintegration-265403.temp.dau_and_bookings_predict_365_enter_abtest_dau` group by 1,2) e
    ON e.user_pseudo_id = ad.user_pseudo_id and e.enter_abtest_date <= ad.event_date
    where e.user_pseudo_id is not null
)

select * from
(
    select
        abcode
        ,standard_order_date date
        ,subscription_period types
--         ,count(distinct device_id) sub_success_uv
--         ,count(distinct case when order_status in (1,2) then device_id
--                     when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
        ,sum(case when order_status in (1,2) then payment_price_usd
            when order_status= 0 and next_standard_order_date is not null then next_payment_price_usd
            else 0 end) gmv
    from
    (
        select
            a.enter_abtest_date,a.abcode,a.device_id
            ,b.standard_order_date,b.original_order_id,b.sku,b.order_status,b.subscription_period
            ,b.payment_price_usd
            ,next_standard_order_date
            ,next_payment_price_usd
        from fe a
        join paid b on a.order_id = b.order_id and a.sku = b.sku
    )
    group by 1,2,3

    union all

    select
        abcode
        ,event_date date
        ,'ads' types
--         ,count(distinct device_id) sub_success_uv
--         ,count(distinct case when order_status in (1,2) then device_id
--                     when order_status= 0 and next_standard_order_date is not null then device_id end) sub_success_to_paid_uv
        ,sum(max_revenue) gmv
    from ads_ab
    group by 1,2,3
)
order by 1,2,3

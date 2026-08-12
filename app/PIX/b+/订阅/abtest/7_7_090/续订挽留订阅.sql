-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
with
abcode as
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as device_id
    , country_id
    , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        date_p>='2024-04-23' and date_p<='2024-05-29'
        and cast(ab_code as string) in ('10645','10646',
                                        '10647','10648')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
-- 进入实验的用户：是否订阅中，是否订阅取消，什么时候到期
sub_status as
(
    select g.*
      ,case when coalesce(s.uuid,sp.uuid) is null then 'past no order'
            when coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) is null then 'now no sub'
            when coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) is not null then 'now sub'
      end before_sub_types
      , coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) current_sub_sku_type
      , coalesce(s.is_current_subscription_cancelled,sp.is_current_subscription_cancelled) is_current_subscription_cancelled
      , coalesce(s.current_subscription_expired_day,sp.current_subscription_expired_day) current_subscription_expired_day
      , date_add(g.date_p,interval coalesce(s.current_subscription_expired_day,sp.current_subscription_expired_day) day) current_subscription_expired_date
    from
    (
        select distinct date_p, code, device_id, platform, timestamp, m.uuid
        from abcode a
        join `dataintegration-265403.stat.dmi_dz_idmapping` m
        on a.device_id=m.key
    ) g
    left join
    (
        select event_date_hk, uuid, current_sub_sku_type, is_current_subscription_cancelled, current_subscription_expired_day
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
        where event_date_hk between '2024-04-23' and '2024-05-29'
        and app_id in ('BeautyPlus')
    ) s
    on g.uuid=s.uuid and g.date_p = s.event_date_hk
    left join
    (
        select event_date_hk, uuid, current_sub_sku_type, is_current_subscription_cancelled, current_subscription_expired_day
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
        where event_date_hk between '2024-04-24' and '2024-05-30'
        and app_id in ('BeautyPlus')
    ) sp
    on g.uuid=sp.uuid and g.date_p = date_sub(sp.event_date_hk,interval 1 day)
)
,
subscription_event as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
--         date>='2023-11-17' and date<='2023-12-08' --ios时间
        date>='2024-04-23' --and date<='2024-05-29'
        and device_id is not null
        -- and source2<>'OnboardingPage'
)
,
ab_sub_event as
(
select distinct
    a.date,
--     case when date_diff(current_subscription_expired_date,a.date,DAY)>0 then 'pre'
--           when date_diff(current_subscription_expired_date,a.date,DAY)<=0 then 'af'
--     end if_expired,
    case when date_diff(a.date,u.current_subscription_expired_date,DAY) < 0 then '0:pre'
            when date_diff(a.date,u.current_subscription_expired_date,DAY) between 0 and 1 then '1:renewal'
--             when date_diff(a.date,u.current_subscription_expired_date,DAY) between 2 and 30 then '2:af_2_30'
--             when date_diff(a.date,u.current_subscription_expired_date,DAY) between 31 and 90 then '3:af_31_90'
--             when date_diff(a.date,u.current_subscription_expired_date,DAY) >= 91 then '4:af_91+'
            when date_diff(a.date,u.current_subscription_expired_date,DAY) >= 2 then '2:af'
      end current_status,
    current_sub_sku_type before_expired_sub_type,
    before_sub_types,
    a.platform,
    a.country,
    case when a.country in ('South Korea','Thailand','Japan','United States') then a.country else 'WW' end as region,
    case
       when u.code in ('10645','10647') then '对照组'
       when u.code in ('10646','10648') then '实验组'
    end as code,
    case when source2 in ('月续订取消挽留弹窗-月优惠','月续订取消挽留弹窗-年优惠','年续订取消挽留弹窗-折扣','年续订取消挽留弹窗-无折扣') then '续订挽留'
      else '其他'
      end source,
    case when source2 in ('月续订取消挽留弹窗-月优惠','月续订取消挽留弹窗-年优惠','年续订取消挽留弹窗-折扣','年续订取消挽留弹窗-无折扣') then source2
      else '其他'
      end source_detail,
    a.sku_type,
    a.sku_has_trial,
    a.sku,
    a.sku_tag,
--     t.sub_user_type,
    a.event_name,
    source2,
    -- a.category1,
--     u.is_new,
    a.user_pseudo_id,
    a.device_id,
    new_uuid,
    a.payment_price_usd,
    purchase_date,
    standard_order_date,
    cur_page_type,
    a.timestamp
    from
        (SELECT
            distinct
            date,
            event_timestamp timestamp,
            device_id,
            platform,
            country,
            sku_type,
            sku_has_trial,
            sku,
            sku_tag,
            sub_user_type,
            payment_price_usd,
            event_name,
            source2,
            -- s.category1,
--             s.category2,
            user_pseudo_id,
            new_uuid,
            purchase_date,
            standard_order_date,
            cur_page_type

        FROM
            subscription_event --,unnest(agg) as s

            )a
    --关联实验时机
    join sub_status u
    on a.device_id=u.device_id  and a.timestamp>=u.timestamp-15000000
)
,
real_bookings as
(
    select  standard_order_date
--       ,case when date_diff(current_subscription_expired_date,a.standard_order_date,DAY)>0 then 'pre'
--             when date_diff(current_subscription_expired_date,a.standard_order_date,DAY)<=0 then 'af'
--       end if_expired
      ,case when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) < 0 then '0:pre'
            when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) between 0 and 1 then '1:renewal'
--             when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) between 2 and 30 then '2:af_2_30'
--             when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) between 31 and 90 then '3:af_31_90'
--             when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) >= 91 then '4:af_91+'
            when date_diff(a.standard_order_date,u.current_subscription_expired_date,DAY) >= 2 then '2:af'
      end current_status
      ,subscription_period,sku_is_trial,order_status,payment_price_usd,a.platform,a.offer_method
      ,case
           when u.code in ('10645','10647') then '对照组'
           when u.code in ('10646','10648') then '实验组'
        end as code
      ,u.before_sub_types
      ,u.current_sub_sku_type before_expired_sub_type
      ,u.device_id,u.uuid
    from
    (
        select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date >= '2024-04-23'
            and order_status not in (0)
        and app_id='BeautyPlus'
            -- and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
            -- and offer_method = 'normal'
    ) a
    join
    (
        select uuid
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date >= '2024-04-23'
        and app_id='BeautyPlus'
        group by uuid
        having count(1)<=20
    ) r on a.uuid=r.uuid
    join sub_status u
    on a.standard_order_date>=u.date_p and a.uuid=u.uuid
)
,
event_all as
(
    select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `beautyplus-bc0ed.temp.temp_renewal_retain_abtest_event`
    where app_name in ('BeautyPlus')
        and event_date>='2024-04-23' and event_date<='2024-05-29'
--         and cast(meepo_abcode as string) in ('10645','10646',
--                                         '10647','10648')
        and device_id is not null --limit 100
)
,
event_ab as
(
    select m.*
        ,a.code
--         ,case when date_diff(current_subscription_expired_date,m.event_date,DAY)>0 then 'pre'
--               when date_diff(current_subscription_expired_date,m.event_date,DAY)<=0 then 'af'
--         end if_expired
        ,case when date_diff(m.event_date,current_subscription_expired_date,DAY) < 0 then '0:pre'
                when date_diff(m.event_date,current_subscription_expired_date,DAY) between 0 and 1 then '1:renewal'
--                 when date_diff(m.event_date,current_subscription_expired_date,DAY) between 2 and 30 then '2:af_2_30'
--                 when date_diff(m.event_date,current_subscription_expired_date,DAY) between 31 and 90 then '3:af_31_90'
--                 when date_diff(m.event_date,current_subscription_expired_date,DAY) >= 91 then '4:af_91+'
                when date_diff(m.event_date,current_subscription_expired_date,DAY) >= 2 then '2:af'
        end current_status
        ,current_sub_sku_type before_expired_sub_type
        ,before_sub_types
        ,case
        when a.code in ('10645','10647') then '对照组'
        when a.code in ('10646','10648') then '实验组'
        end as code_type
--         ,a.is_new
    from
    (
        select event_date
            ,event_timestamp
            ,platform
            ,country
            ,case when country in ('South Korea','Thailand','Japan','United States') then country else 'WW' end as region
            ,event_name
            ,coalesce(cast(func.getParams(event_params,'pop_type').int_value as string),func.getParams(event_params,'pop_type').string_value) as pop_type
            ,user_pseudo_id
            ,device_id
        from event_all
--         where event_name in  ('renewal_retain_pop_appr_bd','renewal_retain_pop_clk_bd')
        where event_name = 'renewal_retain_pop_appr_bd'
            or (event_name = 'renewal_retain_pop_clk_bd' and func.getParams(event_params,'type').string_value='accept')
    ) m
    join sub_status a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
)
,
final_sub_event as
(
    select date,current_status,event_name,platform,code,source,source_detail,sku_type,sku_has_trial,before_sub_types,device_id,before_expired_sub_type
    from ab_sub_event

    union all

    select event_date date,current_status
           ,case when event_name = 'renewal_retain_pop_appr_bd' then 'page_event'
                 when event_name = 'renewal_retain_pop_clk_bd' then 'subscription_clk_try'
           end event_name
           ,platform,code_type code
           ,'续订挽留' source
           ,case when pop_type in ('1','2') then '月续订取消挽留弹窗-月优惠'
                 when pop_type in ('3') then '年续订取消挽留弹窗-折扣'
                 when pop_type in ('4') then '年续订取消挽留弹窗-无折扣'
            end source_detail
           ,case when pop_type in ('1','2') then '1-month' else '1-year' end sku_type
           ,cast(null as string) sku_has_trial
           ,before_sub_types,device_id,before_expired_sub_type
    from event_ab
)

select  current_status,case when  event_name in ('page_event') then '1:sub enter uv'
    when  event_name in ('subscription_clk_try') then '2:sub click uv'
    else event_name end as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
    ,source
    ,case when sku_type='12m' then '1-year'
          when sku_type='1m' then '1-month'
    else sku_type
    end sku_type
    ,sku_has_trial
--     ,sku
--     ,sku_tag
--     ,sub_user_type
    ,before_expired_sub_type
--     ,before_sub_types
--     ,-999 order_status
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  final_sub_event a
where
    event_name not in ('subscription_try_suc')
--     and platform='IOS'
--     and platform='ANDROID'
    group by 1,2,3,4,5,6,7,8

union all

select  current_status,'3:sub_success uv' as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
    ,source
    ,case when sku_type='12m' then '1-year'
          when sku_type='1m' then '1-month'
    else sku_type
    end sku_type
    ,sku_has_trial
--     ,sku
--     ,sku_tag
--     ,sub_user_type
    ,before_expired_sub_type
--     ,before_sub_types
--     ,-999 order_status
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  final_sub_event a
where event_name in ('subscription_try_suc')
--     and standard_order_date is not null
--     and platform='IOS'
--     and platform='ANDROID'
group by 1,2,3,4,5,6,7,8

-- union all
--
-- select  if_expired,'4:sub_success_to_paid uv' as event_name
--     ,a.platform
-- --     ,a.region
--     -- ,is_new
--     ,code
--     ,source
--     ,sku_type
--     ,sku_has_trial
-- --     ,sku
-- --     ,sku_tag
-- --     ,sub_user_type
--     ,before_expired_sub_type
--     ,-999 order_status
--     ,count(distinct a.device_id) value
--     ,count(1) pv
-- from
--   ab_sub_event a
-- where standard_order_date is not null and purchase_date is not null
-- and event_name in ('subscription_try_suc')
-- --     and platform='IOS'
-- --     and platform='ANDROID'
--     group by 1,2,3,4,5,6,7,8,9
--
-- union all
--
-- select  if_expired,'5:sub_success_to_paid revenue' as event_name
--     ,a.platform
-- --     ,a.region
--     -- ,is_new
--     ,code
--     ,source
--     ,sku_type
--     ,sku_has_trial
-- --     ,sku
-- --     ,sku_tag
-- --     ,sub_user_type
--     ,before_expired_sub_type
--     ,-999 order_status
--     ,round(sum(payment_price_usd),2) value
--     ,count(1) pv
-- from
--   ab_sub_event a
-- where standard_order_date is not null and purchase_date is not null
-- and event_name in ('subscription_try_suc')
-- --     and platform='IOS'
-- --     and platform='ANDROID'
--     group by 1,2,3,4,5,6,7,8,9

union all

select
--     standard_order_date date
    current_status
    ,'5:real_pay_users' event_name
    ,a.platform
--     ,null region
    -- ,a.is_new
    ,a.code
    ,'null' source
    ,subscription_period sku_type
    ,sku_is_trial sku_has_trial
--     ,null sku
--     ,'null' sku_tag
--     ,null sub_user_type
    ,before_expired_sub_type
--     ,before_sub_types
--     ,order_status
    ,count(distinct a.device_id) value
    ,count(1) pv
from real_bookings a
group by 1,2,3,4,5,6,7,8

union all

select
--     standard_order_date date
    current_status
    ,'6:real_bookings' event_name
    ,a.platform
--     ,null region
    -- ,a.is_new
    ,a.code
    ,'null' source
    ,subscription_period sku_type
    ,sku_is_trial sku_has_trial
--     ,null sku
--     ,'null' sku_tag
--     ,null sub_user_type
    ,before_expired_sub_type
--     ,before_sub_types
--     ,order_status
    ,round(sum(payment_price_usd),2) value
    ,count(1) pv
from real_bookings a
group by 1,2,3,4,5,6,7,8

union all

select
--     date_p date
    'pre' if_expired
    ,'0:enter_ab_test' event_name
    ,a.platform
--     ,null region
    -- ,a.is_new
    ,case when a.code in ('10645','10647') then '对照组'
        when a.code in ('10646','10648') then '实验组'
    end as code
    ,'null' source
    ,'null' sku_type
    ,'null' sku_has_trial
--     ,null sku
--     ,'null' sku_tag
--     ,null sub_user_type
    ,current_sub_sku_type before_expired_sub_type
--     ,before_sub_types
--     ,-999 order_status
    ,count(distinct a.device_id) value
    ,count(1) pv
from sub_status a
group by 1,2,3,4,5,6,7,8

;


-- select  case
--     when  event_name in ('page_event') then '1:sub enter uv'
--     when  event_name in ('subscription_clk_try') then '2:sub click uv'
--     when event_name in ('subscription_try_suc') then '3:sub_success uv'
--     end as event_name
--     ,a.platform
-- --     ,a.region
--     -- ,is_new
--     ,code
--     ,source_detail
--     ,case when sku_type='12m' then '1-year'
--           when sku_type='1m' then '1-month'
--     else sku_type
--     end sku_type
--     ,sku_has_trial
-- --     ,sku
-- --     ,sku_tag
-- --     ,sub_user_type
-- --     ,before_expired_sub_type
-- --     ,before_sub_types
-- --     ,-999 order_status
--     ,count(distinct a.device_id) value
--     ,count(1) pv
-- from
--   final_sub_event a
-- group by 1,2,3,4,5,6





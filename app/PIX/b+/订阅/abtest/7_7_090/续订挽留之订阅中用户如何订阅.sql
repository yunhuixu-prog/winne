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
    select g.*,s.current_sub_sku_type, s.is_current_subscription_cancelled, s.current_subscription_expired_day
      , date_add(g.date_p,interval current_subscription_expired_day day) current_subscription_expired_date
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
    on g.uuid=s.uuid and g.date_p=s.event_date_hk
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
    case when date_diff(current_subscription_expired_date,a.date,DAY)>0 then 'pre'
          when date_diff(current_subscription_expired_date,a.date,DAY)<=0 then 'af'
    end if_expired,
    current_subscription_expired_date,
    current_sub_sku_type before_expired_sub_type,
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

select  *
from
  ab_sub_event a
where
    event_name in ('subscription_try_suc')
    and if_expired='pre'
limit 100



-- 查询订阅事件
select event_date,event_timestamp,event_name,event_params
      ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value hwgid
      ,`dataintegration-265403.func`.getUserprop(user_properties,'original_order_id').string_value original_order_id
      ,`dataintegration-265403.func`.getUserprop(user_properties,'device_id').string_value device_id
      ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
from
      `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-09', '2024-05-09', 'beautyplus', false)
where user_pseudo_id='28DBEAEED4FA4D318CE77DA659E778B5'
and event_name in ('subscription_clk_try','subscription_try_suc','renewal_retain_pop_appr_bd','renewal_retain_pop_clk_bd')
order by 2

-- 查询订单
select  order_date,subscription_period,order_status,payment_price_usd
  ,standard_order_date,standard_order_expire_date,subscription_user_type,standard_insert_date
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2023-01-01' and '2024-09-30'
  -- and order_status in (0,1,2)
  and app_id='BeautyPlus'
  -- and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
  -- and offer_method = 'normal'
  and uuid='625825874'
order by order_date


select *
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-04-23' and '2024-09-01'
and app_id in ('BeautyPlus')
and uuid='625825874'
order by event_date_hk
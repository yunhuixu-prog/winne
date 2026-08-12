
-- dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v

with  new_sub as (
SELECT
 -- DISTINCT
  'subscription' as product,
  a.app_id,
  a.standard_order_date,
  a.subscription_period,
  a.original_order_id,
  a.order_id,
  a.platform,
  a.standard_order_expire_date,
  a.order_status,
  a.payment_price_usd,
  a.sku,
  a.sku_is_trial,
  a.range_group,
  --a.subscribe_grp,
  a.pre_order_expire_date,
  a.offer_params, --参数
  a.offer_method,
  a.subscription_user_type,
  a.uuid,
  --b.Country_Code,
  a.country ,a.is_UA,
 -- b.Media_Source,
  --b.Campaign,
  --b.Keywords,
 -- b.Site_ID,
  --b.IOS_OS_Version,
  b.event_date AS Attributed_Touch_Time
FROM
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
JOIN
 (
    -- 新增表
        select
           app_name,platform,
           case when country='Türkiye' then 'Turkey' else country end as country,is_UA,uuid --,appsflyer_id
           ,min(event_date_hk) event_date

          --from `dataintegration-265403.subscription.dws_act_subscription_preprocess`
          from `dataintegration-265403.stat.stat_active_advice_detail_d`
          where
              is_new = 1 -- 限制新增用户
              and event_date_hk >= '2020-08-01'

        group by  app_name,platform,country,is_UA,uuid

 )  b on a.app_id = b.app_name and a.platform = b.platform and a.uuid = b.uuid and a.is_UA = b.is_UA
            and coalesce(a.country,'-') = coalesce(b.country,'-')
WHERE
  a.standard_order_date>=b.event_date

  union all
  SELECT
  'consumables' as product,
  a.app_id,
  a.standard_order_date,
  'consumables' subscription_period,
  a.original_order_id,
  a.order_id,
  a.platform,
  a.standard_order_expire_date,
  a.order_status,
  a.payment_price_usd,
  a.sku,
  'no_trial' as sku_is_trial,
  null as range_group,
  --a.subscribe_grp,
  null as pre_order_expire_date,
  null as offer_params, --参数
  null as offer_method,
  null as subscription_user_type,
  a.uuid,
  --b.Country_Code,
  a.country ,a.is_UA,
 -- b.Media_Source,
  --b.Campaign,
  --b.Keywords,
 -- b.Site_ID,
  --b.IOS_OS_Version,
  b.event_date AS Attributed_Touch_Time
FROM
`dataintegration-265403.purchase.dwd_da_purchase_daily` a
JOIN
 (
    -- 新增表
        select
           app_name,platform,
           case when country='Türkiye' then 'Turkey' else country end as country,is_UA,uuid --,appsflyer_id
           ,min(event_date_hk) event_date

          --from `dataintegration-265403.subscription.dws_act_subscription_preprocess`
          from `dataintegration-265403.stat.stat_active_advice_detail_d`
          where
              is_new = 1 -- 限制新增用户
              and event_date_hk >= '2020-08-01'

        group by  app_name,platform,country,is_UA,uuid

 )  b on a.app_id = b.app_name and a.platform = b.platform and a.uuid = b.uuid and a.is_UA = b.is_UA
            and coalesce(a.country,'-') = coalesce(b.country,'-')
WHERE
  a.standard_order_date>=b.event_date


),
new_was_sub as (
select   -- 新增时，有一个订阅有效期内的付费，且没有退款，剔除这部分用户
distinct b.original_order_id
--b.app_id,a.platform,a.original_order_id,a.Attributed_Touch_Date,a.order_id,a.standard_order_date,a.standard_order_expire_date,a.order_status
 from
 (
     select
     a.app_id,a.platform,a.original_order_id,a.Attributed_Touch_Date,a.order_id,a.standard_order_date,a.standard_order_expire_date,a.order_status,a.num
     from
      (
      SELECT distinct
      app_id,
      platform,
      original_order_id,
      EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" )  as Attributed_Touch_Date,
      order_id,
      standard_order_date,
      standard_order_expire_date,
      order_status,
      ROW_NUMBER() OVER(partition by app_id,platform,original_order_id,EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" ) ORDER BY standard_order_date desc) AS num
      FROM `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
      WHERE standard_order_date >= "2020-08-01"--and  standard_order_date <= "2022-05-20"
      and order_status >=0 and order_status <=2
      -- 新增时，有一个订阅有效期内的付费
      and standard_order_date < EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" )
      and EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" ) < standard_order_expire_date
      )a
    where a.num=1   -- 用户首次
 )b
 where concat(b.app_id,'-',b.platform,'-',b.original_order_id,'-',b.order_id,'-',b.Attributed_Touch_Date) not  in (
 select concat(c.app_id,'-',c.platform,'-',c.original_order_id,'-',c.order_id,'-',c.Attributed_Touch_Date) from
 (
 select distinct app_id,
      platform,
      original_order_id,
      EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" )  as Attributed_Touch_Date,
      order_id,
      standard_order_date,
      standard_order_expire_date
  from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
  WHERE standard_order_date >= "2020-08-01"--and  standard_order_date <= "2022-05-20"
  and order_status =3
  and standard_order_date < EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" )
  and EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" ) < standard_order_expire_date
  )c
 --on c.app_id=b.app_id and c.platform=b.platform and c.original_order_id=b.original_order_id and c.order_id=b.order_id and c.Attributed_Touch_Date=b.Attributed_Touch_Date
 )

--and b.original_order_id in ('GPA.3338-8280-0912-03189')

)
SELECT
  app_id,
  platform,
  country, is_UA, uuid,
  Attributed_Touch_Time,
  original_order_id,
  order_id,
--   range_group,
  standard_order_date,
  standard_order_expire_date,
--   sku,
  subscription_period,
  sku_is_trial,--add
  payment_price_usd,
--   offer_method,
--   offer_params,
  order_status,
--   subscription_user_type,
  product,
--   case when  offer_method in ('trial mix pay up front','trial mix pay as as go') then concat( offer_method, order_status)
--   else offer_method end as offer_mark,
--   ROW_NUMBER() OVER(partition by app_id,platform,original_order_id ORDER BY standard_order_date) AS num
FROM
  new_sub
WHERE
   order_status>=0 and  order_status<=2
   and original_order_id not in (select original_order_id from new_was_sub)--剔除触发归因前已经是在订阅状态
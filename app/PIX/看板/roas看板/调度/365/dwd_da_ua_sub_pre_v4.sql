

delete from `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4`
with  ua_sub as (

SELECT
 -- DISTINCT
  'subscription' as product,
  a.app_id,
  a.order_date,
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
  b.AppsFlyer_ID,
  b.Country_Code,
  a.country ,
  b.Media_Source,
  b.Campaign,
  b.Keywords,
  b.Site_ID,
  b.IOS_OS_Version,
  b.Attributed_Touch_Date_hk AS Attributed_Touch_Time,
  b.Campaign_ID,---update by zxy 23/02/08
  cast(b.Keyword_ID as string) as Keyword_ID,
  b.Ad_Group,
  b.Ad_Group_ID
FROM
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
JOIN
   `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`  b
ON
  a.app_id=b.App_Name
  AND a.platform=UPPER(b.Platform)
  AND a.AppsFlyer_ID=b.AppsFlyer_ID
WHERE
  a.standard_order_date>=b.Attributed_Touch_Date
  AND is_ua IN ('non-Organic')
  AND b.Attributed_Touch_Date_hk>='2020-08-01'
  and subscription_period not in ('inapp')

  union all

  SELECT
 -- DISTINCT
  'consumables' as product,
  a.app_id,
  a.order_date,
  a.standard_order_date,
  'consumables' as subscription_period,
  a.original_order_id,
  a.order_id,
  a.platform,
  a.standard_order_expire_date,
  a.order_status,
  a.payment_price_usd,
  a.sku,
  'no_trial' as sku_is_trial,
  null as range_group,
  null as pre_order_expire_date,
  null as offer_params, --参数
  null as offer_method,
  null as subscription_user_type,
  b.AppsFlyer_ID,
  b.Country_Code,
  a.country ,
  b.Media_Source,
  b.Campaign,
  b.Keywords,
  b.Site_ID,
  b.IOS_OS_Version,
  b.Attributed_Touch_Date_hk AS Attributed_Touch_Time,
  b.Campaign_ID,---update by zxy 23/02/08
  cast(b.Keyword_ID as string) as Keyword_ID,
  b.Ad_Group,
  b.Ad_Group_ID
FROM
 `dataintegration-265403.purchase.dwd_da_purchase_daily` a
JOIN
   `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`  b
ON
  a.app_id=b.App_Name
  AND a.platform=UPPER(b.Platform)
  AND a.AppsFlyer_ID=b.AppsFlyer_ID
WHERE
  a.standard_order_date>=b.Attributed_Touch_Date
  AND is_ua IN ('non-Organic')
  AND b.Attributed_Touch_Date_hk>='2023-07-01'

),
ua_was_sub as (
select
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
      and is_ua in ('non-Organic')
      and standard_order_date < EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" )
      and EXTRACT(DATE FROM Attributed_Touch_Time AT TIME ZONE "UTC+8" ) < standard_order_expire_date
      )a
    where a.num=1
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
  and is_ua in ('non-Organic')
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
  country,
  Media_Source,
  Campaign,
  Keywords,--add
  Site_ID,
  IOS_OS_Version,--add
  Attributed_Touch_Time,
  original_order_id,
  order_id,
  range_group,
  standard_order_date,
  standard_order_expire_date,
  sku,
  subscription_period,
  sku_is_trial,--add
  payment_price_usd,
  offer_method,
  offer_params,
  order_status,
  subscription_user_type,
  case when  offer_method like '%mix%'--in ('trial mix pay up front','trial mix pay as as go')
  then concat( offer_method, order_status)
  else offer_method end as offer_mark,
  ROW_NUMBER() OVER(partition by app_id,platform,original_order_id ORDER BY order_date) AS num,--按订单时间戳排序
  Campaign_ID,--update by zxy 23/02/08
  Keyword_ID,
  Ad_Group,
  Ad_Group_ID,
  product
FROM
  ua_sub
WHERE
   order_status>=0 and  order_status<=2
   and original_order_id not in (select original_order_id from ua_was_sub)--剔除触发归因前已经是在订阅状态
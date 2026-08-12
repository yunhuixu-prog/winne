--结果表加金额
--SELECT  FROM `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription` LIMIT 1000
delete from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription`  where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=30)).strftime("%Y-%m-%d") }}' ;

insert into `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription`
with 
content_id as 
(
SELECT date, CAST(module_type AS STRING) as category2 , --1-轮播图，2-素材，3-banner
CAST(module_id AS STRING) as module_id, content_id, module_title as content_title, country as content_country
FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_home_media`  
union all
-- change HPP to POP by ethan 20211230
SELECT date, case when theme in ('启动页') then 'LBD'else 'POP' end as category2, id as module_id, '0' as content_id,title as content_title, country as content_country 
FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert` a

),
--为了弥补维表缺失日期，id匹配为空的情况，新创建一个没有日期的维表用于匹配，对于同一个id对应两个及以上内容时，取最近的一个内容 2022-04-18
content_id_2 as 
(  
  select distinct a.id as module_id, '0' as content_id,title as content_title, country as content_country 
   FROM 
   (
        SELECT
        *, row_number () over (partition by id order by date desc)as ranking 
        FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
       -- where title is not null  and id='BP_POP_00000023'
    ) a
   where  a.ranking=1 
   union all 
     SELECT distinct CAST(c.module_id AS STRING) as module_id, c.content_id, c.module_title as content_title, country as content_country 
FROM  
   (
        SELECT
        *,row_number () over (partition by module_id, content_id order by date desc)as ranking 
        FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_home_media` 
   ) c
   where  c.ranking=1 
),
subscription_event as 
(
select a.*,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new,u.is_UA 
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre` a 
left join `dataintegration-265403.subscription.dws_act_subscription_preprocess` u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date and a.platform=u.platform
--WHERE a.date = "2022-01-10"
--and u.event_date = "2022-01-10"
WHERE a.date >=  '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=30)).strftime("%Y-%m-%d") }}'
and u.event_date >=  '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=30)).strftime("%Y-%m-%d") }}'
and u.app_name = 'BeautyPlus'
),
subscription_pre as 
(
SELECT
  date,
  platform,
  is_new,
  is_UA,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'sub_suc' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  0 as payment_price_usd 
FROM subscription_event

  where event_name in ('subscription_try_suc') and standard_order_date is not null

 union all 

 SELECT
  date,
  platform,
  is_new,
  is_UA,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'sub_to_paid' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  payment_price_usd   
FROM subscription_event

  where event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null  

union all 

SELECT
  date,
  platform,
  is_new,
  is_UA,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  case when  event_name in ('page_event') then 'enter_subscription_page'
  when  event_name in ('subscription_try_suc') then 'subscription_start_try'
  else event_name end as event_name,
  agg,
  user_pseudo_id,
  uuid,
  0 as payment_price_usd  
FROM subscription_event

union all 
SELECT
  date,
  platform,
  is_new,
  is_UA,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'trial' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  0 as payment_price_usd  
FROM subscription_event
  WHERE event_name in ('subscription_try_suc') and standard_order_date is not null and  sku_has_trial IN ('has_trial')

union all 
SELECT
  date,
  platform,
  is_new,
  is_UA,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'trial_to_paid' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  payment_price_usd  
FROM subscription_event
  where  event_name in ('subscription_try_suc') and standard_order_date is not null and  purchase_date is not null  and sku_has_trial IN ('has_trial')
),

sub_category3 as
(select
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
a.category1,
a.category2,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
--如果为空没有匹配上，则匹配新创建的无日期的维表 2022-04-18
case when a.content_title is null then c.content_title else a.content_title end as content_title,
case when a.content_country is null then c.content_country else a.content_country end as content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd
from 
 (
  select a.*except(category2),case when b.english_name is not null then b.english_name else a.category2 end as category2,
  c.content_title ,c.content_country
  from
    (SELECT
      distinct  
      date,
      platform,
      country,
      is_new,
      is_UA,
      app_version,
      sku_type,
      sku_has_trial,
      '' as sku,
      event_name,
      s.category1,
      category2,
      -- change to complete for feature ID, 20211222 by xinying
      case when s.category1 in ('material') then s.category3_id else s.category3_mid end as category3_mid, 
      s.category3_cid,
      s.category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd 
    FROM
      subscription_pre
    CROSS JOIN
      UNNEST(agg) AS s
    )a
      left join
      `dataintegration-265403.dmi.dmi_da_content_page_dictionary` b
      on a.category2=b.key
      left join content_id c
      on  a.date=c.date and case when a.category1 in ('content') and a.category2 not in ('LBD','HPP', 'POP') then concat(a.category3_mid,'_',a.category3_cid) else concat(a.category3_mid,'_0') end
       = concat(c.module_id,'_',c.content_id) 
 ) a
     left join content_id_2 c  --新维表的关联条件与旧的有所不同
     on   case when a.category1 in ('content') and a.category2 not in ('HomePage Pop','Launch Board') then concat(a.category3_mid,'_',a.category3_cid) else concat(a.category3_mid,'_0') end
       = concat(c.module_id,'_',c.content_id) 
),

sub_category2 as
(select
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
a.category1,
case when b.english_name is not null then b.english_name else a.category2 end as category2,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
--b.english_name,
'-' as content_title,
'-' as content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd
from 
    (SELECT
      distinct  
      date,
      platform,
      country,
      is_new,
      is_UA,
      app_version,
      sku_type,
      sku_has_trial,
      '' as sku,
      event_name,
      s.category1,
      category2,
      -- change to complete for feature ID, 20211222 by xinying
      '-' as category3_mid, 
      '-' as category3_cid,
      '-' as category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd 
    FROM
      subscription_pre
    CROSS JOIN
      UNNEST(agg) AS s
      )a
      left join
      `dataintegration-265403.dmi.dmi_da_content_page_dictionary` b
      on a.category2=b.key

),

sub_category1 as
(select
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
a.category1,
a.category2,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
--b.english_name,
'-' as content_title,
'-' as content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd
from 
    (SELECT
      distinct  
      date,
      platform,
      country,
      is_new,
      is_UA,
      app_version,
      sku_type,
      sku_has_trial,
      '' as sku,
      event_name,
      s.category1,
      '-' as category2, 
      -- change to complete for feature ID, 20211222 by xinying
      '-' as category3_mid, 
      '-' as category3_cid,
      '-' as category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd 
    FROM
      subscription_pre
    CROSS JOIN
      UNNEST(agg) AS s
      )a
  ),
event_pre as (
select distinct 
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      sku_type,
      sku_has_trial,
      sku,
      user_pseudo_id,
      payment_price_usd
 from subscription_pre
)
SELECT
      'category3' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      sku_type,
      sku_has_trial,
      sku,
      category1,
      category2,  
      category3_mid, 
      category3_cid,
      content_title,
      content_country,
      category3_feature_content,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category3
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

union all       

SELECT
      'category2' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      sku_type,
      sku_has_trial,
      sku,
      category1,
      category2,  
      category3_mid, 
      category3_cid,
      content_title,
      content_country,
      category3_feature_content,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category2
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

union all       

SELECT
      'category1' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      sku_type,
      sku_has_trial,
      sku,
      category1,
      category2,  
      category3_mid, 
      category3_cid,
      content_title,
      content_country,
      category3_feature_content,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category1
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18      

  union all
      SELECT
      'event_and_sku' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      sku_type,
      sku_has_trial,
      sku,
      '-' as category1,
      '-' as category2,  
      '-' as category3_mid, 
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      count(distinct user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

      union all
      SELECT
      'event' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      '' as sku_type,
      '' as sku_has_trial,
      '' as sku,
      '-' as category1,
      '-' as category2,  
      '-' as category3_mid, 
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      count(distinct user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

      union all      
      SELECT
      'event' as data_type,
      a.event_date as date,
      a.platform,
      c.country,
      b.app_version,
      a.is_UA as is_ua,
      case when a.is_new=1 then 'New-user' else 'Old-user' end as is_new,
      'dau' as event_name,
      '' as sku_type,
      '' as sku_has_trial,
      '' as sku,
      '-' as category1,
      '-' as category2,  
      '-' as category3_mid, 
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      count(distinct a.user_pseudo_id) as uv,
      0 as payment_price_usd
      FROM `dataintegration-265403.subscription.dws_act_subscription_preprocess` a
      left join `beautyplus-bc0ed.ods.ods_dz_active_device` b 

      on a.user_pseudo_id=b.user_pseudo_id and a.event_date=b.event_date_hk and a.platform=b.platform
      left join  `dataintegration-265403.stat_dm.stat_rda_locaiton` c on b.geo_id = c.geo_id
      --where a.event_date= "2022-01-10" and b.event_date= "2022-01-10"
      where a.event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=30)).strftime("%Y-%m-%d") }}'
      and a.app_name = 'BeautyPlus'
      and b.event_date_hk  >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=30)).strftime("%Y-%m-%d") }}'
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
/*smp_final
* @Last Modified by:   zhoutao
* @Last Modified time: 2023-09-01,2023-05-16
* @Last Modified content: 订阅指标升级，首页内容更新 数据字典更新，增加二级分类、增加首页内容2.0维表，内容维表只取唯一值逻辑
* @to_do:
*/
drop table if exists `beautyplus-bc0ed.temp.ads_spm_trial_subscription_v5_temp`;
create table `beautyplus-bc0ed.temp.ads_spm_trial_subscription_v5_temp` as
with

--对于同一个id对应两个及以上内容时，取最近的一个内容
content_id as
(
  --弹窗,启动页
  select distinct a.id as module_id, '0' as content_id,title as content_title, country as content_country
   FROM
   (
        SELECT
        *, row_number () over (partition by id order by date desc)as ranking
        FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
        where title is not null
    ) a
   where  a.ranking=1
   --首页内容1.0
   union all
     SELECT distinct CAST(c.module_id AS STRING) as module_id, c.content_id, c.module_title as content_title, country as content_country
FROM
   (
        SELECT
        *,row_number () over (partition by module_id, content_id order by date desc)as ranking
        FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_home_media`
        where module_title is not null
   ) c
   where  c.ranking=1
--首页内容2.0
  union all

       select distinct module_id,'0' as content_id,
        module_name as content_title,
       marvel_region as content_country
       from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content`
       where level_type='content_id' and  data_type='uv' AND module<>'轮播图'

  union all

       select distinct module_id,content_id,
       content_name  as content_title,
       marvel_region as content_country
       from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content`
       where level_type='content_id' and  data_type='uv' AND module='轮播图'
),


subscription_event as
(
select a.*except(sku_has_trial)
  ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
       else 'no_trial'
  end sku_has_trial,
case
     when pre_page like '%修图编辑页%'  then 'Photo Editor'
     when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
     when pre_page like '拍后确认页_视频%'  then 'Video'
     when pre_page like '拍后确认页_电影%'  then 'Studio'
     when pre_page like '视频编辑页%' then 'Video Editor'
     when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module,
case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new,u.is_UA
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
 join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
--WHERE a.date >= '2021-01-01'
--and u.event_date_hk >= '2021-01-01'
WHERE a.date >=  '2025-01-01'
and u.event_date_hk >=  '2025-01-01'
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
  0 as payment_price_usd,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
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
  payment_price_usd,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
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
  0 as payment_price_usd,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
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
  0 as payment_price_usd,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
FROM subscription_event
  WHERE event_name in ('subscription_try_suc') and standard_order_date is not null and  sku_has_trial IN ('has_trial') -- sub_success_offer_type in ('trial','intro_trial','promotion_trial')

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
  payment_price_usd,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
FROM subscription_event
  where  event_name in ('subscription_try_suc') and standard_order_date is not null and  purchase_date is not null  and sku_has_trial IN ('has_trial') -- sub_success_offer_type in ('trial','intro_trial','promotion_trial')

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
  'sub_success_to_standard_paid' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  sub_success_to_standard_paid_revenue,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
FROM subscription_event
  WHERE   event_name in ('subscription_try_suc') and sub_success_to_standard_paid_order_id is not null

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
  'sub_success_to_promotional_paid' as event_name,
  agg,
  user_pseudo_id,
  uuid,
  Promotional_revenue,
  pre_page,
  module,
  sub_user_type,
  sku_tag,
  source_amount_proportion
FROM subscription_event
  where  event_name in ('subscription_try_suc') and purchase_order_id is not null and sub_success_to_standard_paid_order_id is null
),

sub_category3 as
(select distinct
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
case when a.category2 in ('首页-默认入口') then 'content'
else a.category1 end as category1,
a.category2,
a.category,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
content_title,
content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd,
    pre_page,
    module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
from
 (
  select a.*except(category2),
  case
  when b.english_name is not null then b.english_name
  else a.category2 end as category2,b.category,
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
      case when s.category1 in ('material','H5') then s.category3_id else s.category3_mid end as category3_mid,
      s.category3_cid,
      s.category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd,
       module,
      pre_page,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
    FROM
      subscription_pre
    CROSS JOIN
      UNNEST(agg) AS s
    )a
--       left join
--       `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b
      left join
      (
        select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category
        from `dataintegration-265403.dim.dim_aa_content_dict`
        where key is not null
        group by 1
      ) b
      on a.category2=b.key
      left join content_id c
       on  case when a.category1 in ('content') and a.category2  in ('HTB','HBR','HAR','HFI') then concat(a.category3_mid,'_',a.category3_cid) else concat(a.category3_mid,'_0') end
       = concat(c.module_id,'_',c.content_id)
 ) a
),

sub_category2 as
(select distinct
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
case when a.category2 in ('首页-默认入口') then 'content'
else a.category1 end as category1,
  case
  when b.english_name is not null then b.english_name
  else a.category2 end as category2,b.category,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
--b.english_name,
'-' as content_title,
'-' as content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd,
    pre_page,
    module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
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
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd,
      pre_page,
      module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
    FROM
      subscription_pre
    CROSS JOIN
      UNNEST(agg) AS s
      )a
--       left join
--       `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b
      left join
      (
        select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category
        from `dataintegration-265403.dim.dim_aa_content_dict`
        where key is not null
        group by 1
      ) b
      on a.category2=b.key

),

sub_category1 as
(select distinct
a.date,
a.platform,
a.country,
a.app_version,
a.sku_type,
a.sku_has_trial,
a.sku,
a.event_name,
case when a.category2 in ('首页-默认入口') then 'content'
else a.category1 end as category1,
-- a.category2,
'-' as category2,
a.category3_mid,
a.category3_cid,
a.category3_feature_content,
--b.english_name,
'-' as content_title,
'-' as content_country,
a.is_UA as is_ua,
a.is_new,
a.user_pseudo_id,
a.payment_price_usd,
    pre_page,
     module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
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
--       '-' as category2,
      category2,
      -- change to complete for feature ID, 20211222 by xinying
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as category3_feature_content,
      user_pseudo_id,
      uuid,
      payment_price_usd,
      pre_page,
     module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
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
      payment_price_usd,
      pre_page,
     module,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
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
case
        when Category1 in ('content','H5','else') then Category1
        when category is not null then category
        else 'others' end as category1_sub,
      '_' as pre_page,
    'All' as module,
    sub_user_type,
    sku_tag,
    sum(source_amount_proportion*payment_price_usd)as source_amount_proportion,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category3
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

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
      case
        when Category1 in ('content','H5','else') then Category1
        when category is not null then category
        else 'others' end as category1_sub,
/*case
        when Category1 in ('content','H5','else') then Category1
        when Category2 in ('Details','RetouchHD','Concealer','FacialReshape','Relight','Firm','Reshape','TeethCorrection','Acne','DarkCircle','Details','Slim','SkinTone','AI Sets','HairThickness','HairLine','DoubleChin','SoftHair','SmileLine','Expression','Hair Style','Makeup Style','Avatar','Slim_background_protecting') then 'Beauty'
        when Category2  in ('Cutout','Enhance','Remover','Disperse','Mosaic','Blur','PhotoRepair') then 'Edit'
        when Category2  in ('Filter','Sticker','Brush','Text','Background Texture','Background Gradient','Template','Font','LOOK','Style Category' ,'AR','Flare','Anime Me') then 'Material'
        when Category2  in ('Lipstick Color','Lipstick Style','Eyelash Style','Eyelash Color','Eyebrow Style','Eyebrow Color','Blush Color','Blush Style','Pupil','Contour','Hair Dye','Eyeshadow',
          'Contour','Aegyo sal','Contact lens','Freckles','Lipstick','Eyelash','Eyebrow','Blush') then 'Makeup'
      else 'others' end as category1_sub,*/
      '' as pre_page,
    'All' as  module,
    sub_user_type,
    sku_tag,
    sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category2
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

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
      '_' as category1_sub,
      '_' as pre_page,
      'All' as module,
    sub_user_type,
    sku_tag,
    sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category1
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

union all --此处的分类二级与之前的区别是module字段的区别

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
      case
        when Category1 in ('content','H5','else') then Category1
        when category is not null then category
        else 'others' end as category1_sub,
      '_' as pre_page,
     module,
    sub_user_type,
    sku_tag,
    sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from sub_category2
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23


union all

SELECT
      'module' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
      '_' as sku_type,
      '_' as sku_has_trial,
      '_' as sku,
      '-' as category1,
      '-' as category2,
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      '_' as category1_sub,
      '_' as pre_page,
     module,
    sub_user_type,
    sku_tag,
    sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

union all

SELECT
      'user_type' as data_type,
      date,
      platform,
      country,
      app_version,
      is_ua,
      is_new,
      event_name,
       '_' as sku_type,
      '_' as sku_has_trial,
      '_' as sku,
      '-' as category1,
      '-' as category2,
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      '_' as category1_sub,
      '_' as pre_page,
    '_' as module,
     sub_user_type,
     sku_tag,
   sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(distinct user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

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
      '_' as category1_sub,
      '_' as pre_page,
    '_' as module,
    '_' as sub_user_type,
    '_' as sku_tag,
     sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(distinct user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

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
      '_' as sku_type,
      '_' as sku_has_trial,
      '_' as sku,
      '-' as category1,
      '-' as category2,
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      '_' as category1_sub,
      '_' as pre_page,
    '_' as module,
    '_' as sub_user_type,
    '_' as sku_tag,
     sum(source_amount_proportion*payment_price_usd)as source_amount_proportion ,
      count(distinct user_pseudo_id) as uv,
      sum(payment_price_usd) as payment_price_usd
      from event_pre
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

      union all
      SELECT
      'event' as data_type,
      a.event_date_hk as date,
      a.platform,
      country,
      app_version,
      a.is_UA as is_ua,
      case when a.is_new=1 then 'New-user' else 'Old-user' end as is_new,
      'dau' as event_name,
      '_' as sku_type,
      '' as sku_has_trial,
      '_' as sku,
      '-' as category1,
      '-' as category2,
      '-' as category3_mid,
      '-' as category3_cid,
      '-' as content_title,
      '-' as content_country,
      '-' as category3_feature_content,
      '_' as category1_sub,
       '_' as pre_page,
    '_' as module,
    '_' as sub_user_type,
    '_' as sku_tag,
    0 as source_amount_proportion,
      count(distinct a.user_pseudo_id) as uv,
      0 as payment_price_usd
      FROM `dataintegration-265403.stat.stat_active_advice_detail_d`  a
      --where a.event_date_hk>= '2021-01-01'
      where a.event_date_hk >= '2025-01-01'
       and a.app_name = 'BeautyPlus'
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

      /* left join `beautyplus-bc0ed.ods.ods_dz_active_device` b
      on a.user_pseudo_id=b.user_pseudo_id and a.event_date_hk=b.event_date_hk and a.platform=b.platform
      left join  `dataintegration-265403.stat_dm.stat_rda_locaiton` c on b.geo_id = c.geo_id
      --where a.event_date_hk>= "2023-06-01" and b.event_date_hk>= "2023-06-01"
      and b.event_date_hk  >= '2025-01-01'
      */

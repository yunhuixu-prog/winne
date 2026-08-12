SELECT
 'V5.0' as edition,
  data_type,
  date,
  platform,
  app_version as version,
  case when country='China' then 'China Mainland'
  else country end as country,
  is_ua,
  is_new,
  sku_type,
  Category1,
--   Category1_sub,
  coalesce(c.en_cn_name,Category1_sub) Category1_sub,
--   Category2,
  coalesce(b.en_cn_name,Category2) Category2,
  Category3_mid,
  Category3_cid,
  content_title,
  content_country,
  Category3_feature_content,
  uv,
  case when event_name in ('enter_subscription_page') then 'Sub enter'
       when event_name in ('subscription_clk_try') then 'Sub click'
       when event_name in ('sub_suc') then 'Sub success'
       when event_name in ('sub_to_paid') then 'Sub success to paid'
       when event_name in ('dau') then 'DAU'
       when event_name in ('trial') then 'Trial uv'
       when event_name in ('trial_to_paid') then 'Trial to paid uv'
  end as event_name,
  payment_price_usd,
  Share_Revenue,
  module,
  sub_user_type
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) b
on a.Category2=b.subscription_table_name
left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) c
on a.Category1_sub=c.subscription_table_name
WHERE data_type in ('category2')
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
 and Category2 is not null
 and Category2<>''
 and a.date between '2024-11-01' and '2024-11-14'
 and a.module='shoot'
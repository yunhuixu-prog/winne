--`beautyplus-bc0ed.sub_dataset.ads_dz_sub_dtype_eventSKU`
SELECT
  '3.0' as edition,
  data_type,
  date,
  platform,
  app_version as version,
  country,
  is_ua,
  is_new,
  sku_type,
  sku_has_trial,
  sku,
  Category1,
  Category2,
  Category3_mid,
  Category3_cid,
  Category3_content_title,
  Category3_content_country,
  Category3_feature_content,
  uv,
  case when event_name in ('subscription_clk_try') then 'Sub click'
       when event_name in ('sub_suc') then 'Sub success'
       when event_name in ('sub_to_paid') then 'Sub success to paid'
       when event_name in ('dau') then 'DAU'
       when event_name in ('trial') then 'Trial uv'
       when event_name in ('trial_to_paid') then 'Trial to paid uv'
  end as event_name,
  payment_price_usd
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription`
 where data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
 union all
 SELECT
  '4.0' as edition,
  data_type,
  date,
  platform,
  app_version as version,
  country,
  is_ua,
  is_new,
  sku_type,
  sku_has_trial,
  sku,
  Category1,
  Category2,
  Category3_mid,
  Category3_cid,
  Category3_content_title,
  Category3_content_country,
  Category3_feature_content,
  uv,
  case when event_name in ('subscription_clk_try') then 'Sub click'
       when event_name in ('sub_suc') then 'Sub success'
       when event_name in ('sub_to_paid') then 'Sub success to paid'
       when event_name in ('dau') then 'DAU'
       when event_name in ('trial') then 'Trial uv'
       when event_name in ('trial_to_paid') then 'Trial to paid uv'
  end as event_name,
  payment_price_usd
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v4`
 where data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')


  union all
 SELECT
  'V5.0' as edition,
  data_type,
  date,
  platform,
  app_version as version,
  country,
  is_ua,
  is_new,
  sku_type,
  sku_has_trial,
  sku,
  Category1,
  Category2,
  Category3_mid,
  Category3_cid,
  content_title,
  content_country,
  Category3_feature_content,
  uv,
  case when event_name in ('subscription_clk_try') then 'Sub click'
       when event_name in ('sub_suc') then 'Sub success'
       when event_name in ('sub_to_paid') then 'Sub success to paid'
       when event_name in ('dau') then 'DAU'
       when event_name in ('trial') then 'Trial uv'
       when event_name in ('trial_to_paid') then 'Trial to paid uv'
  end as event_name,
  payment_price_usd
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
 where data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')

union all

SELECT
    'V6.0' as edition,
    data_type,
    date,
    platform,
    app_version as version,
    case when country='China' then 'China Mainland'
    else country end as country,
    is_ua,
    is_new,
    sku_type,
    sku_has_trial,
    sku,
    Category1,
--     '-' Category1_sub,
--     '-' Category2_sub,
    Category2,
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
    payment_price_usd
--     Share_Revenue,
--     module,
--     sub_user_type
FROM
`beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
where data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
    and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')

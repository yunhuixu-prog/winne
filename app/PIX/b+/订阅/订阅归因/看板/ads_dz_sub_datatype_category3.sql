--`beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_category3`
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
  Category1,
  '' as Category1_sub,
  Category2,
  Category3_mid,
  Category3_cid,
  Category3_content_title,
  Category3_content_country,
  Category3_feature_content,
  1 flag,
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
  0 AS Share_Revenue,
  '_' AS module,
  '_' AS sub_user_type
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription`
WHERE data_type in ('category3')
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
  and Category2 is not null
 and Category2 not in ('','H','HT','HA')

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
  Category1,
  Category1_sub,
  Category2,
  Category3_mid,
  Category3_cid,
  Category3_content_title,
  Category3_content_country,
  Category3_feature_content,
  1 flag,
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
  0 AS Share_Revenue,
  '_' AS module,
  '_' AS sub_user_type
FROM
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v4`
WHERE data_type in ('category3')
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
  and Category2 is not null
 and Category2 not in ('','H','HT','HA')

 union all

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
  case when Category1_sub in ('Makeup','Makeup Material') then 'Makeup' else Category1_sub end Category1_sub,
  coalesce(en_cn_name,Category2) Category2,
  Category3_mid,
  Category3_cid,
  content_title,
  content_country,
  Category3_feature_content,
  case when a.Category1_sub in ('Beauty','Creative Material','Edit','Advance','Makeup','Makeup Material')
        and a.module in ('Photo Editor','Shoot','Video Editor','Video','Batch Edit') and c.subscription_table_name is null then 0
    else 1
    end flag,
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
left join
(
    select distinct case when module='修图' then 'Photo Editor'
                         when module='拍摄' then 'Shoot'
                         when module='视频编辑' then 'Video Editor'
                         when module='批量编辑' then 'Batch Edit'
            end module_name
            ,subscription_table_name
    from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`

    union all
    -- 视频默认有拍摄下的所有功能+自身的功能（长视频拍后加长时间，在else里）
    select distinct 'Video' module_name
            ,subscription_table_name
    from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`
    where module='拍摄'
) c
on a.module=c.module_name and a.Category2=c.subscription_table_name
WHERE data_type in ('category3')
 and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--   and Category2 is not null
--  and Category2 not in ('','H','HT','HA')


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
    Category1,
    case when Category1_sub in ('Makeup','Makeup Material') then 'Makeup' else Category1_sub end Category1_sub,
--     case when Category1_sub = 'Makeup Material' then 'Makeup Material' else coalesce(en_cn_name,Category2) end Category2_sub, -- 除美妆素材外，延用Category2，美妆素材（口红、睫毛这些）统一成一类
--     Category2,
    coalesce(en_cn_name,Category2) Category2,
    Category3_mid,
    Category3_cid,
    content_title,
    content_country,
    Category3_feature_content,
    case when a.Category1_sub in ('Beauty','Creative Material','Edit','Advance','Makeup','Makeup Material')
        and a.module in ('Photo Editor','Shoot','Video Editor','Video','Batch Edit') and c.subscription_table_name is null then 0
    else 1
    end flag,
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
`beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest` a
left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) b
on a.Category2=b.subscription_table_name
left join
(
    select distinct case when module='修图' then 'Photo Editor'
                         when module='拍摄' then 'Shoot'
                         when module='视频编辑' then 'Video Editor'
                         when module='批量编辑' then 'Batch Edit'
            end module_name
            ,subscription_table_name
    from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`

    union all
    -- 视频默认有拍摄下的所有功能+自身的功能（长视频拍后加长时间，在else里）
    select distinct 'Video' module_name
            ,subscription_table_name
    from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`
    where module='拍摄'
) c
on a.module=c.module_name and a.Category2=c.subscription_table_name
WHERE data_type in ('category3')
    and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--     and Category2 is not null
--     and Category2 not in ('','H','HT','HA')

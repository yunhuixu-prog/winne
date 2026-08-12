--`beautyplus-bc0ed.view.ads_dz_sub_no_content_category2`
-- SELECT
--     'category1' as edition,
--     data_type,
--     date,
--     platform,
--     app_version as version,
--     case when country='China' then 'China Mainland'
--     else country end as country,
--     is_ua,
--     is_new,
--     sku_type,
--     Category1,
--     '-' Category1_sub,
--     '-' Category2_sub,
--     Category2,
--     Category3_mid,
--     Category3_cid,
--     content_title,
--     content_country,
--     Category3_feature_content,
--     uv,
--     case when event_name in ('enter_subscription_page') then 'Sub enter'
--         when event_name in ('subscription_clk_try') then 'Sub click'
--         when event_name in ('sub_suc') then 'Sub success'
--         when event_name in ('sub_to_paid') then 'Sub success to paid'
--         when event_name in ('dau') then 'DAU'
--         when event_name in ('trial') then 'Trial uv'
--         when event_name in ('trial_to_paid') then 'Trial to paid uv'
--     end as event_name,
--     payment_price_usd,
--     Share_Revenue,
--     module,
--     sub_user_type
-- FROM
-- `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
-- WHERE data_type in ('category1')
--     and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--
-- union all

SELECT
    'category2' as edition,
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
    case when Category1_sub = 'Makeup Material' then 'Makeup Material' else coalesce(en_cn_name,Category2) end Category2_sub, -- 除美妆素材外，延用Category2，美妆素材（口红、睫毛这些）统一成一类
    --   Category2,
    coalesce(en_cn_name,Category2) Category2,
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
`beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest` a
left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) b
on a.Category2=b.subscription_table_name
WHERE data_type in ('category2')
    and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
    and Category2 is not null
    and Category2<>''

-- union all
--
-- SELECT
--     'category3' as edition,
--     data_type,
--     date,
--     platform,
--     app_version as version,
--     case when country='China' then 'China Mainland'
--     else country end as country,
--     is_ua,
--     is_new,
--     sku_type,
--     Category1,
--     case when Category1_sub in ('Makeup','Makeup Material') then 'Makeup' else Category1_sub end Category1_sub,
--     case when Category1_sub = 'Makeup Material' then 'Makeup Material' else coalesce(en_cn_name,Category2) end Category2_sub, -- 除美妆素材外，延用Category2，美妆素材（口红、睫毛这些）统一成一类
--     --   Category2,
--     coalesce(en_cn_name,Category2) Category2,
--     Category3_mid,
--     Category3_cid,
--     content_title,
--     content_country,
--     Category3_feature_content,
--     uv,
--     case when event_name in ('enter_subscription_page') then 'Sub enter'
--         when event_name in ('subscription_clk_try') then 'Sub click'
--         when event_name in ('sub_suc') then 'Sub success'
--         when event_name in ('sub_to_paid') then 'Sub success to paid'
--         when event_name in ('dau') then 'DAU'
--         when event_name in ('trial') then 'Trial uv'
--         when event_name in ('trial_to_paid') then 'Trial to paid uv'
--     end as event_name,
--     payment_price_usd,
--     Share_Revenue,
--     module,
--     sub_user_type
-- FROM
-- `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest` a
-- left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) b
-- on a.Category2=b.subscription_table_name
-- WHERE data_type in ('category3')
--     and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--     and Category2 is not null
--     and Category2 not in ('','H','HT','HA')
--
-- union all
--
-- SELECT
--     'event' as edition,
--     data_type,
--     date,
--     platform,
--     app_version as version,
--     case when country='China' then 'China Mainland'
--     else country end as country,
--     is_ua,
--     is_new,
--     sku_type,
--     Category1,
--     '-' Category1_sub,
--     '-' Category2_sub,
--     Category2,
--     Category3_mid,
--     Category3_cid,
--     content_title,
--     content_country,
--     Category3_feature_content,
--     uv,
--     case when event_name in ('enter_subscription_page') then 'Sub enter'
--         when event_name in ('subscription_clk_try') then 'Sub click'
--         when event_name in ('sub_suc') then 'Sub success'
--         when event_name in ('sub_to_paid') then 'Sub success to paid'
--         when event_name in ('dau') then 'DAU'
--         when event_name in ('trial') then 'Trial uv'
--         when event_name in ('trial_to_paid') then 'Trial to paid uv'
--     end as event_name,
--     payment_price_usd,
--     Share_Revenue,
--     module,
--     sub_user_type
-- FROM
-- `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
-- WHERE data_type = 'event'
--
-- union all
--
-- SELECT
--     'event_and_sku' as edition,
--     data_type,
--     date,
--     platform,
--     app_version as version,
--     case when country='China' then 'China Mainland'
--     else country end as country,
--     is_ua,
--     is_new,
--     sku_type,
--     Category1,
--     '-' Category1_sub,
--     '-' Category2_sub,
--     Category2,
--     Category3_mid,
--     Category3_cid,
--     content_title,
--     content_country,
--     Category3_feature_content,
--     uv,
--     case when event_name in ('enter_subscription_page') then 'Sub enter'
--         when event_name in ('subscription_clk_try') then 'Sub click'
--         when event_name in ('sub_suc') then 'Sub success'
--         when event_name in ('sub_to_paid') then 'Sub success to paid'
--         when event_name in ('dau') then 'DAU'
--         when event_name in ('trial') then 'Trial uv'
--         when event_name in ('trial_to_paid') then 'Trial to paid uv'
--     end as event_name,
--     payment_price_usd,
--     Share_Revenue,
--     module,
--     sub_user_type
-- FROM
-- `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
-- where data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
--     and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--
-- union all
--
-- SELECT
--     'module' as edition,
--     data_type,
--     date,
--     platform,
--     app_version as version,
--     case when country='China' then 'China Mainland'
--     else country end as country,
--     is_ua,
--     is_new,
--     sku_type,
--     Category1,
--     '-' Category1_sub,
--     '-' Category2_sub,
--     Category2,
--     Category3_mid,
--     Category3_cid,
--     content_title,
--     content_country,
--     Category3_feature_content,
--     uv,
--     case when event_name in ('enter_subscription_page') then 'Sub enter'
--         when event_name in ('subscription_clk_try') then 'Sub click'
--         when event_name in ('sub_suc') then 'Sub success'
--         when event_name in ('sub_to_paid') then 'Sub success to paid'
--         when event_name in ('dau') then 'DAU'
--         when event_name in ('trial') then 'Trial uv'
--         when event_name in ('trial_to_paid') then 'Trial to paid uv'
--     end as event_name,
--     payment_price_usd,
--     Share_Revenue,
--     module,
--     sub_user_type
-- FROM
-- `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
-- WHERE (data_type in ('module') or (data_type in ('event') and event_name in ('dau')))
--  and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')


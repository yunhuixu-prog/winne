-- 用prf_func区分，但是没上报
select
   event_date_hk as date,
    platform,user_pseudo_id, event_timestamp, event_name,
    `beautyplus-bc0ed.func.getParams`(event_params,'cur_page_content').string_value as cur_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'pre_page_content').string_value as pre_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'dpre_page_content').string_value as dpre_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'source_feature_content').string_value as source_feature_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'source_click_position').string_value as  source_click_position,
    `beautyplus-bc0ed.func.getParams`(event_params,'prf_func').string_value as  prf_func,
    `beautyplus-bc0ed.func.getParams`(event_params,'SKU_ID').string_value as SKU_ID,
    version   as app_version,
    geo,
      `beautyplus-bc0ed.func.getParams`(event_params,'sub_user_type').string_value  as sub_user_type,
       `beautyplus-bc0ed.func.getParams`(event_params,'sku_tag').string_value  as sku_tag,
     func.getUserprop(user_properties, 'device_id').string_value AS device_id
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-09', '2025-07-10','beautyplus',false)
  where event_name in ('subscription_clk_try', 'subscription_try_suc', 'page_event')
    and `beautyplus-bc0ed.func.getParams`(event_params,'source_feature_content').string_value like '%ImageQuality%'
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.14.0')

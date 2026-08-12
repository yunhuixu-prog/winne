--ads_dz_event_edit_02
SELECT '< 7.4.000' as data, event_date, platform, country, is_new, is_UA, user_type, is_pay, version, null as android_device, dau, event_name, event_name_cn, key_name, value_name, module, class, function, subfunction, subfunction_a, action, mark,num, uv, pv
FROM `beautyplus-bc0ed.event_dataset.ads_dz_event_data` where module in ('修图') and version>='7.1.060' and  version<'7.4.000'
and action is not null

union all

SELECT
'>= 7.4.000' as data,
 event_date, platform, country, is_new, is_UA, user_type, is_pay, version, android_device, dau, event_name, event_name_cn, key_name, value_name, module, class, function, subfunction, subfunction_a, action, mark,num, uv, pv
FROM `beautyplus-bc0ed.event_dataset_2.ads_dz_event_data_02`
where module in ('修图') and  mark>=1 and mark<=4
--PARSE_DATE("%Y%m%d", event_date) as

union all

SELECT
'V3.0' as data,
 event_date, platform, country, is_new, is_UA, user_type, is_pay, version, android_device, dau, event_name, event_name_cn, key_name, value_name, module, class, function, subfunction, subfunction_a, action, mark,num, uv, pv
FROM `beautyplus-bc0ed.event_dataset_3.ads_dz_event_data_03`
where module in ('修图') and  mark>=1 and mark<=4
--PARSE_DATE("%Y%m%d", event_date) as

union all

SELECT
'V4.0' as data,
 event_date, platform,   case when country='China' then 'China Mainland'
  else country end as country, is_new, is_UA, user_type, is_pay, version, android_device, dau, event_name, event_name_cn, key_name, value_name, module, class, function, subfunction, subfunction_a, action, mark,num, uv, pv
FROM `beautyplus-bc0ed.event_dataset_4.ads_dz_event_data_04`
where  mark>=1 and mark<=4 --4.0逻辑与之前不同：在底表未限定模块，需要在看板限定
--PARSE_DATE("%Y%m%d", event_date) as


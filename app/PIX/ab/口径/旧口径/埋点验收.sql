SELECT distinct
event_name,
-- func.getParams(event_params,'name').string_value name,
-- func.getParams(event_params,'version').string_value version,
-- func.getParams(event_params,'type').string_value type,
-- func.getParams(event_params,'port').string_value port,
-- func.getParams(event_params,'function').string_value function,
-- func.getParams(event_params,'source_module').string_value source_module,
-- func.getParams(event_params,'source_0').string_value source_0,
-- func.getParams(event_params,'source_1').string_value source_1,
-- func.getParams(event_params,'duration').string_value duration,
-- func.getParams(event_params,'SKU').string_value sku,
-- func.getParams(event_params,'order_id').string_value order_id,
func.getParams(event_params,'first_func').string_value first_func,
func.getParams(event_params,'second_func').string_value second_func,
func.getParams(event_params,'third_func').string_value third_func,
func.getParams(event_params,'is_success').string_value is_success,
-- func.getParams(event_params,'first_func_order').string_value first_func_order,
-- func.getParams(event_params,'second_func_order').string_value second_func_order,
-- func.getParams(event_params,'is_effect').string_value is_effect,
-- func.getParams(event_params,'flash_stat').string_value flash_stat,
-- func.getParams(event_params,'flash').string_value flash,
-- func.getParams(event_params,'presets_selection').string_value presets_selection,
-- func.getParams(event_params,'prf_first_func').string_value prf_first_func,
-- func.getParams(event_params,'prf_second_func').string_value prf_second_func,
-- func.getParams(event_params,'time').string_value time
-- func.getParams(event_params,'ad_placement').string_value ad_placement
-- ,count(distinct user_pseudo_id)
FROM
`airbrush-test-f031b.analytics_150700384.events_intraday_20250924`
--`airbrush-test-f031b.analytics_150700384.events_20240129`
--`airbrush-1324.analytics_152810936.events_20240126`
where
-- _table_suffix >=  FORMAT_DATE("%Y%m%d", date_sub(current_date,interval 2 day))
-- and
event_name in(
-- 'cloudfilter_per_show',
-- 'cloudfilter_per_show_ok',
-- 'w_subscription_enter',
-- 'w_subscription_click',
-- 'w_subscription_success',
'ai_func_delivery',
'ai_func_use_result'
-- 'third_func_enter',
-- 'second_func_use',
-- 'second_func_save',
-- 'edit_save'
)
and app_info.version='7.17.1'
-- and date(timestamp_micros(event_timestamp), 'Asia/Singapore')='2024-01-29'
and platform ='ANDROID'
-- and platform ='IOS'
--group by 1,2,4,5,6,7,8,9,10,11,12
order by 1,2

;

--看看实验code是不是都 报了
select event_timestamp,func.getParams(event_params,'current_abcode').string_value,
user_pseudo_id
 --distinct func.getParams(event_params,'current_abcode').string_value,
FROM
--`airbrush-1324.analytics_152810936.events_intraday_20240129`
`airbrush-test-f031b.analytics_150700384.events_*`
where
_table_suffix >=  FORMAT_DATE("%Y%m%d", date_sub(current_date,interval 5 day))
and
event_name='abcode_enter_test'
and app_info.version='7.15.0'
and platform ='ANDROID'
-- and platform ='IOS'
and func.getParams(event_params,'current_abcode').string_value in('11372','11373','11376','11377','11390','11391')
-- and func.getParams(event_params,'current_abcode').string_value in('11369','11371','11374','11375','11392','11393')

-- 挑几个用户看看 abcode_enter_test触发时机对不对，以及 该事件之后的所有事件是不是带abcode
select
`airbrush-1324.func.convertWithCh`(func.getParams(event_params,'meepo_abcode').string_value,func.getParams(event_params,'meepo_abcount').string_value),event_name
-- select event_name,func.getParams(event_params,'current_abcode').string_value
from
`airbrush-test-f031b.analytics_150700384.events_*`
where
_table_suffix >=  FORMAT_DATE("%Y%m%d", date_sub(current_date,interval 5 day))
and
app_info.version='7.15.0'
and platform ='ANDROID'
-- and platform ='IOS'
and event_timestamp>=1755508291760281
and user_pseudo_id='10ec5fcb3afa233703e2d4373e99e2d8'
order by event_timestamp



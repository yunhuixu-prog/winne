
drop table if exists `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_test_pre`;
create table if not exists `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_test_pre` as


select event_date,user_pseudo_id,event_name,event_timestamp,platform
        ,case when event_name in ('beauty_appr_bd') then
                if(coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,'0') != '0'
                    ,`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
                    ,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value)
              when event_name in ('camera_appr_bd') then
                  if(coalesce(`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value,'0') != '0'
                      ,`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value
                      ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value)
              when event_name in ('h5_enter_bd','single_function_enter_bd') then `dataintegration-265403.func`.getParams(event_params,'from').string_value
              end as source
        ,case when coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,'0') != '0'
                then `dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
              when coalesce(`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value,'0') != '0'
                then `dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value
        end content
        ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
        ,`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value enter_source_id
        ,`dataintegration-265403.func`.getParams(event_params,'homepage_func_id').string_value homepage_func_id
        ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    FROM `beautyplus-test.analytics_152810462.events_intraday_20250717`
    WHERE (
        event_name in ('beauty_appr_bd'
                       ,'camera_appr_bd','selfie_appr_bd','iphone_mode_appr_bd','stamp_cam_appr_bd','glow_cam_appr_bd','film_cam_appr_bd' -- 后面几个还没加上source且理论上不该用到后面几个，只是camera是后加的埋点
                       ,'h5_enter_bd','single_function_enter_bd'

                       ,'beautifysave_bd'
                       ,'selfiesave_bd','iphone_mode_save_bd','stamp_cam_save_bd','glow_cam_save_bd','film_cam_save_bd'
                       ,'h5_page_button_clk_bd','h5_page_button_clk'
                       ,'ai_editor_save_suc_bd'
                       ,'subscription_try_suc','subscription_clk_try')
        OR (event_name IN ('page_event') AND
            `beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
                    IN ('1009','1008_01') )
        )
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.15.0')

;

select event_name,platform
    ,if(trace_info is not null,1,0) is_trace_info
    ,count(1) pv
from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_test_pre`
group by 1,2,3
order by 1,2,3

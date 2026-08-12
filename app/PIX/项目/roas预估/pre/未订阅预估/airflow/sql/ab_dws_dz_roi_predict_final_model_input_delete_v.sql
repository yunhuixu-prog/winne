-- airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v

select types,date,Attributed_Touch_Date,user_pseudo_id
--        ,region
       ,case when region in ('United States','Japan','United Kingdom','South Korea','Thailand','Brazil') then region else 'else' end region
       ,platform,sub_now,sub_revenue_now,is_sub_now
       ,sub_365,sub_no_trial_365,sub_revenue_365
--        ,case when sub_no_trial_year_365>0 then 1
--              when sub_no_trial_month_365>0 then 2
--              when sub_no_trial_other_365>0 then 3
--        else 0 end sub_no_trial_flag_365
       ,active_mins,active_sessions,active_days
       ,`pv_edit_save-all-all`,`pv_edit_use-Tools-all`,`pv_camera_save-Filter-all`,`pv_edit_use-Creative-all`,`pv_edit_use-Presets-all`,`pv_camera_enter-all-all`,`pv_camera_save-all-all`,`pv_edit_enter-Presets-all`,`pv_edit_enter-Filter-all`,`pv_edit_enter-Retouch-all`,`pv_edit_save-AI Style-all`,`pv_edit_save-Hair-all`,`pv_camera_taken-Filter-all`,`pv_edit_enter-all-all`,`pv_camera_taken-all-all`
       ,`pv_edit_enter-Tools-Eraser`,`pv_edit_save-Retouch-Smooth`,`pv_edit_save-Retouch-Reshape`,`pv_edit_enter-Retouch-Foundation`,`pv_edit_enter-Retouch-Sculpt`,`pv_edit_enter-Makeup-Sets`,`pv_edit_save-Retouch-Magic`,`pv_edit_enter-Tools-Adjust`,`pv_edit_enter-Tools-Blur`,`pv_edit_enter-Retouch-Firm`,`pv_edit_enter-Makeup-Eyelashes`,`pv_edit_use-Tools-Bokeh`,`pv_edit_use-Hair-HairDye`,`pv_edit_use-Retouch-Sculpt`,`pv_edit_enter-Tools-Stretch`,`pv_edit_use-Makeup-Contour`,`pv_edit_save-Retouch-Whiten`,`pv_edit_enter-Tools-Vignette`,`pv_edit_enter-Tools-Enhance`,`pv_edit_use-Retouch-Acne`,`pv_edit_enter-Tools-Relight`,`pv_edit_use-Tools-Enhance`,`pv_edit_use-Retouch-DarkCircles`,`pv_edit_save-Retouch-Acne`,`pv_edit_save-Retouch-Resize`,`pv_edit_enter-Makeup-Eyebrows`,`pv_edit_enter-Makeup-BuildLooks`,`pv_edit_use-Retouch-Iris`,`pv_edit_use-Retouch-Whiten`,`pv_edit_use-Tools-Eraser`,`pv_edit_enter-Makeup-Blush`,`pv_edit_enter-Retouch-SkinTone`,`pv_edit_use-Retouch-SkinTone`,`pv_edit_save-Tools-Eraser`,`pv_edit_use-Tools-Stretch`
       ,aigc_enter_pv,aigc_generate_pv,aigc_download_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click,max_impression_pv,impression_pv,click_pv,pay_function_use_pv,free_function_use_pv,free_function_save_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv,function_num
       ,brand,last_active_days,active_category,life_time_active_days
       ,active_mins_7d,active_sessions_7d,active_mins_90d,active_sessions_90d,active_days_7d,active_days_90d,active_days_14d,active_days_31d,active_days_60d
       ,pay_function_use_pv_31,free_function_use_pv_31,free_function_save_pv_31,aigc_enter_pv_31,aigc_generate_pv_31,aigc_download_pv_31,sub_page_enter_31,sub_page_click_31,max_impression_pv_31,impression_pv_31,click_pv_31,pay_duffle_click_pv_31,free_duffle_click_pv_31,free_duffle_save_pv_31,function_num_31
       ,days,pay_duffle_click_ratio,pay_duffle_click_ratio_31,pay_function_use_ratio,pay_function_use_ratio_31
from airbrush-1324.temp.dws_dz_roi_predict_model_input


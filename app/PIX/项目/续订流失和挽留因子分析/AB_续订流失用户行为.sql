
drop table if exists airbrush-1324.temp.renewal_order_loss_behave;
create table airbrush-1324.temp.renewal_order_loss_behave as

select a.loss_type,a.date,a.app_id,a.uuid,a.subscription_period,date_diff(a.date,a.standard_order_date,day) start_day
    ,by_period
    ,is_cancell_future_1,is_cancell_future_3,is_cancell_future_7
    ,region,active_days_90d_type,install_days_type,last_active_days_type
    ,is_edit_selfi_7
--     ,is_active_30,is_edit_selfi_30,is_active_60,is_edit_selfi_60,is_active_90,is_edit_selfi_90
    ,is_current_trial,current_trial_day,is_current_subscription_cancelled,past_sub_times,trial_times,cancel_subscription_times,refund_subscription_times,promotional_paying_times
    ,is_new,is_ua,b.platform,brand,model_1,model_2,phone_price,install_days,life_time_active_days,last_active_days
    ,active_mins_90d,active_sessions_90d,active_mins_7d,active_sessions_7d,active_days_90d,active_days_7d,active_days_60,active_days_30,active_days_14,active_category
    ,id_num,active_days_365,holiday_active_days_365,weekend_active_days_365,weekend_include_five_active_days_365,holiday_active_ratio,weekend_active_ratio,weekend_include_five_active_ratio
    ,pv_camera_enter_all_all,pv_camera_save_Filter_all,pv_camera_save_all_all,pv_camera_taken_Filter_all,pv_camera_taken_all_all
    ,pv_edit_enter_AI_Style_all,pv_edit_enter_Creative_all,pv_edit_enter_Filter_all,pv_edit_enter_Hair_all,pv_edit_enter_Makeup_all,pv_edit_enter_Mykit_all,pv_edit_enter_Presets_all,pv_edit_enter_Retouch_all,pv_edit_enter_Tools_all,pv_edit_enter_all_all,pv_edit_save_AI_Style_all,pv_edit_save_Creative_all,pv_edit_save_Filter_all,pv_edit_save_Hair_all,pv_edit_save_Makeup_all,pv_edit_save_Presets_all,pv_edit_save_Retouch_all,pv_edit_save_Tools_all,pv_edit_save_all_all,pv_edit_save_else_all,pv_edit_use_AI_Style_all,pv_edit_use_Creative_all,pv_edit_use_Filter_all,pv_edit_use_Hair_all,pv_edit_use_Makeup_all,pv_edit_use_Presets_all,pv_edit_use_Retouch_all,pv_edit_use_Tools_all
    ,pv_edit_enter_Retouch_AI_Retouch,pv_edit_enter_Retouch_Acne,pv_edit_enter_Retouch_Align,pv_edit_enter_Retouch_Brighten,pv_edit_enter_Retouch_Contour,pv_edit_enter_Retouch_DarkCircles,pv_edit_enter_Retouch_Details,pv_edit_enter_Retouch_Firm,pv_edit_enter_Retouch_Foundation,pv_edit_enter_Retouch_Highlighter,pv_edit_enter_Retouch_Iris,pv_edit_enter_Retouch_Magic,pv_edit_enter_Retouch_Matte,pv_edit_enter_Retouch_Reshape,pv_edit_enter_Retouch_Resize,pv_edit_enter_Retouch_Sculpt,pv_edit_enter_Retouch_SkinTone,pv_edit_enter_Retouch_Smooth,pv_edit_enter_Retouch_Texture,pv_edit_enter_Retouch_Whiten,pv_edit_save_Retouch_AI_Retouch,pv_edit_save_Retouch_Acne,pv_edit_save_Retouch_Align,pv_edit_save_Retouch_Brighten,pv_edit_save_Retouch_Contour,pv_edit_save_Retouch_DarkCircles,pv_edit_save_Retouch_Details,pv_edit_save_Retouch_Firm,pv_edit_save_Retouch_Foundation,pv_edit_save_Retouch_Highlighter,pv_edit_save_Retouch_Iris,pv_edit_save_Retouch_Magic,pv_edit_save_Retouch_Matte,pv_edit_save_Retouch_Reshape,pv_edit_save_Retouch_Resize,pv_edit_save_Retouch_Sculpt,pv_edit_save_Retouch_SkinTone,pv_edit_save_Retouch_Smooth,pv_edit_save_Retouch_Texture,pv_edit_save_Retouch_Whiten,pv_edit_use_Retouch_AI_Retouch,pv_edit_use_Retouch_Acne,pv_edit_use_Retouch_Align,pv_edit_use_Retouch_Brighten,pv_edit_use_Retouch_Contour,pv_edit_use_Retouch_DarkCircles,pv_edit_use_Retouch_Details,pv_edit_use_Retouch_Firm,pv_edit_use_Retouch_Foundation,pv_edit_use_Retouch_Highlighter,pv_edit_use_Retouch_Iris,pv_edit_use_Retouch_Magic,pv_edit_use_Retouch_Matte,pv_edit_use_Retouch_Reshape,pv_edit_use_Retouch_Resize,pv_edit_use_Retouch_Sculpt,pv_edit_use_Retouch_SkinTone,pv_edit_use_Retouch_Smooth,pv_edit_use_Retouch_Texture,pv_edit_use_Retouch_Whiten
--     ,pv_camera_enter_all_all_30,pv_camera_save_Filter_all_30,pv_camera_save_all_all_30,pv_camera_taken_Filter_all_30,pv_camera_taken_all_all_30,pv_edit_enter_AI_Style_all_30,pv_edit_enter_Creative_all_30,pv_edit_enter_Filter_all_30,pv_edit_enter_Hair_all_30,pv_edit_enter_Makeup_all_30,pv_edit_enter_Mykit_all_30,pv_edit_enter_Presets_all_30,pv_edit_enter_Retouch_all_30,pv_edit_enter_Tools_all_30,pv_edit_enter_all_all_30,pv_edit_save_AI_Style_all_30,pv_edit_save_Creative_all_30,pv_edit_save_Filter_all_30,pv_edit_save_Hair_all_30,pv_edit_save_Makeup_all_30,pv_edit_save_Presets_all_30,pv_edit_save_Retouch_all_30,pv_edit_save_Tools_all_30,pv_edit_save_all_all_30,pv_edit_save_else_all_30,pv_edit_use_AI_Style_all_30,pv_edit_use_Creative_all_30,pv_edit_use_Filter_all_30,pv_edit_use_Hair_all_30,pv_edit_use_Makeup_all_30,pv_edit_use_Presets_all_30,pv_edit_use_Retouch_all_30,pv_edit_use_Tools_all_30
--     ,pv_camera_enter_all_all_60,pv_camera_save_Filter_all_60,pv_camera_save_all_all_60,pv_camera_taken_Filter_all_60,pv_camera_taken_all_all_60,pv_edit_enter_AI_Style_all_60,pv_edit_enter_Creative_all_60,pv_edit_enter_Filter_all_60,pv_edit_enter_Hair_all_60,pv_edit_enter_Makeup_all_60,pv_edit_enter_Mykit_all_60,pv_edit_enter_Presets_all_60,pv_edit_enter_Retouch_all_60,pv_edit_enter_Tools_all_60,pv_edit_enter_all_all_60,pv_edit_save_AI_Style_all_60,pv_edit_save_Creative_all_60,pv_edit_save_Filter_all_60,pv_edit_save_Hair_all_60,pv_edit_save_Makeup_all_60,pv_edit_save_Presets_all_60,pv_edit_save_Retouch_all_60,pv_edit_save_Tools_all_60,pv_edit_save_all_all_60,pv_edit_save_else_all_60,pv_edit_use_AI_Style_all_60,pv_edit_use_Creative_all_60,pv_edit_use_Filter_all_60,pv_edit_use_Hair_all_60,pv_edit_use_Makeup_all_60,pv_edit_use_Presets_all_60,pv_edit_use_Retouch_all_60,pv_edit_use_Tools_all_60
--     ,pv_camera_enter_all_all_90,pv_camera_save_Filter_all_90,pv_camera_save_all_all_90,pv_camera_taken_Filter_all_90,pv_camera_taken_all_all_90,pv_edit_enter_AI_Style_all_90,pv_edit_enter_Creative_all_90,pv_edit_enter_Filter_all_90,pv_edit_enter_Hair_all_90,pv_edit_enter_Makeup_all_90,pv_edit_enter_Mykit_all_90,pv_edit_enter_Presets_all_90,pv_edit_enter_Retouch_all_90,pv_edit_enter_Tools_all_90,pv_edit_enter_all_all_90,pv_edit_save_AI_Style_all_90,pv_edit_save_Creative_all_90,pv_edit_save_Filter_all_90,pv_edit_save_Hair_all_90,pv_edit_save_Makeup_all_90,pv_edit_save_Presets_all_90,pv_edit_save_Retouch_all_90,pv_edit_save_Tools_all_90,pv_edit_save_all_all_90,pv_edit_save_else_all_90,pv_edit_use_AI_Style_all_90,pv_edit_use_Creative_all_90,pv_edit_use_Filter_all_90,pv_edit_use_Hair_all_90,pv_edit_use_Makeup_all_90,pv_edit_use_Presets_all_90,pv_edit_use_Retouch_all_90,pv_edit_use_Tools_all_90

    ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click,force_sub_page_enter,force_sub_page_click,subscript_sub_page_enter,subscript_sub_page_click,other_sub_page_enter,other_sub_page_click,max_impression_pv,impression_pv,click_pv
--     ,aigc_enter_pv_30,aigc_use_pv_30,aigc_save_pv_30,pop_exposure_30,pop_click_30,content_exposure_30,content_click_30,max_module_positon_30,sub_page_enter_30,sub_page_click_30,force_sub_page_enter_30,force_sub_page_click_30,subscript_sub_page_enter_30,subscript_sub_page_click_30,other_sub_page_enter_30,other_sub_page_click_30,max_impression_pv_30,impression_pv_30,click_pv_30
--     ,aigc_enter_pv_60,aigc_use_pv_60,aigc_save_pv_60,pop_exposure_60,pop_click_60,content_exposure_60,content_click_60,max_module_positon_60,sub_page_enter_60,sub_page_click_60,force_sub_page_enter_60,force_sub_page_click_60,subscript_sub_page_enter_60,subscript_sub_page_click_60,other_sub_page_enter_60,other_sub_page_click_60,max_impression_pv_60,impression_pv_60,click_pv_60
--     ,aigc_enter_pv_90,aigc_use_pv_90,aigc_save_pv_90,pop_exposure_90,pop_click_90,content_exposure_90,content_click_90,max_module_positon_90,sub_page_enter_90,sub_page_click_90,force_sub_page_enter_90,force_sub_page_click_90,subscript_sub_page_enter_90,subscript_sub_page_click_90,other_sub_page_enter_90,other_sub_page_click_90,max_impression_pv_90,impression_pv_90,click_pv_90
    ,pay_function_click_pv,free_function_click_pv,free_function_save_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
    ,pay_function_click_pv_30,free_function_click_pv_30,free_function_save_pv_30,pay_function_click_pv_60,free_function_click_pv_60,free_function_save_pv_60,pay_function_click_pv_90,free_function_click_pv_90,free_function_save_pv_90
    ,pay_duffle_click_pv_30,free_duffle_click_pv_30,free_duffle_save_pv_30,pay_duffle_click_pv_60,free_duffle_click_pv_60,free_duffle_save_pv_60,pay_duffle_click_pv_90,free_duffle_click_pv_90,free_duffle_save_pv_90

    ,save_beauty_ratio,enter_beauty_ratio,beauty_enter_to_save_ratio,save_beauty_ratio_30,enter_beauty_ratio_30,beauty_enter_to_save_ratio_30,save_beauty_ratio_60,enter_beauty_ratio_60,beauty_enter_to_save_ratio_60,save_beauty_ratio_90,enter_beauty_ratio_90,beauty_enter_to_save_ratio_90
    ,function_num,function_num_pre,grow_function_num,function_num_30,function_num_60,function_num_90
    ,pay_duffle_click_ratio,pay_duffle_click_ratio_30,pay_duffle_click_ratio_60,pay_duffle_click_ratio_90
    ,pay_function_click_ratio,pay_function_click_ratio_30,pay_function_click_ratio_60,pay_function_click_ratio_90
    ,life_time_active_ratio
    ,pop_click_ratio,content_click_ratio,pop_click_ratio_30,content_click_ratio_30,pop_click_ratio_60,content_click_ratio_60,pop_click_ratio_90,content_click_ratio_90
    ,sub_page_click_ratio,sub_page_click_ratio_30,sub_page_click_ratio_60,sub_page_click_ratio_90
    ,subscript_sub_page_enter_ratio,subscript_sub_page_enter_ratio_30,subscript_sub_page_enter_ratio_60,subscript_sub_page_enter_ratio_90
    ,homepage_exposure_pv

from
(
    select *,'loss af 1 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2024-01-01' and '2024-09-30'
        and app_id = 'AirBrush'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>0
        and (is_cancell_future_1=1
            or (is_final_cancell=0 and rand()<0.005)
        )

    union all

    select *,'loss af 3 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2024-01-01' and '2024-09-30'
        and app_id = 'AirBrush'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>0
        and (date_diff(standard_cancel_date,date,day) = 3
    --     and (is_cancell_future_3=1
            or (is_final_cancell=0 and rand()<0.005)
        )

    union all

    select *,'loss af 7 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2024-01-01' and '2024-09-30'
        and app_id = 'AirBrush'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>0
        and (date_diff(standard_cancel_date,date,day) = 7
    --     and (is_cancell_future_7=1
            or (is_final_cancell=0 and rand()<0.005)
        )
) a
-- 活跃行为
join
(
    select *
    from airbrush-1324.temp.dws_dz_his_split_final_user_behave_pay_v
    where date between '2024-01-01' and '2024-09-30' and is_active_7=1
) b
on a.uuid=b.uuid and a.date=b.date




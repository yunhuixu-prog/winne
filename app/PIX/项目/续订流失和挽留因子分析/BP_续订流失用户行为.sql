
drop table if exists beautyplus-bc0ed.temp.renewal_order_loss_behave;
create table beautyplus-bc0ed.temp.renewal_order_loss_behave as

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
    ,pv_tab0_edit_entry,pv_tab0_edit_save,pv_tab0_movie_save,pv_tab0_movie_shoot,pv_tab0_selfie_entry,pv_tab0_shoot_save,pv_tab0_shoot_shoot,pv_tab0_video_save,pv_tab0_video_shoot,pv_tab0_videoedit_entry,pv_tab0_videoedit_save
    ,pv_tab1_edit_beauty_click,pv_tab1_edit_beauty_save,pv_tab1_edit_creative_click,pv_tab1_edit_creative_save,pv_tab1_edit_edit_click,pv_tab1_edit_edit_save,pv_tab1_edit_filter_click,pv_tab1_edit_filter_save,pv_tab1_edit_makeup_click,pv_tab1_edit_makeup_save,pv_tab1_edit_senioredit_click,pv_tab1_shoot_ar_save,pv_tab1_shoot_ar_shoot,pv_tab1_shoot_beauty_save,pv_tab1_shoot_filter_save,pv_tab1_shoot_filter_shoot,pv_tab1_shoot_look_save,pv_tab1_shoot_look_shoot,pv_tab1_shoot_makeup_save,pv_tab1_shoot_makeup_shoot
    ,pv_tab2_edit_beauty_AIbeauty_click,pv_tab2_edit_beauty_AIbeauty_save,pv_tab2_edit_beauty_Threedimensionalface_click,pv_tab2_edit_beauty_Threedimensionalface_save,pv_tab2_edit_beauty_detail_click,pv_tab2_edit_beauty_detail_save,pv_tab2_edit_beauty_doublechin_click,pv_tab2_edit_beauty_doublechin_save,pv_tab2_edit_beauty_evenskin_click,pv_tab2_edit_beauty_evenskin_save,pv_tab2_edit_beauty_expression_click,pv_tab2_edit_beauty_expression_save,pv_tab2_edit_beauty_eyecatching_click,pv_tab2_edit_beauty_eyecatching_save,pv_tab2_edit_beauty_eyedilated_click,pv_tab2_edit_beauty_eyedilated_save,pv_tab2_edit_beauty_facecolor_click,pv_tab2_edit_beauty_facecolor_save,pv_tab2_edit_beauty_faceslimming_click,pv_tab2_edit_beauty_faceslimming_save,pv_tab2_edit_beauty_faciallighting_click,pv_tab2_edit_beauty_faciallighting_save,pv_tab2_edit_beauty_facialreshaping_click,pv_tab2_edit_beauty_facialreshaping_save,pv_tab2_edit_beauty_hairdressing_click,pv_tab2_edit_beauty_hairdressing_save,pv_tab2_edit_beauty_lightendarkcircle_click,pv_tab2_edit_beauty_lightendarkcircle_save,pv_tab2_edit_beauty_microdermabrasion_click,pv_tab2_edit_beauty_microdermabrasion_save,pv_tab2_edit_beauty_narrownose_click,pv_tab2_edit_beauty_narrownose_save,pv_tab2_edit_beauty_oneclickbeauty_click,pv_tab2_edit_beauty_oneclickbeauty_save,pv_tab2_edit_beauty_orthodontics_click,pv_tab2_edit_beauty_orthodontics_save,pv_tab2_edit_beauty_removieacne_click,pv_tab2_edit_beauty_removieacne_save,pv_tab2_edit_beauty_removieshine_click,pv_tab2_edit_beauty_removieshine_save,pv_tab2_edit_beauty_removiewrinkles_click,pv_tab2_edit_beauty_removiewrinkles_save,pv_tab2_edit_beauty_shape_click,pv_tab2_edit_beauty_shape_save,pv_tab2_edit_beauty_shrinkhead_click,pv_tab2_edit_beauty_shrinkhead_save,pv_tab2_edit_beauty_teethwhitening_click,pv_tab2_edit_beauty_teethwhitening_save
--     ,pv_tab0_edit_entry_30,pv_tab0_edit_save_30,pv_tab0_movie_save_30,pv_tab0_movie_shoot_30,pv_tab0_selfie_entry_30,pv_tab0_shoot_save_30,pv_tab0_shoot_shoot_30,pv_tab0_video_save_30,pv_tab0_video_shoot_30,pv_tab0_videoedit_entry_30,pv_tab0_videoedit_save_30,pv_tab1_edit_beauty_click_30,pv_tab1_edit_beauty_save_30,pv_tab1_edit_creative_click_30,pv_tab1_edit_creative_save_30,pv_tab1_edit_edit_click_30,pv_tab1_edit_edit_save_30,pv_tab1_edit_filter_click_30,pv_tab1_edit_filter_save_30,pv_tab1_edit_makeup_click_30,pv_tab1_edit_makeup_save_30,pv_tab1_edit_senioredit_click_30,pv_tab1_shoot_ar_save_30,pv_tab1_shoot_ar_shoot_30,pv_tab1_shoot_beauty_save_30,pv_tab1_shoot_filter_save_30,pv_tab1_shoot_filter_shoot_30,pv_tab1_shoot_look_save_30,pv_tab1_shoot_look_shoot_30,pv_tab1_shoot_makeup_save_30,pv_tab1_shoot_makeup_shoot_30
--     ,pv_tab0_edit_entry_60,pv_tab0_edit_save_60,pv_tab0_movie_save_60,pv_tab0_movie_shoot_60,pv_tab0_selfie_entry_60,pv_tab0_shoot_save_60,pv_tab0_shoot_shoot_60,pv_tab0_video_save_60,pv_tab0_video_shoot_60,pv_tab0_videoedit_entry_60,pv_tab0_videoedit_save_60,pv_tab1_edit_beauty_click_60,pv_tab1_edit_beauty_save_60,pv_tab1_edit_creative_click_60,pv_tab1_edit_creative_save_60,pv_tab1_edit_edit_click_60,pv_tab1_edit_edit_save_60,pv_tab1_edit_filter_click_60,pv_tab1_edit_filter_save_60,pv_tab1_edit_makeup_click_60,pv_tab1_edit_makeup_save_60,pv_tab1_edit_senioredit_click_60,pv_tab1_shoot_ar_save_60,pv_tab1_shoot_ar_shoot_60,pv_tab1_shoot_beauty_save_60,pv_tab1_shoot_filter_save_60,pv_tab1_shoot_filter_shoot_60,pv_tab1_shoot_look_save_60,pv_tab1_shoot_look_shoot_60,pv_tab1_shoot_makeup_save_60,pv_tab1_shoot_makeup_shoot_60
--     ,pv_tab0_edit_entry_90,pv_tab0_edit_save_90,pv_tab0_movie_save_90,pv_tab0_movie_shoot_90,pv_tab0_selfie_entry_90,pv_tab0_shoot_save_90,pv_tab0_shoot_shoot_90,pv_tab0_video_save_90,pv_tab0_video_shoot_90,pv_tab0_videoedit_entry_90,pv_tab0_videoedit_save_90,pv_tab1_edit_beauty_click_90,pv_tab1_edit_beauty_save_90,pv_tab1_edit_creative_click_90,pv_tab1_edit_creative_save_90,pv_tab1_edit_edit_click_90,pv_tab1_edit_edit_save_90,pv_tab1_edit_filter_click_90,pv_tab1_edit_filter_save_90,pv_tab1_edit_makeup_click_90,pv_tab1_edit_makeup_save_90,pv_tab1_edit_senioredit_click_90,pv_tab1_shoot_ar_save_90,pv_tab1_shoot_ar_shoot_90,pv_tab1_shoot_beauty_save_90,pv_tab1_shoot_filter_save_90,pv_tab1_shoot_filter_shoot_90,pv_tab1_shoot_look_save_90,pv_tab1_shoot_look_shoot_90,pv_tab1_shoot_makeup_save_90,pv_tab1_shoot_makeup_shoot_90
    ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon
    ,sub_page_enter,sub_page_click,force_sub_page_enter,force_sub_page_click,subscript_sub_page_enter,subscript_sub_page_click,other_sub_page_enter,other_sub_page_click,max_impression_pv,impression_pv,click_pv
--     ,aigc_enter_pv_30,aigc_use_pv_30,aigc_save_pv_30,pop_exposure_30,pop_click_30,content_exposure_30,content_click_30,max_module_positon_30,sub_page_enter_30,sub_page_click_30,force_sub_page_enter_30,force_sub_page_click_30,subscript_sub_page_enter_30,subscript_sub_page_click_30,other_sub_page_enter_30,other_sub_page_click_30,max_impression_pv_30,impression_pv_30,click_pv_30
--     ,aigc_enter_pv_60,aigc_use_pv_60,aigc_save_pv_60,pop_exposure_60,pop_click_60,content_exposure_60,content_click_60,max_module_positon_60,sub_page_enter_60,sub_page_click_60,force_sub_page_enter_60,force_sub_page_click_60,subscript_sub_page_enter_60,subscript_sub_page_click_60,other_sub_page_enter_60,other_sub_page_click_60,max_impression_pv_60,impression_pv_60,click_pv_60
--     ,aigc_enter_pv_90,aigc_use_pv_90,aigc_save_pv_90,pop_exposure_90,pop_click_90,content_exposure_90,content_click_90,max_module_positon_90,sub_page_enter_90,sub_page_click_90,force_sub_page_enter_90,force_sub_page_click_90,subscript_sub_page_enter_90,subscript_sub_page_click_90,other_sub_page_enter_90,other_sub_page_click_90,max_impression_pv_90,impression_pv_90,click_pv_90
    ,puzzle_click_pv,puzzle_save_pv,puzzle_click_pv_30,puzzle_save_pv_30,puzzle_click_pv_60,puzzle_save_pv_60,puzzle_click_pv_90,puzzle_save_pv_90
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
    ,homepage_exposure_pv,homepage_click_pv,homepage_feature_show_pv,homepage_feature_click_pv,homepage_banner_show_pv,homepage_banner_click_pv,homepage_reconmend_show_pv,homepage_reconmend_click_pv,homepage_topic_show_pv,homepage_topic_click_pv,homepage_miniapp_show_pv,homepage_miniapp_click_pv
--     ,homepage_exposure_pv_30,homepage_click_pv_30,homepage_feature_show_pv_30,homepage_feature_click_pv_30,homepage_banner_show_pv_30,homepage_banner_click_pv_30,homepage_reconmend_show_pv_30,homepage_reconmend_click_pv_30,homepage_topic_show_pv_30,homepage_topic_click_pv_30,homepage_miniapp_show_pv_30,homepage_miniapp_click_pv_30
--     ,homepage_exposure_pv_60,homepage_click_pv_60,homepage_feature_show_pv_60,homepage_feature_click_pv_60,homepage_banner_show_pv_60,homepage_banner_click_pv_60,homepage_reconmend_show_pv_60,homepage_reconmend_click_pv_60,homepage_topic_show_pv_60,homepage_topic_click_pv_60,homepage_miniapp_show_pv_60,homepage_miniapp_click_pv_60
--     ,homepage_exposure_pv_90,homepage_click_pv_90,homepage_feature_show_pv_90,homepage_feature_click_pv_90,homepage_banner_show_pv_90,homepage_banner_click_pv_90,homepage_reconmend_show_pv_90,homepage_reconmend_click_pv_90,homepage_topic_show_pv_90,homepage_topic_click_pv_90,homepage_miniapp_show_pv_90,homepage_miniapp_click_pv_90
from
(
    select *,'loss af 1 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2023-06-01' and '2024-09-30'
        and app_id = 'BeautyPlus'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>=7
        and (is_cancell_future_1=1
                or (is_final_cancell=0 and rand()<0.005)
        )

    union all

    select *,'loss af 3 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2023-06-01' and '2024-09-30'
        and app_id = 'BeautyPlus'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>=7
        and (date_diff(standard_cancel_date,date,day) = 3
    --     and (is_cancell_future_3=1
                or (is_final_cancell=0 and rand()<0.005)
        )

    union all

    select *,'loss af 7 day' loss_type
    from dataintegration-265403.temp.renewal_order_id_loss_data
    where date between '2023-06-01' and '2024-09-30'
        and app_id = 'BeautyPlus'
        and is_now_cancell=0
        and is_refund=0
        and is_active_7=1
        and date_diff(date,standard_order_date,day)>=7
        and (date_diff(standard_cancel_date,date,day) = 7
    --     and (is_cancell_future_7=1
            or (is_final_cancell=0 and rand()<0.005)
        )
) a
-- 活跃行为
join
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_pay_v
    where date between '2023-06-01' and '2024-09-30' and is_active_7=1
) b
on a.uuid=b.uuid and a.date=b.date




-- -- 初始化
-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_his_split_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_his_split_user_behave as

-- 非初始化
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=368)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=359)).strftime("%Y-%m-%d") }}';
-- DECLARE mDATE_START DATE DEFAULT '2024-03-01';
-- DECLARE mDATE_END DATE DEFAULT '2024-03-31';
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.dws_dz_his_split_user_behave where date = mDATE;
insert into beautyplus-bc0ed.temp.dws_dz_his_split_user_behave


-- 历史dau
with goal_users as
(
    select user_pseudo_id
            ,is_new
            ,is_ua
            ,media_source
            ,android_level
            ,permanent_country
            ,platform
            ,brand
            ,model
            ,t2.phone_price
            ,language
            ,operating_system
            ,first_active_date
            ,DATE_DIFF(event_date_hk,first_active_date,DAY)+1 install_days
            ,last_active_date
            ,DATE_DIFF(event_date_hk,last_active_date,DAY) last_active_days
            ,life_time_active_days
            ,active_mins_90d
            ,active_sessions_90d
            ,active_days_90d
            ,active_mins_7d
            ,active_sessions_7d
            ,active_days_7d
            ,active_category
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user` t1
    left join (select mobile_brand_name,mobile_model_name,max(phone_price) phone_price from `dataintegration-265403.view.dim_ya_common_model_phone_price` group by 1,2) t2
    on t1.model=t2.mobile_model_name and t1.brand=t2.mobile_brand_name
    where event_date_hk=mDATE
        and case when event_date_hk<='2024-08-15' then first_active_date>='2022-01-01'
                 when event_date_hk>'2024-08-15' then last_active_date>=date_sub(event_date_hk,interval 365 day) end
)
,
-- 近7天用户行为
core_behave as
(
    SELECT user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry, sum(pv_tab0_edit_save) pv_tab0_edit_save, sum(pv_tab0_movie_save) pv_tab0_movie_save, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry, sum(pv_tab0_shoot_save) pv_tab0_shoot_save, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot, sum(pv_tab0_video_save) pv_tab0_video_save, sum(pv_tab0_video_shoot) pv_tab0_video_shoot, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot
        , sum(pv_tab2_edit_beauty_AIbeauty_click) pv_tab2_edit_beauty_AIbeauty_click, sum(pv_tab2_edit_beauty_AIbeauty_save) pv_tab2_edit_beauty_AIbeauty_save, sum(pv_tab2_edit_beauty_Threedimensionalface_click) pv_tab2_edit_beauty_Threedimensionalface_click, sum(pv_tab2_edit_beauty_Threedimensionalface_save) pv_tab2_edit_beauty_Threedimensionalface_save, sum(pv_tab2_edit_beauty_detail_click) pv_tab2_edit_beauty_detail_click, sum(pv_tab2_edit_beauty_detail_save) pv_tab2_edit_beauty_detail_save, sum(pv_tab2_edit_beauty_doublechin_click) pv_tab2_edit_beauty_doublechin_click, sum(pv_tab2_edit_beauty_doublechin_save) pv_tab2_edit_beauty_doublechin_save, sum(pv_tab2_edit_beauty_evenskin_click) pv_tab2_edit_beauty_evenskin_click, sum(pv_tab2_edit_beauty_evenskin_save) pv_tab2_edit_beauty_evenskin_save, sum(pv_tab2_edit_beauty_expression_click) pv_tab2_edit_beauty_expression_click, sum(pv_tab2_edit_beauty_expression_save) pv_tab2_edit_beauty_expression_save, sum(pv_tab2_edit_beauty_eyecatching_click) pv_tab2_edit_beauty_eyecatching_click, sum(pv_tab2_edit_beauty_eyecatching_save) pv_tab2_edit_beauty_eyecatching_save, sum(pv_tab2_edit_beauty_eyedilated_click) pv_tab2_edit_beauty_eyedilated_click, sum(pv_tab2_edit_beauty_eyedilated_save) pv_tab2_edit_beauty_eyedilated_save, sum(pv_tab2_edit_beauty_facecolor_click) pv_tab2_edit_beauty_facecolor_click, sum(pv_tab2_edit_beauty_facecolor_save) pv_tab2_edit_beauty_facecolor_save, sum(pv_tab2_edit_beauty_faceslimming_click) pv_tab2_edit_beauty_faceslimming_click, sum(pv_tab2_edit_beauty_faceslimming_save) pv_tab2_edit_beauty_faceslimming_save, sum(pv_tab2_edit_beauty_faciallighting_click) pv_tab2_edit_beauty_faciallighting_click, sum(pv_tab2_edit_beauty_faciallighting_save) pv_tab2_edit_beauty_faciallighting_save, sum(pv_tab2_edit_beauty_facialreshaping_click) pv_tab2_edit_beauty_facialreshaping_click, sum(pv_tab2_edit_beauty_facialreshaping_save) pv_tab2_edit_beauty_facialreshaping_save, sum(pv_tab2_edit_beauty_hairdressing_click) pv_tab2_edit_beauty_hairdressing_click, sum(pv_tab2_edit_beauty_hairdressing_save) pv_tab2_edit_beauty_hairdressing_save, sum(pv_tab2_edit_beauty_lightendarkcircle_click) pv_tab2_edit_beauty_lightendarkcircle_click, sum(pv_tab2_edit_beauty_lightendarkcircle_save) pv_tab2_edit_beauty_lightendarkcircle_save, sum(pv_tab2_edit_beauty_microdermabrasion_click) pv_tab2_edit_beauty_microdermabrasion_click, sum(pv_tab2_edit_beauty_microdermabrasion_save) pv_tab2_edit_beauty_microdermabrasion_save, sum(pv_tab2_edit_beauty_narrownose_click) pv_tab2_edit_beauty_narrownose_click, sum(pv_tab2_edit_beauty_narrownose_save) pv_tab2_edit_beauty_narrownose_save, sum(pv_tab2_edit_beauty_oneclickbeauty_click) pv_tab2_edit_beauty_oneclickbeauty_click, sum(pv_tab2_edit_beauty_oneclickbeauty_save) pv_tab2_edit_beauty_oneclickbeauty_save, sum(pv_tab2_edit_beauty_orthodontics_click) pv_tab2_edit_beauty_orthodontics_click, sum(pv_tab2_edit_beauty_orthodontics_save) pv_tab2_edit_beauty_orthodontics_save, sum(pv_tab2_edit_beauty_removieacne_click) pv_tab2_edit_beauty_removieacne_click, sum(pv_tab2_edit_beauty_removieacne_save) pv_tab2_edit_beauty_removieacne_save, sum(pv_tab2_edit_beauty_removieshine_click) pv_tab2_edit_beauty_removieshine_click, sum(pv_tab2_edit_beauty_removieshine_save) pv_tab2_edit_beauty_removieshine_save, sum(pv_tab2_edit_beauty_removiewrinkles_click) pv_tab2_edit_beauty_removiewrinkles_click, sum(pv_tab2_edit_beauty_removiewrinkles_save) pv_tab2_edit_beauty_removiewrinkles_save, sum(pv_tab2_edit_beauty_shape_click) pv_tab2_edit_beauty_shape_click, sum(pv_tab2_edit_beauty_shape_save) pv_tab2_edit_beauty_shape_save, sum(pv_tab2_edit_beauty_shrinkhead_click) pv_tab2_edit_beauty_shrinkhead_click, sum(pv_tab2_edit_beauty_shrinkhead_save) pv_tab2_edit_beauty_shrinkhead_save, sum(pv_tab2_edit_beauty_teethwhitening_click) pv_tab2_edit_beauty_teethwhitening_click, sum(pv_tab2_edit_beauty_teethwhitening_save) pv_tab2_edit_beauty_teethwhitening_save
        , sum(pv_tab2_edit_creative_background_click) pv_tab2_edit_creative_background_click, sum(pv_tab2_edit_creative_background_save) pv_tab2_edit_creative_background_save, sum(pv_tab2_edit_creative_formula_click) pv_tab2_edit_creative_formula_click, sum(pv_tab2_edit_creative_formula_save) pv_tab2_edit_creative_formula_save, sum(pv_tab2_edit_creative_graffiti_click) pv_tab2_edit_creative_graffiti_click, sum(pv_tab2_edit_creative_graffiti_save) pv_tab2_edit_creative_graffiti_save, sum(pv_tab2_edit_creative_sticker_click) pv_tab2_edit_creative_sticker_click, sum(pv_tab2_edit_creative_sticker_save) pv_tab2_edit_creative_sticker_save, sum(pv_tab2_edit_creative_text_click) pv_tab2_edit_creative_text_click, sum(pv_tab2_edit_creative_text_save) pv_tab2_edit_creative_text_save, sum(pv_tab2_edit_edit_AIenhance_click) pv_tab2_edit_edit_AIenhance_click, sum(pv_tab2_edit_edit_AIenhance_save) pv_tab2_edit_edit_AIenhance_save, sum(pv_tab2_edit_edit_AIextension_click) pv_tab2_edit_edit_AIextension_click, sum(pv_tab2_edit_edit_AIextension_save) pv_tab2_edit_edit_AIextension_save, sum(pv_tab2_edit_edit_adjustment_click) pv_tab2_edit_edit_adjustment_click, sum(pv_tab2_edit_edit_ar_click) pv_tab2_edit_edit_ar_click, sum(pv_tab2_edit_edit_ar_save) pv_tab2_edit_edit_ar_save, sum(pv_tab2_edit_edit_blur_click) pv_tab2_edit_edit_blur_click, sum(pv_tab2_edit_edit_blur_save) pv_tab2_edit_edit_blur_save, sum(pv_tab2_edit_edit_clone_click) pv_tab2_edit_edit_clone_click, sum(pv_tab2_edit_edit_clone_save) pv_tab2_edit_edit_clone_save, sum(pv_tab2_edit_edit_composition_click) pv_tab2_edit_edit_composition_click, sum(pv_tab2_edit_edit_composition_save) pv_tab2_edit_edit_composition_save, sum(pv_tab2_edit_edit_cutout_click) pv_tab2_edit_edit_cutout_click, sum(pv_tab2_edit_edit_cutout_save) pv_tab2_edit_edit_cutout_save, sum(pv_tab2_edit_edit_dispersion_click) pv_tab2_edit_edit_dispersion_click, sum(pv_tab2_edit_edit_dispersion_save) pv_tab2_edit_edit_dispersion_save, sum(pv_tab2_edit_edit_elimination_click) pv_tab2_edit_edit_elimination_click, sum(pv_tab2_edit_edit_elimination_save) pv_tab2_edit_edit_elimination_save, sum(pv_tab2_edit_edit_mosaic_click) pv_tab2_edit_edit_mosaic_click, sum(pv_tab2_edit_edit_mosaic_save) pv_tab2_edit_edit_mosaic_save, sum(pv_tab2_edit_edit_photorepair_click) pv_tab2_edit_edit_photorepair_click, sum(pv_tab2_edit_edit_photorepair_save) pv_tab2_edit_edit_photorepair_save, sum(pv_tab2_edit_edit_stylization_click) pv_tab2_edit_edit_stylization_click, sum(pv_tab2_edit_edit_stylization_save) pv_tab2_edit_edit_stylization_save, sum(pv_tab2_shoot_beauty_bigeyes_save) pv_tab2_shoot_beauty_bigeyes_save, sum(pv_tab2_shoot_beauty_eyecatching_save) pv_tab2_shoot_beauty_eyecatching_save, sum(pv_tab2_shoot_beauty_facecolor_save) pv_tab2_shoot_beauty_facecolor_save, sum(pv_tab2_shoot_beauty_faceslimming_save) pv_tab2_shoot_beauty_faceslimming_save, sum(pv_tab2_shoot_beauty_microdermabrasion_save) pv_tab2_shoot_beauty_microdermabrasion_save, sum(pv_tab2_shoot_beauty_oneclickbody_save) pv_tab2_shoot_beauty_oneclickbody_save, sum(pv_tab2_shoot_beauty_removieacnefreckles_save) pv_tab2_shoot_beauty_removieacnefreckles_save, sum(pv_tab2_shoot_beauty_removiedarkcircles_save) pv_tab2_shoot_beauty_removiedarkcircles_save, sum(pv_tab2_shoot_beauty_removienasolabial_save) pv_tab2_shoot_beauty_removienasolabial_save, sum(pv_tab2_shoot_beauty_shrinkhead_save) pv_tab2_shoot_beauty_shrinkhead_save, sum(pv_tab2_shoot_beauty_softhair_save) pv_tab2_shoot_beauty_softhair_save, sum(pv_tab2_shoot_beauty_teethwhitening_save) pv_tab2_shoot_beauty_teethwhitening_save, sum(pv_tab2_shoot_beauty_thinnose_save) pv_tab2_shoot_beauty_thinnose_save, sum(pv_tab2_shoot_makeup_blush_save) pv_tab2_shoot_makeup_blush_save, sum(pv_tab2_shoot_makeup_blush_shoot) pv_tab2_shoot_makeup_blush_shoot, sum(pv_tab2_shoot_makeup_contactlenses_save) pv_tab2_shoot_makeup_contactlenses_save, sum(pv_tab2_shoot_makeup_contactlenses_shoot) pv_tab2_shoot_makeup_contactlenses_shoot, sum(pv_tab2_shoot_makeup_dyehair_save) pv_tab2_shoot_makeup_dyehair_save, sum(pv_tab2_shoot_makeup_dyehair_shoot) pv_tab2_shoot_makeup_dyehair_shoot, sum(pv_tab2_shoot_makeup_eyebrow_save) pv_tab2_shoot_makeup_eyebrow_save, sum(pv_tab2_shoot_makeup_eyebrow_shoot) pv_tab2_shoot_makeup_eyebrow_shoot, sum(pv_tab2_shoot_makeup_eyelash_save) pv_tab2_shoot_makeup_eyelash_save, sum(pv_tab2_shoot_makeup_eyelash_shoot) pv_tab2_shoot_makeup_eyelash_shoot, sum(pv_tab2_shoot_makeup_eyeshadow_save) pv_tab2_shoot_makeup_eyeshadow_save, sum(pv_tab2_shoot_makeup_eyeshadow_shoot) pv_tab2_shoot_makeup_eyeshadow_shoot, sum(pv_tab2_shoot_makeup_freckle_save) pv_tab2_shoot_makeup_freckle_save, sum(pv_tab2_shoot_makeup_freckle_shoot) pv_tab2_shoot_makeup_freckle_shoot, sum(pv_tab2_shoot_makeup_lipstick_save) pv_tab2_shoot_makeup_lipstick_save, sum(pv_tab2_shoot_makeup_lipstick_shoot) pv_tab2_shoot_makeup_lipstick_shoot, sum(pv_tab2_shoot_makeup_lyingsilkworm_save) pv_tab2_shoot_makeup_lyingsilkworm_save, sum(pv_tab2_shoot_makeup_lyingsilkworm_shoot) pv_tab2_shoot_makeup_lyingsilkworm_shoot, sum(pv_tab2_shoot_makeup_trimming_save) pv_tab2_shoot_makeup_trimming_save, sum(pv_tab2_shoot_makeup_trimming_shoot) pv_tab2_shoot_makeup_trimming_shoot
        , sum(puzzle_click_pv) puzzle_click_pv, sum(puzzle_save_pv) puzzle_save_pv, sum(pay_function_click_pv) pay_function_click_pv, sum(free_function_click_pv) free_function_click_pv, sum(free_function_save_pv) free_function_save_pv, sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv, sum(homepage_exposure_pv) homepage_exposure_pv, sum(homepage_click_pv) homepage_click_pv, sum(homepage_feature_show_pv) homepage_feature_show_pv, sum(homepage_feature_click_pv) homepage_feature_click_pv, sum(homepage_banner_show_pv) homepage_banner_show_pv, sum(homepage_banner_click_pv) homepage_banner_click_pv, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv, sum(homepage_topic_show_pv) homepage_topic_show_pv, sum(homepage_topic_click_pv) homepage_topic_click_pv, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv
    FROM beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave
    where event_date between date_sub(mDATE, interval 6 day) and mDATE
    group by 1
)
,
-- 近30天用户核心行为
core_behave_30 as
(
    SELECT user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry_30, sum(pv_tab0_edit_save) pv_tab0_edit_save_30, sum(pv_tab0_movie_save) pv_tab0_movie_save_30, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot_30, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry_30, sum(pv_tab0_shoot_save) pv_tab0_shoot_save_30, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot_30, sum(pv_tab0_video_save) pv_tab0_video_save_30, sum(pv_tab0_video_shoot) pv_tab0_video_shoot_30, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry_30, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save_30, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click_30, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save_30, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click_30, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save_30, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click_30, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save_30, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click_30, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save_30, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click_30, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save_30, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click_30, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save_30, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot_30, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save_30, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save_30, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot_30, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save_30, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot_30, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save_30, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot_30
        , sum(puzzle_click_pv) puzzle_click_pv_30, sum(puzzle_save_pv) puzzle_save_pv_30, sum(pay_function_click_pv) pay_function_click_pv_30, sum(free_function_click_pv) free_function_click_pv_30, sum(free_function_save_pv) free_function_save_pv_30, sum(pay_duffle_click_pv) pay_duffle_click_pv_30, sum(free_duffle_click_pv) free_duffle_click_pv_30, sum(free_duffle_save_pv) free_duffle_save_pv_30, sum(homepage_exposure_pv) homepage_exposure_pv_30, sum(homepage_click_pv) homepage_click_pv_30, sum(homepage_feature_show_pv) homepage_feature_show_pv_30, sum(homepage_feature_click_pv) homepage_feature_click_pv_30, sum(homepage_banner_show_pv) homepage_banner_show_pv_30, sum(homepage_banner_click_pv) homepage_banner_click_pv_30, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv_30, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv_30, sum(homepage_topic_show_pv) homepage_topic_show_pv_30, sum(homepage_topic_click_pv) homepage_topic_click_pv_30, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv_30, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv_30
    FROM beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave
    where event_date between date_sub(mDATE, interval 29 day) and mDATE
    group by 1
)
,
-- 近60天用户核心行为
core_behave_60 as
(
    SELECT user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry_60, sum(pv_tab0_edit_save) pv_tab0_edit_save_60, sum(pv_tab0_movie_save) pv_tab0_movie_save_60, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot_60, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry_60, sum(pv_tab0_shoot_save) pv_tab0_shoot_save_60, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot_60, sum(pv_tab0_video_save) pv_tab0_video_save_60, sum(pv_tab0_video_shoot) pv_tab0_video_shoot_60, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry_60, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save_60, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click_60, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save_60, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click_60, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save_60, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click_60, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save_60, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click_60, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save_60, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click_60, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save_60, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click_60, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save_60, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot_60, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save_60, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save_60, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot_60, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save_60, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot_60, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save_60, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot_60
        , sum(puzzle_click_pv) puzzle_click_pv_60, sum(puzzle_save_pv) puzzle_save_pv_60, sum(pay_function_click_pv) pay_function_click_pv_60, sum(free_function_click_pv) free_function_click_pv_60, sum(free_function_save_pv) free_function_save_pv_60, sum(pay_duffle_click_pv) pay_duffle_click_pv_60, sum(free_duffle_click_pv) free_duffle_click_pv_60, sum(free_duffle_save_pv) free_duffle_save_pv_60, sum(homepage_exposure_pv) homepage_exposure_pv_60, sum(homepage_click_pv) homepage_click_pv_60, sum(homepage_feature_show_pv) homepage_feature_show_pv_60, sum(homepage_feature_click_pv) homepage_feature_click_pv_60, sum(homepage_banner_show_pv) homepage_banner_show_pv_60, sum(homepage_banner_click_pv) homepage_banner_click_pv_60, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv_60, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv_60, sum(homepage_topic_show_pv) homepage_topic_show_pv_60, sum(homepage_topic_click_pv) homepage_topic_click_pv_60, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv_60, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv_60
    FROM beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave
    where event_date between date_sub(mDATE, interval 59 day) and mDATE
    group by 1
)
,
-- 近90天用户核心行为
core_behave_90 as
(
    SELECT user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry_90, sum(pv_tab0_edit_save) pv_tab0_edit_save_90, sum(pv_tab0_movie_save) pv_tab0_movie_save_90, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot_90, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry_90, sum(pv_tab0_shoot_save) pv_tab0_shoot_save_90, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot_90, sum(pv_tab0_video_save) pv_tab0_video_save_90, sum(pv_tab0_video_shoot) pv_tab0_video_shoot_90, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry_90, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save_90, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click_90, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save_90, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click_90, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save_90, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click_90, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save_90, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click_90, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save_90, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click_90, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save_90, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click_90, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save_90, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot_90, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save_90, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save_90, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot_90, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save_90, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot_90, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save_90, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot_90
        , sum(puzzle_click_pv) puzzle_click_pv_90, sum(puzzle_save_pv) puzzle_save_pv_90, sum(pay_function_click_pv) pay_function_click_pv_90, sum(free_function_click_pv) free_function_click_pv_90, sum(free_function_save_pv) free_function_save_pv_90, sum(pay_duffle_click_pv) pay_duffle_click_pv_90, sum(free_duffle_click_pv) free_duffle_click_pv_90, sum(free_duffle_save_pv) free_duffle_save_pv_90, sum(homepage_exposure_pv) homepage_exposure_pv_90, sum(homepage_click_pv) homepage_click_pv_90, sum(homepage_feature_show_pv) homepage_feature_show_pv_90, sum(homepage_feature_click_pv) homepage_feature_click_pv_90, sum(homepage_banner_show_pv) homepage_banner_show_pv_90, sum(homepage_banner_click_pv) homepage_banner_click_pv_90, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv_90, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv_90, sum(homepage_topic_show_pv) homepage_topic_show_pv_90, sum(homepage_topic_click_pv) homepage_topic_click_pv_90, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv_90, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv_90
    FROM beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave
    where event_date between date_sub(mDATE, interval 89 day) and mDATE
    group by 1
)
,
-- 2级功能使用情况（统计指标）
function_use as
(
    select user_pseudo_id,function_num,function_num_pre,function_num_30,function_num_60,function_num_90
        ,IFNULL(function_num, 0)-IFNULL(function_num_pre, 0) grow_function_num
    from
    (
        select user_pseudo_id
            , count (distinct case when event_date between date_sub(mDATE, interval 6 day) and mDATE then function end) function_num
            , count (distinct case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then function end) function_num_pre

            , count (distinct case when event_date between date_sub(mDATE, interval 29 day) and mDATE then function end) function_num_30
            , count (distinct case when event_date between date_sub(mDATE, interval 59 day) and mDATE then function end) function_num_60
            , count (distinct function) function_num_90
        from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
        where event_date between date_sub(mDATE, interval 89 day) and mDATE
            and mark=2 and action in ('点击', '拍摄')
        group by 1
    )
)
,
-- 其他行为及增长
other_behave as
(
    select user_pseudo_id
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_enter_pv end) aigc_enter_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_use_pv end) aigc_use_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_save_pv end) aigc_save_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then pop_exposure end) pop_exposure
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then pop_click end) pop_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then content_exposure end) content_exposure
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then content_click end) content_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then max_module_positon end) max_module_positon
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then sub_page_enter end) sub_page_enter
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then sub_page_click end) sub_page_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then force_sub_page_enter end) force_sub_page_enter
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then force_sub_page_click end) force_sub_page_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then subscript_sub_page_enter end) subscript_sub_page_enter
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then subscript_sub_page_click end) subscript_sub_page_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then other_sub_page_enter end) other_sub_page_enter
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then other_sub_page_click end) other_sub_page_click
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then max_impression_pv end) max_impression_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then impression_pv end) impression_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then click_pv end) click_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then share_pv end) share_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then search_pv end) search_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then eva_imp_pv end) eva_imp_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then eva_pv end) eva_pv
        , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then high_eva_pv end) high_eva_pv

        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then aigc_enter_pv end) aigc_enter_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then aigc_use_pv end) aigc_use_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then aigc_save_pv end) aigc_save_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then pop_exposure end) pop_exposure_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then pop_click end) pop_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then content_exposure end) content_exposure_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then content_click end) content_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then max_module_positon end) max_module_positon_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then sub_page_enter end) sub_page_enter_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then sub_page_click end) sub_page_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then force_sub_page_enter end) force_sub_page_enter_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then force_sub_page_click end) force_sub_page_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then subscript_sub_page_enter end) subscript_sub_page_enter_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then subscript_sub_page_click end) subscript_sub_page_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then other_sub_page_enter end) other_sub_page_enter_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then other_sub_page_click end) other_sub_page_click_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then max_impression_pv end) max_impression_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then impression_pv end) impression_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then click_pv end) click_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then share_pv end) share_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then search_pv end) search_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then eva_imp_pv end) eva_imp_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then eva_pv end) eva_pv_30
        , sum (case when date between date_sub(mDATE, interval 29 day) and mDATE then high_eva_pv end) high_eva_pv_30

        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then aigc_enter_pv end) aigc_enter_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then aigc_use_pv end) aigc_use_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then aigc_save_pv end) aigc_save_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then pop_exposure end) pop_exposure_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then pop_click end) pop_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then content_exposure end) content_exposure_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then content_click end) content_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then max_module_positon end) max_module_positon_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then sub_page_enter end) sub_page_enter_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then sub_page_click end) sub_page_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then force_sub_page_enter end) force_sub_page_enter_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then force_sub_page_click end) force_sub_page_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then subscript_sub_page_enter end) subscript_sub_page_enter_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then subscript_sub_page_click end) subscript_sub_page_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then other_sub_page_enter end) other_sub_page_enter_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then other_sub_page_click end) other_sub_page_click_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then max_impression_pv end) max_impression_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then impression_pv end) impression_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then click_pv end) click_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then share_pv end) share_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then search_pv end) search_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then eva_imp_pv end) eva_imp_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then eva_pv end) eva_pv_60
        , sum (case when date between date_sub(mDATE, interval 59 day) and mDATE then high_eva_pv end) high_eva_pv_60

        , sum (aigc_enter_pv) aigc_enter_pv_90
        , sum (aigc_use_pv) aigc_use_pv_90
        , sum (aigc_save_pv) aigc_save_pv_90
        , sum (pop_exposure) pop_exposure_90
        , sum (pop_click) pop_click_90
        , sum (content_exposure) content_exposure_90
        , sum (content_click) content_click_90
        , sum (max_module_positon) max_module_positon_90
        , sum (sub_page_enter) sub_page_enter_90
        , sum (sub_page_click) sub_page_click_90
        , sum (force_sub_page_enter) force_sub_page_enter_90
        , sum (force_sub_page_click) force_sub_page_click_90
        , sum (subscript_sub_page_enter) subscript_sub_page_enter_90
        , sum (subscript_sub_page_click) subscript_sub_page_click_90
        , sum (other_sub_page_enter) other_sub_page_enter_90
        , sum (other_sub_page_click) other_sub_page_click_90
        , sum (max_impression_pv) max_impression_pv_90
        , sum (impression_pv) impression_pv_90
        , sum (click_pv) click_pv_90
        , sum (share_pv) share_pv_90
        , sum (search_pv) search_pv_90
        , sum (eva_imp_pv) eva_imp_pv_90
        , sum (eva_pv) eva_pv_90
        , sum (high_eva_pv) high_eva_pv_90

    from beautyplus-bc0ed.temp.dws_dz_dau_split_user_other_behave
    where date between date_sub(mDATE, interval 89 day) and mDATE
    group by 1
)
,
active as
(
    select user_pseudo_id
--         ,count(distinct a.event_date_hk) life_time_active_days
        ,count(distinct case when a.event_date_hk between date_sub(mDATE,interval 90 day) and mDATE then event_date_hk end) active_days_90
        ,count(distinct case when a.event_date_hk between date_sub(mDATE,interval 60 day) and mDATE then event_date_hk end) active_days_60
        ,count(distinct case when a.event_date_hk between date_sub(mDATE,interval 30 day) and mDATE then event_date_hk end) active_days_30
        ,count(distinct case when a.event_date_hk between date_sub(mDATE,interval 14 day) and mDATE then event_date_hk end) active_days_14
        ,count(distinct case when a.event_date_hk between date_sub(mDATE,interval 7 day) and mDATE then event_date_hk end) active_days_7

        ,count(distinct a.event_date_hk) active_days_365
        ,count(distinct case when is_holiday = 1 then event_date_hk end) holiday_active_days_365
        ,count(distinct case when is_weekend = 1 then event_date_hk end) weekend_active_days_365
        ,count(distinct case when is_weekend_include_five = 1 then event_date_hk end) weekend_include_five_active_days_365
    from dataintegration-265403.temp.dws_dz_his_split_user_active_day_info a
    where
        a.event_date_hk between date_sub(mDATE,interval 365 day) and mDATE
        and app_name='BeautyPlus'
    group by 1
)


select cast(mDATE as date) as date,g.user_pseudo_id
    , g.*except(user_pseudo_id)
    , a.active_days_60, a.active_days_30, active_days_14
    , a.active_days_365, a.holiday_active_days_365, a.weekend_active_days_365, a.weekend_include_five_active_days_365
    , round(a.holiday_active_days_365/a.active_days_365,2) holiday_active_ratio
    , round(a.weekend_active_days_365/a.active_days_365,2) weekend_active_ratio
    , round(a.weekend_include_five_active_days_365/a.active_days_365,2) weekend_include_five_active_ratio
    , pv_tab0_edit_entry, pv_tab0_edit_save, pv_tab0_movie_save, pv_tab0_movie_shoot, pv_tab0_selfie_entry, pv_tab0_shoot_save, pv_tab0_shoot_shoot, pv_tab0_video_save, pv_tab0_video_shoot, pv_tab0_videoedit_entry, pv_tab0_videoedit_save, pv_tab1_edit_beauty_click, pv_tab1_edit_beauty_save, pv_tab1_edit_creative_click, pv_tab1_edit_creative_save, pv_tab1_edit_edit_click, pv_tab1_edit_edit_save, pv_tab1_edit_filter_click, pv_tab1_edit_filter_save, pv_tab1_edit_makeup_click, pv_tab1_edit_makeup_save, pv_tab1_edit_senioredit_click, pv_tab1_shoot_ar_save, pv_tab1_shoot_ar_shoot, pv_tab1_shoot_beauty_save, pv_tab1_shoot_filter_save, pv_tab1_shoot_filter_shoot, pv_tab1_shoot_look_save, pv_tab1_shoot_look_shoot, pv_tab1_shoot_makeup_save, pv_tab1_shoot_makeup_shoot
    , pv_tab2_edit_beauty_AIbeauty_click, pv_tab2_edit_beauty_AIbeauty_save, pv_tab2_edit_beauty_Threedimensionalface_click, pv_tab2_edit_beauty_Threedimensionalface_save, pv_tab2_edit_beauty_detail_click, pv_tab2_edit_beauty_detail_save, pv_tab2_edit_beauty_doublechin_click, pv_tab2_edit_beauty_doublechin_save, pv_tab2_edit_beauty_evenskin_click, pv_tab2_edit_beauty_evenskin_save, pv_tab2_edit_beauty_expression_click, pv_tab2_edit_beauty_expression_save, pv_tab2_edit_beauty_eyecatching_click, pv_tab2_edit_beauty_eyecatching_save, pv_tab2_edit_beauty_eyedilated_click, pv_tab2_edit_beauty_eyedilated_save, pv_tab2_edit_beauty_facecolor_click, pv_tab2_edit_beauty_facecolor_save, pv_tab2_edit_beauty_faceslimming_click, pv_tab2_edit_beauty_faceslimming_save, pv_tab2_edit_beauty_faciallighting_click, pv_tab2_edit_beauty_faciallighting_save, pv_tab2_edit_beauty_facialreshaping_click, pv_tab2_edit_beauty_facialreshaping_save, pv_tab2_edit_beauty_hairdressing_click, pv_tab2_edit_beauty_hairdressing_save, pv_tab2_edit_beauty_lightendarkcircle_click, pv_tab2_edit_beauty_lightendarkcircle_save, pv_tab2_edit_beauty_microdermabrasion_click, pv_tab2_edit_beauty_microdermabrasion_save, pv_tab2_edit_beauty_narrownose_click, pv_tab2_edit_beauty_narrownose_save, pv_tab2_edit_beauty_oneclickbeauty_click, pv_tab2_edit_beauty_oneclickbeauty_save, pv_tab2_edit_beauty_orthodontics_click, pv_tab2_edit_beauty_orthodontics_save, pv_tab2_edit_beauty_removieacne_click, pv_tab2_edit_beauty_removieacne_save, pv_tab2_edit_beauty_removieshine_click, pv_tab2_edit_beauty_removieshine_save, pv_tab2_edit_beauty_removiewrinkles_click, pv_tab2_edit_beauty_removiewrinkles_save, pv_tab2_edit_beauty_shape_click, pv_tab2_edit_beauty_shape_save, pv_tab2_edit_beauty_shrinkhead_click, pv_tab2_edit_beauty_shrinkhead_save, pv_tab2_edit_beauty_teethwhitening_click, pv_tab2_edit_beauty_teethwhitening_save
    , pv_tab2_edit_creative_background_click, pv_tab2_edit_creative_background_save, pv_tab2_edit_creative_formula_click, pv_tab2_edit_creative_formula_save, pv_tab2_edit_creative_graffiti_click, pv_tab2_edit_creative_graffiti_save, pv_tab2_edit_creative_sticker_click, pv_tab2_edit_creative_sticker_save, pv_tab2_edit_creative_text_click, pv_tab2_edit_creative_text_save, pv_tab2_edit_edit_AIenhance_click, pv_tab2_edit_edit_AIenhance_save, pv_tab2_edit_edit_AIextension_click, pv_tab2_edit_edit_AIextension_save, pv_tab2_edit_edit_adjustment_click, pv_tab2_edit_edit_ar_click, pv_tab2_edit_edit_ar_save, pv_tab2_edit_edit_blur_click, pv_tab2_edit_edit_blur_save, pv_tab2_edit_edit_clone_click, pv_tab2_edit_edit_clone_save, pv_tab2_edit_edit_composition_click, pv_tab2_edit_edit_composition_save, pv_tab2_edit_edit_cutout_click, pv_tab2_edit_edit_cutout_save, pv_tab2_edit_edit_dispersion_click, pv_tab2_edit_edit_dispersion_save, pv_tab2_edit_edit_elimination_click, pv_tab2_edit_edit_elimination_save, pv_tab2_edit_edit_mosaic_click, pv_tab2_edit_edit_mosaic_save, pv_tab2_edit_edit_photorepair_click, pv_tab2_edit_edit_photorepair_save, pv_tab2_edit_edit_stylization_click, pv_tab2_edit_edit_stylization_save, pv_tab2_shoot_beauty_bigeyes_save, pv_tab2_shoot_beauty_eyecatching_save, pv_tab2_shoot_beauty_facecolor_save, pv_tab2_shoot_beauty_faceslimming_save, pv_tab2_shoot_beauty_microdermabrasion_save, pv_tab2_shoot_beauty_oneclickbody_save, pv_tab2_shoot_beauty_removieacnefreckles_save, pv_tab2_shoot_beauty_removiedarkcircles_save, pv_tab2_shoot_beauty_removienasolabial_save, pv_tab2_shoot_beauty_shrinkhead_save, pv_tab2_shoot_beauty_softhair_save, pv_tab2_shoot_beauty_teethwhitening_save, pv_tab2_shoot_beauty_thinnose_save, pv_tab2_shoot_makeup_blush_save, pv_tab2_shoot_makeup_blush_shoot, pv_tab2_shoot_makeup_contactlenses_save, pv_tab2_shoot_makeup_contactlenses_shoot, pv_tab2_shoot_makeup_dyehair_save, pv_tab2_shoot_makeup_dyehair_shoot, pv_tab2_shoot_makeup_eyebrow_save, pv_tab2_shoot_makeup_eyebrow_shoot, pv_tab2_shoot_makeup_eyelash_save, pv_tab2_shoot_makeup_eyelash_shoot, pv_tab2_shoot_makeup_eyeshadow_save, pv_tab2_shoot_makeup_eyeshadow_shoot, pv_tab2_shoot_makeup_freckle_save, pv_tab2_shoot_makeup_freckle_shoot, pv_tab2_shoot_makeup_lipstick_save, pv_tab2_shoot_makeup_lipstick_shoot, pv_tab2_shoot_makeup_lyingsilkworm_save, pv_tab2_shoot_makeup_lyingsilkworm_shoot, pv_tab2_shoot_makeup_trimming_save, pv_tab2_shoot_makeup_trimming_shoot
    , pv_tab0_edit_entry_30, pv_tab0_edit_save_30, pv_tab0_movie_save_30, pv_tab0_movie_shoot_30, pv_tab0_selfie_entry_30, pv_tab0_shoot_save_30, pv_tab0_shoot_shoot_30, pv_tab0_video_save_30, pv_tab0_video_shoot_30, pv_tab0_videoedit_entry_30, pv_tab0_videoedit_save_30, pv_tab1_edit_beauty_click_30, pv_tab1_edit_beauty_save_30, pv_tab1_edit_creative_click_30, pv_tab1_edit_creative_save_30, pv_tab1_edit_edit_click_30, pv_tab1_edit_edit_save_30, pv_tab1_edit_filter_click_30, pv_tab1_edit_filter_save_30, pv_tab1_edit_makeup_click_30, pv_tab1_edit_makeup_save_30, pv_tab1_edit_senioredit_click_30, pv_tab1_shoot_ar_save_30, pv_tab1_shoot_ar_shoot_30, pv_tab1_shoot_beauty_save_30, pv_tab1_shoot_filter_save_30, pv_tab1_shoot_filter_shoot_30, pv_tab1_shoot_look_save_30, pv_tab1_shoot_look_shoot_30, pv_tab1_shoot_makeup_save_30, pv_tab1_shoot_makeup_shoot_30
    , pv_tab0_edit_entry_60, pv_tab0_edit_save_60, pv_tab0_movie_save_60, pv_tab0_movie_shoot_60, pv_tab0_selfie_entry_60, pv_tab0_shoot_save_60, pv_tab0_shoot_shoot_60, pv_tab0_video_save_60, pv_tab0_video_shoot_60, pv_tab0_videoedit_entry_60, pv_tab0_videoedit_save_60, pv_tab1_edit_beauty_click_60, pv_tab1_edit_beauty_save_60, pv_tab1_edit_creative_click_60, pv_tab1_edit_creative_save_60, pv_tab1_edit_edit_click_60, pv_tab1_edit_edit_save_60, pv_tab1_edit_filter_click_60, pv_tab1_edit_filter_save_60, pv_tab1_edit_makeup_click_60, pv_tab1_edit_makeup_save_60, pv_tab1_edit_senioredit_click_60, pv_tab1_shoot_ar_save_60, pv_tab1_shoot_ar_shoot_60, pv_tab1_shoot_beauty_save_60, pv_tab1_shoot_filter_save_60, pv_tab1_shoot_filter_shoot_60, pv_tab1_shoot_look_save_60, pv_tab1_shoot_look_shoot_60, pv_tab1_shoot_makeup_save_60, pv_tab1_shoot_makeup_shoot_60
    , pv_tab0_edit_entry_90, pv_tab0_edit_save_90, pv_tab0_movie_save_90, pv_tab0_movie_shoot_90, pv_tab0_selfie_entry_90, pv_tab0_shoot_save_90, pv_tab0_shoot_shoot_90, pv_tab0_video_save_90, pv_tab0_video_shoot_90, pv_tab0_videoedit_entry_90, pv_tab0_videoedit_save_90, pv_tab1_edit_beauty_click_90, pv_tab1_edit_beauty_save_90, pv_tab1_edit_creative_click_90, pv_tab1_edit_creative_save_90, pv_tab1_edit_edit_click_90, pv_tab1_edit_edit_save_90, pv_tab1_edit_filter_click_90, pv_tab1_edit_filter_save_90, pv_tab1_edit_makeup_click_90, pv_tab1_edit_makeup_save_90, pv_tab1_edit_senioredit_click_90, pv_tab1_shoot_ar_save_90, pv_tab1_shoot_ar_shoot_90, pv_tab1_shoot_beauty_save_90, pv_tab1_shoot_filter_save_90, pv_tab1_shoot_filter_shoot_90, pv_tab1_shoot_look_save_90, pv_tab1_shoot_look_shoot_90, pv_tab1_shoot_makeup_save_90, pv_tab1_shoot_makeup_shoot_90
    , aigc_enter_pv, aigc_use_pv, aigc_save_pv, pop_exposure, pop_click, content_exposure, content_click, max_module_positon, sub_page_enter, sub_page_click, force_sub_page_enter, force_sub_page_click, subscript_sub_page_enter, subscript_sub_page_click, other_sub_page_enter, other_sub_page_click, max_impression_pv, impression_pv, click_pv
    , aigc_enter_pv_30, aigc_use_pv_30, aigc_save_pv_30, pop_exposure_30, pop_click_30, content_exposure_30, content_click_30, max_module_positon_30, sub_page_enter_30, sub_page_click_30, force_sub_page_enter_30, force_sub_page_click_30, subscript_sub_page_enter_30, subscript_sub_page_click_30, other_sub_page_enter_30, other_sub_page_click_30, max_impression_pv_30, impression_pv_30, click_pv_30
    , aigc_enter_pv_60, aigc_use_pv_60, aigc_save_pv_60, pop_exposure_60, pop_click_60, content_exposure_60, content_click_60, max_module_positon_60, sub_page_enter_60, sub_page_click_60, force_sub_page_enter_60, force_sub_page_click_60, subscript_sub_page_enter_60, subscript_sub_page_click_60, other_sub_page_enter_60, other_sub_page_click_60, max_impression_pv_60, impression_pv_60, click_pv_60
    , aigc_enter_pv_90, aigc_use_pv_90, aigc_save_pv_90, pop_exposure_90, pop_click_90, content_exposure_90, content_click_90, max_module_positon_90, sub_page_enter_90, sub_page_click_90, force_sub_page_enter_90, force_sub_page_click_90, subscript_sub_page_enter_90, subscript_sub_page_click_90, other_sub_page_enter_90, other_sub_page_click_90, max_impression_pv_90, impression_pv_90, click_pv_90
--     , grow_aigc_enter_pv, grow_aigc_use_pv, grow_aigc_save_pv, grow_pop_exposure, grow_pop_click, grow_content_exposure, grow_content_click, grow_max_module_positon, grow_sub_page_enter, grow_sub_page_click, force_grow_sub_page_enter, force_grow_sub_page_click, subscript_grow_sub_page_enter, subscript_grow_sub_page_click, other_grow_sub_page_enter, other_grow_sub_page_click, grow_max_impression_pv, grow_impression_pv, grow_click_pv
    , puzzle_click_pv, puzzle_save_pv, puzzle_click_pv_30, puzzle_save_pv_30, puzzle_click_pv_60, puzzle_save_pv_60, puzzle_click_pv_90, puzzle_save_pv_90
    , pay_function_click_pv, free_function_click_pv, free_function_save_pv, pay_function_click_pv_30, free_function_click_pv_30, free_function_save_pv_30, pay_function_click_pv_60, free_function_click_pv_60, free_function_save_pv_60, pay_function_click_pv_90, free_function_click_pv_90, free_function_save_pv_90
--     , grow_pay_function_click_pv, grow_free_function_click_pv, grow_free_function_save_pv
    , pay_duffle_click_pv, free_duffle_click_pv, free_duffle_save_pv, pay_duffle_click_pv_30, free_duffle_click_pv_30, free_duffle_save_pv_30, pay_duffle_click_pv_60, free_duffle_click_pv_60, free_duffle_save_pv_60, pay_duffle_click_pv_90, free_duffle_click_pv_90, free_duffle_save_pv_90
--     , grow_pay_duffle_click_pv, grow_free_duffle_click_pv, grow_free_duffle_save_pv
    , function_num, function_num_pre, function_num_30, function_num_60, function_num_90, grow_function_num
--     , grow_edit_enter_pv, grow_edit_save_pv, grow_take_photo_pv, grow_take_photo_save_pv, grow_selftake_enter_pv, grow_take_video_pv, grow_take_video_save_pv
    , homepage_exposure_pv, homepage_click_pv, homepage_feature_show_pv, homepage_feature_click_pv, homepage_banner_show_pv, homepage_banner_click_pv, homepage_reconmend_show_pv, homepage_reconmend_click_pv, homepage_topic_show_pv, homepage_topic_click_pv, homepage_miniapp_show_pv, homepage_miniapp_click_pv
    , homepage_exposure_pv_30, homepage_click_pv_30, homepage_feature_show_pv_30, homepage_feature_click_pv_30, homepage_banner_show_pv_30, homepage_banner_click_pv_30, homepage_reconmend_show_pv_30, homepage_reconmend_click_pv_30, homepage_topic_show_pv_30, homepage_topic_click_pv_30, homepage_miniapp_show_pv_30, homepage_miniapp_click_pv_30
    , homepage_exposure_pv_60, homepage_click_pv_60, homepage_feature_show_pv_60, homepage_feature_click_pv_60, homepage_banner_show_pv_60, homepage_banner_click_pv_60, homepage_reconmend_show_pv_60, homepage_reconmend_click_pv_60, homepage_topic_show_pv_60, homepage_topic_click_pv_60, homepage_miniapp_show_pv_60, homepage_miniapp_click_pv_60
    , homepage_exposure_pv_90, homepage_click_pv_90, homepage_feature_show_pv_90, homepage_feature_click_pv_90, homepage_banner_show_pv_90, homepage_banner_click_pv_90, homepage_reconmend_show_pv_90, homepage_reconmend_click_pv_90, homepage_topic_show_pv_90, homepage_topic_click_pv_90, homepage_miniapp_show_pv_90, homepage_miniapp_click_pv_90
from goal_users g
left join active a
on g.user_pseudo_id=a.user_pseudo_id
left join core_behave c
on g.user_pseudo_id=c.user_pseudo_id
left join core_behave_30 c30
on g.user_pseudo_id=c30.user_pseudo_id
left join core_behave_60 c60
on g.user_pseudo_id=c60.user_pseudo_id
left join core_behave_90 c90
on g.user_pseudo_id=c90.user_pseudo_id
left join other_behave o
on g.user_pseudo_id=o.user_pseudo_id
left join function_use f
on g.user_pseudo_id=f.user_pseudo_id
;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;




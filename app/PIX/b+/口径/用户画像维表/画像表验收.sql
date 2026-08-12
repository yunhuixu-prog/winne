select *
from `dataintegration-265403.dwd.dwd_dz_portrait_beautyplus_firebase_id`
where firebase_id='265E4A75988542D2A58F4BA8CAB3F321'
limit 10

-- 基础信息验收
select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321' and event_date_hk='2024-07-09'

-- 匹配uuid
select key,uuid
from `dataintegration-265403.stat.dmi_dz_idmapping`
where key='265E4A75988542D2A58F4BA8CAB3F321'

-- 订阅状态
select *
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk>='2024-01-01' and event_date_hk = '2024-07-09' and app_id in ('BeautyPlus')
and uuid='267433529'

-- 节假日活跃
select user_pseudo_id
    ,count(distinct a.event_date_hk) active_days_365
    ,count(distinct case when is_holiday = 1 then event_date_hk end) holiday_active_days_365
    ,count(distinct case when is_weekend = 1 then event_date_hk end) weekend_active_days_365
    ,count(distinct case when is_weekend_include_five = 1 then event_date_hk end) weekend_include_five_active_days_365
from dataintegration-265403.temp.dws_dz_his_split_user_active_day_info a
where
    event_date_hk between date_sub('2024-07-09',interval 364 day) and '2024-07-09'
    and app_name='BeautyPlus'
    and user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321'
group by 1

-- 数据1
select user_pseudo_id
     ,sum(aigc_enter_pv) aigc_enter_pv
        ,sum(aigc_use_pv) aigc_use_pv
        ,sum(aigc_save_pv) aigc_save_pv
        ,sum(pop_exposure) pop_exposure
        ,sum(pop_click) pop_click
        ,sum(content_exposure) content_exposure
        ,sum(content_click) content_click
        ,sum(max_module_positon) max_module_positon
        ,sum(sub_page_enter) sub_page_enter
        ,sum(sub_page_click) sub_page_click
        ,sum(force_sub_page_enter) force_sub_page_enter
        ,sum(force_sub_page_click) force_sub_page_click
        ,sum(subscript_sub_page_enter) subscript_sub_page_enter
        ,sum(subscript_sub_page_click) subscript_sub_page_click
        ,sum(other_sub_page_enter) other_sub_page_enter
        ,sum(other_sub_page_click) other_sub_page_click
        ,sum(max_impression_pv) max_impression_pv
        ,sum(impression_pv) impression_pv
        ,sum(click_pv) click_pv
        ,sum(share_pv) share_pv
        ,sum(search_pv) search_pv
        ,sum(eva_imp_pv) eva_imp_pv
        ,sum(eva_pv) eva_pv
        ,sum(high_eva_pv) high_eva_pv
from beautyplus-bc0ed.temp.dws_dz_dau_split_user_other_behave
where date between date_sub('2024-07-09',interval 29 day) and '2024-07-09'
    and user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321'
group by 1

-- 数据2
SELECT user_pseudo_id
    , sum(pv_tab0_edit_entry) pv_tab0_edit_entry, sum(pv_tab0_edit_save) pv_tab0_edit_save, sum(pv_tab0_movie_save) pv_tab0_movie_save, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry, sum(pv_tab0_shoot_save) pv_tab0_shoot_save, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot, sum(pv_tab0_video_save) pv_tab0_video_save, sum(pv_tab0_video_shoot) pv_tab0_video_shoot, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot
    , sum(pv_tab2_edit_beauty_AIbeauty_click) pv_tab2_edit_beauty_AIbeauty_click, sum(pv_tab2_edit_beauty_AIbeauty_save) pv_tab2_edit_beauty_AIbeauty_save, sum(pv_tab2_edit_beauty_Threedimensionalface_click) pv_tab2_edit_beauty_Threedimensionalface_click, sum(pv_tab2_edit_beauty_Threedimensionalface_save) pv_tab2_edit_beauty_Threedimensionalface_save, sum(pv_tab2_edit_beauty_detail_click) pv_tab2_edit_beauty_detail_click, sum(pv_tab2_edit_beauty_detail_save) pv_tab2_edit_beauty_detail_save, sum(pv_tab2_edit_beauty_doublechin_click) pv_tab2_edit_beauty_doublechin_click, sum(pv_tab2_edit_beauty_doublechin_save) pv_tab2_edit_beauty_doublechin_save, sum(pv_tab2_edit_beauty_evenskin_click) pv_tab2_edit_beauty_evenskin_click, sum(pv_tab2_edit_beauty_evenskin_save) pv_tab2_edit_beauty_evenskin_save, sum(pv_tab2_edit_beauty_expression_click) pv_tab2_edit_beauty_expression_click, sum(pv_tab2_edit_beauty_expression_save) pv_tab2_edit_beauty_expression_save, sum(pv_tab2_edit_beauty_eyecatching_click) pv_tab2_edit_beauty_eyecatching_click, sum(pv_tab2_edit_beauty_eyecatching_save) pv_tab2_edit_beauty_eyecatching_save, sum(pv_tab2_edit_beauty_eyedilated_click) pv_tab2_edit_beauty_eyedilated_click, sum(pv_tab2_edit_beauty_eyedilated_save) pv_tab2_edit_beauty_eyedilated_save, sum(pv_tab2_edit_beauty_facecolor_click) pv_tab2_edit_beauty_facecolor_click, sum(pv_tab2_edit_beauty_facecolor_save) pv_tab2_edit_beauty_facecolor_save, sum(pv_tab2_edit_beauty_faceslimming_click) pv_tab2_edit_beauty_faceslimming_click, sum(pv_tab2_edit_beauty_faceslimming_save) pv_tab2_edit_beauty_faceslimming_save, sum(pv_tab2_edit_beauty_faciallighting_click) pv_tab2_edit_beauty_faciallighting_click, sum(pv_tab2_edit_beauty_faciallighting_save) pv_tab2_edit_beauty_faciallighting_save, sum(pv_tab2_edit_beauty_facialreshaping_click) pv_tab2_edit_beauty_facialreshaping_click, sum(pv_tab2_edit_beauty_facialreshaping_save) pv_tab2_edit_beauty_facialreshaping_save, sum(pv_tab2_edit_beauty_hairdressing_click) pv_tab2_edit_beauty_hairdressing_click, sum(pv_tab2_edit_beauty_hairdressing_save) pv_tab2_edit_beauty_hairdressing_save, sum(pv_tab2_edit_beauty_lightendarkcircle_click) pv_tab2_edit_beauty_lightendarkcircle_click, sum(pv_tab2_edit_beauty_lightendarkcircle_save) pv_tab2_edit_beauty_lightendarkcircle_save, sum(pv_tab2_edit_beauty_microdermabrasion_click) pv_tab2_edit_beauty_microdermabrasion_click, sum(pv_tab2_edit_beauty_microdermabrasion_save) pv_tab2_edit_beauty_microdermabrasion_save, sum(pv_tab2_edit_beauty_narrownose_click) pv_tab2_edit_beauty_narrownose_click, sum(pv_tab2_edit_beauty_narrownose_save) pv_tab2_edit_beauty_narrownose_save, sum(pv_tab2_edit_beauty_oneclickbeauty_click) pv_tab2_edit_beauty_oneclickbeauty_click, sum(pv_tab2_edit_beauty_oneclickbeauty_save) pv_tab2_edit_beauty_oneclickbeauty_save, sum(pv_tab2_edit_beauty_orthodontics_click) pv_tab2_edit_beauty_orthodontics_click, sum(pv_tab2_edit_beauty_orthodontics_save) pv_tab2_edit_beauty_orthodontics_save, sum(pv_tab2_edit_beauty_removieacne_click) pv_tab2_edit_beauty_removieacne_click, sum(pv_tab2_edit_beauty_removieacne_save) pv_tab2_edit_beauty_removieacne_save, sum(pv_tab2_edit_beauty_removieshine_click) pv_tab2_edit_beauty_removieshine_click, sum(pv_tab2_edit_beauty_removieshine_save) pv_tab2_edit_beauty_removieshine_save, sum(pv_tab2_edit_beauty_removiewrinkles_click) pv_tab2_edit_beauty_removiewrinkles_click, sum(pv_tab2_edit_beauty_removiewrinkles_save) pv_tab2_edit_beauty_removiewrinkles_save, sum(pv_tab2_edit_beauty_shape_click) pv_tab2_edit_beauty_shape_click, sum(pv_tab2_edit_beauty_shape_save) pv_tab2_edit_beauty_shape_save, sum(pv_tab2_edit_beauty_shrinkhead_click) pv_tab2_edit_beauty_shrinkhead_click, sum(pv_tab2_edit_beauty_shrinkhead_save) pv_tab2_edit_beauty_shrinkhead_save, sum(pv_tab2_edit_beauty_teethwhitening_click) pv_tab2_edit_beauty_teethwhitening_click, sum(pv_tab2_edit_beauty_teethwhitening_save) pv_tab2_edit_beauty_teethwhitening_save
    , sum(pv_tab2_edit_creative_background_click) pv_tab2_edit_creative_background_click, sum(pv_tab2_edit_creative_background_save) pv_tab2_edit_creative_background_save, sum(pv_tab2_edit_creative_formula_click) pv_tab2_edit_creative_formula_click, sum(pv_tab2_edit_creative_formula_save) pv_tab2_edit_creative_formula_save, sum(pv_tab2_edit_creative_graffiti_click) pv_tab2_edit_creative_graffiti_click, sum(pv_tab2_edit_creative_graffiti_save) pv_tab2_edit_creative_graffiti_save, sum(pv_tab2_edit_creative_sticker_click) pv_tab2_edit_creative_sticker_click, sum(pv_tab2_edit_creative_sticker_save) pv_tab2_edit_creative_sticker_save, sum(pv_tab2_edit_creative_text_click) pv_tab2_edit_creative_text_click, sum(pv_tab2_edit_creative_text_save) pv_tab2_edit_creative_text_save, sum(pv_tab2_edit_edit_AIenhance_click) pv_tab2_edit_edit_AIenhance_click, sum(pv_tab2_edit_edit_AIenhance_save) pv_tab2_edit_edit_AIenhance_save, sum(pv_tab2_edit_edit_AIextension_click) pv_tab2_edit_edit_AIextension_click, sum(pv_tab2_edit_edit_AIextension_save) pv_tab2_edit_edit_AIextension_save, sum(pv_tab2_edit_edit_adjustment_click) pv_tab2_edit_edit_adjustment_click, sum(pv_tab2_edit_edit_ar_click) pv_tab2_edit_edit_ar_click, sum(pv_tab2_edit_edit_ar_save) pv_tab2_edit_edit_ar_save, sum(pv_tab2_edit_edit_blur_click) pv_tab2_edit_edit_blur_click, sum(pv_tab2_edit_edit_blur_save) pv_tab2_edit_edit_blur_save, sum(pv_tab2_edit_edit_clone_click) pv_tab2_edit_edit_clone_click, sum(pv_tab2_edit_edit_clone_save) pv_tab2_edit_edit_clone_save, sum(pv_tab2_edit_edit_composition_click) pv_tab2_edit_edit_composition_click, sum(pv_tab2_edit_edit_composition_save) pv_tab2_edit_edit_composition_save, sum(pv_tab2_edit_edit_cutout_click) pv_tab2_edit_edit_cutout_click, sum(pv_tab2_edit_edit_cutout_save) pv_tab2_edit_edit_cutout_save, sum(pv_tab2_edit_edit_dispersion_click) pv_tab2_edit_edit_dispersion_click, sum(pv_tab2_edit_edit_dispersion_save) pv_tab2_edit_edit_dispersion_save, sum(pv_tab2_edit_edit_elimination_click) pv_tab2_edit_edit_elimination_click, sum(pv_tab2_edit_edit_elimination_save) pv_tab2_edit_edit_elimination_save, sum(pv_tab2_edit_edit_mosaic_click) pv_tab2_edit_edit_mosaic_click, sum(pv_tab2_edit_edit_mosaic_save) pv_tab2_edit_edit_mosaic_save, sum(pv_tab2_edit_edit_photorepair_click) pv_tab2_edit_edit_photorepair_click, sum(pv_tab2_edit_edit_photorepair_save) pv_tab2_edit_edit_photorepair_save, sum(pv_tab2_edit_edit_stylization_click) pv_tab2_edit_edit_stylization_click, sum(pv_tab2_edit_edit_stylization_save) pv_tab2_edit_edit_stylization_save, sum(pv_tab2_shoot_beauty_bigeyes_save) pv_tab2_shoot_beauty_bigeyes_save, sum(pv_tab2_shoot_beauty_eyecatching_save) pv_tab2_shoot_beauty_eyecatching_save, sum(pv_tab2_shoot_beauty_facecolor_save) pv_tab2_shoot_beauty_facecolor_save, sum(pv_tab2_shoot_beauty_faceslimming_save) pv_tab2_shoot_beauty_faceslimming_save, sum(pv_tab2_shoot_beauty_microdermabrasion_save) pv_tab2_shoot_beauty_microdermabrasion_save, sum(pv_tab2_shoot_beauty_oneclickbody_save) pv_tab2_shoot_beauty_oneclickbody_save, sum(pv_tab2_shoot_beauty_removieacnefreckles_save) pv_tab2_shoot_beauty_removieacnefreckles_save, sum(pv_tab2_shoot_beauty_removiedarkcircles_save) pv_tab2_shoot_beauty_removiedarkcircles_save, sum(pv_tab2_shoot_beauty_removienasolabial_save) pv_tab2_shoot_beauty_removienasolabial_save, sum(pv_tab2_shoot_beauty_shrinkhead_save) pv_tab2_shoot_beauty_shrinkhead_save, sum(pv_tab2_shoot_beauty_softhair_save) pv_tab2_shoot_beauty_softhair_save, sum(pv_tab2_shoot_beauty_teethwhitening_save) pv_tab2_shoot_beauty_teethwhitening_save, sum(pv_tab2_shoot_beauty_thinnose_save) pv_tab2_shoot_beauty_thinnose_save, sum(pv_tab2_shoot_makeup_blush_save) pv_tab2_shoot_makeup_blush_save, sum(pv_tab2_shoot_makeup_blush_shoot) pv_tab2_shoot_makeup_blush_shoot, sum(pv_tab2_shoot_makeup_contactlenses_save) pv_tab2_shoot_makeup_contactlenses_save, sum(pv_tab2_shoot_makeup_contactlenses_shoot) pv_tab2_shoot_makeup_contactlenses_shoot, sum(pv_tab2_shoot_makeup_dyehair_save) pv_tab2_shoot_makeup_dyehair_save, sum(pv_tab2_shoot_makeup_dyehair_shoot) pv_tab2_shoot_makeup_dyehair_shoot, sum(pv_tab2_shoot_makeup_eyebrow_save) pv_tab2_shoot_makeup_eyebrow_save, sum(pv_tab2_shoot_makeup_eyebrow_shoot) pv_tab2_shoot_makeup_eyebrow_shoot, sum(pv_tab2_shoot_makeup_eyelash_save) pv_tab2_shoot_makeup_eyelash_save, sum(pv_tab2_shoot_makeup_eyelash_shoot) pv_tab2_shoot_makeup_eyelash_shoot, sum(pv_tab2_shoot_makeup_eyeshadow_save) pv_tab2_shoot_makeup_eyeshadow_save, sum(pv_tab2_shoot_makeup_eyeshadow_shoot) pv_tab2_shoot_makeup_eyeshadow_shoot, sum(pv_tab2_shoot_makeup_freckle_save) pv_tab2_shoot_makeup_freckle_save, sum(pv_tab2_shoot_makeup_freckle_shoot) pv_tab2_shoot_makeup_freckle_shoot, sum(pv_tab2_shoot_makeup_lipstick_save) pv_tab2_shoot_makeup_lipstick_save, sum(pv_tab2_shoot_makeup_lipstick_shoot) pv_tab2_shoot_makeup_lipstick_shoot, sum(pv_tab2_shoot_makeup_lyingsilkworm_save) pv_tab2_shoot_makeup_lyingsilkworm_save, sum(pv_tab2_shoot_makeup_lyingsilkworm_shoot) pv_tab2_shoot_makeup_lyingsilkworm_shoot, sum(pv_tab2_shoot_makeup_trimming_save) pv_tab2_shoot_makeup_trimming_save, sum(pv_tab2_shoot_makeup_trimming_shoot) pv_tab2_shoot_makeup_trimming_shoot
    , sum(puzzle_click_pv) puzzle_click_pv, sum(puzzle_save_pv) puzzle_save_pv, sum(pay_function_click_pv) pay_function_click_pv, sum(free_function_click_pv) free_function_click_pv, sum(free_function_save_pv) free_function_save_pv, sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv, sum(homepage_exposure_pv) homepage_exposure_pv, sum(homepage_click_pv) homepage_click_pv, sum(homepage_feature_show_pv) homepage_feature_show_pv, sum(homepage_feature_click_pv) homepage_feature_click_pv, sum(homepage_banner_show_pv) homepage_banner_show_pv, sum(homepage_banner_click_pv) homepage_banner_click_pv, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv, sum(homepage_topic_show_pv) homepage_topic_show_pv, sum(homepage_topic_click_pv) homepage_topic_click_pv, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv
FROM beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave
where event_date between date_sub('2024-07-09',interval 29 day) and '2024-07-09'
    and user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321'
group by 1

select *
select distinct function
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
where event_date between date_sub('2024-07-09',interval 29 day) and '2024-07-09'
    and user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321'
    and action='拍摄'
    and module='拍摄'
    and mark=2

-- 看下整体的数

select count(1),count(distinct firebase_id)
from `dataintegration-265403.dwd.dwd_dz_portrait_beautyplus_firebase_id`

select max(life_time_active_days)
from `dataintegration-265403.dwd.dwd_dz_portrait_beautyplus_firebase_id`



-- gid表

select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
where event_date_hk='2024-07-09' and last_user_pseudo_id='265E4A75988542D2A58F4BA8CAB3F321'

select *
from `dataintegration-265403.dwd.dwd_dz_portrait_beautyplus_gid`
where gid='2436691966'
limit 10
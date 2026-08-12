-- -- 初始化
-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_his_split_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_his_split_user_behave as

-- 非初始化
DECLARE mDATE_START DATE DEFAULT '2023-05-20';
DECLARE mDATE_END DATE DEFAULT '2024-06-30';
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
    where event_date_hk=mDATE and first_active_date>='2022-01-01'
)
,
behave_pre as
(
    select event_date,a.mark, a.module, a.class, a.function
        , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
                when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
                when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
                when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
                when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
                when a.mark=0 and a.module ='自拍' and a.event_name_cn='自拍页展现' then '进入'
                when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
                when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
                else a.action
          end action
        , a.user_pseudo_id
        , a.pv
        , b.mark mark_c, b.module module_c, b.class class_c, b.function function_c, b.is_pay, b.is_function
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
    left join beautyplus-bc0ed.temp.dmi_da_class_is_pay_en b
    on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
    where event_date between date_sub(mDATE,interval 89 day) and mDATE
        and a.mark in (0, 1, 2)
)
,
-- 近7天用户核心行为
core_behave as
(
    SELECT *
    FROM
    (
        SELECT user_pseudo_id
            , concat('tab', mark_c, '_'
                , IFNULL(module_c, '')
                , IF(class_c is null, '', '_'), IFNULL(class_c, '')
                , IF(function_c is null, '', '_'), IFNULL(function_c, ''), '_'
                , case when action='点击' then 'click'
                        when action='进入' then 'entry'
                        when action='保存' then 'save'
                        when action='拍摄' then 'shoot' end) behave, sum (pv) pv
        FROM
        behave_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 6 day) and mDATE
        group by 1, 2
    )
    PIVOT
    (
        -- #2 aggregate
        sum (pv) AS pv
        -- #3 pivot_column
        -- 批量获取格式后的behave，参考onenote中的文字批量加上引号方法
        FOR behave in ('tab0_edit_entry','tab0_edit_save','tab0_movie_save','tab0_movie_shoot','tab0_selfie_entry','tab0_shoot_save','tab0_shoot_shoot','tab0_video_save','tab0_video_shoot','tab0_videoedit_entry','tab0_videoedit_save','tab1_edit_beauty_click','tab1_edit_beauty_save','tab1_edit_creative_click','tab1_edit_creative_save','tab1_edit_edit_click','tab1_edit_edit_save','tab1_edit_filter_click','tab1_edit_filter_save','tab1_edit_makeup_click','tab1_edit_makeup_save','tab1_edit_senioredit_click','tab1_shoot_ar_save','tab1_shoot_ar_shoot','tab1_shoot_beauty_save','tab1_shoot_filter_save','tab1_shoot_filter_shoot','tab1_shoot_look_save','tab1_shoot_look_shoot','tab1_shoot_makeup_save','tab1_shoot_makeup_shoot','tab2_edit_beauty_AIbeauty_click','tab2_edit_beauty_AIbeauty_save','tab2_edit_beauty_Threedimensionalface_click','tab2_edit_beauty_Threedimensionalface_save','tab2_edit_beauty_detail_click','tab2_edit_beauty_detail_save','tab2_edit_beauty_doublechin_click','tab2_edit_beauty_doublechin_save','tab2_edit_beauty_evenskin_click','tab2_edit_beauty_evenskin_save','tab2_edit_beauty_expression_click','tab2_edit_beauty_expression_save','tab2_edit_beauty_eyecatching_click','tab2_edit_beauty_eyecatching_save','tab2_edit_beauty_eyedilated_click','tab2_edit_beauty_eyedilated_save','tab2_edit_beauty_facecolor_click','tab2_edit_beauty_facecolor_save','tab2_edit_beauty_faceslimming_click','tab2_edit_beauty_faceslimming_save','tab2_edit_beauty_faciallighting_click','tab2_edit_beauty_faciallighting_save','tab2_edit_beauty_facialreshaping_click','tab2_edit_beauty_facialreshaping_save','tab2_edit_beauty_hairdressing_click','tab2_edit_beauty_hairdressing_save','tab2_edit_beauty_lightendarkcircle_click','tab2_edit_beauty_lightendarkcircle_save','tab2_edit_beauty_microdermabrasion_click','tab2_edit_beauty_microdermabrasion_save','tab2_edit_beauty_narrownose_click','tab2_edit_beauty_narrownose_save','tab2_edit_beauty_oneclickbeauty_click','tab2_edit_beauty_oneclickbeauty_save','tab2_edit_beauty_orthodontics_click','tab2_edit_beauty_orthodontics_save','tab2_edit_beauty_removieacne_click','tab2_edit_beauty_removieacne_save','tab2_edit_beauty_removieshine_click','tab2_edit_beauty_removieshine_save','tab2_edit_beauty_removiewrinkles_click','tab2_edit_beauty_removiewrinkles_save','tab2_edit_beauty_shape_click','tab2_edit_beauty_shape_save','tab2_edit_beauty_shrinkhead_click','tab2_edit_beauty_shrinkhead_save','tab2_edit_beauty_teethwhitening_click','tab2_edit_beauty_teethwhitening_save','tab2_edit_creative_background_click','tab2_edit_creative_background_save','tab2_edit_creative_formula_click','tab2_edit_creative_formula_save','tab2_edit_creative_graffiti_click','tab2_edit_creative_graffiti_save','tab2_edit_creative_sticker_click','tab2_edit_creative_sticker_save','tab2_edit_creative_text_click','tab2_edit_creative_text_save','tab2_edit_edit_AIenhance_click','tab2_edit_edit_AIenhance_save','tab2_edit_edit_AIextension_click','tab2_edit_edit_AIextension_save','tab2_edit_edit_adjustment_click','tab2_edit_edit_ar_click','tab2_edit_edit_ar_save','tab2_edit_edit_blur_click','tab2_edit_edit_blur_save','tab2_edit_edit_clone_click','tab2_edit_edit_clone_save','tab2_edit_edit_composition_click','tab2_edit_edit_composition_save','tab2_edit_edit_cutout_click','tab2_edit_edit_cutout_save','tab2_edit_edit_dispersion_click','tab2_edit_edit_dispersion_save','tab2_edit_edit_elimination_click','tab2_edit_edit_elimination_save','tab2_edit_edit_mosaic_click','tab2_edit_edit_mosaic_save','tab2_edit_edit_photorepair_click','tab2_edit_edit_photorepair_save','tab2_edit_edit_stylization_click','tab2_edit_edit_stylization_save','tab2_shoot_beauty_bigeyes_save','tab2_shoot_beauty_eyecatching_save','tab2_shoot_beauty_facecolor_save','tab2_shoot_beauty_faceslimming_save','tab2_shoot_beauty_microdermabrasion_save','tab2_shoot_beauty_oneclickbody_save','tab2_shoot_beauty_removieacnefreckles_save','tab2_shoot_beauty_removiedarkcircles_save','tab2_shoot_beauty_removienasolabial_save','tab2_shoot_beauty_shrinkhead_save','tab2_shoot_beauty_softhair_save','tab2_shoot_beauty_teethwhitening_save','tab2_shoot_beauty_thinnose_save','tab2_shoot_makeup_blush_save','tab2_shoot_makeup_blush_shoot','tab2_shoot_makeup_contactlenses_save','tab2_shoot_makeup_contactlenses_shoot','tab2_shoot_makeup_dyehair_save','tab2_shoot_makeup_dyehair_shoot','tab2_shoot_makeup_eyebrow_save','tab2_shoot_makeup_eyebrow_shoot','tab2_shoot_makeup_eyelash_save','tab2_shoot_makeup_eyelash_shoot','tab2_shoot_makeup_eyeshadow_save','tab2_shoot_makeup_eyeshadow_shoot','tab2_shoot_makeup_freckle_save','tab2_shoot_makeup_freckle_shoot','tab2_shoot_makeup_lipstick_save','tab2_shoot_makeup_lipstick_shoot','tab2_shoot_makeup_lyingsilkworm_save','tab2_shoot_makeup_lyingsilkworm_shoot','tab2_shoot_makeup_trimming_save','tab2_shoot_makeup_trimming_shoot')
    )
)
,
-- 近30天用户核心行为
core_behave_30 as
(
    SELECT *
    FROM
    (
        SELECT user_pseudo_id
            , concat('tab', mark_c, '_'
                , IFNULL(module_c, '')
                , IF(class_c is null, '', '_'), IFNULL(class_c, '')
                , IF(function_c is null, '', '_'), IFNULL(function_c, ''), '_'
                , case when action='点击' then 'click'
                        when action='进入' then 'entry'
                        when action='保存' then 'save'
                        when action='拍摄' then 'shoot' end, '_30') behave, sum (pv) pv
        FROM
        behave_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 29 day) and mDATE
        group by 1, 2
    )
    PIVOT
    (
        -- #2 aggregate
        sum (pv) AS pv
        -- #3 pivot_column
        -- 批量获取格式后的behave，参考onenote中的文字批量加上引号方法
        FOR behave in ('tab0_edit_entry_30','tab0_edit_save_30','tab0_movie_save_30','tab0_movie_shoot_30','tab0_selfie_entry_30','tab0_shoot_save_30','tab0_shoot_shoot_30','tab0_video_save_30','tab0_video_shoot_30','tab0_videoedit_entry_30','tab0_videoedit_save_30','tab1_edit_beauty_click_30','tab1_edit_beauty_save_30','tab1_edit_creative_click_30','tab1_edit_creative_save_30','tab1_edit_edit_click_30','tab1_edit_edit_save_30','tab1_edit_filter_click_30','tab1_edit_filter_save_30','tab1_edit_makeup_click_30','tab1_edit_makeup_save_30','tab1_edit_senioredit_click_30','tab1_shoot_ar_save_30','tab1_shoot_ar_shoot_30','tab1_shoot_beauty_save_30','tab1_shoot_filter_save_30','tab1_shoot_filter_shoot_30','tab1_shoot_look_save_30','tab1_shoot_look_shoot_30','tab1_shoot_makeup_save_30','tab1_shoot_makeup_shoot_30')
    )
)
,
-- 近60天用户核心行为
core_behave_60 as
(
    SELECT *
    FROM
    (
        SELECT user_pseudo_id
            , concat('tab', mark_c, '_'
                , IFNULL(module_c, '')
                , IF(class_c is null, '', '_'), IFNULL(class_c, '')
                , IF(function_c is null, '', '_'), IFNULL(function_c, ''), '_'
                , case when action='点击' then 'click'
                        when action='进入' then 'entry'
                        when action='保存' then 'save'
                        when action='拍摄' then 'shoot' end, '_60') behave, sum (pv) pv
        FROM
        behave_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 59 day) and mDATE
        group by 1, 2
    )
    PIVOT
    (
        -- #2 aggregate
        sum (pv) AS pv
        -- #3 pivot_column
        -- 批量获取格式后的behave，参考onenote中的文字批量加上引号方法
        FOR behave in ('tab0_edit_entry_60','tab0_edit_save_60','tab0_movie_save_60','tab0_movie_shoot_60','tab0_selfie_entry_60','tab0_shoot_save_60','tab0_shoot_shoot_60','tab0_video_save_60','tab0_video_shoot_60','tab0_videoedit_entry_60','tab0_videoedit_save_60','tab1_edit_beauty_click_60','tab1_edit_beauty_save_60','tab1_edit_creative_click_60','tab1_edit_creative_save_60','tab1_edit_edit_click_60','tab1_edit_edit_save_60','tab1_edit_filter_click_60','tab1_edit_filter_save_60','tab1_edit_makeup_click_60','tab1_edit_makeup_save_60','tab1_edit_senioredit_click_60','tab1_shoot_ar_save_60','tab1_shoot_ar_shoot_60','tab1_shoot_beauty_save_60','tab1_shoot_filter_save_60','tab1_shoot_filter_shoot_60','tab1_shoot_look_save_60','tab1_shoot_look_shoot_60','tab1_shoot_makeup_save_60','tab1_shoot_makeup_shoot_60')
    )
)
,
-- 近90天用户核心行为
core_behave_90 as
(
    SELECT *
    FROM
    (
        SELECT user_pseudo_id
            , concat('tab', mark_c, '_'
                , IFNULL(module_c, '')
                , IF(class_c is null, '', '_'), IFNULL(class_c, '')
                , IF(function_c is null, '', '_'), IFNULL(function_c, ''), '_'
                , case when action='点击' then 'click'
                        when action='进入' then 'entry'
                        when action='保存' then 'save'
                        when action='拍摄' then 'shoot' end, '_90') behave, sum (pv) pv
        FROM
        behave_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 89 day) and mDATE
        group by 1, 2
    )
    PIVOT
    (
        -- #2 aggregate
        sum (pv) AS pv
        -- #3 pivot_column
        -- 批量获取格式后的behave，参考onenote中的文字批量加上引号方法
        FOR behave in ('tab0_edit_entry_90','tab0_edit_save_90','tab0_movie_save_90','tab0_movie_shoot_90','tab0_selfie_entry_90','tab0_shoot_save_90','tab0_shoot_shoot_90','tab0_video_save_90','tab0_video_shoot_90','tab0_videoedit_entry_90','tab0_videoedit_save_90','tab1_edit_beauty_click_90','tab1_edit_beauty_save_90','tab1_edit_creative_click_90','tab1_edit_creative_save_90','tab1_edit_edit_click_90','tab1_edit_edit_save_90','tab1_edit_filter_click_90','tab1_edit_filter_save_90','tab1_edit_makeup_click_90','tab1_edit_makeup_save_90','tab1_edit_senioredit_click_90','tab1_shoot_ar_save_90','tab1_shoot_ar_shoot_90','tab1_shoot_beauty_save_90','tab1_shoot_filter_save_90','tab1_shoot_filter_shoot_90','tab1_shoot_look_save_90','tab1_shoot_look_shoot_90','tab1_shoot_makeup_save_90','tab1_shoot_makeup_shoot_90')
    )
)
,
-- 近7/30/60天拼图行为
puzzle as
(
    select user_pseudo_id
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv
            , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv_30
            , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv_30
            , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv_60
            , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv_60
            , sum (case when action ='拼图点击' then pv end) puzzle_click_pv_90
            , sum (case when action ='拼图保存' then pv end) puzzle_save_pv_90
    from behave_pre
    where mark_c is not null
      and action in ('拼图点击', '拼图保存')
      and event_date between date_sub(mDATE, interval 89 day) and mDATE
    group by 1
)
,
-- 近7天付费非付费功能使用情况及成长情况，近30/60
pay_function as
(
    select user_pseudo_id,pay_function_click_pv,free_function_click_pv,free_function_save_pv
            , pay_function_click_pv_30,free_function_click_pv_30,free_function_save_pv_30
            , pay_function_click_pv_60,free_function_click_pv_60,free_function_save_pv_60
            , pay_function_click_pv_90,free_function_click_pv_90,free_function_save_pv_90
            , IFNULL(pay_function_click_pv, 0)-IFNULL(pay_function_click_pv_pre, 0) grow_pay_function_click_pv
            , IFNULL(free_function_click_pv, 0)-IFNULL(free_function_click_pv_pre, 0) grow_free_function_click_pv
            , IFNULL(free_function_save_pv, 0)-IFNULL(free_function_save_pv_pre, 0) grow_free_function_save_pv
    from
    (
        select user_pseudo_id
                , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                        and is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv_pre
                , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                        and is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv_pre
                , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                        and is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv_pre

                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv_30
                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv_30
                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv_30

                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv_60
                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv_60
                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv_60

                , sum (case when is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv_90
                , sum (case when is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv_90
                , sum (case when is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv_90
        from behave_pre
        where is_function = '功能'
          and mark=2
          and action in ('点击', '保存', '拍摄')
          and event_date between date_sub(mDATE, interval 89 day) and mDATE
        group by 1
    )
)
,
-- 近7天比前7天一级行为增长
grow as
(
    select user_pseudo_id
            , IFNULL(edit_enter_pv_7, 0)-IFNULL(edit_enter_pv_pre_7, 0) grow_edit_enter_pv
            , IFNULL(edit_save_pv_7, 0)-IFNULL(edit_save_pv_pre_7, 0) grow_edit_save_pv
            , IFNULL(take_photo_pv_7, 0)-IFNULL(take_photo_pv_pre_7, 0) grow_take_photo_pv
            , IFNULL(take_photo_save_pv_7, 0)-IFNULL(take_photo_save_pv_pre_7, 0) grow_take_photo_save_pv
            , IFNULL(selftake_enter_pv_7, 0)-IFNULL(selftake_enter_pv_pre_7, 0) grow_selftake_enter_pv
            , IFNULL(take_video_pv_7, 0)-IFNULL(take_video_pv_pre_7, 0) grow_take_video_pv
            , IFNULL(take_video_save_pv_7, 0)-IFNULL(take_video_save_pv_pre_7, 0) grow_take_video_save_pv
    from
    (
        select user_pseudo_id
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='修图' and action ='进入' then pv end) edit_enter_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='修图' and action ='进入' then pv end) edit_enter_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='修图' and action ='保存' then pv end) edit_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='修图' and action ='保存' then pv end) edit_save_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='拍摄' and action ='拍摄' then pv end) take_photo_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='拍摄' and action ='拍摄' then pv end) take_photo_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='拍摄' and action ='保存' then pv end) take_photo_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='拍摄' and action ='保存' then pv end) take_photo_save_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='自拍' and action ='进入' then pv end) selftake_enter_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='自拍' and action ='进入' then pv end) selftake_enter_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='视频' and action ='拍摄' then pv end) take_video_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='视频' and action ='拍摄' then pv end) take_video_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        module ='视频' and action ='保存' then pv end) take_video_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        module ='视频' and action ='保存' then pv end) take_video_save_pv_pre_7
        from behave_pre
        where mark_c = '0' and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 13 day) and mDATE
        group by 1
    )
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
        from behave_pre
        where mark=2 and action in ('点击', '拍摄')
        and event_date between date_sub(mDATE, interval 89 day) and mDATE
        group by 1
    )
)
,
-- 其他行为及增长
other_behave as
(
    select user_pseudo_id
            ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click
            ,content_exposure,content_click,max_module_positon
            ,sub_page_enter,sub_page_click,force_sub_page_enter,force_sub_page_click
            ,subscript_sub_page_enter,subscript_sub_page_click,other_sub_page_enter,other_sub_page_click
            ,max_impression_pv,impression_pv,click_pv

            ,aigc_enter_pv_30,aigc_use_pv_30,aigc_save_pv_30,pop_exposure_30,pop_click_30
            ,content_exposure_30,content_click_30,max_module_positon_30
            ,sub_page_enter_30,sub_page_click_30,force_sub_page_enter_30,force_sub_page_click_30
            ,subscript_sub_page_enter_30,subscript_sub_page_click_30,other_sub_page_enter_30,other_sub_page_click_30
            ,max_impression_pv_30,impression_pv_30,click_pv_30

            ,aigc_enter_pv_60,aigc_use_pv_60,aigc_save_pv_60,pop_exposure_60,pop_click_60
            ,content_exposure_60,content_click_60,max_module_positon_60
            ,sub_page_enter_60,sub_page_click_60,force_sub_page_enter_60,force_sub_page_click_60
            ,subscript_sub_page_enter_60,subscript_sub_page_click_60,other_sub_page_enter_60,other_sub_page_click_60
            ,max_impression_pv_60,impression_pv_60,click_pv_60

            ,aigc_enter_pv_90,aigc_use_pv_90,aigc_save_pv_90,pop_exposure_90,pop_click_90
            ,content_exposure_90,content_click_90,max_module_positon_90
            ,sub_page_enter_90,sub_page_click_90,force_sub_page_enter_90,force_sub_page_click_90
            ,subscript_sub_page_enter_90,subscript_sub_page_click_90,other_sub_page_enter_90,other_sub_page_click_90
            ,max_impression_pv_90,impression_pv_90,click_pv_90

            ,IFNULL(aigc_enter_pv, 0)-IFNULL(aigc_enter_pv_pre, 0) grow_aigc_enter_pv
            ,IFNULL(aigc_use_pv, 0)-IFNULL(aigc_use_pv_pre, 0) grow_aigc_use_pv
            ,IFNULL(aigc_save_pv, 0)-IFNULL(aigc_save_pv_pre, 0) grow_aigc_save_pv
            ,IFNULL(pop_exposure, 0)-IFNULL(pop_exposure_pre, 0) grow_pop_exposure
            ,IFNULL(pop_click, 0)-IFNULL(pop_click_pre, 0) grow_pop_click
            ,IFNULL(content_exposure, 0)-IFNULL(content_exposure_pre, 0) grow_content_exposure
            ,IFNULL(content_click, 0)-IFNULL(content_click_pre, 0) grow_content_click
            ,IFNULL(max_module_positon, 0)-IFNULL(max_module_positon_pre, 0) grow_max_module_positon
            ,IFNULL(sub_page_enter, 0)-IFNULL(sub_page_enter_pre, 0) grow_sub_page_enter
            ,IFNULL(sub_page_click, 0)-IFNULL(sub_page_click_pre, 0) grow_sub_page_click
            ,IFNULL(force_sub_page_enter, 0)-IFNULL(force_sub_page_enter_pre, 0) force_grow_sub_page_enter
            ,IFNULL(force_sub_page_click, 0)-IFNULL(force_sub_page_click_pre, 0) force_grow_sub_page_click
            ,IFNULL(subscript_sub_page_enter, 0)-IFNULL(subscript_sub_page_enter_pre, 0) subscript_grow_sub_page_enter
            ,IFNULL(subscript_sub_page_click, 0)-IFNULL(subscript_sub_page_click_pre, 0) subscript_grow_sub_page_click
            ,IFNULL(other_sub_page_enter, 0)-IFNULL(other_sub_page_enter_pre, 0) other_grow_sub_page_enter
            ,IFNULL(other_sub_page_click, 0)-IFNULL(other_sub_page_click_pre, 0) other_grow_sub_page_click

            ,IFNULL(max_impression_pv, 0)-IFNULL(max_impression_pv_pre, 0) grow_max_impression_pv
            ,IFNULL(impression_pv, 0)-IFNULL(impression_pv_pre, 0) grow_impression_pv
            ,IFNULL(click_pv, 0)-IFNULL(click_pv_pre, 0) grow_click_pv
    from
    (
        select user_pseudo_id
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_enter_pv end) aigc_enter_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then aigc_enter_pv end) aigc_enter_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_use_pv end) aigc_use_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then aigc_use_pv end) aigc_use_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then aigc_save_pv end) aigc_save_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then aigc_save_pv end) aigc_save_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then pop_exposure end) pop_exposure
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then pop_exposure end) pop_exposure_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then pop_click end) pop_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then pop_click end) pop_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then content_exposure end) content_exposure
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then content_exposure end) content_exposure_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then content_click end) content_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then content_click end) content_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then max_module_positon end) max_module_positon
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then max_module_positon end) max_module_positon_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then sub_page_enter end) sub_page_enter
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then sub_page_enter end) sub_page_enter_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then sub_page_click end) sub_page_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then sub_page_click end) sub_page_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then force_sub_page_enter end) force_sub_page_enter
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then force_sub_page_enter end) force_sub_page_enter_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then force_sub_page_click end) force_sub_page_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then force_sub_page_click end) force_sub_page_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then subscript_sub_page_enter end) subscript_sub_page_enter
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then subscript_sub_page_enter end) subscript_sub_page_enter_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then subscript_sub_page_click end) subscript_sub_page_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then subscript_sub_page_click end) subscript_sub_page_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then other_sub_page_enter end) other_sub_page_enter
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then other_sub_page_enter end) other_sub_page_enter_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then other_sub_page_click end) other_sub_page_click
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then other_sub_page_click end) other_sub_page_click_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then max_impression_pv end) max_impression_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then max_impression_pv end) max_impression_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then impression_pv end) impression_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then impression_pv end) impression_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then click_pv end) click_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then click_pv end) click_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then share_pv end) share_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then share_pv end) share_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then search_pv end) search_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then search_pv end) search_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then eva_imp_pv end) eva_imp_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then eva_imp_pv end) eva_imp_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then eva_pv end) eva_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then eva_pv end) eva_pv_pre
            , sum (case when date between date_sub(mDATE, interval 6 day) and mDATE then high_eva_pv end) high_eva_pv
            , sum (case when date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then high_eva_pv end) high_eva_pv_pre

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
)
,
-- 付费素材指标及成长情况
-- beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
pay_duffle as
(
    select user_pseudo_id
            , pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
            , pay_duffle_click_pv_30,free_duffle_click_pv_30,free_duffle_save_pv_30
            , pay_duffle_click_pv_60,free_duffle_click_pv_60,free_duffle_save_pv_60
            , pay_duffle_click_pv_90,free_duffle_click_pv_90,free_duffle_save_pv_90
            , IFNULL(pay_duffle_click_pv, 0)-IFNULL(pay_duffle_click_pv_pre, 0) grow_pay_duffle_click_pv
            , IFNULL(free_duffle_click_pv, 0)-IFNULL(free_duffle_click_pv_pre, 0) grow_free_duffle_click_pv
            , IFNULL(free_duffle_save_pv, 0)-IFNULL(free_duffle_save_pv_pre, 0) grow_free_duffle_save_pv
    from
    (
        select user_pseudo_id
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_pre
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_pre
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_pre

                , sum (case when date_p between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_30
                , sum (case when date_p between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_30
                , sum (case when date_p between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_30

                , sum (case when date_p between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_60
                , sum (case when date_p between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_60
                , sum (case when date_p between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_60

                , sum (case when paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_90
                , sum (case when paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_90
                , sum (case when paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_90
        from beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
        where date_p between date_sub(mDATE, interval 89 day) and mDATE
        group by 1
    )
)
,
home_content as
(
    select user_pseudo_id
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and event_name='homepageappr_bd' then pv end) homepage_exposure_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv

            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and event_name='homepageappr_bd' then pv end) homepage_exposure_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_30
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_30

            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and event_name='homepageappr_bd' then pv end) homepage_exposure_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_60
            ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                    and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_60

            ,sum(case when event_name='homepageappr_bd' then pv end) homepage_exposure_pv_90
            ,sum(case when event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_90
            ,sum(case when module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_90
            ,sum(case when module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_90
            ,sum(case when module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_90
            ,sum(case when module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_90
            ,sum(case when module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_90
            ,sum(case when module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_90
            ,sum(case when module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_90
            ,sum(case when module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_90
            ,sum(case when module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_90
            ,sum(case when module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_90
    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between date_sub(mDATE, interval 89 day) and mDATE
        and event_name in ('homepageappr_bd','home_content_clk_bd','home_content_show_f_bd')
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
    ,g.*except(user_pseudo_id)
    ,a.active_days_60,a.active_days_30,active_days_14
    ,a.active_days_365,a.holiday_active_days_365,a.weekend_active_days_365,a.weekend_include_five_active_days_365
    ,round(a.holiday_active_days_365/a.active_days_365,2) holiday_active_ratio
    ,round(a.weekend_active_days_365/a.active_days_365,2) weekend_active_ratio
    ,round(a.weekend_include_five_active_days_365/a.active_days_365,2) weekend_include_five_active_ratio
    ,c.*except(user_pseudo_id)
    ,c30.*except(user_pseudo_id)
    ,c60.*except(user_pseudo_id)
    ,c90.*except(user_pseudo_id)
    ,o.*except(user_pseudo_id)
    ,p.*except(user_pseudo_id)
    ,pf.*except(user_pseudo_id)
    ,pd.*except(user_pseudo_id)
    ,f.*except(user_pseudo_id)
    ,gr.*except(user_pseudo_id)
    ,h.*except(user_pseudo_id)
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
left join puzzle p
on g.user_pseudo_id=p.user_pseudo_id
left join pay_function pf
on g.user_pseudo_id=pf.user_pseudo_id
left join pay_duffle pd
on g.user_pseudo_id=pd.user_pseudo_id
left join function_use f
on g.user_pseudo_id=f.user_pseudo_id
left join grow gr
on g.user_pseudo_id=gr.user_pseudo_id
left join home_content h
on g.user_pseudo_id=h.user_pseudo_id
;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;




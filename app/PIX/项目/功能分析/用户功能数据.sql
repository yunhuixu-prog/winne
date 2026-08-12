DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2024-05-01');
DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2024-11-30');

drop table if exists beautyplus-bc0ed.temp.function_analysis_winne_data_pre;
create table beautyplus-bc0ed.temp.function_analysis_winne_data_pre as

select event_date,a.mark, case when a.mark=0 and a.module ='拍摄' and a.event_name_cn='自拍页展现' then '自拍' else a.module end module, a.class, a.function
    , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='自拍页展现' then '进入'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
            else a.action
      end action
    , a.user_pseudo_id
    , a.pv
    , b.mark mark_c
    , case when a.mark=0 and a.module ='拍摄' and a.event_name_cn='自拍页展现' then 'selfie' else b.module end module_c
    , b.class class_c, b.function function_c, b.is_pay, b.is_function
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
left join beautyplus-bc0ed.temp.dmi_da_class_is_pay_en b
on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
where event_date between mDATE_START and mDATE_END
    and a.mark in (0, 1, 2)
;
drop table if exists beautyplus-bc0ed.temp.function_analysis_winne_data;
create table beautyplus-bc0ed.temp.function_analysis_winne_data as

-- delete from beautyplus-bc0ed.temp.function_analysis_winne_data where event_date between mDATE_START and mDATE_END;
-- insert into beautyplus-bc0ed.temp.function_analysis_winne_data

with core_behave as
(
    SELECT *
    FROM
    (
        SELECT event_date,user_pseudo_id
            , concat('tab', mark_c, '_'
                , IFNULL(module_c, '')
                , IF(class_c is null, '', '_'), IFNULL(class_c, '')
                , IF(function_c is null, '', '_'), IFNULL(function_c, ''), '_'
                , case when action='点击' then 'click'
                        when action='进入' then 'entry'
                        when action='保存' then 'save'
                        when action='拍摄' then 'shoot' end) behave, sum (pv) pv
        FROM
            beautyplus-bc0ed.temp.function_analysis_winne_data_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between mDATE_START and mDATE_END
        group by 1, 2,3
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
puzzle as
(
    select event_date,user_pseudo_id
            , sum (case when action ='拼图点击' then pv end) puzzle_click_pv
            , sum (case when action ='拼图保存' then pv end) puzzle_save_pv
    from beautyplus-bc0ed.temp.function_analysis_winne_data_pre
    where mark_c is not null
      and action in ('拼图点击', '拼图保存')
      and event_date between mDATE_START and mDATE_END
    group by 1,2
)
,
pay_function as
(
    select event_date,user_pseudo_id
            , sum (case when is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv
            , sum (case when is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv
            , sum (case when is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv
    from beautyplus-bc0ed.temp.function_analysis_winne_data_pre
    where is_function = '功能'
      and mark=2
      and action in ('点击', '保存', '拍摄')
      and event_date between mDATE_START and mDATE_END
    group by 1,2
)
,
pay_duffle as
(
    SELECT
      date_p event_date,user_pseudo_id
            , sum (case when paid_type='1' and event_action in ('impression') then pv end) pay_duffle_exposure_pv
            , sum (case when paid_type='0' and event_action in ('impression') then pv end) free_duffle_exposure_pv
            , sum (case when paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv
            , sum (case when paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv
            , sum (case when paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv
    from
    (
        select t.*,CASE
                    WHEN material_id IN ('BV_STX_00000001', 'BV_STX_00009999') THEN '0'
                    ELSE IFNULL(duffle.paid_type, marvel.paid_type)
                  END AS paid_type
        FROM
        (
            -- 如果数量太大就限制一下目标用户
            SELECT
              date_p,
              'BeautyPlus' app_name,
              platform,
              event_action,
              user_pseudo_id,
              module,
              material_lv1,
              x.material_id,
              x.material_type,
              count(1) pv
            FROM
              `dataintegration-265403.duffle.dwd_dz_material_events`,UNNEST(material_info) x
            WHERE app_code = 'BP'
              and event_action in ('impression', 'click', 'use', 'save')
              and date_p between mDATE_START and mDATE_END
            group by 1,2,3,4,5,6,7,8,9
        ) t
        LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` duffle -- new_duffle素材信息，获取付费信息
            ON t.app_name = duffle.app
            AND t.platform = duffle.platform
            AND t.material_id = duffle.m_id
            AND t.date_p >= duffle.start_date
            AND t.date_p < duffle.end_date
            AND duffle.`source` = 'new_duffle'
        LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` marvel -- marvel素材信息，获取付费信息
            ON t.app_name = marvel.app
            AND t.platform = marvel.platform
            AND t.material_id = marvel.m_id
            AND t.date_p >= marvel.start_date
            AND t.date_p < marvel.end_date
            AND marvel.`source` = 'marvel'
    )
    group by 1,2
)


select coalesce(a.event_date,b.event_date) event_date
    ,coalesce(a.user_pseudo_id,b.user_pseudo_id) user_pseudo_id
    ,a.*except(event_date,user_pseudo_id)
    ,b.*except(event_date,user_pseudo_id)
from
(
    select *
    from core_behave
) a
full join
(
    select event_date,user_pseudo_id
        , sum(puzzle_click_pv) puzzle_click_pv, sum(puzzle_save_pv) puzzle_save_pv
        , sum(pay_function_click_pv) pay_function_click_pv, sum(free_function_click_pv) free_function_click_pv, sum(free_function_save_pv) free_function_save_pv
        , sum(pay_duffle_exposure_pv) pay_duffle_exposure_pv, sum(free_duffle_exposure_pv) free_duffle_exposure_pv
        , sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv

    from
    (
        select event_date,user_pseudo_id
            ,puzzle_click_pv,puzzle_save_pv
            ,0 pay_function_click_pv,0 free_function_click_pv,0 free_function_save_pv
            ,0 pay_duffle_exposure_pv,0 free_duffle_exposure_pv,0 pay_duffle_click_pv,0 free_duffle_click_pv,0 free_duffle_save_pv
        from puzzle

        union all

        select event_date,user_pseudo_id
            ,0 puzzle_click_pv,0 puzzle_save_pv
            ,pay_function_click_pv,free_function_click_pv,free_function_save_pv
            ,0 pay_duffle_exposure_pv,0 free_duffle_exposure_pv,0 pay_duffle_click_pv,0 free_duffle_click_pv,0 free_duffle_save_pv
        from pay_function

        union all

        select event_date,user_pseudo_id
            ,0 puzzle_click_pv,0 puzzle_save_pv
            ,0 pay_function_click_pv,0 free_function_click_pv,0 free_function_save_pv
            ,pay_duffle_exposure_pv,free_duffle_exposure_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
        from pay_duffle
    )
    group by 1,2
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
;
-- 加入其他信息:未来7天是否订阅

drop table if exists beautyplus-bc0ed.temp.function_analysis_winne_data_final;
create table beautyplus-bc0ed.temp.function_analysis_winne_data_final as

-- delete from beautyplus-bc0ed.temp.function_analysis_winne_data_final where event_date between mDATE_START and mDATE_END;
-- insert into beautyplus-bc0ed.temp.function_analysis_winne_data_final

with
users as
(
    select event_date_hk event_date,user_pseudo_id,active_days_90d,platform
         ,DATE_DIFF(event_date_hk,first_active_date,DAY)+1 install_days
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between mDATE_START and mDATE_END and active_days_90d>0
)
,
functions as
(
    select a.date event_date_hk
        ,b.user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry_30, sum(pv_tab0_edit_save) pv_tab0_edit_save_30, sum(pv_tab0_movie_save) pv_tab0_movie_save_30, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot_30, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry_30, sum(pv_tab0_shoot_save) pv_tab0_shoot_save_30, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot_30, sum(pv_tab0_video_save) pv_tab0_video_save_30, sum(pv_tab0_video_shoot) pv_tab0_video_shoot_30, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry_30, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save_30
        , sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click_30, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save_30, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click_30, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save_30, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click_30, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save_30, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click_30, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save_30, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click_30, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save_30, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click_30, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save_30, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot_30, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save_30, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save_30, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot_30, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save_30, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot_30, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save_30, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot_30
        , sum(pv_tab2_edit_beauty_AIbeauty_click) pv_tab2_edit_beauty_AIbeauty_click_30, sum(pv_tab2_edit_beauty_AIbeauty_save) pv_tab2_edit_beauty_AIbeauty_save_30, sum(pv_tab2_edit_beauty_Threedimensionalface_click) pv_tab2_edit_beauty_Threedimensionalface_click_30, sum(pv_tab2_edit_beauty_Threedimensionalface_save) pv_tab2_edit_beauty_Threedimensionalface_save_30, sum(pv_tab2_edit_beauty_detail_click) pv_tab2_edit_beauty_detail_click_30, sum(pv_tab2_edit_beauty_detail_save) pv_tab2_edit_beauty_detail_save_30, sum(pv_tab2_edit_beauty_doublechin_click) pv_tab2_edit_beauty_doublechin_click_30, sum(pv_tab2_edit_beauty_doublechin_save) pv_tab2_edit_beauty_doublechin_save_30, sum(pv_tab2_edit_beauty_evenskin_click) pv_tab2_edit_beauty_evenskin_click_30, sum(pv_tab2_edit_beauty_evenskin_save) pv_tab2_edit_beauty_evenskin_save_30, sum(pv_tab2_edit_beauty_expression_click) pv_tab2_edit_beauty_expression_click_30, sum(pv_tab2_edit_beauty_expression_save) pv_tab2_edit_beauty_expression_save_30, sum(pv_tab2_edit_beauty_eyecatching_click) pv_tab2_edit_beauty_eyecatching_click_30, sum(pv_tab2_edit_beauty_eyecatching_save) pv_tab2_edit_beauty_eyecatching_save_30, sum(pv_tab2_edit_beauty_eyedilated_click) pv_tab2_edit_beauty_eyedilated_click_30, sum(pv_tab2_edit_beauty_eyedilated_save) pv_tab2_edit_beauty_eyedilated_save_30, sum(pv_tab2_edit_beauty_facecolor_click) pv_tab2_edit_beauty_facecolor_click_30, sum(pv_tab2_edit_beauty_facecolor_save) pv_tab2_edit_beauty_facecolor_save_30, sum(pv_tab2_edit_beauty_faceslimming_click) pv_tab2_edit_beauty_faceslimming_click_30, sum(pv_tab2_edit_beauty_faceslimming_save) pv_tab2_edit_beauty_faceslimming_save_30, sum(pv_tab2_edit_beauty_faciallighting_click) pv_tab2_edit_beauty_faciallighting_click_30, sum(pv_tab2_edit_beauty_faciallighting_save) pv_tab2_edit_beauty_faciallighting_save_30, sum(pv_tab2_edit_beauty_facialreshaping_click) pv_tab2_edit_beauty_facialreshaping_click_30, sum(pv_tab2_edit_beauty_facialreshaping_save) pv_tab2_edit_beauty_facialreshaping_save_30, sum(pv_tab2_edit_beauty_hairdressing_click) pv_tab2_edit_beauty_hairdressing_click_30, sum(pv_tab2_edit_beauty_hairdressing_save) pv_tab2_edit_beauty_hairdressing_save_30, sum(pv_tab2_edit_beauty_lightendarkcircle_click) pv_tab2_edit_beauty_lightendarkcircle_click_30, sum(pv_tab2_edit_beauty_lightendarkcircle_save) pv_tab2_edit_beauty_lightendarkcircle_save_30, sum(pv_tab2_edit_beauty_microdermabrasion_click) pv_tab2_edit_beauty_microdermabrasion_click_30, sum(pv_tab2_edit_beauty_microdermabrasion_save) pv_tab2_edit_beauty_microdermabrasion_save_30, sum(pv_tab2_edit_beauty_narrownose_click) pv_tab2_edit_beauty_narrownose_click_30, sum(pv_tab2_edit_beauty_narrownose_save) pv_tab2_edit_beauty_narrownose_save_30, sum(pv_tab2_edit_beauty_oneclickbeauty_click) pv_tab2_edit_beauty_oneclickbeauty_click_30, sum(pv_tab2_edit_beauty_oneclickbeauty_save) pv_tab2_edit_beauty_oneclickbeauty_save_30, sum(pv_tab2_edit_beauty_orthodontics_click) pv_tab2_edit_beauty_orthodontics_click_30, sum(pv_tab2_edit_beauty_orthodontics_save) pv_tab2_edit_beauty_orthodontics_save_30, sum(pv_tab2_edit_beauty_removieacne_click) pv_tab2_edit_beauty_removieacne_click_30, sum(pv_tab2_edit_beauty_removieacne_save) pv_tab2_edit_beauty_removieacne_save_30, sum(pv_tab2_edit_beauty_removieshine_click) pv_tab2_edit_beauty_removieshine_click_30, sum(pv_tab2_edit_beauty_removieshine_save) pv_tab2_edit_beauty_removieshine_save_30, sum(pv_tab2_edit_beauty_removiewrinkles_click) pv_tab2_edit_beauty_removiewrinkles_click_30, sum(pv_tab2_edit_beauty_removiewrinkles_save) pv_tab2_edit_beauty_removiewrinkles_save_30, sum(pv_tab2_edit_beauty_shape_click) pv_tab2_edit_beauty_shape_click_30, sum(pv_tab2_edit_beauty_shape_save) pv_tab2_edit_beauty_shape_save_30, sum(pv_tab2_edit_beauty_shrinkhead_click) pv_tab2_edit_beauty_shrinkhead_click_30, sum(pv_tab2_edit_beauty_shrinkhead_save) pv_tab2_edit_beauty_shrinkhead_save_30, sum(pv_tab2_edit_beauty_teethwhitening_click) pv_tab2_edit_beauty_teethwhitening_click_30, sum(pv_tab2_edit_beauty_teethwhitening_save) pv_tab2_edit_beauty_teethwhitening_save_30, sum(pv_tab2_edit_creative_background_click) pv_tab2_edit_creative_background_click_30, sum(pv_tab2_edit_creative_background_save) pv_tab2_edit_creative_background_save_30, sum(pv_tab2_edit_creative_formula_click) pv_tab2_edit_creative_formula_click_30, sum(pv_tab2_edit_creative_formula_save) pv_tab2_edit_creative_formula_save_30, sum(pv_tab2_edit_creative_graffiti_click) pv_tab2_edit_creative_graffiti_click_30, sum(pv_tab2_edit_creative_graffiti_save) pv_tab2_edit_creative_graffiti_save_30, sum(pv_tab2_edit_creative_sticker_click) pv_tab2_edit_creative_sticker_click_30, sum(pv_tab2_edit_creative_sticker_save) pv_tab2_edit_creative_sticker_save_30, sum(pv_tab2_edit_creative_text_click) pv_tab2_edit_creative_text_click_30, sum(pv_tab2_edit_creative_text_save) pv_tab2_edit_creative_text_save_30, sum(pv_tab2_edit_edit_AIenhance_click) pv_tab2_edit_edit_AIenhance_click_30, sum(pv_tab2_edit_edit_AIenhance_save) pv_tab2_edit_edit_AIenhance_save_30, sum(pv_tab2_edit_edit_AIextension_click) pv_tab2_edit_edit_AIextension_click_30, sum(pv_tab2_edit_edit_AIextension_save) pv_tab2_edit_edit_AIextension_save_30, sum(pv_tab2_edit_edit_adjustment_click) pv_tab2_edit_edit_adjustment_click_30, sum(pv_tab2_edit_edit_ar_click) pv_tab2_edit_edit_ar_click_30, sum(pv_tab2_edit_edit_ar_save) pv_tab2_edit_edit_ar_save_30, sum(pv_tab2_edit_edit_blur_click) pv_tab2_edit_edit_blur_click_30, sum(pv_tab2_edit_edit_blur_save) pv_tab2_edit_edit_blur_save_30, sum(pv_tab2_edit_edit_clone_click) pv_tab2_edit_edit_clone_click_30, sum(pv_tab2_edit_edit_clone_save) pv_tab2_edit_edit_clone_save_30, sum(pv_tab2_edit_edit_composition_click) pv_tab2_edit_edit_composition_click_30, sum(pv_tab2_edit_edit_composition_save) pv_tab2_edit_edit_composition_save_30, sum(pv_tab2_edit_edit_cutout_click) pv_tab2_edit_edit_cutout_click_30, sum(pv_tab2_edit_edit_cutout_save) pv_tab2_edit_edit_cutout_save_30, sum(pv_tab2_edit_edit_dispersion_click) pv_tab2_edit_edit_dispersion_click_30, sum(pv_tab2_edit_edit_dispersion_save) pv_tab2_edit_edit_dispersion_save_30, sum(pv_tab2_edit_edit_elimination_click) pv_tab2_edit_edit_elimination_click_30, sum(pv_tab2_edit_edit_elimination_save) pv_tab2_edit_edit_elimination_save_30, sum(pv_tab2_edit_edit_mosaic_click) pv_tab2_edit_edit_mosaic_click_30, sum(pv_tab2_edit_edit_mosaic_save) pv_tab2_edit_edit_mosaic_save_30, sum(pv_tab2_edit_edit_photorepair_click) pv_tab2_edit_edit_photorepair_click_30, sum(pv_tab2_edit_edit_photorepair_save) pv_tab2_edit_edit_photorepair_save_30, sum(pv_tab2_edit_edit_stylization_click) pv_tab2_edit_edit_stylization_click_30, sum(pv_tab2_edit_edit_stylization_save) pv_tab2_edit_edit_stylization_save_30, sum(pv_tab2_shoot_beauty_bigeyes_save) pv_tab2_shoot_beauty_bigeyes_save_30, sum(pv_tab2_shoot_beauty_eyecatching_save) pv_tab2_shoot_beauty_eyecatching_save_30, sum(pv_tab2_shoot_beauty_facecolor_save) pv_tab2_shoot_beauty_facecolor_save_30, sum(pv_tab2_shoot_beauty_faceslimming_save) pv_tab2_shoot_beauty_faceslimming_save_30, sum(pv_tab2_shoot_beauty_microdermabrasion_save) pv_tab2_shoot_beauty_microdermabrasion_save_30, sum(pv_tab2_shoot_beauty_oneclickbody_save) pv_tab2_shoot_beauty_oneclickbody_save_30, sum(pv_tab2_shoot_beauty_removieacnefreckles_save) pv_tab2_shoot_beauty_removieacnefreckles_save_30, sum(pv_tab2_shoot_beauty_removiedarkcircles_save) pv_tab2_shoot_beauty_removiedarkcircles_save_30, sum(pv_tab2_shoot_beauty_removienasolabial_save) pv_tab2_shoot_beauty_removienasolabial_save_30, sum(pv_tab2_shoot_beauty_shrinkhead_save) pv_tab2_shoot_beauty_shrinkhead_save_30, sum(pv_tab2_shoot_beauty_softhair_save) pv_tab2_shoot_beauty_softhair_save_30, sum(pv_tab2_shoot_beauty_teethwhitening_save) pv_tab2_shoot_beauty_teethwhitening_save_30, sum(pv_tab2_shoot_beauty_thinnose_save) pv_tab2_shoot_beauty_thinnose_save_30, sum(pv_tab2_shoot_makeup_blush_save) pv_tab2_shoot_makeup_blush_save_30, sum(pv_tab2_shoot_makeup_blush_shoot) pv_tab2_shoot_makeup_blush_shoot_30, sum(pv_tab2_shoot_makeup_contactlenses_save) pv_tab2_shoot_makeup_contactlenses_save_30, sum(pv_tab2_shoot_makeup_contactlenses_shoot) pv_tab2_shoot_makeup_contactlenses_shoot_30, sum(pv_tab2_shoot_makeup_dyehair_save) pv_tab2_shoot_makeup_dyehair_save_30, sum(pv_tab2_shoot_makeup_dyehair_shoot) pv_tab2_shoot_makeup_dyehair_shoot_30, sum(pv_tab2_shoot_makeup_eyebrow_save) pv_tab2_shoot_makeup_eyebrow_save_30, sum(pv_tab2_shoot_makeup_eyebrow_shoot) pv_tab2_shoot_makeup_eyebrow_shoot_30, sum(pv_tab2_shoot_makeup_eyelash_save) pv_tab2_shoot_makeup_eyelash_save_30, sum(pv_tab2_shoot_makeup_eyelash_shoot) pv_tab2_shoot_makeup_eyelash_shoot_30, sum(pv_tab2_shoot_makeup_eyeshadow_save) pv_tab2_shoot_makeup_eyeshadow_save_30, sum(pv_tab2_shoot_makeup_eyeshadow_shoot) pv_tab2_shoot_makeup_eyeshadow_shoot_30, sum(pv_tab2_shoot_makeup_freckle_save) pv_tab2_shoot_makeup_freckle_save_30, sum(pv_tab2_shoot_makeup_freckle_shoot) pv_tab2_shoot_makeup_freckle_shoot_30, sum(pv_tab2_shoot_makeup_lipstick_save) pv_tab2_shoot_makeup_lipstick_save_30, sum(pv_tab2_shoot_makeup_lipstick_shoot) pv_tab2_shoot_makeup_lipstick_shoot_30, sum(pv_tab2_shoot_makeup_lyingsilkworm_save) pv_tab2_shoot_makeup_lyingsilkworm_save_30, sum(pv_tab2_shoot_makeup_lyingsilkworm_shoot) pv_tab2_shoot_makeup_lyingsilkworm_shoot_30, sum(pv_tab2_shoot_makeup_trimming_save) pv_tab2_shoot_makeup_trimming_save_30, sum(pv_tab2_shoot_makeup_trimming_shoot) pv_tab2_shoot_makeup_trimming_shoot_30
        , sum(puzzle_click_pv) puzzle_click_pv_30, sum(puzzle_save_pv) puzzle_save_pv_30
        , sum(pay_function_click_pv) pay_function_click_pv_30, sum(free_function_click_pv) free_function_click_pv_30, sum(free_function_save_pv) free_function_save_pv_30
        , sum(pay_duffle_exposure_pv) pay_duffle_exposure_pv_30, sum(free_duffle_exposure_pv) free_duffle_exposure_pv_30, sum(pay_duffle_click_pv) pay_duffle_click_pv_30, sum(free_duffle_click_pv) free_duffle_click_pv_30, sum(free_duffle_save_pv) free_duffle_save_pv_30
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join
    (
        select *
        from beautyplus-bc0ed.temp.function_analysis_winne_data
         where event_date between DATE_SUB(mDATE_START, INTERVAL 29 DAY) and mDATE_END
    ) b
    where b.event_date between DATE_SUB(a.date, INTERVAL 29 DAY) and a.date
    group by 1,2
)
,
sub_event as
(
    select
        uuid,standard_order_date,order_status,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 7 day)
        and app_id in('BeautyPlus')
        and order_status in (0,1,2)
    group by 1,2,3
)
,
sub_his_now as
(
    select a.date event_date_hk
        ,b.uuid
        ,count(case when b.event_date_hk = a.date and (is_current_trial = 1 or is_current_pay = 1) then 1 end) sub_status_now
        ,count(case when b.event_date_hk = a.date and is_current_pay = 1 then 1 end) sub_pay_status_now
        ,count(case when b.event_date_hk = a.date and is_current_trial = 1 then 1 end) trial_status_now
        ,max(case when b.event_date_hk = a.date then past_sub_times end) past_sub_times
        ,max(case when b.event_date_hk = a.date then past_trial_times end) past_trial_times
        ,count(case when is_current_trial = 1 or is_current_pay = 1 then 1 end) sub_status_pre_90
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join
    (
        select uuid,event_date_hk,current_sub_sku_type
            ,if(current_trial_day is not null,1,0) is_current_trial
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times past_trial_times
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
         where event_date_hk between DATE_SUB(mDATE_START, INTERVAL 89 DAY) and mDATE_END and app_id in ('BeautyPlus')
    ) b
    where b.event_date_hk between DATE_SUB(a.date, INTERVAL 89 DAY) and a.date
    group by 1,2
)
,
future_sub_pay as
(
    select a.date event_date_hk
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) future_sub_7
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) and order_status in (1,2) then 1 end) future_sub_pay_7
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join sub_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY)
    group by 1,2
)

select a.event_date,a.user_pseudo_id,b.uuid,a.platform
        ,a.active_days_90d,a.install_days
        ,d.*except(event_date_hk,user_pseudo_id)
        ,coalesce(c.sub_status_now,0) sub_status_now
        ,coalesce(c.sub_pay_status_now,0) sub_pay_status_now
        ,coalesce(c.trial_status_now,0) trial_status_now
        ,coalesce(c.past_sub_times,0) past_sub_times
        ,coalesce(c.past_trial_times,0) past_trial_times
        ,coalesce(c.sub_status_pre_90,0) sub_status_pre_90
        ,coalesce(e.future_sub_7,0) future_sub_7
        ,coalesce(e.future_sub_pay_7,0) future_sub_pay_7
from users a
left join (select key,uuid from `dataintegration-265403.stat.dmi_dz_idmapping`) b
on a.user_pseudo_id=b.key
left join sub_his_now c
on b.uuid=c.uuid and a.event_date=c.event_date_hk
left join functions d
on a.user_pseudo_id=d.user_pseudo_id and a.event_date=d.event_date_hk
left join future_sub_pay e
on b.uuid=e.uuid and a.event_date=e.event_date_hk

;

-- drop table if exists beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final;
-- create table beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final as

delete from beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final where event_date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final

with
users as
(
    select event_date_hk event_date,user_pseudo_id,active_days_90d,platform
         ,DATE_DIFF(event_date_hk,first_active_date,DAY)+1 install_days
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between mDATE_START and mDATE_END and active_days_90d>0
)
,
functions_7 as
(
    select a.date event_date_hk
        ,b.user_pseudo_id
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry_7, sum(pv_tab0_edit_save) pv_tab0_edit_save_7, sum(pv_tab0_movie_save) pv_tab0_movie_save_7, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot_7, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry_7, sum(pv_tab0_shoot_save) pv_tab0_shoot_save_7, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot_7, sum(pv_tab0_video_save) pv_tab0_video_save_7, sum(pv_tab0_video_shoot) pv_tab0_video_shoot_7, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry_7, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save_7
        , sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click_7, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save_7, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click_7, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save_7, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click_7, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save_7, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click_7, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save_7, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click_7, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save_7, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click_7, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save_7, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot_7, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save_7, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save_7, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot_7, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save_7, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot_7, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save_7, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot_7
        , sum(pv_tab2_edit_beauty_AIbeauty_click) pv_tab2_edit_beauty_AIbeauty_click_7, sum(pv_tab2_edit_beauty_AIbeauty_save) pv_tab2_edit_beauty_AIbeauty_save_7, sum(pv_tab2_edit_beauty_Threedimensionalface_click) pv_tab2_edit_beauty_Threedimensionalface_click_7, sum(pv_tab2_edit_beauty_Threedimensionalface_save) pv_tab2_edit_beauty_Threedimensionalface_save_7, sum(pv_tab2_edit_beauty_detail_click) pv_tab2_edit_beauty_detail_click_7, sum(pv_tab2_edit_beauty_detail_save) pv_tab2_edit_beauty_detail_save_7, sum(pv_tab2_edit_beauty_doublechin_click) pv_tab2_edit_beauty_doublechin_click_7, sum(pv_tab2_edit_beauty_doublechin_save) pv_tab2_edit_beauty_doublechin_save_7, sum(pv_tab2_edit_beauty_evenskin_click) pv_tab2_edit_beauty_evenskin_click_7, sum(pv_tab2_edit_beauty_evenskin_save) pv_tab2_edit_beauty_evenskin_save_7, sum(pv_tab2_edit_beauty_expression_click) pv_tab2_edit_beauty_expression_click_7, sum(pv_tab2_edit_beauty_expression_save) pv_tab2_edit_beauty_expression_save_7, sum(pv_tab2_edit_beauty_eyecatching_click) pv_tab2_edit_beauty_eyecatching_click_7, sum(pv_tab2_edit_beauty_eyecatching_save) pv_tab2_edit_beauty_eyecatching_save_7, sum(pv_tab2_edit_beauty_eyedilated_click) pv_tab2_edit_beauty_eyedilated_click_7, sum(pv_tab2_edit_beauty_eyedilated_save) pv_tab2_edit_beauty_eyedilated_save_7, sum(pv_tab2_edit_beauty_facecolor_click) pv_tab2_edit_beauty_facecolor_click_7, sum(pv_tab2_edit_beauty_facecolor_save) pv_tab2_edit_beauty_facecolor_save_7, sum(pv_tab2_edit_beauty_faceslimming_click) pv_tab2_edit_beauty_faceslimming_click_7, sum(pv_tab2_edit_beauty_faceslimming_save) pv_tab2_edit_beauty_faceslimming_save_7, sum(pv_tab2_edit_beauty_faciallighting_click) pv_tab2_edit_beauty_faciallighting_click_7, sum(pv_tab2_edit_beauty_faciallighting_save) pv_tab2_edit_beauty_faciallighting_save_7, sum(pv_tab2_edit_beauty_facialreshaping_click) pv_tab2_edit_beauty_facialreshaping_click_7, sum(pv_tab2_edit_beauty_facialreshaping_save) pv_tab2_edit_beauty_facialreshaping_save_7, sum(pv_tab2_edit_beauty_hairdressing_click) pv_tab2_edit_beauty_hairdressing_click_7, sum(pv_tab2_edit_beauty_hairdressing_save) pv_tab2_edit_beauty_hairdressing_save_7, sum(pv_tab2_edit_beauty_lightendarkcircle_click) pv_tab2_edit_beauty_lightendarkcircle_click_7, sum(pv_tab2_edit_beauty_lightendarkcircle_save) pv_tab2_edit_beauty_lightendarkcircle_save_7, sum(pv_tab2_edit_beauty_microdermabrasion_click) pv_tab2_edit_beauty_microdermabrasion_click_7, sum(pv_tab2_edit_beauty_microdermabrasion_save) pv_tab2_edit_beauty_microdermabrasion_save_7, sum(pv_tab2_edit_beauty_narrownose_click) pv_tab2_edit_beauty_narrownose_click_7, sum(pv_tab2_edit_beauty_narrownose_save) pv_tab2_edit_beauty_narrownose_save_7, sum(pv_tab2_edit_beauty_oneclickbeauty_click) pv_tab2_edit_beauty_oneclickbeauty_click_7, sum(pv_tab2_edit_beauty_oneclickbeauty_save) pv_tab2_edit_beauty_oneclickbeauty_save_7, sum(pv_tab2_edit_beauty_orthodontics_click) pv_tab2_edit_beauty_orthodontics_click_7, sum(pv_tab2_edit_beauty_orthodontics_save) pv_tab2_edit_beauty_orthodontics_save_7, sum(pv_tab2_edit_beauty_removieacne_click) pv_tab2_edit_beauty_removieacne_click_7, sum(pv_tab2_edit_beauty_removieacne_save) pv_tab2_edit_beauty_removieacne_save_7, sum(pv_tab2_edit_beauty_removieshine_click) pv_tab2_edit_beauty_removieshine_click_7, sum(pv_tab2_edit_beauty_removieshine_save) pv_tab2_edit_beauty_removieshine_save_7, sum(pv_tab2_edit_beauty_removiewrinkles_click) pv_tab2_edit_beauty_removiewrinkles_click_7, sum(pv_tab2_edit_beauty_removiewrinkles_save) pv_tab2_edit_beauty_removiewrinkles_save_7, sum(pv_tab2_edit_beauty_shape_click) pv_tab2_edit_beauty_shape_click_7, sum(pv_tab2_edit_beauty_shape_save) pv_tab2_edit_beauty_shape_save_7, sum(pv_tab2_edit_beauty_shrinkhead_click) pv_tab2_edit_beauty_shrinkhead_click_7, sum(pv_tab2_edit_beauty_shrinkhead_save) pv_tab2_edit_beauty_shrinkhead_save_7, sum(pv_tab2_edit_beauty_teethwhitening_click) pv_tab2_edit_beauty_teethwhitening_click_7, sum(pv_tab2_edit_beauty_teethwhitening_save) pv_tab2_edit_beauty_teethwhitening_save_7, sum(pv_tab2_edit_creative_background_click) pv_tab2_edit_creative_background_click_7, sum(pv_tab2_edit_creative_background_save) pv_tab2_edit_creative_background_save_7, sum(pv_tab2_edit_creative_formula_click) pv_tab2_edit_creative_formula_click_7, sum(pv_tab2_edit_creative_formula_save) pv_tab2_edit_creative_formula_save_7, sum(pv_tab2_edit_creative_graffiti_click) pv_tab2_edit_creative_graffiti_click_7, sum(pv_tab2_edit_creative_graffiti_save) pv_tab2_edit_creative_graffiti_save_7, sum(pv_tab2_edit_creative_sticker_click) pv_tab2_edit_creative_sticker_click_7, sum(pv_tab2_edit_creative_sticker_save) pv_tab2_edit_creative_sticker_save_7, sum(pv_tab2_edit_creative_text_click) pv_tab2_edit_creative_text_click_7, sum(pv_tab2_edit_creative_text_save) pv_tab2_edit_creative_text_save_7, sum(pv_tab2_edit_edit_AIenhance_click) pv_tab2_edit_edit_AIenhance_click_7, sum(pv_tab2_edit_edit_AIenhance_save) pv_tab2_edit_edit_AIenhance_save_7, sum(pv_tab2_edit_edit_AIextension_click) pv_tab2_edit_edit_AIextension_click_7, sum(pv_tab2_edit_edit_AIextension_save) pv_tab2_edit_edit_AIextension_save_7, sum(pv_tab2_edit_edit_adjustment_click) pv_tab2_edit_edit_adjustment_click_7, sum(pv_tab2_edit_edit_ar_click) pv_tab2_edit_edit_ar_click_7, sum(pv_tab2_edit_edit_ar_save) pv_tab2_edit_edit_ar_save_7, sum(pv_tab2_edit_edit_blur_click) pv_tab2_edit_edit_blur_click_7, sum(pv_tab2_edit_edit_blur_save) pv_tab2_edit_edit_blur_save_7, sum(pv_tab2_edit_edit_clone_click) pv_tab2_edit_edit_clone_click_7, sum(pv_tab2_edit_edit_clone_save) pv_tab2_edit_edit_clone_save_7, sum(pv_tab2_edit_edit_composition_click) pv_tab2_edit_edit_composition_click_7, sum(pv_tab2_edit_edit_composition_save) pv_tab2_edit_edit_composition_save_7, sum(pv_tab2_edit_edit_cutout_click) pv_tab2_edit_edit_cutout_click_7, sum(pv_tab2_edit_edit_cutout_save) pv_tab2_edit_edit_cutout_save_7, sum(pv_tab2_edit_edit_dispersion_click) pv_tab2_edit_edit_dispersion_click_7, sum(pv_tab2_edit_edit_dispersion_save) pv_tab2_edit_edit_dispersion_save_7, sum(pv_tab2_edit_edit_elimination_click) pv_tab2_edit_edit_elimination_click_7, sum(pv_tab2_edit_edit_elimination_save) pv_tab2_edit_edit_elimination_save_7, sum(pv_tab2_edit_edit_mosaic_click) pv_tab2_edit_edit_mosaic_click_7, sum(pv_tab2_edit_edit_mosaic_save) pv_tab2_edit_edit_mosaic_save_7, sum(pv_tab2_edit_edit_photorepair_click) pv_tab2_edit_edit_photorepair_click_7, sum(pv_tab2_edit_edit_photorepair_save) pv_tab2_edit_edit_photorepair_save_7, sum(pv_tab2_edit_edit_stylization_click) pv_tab2_edit_edit_stylization_click_7, sum(pv_tab2_edit_edit_stylization_save) pv_tab2_edit_edit_stylization_save_7, sum(pv_tab2_shoot_beauty_bigeyes_save) pv_tab2_shoot_beauty_bigeyes_save_7, sum(pv_tab2_shoot_beauty_eyecatching_save) pv_tab2_shoot_beauty_eyecatching_save_7, sum(pv_tab2_shoot_beauty_facecolor_save) pv_tab2_shoot_beauty_facecolor_save_7, sum(pv_tab2_shoot_beauty_faceslimming_save) pv_tab2_shoot_beauty_faceslimming_save_7, sum(pv_tab2_shoot_beauty_microdermabrasion_save) pv_tab2_shoot_beauty_microdermabrasion_save_7, sum(pv_tab2_shoot_beauty_oneclickbody_save) pv_tab2_shoot_beauty_oneclickbody_save_7, sum(pv_tab2_shoot_beauty_removieacnefreckles_save) pv_tab2_shoot_beauty_removieacnefreckles_save_7, sum(pv_tab2_shoot_beauty_removiedarkcircles_save) pv_tab2_shoot_beauty_removiedarkcircles_save_7, sum(pv_tab2_shoot_beauty_removienasolabial_save) pv_tab2_shoot_beauty_removienasolabial_save_7, sum(pv_tab2_shoot_beauty_shrinkhead_save) pv_tab2_shoot_beauty_shrinkhead_save_7, sum(pv_tab2_shoot_beauty_softhair_save) pv_tab2_shoot_beauty_softhair_save_7, sum(pv_tab2_shoot_beauty_teethwhitening_save) pv_tab2_shoot_beauty_teethwhitening_save_7, sum(pv_tab2_shoot_beauty_thinnose_save) pv_tab2_shoot_beauty_thinnose_save_7, sum(pv_tab2_shoot_makeup_blush_save) pv_tab2_shoot_makeup_blush_save_7, sum(pv_tab2_shoot_makeup_blush_shoot) pv_tab2_shoot_makeup_blush_shoot_7, sum(pv_tab2_shoot_makeup_contactlenses_save) pv_tab2_shoot_makeup_contactlenses_save_7, sum(pv_tab2_shoot_makeup_contactlenses_shoot) pv_tab2_shoot_makeup_contactlenses_shoot_7, sum(pv_tab2_shoot_makeup_dyehair_save) pv_tab2_shoot_makeup_dyehair_save_7, sum(pv_tab2_shoot_makeup_dyehair_shoot) pv_tab2_shoot_makeup_dyehair_shoot_7, sum(pv_tab2_shoot_makeup_eyebrow_save) pv_tab2_shoot_makeup_eyebrow_save_7, sum(pv_tab2_shoot_makeup_eyebrow_shoot) pv_tab2_shoot_makeup_eyebrow_shoot_7, sum(pv_tab2_shoot_makeup_eyelash_save) pv_tab2_shoot_makeup_eyelash_save_7, sum(pv_tab2_shoot_makeup_eyelash_shoot) pv_tab2_shoot_makeup_eyelash_shoot_7, sum(pv_tab2_shoot_makeup_eyeshadow_save) pv_tab2_shoot_makeup_eyeshadow_save_7, sum(pv_tab2_shoot_makeup_eyeshadow_shoot) pv_tab2_shoot_makeup_eyeshadow_shoot_7, sum(pv_tab2_shoot_makeup_freckle_save) pv_tab2_shoot_makeup_freckle_save_7, sum(pv_tab2_shoot_makeup_freckle_shoot) pv_tab2_shoot_makeup_freckle_shoot_7, sum(pv_tab2_shoot_makeup_lipstick_save) pv_tab2_shoot_makeup_lipstick_save_7, sum(pv_tab2_shoot_makeup_lipstick_shoot) pv_tab2_shoot_makeup_lipstick_shoot_7, sum(pv_tab2_shoot_makeup_lyingsilkworm_save) pv_tab2_shoot_makeup_lyingsilkworm_save_7, sum(pv_tab2_shoot_makeup_lyingsilkworm_shoot) pv_tab2_shoot_makeup_lyingsilkworm_shoot_7, sum(pv_tab2_shoot_makeup_trimming_save) pv_tab2_shoot_makeup_trimming_save_7, sum(pv_tab2_shoot_makeup_trimming_shoot) pv_tab2_shoot_makeup_trimming_shoot_7
        , sum(puzzle_click_pv) puzzle_click_pv_7, sum(puzzle_save_pv) puzzle_save_pv_7
        , sum(pay_function_click_pv) pay_function_click_pv_7, sum(free_function_click_pv) free_function_click_pv_7, sum(free_function_save_pv) free_function_save_pv_7
        , sum(pay_duffle_exposure_pv) pay_duffle_exposure_pv_7, sum(free_duffle_exposure_pv) free_duffle_exposure_pv_7, sum(pay_duffle_click_pv) pay_duffle_click_pv_7, sum(free_duffle_click_pv) free_duffle_click_pv_7, sum(free_duffle_save_pv) free_duffle_save_pv_7
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join
    (
        select *
        from beautyplus-bc0ed.temp.function_analysis_winne_data
         where event_date between DATE_SUB(mDATE_START, INTERVAL 6 DAY) and mDATE_END
    ) b
    where b.event_date between DATE_SUB(a.date, INTERVAL 6 DAY) and a.date
    group by 1,2
)
,
functions_1 as
(
    select *
    from beautyplus-bc0ed.temp.function_analysis_winne_data
     where event_date between mDATE_START and mDATE_END
)
,
sub_event as
(
    select
        uuid,standard_order_date,order_status,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 7 day)
        and app_id in('BeautyPlus')
        and order_status in (0,1,2)
    group by 1,2,3
)
,
sub_his_now as
(
    select a.date event_date_hk
        ,b.uuid
        ,count(case when b.event_date_hk = a.date and (is_current_trial = 1 or is_current_pay = 1) then 1 end) sub_status_now
        ,count(case when b.event_date_hk = a.date and is_current_pay = 1 then 1 end) sub_pay_status_now
        ,count(case when b.event_date_hk = a.date and is_current_trial = 1 then 1 end) trial_status_now
        ,max(case when b.event_date_hk = a.date then past_sub_times end) past_sub_times
        ,max(case when b.event_date_hk = a.date then past_trial_times end) past_trial_times
        ,count(case when is_current_trial = 1 or is_current_pay = 1 then 1 end) sub_status_pre_90
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join
    (
        select uuid,event_date_hk,current_sub_sku_type
            ,if(current_trial_day is not null,1,0) is_current_trial
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times past_trial_times
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
         where event_date_hk between DATE_SUB(mDATE_START, INTERVAL 89 DAY) and mDATE_END and app_id in ('BeautyPlus')
    ) b
    where b.event_date_hk between DATE_SUB(a.date, INTERVAL 89 DAY) and a.date
    group by 1,2
)
,
future_sub_pay as
(
    select a.date event_date_hk
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) future_sub_7
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) and order_status in (1,2) then 1 end) future_sub_pay_7
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between mDATE_START and mDATE_END
    ) a
    cross join sub_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY)
    group by 1,2
)

select a.event_date,a.user_pseudo_id,b.uuid,a.platform
        ,a.active_days_90d,a.install_days
        ,d7.*except(event_date_hk,user_pseudo_id)
        ,d1.*except(event_date,user_pseudo_id)
        ,coalesce(c.sub_status_now,0) sub_status_now
        ,coalesce(c.sub_pay_status_now,0) sub_pay_status_now
        ,coalesce(c.trial_status_now,0) trial_status_now
        ,coalesce(c.past_sub_times,0) past_sub_times
        ,coalesce(c.past_trial_times,0) past_trial_times
        ,coalesce(c.sub_status_pre_90,0) sub_status_pre_90
        ,coalesce(e.future_sub_7,0) future_sub_7
        ,coalesce(e.future_sub_pay_7,0) future_sub_pay_7
from users a
left join (select key,uuid from `dataintegration-265403.stat.dmi_dz_idmapping`) b
on a.user_pseudo_id=b.key
left join sub_his_now c
on b.uuid=c.uuid and a.event_date=c.event_date_hk
left join functions_7 d7
on a.user_pseudo_id=d7.user_pseudo_id and a.event_date=d7.event_date_hk
left join functions_1 d1
on a.user_pseudo_id=d1.user_pseudo_id and a.event_date=d1.event_date
left join future_sub_pay e
on b.uuid=e.uuid and a.event_date=e.event_date_hk





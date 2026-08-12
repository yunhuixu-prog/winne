DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-01-01');
-- DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-06-30');

drop table if exists beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave_pre;
create table beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave_pre as

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
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave as

delete from beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave where event_date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave

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
            beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave_pre
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
    from beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave_pre
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
    from beautyplus-bc0ed.temp.dws_dz_dau_split_user_core_behave_pre
    where is_function = '功能'
      and mark=2
      and action in ('点击', '保存', '拍摄')
      and event_date between mDATE_START and mDATE_END
    group by 1,2
)
,
pay_duffle as
(
    select date_p event_date,user_pseudo_id
            , sum (case when paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv
            , sum (case when paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv
            , sum (case when paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv
    from beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
    where date_p between mDATE_START and mDATE_END
    group by 1,2
)
,
home_content as
(
    select event_date,user_pseudo_id
            ,sum(case when event_name='homepageappr_bd' then pv end) homepage_exposure_pv
            ,sum(case when event_name in ('home_content_clk_bd') then pv end) homepage_click_pv
            ,sum(case when module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv
            ,sum(case when module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv
            ,sum(case when module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv
            ,sum(case when module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv
            ,sum(case when module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv
            ,sum(case when module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv
            ,sum(case when module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv
            ,sum(case when module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv
            ,sum(case when module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv
            ,sum(case when module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv
    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between mDATE_START and mDATE_END
        and event_name in ('homepageappr_bd','home_content_clk_bd','home_content_show_f_bd')
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
        , sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv
        , sum(homepage_exposure_pv) homepage_exposure_pv, sum(homepage_click_pv) homepage_click_pv, sum(homepage_feature_show_pv) homepage_feature_show_pv, sum(homepage_feature_click_pv) homepage_feature_click_pv, sum(homepage_banner_show_pv) homepage_banner_show_pv, sum(homepage_banner_click_pv) homepage_banner_click_pv, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv, sum(homepage_topic_show_pv) homepage_topic_show_pv, sum(homepage_topic_click_pv) homepage_topic_click_pv, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv

    from
    (
        select event_date,user_pseudo_id
            ,puzzle_click_pv,puzzle_save_pv
            ,0 pay_function_click_pv,0 free_function_click_pv,0 free_function_save_pv
            ,0 pay_duffle_click_pv,0 free_duffle_click_pv,0 free_duffle_save_pv
            ,0 homepage_exposure_pv,0 homepage_click_pv,0 homepage_feature_show_pv,0 homepage_feature_click_pv,0 homepage_banner_show_pv,0 homepage_banner_click_pv,0 homepage_reconmend_show_pv,0 homepage_reconmend_click_pv,0 homepage_topic_show_pv,0 homepage_topic_click_pv,0 homepage_miniapp_show_pv,0 homepage_miniapp_click_pv
        from puzzle

        union all

        select event_date,user_pseudo_id
            ,0 puzzle_click_pv,0 puzzle_save_pv
            ,pay_function_click_pv,free_function_click_pv,free_function_save_pv
            ,0 pay_duffle_click_pv,0 free_duffle_click_pv,0 free_duffle_save_pv
            ,0 homepage_exposure_pv,0 homepage_click_pv,0 homepage_feature_show_pv,0 homepage_feature_click_pv,0 homepage_banner_show_pv,0 homepage_banner_click_pv,0 homepage_reconmend_show_pv,0 homepage_reconmend_click_pv,0 homepage_topic_show_pv,0 homepage_topic_click_pv,0 homepage_miniapp_show_pv,0 homepage_miniapp_click_pv
        from pay_function

        union all

        select event_date,user_pseudo_id
            ,0 puzzle_click_pv,0 puzzle_save_pv
            ,0 pay_function_click_pv,0 free_function_click_pv,0 free_function_save_pv
            ,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
            ,0 homepage_exposure_pv,0 homepage_click_pv,0 homepage_feature_show_pv,0 homepage_feature_click_pv,0 homepage_banner_show_pv,0 homepage_banner_click_pv,0 homepage_reconmend_show_pv,0 homepage_reconmend_click_pv,0 homepage_topic_show_pv,0 homepage_topic_click_pv,0 homepage_miniapp_show_pv,0 homepage_miniapp_click_pv
        from pay_duffle

        union all

        select event_date,user_pseudo_id
             ,0 puzzle_click_pv,0 puzzle_save_pv
             ,0 pay_function_click_pv,0 free_function_click_pv,0 free_function_save_pv
             ,0 pay_duffle_click_pv,0 free_duffle_click_pv,0 free_duffle_save_pv
             ,homepage_exposure_pv,homepage_click_pv,homepage_feature_show_pv,homepage_feature_click_pv,homepage_banner_show_pv,homepage_banner_click_pv,homepage_reconmend_show_pv,homepage_reconmend_click_pv,homepage_topic_show_pv,homepage_topic_click_pv,homepage_miniapp_show_pv,homepage_miniapp_click_pv
        from home_content
    )
    group by 1,2
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id


-- 人数分布
select
--      event_date,
     platform
     ,case
        when install_days<=90 then 'new'
        when active_days_90d<=10 then 'no_active'
        when sub_status_pre_90=0 and active_days_90d>10 then 'active_no_sub'
        when sub_status_pre_90>0 and active_days_90d>10 then 'active_past_sub'
     end types
     ,count(user_pseudo_id) uv
     ,round(avg(coalesce(pv_tab0_edit_entry,0)),2) pv_tab0_edit_entry
     ,round(avg(coalesce(pv_tab0_selfie_entry,0)),2) pv_tab0_selfie_entry
     ,round(avg(coalesce(pv_tab0_videoedit_entry,0)),2) pv_tab0_videoedit_entry
     ,round(avg(coalesce(pv_tab0_edit_save,0)),2) pv_tab0_edit_save
     ,round(avg(coalesce(pv_tab0_shoot_save,0)),2) pv_tab0_shoot_save
--      ,round(avg(coalesce(pv_tab0_movie_save,0)),2) pv_tab0_movie_save
--      ,round(avg(coalesce(pv_tab0_video_save,0)),2) pv_tab0_video_save
     ,round(avg(coalesce(pv_tab0_videoedit_save,0)),2) pv_tab0_videoedit_save

     ,round(avg(coalesce(pv_tab1_edit_beauty_click,0)),2) pv_tab1_edit_beauty_click
     ,round(avg(coalesce(pv_tab1_edit_creative_click,0)),2) pv_tab1_edit_creative_click
     ,round(avg(coalesce(pv_tab1_edit_edit_click,0)),2) pv_tab1_edit_edit_click
     ,round(avg(coalesce(pv_tab1_edit_filter_click,0)),2) pv_tab1_edit_filter_click
     ,round(avg(coalesce(pv_tab1_edit_makeup_click,0)),2) pv_tab1_edit_makeup_click
     ,round(avg(coalesce(pv_tab1_edit_senioredit_click,0)),2) pv_tab1_edit_senioredit_click
     ,round(avg(coalesce(pv_tab1_edit_beauty_save,0)),2) pv_tab1_edit_beauty_save
     ,round(avg(coalesce(pv_tab1_edit_creative_save,0)),2) pv_tab1_edit_creative_save
     ,round(avg(coalesce(pv_tab1_edit_edit_save,0)),2) pv_tab1_edit_edit_save
     ,round(avg(coalesce(pv_tab1_edit_filter_save,0)),2) pv_tab1_edit_filter_save
     ,round(avg(coalesce(pv_tab1_edit_makeup_save,0)),2) pv_tab1_edit_makeup_save

     ,round(avg(coalesce(pv_tab1_shoot_ar_shoot,0)),2) pv_tab1_shoot_ar_shoot
     ,round(avg(coalesce(pv_tab1_shoot_filter_shoot,0)),2) pv_tab1_shoot_filter_shoot
     ,round(avg(coalesce(pv_tab1_shoot_look_shoot,0)),2) pv_tab1_shoot_look_shoot
     ,round(avg(coalesce(pv_tab1_shoot_makeup_shoot,0)),2) pv_tab1_shoot_makeup_shoot
     ,round(avg(coalesce(pv_tab1_shoot_ar_save,0)),2) pv_tab1_shoot_ar_save
     ,round(avg(coalesce(pv_tab1_shoot_beauty_save,0)),2) pv_tab1_shoot_beauty_save
     ,round(avg(coalesce(pv_tab1_shoot_filter_save,0)),2) pv_tab1_shoot_filter_save
     ,round(avg(coalesce(pv_tab1_shoot_look_save,0)),2) pv_tab1_shoot_look_save
     ,round(avg(coalesce(pv_tab1_shoot_makeup_save,0)),2) pv_tab1_shoot_makeup_save
-- from beautyplus-bc0ed.temp.function_analysis_winne_data_final
from beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final
where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
group by 1,2
order by 1,2


-- 一级功能使用情况
select
--      event_date,
     platform
    ,case
        when install_days<=90 then 'new'
        when active_days_90d<=10 then 'no_active'
        when sub_status_pre_90=0 and active_days_90d>10 then 'active_no_sub'
        when sub_status_pre_90>0 and active_days_90d>10 then 'active_past_sub'
     end types
    ,CONCAT(
        CASE WHEN pv_tab0_edit_entry > 0 THEN 'edit,' ELSE '' END,
        CASE WHEN pv_tab0_selfie_entry > 0 THEN 'selfie,' ELSE '' END,
        CASE WHEN pv_tab0_videoedit_entry > 0 THEN 'videoedit,' ELSE '' END
      ) AS tab0_entry
    ,CONCAT(
        CASE WHEN pv_tab1_edit_beauty_click > 0 THEN 'beauty,' ELSE '' END,
        CASE WHEN pv_tab1_edit_creative_click > 0 THEN 'creative,' ELSE '' END,
        CASE WHEN pv_tab1_edit_edit_click > 0 THEN 'edit,' ELSE '' END,
        CASE WHEN pv_tab1_edit_filter_click > 0 THEN 'filter,' ELSE '' END,
        CASE WHEN pv_tab1_edit_makeup_click > 0 THEN 'makeup,' ELSE '' END,
        CASE WHEN pv_tab1_edit_senioredit_click > 0 THEN 'senioredit,' ELSE '' END
      ) AS tab1_edit_click
     ,CONCAT(
        CASE WHEN pv_tab1_shoot_ar_save > 0 THEN 'ar,' ELSE '' END,
        CASE WHEN pv_tab1_shoot_beauty_save > 0 THEN 'beauty,' ELSE '' END,
        CASE WHEN pv_tab1_shoot_filter_save > 0 THEN 'filter,' ELSE '' END,
        CASE WHEN pv_tab1_shoot_look_save > 0 THEN 'look,' ELSE '' END,
        CASE WHEN pv_tab1_shoot_makeup_save > 0 THEN 'makeup,' ELSE '' END
      ) AS tab1_shoot_save
    ,count(user_pseudo_id) uv
-- from beautyplus-bc0ed.temp.function_analysis_winne_data_final
from beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final
where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
--     and install_days>90 and active_days_90d>10
group by 1,2,3,4,5


-- 修图使用情况
select platform,types,function_num
     ,case when ranks<=100 then tab2_edit_click
            else 'others'
     end tab2_edit_click
     ,sum(uv) uv
from
(select platform,types,tab2_edit_click,ARRAY_LENGTH(split(tab2_edit_click,','))-1 function_num,uv
     ,rank() over(partition by platform,types order by uv desc) ranks
from
(
    select
    --      event_date,
         platform
        ,case
            when install_days<=90 then 'new'
            when active_days_90d<=10 then 'no_active'
            when sub_status_pre_90=0 and active_days_90d>10 then 'active_no_sub'
            when sub_status_pre_90>0 and active_days_90d>10 then 'active_past_sub'
         end types
         ,CONCAT(
            CASE WHEN pv_tab2_edit_beauty_AIbeauty_click > 0 THEN 'beauty&AIbeauty,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_Threedimensionalface_click > 0 THEN 'beauty&Threedimensionalface,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_detail_click > 0 THEN 'beauty&detail,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_doublechin_click > 0 THEN 'beauty&doublechin,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_evenskin_click > 0 THEN 'beauty&evenskin,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_expression_click > 0 THEN 'beauty&expression,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_eyecatching_click > 0 THEN 'beauty&eyecatching,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_eyedilated_click > 0 THEN 'beauty&eyedilated,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_facecolor_click > 0 THEN 'beauty&facecolor,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_faceslimming_click > 0 THEN 'beauty&faceslimming,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_faciallighting_click > 0 THEN 'beauty&faciallighting,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_facialreshaping_click > 0 THEN 'beauty&facialreshaping,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_hairdressing_click > 0 THEN 'beauty&hairdressing,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_lightendarkcircle_click > 0 THEN 'beauty&lightendarkcircle,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_microdermabrasion_click > 0 THEN 'beauty&microdermabrasion,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_narrownose_click > 0 THEN 'beauty&narrownose,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_oneclickbeauty_click > 0 THEN 'beauty&oneclickbeauty,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_orthodontics_click > 0 THEN 'beauty&orthodontics,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_removieacne_click > 0 THEN 'beauty&removieacne,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_removieshine_click > 0 THEN 'beauty&removieshine,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_removiewrinkles_click > 0 THEN 'beauty&removiewrinkles,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_shape_click > 0 THEN 'beauty&shape,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_shrinkhead_click > 0 THEN 'beauty&shrinkhead,' ELSE '' END,
            CASE WHEN pv_tab2_edit_beauty_teethwhitening_click > 0 THEN 'beauty&teethwhitening,' ELSE '' END,
            CASE WHEN pv_tab2_edit_creative_background_click > 0 THEN 'creative&background,' ELSE '' END,
--             CASE WHEN pv_tab2_edit_creative_formula_click > 0 THEN 'creative&formula,' ELSE '' END,
            CASE WHEN pv_tab2_edit_creative_graffiti_click > 0 THEN 'creative&graffiti,' ELSE '' END,
            CASE WHEN pv_tab2_edit_creative_sticker_click > 0 THEN 'creative&sticker,' ELSE '' END,
            CASE WHEN pv_tab2_edit_creative_text_click > 0 THEN 'creative&text,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_AIenhance_click > 0 THEN 'edit&AIenhance,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_AIextension_click > 0 THEN 'edit&AIextension,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_ar_click > 0 THEN 'edit&ar,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_blur_click > 0 THEN 'edit&blur,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_clone_click > 0 THEN 'edit&clone,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_composition_click > 0 THEN 'edit&composition,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_cutout_click > 0 THEN 'edit&cutout,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_dispersion_click > 0 THEN 'edit&dispersion,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_elimination_click > 0 THEN 'edit&elimination,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_mosaic_click > 0 THEN 'edit&mosaic,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_photorepair_click > 0 THEN 'edit&photorepair,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_stylization_click > 0 THEN 'edit&stylization,' ELSE '' END,
            CASE WHEN pv_tab2_edit_edit_adjustment_click > 0 THEN 'edit&adjustment,' ELSE '' END,
            CASE WHEN pv_tab1_edit_filter_click > 0 THEN 'filter,' ELSE '' END,
            CASE WHEN pv_tab1_edit_makeup_click > 0 THEN 'makeup,' ELSE '' END,
            CASE WHEN pv_tab1_edit_senioredit_click > 0 THEN 'senioredit,' ELSE '' END
          ) AS tab2_edit_click
        ,count(user_pseudo_id) uv
    -- from beautyplus-bc0ed.temp.function_analysis_winne_data_final
    from beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final
    where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
--         and install_days>90 and active_days_90d>10
    group by 1,2,3
))
group by 1,2,3,4







-- 拍照使用情况
select platform,types
     ,case when ranks<=1000 then tab2_shoot_save
            else 'others'
     end tab2_shoot_save
     ,sum(uv) uv
from
(select platform,types,tab2_shoot_save,uv
     ,rank() over(partition by platform,types order by uv desc) ranks
from
(
    select
    --      event_date,
         platform
        ,case
            when install_days<=90 then 'new'
            when active_days_90d<=10 then 'no_active'
            when sub_status_pre_90=0 and active_days_90d>10 then 'active_no_sub'
            when sub_status_pre_90>0 and active_days_90d>10 then 'active_past_sub'
         end types
         ,CONCAT(
            CASE WHEN pv_tab2_shoot_beauty_bigeyes_save > 0 THEN 'beauty&bigeyes,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_eyecatching_save > 0 THEN 'beauty&eyecatching,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_facecolor_save > 0 THEN 'beauty&facecolor,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_faceslimming_save > 0 THEN 'beauty&faceslimming,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_microdermabrasion_save > 0 THEN 'beauty&microdermabrasion,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_oneclickbody_save > 0 THEN 'beauty&oneclickbody,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_removieacnefreckles_save > 0 THEN 'beauty&removieacnefreckles,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_removiedarkcircles_save > 0 THEN 'beauty&removiedarkcircles,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_removienasolabial_save > 0 THEN 'beauty&removienasolabial,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_shrinkhead_save > 0 THEN 'beauty&shrinkhead,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_softhair_save > 0 THEN 'beauty&softhair,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_teethwhitening_save > 0 THEN 'beauty&teethwhitening,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_beauty_thinnose_save > 0 THEN 'beauty&thinnose,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_blush_save > 0 THEN 'makeup&blush,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_contactlenses_save > 0 THEN 'makeup&contactlenses,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_dyehair_save > 0 THEN 'makeup&dyehair,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_eyebrow_save > 0 THEN 'makeup&eyebrow,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_eyelash_save > 0 THEN 'makeup&eyelash,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_eyeshadow_save > 0 THEN 'makeup&eyeshadow,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_freckle_save > 0 THEN 'makeup&freckle,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_lipstick_save > 0 THEN 'makeup&lipstick,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_lyingsilkworm_save > 0 THEN 'makeup&lyingsilkworm,' ELSE '' END,
            CASE WHEN pv_tab2_shoot_makeup_trimming_save > 0 THEN 'makeup&trimming,' ELSE '' END,
            CASE WHEN pv_tab1_shoot_ar_save > 0 THEN 'ar,' ELSE '' END,
            CASE WHEN pv_tab1_shoot_filter_save > 0 THEN 'filter,' ELSE '' END,
            CASE WHEN pv_tab1_shoot_look_save > 0 THEN 'look,' ELSE '' END
          ) AS tab2_shoot_save
        ,count(user_pseudo_id) uv
    -- from beautyplus-bc0ed.temp.function_analysis_winne_data_final
    from beautyplus-bc0ed.temp.function_7day_analysis_winne_data_final
    where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
--         and install_days>90 and active_days_90d>10
    group by 1,2,3
))
group by 1,2,3




pv_tab0_edit_entry	 pv_tab0_selfie_entry   pv_tab0_videoedit_entry
pv_tab0_movie_shoot   pv_tab0_shoot_shoot   pv_tab0_video_shoot
pv_tab0_edit_save	pv_tab0_movie_save   pv_tab0_shoot_save	  pv_tab0_video_save	pv_tab0_videoedit_save

pv_tab1_edit_beauty_click	pv_tab1_edit_creative_click   pv_tab1_edit_edit_click   pv_tab1_edit_filter_click   pv_tab1_edit_makeup_click   pv_tab1_edit_senioredit_click
pv_tab1_edit_beauty_save	pv_tab1_edit_creative_save   pv_tab1_edit_edit_save   pv_tab1_edit_filter_save   pv_tab1_edit_makeup_save

pv_tab1_shoot_ar_shoot   pv_tab1_shoot_filter_shoot  pv_tab1_shoot_look_shoot   pv_tab1_shoot_makeup_shoot
pv_tab1_shoot_ar_save	pv_tab1_shoot_beauty_save	pv_tab1_shoot_filter_save	pv_tab1_shoot_look_save	 pv_tab1_shoot_makeup_save

pv_tab2_edit_beauty_AIbeauty_click	pv_tab2_edit_beauty_Threedimensionalface_click	pv_tab2_edit_beauty_detail_click   pv_tab2_edit_beauty_doublechin_click   pv_tab2_edit_beauty_evenskin_click   pv_tab2_edit_beauty_expression_click	   pv_tab2_edit_beauty_eyecatching_click   pv_tab2_edit_beauty_eyedilated_click	  pv_tab2_edit_beauty_facecolor_click	pv_tab2_edit_beauty_faceslimming_click	 pv_tab2_edit_beauty_faciallighting_click	pv_tab2_edit_beauty_facialreshaping_click	pv_tab2_edit_beauty_hairdressing_click	pv_tab2_edit_beauty_lightendarkcircle_click   pv_tab2_edit_beauty_microdermabrasion_click	pv_tab2_edit_beauty_narrownose_click   pv_tab2_edit_beauty_oneclickbeauty_click	   pv_tab2_edit_beauty_orthodontics_click	pv_tab2_edit_beauty_removieacne_click	pv_tab2_edit_beauty_removieshine_click	 pv_tab2_edit_beauty_removiewrinkles_click	pv_tab2_edit_beauty_shape_click	  pv_tab2_edit_beauty_shrinkhead_click	 pv_tab2_edit_beauty_teethwhitening_click
pv_tab2_edit_beauty_AIbeauty_save   pv_tab2_edit_beauty_Threedimensionalface_save   pv_tab2_edit_beauty_detail_save    pv_tab2_edit_beauty_doublechin_save    pv_tab2_edit_beauty_evenskin_save    pv_tab2_edit_beauty_expression_save     pv_tab2_edit_beauty_eyecatching_save    pv_tab2_edit_beauty_eyedilated_save    pv_tab2_edit_beauty_facecolor_save    pv_tab2_edit_beauty_faceslimming_save    pv_tab2_edit_beauty_faciallighting_save    pv_tab2_edit_beauty_facialreshaping_save    pv_tab2_edit_beauty_hairdressing_save   pv_tab2_edit_beauty_lightendarkcircle_save    pv_tab2_edit_beauty_microdermabrasion_save    pv_tab2_edit_beauty_narrownose_save    pv_tab2_edit_beauty_oneclickbeauty_save     pv_tab2_edit_beauty_orthodontics_save    pv_tab2_edit_beauty_removieacne_save    pv_tab2_edit_beauty_removieshine_save    pv_tab2_edit_beauty_removiewrinkles_save   pv_tab2_edit_beauty_shape_save    pv_tab2_edit_beauty_shrinkhead_save    pv_tab2_edit_beauty_teethwhitening_save

pv_tab2_edit_creative_background_click	pv_tab2_edit_creative_formula_click	  pv_tab2_edit_creative_graffiti_click	 pv_tab2_edit_creative_sticker_click	pv_tab2_edit_creative_text_click	pv_tab2_edit_edit_AIenhance_click	pv_tab2_edit_edit_AIextension_click    pv_tab2_edit_edit_ar_click	pv_tab2_edit_edit_blur_click	pv_tab2_edit_edit_clone_click	pv_tab2_edit_edit_composition_click	  pv_tab2_edit_edit_cutout_click	pv_tab2_edit_edit_dispersion_click	pv_tab2_edit_edit_elimination_click   pv_tab2_edit_edit_mosaic_click	pv_tab2_edit_edit_photorepair_click   pv_tab2_edit_edit_stylization_click   pv_tab2_edit_edit_adjustment_click
pv_tab2_edit_creative_background_save   pv_tab2_edit_creative_formula_save    pv_tab2_edit_creative_graffiti_save    pv_tab2_edit_creative_sticker_save     pv_tab2_edit_creative_text_save     pv_tab2_edit_edit_AIenhance_save    pv_tab2_edit_edit_AIextension_save     pv_tab2_edit_edit_ar_save   pv_tab2_edit_edit_blur_save     pv_tab2_edit_edit_clone_save    pv_tab2_edit_edit_composition_save    pv_tab2_edit_edit_cutout_save     pv_tab2_edit_edit_dispersion_save   pv_tab2_edit_edit_elimination_save    pv_tab2_edit_edit_mosaic_save     pv_tab2_edit_edit_photorepair_save    pv_tab2_edit_edit_stylization_save

pv_tab2_shoot_beauty_bigeyes_save	pv_tab2_shoot_beauty_eyecatching_save	pv_tab2_shoot_beauty_facecolor_save	  pv_tab2_shoot_beauty_faceslimming_save	pv_tab2_shoot_beauty_microdermabrasion_save	 pv_tab2_shoot_beauty_oneclickbody_save	  pv_tab2_shoot_beauty_removieacnefreckles_save	  pv_tab2_shoot_beauty_removiedarkcircles_save	 pv_tab2_shoot_beauty_removienasolabial_save	pv_tab2_shoot_beauty_shrinkhead_save	pv_tab2_shoot_beauty_softhair_save	pv_tab2_shoot_beauty_teethwhitening_save	pv_tab2_shoot_beauty_thinnose_save

pv_tab2_shoot_makeup_blush_shoot   pv_tab2_shoot_makeup_contactlenses_shoot   pv_tab2_shoot_makeup_dyehair_shoot    pv_tab2_shoot_makeup_eyebrow_shoot   pv_tab2_shoot_makeup_eyelash_shoot    pv_tab2_shoot_makeup_eyeshadow_shoot   pv_tab2_shoot_makeup_freckle_shoot   pv_tab2_shoot_makeup_lipstick_shoot   pv_tab2_shoot_makeup_lyingsilkworm_shoot   pv_tab2_shoot_makeup_trimming_shoot
pv_tab2_shoot_makeup_blush_save	   pv_tab2_shoot_makeup_contactlenses_save	  pv_tab2_shoot_makeup_dyehair_save		pv_tab2_shoot_makeup_eyebrow_save	 pv_tab2_shoot_makeup_eyelash_save	   pv_tab2_shoot_makeup_eyeshadow_save	  pv_tab2_shoot_makeup_freckle_save    pv_tab2_shoot_makeup_lipstick_save	 pv_tab2_shoot_makeup_lyingsilkworm_save	pv_tab2_shoot_makeup_trimming_save



-- 模型特征分析-数据集
drop table if exists beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_local;
create table beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_local as

select *except(event_date,user_pseudo_id,uuid)
from beautyplus-bc0ed.temp.function_analysis_winne_data_final
where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
    and rand()<least(200000/706732,1)
    and future_sub_7>0

union all

select *except(event_date,user_pseudo_id,uuid)
from beautyplus-bc0ed.temp.function_analysis_winne_data_final
where sub_status_now=0 and event_date between '2024-11-01' and '2024-11-30'
    and rand()<least(200000/198820474,1)
    and future_sub_7=0


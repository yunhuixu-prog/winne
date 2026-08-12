-- -- 初始化
-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists airbrush-1324.temp.dws_dz_his_split_user_behave;
-- create table airbrush-1324.temp.dws_dz_his_split_user_behave as

-- 非初始化
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
-- DECLARE mDATE_START DATE DEFAULT '2023-01-01';
-- DECLARE mDATE_END DATE DEFAULT '2023-05-20';
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from airbrush-1324.temp.dws_dz_his_split_user_behave where date = mDATE;
insert into airbrush-1324.temp.dws_dz_his_split_user_behave


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
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user` t1
    left join (select mobile_brand_name,mobile_model_name,max(phone_price) phone_price from `dataintegration-265403.view.dim_ya_common_model_phone_price` group by 1,2) t2
    on t1.model=t2.mobile_model_name and t1.brand=t2.mobile_brand_name
    where event_date_hk=mDATE and last_active_date>='2022-01-01'  -- ab有太多22年之前现在还活跃的用户了
)
,
behave_pre as
(
        select event_date,a.event_name,a.first,a.second
        , a.user_pseudo_id
        , a.pv
        , b.paid_type
        from
        (select event_date,event_name,first,second
        , user_pseudo_id
        , pv
        from  `airbrush-1324.stat.dws_airbrush_act_info_uid`
         union all
        select  date1 event_date,event_name,function first,'all' second
        , user_pseudo_id
        , pv
        FROM `airbrush-1324.user_behavior.dwd_video_edit_behavior_d`
        where event_name in('func_video_enter','func_video_use','video_save')) a
        left join (SELECT string_field_0 first, string_field_1 second,string_field_2 paid_type
        FROM `airbrush-1324.temp.func_paid_type`) b
        on a.first=b.first and a.second=b.second
        where event_date between date_sub(mDATE,interval 89 day) and mDATE
)
,
-- 近7天用户核心行为
core_behave as
(
    SELECT * FROM
(
SELECT user_pseudo_id, concat(event_name,'-',first,'-',second) activity,sum(pv) pv
FROM  behave_pre
where event_date  between date_sub(mDATE, interval 6 day) and mDATE
group by 1,2
)
PIVOT
(
sum(pv) AS pv
FOR activity in (
"camera_enter-all-all","camera_save-Filter-all","camera_save-all-all","camera_taken-Filter-all","camera_taken-all-all","edit_enter-AI Style-all","edit_enter-Creative-all","edit_enter-Filter-all","edit_enter-Hair-all","edit_enter-Makeup-all","edit_enter-Mykit-all","edit_enter-Presets-all","edit_enter-Retouch-all","edit_enter-Tools-all","edit_enter-all-all","edit_save-AI Style-all","edit_save-Creative-all","edit_save-Filter-all","edit_save-Hair-all","edit_save-Makeup-all","edit_save-Presets-all","edit_save-Retouch-all","edit_save-Tools-all","edit_save-all-all","edit_save-其他-all","edit_use-AI Style-all","edit_use-Creative-all","edit_use-Filter-all","edit_use-Hair-all","edit_use-Makeup-all","edit_use-Presets-all","edit_use-Retouch-all","edit_use-Tools-all",
"func_video_enter-reshape", "func_video_use-foundation", "func_video_enter-firm", "func_video_enter-acne", "func_video_use-sculpt", "func_video_enter-clarity", "func_video_use-brighten", "func_video_use-reshape", "func_video_use-matte", "func_video_enter-dark_circle", "func_video_enter-stretch", "video_magic_status-open", "video_save-skin_tone", "func_video_enter-smooth", "func_video_enter-sculpt", "video_save-whiten", "func_video_use-clarity", "video_save-acne", "video_save-reshape", "video_save-contouring", "video_save-brighten", "func_video_enter-makeup", "func_video_use-makeup", "func_video_enter-foundation", "video_save-stretch", "video_save-overview", "video_start_edit-overview", "func_video_enter-matte", "func_video_use-firm", "func_video_use-whiten", "video_save-matte", "video_save-foundation", "func_video_enter-whiten", "func_video_enter-brighten", "func_video_use-stretch", "video_save-firm", "video_save-dark_circle", "func_video_use-smooth", "video_magic_status-close", "func_video_use-skin_tone", "video_save-sculpt", "func_video_use-dark_circle", "func_video_use-acne", "video_save-smooth", "func_video_use-contouring", "video_save-clarity", "func_video_enter-contouring", "func_video_enter-skin_tone", "video_save-makeup"
,"edit_enter-Creative-Background", "edit_enter-Creative-Colors", "edit_enter-Creative-Glitter", "edit_enter-Creative-Sparkle", "edit_enter-Creative-Text", "edit_enter-Hair-Bangs", "edit_enter-Hair-HairDye", "edit_enter-Hair-Hairline", "edit_enter-Hair-Hairstyles", "edit_enter-Makeup-Blush", "edit_enter-Makeup-BuildLooks", "edit_enter-Makeup-Contour", "edit_enter-Makeup-Eyebrows", "edit_enter-Makeup-Eyecolor", "edit_enter-Makeup-Eyelashes", "edit_enter-Makeup-Eyeliner", "edit_enter-Makeup-Eyeshadow", "edit_enter-Makeup-Lips", "edit_enter-Makeup-Sets", "edit_enter-Mykit-AI Retouch", "edit_enter-Mykit-Acne", "edit_enter-Mykit-Adjust", "edit_enter-Mykit-Align", "edit_enter-Mykit-Background", "edit_enter-Mykit-Bangs", "edit_enter-Mykit-Blur", "edit_enter-Mykit-Bokeh", "edit_enter-Mykit-Brighten", "edit_enter-Mykit-Colors", "edit_enter-Mykit-Contour", "edit_enter-Mykit-DarkCircles", "edit_enter-Mykit-Details", "edit_enter-Mykit-Enhance", "edit_enter-Mykit-Eraser", "edit_enter-Mykit-Filter", "edit_enter-Mykit-Firm", "edit_enter-Mykit-Foundation", "edit_enter-Mykit-Glitter", "edit_enter-Mykit-HairDye", "edit_enter-Mykit-Hairline", "edit_enter-Mykit-Hairstyles", "edit_enter-Mykit-Highlighter", "edit_enter-Mykit-Iris", "edit_enter-Mykit-Magic", "edit_enter-Mykit-Makeup", "edit_enter-Mykit-Matte", "edit_enter-Mykit-Presets", "edit_enter-Mykit-Prism", "edit_enter-Mykit-Relight", "edit_enter-Mykit-Reshape", "edit_enter-Mykit-Resize", "edit_enter-Mykit-Sculpt", "edit_enter-Mykit-SkinTone", "edit_enter-Mykit-Smooth", "edit_enter-Mykit-Stamp", "edit_enter-Mykit-Stretch", "edit_enter-Mykit-Text", "edit_enter-Mykit-Texture", "edit_enter-Mykit-Vignette", "edit_enter-Mykit-Whiten", "edit_enter-Retouch-AI Retouch", "edit_enter-Retouch-Acne", "edit_enter-Retouch-Align", "edit_enter-Retouch-Brighten", "edit_enter-Retouch-Contour", "edit_enter-Retouch-DarkCircles", "edit_enter-Retouch-Details", "edit_enter-Retouch-Firm", "edit_enter-Retouch-Foundation", "edit_enter-Retouch-Highlighter", "edit_enter-Retouch-Iris", "edit_enter-Retouch-Magic", "edit_enter-Retouch-Matte", "edit_enter-Retouch-Reshape", "edit_enter-Retouch-Resize", "edit_enter-Retouch-Sculpt", "edit_enter-Retouch-SkinTone", "edit_enter-Retouch-Smooth", "edit_enter-Retouch-Texture", "edit_enter-Retouch-Whiten", "edit_enter-Tools-AI Replace", "edit_enter-Tools-Adjust", "edit_enter-Tools-Blur", "edit_enter-Tools-Bokeh", "edit_enter-Tools-Enhance", "edit_enter-Tools-Eraser", "edit_enter-Tools-Prism", "edit_enter-Tools-Relight", "edit_enter-Tools-Stamp", "edit_enter-Tools-Stretch", "edit_enter-Tools-Vignette", "edit_save-Creative-Background", "edit_save-Creative-Colors", "edit_save-Creative-Glitter", "edit_save-Creative-Sparkle", "edit_save-Creative-Text", "edit_save-Hair-Bangs", "edit_save-Hair-HairDye", "edit_save-Hair-Hairline", "edit_save-Hair-Hairstyles", "edit_save-Makeup-Blush", "edit_save-Makeup-Contour", "edit_save-Makeup-Eyebrows", "edit_save-Makeup-Eyecolor", "edit_save-Makeup-Eyelashes", "edit_save-Makeup-Eyeliner","edit_save-Makeup-Eyeshadow", "edit_save-Makeup-Lips", "edit_save-Makeup-Sets", "edit_save-Retouch-AI Retouch", "edit_save-Retouch-Acne", "edit_save-Retouch-Align", "edit_save-Retouch-Brighten", "edit_save-Retouch-Contour", "edit_save-Retouch-DarkCircles", "edit_save-Retouch-Details", "edit_save-Retouch-Firm", "edit_save-Retouch-Foundation", "edit_save-Retouch-Highlighter", "edit_save-Retouch-Iris", "edit_save-Retouch-Magic", "edit_save-Retouch-Matte", "edit_save-Retouch-Reshape", "edit_save-Retouch-Resize", "edit_save-Retouch-Sculpt", "edit_save-Retouch-SkinTone", "edit_save-Retouch-Smooth", "edit_save-Retouch-Texture", "edit_save-Retouch-Whiten", "edit_save-Tools-AI Replace", "edit_save-Tools-Adjust", "edit_save-Tools-Blur", "edit_save-Tools-Bokeh", "edit_save-Tools-Enhance", "edit_save-Tools-Eraser", "edit_save-Tools-Prism", "edit_save-Tools-Relight", "edit_save-Tools-Stamp", "edit_save-Tools-Stretch", "edit_save-Tools-Vignette", "edit_use-Creative-Background", "edit_use-Creative-Colors", "edit_use-Creative-Glitter", "edit_use-Creative-Sparkle", "edit_use-Creative-Text", "edit_use-Hair-Bangs", "edit_use-Hair-HairDye", "edit_use-Hair-Hairline", "edit_use-Hair-Hairstyles", "edit_use-Makeup-Blush", "edit_use-Makeup-BuildLooks", "edit_use-Makeup-Contour", "edit_use-Makeup-Eyebrows", "edit_use-Makeup-Eyecolor", "edit_use-Makeup-Eyelashes", "edit_use-Makeup-Eyeliner", "edit_use-Makeup-Eyeshadow", "edit_use-Makeup-Lips", "edit_use-Makeup-Sets", "edit_use-Retouch-AI Retouch", "edit_use-Retouch-Acne", "edit_use-Retouch-Align", "edit_use-Retouch-Brighten", "edit_use-Retouch-Contour", "edit_use-Retouch-DarkCircles", "edit_use-Retouch-Details", "edit_use-Retouch-Firm", "edit_use-Retouch-Foundation", "edit_use-Retouch-Highlighter", "edit_use-Retouch-Iris", "edit_use-Retouch-Magic", "edit_use-Retouch-Matte", "edit_use-Retouch-Reshape", "edit_use-Retouch-Resize", "edit_use-Retouch-Sculpt", "edit_use-Retouch-SkinTone", "edit_use-Retouch-Smooth", "edit_use-Retouch-Texture", "edit_use-Retouch-Whiten", "edit_use-Tools-AI Replace", "edit_use-Tools-Adjust", "edit_use-Tools-Blur", "edit_use-Tools-Bokeh", "edit_use-Tools-Enhance", "edit_use-Tools-Eraser", "edit_use-Tools-Prism", "edit_use-Tools-Relight", "edit_use-Tools-Stamp", "edit_use-Tools-Stretch", "edit_use-Tools-Vignette"

))
)
,
-- 近30天用户核心行为
core_behave_30 as
(
 SELECT * FROM
(
SELECT user_pseudo_id, concat(event_name,'-',first,'-',second,'_30') activity,sum(pv) pv
FROM  behave_pre
where event_date  between date_sub(mDATE, interval 29 day) and mDATE
group by 1,2
)
PIVOT
(
sum(pv) AS pv
FOR activity in (
"camera_enter-all-all_30","camera_save-Filter-all_30","camera_save-all-all_30","camera_taken-Filter-all_30","camera_taken-all-all_30","edit_enter-AI Style-all_30","edit_enter-Creative-all_30","edit_enter-Filter-all_30","edit_enter-Hair-all_30","edit_enter-Makeup-all_30","edit_enter-Mykit-all_30","edit_enter-Presets-all_30","edit_enter-Retouch-all_30","edit_enter-Tools-all_30","edit_enter-all-all_30","edit_save-AI Style-all_30","edit_save-Creative-all_30","edit_save-Filter-all_30","edit_save-Hair-all_30","edit_save-Makeup-all_30","edit_save-Presets-all_30","edit_save-Retouch-all_30","edit_save-Tools-all_30","edit_save-all-all_30","edit_save-其他-all_30","edit_use-AI Style-all_30","edit_use-Creative-all_30","edit_use-Filter-all_30","edit_use-Hair-all_30","edit_use-Makeup-all_30","edit_use-Presets-all_30","edit_use-Retouch-all_30","edit_use-Tools-all_30",
"func_video_enter-reshape_30", "func_video_use-foundation_30", "func_video_enter-firm_30", "func_video_enter-acne_30", "func_video_use-sculpt_30", "func_video_enter-clarity_30", "func_video_use-brighten_30", "func_video_use-reshape_30", "func_video_use-matte_30", "func_video_enter-dark_circle_30", "func_video_enter-stretch_30", "video_magic_status-open_30", "video_save-skin_tone_30", "func_video_enter-smooth_30", "func_video_enter-sculpt_30", "video_save-whiten_30", "func_video_use-clarity_30", "video_save-acne_30", "video_save-reshape_30", "video_save-contouring_30", "video_save-brighten_30", "func_video_enter-makeup_30", "func_video_use-makeup_30", "func_video_enter-foundation_30", "video_save-stretch_30", "video_save-overview_30", "video_start_edit-overview_30", "func_video_enter-matte_30", "func_video_use-firm_30", "func_video_use-whiten_30", "video_save-matte_30", "video_save-foundation_30", "func_video_enter-whiten_30", "func_video_enter-brighten_30", "func_video_use-stretch_30", "video_save-firm_30", "video_save-dark_circle_30", "func_video_use-smooth_30", "video_magic_status-close_30", "func_video_use-skin_tone_30", "video_save-sculpt_30", "func_video_use-dark_circle_30", "func_video_use-acne_30", "video_save-smooth_30", "func_video_use-contouring_30", "video_save-clarity_30", "func_video_enter-contouring_30", "func_video_enter-skin_tone_30", "video_save-makeup_30"
        )
    )
)
,
core_behave_60 as
(
 SELECT * FROM
(
SELECT user_pseudo_id, concat(event_name,'-',first,'-',second,'_60') activity,sum(pv) pv
FROM  behave_pre
where event_date  between date_sub(mDATE, interval 59 day) and mDATE
group by 1,2
)
PIVOT
(
sum(pv) AS pv
FOR activity in (
"camera_enter-all-all_60","camera_save-Filter-all_60","camera_save-all-all_60","camera_taken-Filter-all_60","camera_taken-all-all_60","edit_enter-AI Style-all_60","edit_enter-Creative-all_60","edit_enter-Filter-all_60","edit_enter-Hair-all_60","edit_enter-Makeup-all_60","edit_enter-Mykit-all_60","edit_enter-Presets-all_60","edit_enter-Retouch-all_60","edit_enter-Tools-all_60","edit_enter-all-all_60","edit_save-AI Style-all_60","edit_save-Creative-all_60","edit_save-Filter-all_60","edit_save-Hair-all_60","edit_save-Makeup-all_60","edit_save-Presets-all_60","edit_save-Retouch-all_60","edit_save-Tools-all_60","edit_save-all-all_60","edit_save-其他-all_60","edit_use-AI Style-all_60","edit_use-Creative-all_60","edit_use-Filter-all_60","edit_use-Hair-all_60","edit_use-Makeup-all_60","edit_use-Presets-all_60","edit_use-Retouch-all_60","edit_use-Tools-all_60",
"func_video_enter-reshape_60", "func_video_use-foundation_60", "func_video_enter-firm_60", "func_video_enter-acne_60", "func_video_use-sculpt_60", "func_video_enter-clarity_60", "func_video_use-brighten_60", "func_video_use-reshape_60", "func_video_use-matte_60", "func_video_enter-dark_circle_60", "func_video_enter-stretch_60", "video_magic_status-open_60", "video_save-skin_tone_60", "func_video_enter-smooth_60", "func_video_enter-sculpt_60", "video_save-whiten_60", "func_video_use-clarity_60", "video_save-acne_60", "video_save-reshape_60", "video_save-contouring_60", "video_save-brighten_60", "func_video_enter-makeup_60", "func_video_use-makeup_60", "func_video_enter-foundation_60", "video_save-stretch_60", "video_save-overview_60", "video_start_edit-overview_60", "func_video_enter-matte_60", "func_video_use-firm_60", "func_video_use-whiten_60", "video_save-matte_60", "video_save-foundation_60", "func_video_enter-whiten_60", "func_video_enter-brighten_60", "func_video_use-stretch_60", "video_save-firm_60", "video_save-dark_circle_60", "func_video_use-smooth_60", "video_magic_status-close_60", "func_video_use-skin_tone_60", "video_save-sculpt_60", "func_video_use-dark_circle_60", "func_video_use-acne_60", "video_save-smooth_60", "func_video_use-contouring_60", "video_save-clarity_60", "func_video_enter-contouring_60", "func_video_enter-skin_tone_60", "video_save-makeup_60"
        )
    )
)
,
core_behave_90 as
(
 SELECT * FROM
(
SELECT user_pseudo_id, concat(event_name,'-',first,'-',second,'_90') activity,sum(pv) pv
FROM  behave_pre
where event_date  between date_sub(mDATE, interval 89 day) and mDATE
group by 1,2
)
PIVOT
(
sum(pv) AS pv
FOR activity in (
"camera_enter-all-all_90","camera_save-Filter-all_90","camera_save-all-all_90","camera_taken-Filter-all_90","camera_taken-all-all_90","edit_enter-AI Style-all_90","edit_enter-Creative-all_90","edit_enter-Filter-all_90","edit_enter-Hair-all_90","edit_enter-Makeup-all_90","edit_enter-Mykit-all_90","edit_enter-Presets-all_90","edit_enter-Retouch-all_90","edit_enter-Tools-all_90","edit_enter-all-all_90","edit_save-AI Style-all_90","edit_save-Creative-all_90","edit_save-Filter-all_90","edit_save-Hair-all_90","edit_save-Makeup-all_90","edit_save-Presets-all_90","edit_save-Retouch-all_90","edit_save-Tools-all_90","edit_save-all-all_90","edit_save-其他-all_90","edit_use-AI Style-all_90","edit_use-Creative-all_90","edit_use-Filter-all_90","edit_use-Hair-all_90","edit_use-Makeup-all_90","edit_use-Presets-all_90","edit_use-Retouch-all_90","edit_use-Tools-all_90",
"func_video_enter-reshape_90", "func_video_use-foundation_90", "func_video_enter-firm_90", "func_video_enter-acne_90", "func_video_use-sculpt_90", "func_video_enter-clarity_90", "func_video_use-brighten_90", "func_video_use-reshape_90", "func_video_use-matte_90", "func_video_enter-dark_circle_90", "func_video_enter-stretch_90", "video_magic_status-open_90", "video_save-skin_tone_90", "func_video_enter-smooth_90", "func_video_enter-sculpt_90", "video_save-whiten_90", "func_video_use-clarity_90", "video_save-acne_90", "video_save-reshape_90", "video_save-contouring_90", "video_save-brighten_90", "func_video_enter-makeup_90", "func_video_use-makeup_90", "func_video_enter-foundation_90", "video_save-stretch_90", "video_save-overview_90", "video_start_edit-overview_90", "func_video_enter-matte_90", "func_video_use-firm_90", "func_video_use-whiten_90", "video_save-matte_90", "video_save-foundation_90", "func_video_enter-whiten_90", "func_video_enter-brighten_90", "func_video_use-stretch_90", "video_save-firm_90", "video_save-dark_circle_90", "func_video_use-smooth_90", "video_magic_status-close_90", "func_video_use-skin_tone_90", "video_save-sculpt_90", "func_video_use-dark_circle_90", "func_video_use-acne_90", "video_save-smooth_90", "func_video_use-contouring_90", "video_save-clarity_90", "func_video_enter-contouring_90", "func_video_enter-skin_tone_90", "video_save-makeup_90"
        )
    )
)
,
-- 近7/30/60天拼图行为
-- puzzle as
-- (
--     select user_pseudo_id
--             , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv
--             , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv
--             , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv_30
--             , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv_30
--             , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE and action ='拼图点击' then pv end) puzzle_click_pv_60
--             , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE and action ='拼图保存' then pv end) puzzle_save_pv_60
--             , sum (case when action ='拼图点击' then pv end) puzzle_click_pv_90
--             , sum (case when action ='拼图保存' then pv end) puzzle_save_pv_90
--     from behave_pre
--     where mark_c is not null
--       and action in ('拼图点击', '拼图保存')
--       and event_date between date_sub(mDATE, interval 89 day) and mDATE
--     group by 1
-- )
-- ,
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
                        and paid_type ='paid' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) pay_function_click_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type ='paid' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) pay_function_click_pv_pre
                , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) free_function_click_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type ='free' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) free_function_click_pv_pre
                , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_save','camera_save','video_save') then pv end) free_function_save_pv
                , sum (case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type ='free' and event_name in ('edit_save','camera_save','video_save') then pv end) free_function_save_pv_pre

                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type ='paid' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) pay_function_click_pv_30
                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) free_function_click_pv_30
                , sum (case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_save','camera_save','video_save') then pv end) free_function_save_pv_30

                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type ='paid' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) pay_function_click_pv_60
                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) free_function_click_pv_60
                , sum (case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                        and paid_type ='free' and event_name in ('edit_save','camera_save','video_save') then pv end) free_function_save_pv_60

                , sum (case when paid_type ='paid' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) pay_function_click_pv_90
                , sum (case when paid_type ='free' and event_name in ('edit_use','camera_taken','func_video_use') then pv end) free_function_click_pv_90
                , sum (case when paid_type ='free' and event_name in ('edit_save','camera_save','video_save') then pv end) free_function_save_pv_90
        from behave_pre
        where event_name in ('edit_use','camera_taken','edit_save','camera_save')
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
        --     , IFNULL(selftake_enter_pv_7, 0)-IFNULL(selftake_enter_pv_pre_7, 0) grow_selftake_enter_pv
            , IFNULL(take_video_pv_7, 0)-IFNULL(take_video_pv_pre_7, 0) grow_take_video_pv
            , IFNULL(take_video_save_pv_7, 0)-IFNULL(take_video_save_pv_pre_7, 0) grow_take_video_save_pv
    from
    (
        select user_pseudo_id
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        event_name in('edit_enter') then pv end) edit_enter_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        event_name in('edit_enter')  then pv end) edit_enter_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        event_name in('edit_save') then pv end) edit_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        event_name in('edit_save') then pv end) edit_save_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        event_name in('camera_taken') then pv end) take_photo_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        event_name in('camera_taken') then pv end) take_photo_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        event_name in('camera_save') then pv end) take_photo_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        event_name in('camera_save') then pv end) take_photo_save_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
        event_name in('func_video_use')then pv end) take_video_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
         event_name in('func_video_use') then pv end) take_video_pv_pre_7
            , sum (case when event_date between date_sub(mDATE, interval 6 day) and mDATE and
         event_name in('video_save') then pv end) take_video_save_pv_7
            , sum (case
        when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) and
        event_name in('video_save')  then pv end) take_video_save_pv_pre_7
        from behave_pre
        where event_date between date_sub(mDATE, interval 13 day) and mDATE
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
            , count (distinct case when event_date between date_sub(mDATE, interval 6 day) and mDATE then second end) function_num
            , count (distinct case when event_date between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day) then second end) function_num_pre

            , count (distinct case when event_date between date_sub(mDATE, interval 29 day) and mDATE then second end) function_num_30
            , count (distinct case when event_date between date_sub(mDATE, interval 59 day) and mDATE then second end) function_num_60
            , count (distinct second) function_num_90
        from behave_pre
        where event_date between date_sub(mDATE, interval 89 day) and mDATE
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

        from airbrush-1324.temp.dws_dz_dau_split_user_other_behave
        where date between date_sub(mDATE, interval 89 day) and mDATE
        group by 1
    )
)
,
-- 付费素材指标及成长情况
-- airbrush-1324.temp.dwd_dz_roi_predict_0_material_events_v
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
        --from airbrush-1324.temp.dwd_dz_roi_predict_0_material_events_v
        from airbrush-1324.temp.dwd_dz_material_events_temp_v
        where date_p between date_sub(mDATE, interval 89 day) and mDATE
        group by 1
    )
)
,
home_content as
(
    select user_pseudo_id
            ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
                    and event_name='hp_exp' and module='Homepage_show' then pv end) homepage_exposure_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 6 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv
            ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
                    and event_name='hp_exp' and module='Homepage_show' then pv end) homepage_exposure_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_30
        --     ,sum(case when event_date between date_sub(mDATE, interval 29 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_30
               ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
                and event_name='hp_exp' and module='Homepage_show' then pv end) homepage_exposure_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and event_name='hp_exp' and module_type='Homepage_show' then pv end) homepage_exposure_pv
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_60
        --     ,sum(case when event_date between date_sub(mDATE, interval 59 day) and mDATE
        --             and module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_60
            ,sum(case when event_name='hp_exp' and module='Homepage_show' then pv end) homepage_exposure_pv_90
        --     ,sum(case when event_name='homepageappr_bd' then pv end) homepage_exposure_pv_90
        --     ,sum(case when event_name in ('home_content_clk_bd') then pv end) homepage_click_pv_90
        --     ,sum(case when module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) homepage_feature_show_pv_90
        --     ,sum(case when module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) homepage_feature_click_pv_90
        --     ,sum(case when module_type='Banner' and event_name='home_content_show_f_bd' then pv end) homepage_banner_show_pv_90
        --     ,sum(case when module_type='Banner' and event_name='home_content_clk_bd' then pv end) homepage_banner_click_pv_90
        --     ,sum(case when module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) homepage_reconmend_show_pv_90
        --     ,sum(case when module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) homepage_reconmend_click_pv_90
        --     ,sum(case when module_type='专题' and event_name='home_content_show_f_bd' then pv end) homepage_topic_show_pv_90
        --     ,sum(case when module_type='专题' and event_name='home_content_clk_bd' then pv end) homepage_topic_click_pv_90
        --     ,sum(case when module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) homepage_miniapp_show_pv_90
        --     ,sum(case when module_type='miniapp' and event_name='home_content_clk_bd' then pv end) homepage_miniapp_click_pv_90
--     from `airbrush-1324.temp.dwd_dz_homepage_overall_behave_pre`
     from `airbrush-1324.stat.dwd_dz_airbrush_behavior_homepage_func2`
    where event_date between date_sub(mDATE, interval 89 day) and mDATE
        and event_name in ('hp_exp')
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
        and app_name='AirBrush'
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
--     ,p.*except(user_pseudo_id)
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
-- left join puzzle p
-- on g.user_pseudo_id=p.user_pseudo_id
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




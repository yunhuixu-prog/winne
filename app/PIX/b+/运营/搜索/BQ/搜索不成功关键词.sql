
with search_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,platform
-- ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
-- ,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
,`dataintegration-265403.func`.getParams(event_params,'word_content').string_value word_content
-- ,`dataintegration-265403.func`.getParams(event_params,'template_id').string_value template_id
,`dataintegration-265403.func`.getParams(event_params,'tem_tag').string_value tem_tag
-- ,`dataintegration-265403.func`.getParams(event_params,'贴纸素材ID').string_value sticker_id
,`dataintegration-265403.func`.getParams(event_params,'贴纸分类ID').string_value sticker_tag
,`dataintegration-265403.func`.getParams(event_params,'bru_material_tag').string_value bru_material_tag
,`dataintegration-265403.func`.getParams(event_params,'滤镜分类').string_value filter_material_tag
,`dataintegration-265403.func`.getParams(event_params,'tex_material_tag').string_value tex_material_tag
-- ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value sub_feature
-- ,`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value cur_spm
        ,user_pseudo_id
        ,country
        ,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-01',
        '2024-05-15','beautyplus',false)
    where version>='7.6.030'
    and event_name in   ('material_search_content_bd'  -- 搜索内容
                        ,'beauty_template_material_appr_bd' -- 配方曝光（需要限制搜索）
--                         ,'beauty_template_material_clk_bd'
                        ,'beauty_sticker_imp_bd' -- 贴纸曝光（需要限制搜索）
--                         ,'beau_clk_sticker_use_bd'
                        ,'search_func_appr_bd' -- 搜索功能曝光
--                         ,'search_func_clk_bd'
                        ,'search_miniapp_appr_bd'  --搜索miniapp曝光
--                         ,'search_miniapp_clk_bd'
                        ,'beauty_doodle_imp_bd'  -- 涂鸦笔曝光（需要限制搜索）
--                         ,'beau_clk_doodle_use_bd'
                        ,'beauty_filter_imp_bd'  -- 编辑滤镜笔曝光（需要限制搜索）
--                         ,'beauty_filter_click_bd'
                        ,'selfie_filter_imp_bd'  -- 自拍滤镜曝光（需要限制搜索）
--                         ,'selfie_filter_click_bd'
                        ,'beauty_text_imp_bd'  -- 文字曝光（需要限制搜索）
--                         ,'beau_clk_text_use_bd'
                        )
    group by
        1,2,3,4,5,6,7,8,9,10,11,12
)
,
user_info as
(
    select distinct
        event_date_hk
        ,platform
        ,user_pseudo_id
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date'2024-05-01'
        and '2024-05-15'
        and app_name='BeautyPlus'
)
,
search_final_event as
(
    select
        event_date
        ,timestamp_add(timestamp_micros(event_timestamp), interval 8 hour) event_time
        ,event_name
        ,t.platform platform
        ,word_content
        ,coalesce(tem_tag,sticker_tag) material_tag
        ,t.user_pseudo_id user_pseudo_id
        ,country
        ,pv
    from
        search_event t
    join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform
    where
        case    when event_name in ('beauty_template_material_appr_bd') then tem_tag='BP_cat_TEM_SCH'
                when event_name in ('beauty_sticker_imp_bd') then sticker_tag in ('BP_cat_DST_SCH','BP_cat_STI_SCH')
                when event_name in ('beauty_doodle_imp_bd') then bru_material_tag='BP_cat_BRU_SCH' -- 涂鸦笔
                when event_name in ('beauty_filter_imp_bd','selfie_filter_imp_bd') then filter_material_tag='BP_cat_FIL_SCH' -- 滤镜
                when event_name in ('beauty_text_imp_bd') then tex_material_tag='BP_cat_TEX_SCH' -- 文字
                else 1=1
                end
)

select
    s.country
    ,s.platform
    ,s.event_date
    ,count(distinct s.word_content) search_word  -- 搜索的单词量级
    ,count(distinct r.word_content) search_word_has_result  -- 搜索有结果的单词量级
from
    (select
        country
        ,platform
        ,event_date
        ,event_time
        ,user_pseudo_id
        ,word_content
    from
        search_final_event
    where event_name in ('material_search_content_bd')
    group by
        1,2,3,4,5,6) s
    left join   (select
                    country
                    ,platform
                    ,event_date
                    ,event_time
                    ,user_pseudo_id
                    ,word_content
                from
                    search_final_event
                where event_name in ('beauty_template_material_appr_bd','beauty_sticker_imp_bd'
                    ,'search_miniapp_appr_bd','search_func_appr_bd'
                    ,'beauty_doodle_imp_bd','beauty_filter_imp_bd','selfie_filter_imp_bd','beauty_text_imp_bd')
                group by
                    1,2,3,4,5,6) r on s.country=r.country and s.event_date=r.event_date and s.user_pseudo_id=r.user_pseudo_id
                                    and s.platform=r.platform and s.word_content=r.word_content
--                                     and s.event_time+interval'15'second >= r.event_time
--                                     and s.event_time-interval'1'second <= r.event_time
group by 
    1,2,3


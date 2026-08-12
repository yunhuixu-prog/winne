-- drop table if exists `beautyplus-bc0ed.temp.dwd_search_behavior`;
-- create table if not exists `beautyplus-bc0ed.temp.dwd_search_behavior` as
delete from beautyplus-bc0ed.temp.dwd_search_behavior where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into beautyplus-bc0ed.temp.dwd_search_behavior


with search_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_pseudo_id
        ,country
        ,platform
        ,version
        ,language
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}',
        '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}','beautyplus',true)
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.6.030')
)
,
dwd_search_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,platform
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
        ,`dataintegration-265403.func`.getParams(event_params,'word_content').string_value word_content
        ,`dataintegration-265403.func`.getParams(event_params,'template_id').string_value template_id
        ,`dataintegration-265403.func`.getParams(event_params,'tem_tag').string_value tem_tag
        ,`dataintegration-265403.func`.getParams(event_params,'贴纸素材ID').string_value sticker_id
        ,`dataintegration-265403.func`.getParams(event_params,'贴纸分类ID').string_value sticker_tag
        ,`dataintegration-265403.func`.getParams(event_params,'mids_material_tag').string_value mids_material_tag
        ,`dataintegration-265403.func`.getParams(event_params,'mids_material').string_value mids_material
        ,`dataintegration-265403.func`.getParams(event_params,'bru_material_tag').string_value bru_material_tag
        ,`dataintegration-265403.func`.getParams(event_params,'滤镜分类').string_value filter_material_tag
        ,`dataintegration-265403.func`.getParams(event_params,'tex_material_tag').string_value tex_material_tag

        ,`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value pre_page_content
        ,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value dpre_page_content
        ,`dataintegration-265403.func`.getParams(event_params,'ddpre_page_content').string_value ddpre_page_content
        ,`dataintegration-265403.func`.getParams(event_params,'dddpre_page_content').string_value dddpre_page_content

        ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value sub_feature
        ,`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value cur_spm
        ,split(language,'-')[0] lang
        ,user_pseudo_id
        ,country
        ,version
        ,count(1) pv
    from
        search_event
    where
    (
        event_name in   (
                        -- 搜索按钮点击，热搜词曝光点击，搜索内容
                        'material_search_button_clk_bd'
                        ,'trending_word_imp_bd'
                        ,'trending_word_clk_bd'
                        ,'material_search_content_bd'
                        -- 搜索素材曝光点击保存订阅
                        ,'beauty_template_material_appr_bd'
                        ,'beauty_template_material_clk_bd'
                        ,'beauty_sticker_imp_bd'
                        ,'beau_clk_sticker_use_bd'
                        ,'search_func_appr_bd'
                        ,'search_func_clk_bd'
                        ,'search_miniapp_appr_bd'
                        ,'search_miniapp_clk_bd'
                        ,'beauty_doodle_imp_bd'
                        ,'beau_clk_doodle_use_bd'
                        ,'beauty_filter_imp_bd'
                        ,'beauty_filter_click_bd'
                        ,'selfie_filter_imp_bd'
                        ,'selfie_filter_click_bd'
                        ,'beauty_text_imp_bd'
                        ,'beau_clk_text_use_bd'

                        ,'subscription_try_suc'  -- 订阅
                        ,'beautifysave_bd'  -- 限制搜索配方保存，滤镜保存
                        ,'selfiesave_bd'  -- 限制滤镜保存
                        ,'beau_sticker_save_bd' -- 限制搜索贴纸保存
                        ,'beau_doodle_save_bd'
                        ,'beau_text_save_bd'

                        -- 搜索按钮曝光
                        ,'beauty_appr_tab_clk_bd' -- 修图页底部选择tab按钮点击
                        ,'page_event' -- 限制商店页
--                         ,'beauty_appr_bd'-- 之前用的
                        )
    ) or
    (event_name in ('homepageappr_bd') and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.7.010'))
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
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
        event_date_hk between date'{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name='BeautyPlus'
)
-- 订阅页面，订阅事件，tab点击等还没有区分source和material type，where条件估计也不对，有时间看下
select
    event_date
    ,timestamp_add(timestamp_micros(event_timestamp), interval 8 hour) event_time
    ,event_name
    ,t.platform platform
    ,case   when event_name in ('beautifysave_bd','selfiesave_bd','subscription_try_suc','beau_sticker_save_bd','beau_doodle_save_bd','beau_text_save_bd') then 'total'
            when event_name in ('beauty_appr_tab_clk_bd') then 'func_page_search'
            when event_name in ('page_event') and regexp_contains(cur_spm,'1012_04|1012_03|1012_02|1012_01') then 'shop_page_search'
            when event_name in ('homepageappr_bd') then 'home_page_search'
--             when event_name in ('page_event') and regexp_contains(cur_spm,'1005') then 'total'
            when event_name in ('search_func_appr_bd','search_func_clk_bd') then 'home_page_search'
            else source end source
    ,case   when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd') or (event_name='beautifysave_bd' and tem_tag='BP_cat_TEM_SCH') then 'template'
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd','beau_sticker_save_bd') then 'sticker'
            when event_name in ('beauty_filter_imp_bd','beauty_filter_click_bd','selfie_filter_imp_bd','selfie_filter_click_bd') or (event_name in ('beautifysave_bd','selfiesave_bd') and filter_material_tag='BP_cat_FIL_SCH' ) then 'filter'
            when event_name in ('beauty_doodle_imp_bd','beau_clk_doodle_use_bd','beau_doodle_save_bd') then 'brush'
            when event_name in ('beauty_text_imp_bd','beau_clk_text_use_bd','beau_text_save_bd') then 'text'
            when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then 'miniapp'
            when event_name in ('search_func_appr_bd','search_func_clk_bd') then 'function'

            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_TEM_SCH') then 'template'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_STI_SCH') then 'sticker'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_BRU_SCH') then 'brush'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_FIL_SCH') then 'filter'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_TEX_SCH') then 'text'
            when event_name in ('subscription_try_suc') then 'function'

            end material_type
    ,case   when event_name in ('homepageappr_bd') then 'all'
            when sub_feature in ('配方') or regexp_contains(cur_spm,'1012_04') then 'template'
            when sub_feature in ('贴纸') or regexp_contains(cur_spm,'1012_02') then 'sticker'
            when sub_feature in ('文字') then 'text'
            when sub_feature in ('涂鸦笔') or regexp_contains(cur_spm,'1012_03') then 'brush'
            when sub_feature in ('滤镜') or regexp_contains(cur_spm,'1012_01') then 'filter'
            else material_type
            end source_material_type
    ,word_content
    ,coalesce(template_id,sticker_id) material_id
    ,coalesce(tem_tag,sticker_tag) material_tag
    ,mids_material_tag
    ,mids_material
    ,t.user_pseudo_id user_pseudo_id
    ,country
    ,pv
    ,lang
from
    dwd_search_event t
join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform
where
    case    when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd','beautifysave_bd') then tem_tag='BP_cat_TEM_SCH' -- 配方
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd','beau_sticker_save_bd') then sticker_tag in ('BP_cat_DST_SCH','BP_cat_STI_SCH') -- 贴纸
            when event_name in ('beauty_doodle_imp_bd','beau_clk_doodle_use_bd','beau_doodle_save_bd') then bru_material_tag='BP_cat_BRU_SCH' -- 涂鸦笔
            when event_name in ('beauty_filter_imp_bd','beauty_filter_click_bd','selfie_filter_imp_bd','selfie_filter_click_bd','beautifysave_bd','selfiesave_bd') then filter_material_tag='BP_cat_FIL_SCH' -- 滤镜
            when event_name in ('beauty_text_imp_bd','beau_clk_text_use_bd','beau_text_save_bd') then tex_material_tag='BP_cat_TEX_SCH' -- 文字

            when event_name in ('subscription_try_suc') then (mids_material_tag in ('BP_cat_TEM_SCH','BP_cat_STI_SCH','BP_cat_BRU_SCH','BP_cat_FIL_SCH','BP_cat_TEX_SCH') or regexp_contains(pre_page_content,'搜索[,，][0-9]{4}') or regexp_contains(dpre_page_content,'搜索[,，][0-9]{4}') or regexp_contains(ddpre_page_content,'搜索[,，][0-9]{4}') or regexp_contains(dddpre_page_content,'搜索[,，][0-9]{4}'))

            when event_name in ('beauty_appr_tab_clk_bd') then sub_feature in ('贴纸','配方') or (sub_feature in ('文字','涂鸦笔','滤镜') and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.7.100'))
            -- 配方商店页 1012_04, 贴纸商店页 1012_02, 滤镜商店页 1012_01, 涂鸦笔商店页 1012_03, 修图编辑页 1005
            when event_name in ('page_event') then regexp_contains(cur_spm,'1012_04|1012_02') or (regexp_contains(cur_spm,'1012_03|1012_01') and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.7.100'))
            else 1=1
            end

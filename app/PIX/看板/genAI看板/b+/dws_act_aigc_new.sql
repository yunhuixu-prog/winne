--aigc行为
-- BeautyPlus_391_dws_aigc_new
delete from beautyplus-bc0ed.temp.dws_act_aigc_new where date>= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
-- delete from beautyplus-bc0ed.temp.dws_act_aigc_new where date>= '2023-09-14';
insert into `beautyplus-bc0ed.temp.dws_act_aigc_new` 
with event as
(     
    SELECT
    *    
    FROM
        `beautyplus-bc0ed.analytics.stage_dz_event_view` 
    WHERE  
        -- parse_date('%Y%m%d', event_date) >='2023-09-14'
        parse_date('%Y%m%d', event_date) >='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and platform in ('IOS','ANDROID')  
)
,
EVENT1 AS  
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,case   when func.getParams(event_params,'page_id').string_value in ('home_page_view','homepage') then 'enter'
                when func.getParams(event_params,'page_id').string_value in ('make_page_view','bundle_make_page_view','video_make_page_view','list_page_view','multi_image_page') then 'use'
                end as action
        ,func.getParams(event_params,'project').string_value as project
        ,user_pseudo_id
        ,count(1) as pv
    FROM
        event
    WHERE
        event_name IN ('h5_page_event_bd')
        and func.getParams(event_params,'project').string_value in ('AI_art','AI_sketch','AI_motion_comic','BeautyPlus_AI','AI_style_morph_pet','AI_Zodiac_Persona','AI_Image_Photo','AI_Pet_Portray','BeautyPlus_AI_V3','AI_Double_Photo','ai_portrait','ai_filter')
        and func.getParams(event_params,'page_id').string_value in ('home_page_view','make_page_view','bundle_make_page_view','video_make_page_view','list_page_view','multi_image_page','homepage')
    group by 
        1,2,3,4
    
    union all
    select                    
        parse_date('%Y%m%d', event_date) event_date
        ,'save' as action
        ,func.getParams(event_params,'project').string_value as project
        ,user_pseudo_id
        ,count(1) as pv
    FROM
        event
    WHERE
        event_name in ('h5_page_clk_bd','h5_page_button_clk_bd')
        and func.getParams(event_params,'project').string_value in ('AI_art','AI_sketch','AI_motion_comic','BeautyPlus_AI','AI_style_morph_pet','AI_Zodiac_Persona','AI_Image_Photo','AI_Pet_Portray','BeautyPlus_AI_V3','AI_Double_Photo','ai_portrait','ai_filter')
        and func.getParams(event_params,'button_type').string_value in ('save_collection','save','save_poster','save_vedio','save_all')
    group by 
        1,2,3,4

    union all
    select
                                
        parse_date('%Y%m%d', event_date) event_date
        ,'use' as action
        ,func.getParams(event_params,'project').string_value as project
        ,user_pseudo_id
        ,count(1) as pv
    from
        event
    where
        event_name IN ('h5_page_clk_bd','h5_page_button_clk_bd')
        and func.getParams(event_params,'project').string_value in ('AI_style_morph_pet')
        and func.getParams(event_params,'button_type').string_value in ('upload')
    group by
        1,2,3,4 

    union all
    select 
        parse_date('%Y%m%d', event_date) event_date
        ,case   when event_name='ai_figure_clk_bd' then 'enter'
                when event_name="material_click_bd" then 'use'
                when event_name="beautifysave_bd" then 'save'
                end as action
        ,'Avatar' as project
        ,user_pseudo_id
        ,count(1) as pv
    from
        event
    where
            event_name IN ("ai_figure_clk_bd" )
            or (event_name = "material_click_bd"  and func.getParams(event_params,'material_id').string_value like 'BP_AIR%')
            or (event_name = "beautifysave_bd"  and func.getParams(event_params,'分身素材ID').string_value like 'BP_AIR%')
    group by
        1,2,3,4 

    union all
     select 
        parse_date('%Y%m%d', event_date) event_date
        ,case   when event_name="beau_composition_clk_bd" then 'enter'
                when event_name in ("ai_extend_generate_clk_bd",'ai_extend_regenerate_clk_bd')  then 'use'
                when event_name="beautifysave_bd" then 'save'
                end as action
        ,case
        when s.value.string_value='原始尺寸' then 'AI Extend_Original'
        when s.value.string_value='自定义' then 'AI Extend_Custom'
        end as project
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(event_params) s
    where
            (event_name IN ("beau_composition_clk_bd" ) and s.key= '子功能' and s.value.string_value in('原始尺寸','自定义') )
            or (event_name in ("ai_extend_generate_clk_bd",'ai_extend_regenerate_clk_bd')  and s.key= 'type' )
    group by
        1,2,3,4 

   union all
      select 
        parse_date('%Y%m%d', event_date) event_date
        , 'save' as action
        ,case
        when a='原始尺寸' then 'AI Extend_Original'
        when a='自定义' then 'AI Extend_Custom'
        end as project
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(event_params) s,unnest(SPLIT(s.value.string_value, ',')) a
    where
        event_name = "beautifysave_bd"  and s.key= 'AI扩展' and s.value.string_value <>''
    group by
        1,2,3,4 

) 

select 
    event_date date 
    ,case   when project='AI_art' then 'AIArt'
            when project='AI_sketch' then 'AISketch'
            when project='AI_style_morph_pet' then 'AI Style Morph Pet'
            when project='AI_motion_comic' then 'AI Motion Comic'
            when project='BeautyPlus_AI' then 'BeautyPlus_AI'
            when project='AI_Zodiac_Persona' then 'AI Zodiac Persona'
            when project='AI_Image_Photo' then 'AI Image Photo'
            when project='AI_Pet_Portray' then 'AI Pet Portray'
            when project='BeautyPlus_AI_V3' then 'BeautyPlus_AI V3'
            when project='AI_Double_Photo' then 'AI Pair Photo'
            when project='ai_portrait' then 'AI Portrait 2.0'
            when project='ai_filter' then 'AI Filter 1.0'
            else project 
            end as function
    ,action
    ,platform
    ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,country
    ,is_UA
    ,a.user_pseudo_id
    ,SUM(pv)pv
from 
    EVENT1 a
    -- join `dataintegration-265403.stat.stat_active_advice_detail_d` b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date and event_date_hk>='2023-09-14'
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date and event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
group by
    1,2,3,4,5,6,7,8

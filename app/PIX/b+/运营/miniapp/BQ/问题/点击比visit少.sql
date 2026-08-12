
--miniapp 点击进入对不上问题：7.6.020前的版本根本没有首页曝光事件哦
with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
        ,app_info.version version
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        parse_date('%Y%m%d', event_date) >='2024-01-01'
        -- and platform in ('IOS','ANDROID')
        and event_name in ('home_content_clk_bd','h5_page_event_bd')
)

select event_date,event_name,version
    -- ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value
    ,count(distinct user_pseudo_id)
from event
-- where case when event_name in ('home_content_show_f_bd','home_content_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='miniapp' and coalesce(`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value) in ('BP_MIN_00000012','BP_MIN_00000068')
--       when event_name in ('h5_page_event_bd') then `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_style_morph_pet' and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
--       end
-- where case when event_name in ('home_content_show_f_bd','home_content_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='miniapp' and coalesce(`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value) in ('BP_MIN_00000001')
--       when event_name in ('h5_page_event_bd') then `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_art' and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
--       end
where case when event_name in ('home_content_show_f_bd','home_content_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='miniapp' and coalesce(`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value) in ('BP_MIN_00000146','BP_MIN_00000002','BP_MIN_00000147','BP_MIN_00000009')
      when event_name in ('h5_page_event_bd') then `dataintegration-265403.func`.getParams(event_params,'project').string_value in ('id_photo_v3','id_photo') and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
      end

group by 1,2,3
order by 1,3,2



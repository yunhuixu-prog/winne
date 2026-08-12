-- 主题
-- 曝光 theme_page_material_imp material_id
-- 点击 theme_page_material_clk material_id
-- 使用：详情页、收藏列表内，点击设置主题 
    -- theme_material_page_set_clk material_id
-- 收藏：wallpaper_material_favorite_clk material='theme'

-- widget图/Quotes
-- 曝光 widget_page_material_imp widget_material_page_imp material_id
-- 点击 widget_page_material_clk material_id
-- 使用：主题详情页、分类导航页widget内、收藏列表内，点击添加widget 
    -- theme_set_page_clk internal_material_id set_type='widget'
    -- widget_add_clk material_id
-- 收藏：wallpaper_material_favorite_clk material='widget'

-- icon
-- 曝光 icon_page_material_imp material_id
-- 点击 icon_page_material_clk material_id
-- 使用：详情页、收藏列表内，点击设置主题 
    -- icon_material_page_install_clk material_id
-- 收藏：wallpaper_material_favorite_clk material='icon'

-- wallpaper
-- 曝光 wallpaper_page_material_imp material_id
-- 点击 wallpaper_page_material_clk material_id
-- 使用：主题详情页、分类导航页壁纸内、收藏列表内，点击下载
    -- wallpaper_material_download_clk material='wallpaper'
-- 收藏：wallpaper_material_favorite_clk material='wallpaper'

-- AI壁纸
-- 曝光 ai_wallpaper_page_material_imp material_id
-- 点击 ai_wallpaper_page_material_clk material_id
-- 使用：AI Art素材详情页、收藏列表内，点击下载
    -- wallpaper_material_download_clk material='ai_wallpaper'
-- 收藏：wallpaper_material_favorite_clk material='ai_wallpaper'


-- 订阅 sub_suc material_id
with event_pre as
(
    select 
        parse_date('%Y%m%d', event_date) event_date
        ,event_name
        ,event_params
        ,user_pseudo_id
    from 
        `aiwidget-abc05.analytics_383121217.events_intraday_*`
    where 
        event_name in ('theme_page_material_imp'
                        ,'theme_page_material_clk'
                        ,'theme_material_page_set_clk'
                        ,'wallpaper_material_favorite_clk'
                        ,'widget_page_material_imp'
                        ,'widget_material_page_imp'
                        ,'widget_page_material_clk'
                        ,'theme_set_page_clk'
                        ,'widget_add_clk'
                        ,'icon_page_material_imp'
                        ,'icon_page_material_clk'
                        ,'icon_material_page_install_clk'
                        ,'wallpaper_page_material_imp'
                        ,'wallpaper_page_material_clk'
                        ,'wallpaper_material_download_clk'
                        ,'ai_wallpaper_page_material_imp'
                        ,'ai_wallpaper_page_material_clk'
                        ,'sub_suc')
        and parse_date('%Y%m%d', event_date) <= '2023-09-21'
    union all 
    select 
        parse_date('%Y%m%d', event_date) event_date
        ,event_name
        ,event_params
        ,user_pseudo_id
    from 
        `aiwidget-abc05.analytics_383121217.events_*`
    where 
        event_name in ('theme_page_material_imp'
                        ,'theme_page_material_clk'
                        ,'theme_material_page_set_clk'
                        ,'wallpaper_material_favorite_clk'
                        ,'widget_page_material_imp'
                        ,'widget_material_page_imp'
                        ,'widget_page_material_clk'
                        ,'theme_set_page_clk'
                        ,'widget_add_clk'
                        ,'icon_page_material_imp'
                        ,'icon_page_material_clk'
                        ,'icon_material_page_install_clk'
                        ,'wallpaper_page_material_imp'
                        ,'wallpaper_page_material_clk'
                        ,'wallpaper_material_download_clk'
                        ,'ai_wallpaper_page_material_imp'
                        ,'ai_wallpaper_page_material_clk'
                        ,'sub_suc')
        and parse_date('%Y%m%d', event_date) <= '2023-09-21'
)
,
event as
(
    select
        event_date
        ,event_name
        ,case   when event_name in ('theme_page_material_imp','theme_page_material_clk','theme_material_page_set_clk')
                    or (event_name in ('wallpaper_material_favorite_clk') and material='theme')
                    then 'theme'
                when event_name in ('widget_page_material_imp','widget_material_page_imp','widget_page_material_clk','widget_add_clk')
                    or (event_name in ('theme_set_page_clk') and set_type='widget')
                    or (event_name in ('wallpaper_material_favorite_clk') and material='widget')
                    then 'widget'
                when event_name in ('icon_page_material_imp','icon_page_material_clk','icon_material_page_install_clk')
                    or (event_name in ('wallpaper_material_favorite_clk') and material='icon')
                    then 'icon'
                when event_name in ('wallpaper_page_material_imp','wallpaper_page_material_clk')
                    or (event_name in ('wallpaper_material_download_clk') and material='wallpaper')
                    or (event_name in ('wallpaper_material_favorite_clk') and material='wallpaper' )
                    then 'wallpaper'
                when event_name in ('ai_wallpaper_page_material_imp','ai_wallpaper_page_material_clk')
                    or (event_name in ('wallpaper_material_download_clk') and material='ai_wallpaper')
                    or (event_name in ('wallpaper_material_favorite_clk') and material='ai_wallpaper')
                    then 'ai_wallpaper'
                end material_type
        ,source
        ,material
        ,set_type
        ,coalesce(material_id,internal_material_id) material_id
        ,user_pseudo_id
        ,pv
    from
        (select
            event_date
            ,event_name
            ,func.getParams(event_params,'source').string_value source
            ,func.getParams(event_params,'material_id').string_value material_id
            ,func.getParams(event_params,'material').string_value material
            ,func.getParams(event_params,'set_type').string_value set_type
            ,func.getParams(event_params,'internal_material_id').string_value internal_material_id 
            ,user_pseudo_id
            ,sum(1) pv
        from 
            event_pre
        group by
            1,2,3,4,5,6,7,8)
)

select
    coalesce(s1.event_month, s2.event_month) event_month
    ,coalesce(s1.material_id, s2.material_id) material_id
    ,substr(coalesce(s1.material_id, s2.material_id),4,3) material_type
    ,impression_uv
    ,click_uv
    ,use_uv
    ,favorite_uv
    ,suv_uv
    ,impression_pv
    ,click_pv
    ,use_pv
    ,favorite_pv
    ,suv_pv
from
    (select
        date_trunc(event_date, month) event_month
        ,split_material_id material_id
        -- ,material_type
        ,count(distinct case when event_name in ('theme_page_material_imp','widget_page_material_imp','widget_material_page_imp','icon_page_material_imp','wallpaper_page_material_imp','ai_wallpaper_page_material_imp') then user_pseudo_id end)
            impression_uv
        ,count(distinct case when event_name in ('theme_page_material_clk','widget_page_material_clk','icon_page_material_clk','wallpaper_page_material_clk','ai_wallpaper_page_material_clk') then user_pseudo_id end)
            click_uv
        ,count(distinct case when event_name in ('theme_material_page_set_clk','theme_set_page_clk','widget_add_clk','icon_material_page_install_clk','wallpaper_material_download_clk') then user_pseudo_id end)
            use_uv
        ,count(distinct case when event_name in ('wallpaper_material_favorite_clk') then user_pseudo_id end)
            favorite_uv
        ,sum(case when event_name in ('theme_page_material_imp','widget_page_material_imp','widget_material_page_imp','icon_page_material_imp','wallpaper_page_material_imp','ai_wallpaper_page_material_imp') then pv end)
            impression_pv
        ,sum(case when event_name in ('theme_page_material_clk','widget_page_material_clk','icon_page_material_clk','wallpaper_page_material_clk','ai_wallpaper_page_material_clk') then pv end)
            click_pv
        ,sum(case when event_name in ('theme_material_page_set_clk','theme_set_page_clk','widget_add_clk','icon_material_page_install_clk','wallpaper_material_download_clk') then pv end)
            use_pv
        ,sum(case when event_name in ('wallpaper_material_favorite_clk') then pv end)
            favorite_pv
    from 
        event e
        cross join unnest(split(material_id,',')) split_material_id
    where 
        material_id is not null
        and event_name not in ('sub_suc')
    group by
        1,2) s1
    full outer join    (select
                            date_trunc(event_date, month) event_month
                            ,split_material_id material_id
                            ,count(distinct user_pseudo_id) suv_uv
                            ,sum(pv) suv_pv
                        from
                            event e
                            cross join unnest(split(material_id,',')) split_material_id
                        where
                            event_name in ('sub_suc')
                            and material_id is not null
                        group by
                            1,2) s2 on s1.material_id=s2.material_id and s1.event_month=s2.event_month
    
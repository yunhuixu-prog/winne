-- 点击人数/次数
-- 使用人数/次数
-- 保存人数/次数
-- 订阅人数/次数
-- 积分充值人数/次数
-- 积分消耗人数/次数

-- AI Avatar
with user_active as 
(    --用户标签 新老  活跃 国家
    select
        event_date
        ,app_name
        ,user_pseudo_id
        ,uuid
        ,max(platform)platform
        ,max(app_version) app_version
        ,max(is_UA) is_UA
        ,max(is_new) is_New
        ,max(country) country
    from 
        (select 
            event_date_hk event_date
            ,app_name
            ,platform
            ,user_pseudo_id
            ,uuid
            ,is_new
            ,is_UA
            ,app_version
            ,country
        from 
            `dataintegration-265403.stat.stat_active_advice_detail_d`
        where 
            app_name='Themeu')
    group by 
        1,2,3,4
)

select 
    date
    ,country
    ,is_New
    ,is_UA
    ,platform
    ,count(distinct case when event_name in ('ai_avatar_clk') then e.user_pseudo_id end) click_uv
    ,count(distinct case when (event_name in ('ai_avatar_upload_clk') and action='generate') or (event_name in ('ai_avatar_generated_clk') and action='reupload') then e.user_pseudo_id end) generate_uv
    ,count(distinct case when event_name in ('wallpaper_material_download_clk') and source='ai_avatar' then e.user_pseudo_id end) save_uv
    -- ,count(distinct case when event_name in ('sub_suc') and source='ai_avatar' then e.user_pseudo_id end) sub_suc_uv
from
    (select
        PARSE_DATE('%Y%m%d', event_date) date
        ,event_name
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'action').string_value action
        ,func.getParams(event_params,'sku_type').string_value sku_type
        ,user_pseudo_id
        ,sum(1) pv
    from 
        (select 
            event_date
            ,event_name
            ,event_params
            ,user_pseudo_id
        from 
            `aiwidget-abc05.analytics_383121217.events_intraday_*`
        where 
            event_name in ('ai_avatar_clk','ai_avatar_upload_clk','ai_avatar_generated_clk','wallpaper_material_download_clk','credit_suc','sub_suc')
        union all 
        select 
            event_date
            ,event_name
            ,event_params
            ,user_pseudo_id
        from 
            `aiwidget-abc05.analytics_383121217.events_*`
        where 
            event_name in ('ai_avatar_clk','ai_avatar_upload_clk','ai_avatar_generated_clk','wallpaper_material_download_clk','credit_suc','sub_suc')
        )
    group by 
        1,2,3,4,5,6) e
    left join user_active u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date
group by 
    1,2,3,4,5




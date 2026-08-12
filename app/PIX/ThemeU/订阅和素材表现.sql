-- Theme U 
-- Event表: `aiwidget-abc05.analytics_383121217.events_intraday_*`,`aiwidget-abc05.analytics_383121217.events_*`
-- Duffle表: `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
-- 活跃表: `dataintegration-265403.stat.stat_active_advice_detail_d`
-- 订单表: `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`


-- see all
select 
    date
    ,sum(case when event_name in ('homepage_enter') then pv end) homepage_enter_pv
    ,sum(case when event_name in ('wallpaper_theme_page_enter') then pv end) wallpaper_theme_page_enter_pv
    ,count(distinct case when event_name in ('homepage_enter') then user_pseudo_id end) homepage_enter_uv
    ,count(distinct case when event_name in ('wallpaper_theme_page_enter') then user_pseudo_id end) wallpaper_theme_page_enter_uv
from
    (select
        PARSE_DATE('%Y%m%d', event_date) date
        ,event_name
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
            event_name in ('homepage_enter','wallpaper_theme_page_enter')
        union all 
        select 
            event_date
            ,event_name
            ,event_params
            ,user_pseudo_id
        from 
            `aiwidget-abc05.analytics_383121217.events_*`
        where 
            event_name in ('homepage_enter','wallpaper_theme_page_enter')
        )
    group by 
        1,2,3)
group by 
    1
order by
    1


-- 活跃用户数
select 
    event_date_hk
    ,count(*) active_users
from 
    `dataintegration-265403.stat.stat_active_advice_detail_d`
where 
    app_name='Themeu'
group by
    1
order by
    1


-- 订阅明细
select
    a.standard_order_date
    ,a.subscription_user_type
    ,a.original_order_id
    ,a.order_id
    ,a.uuid
    ,a.sku
    ,a.sku_is_trial
    ,a.payment_price_usd
    ,a.order_status
    ,a.order_expire_date
    ,pre_order_expire_date
    ,standard_order_expire_date
    ,lead(standard_order_date) over(partition by a.original_order_id order by standard_order_date) as next_order_date
    ,lead(order_status) over(partition by a.original_order_id order by standard_order_date) as next_order_status
    ,lead(a.order_id) over(partition by a.original_order_id order by standard_order_date) as next_order_id
    ,lead(a.sku) over(partition by a.original_order_id order by standard_order_date) as next_sku
    ,lead(a.payment_price_usd) over(partition by a.original_order_id order by standard_order_date) as next_payment_price_usd
from 
    `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
where
    order_status != 3
    and app_id='Themeu'


-- 素材使用情况：曝光、收藏、下载
-- wallpaper_material_page_enter	进入壁纸素材详情页
-- wallpaper_material_favorite_clk	壁纸素材点击收藏
-- wallpaper_material_download_clk	壁纸素材点击下载
-- widget_material_page_imp	widget素材详情页展示
-- widget_add_clk	widget素材详情页点击添加
-- widget_done_clk	widget完成点击
with event_pre as
(
    select 
        event_date
        ,event_name
        ,event_params
        ,user_pseudo_id
    from 
        `aiwidget-abc05.analytics_383121217.events_intraday_*`
    where 
        event_name in   ('wallpaper_material_page_enter','wallpaper_material_favorite_clk','wallpaper_material_download_clk'
                        ,'widget_material_page_imp','widget_add_clk','widget_done_clk')
    union all 
    select 
        event_date
        ,event_name
        ,event_params
        ,user_pseudo_id
    from 
        `aiwidget-abc05.analytics_383121217.events_*`
    where 
        event_name in   ('wallpaper_material_page_enter','wallpaper_material_favorite_clk','wallpaper_material_download_clk'
                        ,'widget_material_page_imp','widget_add_clk','widget_done_clk')
)
,
duffle as 
(
    select 
        theme
        ,m_id
        ,c_id
        ,name
        ,icon
        ,paid_type
    from
        `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
    where
        app='ThemeU'
)

select
    a material_id
    ,case   when event_name in ('wallpaper_material_page_enter','wallpaper_material_favorite_clk','wallpaper_material_download_clk') then 'wallpaper'
            when event_name in ('widget_material_page_imp','widget_add_clk','widget_done_clk') then 'widget'
            end material_type

    ,sum(case when event_name in ('wallpaper_material_page_enter','widget_material_page_imp') then pv end) pageimp_pv
    ,sum(case when event_name in ('wallpaper_material_favorite_clk','widget_add_clk') then pv end) favorite_or_add_pv
    ,sum(case when event_name in ('wallpaper_material_download_clk','widget_done_clk') then pv end) download_or_done_pv

    ,count(distinct case when event_name in ('wallpaper_material_page_enter','widget_material_page_imp') then user_pseudo_id end) pageimp_uv
    ,count(distinct case when event_name in ('wallpaper_material_favorite_clk','widget_add_clk') then user_pseudo_id end) favorite_or_add_uv
    ,count(distinct case when event_name in ('wallpaper_material_download_clk','widget_done_clk') then user_pseudo_id end) download_or_done_uv

    ,theme
    ,c_id
    ,name
    ,icon
    ,paid_type
from
    (select
        PARSE_DATE('%Y%m%d', event_date) date
        ,event_name
        ,user_pseudo_id
        ,func.getParams(event_params,'material_id').string_value material_id
        ,count(1) pv
    from 
        event_pre
    group by
        1,2,3,4) e 
    ,unnest(split(material_id,',')) a
    left join duffle d on a=d.m_id
group by 
    material_id
    ,material_type
    ,theme
    ,c_id
    ,name
    ,icon
    ,paid_type






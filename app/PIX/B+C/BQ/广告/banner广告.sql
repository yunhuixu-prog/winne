-- Banner广告
-- ad_banner_fail   Banner广告拉取失败
-- ad_banner_show   拍照完成页顶部banner展示
-- ad_banner_click  拍照完成页顶部banner点击
-- beauty_appr_bd 进入编辑页（路径：编辑/拍照编辑）

with event_pre as
(
    select
        event_date date
        ,version app_version
        ,event_name
        ,event_params
        ,user_pseudo_id
        ,geo.country country  -- 不看coutry这行需要注释
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-10', '2023-12-25', 'beautypluscam', false)
    where
        event_name in   ('beauty_appr_bd'
                        ,'ad_banner_fail'
                        ,'ad_banner_show'
                        ,'ad_banner_click'
                        )
        and version>='7.7.010'
        -- and user_pseudo_id='000036a16359730550cec5582154d316' -- 挑选单个用户测试
)

select
    date
    ,app_version
    ,event_name
    ,case   when event_name='beauty_appr_bd' then '1 进入修图页'
            when event_name='ad_banner_fail' then '2-2 Banner广告拉取失败'
            when event_name='ad_banner_show' then '2-1 Banner广告展示'
            when event_name='ad_banner_click' then '3 Banner广告点击'
    end event_ch_name
    ,case   when event_name in ('ad_banner_show','ad_banner_fail','ad_banner_click') then source
            when event_name in ('beauty_appr_bd') then 'editpage'
            end ads_source
--     ,country  -- 不看coutry这行需要注释
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from
    (select
        date
        ,app_version
        ,event_name
        ,func.getParams(event_params,'source').string_value source
        ,user_pseudo_id
--         ,country  -- 不看coutry这行需要注释
        ,count(1) pv
    from
        event_pre
    group by
        1,2,3,4,5) -- 不看country这里需要减1
group by
    1,2,3,4,5 -- 不看country这里需要减1
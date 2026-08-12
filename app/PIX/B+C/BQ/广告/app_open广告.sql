-- app_open 广告
-- ad_appopen_fill  APP OPEN广告拉取成功
-- ad_appopen_fail  APP OPEN广告拉取失败
-- ad_appopen_show  APP OPEN广告展示
-- ad_appopen_click APP OPEN广告点击

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
        event_name in   ('ad_appopen_fill'
                        ,'ad_appopen_fail'
                        ,'ad_appopen_show'
                        ,'ad_appopen_click'
                        )
        and version>='7.7.010'
        -- and user_pseudo_id='000036a16359730550cec5582154d316' -- 挑选单个用户测试
)

select
    date
    ,app_version
    ,event_name
    ,case   when event_name='ad_appopen_fill' then '1 APP OPEN广告拉取成功'
            when event_name='ad_appopen_fail' then '2-2 APP OPEN广告拉取失败'
            when event_name='ad_appopen_show' then '2-1 APP OPEN广告展示'
            when event_name='ad_appopen_click' then '3 APP OPEN广告点击'
    end event_ch_name
    ,'app open' ads_source -- 修改激励视频广告场景
--     ,country  -- 不看coutry这行需要注释
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from
    (select
        date
        ,app_version
        ,event_name
        ,user_pseudo_id
--         ,country  -- 不看coutry这行需要注释
        ,count(1) pv
    from
        event_pre
    group by
        1,2,3,4) -- 不看country这里需要减1
group by
    1,2,3,4,5 -- 不看country这里需要减1

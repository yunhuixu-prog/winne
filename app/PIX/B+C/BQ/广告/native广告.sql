-- Native 广告
-- ad_native_fail   native广告拉取失败
-- ad_native_show   native广告展示
-- ad_native_click  native广告点击

-- new_user_homepage_impression 进入首页
-- album_impression_bd	修图相册页展示

-- beautifysave_bd	修图保存
-- beautify_done_popup_imp_bd	修图保存&分享页展示（修图完成页底部弹窗展示）

-- puzzle_save_bd	拼图完成页「保存」按钮点击
-- puzzle_done_popup_imp	拼图完成页底部弹窗展示

-- beaueditfeature_back_clk_bd	编辑返回键点击(也有无bd的版本)
-- beaueditfeature_back_pop_imp_bd	编辑页退出弹窗展示(也有无bd的版本)

-- exit_app_clk	点击返回键按钮退出app
-- native_ads_exit_app_clk	退出app全屏native广告「Exit」按钮点击

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
        event_name in   ('ad_native_fail'
                        ,'ad_native_show'
                        ,'ad_native_click'
                        ,'new_user_homepage_impression'
                        ,'album_impression_bd'
                        ,'beautifysave_bd'
                        ,'beautify_done_popup_imp_bd'
                        ,'puzzle_save_bd'
                        ,'puzzle_done_popup_imp'
                        ,'beaueditfeature_back_clk_bd'
                        ,'beaueditfeature_back_pop_imp_bd'
                        ,'exit_app_clk'
                        ,'native_ads_exit_app_clk'
                        )
        and version>='7.7.010'
        -- and user_pseudo_id='000036a16359730550cec5582154d316' -- 挑选单个用户测试
)

select
    date
    ,app_version
    ,event_name
    ,case   when event_name in ('ad_native_show') then '2-1 native广告展示'
            when event_name='ad_native_fail' then '2-2 native广告拉取失败'
            when event_name='ad_native_click' then '3 native广告点击'
            when event_name='new_user_homepage_impression' then '1 进入首页'
            when event_name='album_impression_bd' then '1 进入相册选图页'
            when event_name='beautifysave_bd' then '1-1 编辑页「保存」按钮点击'
            when event_name='beautify_done_popup_imp_bd' then '1-2 编辑保存页底部弹窗展示'
            when event_name='puzzle_save_bd' then '1-1 拼图页「保存」按钮点击'
            when event_name='puzzle_done_popup_imp' then '1-2 拼图保存页底部弹窗展示'
            when event_name='beaueditfeature_back_clk_bd' then '1-1 编辑返回键点击'
            when event_name='beaueditfeature_back_pop_imp_bd' then '1-2 编辑页退出弹窗展示'
            when event_name='exit_app_clk' then '1 点击返回键按钮退出app'
            when event_name='native_ads_exit_app_clk' then '4 退出app全屏native广告「Exit」按钮点击'
    end event_ch_name
    ,case   when event_name in ('ad_native_show','ad_native_fail','ad_native_click') then source
            when event_name in ('new_user_homepage_impression') then 'homepage'
            when event_name in ('album_impression_bd') then 'album_top'
            when event_name in ('beautifysave_bd','beautify_done_popup_imp_bd') then 'edit_save'
            when event_name in ('puzzle_save_bd','puzzle_done_popup_imp') then 'puzzle_save'
            when event_name in ('beaueditfeature_back_clk_bd','beaueditfeature_back_pop_imp_bd') then 'edit_back'
            when event_name in ('exit_app_clk','native_ads_exit_app_clk') then 'exit_app'
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
-- ad_interstitial_fill 插屏广告拉取成功
-- ad_interstitial_fail 插屏广告拉取失败
-- ad_interstitial_show 插屏广告展示（分场景导出，共5个场景）
-- ad_interstitial_click 插屏广告点击（分场景导出，共5个场景）

-- 场景明细如下，详见B+C：所有广告位和弹窗逻辑
-- edit,编辑选图：1-选图页-编辑；2-拍照页-顶部大图编辑
-- beauty_appr_bd 进入编辑页

-- ai_beauty,AI美颜：1-拍照保存页AI美颜；2-编辑页AI美颜
-- beauty_appr_beau_clk_bd 编辑页/拍照编辑页 AI美颜点击(美颜内各功能按钮点击)

-- splash,开屏：1-启动app展示（冷启动/热启动都有）
-- bp_app_start_bd app打开（app启动）

-- edit_save_top,编辑保存：1-编辑器-顶部保存
-- beautifysave_bd

-- takepic_4times,拍照第4次保存：1-拍照-保存；
-- takepic_4times_achieve

-- first_screenshot,首次截屏：1-截屏-关闭出现的引导订阅蒙层

-- resource_loading,资源加载中：1-触发资源加载中提醒"
-- resource_loading_tip

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
        event_name in   ('ad_interstitial_fill'
                        ,'ad_interstitial_fail'
                        ,'ad_interstitial_show'
                        ,'ad_interstitial_click'
                        ,'beauty_appr_bd'
                        ,'beauty_appr_beau_clk_bd'
                        ,'bp_app_start_bd'
                        ,'beautifysave_bd'
                        ,'takepic_4times_achieve'
                        ,'resource_loading_tip'
                        )
        and version>='7.7.010'
        -- and user_pseudo_id='000036a16359730550cec5582154d316' -- 挑选单个用户测试
)
,
event as
(
    select
        *
        ,case   when event_name in  ('ad_interstitial_fill'
                                    ,'ad_interstitial_fail'
                                    ,'ad_interstitial_show'
                                    ,'ad_interstitial_click')
                    then source
                when event_name='beauty_appr_bd'
                    then 'edit' -- edit 编辑选图
                when event_name='beauty_appr_beau_clk_bd'
                    then 'ai_beauty' -- ai_beauty AI美颜
                when event_name='bp_app_start_bd'
                    then 'splash' -- splash 开屏：1-启动app展示（冷启动/热启动都有）
                when event_name='beautifysave_bd'
                    then 'edit_save_top' -- edit_save_top 编辑保存：1-编辑器-顶部保存
                when event_name='takepic_4times_achieve'
                    then 'takepic_4times' -- takepic_4times 拍照第4次保存：1-拍照-保存
--                 when event_name='takepic_4times_achieve'
--                     then 'first_screenshot' -- first_screenshot 首次截屏：1-截屏-关闭出现的引导订阅蒙层
                when event_name='resource_loading_tip'
                    then 'resource_loading' -- resource_loading 资源加载中：1-触发资源加载中提醒
        end ads_source
        ,case   when event_name='ad_interstitial_fill' then '2-1 插屏广告拉取成功'
                when event_name='ad_interstitial_fail' then '2-2 插屏广告拉取失败'
                when event_name='ad_interstitial_show' then '3 插屏广告展示'
                when event_name='ad_interstitial_click' then '4 插屏广告点击'
                when event_name='beauty_appr_bd'
                    then '1 进入编辑页'
                when event_name='beauty_appr_beau_clk_bd'
                    then '1 AI美颜子功能点击'
                when event_name='bp_app_start_bd'
                    then '1 app打开'
                when event_name='beautifysave_bd'
                    then '1 修图保存'
                when event_name='takepic_4times_achieve'
                    then '1 拍照第4次保存'
                when event_name='resource_loading_tip'
                    then '1 触发资源加载中提醒'
        end event_ch_name
    from
        (select
            date
            ,app_version
            ,event_name
            ,func.getParams(event_params,'source').string_value source
            ,func.getParams(event_params,'子功能').string_value beautify_func
--             ,country -- 不看coutry这行需要注释
            ,user_pseudo_id
        from
            event_pre)
)

select
    date
    ,app_version
    ,event_name
    ,event_ch_name
    ,ads_source
    ,beautify_func
--     ,country -- 不看coutry这行需要注释
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from
    (select
        date
        ,app_version
        ,event_name
        ,event_ch_name
        ,ads_source
        ,beautify_func
--         ,country -- 不看coutry这行需要注释
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case    when event_name not in ('ad_interstitial_fill','ad_interstitial_fail') then
    ads_source in ('edit','ai_beauty', 'splash', 'edit_save_top','takepic_4times','first_screenshot','resource_loading')
                else 1=1
        end
    group by
        1,2,3,4,5,6,7) -- 不看country这里需要减1
group by
    1,2,3,4,5,6 -- 不看country这里需要减1
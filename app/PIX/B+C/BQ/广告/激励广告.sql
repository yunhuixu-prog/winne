-- ad_rewardedvideo_fill  激励视频广告拉取成功
-- ad_rewardedvideo_fail  激励视频广告拉取失败
-- ad_rewardedvideo_show  激励视频展示
-- ad_rewardedvideo_click 激励视频点击
-- ad_rewardedvideo_videocomplete 激励视频播放完成
-- ad_rewardedvideo_material_suc  解锁成功
-- ad_rewardedvideo_material_fail 解锁失败
-- source 来源渠道

-- 首页广告任务中心
-- source:homepage_task_get_now
-- homepage_ad_first_popup_imp
-- homepage_ad_first_popup_clk watch

-- source:homepage_task_one_more_pop
-- homepage_ad_one_more_popup_imp
-- homepage_ad_one_more_popup_clk watch

-- source:homepage_task_retain_pop
-- homepage_ad_retain_popup_imp
-- homepage_ad_retain_popup_clk watch

-- source:homepage_task_continue
-- homepage_ad_second_popup_imp
-- homepage_ad_second_popup_clk watch

-- 任务完成
-- homepage_ad_success_popup_imp
-- homepage_ad_success_popup_clk

-- 订阅拦截
-- source:sub_intercept_popup_one
-- sub_intercept_one_popup_imp
-- sub_intercept_one_popup_clk

-- source:sub_intercept_popup_all
-- sub_intercept_all_popup_imp
-- sub_intercept_all_popup_clk

-- 任务完成
-- sub_intercept_success_pop_imp
-- sub_intercept_success_pop_clk

-- 去水印（拉取成功失败取source为no_watermark）
-- source:no_watermark
-- watermark_imp
-- watermark_remove_clk

-- source:no_logo_photo
-- photo_remove_log_clk

-- source:no_logo_save
-- save_without_logo_clk



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
        event_name in   ('ad_rewardedvideo_fill'
                        ,'ad_rewardedvideo_fail'
                        ,'ad_rewardedvideo_show'
                        ,'ad_rewardedvideo_click'
                        ,'ad_rewardedvideo_videocomplete'
                        ,'ad_rewardedvideo_material_suc'
                        ,'ad_rewardedvideo_material_fail'

                        ,'homepage_ad_first_popup_imp'
                        ,'homepage_ad_first_popup_clk'
                        ,'homepage_ad_one_more_popup_imp'
                        ,'homepage_ad_one_more_popup_clk'
                        ,'homepage_ad_retain_popup_imp'
                        ,'homepage_ad_retain_popup_clk'
                        ,'homepage_ad_second_popup_imp'
                        ,'homepage_ad_second_popup_clk'
                        ,'homepage_ad_success_popup_imp'
                        ,'homepage_ad_success_popup_clk'

                        ,'sub_intercept_one_popup_imp'
                        ,'sub_intercept_one_popup_clk'
                        ,'sub_intercept_all_popup_imp'
                        ,'sub_intercept_all_popup_clk'
                        ,'sub_intercept_success_pop_imp'
                        ,'sub_intercept_success_pop_clk'

                        ,'watermark_imp_bd'
                        ,'watermark_remove_clk_bd'
                        ,'photo_remove_log_clk_bd'
                        ,'save_without_logo_clk'
                        )
        and version>='7.7.010'
        -- and user_pseudo_id='000036a16359730550cec5582154d316' -- 挑选单个用户测试
)
,
event as
(
    select
        *
        ,case   when event_name in ('ad_rewardedvideo_fill'
                                    ,'ad_rewardedvideo_fail')
                    and source in ('no_watermark','no_logo_photo','no_logo_save') then 'no_watermark'
                when event_name in ('ad_rewardedvideo_show'
                                    ,'ad_rewardedvideo_click'
                                    ,'ad_rewardedvideo_videocomplete'
                                    ,'ad_rewardedvideo_material_suc'
                                    ,'ad_rewardedvideo_material_fail')
                    and source in ('homepage_task_get_now','homepage_task_one_more_pop','homepage_task_retain_pop','homepage_task_continue') then 'homepage_task'
                when event_name in ('ad_rewardedvideo_show'
                                    ,'ad_rewardedvideo_click'
                                    ,'ad_rewardedvideo_videocomplete'
                                    ,'ad_rewardedvideo_material_suc'
                                    ,'ad_rewardedvideo_material_fail')
                    and source in ('sub_intercept_popup_one','sub_intercept_popup_all') then 'sub_intercept'
                when event_name in ('ad_rewardedvideo_show'
                                    ,'ad_rewardedvideo_click'
                                    ,'ad_rewardedvideo_videocomplete'
                                    ,'ad_rewardedvideo_material_suc'
                                    ,'ad_rewardedvideo_material_fail')
                    and source in ('no_watermark','no_logo_photo','no_logo_save') then 'no_watermark'
                when event_name in ('homepage_ad_first_popup_imp','homepage_ad_one_more_popup_imp','homepage_ad_retain_popup_imp',
                                    'homepage_ad_second_popup_imp','homepage_ad_success_popup_imp','homepage_ad_success_popup_clk')
                    or (event_name in ('homepage_ad_first_popup_clk','homepage_ad_one_more_popup_clk','homepage_ad_retain_popup_clk','homepage_ad_second_popup_clk') and clk='watch')
                    then 'homepage_task'
                when event_name in ('sub_intercept_one_popup_imp')
                    or (event_name in ('sub_intercept_one_popup_clk') and clk='unlock_function')
                    then 'sub_intercept'
                when event_name in ('sub_intercept_all_popup_imp')
                    or (event_name in ('sub_intercept_all_popup_clk') and clk='unlock_all')
                    then 'sub_intercept'
                when event_name in ('watermark_imp_bd','watermark_remove_clk_bd','photo_remove_log_clk_bd','save_without_logo_clk')
                    then 'no_watermark'
        end ads_pre_source

        ,case   when event_name in ('ad_rewardedvideo_fill'
                                    ,'ad_rewardedvideo_fail'
                                    ,'ad_rewardedvideo_show'
                                    ,'ad_rewardedvideo_click'
                                    ,'ad_rewardedvideo_videocomplete'
                                    ,'ad_rewardedvideo_material_suc'
                                    ,'ad_rewardedvideo_material_fail')
                    then source
                when event_name in ('homepage_ad_first_popup_imp')
                    or (event_name in ('homepage_ad_first_popup_clk') and clk='watch')
                    then 'homepage_task_get_now'
                when event_name in ('homepage_ad_one_more_popup_imp')
                    or (event_name in ('homepage_ad_one_more_popup_clk') and clk='watch')
                    then 'homepage_task_one_more_pop'
                when event_name in ('homepage_ad_retain_popup_imp')
                    or (event_name in ('homepage_ad_retain_popup_clk') and clk='watch')
                    then 'homepage_task_retain_pop'
                when event_name in ('homepage_ad_second_popup_imp')
                    or (event_name in ('homepage_ad_second_popup_clk') and clk='watch')
                    then 'homepage_task_continue'
                when event_name in ('homepage_ad_success_popup_imp','homepage_ad_success_popup_clk')
                    then 'homepage_task'

                when event_name in ('sub_intercept_one_popup_imp')
                    or (event_name in ('sub_intercept_one_popup_clk') and clk='unlock_function')
                    then 'sub_intercept_popup_one'
                when event_name in ('sub_intercept_all_popup_imp')
                    or (event_name in ('sub_intercept_all_popup_clk') and clk='unlock_all')
                    then 'sub_intercept_popup_all'

                when event_name in ('watermark_imp_bd','watermark_remove_clk_bd')
                    then 'no_watermark'
                when event_name in ('photo_remove_log_clk_bd')
                    then 'no_logo_photo'
                when event_name in ('save_without_logo_clk')
                    then 'no_logo_save'
        end ads_source

        ,case   when event_name='ad_rewardedvideo_fill' then '2-1 激励视频广告拉取成功'
                when event_name='ad_rewardedvideo_fail' then '2-2 激励视频广告拉取失败'
                when event_name='ad_rewardedvideo_show' then '3 激励视频展示'
                when event_name='ad_rewardedvideo_click' then '4 激励视频点击'
                when event_name='ad_rewardedvideo_videocomplete' then '5 激励视频播放完成'
                when event_name='ad_rewardedvideo_material_suc' then '6 解锁成功'
                when event_name='ad_rewardedvideo_material_fail' then '7 解锁失败'
                when event_name in ('homepage_ad_first_popup_imp') then '1-1 首页广告任务中心第一次弹窗曝光'
                when event_name in ('homepage_ad_first_popup_clk') and clk='watch' then '1-2 首页广告任务中心第一次弹窗点击观看'
                when event_name in ('homepage_ad_one_more_popup_imp') then '1-1 首页广告任务中心余一次弹窗曝光'
                when event_name in ('homepage_ad_one_more_popup_clk') and clk='watch' then '1-2 首页广告任务中心余一次弹窗点击观看'
                when event_name in ('homepage_ad_retain_popup_imp') then '1-1 首页广告任务中心挽留弹窗曝光'
                when event_name in ('homepage_ad_retain_popup_clk') and clk='watch' then '1-2 首页广告任务中心挽留弹窗点击观看'
                when event_name in ('homepage_ad_second_popup_imp') then '1-1 首页广告任务中心第二次弹窗曝光'
                when event_name in ('homepage_ad_second_popup_clk') and clk='watch' then '1-2 首页广告任务中心第二次弹窗点击观看'
                when event_name in ('homepage_ad_success_popup_imp') then '8 首页广告任务中心解锁成功弹窗曝光'
                when event_name in ('homepage_ad_success_popup_clk') then '8 首页广告任务中心解锁成功弹窗点击'

                when event_name in ('sub_intercept_one_popup_imp') then '1-1 订阅拦截弹窗免费应用当前功能弹窗曝光'
                when event_name in ('sub_intercept_one_popup_clk') and clk='unlock_function' then '1-2 订阅拦截弹窗免费应用当前功能弹窗点击unlock_function'
                when event_name in ('sub_intercept_all_popup_imp') then '1-1 订阅拦截弹窗免费应用所有功能弹窗曝光'
                when event_name in ('sub_intercept_all_popup_clk') and clk='unlock_all' then '1-2 订阅拦截弹窗免费应用所有功能弹窗点击unlock_all'
                when event_name in ('sub_intercept_success_pop_imp') then '8 订阅拦截解锁成功弹窗曝光'
                when event_name in ('sub_intercept_success_pop_clk') then '8 订阅拦截解锁成功弹窗点击'

                when event_name in ('watermark_imp_bd') then '1-1 去水印展示'
                when event_name in ('watermark_remove_clk_bd') then '1-2 去水印点击'
                when event_name in ('photo_remove_log_clk_bd') then '1 拍照页去水印按钮点击'
                when event_name in ('save_without_logo_clk') then '1 编辑保存页去水印按钮点击'
        end event_ch_name
    from
        (select
            date
            ,app_version
            ,event_name
            ,func.getParams(event_params,'source').string_value source
            ,func.getParams(event_params,'clk').string_value clk
--             ,country
            ,user_pseudo_id
        from
            event_pre)
)

select
    date
    ,app_version
    ,event_name
    ,event_ch_name
    ,ads_pre_source
    ,ads_source
--     ,country
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from
    (select
        date
        ,app_version
        ,event_name
        ,event_ch_name
        ,ads_pre_source
        ,ads_source
        ,user_pseudo_id
--         ,country  -- 不看coutry这行需要注释
        ,count(1) pv
    from
        event
    where
        case    when event_name not in ('ad_rewardedvideo_fill','ad_rewardedvideo_fail') then ads_pre_source in ('homepage_task','sub_intercept','no_watermark')
                else 1=1
        end
    group by
        1,2,3,4,5,6,7) -- 不看country这里需要减1
group by
    1,2,3,4,5,6 -- 不看country这里需要减1

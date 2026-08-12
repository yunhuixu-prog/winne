-- beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_bq_test_v
-- 划分标准：订阅率

select date,region
        -- 分层指标
        ,sub_type
        ,is_active_7
        ,is_edit_selfi_7
        ,is_active_30
        ,is_edit_selfi_30
        ,is_active_60
        ,is_edit_selfi_60
        ,is_active_90
        ,is_edit_selfi_90

        ,active_days_90d_type
         ,install_days_type
         ,last_active_days_type
        -- 历史订阅信息
        ,is_current_trial,current_trial_day,is_current_subscription_cancelled
        ,past_sub_times,trial_times,cancel_subscription_times,refund_subscription_times,promotional_paying_times
        -- 预测指标
        ,sub_365,sub_90
        ,is_new
        ,is_ua
        ,platform
        ,brand
        ,model_1
       ,model_2
        --media_source,operating_system
        ,install_days,life_time_active_days,last_active_days
        ,active_mins_90d,active_sessions_90d,active_mins_7d,active_sessions_7d,active_days_90d,active_days_7d,active_days_60,active_days_30,active_days_14
        ,active_category
        ,`pv_0级tab-修图---保存`,`pv_0级tab-修图---进入`,`pv_0级tab-拍摄---保存`,`pv_0级tab-拍摄---拍摄`,`pv_0级tab-电影---保存`,`pv_0级tab-电影---拍摄`,`pv_0级tab-自拍---进入`,`pv_0级tab-视频---保存`,`pv_0级tab-视频---拍摄`,`pv_0级tab-视频编辑---保存`,`pv_0级tab-视频编辑---进入`,`pv_1级tab-修图-创意--保存`,`pv_1级tab-修图-创意--点击`,`pv_1级tab-修图-滤镜--保存`,`pv_1级tab-修图-滤镜--点击`,`pv_1级tab-修图-编辑--保存`,`pv_1级tab-修图-编辑--点击`,`pv_1级tab-修图-美妆--保存`,`pv_1级tab-修图-美妆--点击`,`pv_1级tab-修图-美颜--保存`,`pv_1级tab-修图-美颜--点击`,`pv_1级tab-修图-高级编辑--点击`,`pv_1级tab-拍摄-AR--保存`,`pv_1级tab-拍摄-AR--拍摄`,`pv_1级tab-拍摄-Look--保存`,`pv_1级tab-拍摄-Look--拍摄`,`pv_1级tab-拍摄-滤镜--保存`,`pv_1级tab-拍摄-滤镜--拍摄`,`pv_1级tab-拍摄-美妆--保存`,`pv_1级tab-拍摄-美妆--拍摄`,`pv_1级tab-拍摄-美颜--保存`

        ,`pv_0级tab-修图---保存_30`,`pv_0级tab-修图---进入_30`,`pv_0级tab-拍摄---保存_30`,`pv_0级tab-拍摄---拍摄_30`,`pv_0级tab-电影---保存_30`,`pv_0级tab-电影---拍摄_30`,`pv_0级tab-自拍---进入_30`,`pv_0级tab-视频---保存_30`,`pv_0级tab-视频---拍摄_30`,`pv_0级tab-视频编辑---保存_30`,`pv_0级tab-视频编辑---进入_30`,`pv_1级tab-修图-创意--保存_30`,`pv_1级tab-修图-创意--点击_30`,`pv_1级tab-修图-滤镜--保存_30`,`pv_1级tab-修图-滤镜--点击_30`,`pv_1级tab-修图-编辑--保存_30`,`pv_1级tab-修图-编辑--点击_30`,`pv_1级tab-修图-美妆--保存_30`,`pv_1级tab-修图-美妆--点击_30`,`pv_1级tab-修图-美颜--保存_30`,`pv_1级tab-修图-美颜--点击_30`,`pv_1级tab-修图-高级编辑--点击_30`,`pv_1级tab-拍摄-AR--保存_30`,`pv_1级tab-拍摄-AR--拍摄_30`,`pv_1级tab-拍摄-Look--保存_30`,`pv_1级tab-拍摄-Look--拍摄_30`,`pv_1级tab-拍摄-滤镜--保存_30`,`pv_1级tab-拍摄-滤镜--拍摄_30`,`pv_1级tab-拍摄-美妆--保存_30`,`pv_1级tab-拍摄-美妆--拍摄_30`,`pv_1级tab-拍摄-美颜--保存_30`
        ,`pv_0级tab-修图---保存_60`,`pv_0级tab-修图---进入_60`,`pv_0级tab-拍摄---保存_60`,`pv_0级tab-拍摄---拍摄_60`,`pv_0级tab-电影---保存_60`,`pv_0级tab-电影---拍摄_60`,`pv_0级tab-自拍---进入_60`,`pv_0级tab-视频---保存_60`,`pv_0级tab-视频---拍摄_60`,`pv_0级tab-视频编辑---保存_60`,`pv_0级tab-视频编辑---进入_60`,`pv_1级tab-修图-创意--保存_60`,`pv_1级tab-修图-创意--点击_60`,`pv_1级tab-修图-滤镜--保存_60`,`pv_1级tab-修图-滤镜--点击_60`,`pv_1级tab-修图-编辑--保存_60`,`pv_1级tab-修图-编辑--点击_60`,`pv_1级tab-修图-美妆--保存_60`,`pv_1级tab-修图-美妆--点击_60`,`pv_1级tab-修图-美颜--保存_60`,`pv_1级tab-修图-美颜--点击_60`,`pv_1级tab-修图-高级编辑--点击_60`,`pv_1级tab-拍摄-AR--保存_60`,`pv_1级tab-拍摄-AR--拍摄_60`,`pv_1级tab-拍摄-Look--保存_60`,`pv_1级tab-拍摄-Look--拍摄_60`,`pv_1级tab-拍摄-滤镜--保存_60`,`pv_1级tab-拍摄-滤镜--拍摄_60`,`pv_1级tab-拍摄-美妆--保存_60`,`pv_1级tab-拍摄-美妆--拍摄_60`,`pv_1级tab-拍摄-美颜--保存_60`
        ,`pv_0级tab-修图---保存_90`,`pv_0级tab-修图---进入_90`,`pv_0级tab-拍摄---保存_90`,`pv_0级tab-拍摄---拍摄_90`,`pv_0级tab-电影---保存_90`,`pv_0级tab-电影---拍摄_90`,`pv_0级tab-自拍---进入_90`,`pv_0级tab-视频---保存_90`,`pv_0级tab-视频---拍摄_90`,`pv_0级tab-视频编辑---保存_90`,`pv_0级tab-视频编辑---进入_90`,`pv_1级tab-修图-创意--保存_90`,`pv_1级tab-修图-创意--点击_90`,`pv_1级tab-修图-滤镜--保存_90`,`pv_1级tab-修图-滤镜--点击_90`,`pv_1级tab-修图-编辑--保存_90`,`pv_1级tab-修图-编辑--点击_90`,`pv_1级tab-修图-美妆--保存_90`,`pv_1级tab-修图-美妆--点击_90`,`pv_1级tab-修图-美颜--保存_90`,`pv_1级tab-修图-美颜--点击_90`,`pv_1级tab-修图-高级编辑--点击_90`,`pv_1级tab-拍摄-AR--保存_90`,`pv_1级tab-拍摄-AR--拍摄_90`,`pv_1级tab-拍摄-Look--保存_90`,`pv_1级tab-拍摄-Look--拍摄_90`,`pv_1级tab-拍摄-滤镜--保存_90`,`pv_1级tab-拍摄-滤镜--拍摄_90`,`pv_1级tab-拍摄-美妆--保存_90`,`pv_1级tab-拍摄-美妆--拍摄_90`,`pv_1级tab-拍摄-美颜--保存_90`

        ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click
        ,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click
        ,max_impression_pv,impression_pv,click_pv

        ,aigc_enter_pv_30,aigc_use_pv_30,aigc_save_pv_30,pop_exposure_30,pop_click_30
        ,content_exposure_30,content_click_30,max_module_positon_30,sub_page_enter_30,sub_page_click_30
        ,max_impression_pv_30,impression_pv_30,click_pv_30

        ,aigc_enter_pv_60,aigc_use_pv_60,aigc_save_pv_60,pop_exposure_60,pop_click_60
        ,content_exposure_60,content_click_60,max_module_positon_60,sub_page_enter_60,sub_page_click_60
        ,max_impression_pv_60,impression_pv_60,click_pv_60

        ,aigc_enter_pv_90,aigc_use_pv_90,aigc_save_pv_90,pop_exposure_90,pop_click_90
        ,content_exposure_90,content_click_90,max_module_positon_90,sub_page_enter_90,sub_page_click_90
        ,max_impression_pv_90,impression_pv_90,click_pv_90

        ,puzzle_click_pv,puzzle_save_pv,puzzle_click_pv_30,puzzle_save_pv_30,puzzle_click_pv_60,puzzle_save_pv_60,puzzle_click_pv_90,puzzle_save_pv_90

        ,pay_function_click_pv,free_function_click_pv,free_function_save_pv
        ,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
        ,pay_function_click_pv_30,free_function_click_pv_30,free_function_save_pv_30
        ,pay_function_click_pv_60,free_function_click_pv_60,free_function_save_pv_60
        ,pay_function_click_pv_90,free_function_click_pv_90,free_function_save_pv_90
        ,pay_duffle_click_pv_30,free_duffle_click_pv_30,free_duffle_save_pv_30
        ,pay_duffle_click_pv_60,free_duffle_click_pv_60,free_duffle_save_pv_60
        ,pay_duffle_click_pv_90,free_duffle_click_pv_90,free_duffle_save_pv_90
        ,save_beauty_ratio
        ,enter_beauty_ratio
        ,beauty_enter_to_save_ratio
         ,save_beauty_ratio_30
        ,enter_beauty_ratio_30
        ,beauty_enter_to_save_ratio_30

         ,save_beauty_ratio_60
        ,enter_beauty_ratio_60
        ,beauty_enter_to_save_ratio_60

         ,save_beauty_ratio_90
        ,enter_beauty_ratio_90
        ,beauty_enter_to_save_ratio_90

        ,function_num_type
        ,function_num_pre_type
        ,grow_function_num_type
        ,function_num_30,function_num_60,function_num_90
        ,pay_duffle_click_ratio_type

        ,pay_duffle_click_ratio_30
         ,pay_duffle_click_ratio_60
         ,pay_duffle_click_ratio_90

        ,pay_function_click_ratio_type

        ,pay_function_click_ratio_30
         ,pay_function_click_ratio_60
         ,pay_function_click_ratio_90

        ,life_time_active_ratio

        ,pop_click_ratio
        ,content_click_ratio

        ,pop_click_ratio_30
        ,content_click_ratio_30
        ,pop_click_ratio_60
        ,content_click_ratio_60
        ,pop_click_ratio_90
        ,content_click_ratio_90

        ,sub_page_click_ratio_type

         ,sub_page_click_ratio_30
         ,sub_page_click_ratio_60
         ,sub_page_click_ratio_90

--         ,homepage_exposure_pv,homepage_click_pv
--         ,homepage_feature_show_pv,homepage_feature_click_pv,homepage_banner_show_pv,homepage_banner_click_pv
--         ,homepage_reconmend_show_pv,homepage_reconmend_click_pv
--         ,homepage_topic_show_pv,homepage_topic_click_pv,homepage_miniapp_show_pv,homepage_miniapp_click_pv
--
--         ,homepage_exposure_pv_30,homepage_click_pv_30
--         ,homepage_feature_show_pv_30,homepage_feature_click_pv_30,homepage_banner_show_pv_30,homepage_banner_click_pv_30
--         ,homepage_reconmend_show_pv_30,homepage_reconmend_click_pv_30
--         ,homepage_topic_show_pv_30,homepage_topic_click_pv_30,homepage_miniapp_show_pv_30,homepage_miniapp_click_pv_30
--
--         ,homepage_exposure_pv_60,homepage_click_pv_60
--         ,homepage_feature_show_pv_60,homepage_feature_click_pv_60,homepage_banner_show_pv_60,homepage_banner_click_pv_60
--         ,homepage_reconmend_show_pv_60,homepage_reconmend_click_pv_60
--         ,homepage_topic_show_pv_60,homepage_topic_click_pv_60,homepage_miniapp_show_pv_60,homepage_miniapp_click_pv_60
--
--         ,homepage_exposure_pv_90,homepage_click_pv_90
--         ,homepage_feature_show_pv_90,homepage_feature_click_pv_90,homepage_banner_show_pv_90,homepage_banner_click_pv_90
--         ,homepage_reconmend_show_pv_90,homepage_reconmend_click_pv_90
--         ,homepage_topic_show_pv_90,homepage_topic_click_pv_90,homepage_miniapp_show_pv_90,homepage_miniapp_click_pv_90

from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_v


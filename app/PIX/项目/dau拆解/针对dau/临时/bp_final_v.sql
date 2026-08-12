-- beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v

select date,user_pseudo_id
        ,case when permanent_country in ('United States','Japan','United Kingdom','South Korea','Thailand') then permanent_country else 'else' end region
--         ,case when date<'2024-01-01' and is_current_trial_pre = 1 then 'trial_now'
--              when date<'2024-01-01' then 'else'
--              when is_current_trial = 1 then 'trial_now'
--              when past_sub_times-trial_times>0 then 'sub_his'
--              when trial_times>0 then 'trial_his'
--              else 'else'
--         end sub_type
        ,case when is_current_trial = 1 then 'trial_now'
             when past_sub_times-trial_times>0 then 'sub_his'
             when trial_times>0 then 'trial_his'
             else 'else'
        end sub_type
        -- 分层指标
        ,case when active_days_90d <= 3 then 1
             when active_days_90d <= 7 then 2
             when active_days_90d <= 12 then 3
             when active_days_90d <= 18 then 4
             when active_days_90d <= 25 then 5
             when active_days_90d <= 35 then 6
             when active_days_90d <= 50 then 7
             when active_days_90d <= 70 then 8
             else 9
        end active_days_90d_type
        -- 仅2024有
        ,is_current_trial,current_trial_day,is_current_subscription_cancelled
        ,past_sub_times,trial_times,cancel_subscription_times,refund_subscription_times,promotional_paying_times
        -- 预测指标
        ,sub_365,sub_90
        ,is_new,is_ua,platform,brand --media_source,model,operating_system
        ,install_days+1 install_days,life_time_active_days
        ,active_mins_90d,active_sessions_90d,active_mins_7d,active_sessions_7d,active_days_90d,active_days_7d,active_days_60,active_days_30,active_days_14
        ,active_category
--         ,round(active_mins_90d/least(90,coalesce(install_days+1,0)),2) active_mins_90d_per
--         ,round(active_sessions_90d/least(90,coalesce(install_days+1,0)),2) active_sessions_90d_per
--         ,round(active_mins_7d/least(7,coalesce(install_days+1,0)),2) active_mins_7d_per
--         ,round(active_sessions_7d/least(7,coalesce(install_days+1,0)),2) active_sessions_7d_per
--         ,round(active_days_90d/least(90,coalesce(install_days+1,0)),2) active_days_90d_per
--         ,round(active_days_7d/least(7,coalesce(install_days+1,0)),2) active_days_7d_per
--         ,round(active_days_60/least(60,coalesce(install_days+1,0)),2) active_days_60_per
--         ,round(active_days_30/least(30,coalesce(install_days+1,0)),2) active_days_30_per
--         ,round(active_days_14/least(14,coalesce(install_days+1,0)),2) active_days_14_per
--         ,`pv_0级tab-修图---保存`,`pv_0级tab-修图---进入`,`pv_0级tab-拍摄---保存`,`pv_0级tab-拍摄---拍摄`,`pv_0级tab-电影---保存`,`pv_0级tab-电影---拍摄`,`pv_0级tab-自拍---进入`,`pv_0级tab-视频---保存`,`pv_0级tab-视频---拍摄`,`pv_0级tab-视频编辑---保存`,`pv_0级tab-视频编辑---进入`,`pv_1级tab-修图-创意--保存`,`pv_1级tab-修图-创意--点击`,`pv_1级tab-修图-滤镜--保存`,`pv_1级tab-修图-滤镜--点击`,`pv_1级tab-修图-编辑--保存`,`pv_1级tab-修图-编辑--点击`,`pv_1级tab-修图-美妆--保存`,`pv_1级tab-修图-美妆--点击`,`pv_1级tab-修图-美颜--保存`,`pv_1级tab-修图-美颜--点击`,`pv_1级tab-修图-高级编辑--点击`,`pv_1级tab-拍摄-AR--保存`,`pv_1级tab-拍摄-AR--拍摄`,`pv_1级tab-拍摄-Look--保存`,`pv_1级tab-拍摄-Look--拍摄`,`pv_1级tab-拍摄-滤镜--保存`,`pv_1级tab-拍摄-滤镜--拍摄`,`pv_1级tab-拍摄-美妆--保存`,`pv_1级tab-拍摄-美妆--拍摄`,`pv_1级tab-拍摄-美颜--保存`
        ,`pv_0级tab-修图---保存`,`pv_0级tab-修图---进入`,`pv_0级tab-拍摄---保存`,`pv_0级tab-拍摄---拍摄`,`pv_0级tab-电影---保存`,`pv_0级tab-电影---拍摄`,`pv_0级tab-自拍---进入`,`pv_0级tab-视频---保存`,`pv_0级tab-视频---拍摄`,`pv_0级tab-视频编辑---保存`,`pv_0级tab-视频编辑---进入`,`pv_1级tab-修图-创意--保存`,`pv_1级tab-修图-创意--点击`,`pv_1级tab-修图-滤镜--保存`,`pv_1级tab-修图-滤镜--点击`,`pv_1级tab-修图-编辑--保存`,`pv_1级tab-修图-编辑--点击`,`pv_1级tab-修图-美妆--保存`,`pv_1级tab-修图-美妆--点击`,`pv_1级tab-修图-美颜--保存`,`pv_1级tab-修图-美颜--点击`,`pv_1级tab-修图-高级编辑--点击`,`pv_1级tab-拍摄-AR--保存`,`pv_1级tab-拍摄-AR--拍摄`,`pv_1级tab-拍摄-Look--保存`,`pv_1级tab-拍摄-Look--拍摄`,`pv_1级tab-拍摄-滤镜--保存`,`pv_1级tab-拍摄-滤镜--拍摄`,`pv_1级tab-拍摄-美妆--保存`,`pv_1级tab-拍摄-美妆--拍摄`,`pv_1级tab-拍摄-美颜--保存`
--         ,`pv_2级tab-修图-创意-文字-保存`,`pv_2级tab-修图-创意-文字-点击`,`pv_2级tab-修图-创意-涂鸦笔-保存`,`pv_2级tab-修图-创意-涂鸦笔-点击`,`pv_2级tab-修图-创意-背景-保存`,`pv_2级tab-修图-创意-背景-点击`,`pv_2级tab-修图-创意-贴纸-保存`,`pv_2级tab-修图-创意-贴纸-点击`,`pv_2级tab-修图-创意-配方-保存`,`pv_2级tab-修图-创意-配方-点击`,`pv_2级tab-修图-编辑-AI增强-保存`,`pv_2级tab-修图-编辑-AI增强-点击`,`pv_2级tab-修图-编辑-AI扩展-保存`,`pv_2级tab-修图-编辑-AI扩展-点击`,`pv_2级tab-修图-编辑-AR-保存`,`pv_2级tab-修图-编辑-AR-点击`,`pv_2级tab-修图-编辑-分身-保存`,`pv_2级tab-修图-编辑-分身-点击`,`pv_2级tab-修图-编辑-抠图-保存`,`pv_2级tab-修图-编辑-抠图-点击`,`pv_2级tab-修图-编辑-构图-保存`,`pv_2级tab-修图-编辑-构图-点击`,`pv_2级tab-修图-编辑-消除笔-保存`,`pv_2级tab-修图-编辑-消除笔-点击`,`pv_2级tab-修图-编辑-照片修复-保存`,`pv_2级tab-修图-编辑-照片修复-点击`,`pv_2级tab-修图-编辑-色散-保存`,`pv_2级tab-修图-编辑-色散-点击`,`pv_2级tab-修图-编辑-虚化-保存`,`pv_2级tab-修图-编辑-虚化-点击`,`pv_2级tab-修图-编辑-调整-点击`,`pv_2级tab-修图-编辑-风格化-保存`,`pv_2级tab-修图-编辑-风格化-点击`,`pv_2级tab-修图-编辑-马赛克-保存`,`pv_2级tab-修图-编辑-马赛克-点击`
        ,`pv_2级tab-修图-美颜-AI美颜-保存`,`pv_2级tab-修图-美颜-AI美颜-点击`,`pv_2级tab-修图-美颜-一键美颜-保存`,`pv_2级tab-修图-美颜-一键美颜-点击`,`pv_2级tab-修图-美颜-五官立体-保存`,`pv_2级tab-修图-美颜-五官立体-点击`,`pv_2级tab-修图-美颜-亮眼-保存`,`pv_2级tab-修图-美颜-亮眼-点击`,`pv_2级tab-修图-美颜-匀肤-保存`,`pv_2级tab-修图-美颜-匀肤-点击`,`pv_2级tab-修图-美颜-去油光-保存`,`pv_2级tab-修图-美颜-去油光-点击`,`pv_2级tab-修图-美颜-塑形-保存`,`pv_2级tab-修图-美颜-塑形-点击`,`pv_2级tab-修图-美颜-淡化黑眼圈-保存`,`pv_2级tab-修图-美颜-淡化黑眼圈-点击`,`pv_2级tab-修图-美颜-牙齿矫正-保存`,`pv_2级tab-修图-美颜-牙齿矫正-点击`,`pv_2级tab-修图-美颜-牙齿美白-保存`,`pv_2级tab-修图-美颜-牙齿美白-点击`,`pv_2级tab-修图-美颜-瘦脸-保存`,`pv_2级tab-修图-美颜-瘦脸-点击`,`pv_2级tab-修图-美颜-眼睛放大-保存`,`pv_2级tab-修图-美颜-眼睛放大-点击`,`pv_2级tab-修图-美颜-磨皮-保存`,`pv_2级tab-修图-美颜-磨皮-点击`,`pv_2级tab-修图-美颜-祛双下巴-保存`,`pv_2级tab-修图-美颜-祛双下巴-点击`,`pv_2级tab-修图-美颜-祛痘-保存`,`pv_2级tab-修图-美颜-祛痘-点击`,`pv_2级tab-修图-美颜-祛皱-保存`,`pv_2级tab-修图-美颜-祛皱-点击`,`pv_2级tab-修图-美颜-细节-保存`,`pv_2级tab-修图-美颜-细节-点击`,`pv_2级tab-修图-美颜-缩头-保存`,`pv_2级tab-修图-美颜-缩头-点击`,`pv_2级tab-修图-美颜-缩小鼻翼-保存`,`pv_2级tab-修图-美颜-缩小鼻翼-点击`,`pv_2级tab-修图-美颜-美发-保存`,`pv_2级tab-修图-美颜-美发-点击`,`pv_2级tab-修图-美颜-肤色-保存`,`pv_2级tab-修图-美颜-肤色-点击`,`pv_2级tab-修图-美颜-表情-保存`,`pv_2级tab-修图-美颜-表情-点击`,`pv_2级tab-修图-美颜-面部打光-保存`,`pv_2级tab-修图-美颜-面部打光-点击`,`pv_2级tab-修图-美颜-面部重塑-保存`,`pv_2级tab-修图-美颜-面部重塑-点击`
--         ,`pv_2级tab-拍摄-美妆-修容-保存`,`pv_2级tab-拍摄-美妆-修容-拍摄`,`pv_2级tab-拍摄-美妆-卧蚕-保存`,`pv_2级tab-拍摄-美妆-卧蚕-拍摄`,`pv_2级tab-拍摄-美妆-口红-保存`,`pv_2级tab-拍摄-美妆-口红-拍摄`,`pv_2级tab-拍摄-美妆-染发-保存`,`pv_2级tab-拍摄-美妆-染发-拍摄`,`pv_2级tab-拍摄-美妆-眉毛-保存`,`pv_2级tab-拍摄-美妆-眉毛-拍摄`,`pv_2级tab-拍摄-美妆-眼影-保存`,`pv_2级tab-拍摄-美妆-眼影-拍摄`,`pv_2级tab-拍摄-美妆-睫毛-保存`,`pv_2级tab-拍摄-美妆-睫毛-拍摄`,`pv_2级tab-拍摄-美妆-美瞳-保存`,`pv_2级tab-拍摄-美妆-美瞳-拍摄`,`pv_2级tab-拍摄-美妆-腮红-保存`,`pv_2级tab-拍摄-美妆-腮红-拍摄`,`pv_2级tab-拍摄-美妆-雀斑-保存`,`pv_2级tab-拍摄-美妆-雀斑-拍摄`,`pv_2级tab-拍摄-美颜-一键美型-保存`,`pv_2级tab-拍摄-美颜-亮眼-保存`,`pv_2级tab-拍摄-美颜-大眼-保存`,`pv_2级tab-拍摄-美颜-柔发-保存`,`pv_2级tab-拍摄-美颜-瘦脸-保存`,`pv_2级tab-拍摄-美颜-瘦鼻-保存`,`pv_2级tab-拍摄-美颜-磨皮-保存`,`pv_2级tab-拍摄-美颜-祛斑祛痘-保存`,`pv_2级tab-拍摄-美颜-祛法令纹-保存`,`pv_2级tab-拍摄-美颜-祛黑眼圈-保存`,`pv_2级tab-拍摄-美颜-缩头-保存`,`pv_2级tab-拍摄-美颜-美白牙齿-保存`,`pv_2级tab-拍摄-美颜-肤色-保存`
        ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click,max_impression_pv,impression_pv,click_pv
--         ,grow_aigc_enter_pv,grow_aigc_use_pv,grow_aigc_save_pv,grow_pop_exposure,grow_pop_click,grow_content_exposure,grow_content_click,grow_max_module_positon,grow_sub_page_enter,grow_sub_page_click,grow_max_impression_pv,grow_impression_pv,grow_click_pv
        ,puzzle_click_pv,puzzle_save_pv,pay_function_click_pv,free_function_click_pv,free_function_save_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
--         ,grow_pay_function_click_pv,grow_free_function_click_pv,grow_free_function_save_pv,grow_pay_duffle_click_pv,grow_free_duffle_click_pv,grow_free_duffle_save_pv
        ,function_num,function_num_pre,grow_function_num
--         ,grow_edit_enter_pv,grow_edit_save_pv,grow_take_photo_pv,grow_take_photo_save_pv,grow_selftake_enter_pv,grow_take_video_pv,grow_take_video_save_pv
        ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
               else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
         end pay_duffle_click_ratio

        ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
               else coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0))
         end pay_function_click_ratio
        ,case when coalesce(install_days+1,0)=0 then null
               else coalesce(life_time_active_days,0)/coalesce(install_days+1,0)
         end life_time_active_ratio

        ,case when coalesce(pop_exposure,0)=0 then null
               else round(coalesce(pop_click,0)/coalesce(pop_exposure,0),4)
         end pop_click_ratio
         ,case when coalesce(content_exposure,0)=0 then null
               else round(coalesce(content_click,0)/coalesce(content_exposure,0),4)
         end content_click_ratio
         ,case when coalesce(sub_page_enter,0)=0 then null
               else round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4)
         end sub_page_click_ratio

from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
where is_paying='un-Paying' and is_consum='un-consumable'


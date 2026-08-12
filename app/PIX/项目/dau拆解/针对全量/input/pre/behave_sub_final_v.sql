-- beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
-- 划分标准：订阅率

select date,uuid,bucket
        ,case when permanent_country in ('Nigeria','India','Iran','Pakistan','Egypt','Cambodia','Bangladesh','Myanmar (Burma)') then 1
             when permanent_country in ('Indonesia','Thailand','Philippines','Mexico','Malaysia','United Arab Emirates','France','Peru'
                ,'Saudi Arabia','Colombia','Taiwan','Russia','Argentina','Hong Kong','South Africa','Dominican Republic'
                ,'Greece','Kuwait','Ukraine','Azerbaijan','Serbia','Ecuador','Lebanon','Hungary','Jordan','Kazakhstan') then 2
             when permanent_country in ('Vietnam','Japan','Turkey','South Korea','Brazil','United Kingdom','Germany','Singapore','Spain','Italy'
                ,'Netherlands','Chile','Romania','Belgium','Poland','Cyprus','Portugal','Sweden') then 3
             when permanent_country in ('United States','Canada','Australia','Israel','Switzerland','Austria') then 4
             when permanent_country in ('Türkiye') then 5
             else 2
         end region
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
         ,case
               when install_days between 1 and 3 then 1
               when install_days between 4 and 7 then 2
               when install_days between 8 and 14 then 3
               when install_days between 15 and 30 then 4
               when install_days between 31 and 60 then 5
               when install_days between 61 and 90 then 6
               when install_days between 91 and 180 then 7
               when install_days between 181 and 365 then 8
               when install_days between 366 and 730 then 9
               else 10
         end install_days_type
--          ,case
--                when install_days between 1 and 7 then install_days
--                when install_days between 8 and 14 then 8
--                when install_days between 15 and 30 then 9
--                when install_days between 31 and 60 then 10
--                when install_days between 61 and 90 then 11
--                when install_days between 91 and 180 then 12
--                when install_days between 181 and 365 then 13
--                when install_days between 366 and 730 then 14
--                else 15
--          end install_days_type
         ,case when last_active_days+1 between 1 and 3 then 1
               when last_active_days+1 between 4 and 7 then 2
               when last_active_days+1 between 8 and 14 then 3
               when last_active_days+1 between 15 and 30 then 4
               when last_active_days+1 between 31 and 60 then 5
               when last_active_days+1 between 61 and 90 then 6
               when last_active_days+1 between 91 and 180 then 7
               when last_active_days+1 between 181 and 365 then 8
               when last_active_days+1 between 366 and 730 then 9
               else 10
         end last_active_days_type
        ,if(last_active_days>=7,0,1) is_active_7
        ,if(coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)>0,1,0) is_edit_selfi_7
        ,if(last_active_days>=30,0,1) is_active_30
        ,if(coalesce(`pv_0级tab-修图---进入_30`,0)+coalesce(`pv_0级tab-自拍---进入_30`,0)>0,1,0) is_edit_selfi_30
        ,if(last_active_days>=60,0,1) is_active_60
        ,if(coalesce(`pv_0级tab-修图---进入_60`,0)+coalesce(`pv_0级tab-自拍---进入_60`,0)>0,1,0) is_edit_selfi_60
        ,if(last_active_days>=90,0,1) is_active_90
        ,if(coalesce(`pv_0级tab-修图---进入_90`,0)+coalesce(`pv_0级tab-自拍---进入_90`,0)>0,1,0) is_edit_selfi_90

        -- 历史订阅信息
        ,is_current_trial,current_trial_day,is_current_subscription_cancelled
        ,past_sub_times,trial_times,cancel_subscription_times,refund_subscription_times,promotional_paying_times
        -- 预测指标
        ,sub_365,sub_90,sub_30,sub_7
        ,active_365,active_90,active_30,active_7
        ,is_new
        ,if(is_ua='non-Organic',1,2) is_ua
        ,if(platform='ANDROID',1,2) platform
--         ,android_level -- 没值
        ,case when brand in ('Infinix','Tecno','itel','Nokia') then 2
            when brand in ('Vivo','Realme','Huawei','LG','Lenovo') then 3
            when brand in ('OPPO','Xiaomi','OnePlus') then 4
            when brand in ('Samsung','Sharp','Honor','POCO') then 5
            when brand in ('Sony') then 6
            when brand in ('Motorola','Google') then 7
            when brand in ('Apple') then 8
            when brand in ('Epik') then 9
            else 3
         end brand
        ,case when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('4s','4','4c') then 4
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('5s','5','5c') then 5
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('6s','6','6c') then 6
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('7s','7','7c') then 7
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('8s','8','8c') then 8
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('SE','XR','X','XS') then 10
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('11') then 11
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('12') then 12
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('13') then 13
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('14') then 14
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('15') then 15
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('16') then 16
              when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') = '' then 14
              else 1
       end model_1
       ,case when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('mini') then 2
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Plus') then 4
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Pro','Max') then 5
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('ProMax') then 6
               when model like '%iPhone%' then 3
               else 1
       end model_2
        --media_source,operating_system
        ,install_days,life_time_active_days,last_active_days
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

--         ,grow_aigc_enter_pv,grow_aigc_use_pv,grow_aigc_save_pv,grow_pop_exposure,grow_pop_click,grow_content_exposure,grow_content_click,grow_max_module_positon,grow_sub_page_enter,grow_sub_page_click,grow_max_impression_pv,grow_impression_pv,grow_click_pv
        ,puzzle_click_pv,puzzle_save_pv,puzzle_click_pv_30,puzzle_save_pv_30,puzzle_click_pv_60,puzzle_save_pv_60,puzzle_click_pv_90,puzzle_save_pv_90

        ,pay_function_click_pv,free_function_click_pv,free_function_save_pv
        ,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
        ,pay_function_click_pv_30,free_function_click_pv_30,free_function_save_pv_30
        ,pay_function_click_pv_60,free_function_click_pv_60,free_function_save_pv_60
        ,pay_function_click_pv_90,free_function_click_pv_90,free_function_save_pv_90
        ,pay_duffle_click_pv_30,free_duffle_click_pv_30,free_duffle_save_pv_30
        ,pay_duffle_click_pv_60,free_duffle_click_pv_60,free_duffle_save_pv_60
        ,pay_duffle_click_pv_90,free_duffle_click_pv_90,free_duffle_save_pv_90
--         ,grow_pay_function_click_pv,grow_free_function_click_pv,grow_free_function_save_pv,grow_pay_duffle_click_pv,grow_free_duffle_click_pv,grow_free_duffle_save_pv
        ,case when coalesce(`pv_0级tab-修图---保存`,0)+coalesce(`pv_0级tab-拍摄---保存`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存`,0)/(coalesce(`pv_0级tab-修图---保存`,0)+coalesce(`pv_0级tab-拍摄---保存`,0)),4)
         end save_beauty_ratio
        ,case when coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---进入`,0)/(coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)),4)
         end enter_beauty_ratio
        ,case when coalesce(`pv_0级tab-修图---进入`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存`,0)/coalesce(`pv_0级tab-修图---进入`,0),4)
         end beauty_enter_to_save_ratio

         ,case when coalesce(`pv_0级tab-修图---保存_30`,0)+coalesce(`pv_0级tab-拍摄---保存_30`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_30`,0)/(coalesce(`pv_0级tab-修图---保存_30`,0)+coalesce(`pv_0级tab-拍摄---保存_30`,0)),4)
         end save_beauty_ratio_30
        ,case when coalesce(`pv_0级tab-修图---进入_30`,0)+coalesce(`pv_0级tab-自拍---进入_30`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---进入_30`,0)/(coalesce(`pv_0级tab-修图---进入_30`,0)+coalesce(`pv_0级tab-自拍---进入_30`,0)),4)
         end enter_beauty_ratio_30
        ,case when coalesce(`pv_0级tab-修图---进入_30`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_30`,0)/coalesce(`pv_0级tab-修图---进入_30`,0),4)
         end beauty_enter_to_save_ratio_30

         ,case when coalesce(`pv_0级tab-修图---保存_60`,0)+coalesce(`pv_0级tab-拍摄---保存_60`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_60`,0)/(coalesce(`pv_0级tab-修图---保存_60`,0)+coalesce(`pv_0级tab-拍摄---保存_60`,0)),4)
         end save_beauty_ratio_60
        ,case when coalesce(`pv_0级tab-修图---进入_60`,0)+coalesce(`pv_0级tab-自拍---进入_60`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---进入_60`,0)/(coalesce(`pv_0级tab-修图---进入_60`,0)+coalesce(`pv_0级tab-自拍---进入_60`,0)),4)
         end enter_beauty_ratio_60
        ,case when coalesce(`pv_0级tab-修图---进入_60`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_60`,0)/coalesce(`pv_0级tab-修图---进入_60`,0),4)
         end beauty_enter_to_save_ratio_60

         ,case when coalesce(`pv_0级tab-修图---保存_90`,0)+coalesce(`pv_0级tab-拍摄---保存_90`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_90`,0)/(coalesce(`pv_0级tab-修图---保存_90`,0)+coalesce(`pv_0级tab-拍摄---保存_90`,0)),4)
         end save_beauty_ratio_90
        ,case when coalesce(`pv_0级tab-修图---进入_90`,0)+coalesce(`pv_0级tab-自拍---进入_90`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---进入_90`,0)/(coalesce(`pv_0级tab-修图---进入_90`,0)+coalesce(`pv_0级tab-自拍---进入_90`,0)),4)
         end enter_beauty_ratio_90
        ,case when coalesce(`pv_0级tab-修图---进入_90`,0)=0 then null
               else round(coalesce(`pv_0级tab-修图---保存_90`,0)/coalesce(`pv_0级tab-修图---进入_90`,0),4)
         end beauty_enter_to_save_ratio_90

--         ,function_num
        ,case when function_num between 0 and 3 then function_num
             when function_num between 4 and 9 then 4
             when function_num between 10 and 20 then 5
             when function_num between 21 and 34 then 6
             when function_num >= 35 then 7
         end function_num_type
--         ,function_num_pre
        ,case when function_num_pre between 0 and 3 then function_num_pre
             when function_num_pre between 4 and 9 then 4
             when function_num_pre between 10 and 25 then 5
             when function_num_pre between 26 and 40 then 6
             when function_num_pre >= 40 then 7
         end function_num_pre_type
--         ,grow_function_num
        ,case when grow_function_num <-35 then -7
             when grow_function_num between -35 and -20 then -6
             when grow_function_num between -19 and -10 then -5
             when grow_function_num between -9 and -4 then -4
             when grow_function_num between -3 and 3 then grow_function_num
             when grow_function_num between 4 and 9 then 4
             when grow_function_num between 10 and 20 then 5
             when grow_function_num between 21 and 35 then 6
             when grow_function_num >= 36 then 7
        end grow_function_num_type
        ,function_num_30,function_num_60,function_num_90
--         ,grow_edit_enter_pv,grow_edit_save_pv,grow_take_photo_pv,grow_take_photo_save_pv,grow_selftake_enter_pv,grow_take_video_pv,grow_take_video_save_pv
--         ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
--                else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
--          end pay_duffle_click_ratio
        ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) = 0 then 0
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.01 then 2
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.01 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.05 then 3
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.05 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.1 then 4
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.1 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.2 then 5
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.2 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.3 then 6
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.3 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.4 then 7
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.4 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.5 then 8
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.5 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.6 then 9
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.6 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.7 then 10
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.7 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.8 then 11
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.8 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.9 then 12
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.9 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) < 1 then 13
             when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) = 1 then 1  -- 比例为1时订阅率反而更低了
        end pay_duffle_click_ratio_type

        ,case when coalesce(free_duffle_click_pv_30,0)=0 and coalesce(pay_duffle_click_pv_30,0)=0 then null
               else coalesce(pay_duffle_click_pv_30,0)/(coalesce(free_duffle_click_pv_30,0)+coalesce(pay_duffle_click_pv_30,0))
         end pay_duffle_click_ratio_30
         ,case when coalesce(free_duffle_click_pv_60,0)=0 and coalesce(pay_duffle_click_pv_60,0)=0 then null
               else coalesce(pay_duffle_click_pv_60,0)/(coalesce(free_duffle_click_pv_60,0)+coalesce(pay_duffle_click_pv_60,0))
         end pay_duffle_click_ratio_60
         ,case when coalesce(free_duffle_click_pv_90,0)=0 and coalesce(pay_duffle_click_pv_90,0)=0 then null
               else coalesce(pay_duffle_click_pv_90,0)/(coalesce(free_duffle_click_pv_90,0)+coalesce(pay_duffle_click_pv_90,0))
         end pay_duffle_click_ratio_90

--         ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
--                else coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0))
--          end pay_function_click_ratio
        ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) = 0 then 1
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.05 then 2
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.05 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.1 then 3
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.1 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.2 then 4
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.2 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.3 then 5
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.3 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.4 then 6
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.4 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.5 then 7
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.5 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.6 then 8
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.6 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.7 then 9
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.7 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.8 then 10
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.8 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.9 then 11
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.9 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) < 1 then 12
             when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) = 1 then 0
         end pay_function_click_ratio_type

        ,case when coalesce(free_function_click_pv_30,0)=0 and coalesce(pay_function_click_pv_30,0)=0 then null
               else coalesce(pay_function_click_pv_30,0)/(coalesce(free_function_click_pv_30,0)+coalesce(pay_function_click_pv_30,0))
         end pay_function_click_ratio_30
         ,case when coalesce(free_function_click_pv_60,0)=0 and coalesce(pay_function_click_pv_60,0)=0 then null
               else coalesce(pay_function_click_pv_60,0)/(coalesce(free_function_click_pv_60,0)+coalesce(pay_function_click_pv_60,0))
         end pay_function_click_ratio_60
         ,case when coalesce(free_function_click_pv_90,0)=0 and coalesce(pay_function_click_pv_90,0)=0 then null
               else coalesce(pay_function_click_pv_90,0)/(coalesce(free_function_click_pv_90,0)+coalesce(pay_function_click_pv_90,0))
         end pay_function_click_ratio_90

        ,case when coalesce(install_days+1,0)=0 then null
               else coalesce(life_time_active_days,0)/coalesce(install_days+1,0)
         end life_time_active_ratio

        ,case when coalesce(pop_exposure,0)=0 then null
               else round(coalesce(pop_click,0)/coalesce(pop_exposure,0),4)
         end pop_click_ratio
        ,case when coalesce(content_exposure,0)=0 then null
               else round(coalesce(content_click,0)/coalesce(content_exposure,0),4)
         end content_click_ratio

        ,case when coalesce(pop_exposure_30,0)=0 then null
               else round(coalesce(pop_click_30,0)/coalesce(pop_exposure_30,0),4)
         end pop_click_ratio_30
        ,case when coalesce(content_exposure_30,0)=0 then null
               else round(coalesce(content_click_30,0)/coalesce(content_exposure_30,0),4)
         end content_click_ratio_30
        ,case when coalesce(pop_exposure_60,0)=0 then null
               else round(coalesce(pop_click_60,0)/coalesce(pop_exposure_60,0),4)
         end pop_click_ratio_60
        ,case when coalesce(content_exposure_60,0)=0 then null
               else round(coalesce(content_click_60,0)/coalesce(content_exposure_60,0),4)
         end content_click_ratio_60
        ,case when coalesce(pop_exposure_90,0)=0 then null
               else round(coalesce(pop_click_90,0)/coalesce(pop_exposure_90,0),4)
         end pop_click_ratio_90
        ,case when coalesce(content_exposure_90,0)=0 then null
               else round(coalesce(content_click_90,0)/coalesce(content_exposure_90,0),4)
         end content_click_ratio_90

--          ,case when coalesce(sub_page_enter,0)=0 then null
--                else round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4)
--          end sub_page_click_ratio
        ,case when coalesce(sub_page_enter,0)=0 then null
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) = 0 then 1
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.1 then 2
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.1 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.2 then 3
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.2 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.3 then 4
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.3 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.4 then 5
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.4 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.5 then 6
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.5 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.7 then 7
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.7 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) < 1 then 8
             when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) = 1 then 9
        end sub_page_click_ratio_type

         ,case when coalesce(sub_page_enter_30,0)=0 then null
               else round(coalesce(sub_page_click_30,0)/coalesce(sub_page_enter_30,0),4)
         end sub_page_click_ratio_30
         ,case when coalesce(sub_page_enter_60,0)=0 then null
               else round(coalesce(sub_page_click_60,0)/coalesce(sub_page_enter_60,0),4)
         end sub_page_click_ratio_60
         ,case when coalesce(sub_page_enter_90,0)=0 then null
               else round(coalesce(sub_page_click_90,0)/coalesce(sub_page_enter_90,0),4)
         end sub_page_click_ratio_90

        ,homepage_exposure_pv,homepage_click_pv
        ,homepage_feature_show_pv,homepage_feature_click_pv,homepage_banner_show_pv,homepage_banner_click_pv
        ,homepage_reconmend_show_pv,homepage_reconmend_click_pv
        ,homepage_topic_show_pv,homepage_topic_click_pv,homepage_miniapp_show_pv,homepage_miniapp_click_pv

        ,homepage_exposure_pv_30,homepage_click_pv_30
        ,homepage_feature_show_pv_30,homepage_feature_click_pv_30,homepage_banner_show_pv_30,homepage_banner_click_pv_30
        ,homepage_reconmend_show_pv_30,homepage_reconmend_click_pv_30
        ,homepage_topic_show_pv_30,homepage_topic_click_pv_30,homepage_miniapp_show_pv_30,homepage_miniapp_click_pv_30

        ,homepage_exposure_pv_60,homepage_click_pv_60
        ,homepage_feature_show_pv_60,homepage_feature_click_pv_60,homepage_banner_show_pv_60,homepage_banner_click_pv_60
        ,homepage_reconmend_show_pv_60,homepage_reconmend_click_pv_60
        ,homepage_topic_show_pv_60,homepage_topic_click_pv_60,homepage_miniapp_show_pv_60,homepage_miniapp_click_pv_60

        ,homepage_exposure_pv_90,homepage_click_pv_90
        ,homepage_feature_show_pv_90,homepage_feature_click_pv_90,homepage_banner_show_pv_90,homepage_banner_click_pv_90
        ,homepage_reconmend_show_pv_90,homepage_reconmend_click_pv_90
        ,homepage_topic_show_pv_90,homepage_topic_click_pv_90,homepage_miniapp_show_pv_90,homepage_miniapp_click_pv_90

from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2
-- where is_paying='un-Paying' and is_consum='un-consumable' -- 该条件限制了当天活跃的
where is_current_pay=0


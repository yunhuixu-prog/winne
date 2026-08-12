-- beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_pay_v
-- 划分标准：订阅率

select date,uuid,bucket
        ,coalesce(case when permanent_country in ('Nigeria','India','Iran','Pakistan','Egypt','Cambodia','Bangladesh','Myanmar (Burma)') then 1
             when permanent_country in ('Indonesia','Thailand','Philippines','Mexico','Malaysia','United Arab Emirates','France','Peru'
                ,'Saudi Arabia','Colombia','Taiwan','Russia','Argentina','Hong Kong','South Africa','Dominican Republic'
                ,'Greece','Kuwait','Ukraine','Azerbaijan','Serbia','Ecuador','Lebanon','Hungary','Jordan','Kazakhstan') then 2
             when permanent_country in ('Vietnam','Japan','Turkey','South Korea','Brazil','United Kingdom','Germany','Singapore','Spain','Italy'
                ,'Netherlands','Chile','Romania','Belgium','Poland','Cyprus','Portugal','Sweden') then 3
             when permanent_country in ('United States','Canada','Australia','Israel','Switzerland','Austria') then 4
             when permanent_country in ('Türkiye') then 5
             else 2
         end,-1) region
        ,case when is_current_trial = 1 then 'trial_now'
             when past_sub_times-trial_times>0 then 'sub_his'
             when trial_times>0 then 'trial_his'
             else 'else'
        end sub_type
        -- 分层指标
        ,coalesce(case when active_days_90d <= 3 then 1
             when active_days_90d <= 7 then 2
             when active_days_90d <= 12 then 3
             when active_days_90d <= 18 then 4
             when active_days_90d <= 25 then 5
             when active_days_90d <= 35 then 6
             when active_days_90d <= 50 then 7
             when active_days_90d <= 70 then 8
             else 9
        end,-1) active_days_90d_type
         ,coalesce(case
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
         end,-1) install_days_type
         ,coalesce(case when last_active_days+1 between 1 and 3 then 1
               when last_active_days+1 between 4 and 7 then 2
               when last_active_days+1 between 8 and 14 then 3
               when last_active_days+1 between 15 and 30 then 4
               when last_active_days+1 between 31 and 60 then 5
               when last_active_days+1 between 61 and 90 then 6
               when last_active_days+1 between 91 and 180 then 7
               when last_active_days+1 between 181 and 365 then 8
               when last_active_days+1 between 366 and 730 then 9
               else 10
         end,-1) last_active_days_type
        ,if(last_active_days>=7,0,1) is_active_7
        ,if(coalesce(pv_tab0_edit_entry,0)+coalesce(pv_tab0_selfie_entry,0)>0,1,0) is_edit_selfi_7
        ,if(last_active_days>=30,0,1) is_active_30
        ,if(coalesce(pv_tab0_edit_entry_30,0)+coalesce(pv_tab0_selfie_entry_30,0)>0,1,0) is_edit_selfi_30
        ,if(last_active_days>=60,0,1) is_active_60
        ,if(coalesce(pv_tab0_edit_entry_60,0)+coalesce(pv_tab0_selfie_entry_60,0)>0,1,0) is_edit_selfi_60
        ,if(last_active_days>=90,0,1) is_active_90
        ,if(coalesce(pv_tab0_edit_entry_90,0)+coalesce(pv_tab0_selfie_entry_90,0)>0,1,0) is_edit_selfi_90

        -- 历史订阅信息
        , coalesce(is_current_trial,-1) is_current_trial, coalesce(current_trial_day,-1) current_trial_day
        , coalesce(is_current_subscription_cancelled,-1) is_current_subscription_cancelled
        , coalesce(past_sub_times,-1) past_sub_times, coalesce(trial_times,-1) trial_times
        , coalesce(cancel_subscription_times,-1) cancel_subscription_times
        , coalesce(refund_subscription_times,-1) refund_subscription_times
        , coalesce(promotional_paying_times,-1) promotional_paying_times
        -- 预测指标
        ,sub_365,sub_90,sub_30,sub_7
        ,coalesce(is_new,-1) is_new
        ,if(is_ua='non-Organic',1,2) is_ua
        ,if(platform='ANDROID',1,2) platform
--         ,android_level -- 没值
        ,coalesce(case when brand in ('Infinix','Tecno','itel','Nokia') then 2
            when brand in ('Vivo','Realme','Huawei','LG','Lenovo') then 3
            when brand in ('OPPO','Xiaomi','OnePlus') then 4
            when brand in ('Samsung','Sharp','Honor','POCO') then 5
            when brand in ('Sony') then 6
            when brand in ('Motorola','Google') then 7
            when brand in ('Apple') then 8
            when brand in ('Epik') then 9
            else 3
         end,-1) brand
        ,coalesce(case when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('4s','4','4c') then 4
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
       end,-1) model_1
       ,coalesce(case when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('mini') then 2
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Plus') then 4
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Pro','Max') then 5
               when model like '%iPhone%'
                    and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('ProMax') then 6
               when model like '%iPhone%' then 3
               else 1
       end,-1) model_2
        ,coalesce(phone_price,-1) phone_price
        --media_source,operating_system
        , coalesce(install_days,-1) install_days, coalesce(life_time_active_days,-1) life_time_active_days
        , coalesce(last_active_days,-1) last_active_days
        , coalesce(active_mins_90d,-1) active_mins_90d, coalesce(active_sessions_90d,-1) active_sessions_90d
        , coalesce(active_mins_7d,-1) active_mins_7d, coalesce(active_sessions_7d,-1) active_sessions_7d
        , coalesce(active_days_90d,-1) active_days_90d, coalesce(active_days_7d,-1) active_days_7d
        , coalesce(active_days_60,-1) active_days_60, coalesce(active_days_30,-1) active_days_30
        , coalesce(active_days_14,-1) active_days_14, coalesce(active_category,-1) active_category
        , coalesce(id_num,-1) id_num, coalesce(active_days_365,-1) active_days_365
        , coalesce(holiday_active_days_365,-1) holiday_active_days_365
        , coalesce(weekend_active_days_365,-1) weekend_active_days_365
        , coalesce(weekend_include_five_active_days_365,-1) weekend_include_five_active_days_365
        , coalesce(holiday_active_ratio,-1) holiday_active_ratio
        , coalesce(weekend_active_ratio,-1) weekend_active_ratio
        , coalesce(weekend_include_five_active_ratio,-1) weekend_include_five_active_ratio
        , coalesce(pv_tab0_edit_entry,-1) pv_tab0_edit_entry, coalesce(pv_tab0_edit_save,-1) pv_tab0_edit_save, coalesce(pv_tab0_movie_save,-1) pv_tab0_movie_save, coalesce(pv_tab0_movie_shoot,-1) pv_tab0_movie_shoot, coalesce(pv_tab0_selfie_entry,-1) pv_tab0_selfie_entry, coalesce(pv_tab0_shoot_save,-1) pv_tab0_shoot_save, coalesce(pv_tab0_shoot_shoot,-1) pv_tab0_shoot_shoot, coalesce(pv_tab0_video_save,-1) pv_tab0_video_save, coalesce(pv_tab0_video_shoot,-1) pv_tab0_video_shoot, coalesce(pv_tab0_videoedit_entry,-1) pv_tab0_videoedit_entry, coalesce(pv_tab0_videoedit_save,-1) pv_tab0_videoedit_save, coalesce(pv_tab1_edit_beauty_click,-1) pv_tab1_edit_beauty_click, coalesce(pv_tab1_edit_beauty_save,-1) pv_tab1_edit_beauty_save, coalesce(pv_tab1_edit_creative_click,-1) pv_tab1_edit_creative_click, coalesce(pv_tab1_edit_creative_save,-1) pv_tab1_edit_creative_save, coalesce(pv_tab1_edit_edit_click,-1) pv_tab1_edit_edit_click, coalesce(pv_tab1_edit_edit_save,-1) pv_tab1_edit_edit_save, coalesce(pv_tab1_edit_filter_click,-1) pv_tab1_edit_filter_click, coalesce(pv_tab1_edit_filter_save,-1) pv_tab1_edit_filter_save, coalesce(pv_tab1_edit_makeup_click,-1) pv_tab1_edit_makeup_click, coalesce(pv_tab1_edit_makeup_save,-1) pv_tab1_edit_makeup_save, coalesce(pv_tab1_edit_senioredit_click,-1) pv_tab1_edit_senioredit_click, coalesce(pv_tab1_shoot_ar_save,-1) pv_tab1_shoot_ar_save, coalesce(pv_tab1_shoot_ar_shoot,-1) pv_tab1_shoot_ar_shoot, coalesce(pv_tab1_shoot_beauty_save,-1) pv_tab1_shoot_beauty_save, coalesce(pv_tab1_shoot_filter_save,-1) pv_tab1_shoot_filter_save, coalesce(pv_tab1_shoot_filter_shoot,-1) pv_tab1_shoot_filter_shoot, coalesce(pv_tab1_shoot_look_save,-1) pv_tab1_shoot_look_save, coalesce(pv_tab1_shoot_look_shoot,-1) pv_tab1_shoot_look_shoot, coalesce(pv_tab1_shoot_makeup_save,-1) pv_tab1_shoot_makeup_save, coalesce(pv_tab1_shoot_makeup_shoot,-1) pv_tab1_shoot_makeup_shoot
        , coalesce(pv_tab2_edit_beauty_AIbeauty_click,-1) pv_tab2_edit_beauty_AIbeauty_click, coalesce(pv_tab2_edit_beauty_AIbeauty_save,-1) pv_tab2_edit_beauty_AIbeauty_save, coalesce(pv_tab2_edit_beauty_Threedimensionalface_click,-1) pv_tab2_edit_beauty_Threedimensionalface_click, coalesce(pv_tab2_edit_beauty_Threedimensionalface_save,-1) pv_tab2_edit_beauty_Threedimensionalface_save, coalesce(pv_tab2_edit_beauty_detail_click,-1) pv_tab2_edit_beauty_detail_click, coalesce(pv_tab2_edit_beauty_detail_save,-1) pv_tab2_edit_beauty_detail_save, coalesce(pv_tab2_edit_beauty_doublechin_click,-1) pv_tab2_edit_beauty_doublechin_click, coalesce(pv_tab2_edit_beauty_doublechin_save,-1) pv_tab2_edit_beauty_doublechin_save, coalesce(pv_tab2_edit_beauty_evenskin_click,-1) pv_tab2_edit_beauty_evenskin_click, coalesce(pv_tab2_edit_beauty_evenskin_save,-1) pv_tab2_edit_beauty_evenskin_save, coalesce(pv_tab2_edit_beauty_expression_click,-1) pv_tab2_edit_beauty_expression_click, coalesce(pv_tab2_edit_beauty_expression_save,-1) pv_tab2_edit_beauty_expression_save, coalesce(pv_tab2_edit_beauty_eyecatching_click,-1) pv_tab2_edit_beauty_eyecatching_click, coalesce(pv_tab2_edit_beauty_eyecatching_save,-1) pv_tab2_edit_beauty_eyecatching_save, coalesce(pv_tab2_edit_beauty_eyedilated_click,-1) pv_tab2_edit_beauty_eyedilated_click, coalesce(pv_tab2_edit_beauty_eyedilated_save,-1) pv_tab2_edit_beauty_eyedilated_save, coalesce(pv_tab2_edit_beauty_facecolor_click,-1) pv_tab2_edit_beauty_facecolor_click, coalesce(pv_tab2_edit_beauty_facecolor_save,-1) pv_tab2_edit_beauty_facecolor_save, coalesce(pv_tab2_edit_beauty_faceslimming_click,-1) pv_tab2_edit_beauty_faceslimming_click, coalesce(pv_tab2_edit_beauty_faceslimming_save,-1) pv_tab2_edit_beauty_faceslimming_save, coalesce(pv_tab2_edit_beauty_faciallighting_click,-1) pv_tab2_edit_beauty_faciallighting_click, coalesce(pv_tab2_edit_beauty_faciallighting_save,-1) pv_tab2_edit_beauty_faciallighting_save, coalesce(pv_tab2_edit_beauty_facialreshaping_click,-1) pv_tab2_edit_beauty_facialreshaping_click, coalesce(pv_tab2_edit_beauty_facialreshaping_save,-1) pv_tab2_edit_beauty_facialreshaping_save, coalesce(pv_tab2_edit_beauty_hairdressing_click,-1) pv_tab2_edit_beauty_hairdressing_click, coalesce(pv_tab2_edit_beauty_hairdressing_save,-1) pv_tab2_edit_beauty_hairdressing_save, coalesce(pv_tab2_edit_beauty_lightendarkcircle_click,-1) pv_tab2_edit_beauty_lightendarkcircle_click, coalesce(pv_tab2_edit_beauty_lightendarkcircle_save,-1) pv_tab2_edit_beauty_lightendarkcircle_save, coalesce(pv_tab2_edit_beauty_microdermabrasion_click,-1) pv_tab2_edit_beauty_microdermabrasion_click, coalesce(pv_tab2_edit_beauty_microdermabrasion_save,-1) pv_tab2_edit_beauty_microdermabrasion_save, coalesce(pv_tab2_edit_beauty_narrownose_click,-1) pv_tab2_edit_beauty_narrownose_click, coalesce(pv_tab2_edit_beauty_narrownose_save,-1) pv_tab2_edit_beauty_narrownose_save, coalesce(pv_tab2_edit_beauty_oneclickbeauty_click,-1) pv_tab2_edit_beauty_oneclickbeauty_click, coalesce(pv_tab2_edit_beauty_oneclickbeauty_save,-1) pv_tab2_edit_beauty_oneclickbeauty_save, coalesce(pv_tab2_edit_beauty_orthodontics_click,-1) pv_tab2_edit_beauty_orthodontics_click, coalesce(pv_tab2_edit_beauty_orthodontics_save,-1) pv_tab2_edit_beauty_orthodontics_save, coalesce(pv_tab2_edit_beauty_removieacne_click,-1) pv_tab2_edit_beauty_removieacne_click, coalesce(pv_tab2_edit_beauty_removieacne_save,-1) pv_tab2_edit_beauty_removieacne_save, coalesce(pv_tab2_edit_beauty_removieshine_click,-1) pv_tab2_edit_beauty_removieshine_click, coalesce(pv_tab2_edit_beauty_removieshine_save,-1) pv_tab2_edit_beauty_removieshine_save, coalesce(pv_tab2_edit_beauty_removiewrinkles_click,-1) pv_tab2_edit_beauty_removiewrinkles_click, coalesce(pv_tab2_edit_beauty_removiewrinkles_save,-1) pv_tab2_edit_beauty_removiewrinkles_save, coalesce(pv_tab2_edit_beauty_shape_click,-1) pv_tab2_edit_beauty_shape_click, coalesce(pv_tab2_edit_beauty_shape_save,-1) pv_tab2_edit_beauty_shape_save, coalesce(pv_tab2_edit_beauty_shrinkhead_click,-1) pv_tab2_edit_beauty_shrinkhead_click, coalesce(pv_tab2_edit_beauty_shrinkhead_save,-1) pv_tab2_edit_beauty_shrinkhead_save, coalesce(pv_tab2_edit_beauty_teethwhitening_click,-1) pv_tab2_edit_beauty_teethwhitening_click, coalesce(pv_tab2_edit_beauty_teethwhitening_save,-1) pv_tab2_edit_beauty_teethwhitening_save
        , coalesce(pv_tab0_edit_entry_30,-1) pv_tab0_edit_entry_30, coalesce(pv_tab0_edit_save_30,-1) pv_tab0_edit_save_30, coalesce(pv_tab0_movie_save_30,-1) pv_tab0_movie_save_30, coalesce(pv_tab0_movie_shoot_30,-1) pv_tab0_movie_shoot_30, coalesce(pv_tab0_selfie_entry_30,-1) pv_tab0_selfie_entry_30, coalesce(pv_tab0_shoot_save_30,-1) pv_tab0_shoot_save_30, coalesce(pv_tab0_shoot_shoot_30,-1) pv_tab0_shoot_shoot_30, coalesce(pv_tab0_video_save_30,-1) pv_tab0_video_save_30, coalesce(pv_tab0_video_shoot_30,-1) pv_tab0_video_shoot_30, coalesce(pv_tab0_videoedit_entry_30,-1) pv_tab0_videoedit_entry_30, coalesce(pv_tab0_videoedit_save_30,-1) pv_tab0_videoedit_save_30, coalesce(pv_tab1_edit_beauty_click_30,-1) pv_tab1_edit_beauty_click_30, coalesce(pv_tab1_edit_beauty_save_30,-1) pv_tab1_edit_beauty_save_30, coalesce(pv_tab1_edit_creative_click_30,-1) pv_tab1_edit_creative_click_30, coalesce(pv_tab1_edit_creative_save_30,-1) pv_tab1_edit_creative_save_30, coalesce(pv_tab1_edit_edit_click_30,-1) pv_tab1_edit_edit_click_30, coalesce(pv_tab1_edit_edit_save_30,-1) pv_tab1_edit_edit_save_30, coalesce(pv_tab1_edit_filter_click_30,-1) pv_tab1_edit_filter_click_30, coalesce(pv_tab1_edit_filter_save_30,-1) pv_tab1_edit_filter_save_30, coalesce(pv_tab1_edit_makeup_click_30,-1) pv_tab1_edit_makeup_click_30, coalesce(pv_tab1_edit_makeup_save_30,-1) pv_tab1_edit_makeup_save_30, coalesce(pv_tab1_edit_senioredit_click_30,-1) pv_tab1_edit_senioredit_click_30, coalesce(pv_tab1_shoot_ar_save_30,-1) pv_tab1_shoot_ar_save_30, coalesce(pv_tab1_shoot_ar_shoot_30,-1) pv_tab1_shoot_ar_shoot_30, coalesce(pv_tab1_shoot_beauty_save_30,-1) pv_tab1_shoot_beauty_save_30, coalesce(pv_tab1_shoot_filter_save_30,-1) pv_tab1_shoot_filter_save_30, coalesce(pv_tab1_shoot_filter_shoot_30,-1) pv_tab1_shoot_filter_shoot_30, coalesce(pv_tab1_shoot_look_save_30,-1) pv_tab1_shoot_look_save_30, coalesce(pv_tab1_shoot_look_shoot_30,-1) pv_tab1_shoot_look_shoot_30, coalesce(pv_tab1_shoot_makeup_save_30,-1) pv_tab1_shoot_makeup_save_30, coalesce(pv_tab1_shoot_makeup_shoot_30,-1) pv_tab1_shoot_makeup_shoot_30
        , coalesce(pv_tab0_edit_entry_60,-1) pv_tab0_edit_entry_60, coalesce(pv_tab0_edit_save_60,-1) pv_tab0_edit_save_60, coalesce(pv_tab0_movie_save_60,-1) pv_tab0_movie_save_60, coalesce(pv_tab0_movie_shoot_60,-1) pv_tab0_movie_shoot_60, coalesce(pv_tab0_selfie_entry_60,-1) pv_tab0_selfie_entry_60, coalesce(pv_tab0_shoot_save_60,-1) pv_tab0_shoot_save_60, coalesce(pv_tab0_shoot_shoot_60,-1) pv_tab0_shoot_shoot_60, coalesce(pv_tab0_video_save_60,-1) pv_tab0_video_save_60, coalesce(pv_tab0_video_shoot_60,-1) pv_tab0_video_shoot_60, coalesce(pv_tab0_videoedit_entry_60,-1) pv_tab0_videoedit_entry_60, coalesce(pv_tab0_videoedit_save_60,-1) pv_tab0_videoedit_save_60, coalesce(pv_tab1_edit_beauty_click_60,-1) pv_tab1_edit_beauty_click_60, coalesce(pv_tab1_edit_beauty_save_60,-1) pv_tab1_edit_beauty_save_60, coalesce(pv_tab1_edit_creative_click_60,-1) pv_tab1_edit_creative_click_60, coalesce(pv_tab1_edit_creative_save_60,-1) pv_tab1_edit_creative_save_60, coalesce(pv_tab1_edit_edit_click_60,-1) pv_tab1_edit_edit_click_60, coalesce(pv_tab1_edit_edit_save_60,-1) pv_tab1_edit_edit_save_60, coalesce(pv_tab1_edit_filter_click_60,-1) pv_tab1_edit_filter_click_60, coalesce(pv_tab1_edit_filter_save_60,-1) pv_tab1_edit_filter_save_60, coalesce(pv_tab1_edit_makeup_click_60,-1) pv_tab1_edit_makeup_click_60, coalesce(pv_tab1_edit_makeup_save_60,-1) pv_tab1_edit_makeup_save_60, coalesce(pv_tab1_edit_senioredit_click_60,-1) pv_tab1_edit_senioredit_click_60, coalesce(pv_tab1_shoot_ar_save_60,-1) pv_tab1_shoot_ar_save_60, coalesce(pv_tab1_shoot_ar_shoot_60,-1) pv_tab1_shoot_ar_shoot_60, coalesce(pv_tab1_shoot_beauty_save_60,-1) pv_tab1_shoot_beauty_save_60, coalesce(pv_tab1_shoot_filter_save_60,-1) pv_tab1_shoot_filter_save_60, coalesce(pv_tab1_shoot_filter_shoot_60,-1) pv_tab1_shoot_filter_shoot_60, coalesce(pv_tab1_shoot_look_save_60,-1) pv_tab1_shoot_look_save_60, coalesce(pv_tab1_shoot_look_shoot_60,-1) pv_tab1_shoot_look_shoot_60, coalesce(pv_tab1_shoot_makeup_save_60,-1) pv_tab1_shoot_makeup_save_60, coalesce(pv_tab1_shoot_makeup_shoot_60,-1) pv_tab1_shoot_makeup_shoot_60
        , coalesce(pv_tab0_edit_entry_90,-1) pv_tab0_edit_entry_90, coalesce(pv_tab0_edit_save_90,-1) pv_tab0_edit_save_90, coalesce(pv_tab0_movie_save_90,-1) pv_tab0_movie_save_90, coalesce(pv_tab0_movie_shoot_90,-1) pv_tab0_movie_shoot_90, coalesce(pv_tab0_selfie_entry_90,-1) pv_tab0_selfie_entry_90, coalesce(pv_tab0_shoot_save_90,-1) pv_tab0_shoot_save_90, coalesce(pv_tab0_shoot_shoot_90,-1) pv_tab0_shoot_shoot_90, coalesce(pv_tab0_video_save_90,-1) pv_tab0_video_save_90, coalesce(pv_tab0_video_shoot_90,-1) pv_tab0_video_shoot_90, coalesce(pv_tab0_videoedit_entry_90,-1) pv_tab0_videoedit_entry_90, coalesce(pv_tab0_videoedit_save_90,-1) pv_tab0_videoedit_save_90, coalesce(pv_tab1_edit_beauty_click_90,-1) pv_tab1_edit_beauty_click_90, coalesce(pv_tab1_edit_beauty_save_90,-1) pv_tab1_edit_beauty_save_90, coalesce(pv_tab1_edit_creative_click_90,-1) pv_tab1_edit_creative_click_90, coalesce(pv_tab1_edit_creative_save_90,-1) pv_tab1_edit_creative_save_90, coalesce(pv_tab1_edit_edit_click_90,-1) pv_tab1_edit_edit_click_90, coalesce(pv_tab1_edit_edit_save_90,-1) pv_tab1_edit_edit_save_90, coalesce(pv_tab1_edit_filter_click_90,-1) pv_tab1_edit_filter_click_90, coalesce(pv_tab1_edit_filter_save_90,-1) pv_tab1_edit_filter_save_90, coalesce(pv_tab1_edit_makeup_click_90,-1) pv_tab1_edit_makeup_click_90, coalesce(pv_tab1_edit_makeup_save_90,-1) pv_tab1_edit_makeup_save_90, coalesce(pv_tab1_edit_senioredit_click_90,-1) pv_tab1_edit_senioredit_click_90, coalesce(pv_tab1_shoot_ar_save_90,-1) pv_tab1_shoot_ar_save_90, coalesce(pv_tab1_shoot_ar_shoot_90,-1) pv_tab1_shoot_ar_shoot_90, coalesce(pv_tab1_shoot_beauty_save_90,-1) pv_tab1_shoot_beauty_save_90, coalesce(pv_tab1_shoot_filter_save_90,-1) pv_tab1_shoot_filter_save_90, coalesce(pv_tab1_shoot_filter_shoot_90,-1) pv_tab1_shoot_filter_shoot_90, coalesce(pv_tab1_shoot_look_save_90,-1) pv_tab1_shoot_look_save_90, coalesce(pv_tab1_shoot_look_shoot_90,-1) pv_tab1_shoot_look_shoot_90, coalesce(pv_tab1_shoot_makeup_save_90,-1) pv_tab1_shoot_makeup_save_90, coalesce(pv_tab1_shoot_makeup_shoot_90,-1) pv_tab1_shoot_makeup_shoot_90
        , coalesce(aigc_enter_pv,-1) aigc_enter_pv, coalesce(aigc_use_pv,-1) aigc_use_pv, coalesce(aigc_save_pv,-1) aigc_save_pv, coalesce(pop_exposure,-1) pop_exposure, coalesce(pop_click,-1) pop_click, coalesce(content_exposure,-1) content_exposure, coalesce(content_click,-1) content_click, coalesce(max_module_positon,-1) max_module_positon, coalesce(sub_page_enter,-1) sub_page_enter, coalesce(sub_page_click,-1) sub_page_click, coalesce(force_sub_page_enter,-1) force_sub_page_enter, coalesce(force_sub_page_click,-1) force_sub_page_click, coalesce(subscript_sub_page_enter,-1) subscript_sub_page_enter, coalesce(subscript_sub_page_click,-1) subscript_sub_page_click, coalesce(other_sub_page_enter,-1) other_sub_page_enter, coalesce(other_sub_page_click,-1) other_sub_page_click, coalesce(max_impression_pv,-1) max_impression_pv, coalesce(impression_pv,-1) impression_pv, coalesce(click_pv,-1) click_pv
        , coalesce(aigc_enter_pv_30,-1) aigc_enter_pv_30, coalesce(aigc_use_pv_30,-1) aigc_use_pv_30, coalesce(aigc_save_pv_30,-1) aigc_save_pv_30, coalesce(pop_exposure_30,-1) pop_exposure_30, coalesce(pop_click_30,-1) pop_click_30, coalesce(content_exposure_30,-1) content_exposure_30, coalesce(content_click_30,-1) content_click_30, coalesce(max_module_positon_30,-1) max_module_positon_30, coalesce(sub_page_enter_30,-1) sub_page_enter_30, coalesce(sub_page_click_30,-1) sub_page_click_30, coalesce(force_sub_page_enter_30,-1) force_sub_page_enter_30, coalesce(force_sub_page_click_30,-1) force_sub_page_click_30, coalesce(subscript_sub_page_enter_30,-1) subscript_sub_page_enter_30, coalesce(subscript_sub_page_click_30,-1) subscript_sub_page_click_30, coalesce(other_sub_page_enter_30,-1) other_sub_page_enter_30, coalesce(other_sub_page_click_30,-1) other_sub_page_click_30, coalesce(max_impression_pv_30,-1) max_impression_pv_30, coalesce(impression_pv_30,-1) impression_pv_30, coalesce(click_pv_30,-1) click_pv_30
        , coalesce(aigc_enter_pv_60,-1) aigc_enter_pv_60, coalesce(aigc_use_pv_60,-1) aigc_use_pv_60, coalesce(aigc_save_pv_60,-1) aigc_save_pv_60, coalesce(pop_exposure_60,-1) pop_exposure_60, coalesce(pop_click_60,-1) pop_click_60, coalesce(content_exposure_60,-1) content_exposure_60, coalesce(content_click_60,-1) content_click_60, coalesce(max_module_positon_60,-1) max_module_positon_60, coalesce(sub_page_enter_60,-1) sub_page_enter_60, coalesce(sub_page_click_60,-1) sub_page_click_60, coalesce(force_sub_page_enter_60,-1) force_sub_page_enter_60, coalesce(force_sub_page_click_60,-1) force_sub_page_click_60, coalesce(subscript_sub_page_enter_60,-1) subscript_sub_page_enter_60, coalesce(subscript_sub_page_click_60,-1) subscript_sub_page_click_60, coalesce(other_sub_page_enter_60,-1) other_sub_page_enter_60, coalesce(other_sub_page_click_60,-1) other_sub_page_click_60, coalesce(max_impression_pv_60,-1) max_impression_pv_60, coalesce(impression_pv_60,-1) impression_pv_60, coalesce(click_pv_60,-1) click_pv_60
        , coalesce(aigc_enter_pv_90,-1) aigc_enter_pv_90, coalesce(aigc_use_pv_90,-1) aigc_use_pv_90, coalesce(aigc_save_pv_90,-1) aigc_save_pv_90, coalesce(pop_exposure_90,-1) pop_exposure_90, coalesce(pop_click_90,-1) pop_click_90, coalesce(content_exposure_90,-1) content_exposure_90, coalesce(content_click_90,-1) content_click_90, coalesce(max_module_positon_90,-1) max_module_positon_90, coalesce(sub_page_enter_90,-1) sub_page_enter_90, coalesce(sub_page_click_90,-1) sub_page_click_90, coalesce(force_sub_page_enter_90,-1) force_sub_page_enter_90, coalesce(force_sub_page_click_90,-1) force_sub_page_click_90, coalesce(subscript_sub_page_enter_90,-1) subscript_sub_page_enter_90, coalesce(subscript_sub_page_click_90,-1) subscript_sub_page_click_90, coalesce(other_sub_page_enter_90,-1) other_sub_page_enter_90, coalesce(other_sub_page_click_90,-1) other_sub_page_click_90, coalesce(max_impression_pv_90,-1) max_impression_pv_90, coalesce(impression_pv_90,-1) impression_pv_90, coalesce(click_pv_90,-1) click_pv_90
        , coalesce(puzzle_click_pv,-1) puzzle_click_pv, coalesce(puzzle_save_pv,-1) puzzle_save_pv, coalesce(puzzle_click_pv_30,-1) puzzle_click_pv_30, coalesce(puzzle_save_pv_30,-1) puzzle_save_pv_30, coalesce(puzzle_click_pv_60,-1) puzzle_click_pv_60, coalesce(puzzle_save_pv_60,-1) puzzle_save_pv_60, coalesce(puzzle_click_pv_90,-1) puzzle_click_pv_90, coalesce(puzzle_save_pv_90,-1) puzzle_save_pv_90
        , coalesce(pay_function_click_pv,-1) pay_function_click_pv, coalesce(free_function_click_pv,-1) free_function_click_pv, coalesce(free_function_save_pv,-1) free_function_save_pv, coalesce(pay_duffle_click_pv,-1) pay_duffle_click_pv, coalesce(free_duffle_click_pv,-1) free_duffle_click_pv, coalesce(free_duffle_save_pv,-1) free_duffle_save_pv
        , coalesce(pay_function_click_pv_30,-1) pay_function_click_pv_30, coalesce(free_function_click_pv_30,-1) free_function_click_pv_30, coalesce(free_function_save_pv_30,-1) free_function_save_pv_30
        , coalesce(pay_function_click_pv_60,-1) pay_function_click_pv_60, coalesce(free_function_click_pv_60,-1) free_function_click_pv_60, coalesce(free_function_save_pv_60,-1) free_function_save_pv_60
        , coalesce(pay_function_click_pv_90,-1) pay_function_click_pv_90, coalesce(free_function_click_pv_90,-1) free_function_click_pv_90, coalesce(free_function_save_pv_90,-1) free_function_save_pv_90
        , coalesce(pay_duffle_click_pv_30,-1) pay_duffle_click_pv_30, coalesce(free_duffle_click_pv_30,-1) free_duffle_click_pv_30, coalesce(free_duffle_save_pv_30,-1) free_duffle_save_pv_30
        , coalesce(pay_duffle_click_pv_60,-1) pay_duffle_click_pv_60, coalesce(free_duffle_click_pv_60,-1) free_duffle_click_pv_60, coalesce(free_duffle_save_pv_60,-1) free_duffle_save_pv_60
        , coalesce(pay_duffle_click_pv_90,-1) pay_duffle_click_pv_90, coalesce(free_duffle_click_pv_90,-1) free_duffle_click_pv_90, coalesce(free_duffle_save_pv_90,-1) free_duffle_save_pv_90

--         , pv_tab2_edit_creative_background_click, pv_tab2_edit_creative_background_save, pv_tab2_edit_creative_formula_click, pv_tab2_edit_creative_formula_save, pv_tab2_edit_creative_graffiti_click, pv_tab2_edit_creative_graffiti_save, pv_tab2_edit_creative_sticker_click, pv_tab2_edit_creative_sticker_save, pv_tab2_edit_creative_text_click, pv_tab2_edit_creative_text_save, pv_tab2_edit_edit_AIenhance_click, pv_tab2_edit_edit_AIenhance_save, pv_tab2_edit_edit_AIextension_click, pv_tab2_edit_edit_AIextension_save, pv_tab2_edit_edit_adjustment_click, pv_tab2_edit_edit_ar_click, pv_tab2_edit_edit_ar_save, pv_tab2_edit_edit_blur_click, pv_tab2_edit_edit_blur_save, pv_tab2_edit_edit_clone_click, pv_tab2_edit_edit_clone_save, pv_tab2_edit_edit_composition_click, pv_tab2_edit_edit_composition_save, pv_tab2_edit_edit_cutout_click, pv_tab2_edit_edit_cutout_save, pv_tab2_edit_edit_dispersion_click, pv_tab2_edit_edit_dispersion_save, pv_tab2_edit_edit_elimination_click, pv_tab2_edit_edit_elimination_save, pv_tab2_edit_edit_mosaic_click, pv_tab2_edit_edit_mosaic_save, pv_tab2_edit_edit_photorepair_click, pv_tab2_edit_edit_photorepair_save, pv_tab2_edit_edit_stylization_click, pv_tab2_edit_edit_stylization_save, pv_tab2_shoot_beauty_bigeyes_save, pv_tab2_shoot_beauty_eyecatching_save, pv_tab2_shoot_beauty_facecolor_save, pv_tab2_shoot_beauty_faceslimming_save, pv_tab2_shoot_beauty_microdermabrasion_save, pv_tab2_shoot_beauty_oneclickbody_save, pv_tab2_shoot_beauty_removieacnefreckles_save, pv_tab2_shoot_beauty_removiedarkcircles_save, pv_tab2_shoot_beauty_removienasolabial_save, pv_tab2_shoot_beauty_shrinkhead_save, pv_tab2_shoot_beauty_softhair_save, pv_tab2_shoot_beauty_teethwhitening_save, pv_tab2_shoot_beauty_thinnose_save, pv_tab2_shoot_makeup_blush_save, pv_tab2_shoot_makeup_blush_shoot, pv_tab2_shoot_makeup_contactlenses_save, pv_tab2_shoot_makeup_contactlenses_shoot, pv_tab2_shoot_makeup_dyehair_save, pv_tab2_shoot_makeup_dyehair_shoot, pv_tab2_shoot_makeup_eyebrow_save, pv_tab2_shoot_makeup_eyebrow_shoot, pv_tab2_shoot_makeup_eyelash_save, pv_tab2_shoot_makeup_eyelash_shoot, pv_tab2_shoot_makeup_eyeshadow_save, pv_tab2_shoot_makeup_eyeshadow_shoot, pv_tab2_shoot_makeup_freckle_save, pv_tab2_shoot_makeup_freckle_shoot, pv_tab2_shoot_makeup_lipstick_save, pv_tab2_shoot_makeup_lipstick_shoot, pv_tab2_shoot_makeup_lyingsilkworm_save, pv_tab2_shoot_makeup_lyingsilkworm_shoot, pv_tab2_shoot_makeup_trimming_save, pv_tab2_shoot_makeup_trimming_shoot
--         ,grow_aigc_enter_pv,grow_aigc_use_pv,grow_aigc_save_pv,grow_pop_exposure,grow_pop_click,grow_content_exposure,grow_content_click,grow_max_module_positon,grow_sub_page_enter,grow_sub_page_click,grow_max_impression_pv,grow_impression_pv,grow_click_pv
--         ,grow_pay_function_click_pv,grow_free_function_click_pv,grow_free_function_save_pv,grow_pay_duffle_click_pv,grow_free_duffle_click_pv,grow_free_duffle_save_pv

        , coalesce(case when coalesce(pv_tab0_edit_save,0)+coalesce(pv_tab0_shoot_save,0)=0 then null
               else round(coalesce(pv_tab0_edit_save,0)/(coalesce(pv_tab0_edit_save,0)+coalesce(pv_tab0_shoot_save,0)),4)
         end,-1) save_beauty_ratio
        , coalesce(case when coalesce(pv_tab0_edit_entry,0)+coalesce(pv_tab0_selfie_entry,0)=0 then null
               else round(coalesce(pv_tab0_edit_entry,0)/(coalesce(pv_tab0_edit_entry,0)+coalesce(pv_tab0_selfie_entry,0)),4)
         end,-1) enter_beauty_ratio
        , coalesce(case when coalesce(pv_tab0_edit_entry,0)=0 then null
               else round(coalesce(pv_tab0_edit_save,0)/coalesce(pv_tab0_edit_entry,0),4)
         end,-1) beauty_enter_to_save_ratio

         , coalesce(case when coalesce(pv_tab0_edit_save_30,0)+coalesce(pv_tab0_shoot_save_30,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_30,0)/(coalesce(pv_tab0_edit_save_30,0)+coalesce(pv_tab0_shoot_save_30,0)),4)
         end,-1) save_beauty_ratio_30
        , coalesce(case when coalesce(pv_tab0_edit_entry_30,0)+coalesce(pv_tab0_selfie_entry_30,0)=0 then null
               else round(coalesce(pv_tab0_edit_entry_30,0)/(coalesce(pv_tab0_edit_entry_30,0)+coalesce(pv_tab0_selfie_entry_30,0)),4)
         end,-1) enter_beauty_ratio_30
        , coalesce(case when coalesce(pv_tab0_edit_entry_30,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_30,0)/coalesce(pv_tab0_edit_entry_30,0),4)
         end,-1) beauty_enter_to_save_ratio_30

        , coalesce(case when coalesce(pv_tab0_edit_save_60,0)+coalesce(pv_tab0_shoot_save_60,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_60,0)/(coalesce(pv_tab0_edit_save_60,0)+coalesce(pv_tab0_shoot_save_60,0)),4)
         end,-1) save_beauty_ratio_60
        , coalesce(case when coalesce(pv_tab0_edit_entry_60,0)+coalesce(pv_tab0_selfie_entry_60,0)=0 then null
               else round(coalesce(pv_tab0_edit_entry_60,0)/(coalesce(pv_tab0_edit_entry_60,0)+coalesce(pv_tab0_selfie_entry_60,0)),4)
         end,-1) enter_beauty_ratio_60
        , coalesce(case when coalesce(pv_tab0_edit_entry_60,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_60,0)/coalesce(pv_tab0_edit_entry_60,0),4)
         end,-1) beauty_enter_to_save_ratio_60

        , coalesce(case when coalesce(pv_tab0_edit_save_90,0)+coalesce(pv_tab0_shoot_save_90,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_90,0)/(coalesce(pv_tab0_edit_save_90,0)+coalesce(pv_tab0_shoot_save_90,0)),4)
         end,-1) save_beauty_ratio_90
        , coalesce(case when coalesce(pv_tab0_edit_entry_90,0)+coalesce(pv_tab0_selfie_entry_90,0)=0 then null
               else round(coalesce(pv_tab0_edit_entry_90,0)/(coalesce(pv_tab0_edit_entry_90,0)+coalesce(pv_tab0_selfie_entry_90,0)),4)
         end,-1) enter_beauty_ratio_90
        , coalesce(case when coalesce(pv_tab0_edit_entry_90,0)=0 then null
               else round(coalesce(pv_tab0_edit_save_90,0)/coalesce(pv_tab0_edit_entry_90,0),4)
         end,-1) beauty_enter_to_save_ratio_90

        , coalesce(function_num,-1) function_num, coalesce(function_num_pre,-1) function_num_pre, coalesce(grow_function_num,-1) grow_function_num
        , coalesce(function_num_30,-1) function_num_30, coalesce(function_num_60,-1) function_num_60, coalesce(function_num_90,-1) function_num_90

--         ,grow_edit_enter_pv,grow_edit_save_pv,grow_take_photo_pv,grow_take_photo_save_pv,grow_selftake_enter_pv,grow_take_video_pv,grow_take_video_save_pv
        , coalesce(case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
               else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
         end,-1) pay_duffle_click_ratio
--         ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) = 0 then 0
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.01 then 2
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.01 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.05 then 3
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.05 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.1 then 4
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.1 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.2 then 5
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.2 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.3 then 6
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.3 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.4 then 7
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.4 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.5 then 8
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.5 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.6 then 9
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.6 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.7 then 10
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.7 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.8 then 11
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.8 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) <= 0.9 then 12
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) > 0.9 and coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) < 1 then 13
--              when coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0)) = 1 then 1  -- 比例为1时订阅率反而更低了
--         end pay_duffle_click_ratio_type

        , coalesce(case when coalesce(free_duffle_click_pv_30,0)=0 and coalesce(pay_duffle_click_pv_30,0)=0 then null
               else coalesce(pay_duffle_click_pv_30,0)/(coalesce(free_duffle_click_pv_30,0)+coalesce(pay_duffle_click_pv_30,0))
         end,-1) pay_duffle_click_ratio_30
         , coalesce(case when coalesce(free_duffle_click_pv_60,0)=0 and coalesce(pay_duffle_click_pv_60,0)=0 then null
               else coalesce(pay_duffle_click_pv_60,0)/(coalesce(free_duffle_click_pv_60,0)+coalesce(pay_duffle_click_pv_60,0))
         end,-1) pay_duffle_click_ratio_60
         , coalesce(case when coalesce(free_duffle_click_pv_90,0)=0 and coalesce(pay_duffle_click_pv_90,0)=0 then null
               else coalesce(pay_duffle_click_pv_90,0)/(coalesce(free_duffle_click_pv_90,0)+coalesce(pay_duffle_click_pv_90,0))
         end,-1) pay_duffle_click_ratio_90

        , coalesce(case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
               else coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0))
         end,-1) pay_function_click_ratio
--         ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) = 0 then 1
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.05 then 2
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.05 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.1 then 3
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.1 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.2 then 4
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.2 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.3 then 5
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.3 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.4 then 6
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.4 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.5 then 7
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.5 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.6 then 8
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.6 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.7 then 9
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.7 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.8 then 10
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.8 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) <= 0.9 then 11
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) > 0.9 and coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) < 1 then 12
--              when coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0)) = 1 then 0
--          end pay_function_click_ratio_type

        , coalesce(case when coalesce(free_function_click_pv_30,0)=0 and coalesce(pay_function_click_pv_30,0)=0 then null
               else coalesce(pay_function_click_pv_30,0)/(coalesce(free_function_click_pv_30,0)+coalesce(pay_function_click_pv_30,0))
         end,-1) pay_function_click_ratio_30
         , coalesce(case when coalesce(free_function_click_pv_60,0)=0 and coalesce(pay_function_click_pv_60,0)=0 then null
               else coalesce(pay_function_click_pv_60,0)/(coalesce(free_function_click_pv_60,0)+coalesce(pay_function_click_pv_60,0))
         end,-1) pay_function_click_ratio_60
         , coalesce(case when coalesce(free_function_click_pv_90,0)=0 and coalesce(pay_function_click_pv_90,0)=0 then null
               else coalesce(pay_function_click_pv_90,0)/(coalesce(free_function_click_pv_90,0)+coalesce(pay_function_click_pv_90,0))
         end,-1) pay_function_click_ratio_90

        , coalesce(case when coalesce(install_days+1,0)=0 then null
               else coalesce(life_time_active_days,0)/coalesce(install_days+1,0)
         end,-1) life_time_active_ratio

        , coalesce(case when coalesce(pop_exposure,0)=0 then null
               else round(coalesce(pop_click,0)/coalesce(pop_exposure,0),4)
         end,-1) pop_click_ratio
        , coalesce(case when coalesce(content_exposure,0)=0 then null
               else round(coalesce(content_click,0)/coalesce(content_exposure,0),4)
         end,-1) content_click_ratio

        , coalesce(case when coalesce(pop_exposure_30,0)=0 then null
               else round(coalesce(pop_click_30,0)/coalesce(pop_exposure_30,0),4)
         end,-1) pop_click_ratio_30
        , coalesce(case when coalesce(content_exposure_30,0)=0 then null
               else round(coalesce(content_click_30,0)/coalesce(content_exposure_30,0),4)
         end,-1) content_click_ratio_30
        , coalesce(case when coalesce(pop_exposure_60,0)=0 then null
               else round(coalesce(pop_click_60,0)/coalesce(pop_exposure_60,0),4)
         end,-1) pop_click_ratio_60
        , coalesce(case when coalesce(content_exposure_60,0)=0 then null
               else round(coalesce(content_click_60,0)/coalesce(content_exposure_60,0),4)
         end,-1) content_click_ratio_60
        , coalesce(case when coalesce(pop_exposure_90,0)=0 then null
               else round(coalesce(pop_click_90,0)/coalesce(pop_exposure_90,0),4)
         end,-1) pop_click_ratio_90
        , coalesce(case when coalesce(content_exposure_90,0)=0 then null
               else round(coalesce(content_click_90,0)/coalesce(content_exposure_90,0),4)
         end,-1) content_click_ratio_90

         , coalesce(case when coalesce(sub_page_enter,0)=0 then null
               else round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4)
         end,-1) sub_page_click_ratio
--         ,case when coalesce(sub_page_enter,0)=0 then null
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) = 0 then 1
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.1 then 2
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.1 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.2 then 3
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.2 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.3 then 4
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.3 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.4 then 5
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.4 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.5 then 6
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.5 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) <= 0.7 then 7
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) > 0.7 and round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) < 1 then 8
--              when round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4) = 1 then 9
--         end sub_page_click_ratio_type

         , coalesce(case when coalesce(sub_page_enter_30,0)=0 then null
               else round(coalesce(sub_page_click_30,0)/coalesce(sub_page_enter_30,0),4)
         end,-1) sub_page_click_ratio_30
         , coalesce(case when coalesce(sub_page_enter_60,0)=0 then null
               else round(coalesce(sub_page_click_60,0)/coalesce(sub_page_enter_60,0),4)
         end,-1) sub_page_click_ratio_60
         , coalesce(case when coalesce(sub_page_enter_90,0)=0 then null
               else round(coalesce(sub_page_click_90,0)/coalesce(sub_page_enter_90,0),4)
         end,-1) sub_page_click_ratio_90

        , coalesce(case when coalesce(sub_page_enter,0)=0 then null
               else round(coalesce(subscript_sub_page_enter,0)/coalesce(sub_page_enter,0),4)
        end,-1) subscript_sub_page_enter_ratio
        , coalesce(case when coalesce(sub_page_enter_30,0)=0 then null
               else round(coalesce(subscript_sub_page_enter_30,0)/coalesce(sub_page_enter_30,0),4)
        end,-1) subscript_sub_page_enter_ratio_30
        , coalesce(case when coalesce(sub_page_enter_60,0)=0 then null
               else round(coalesce(subscript_sub_page_enter_60,0)/coalesce(sub_page_enter_60,0),4)
        end,-1) subscript_sub_page_enter_ratio_60
        , coalesce(case when coalesce(sub_page_enter_90,0)=0 then null
               else round(coalesce(subscript_sub_page_enter_90,0)/coalesce(sub_page_enter_90,0),4)
        end,-1) subscript_sub_page_enter_ratio_90

        , coalesce(homepage_exposure_pv,-1) homepage_exposure_pv, coalesce(homepage_click_pv,-1) homepage_click_pv, coalesce(homepage_feature_show_pv,-1) homepage_feature_show_pv, coalesce(homepage_feature_click_pv,-1) homepage_feature_click_pv, coalesce(homepage_banner_show_pv,-1) homepage_banner_show_pv, coalesce(homepage_banner_click_pv,-1) homepage_banner_click_pv, coalesce(homepage_reconmend_show_pv,-1) homepage_reconmend_show_pv, coalesce(homepage_reconmend_click_pv,-1) homepage_reconmend_click_pv, coalesce(homepage_topic_show_pv,-1) homepage_topic_show_pv, coalesce(homepage_topic_click_pv,-1) homepage_topic_click_pv, coalesce(homepage_miniapp_show_pv,-1) homepage_miniapp_show_pv, coalesce(homepage_miniapp_click_pv,-1) homepage_miniapp_click_pv
        , coalesce(homepage_exposure_pv_30,-1) homepage_exposure_pv_30, coalesce(homepage_click_pv_30,-1) homepage_click_pv_30, coalesce(homepage_feature_show_pv_30,-1) homepage_feature_show_pv_30, coalesce(homepage_feature_click_pv_30,-1) homepage_feature_click_pv_30, coalesce(homepage_banner_show_pv_30,-1) homepage_banner_show_pv_30, coalesce(homepage_banner_click_pv_30,-1) homepage_banner_click_pv_30, coalesce(homepage_reconmend_show_pv_30,-1) homepage_reconmend_show_pv_30, coalesce(homepage_reconmend_click_pv_30,-1) homepage_reconmend_click_pv_30, coalesce(homepage_topic_show_pv_30,-1) homepage_topic_show_pv_30, coalesce(homepage_topic_click_pv_30,-1) homepage_topic_click_pv_30, coalesce(homepage_miniapp_show_pv_30,-1) homepage_miniapp_show_pv_30, coalesce(homepage_miniapp_click_pv_30,-1) homepage_miniapp_click_pv_30
        , coalesce(homepage_exposure_pv_60,-1) homepage_exposure_pv_60, coalesce(homepage_click_pv_60,-1) homepage_click_pv_60, coalesce(homepage_feature_show_pv_60,-1) homepage_feature_show_pv_60, coalesce(homepage_feature_click_pv_60,-1) homepage_feature_click_pv_60, coalesce(homepage_banner_show_pv_60,-1) homepage_banner_show_pv_60, coalesce(homepage_banner_click_pv_60,-1) homepage_banner_click_pv_60, coalesce(homepage_reconmend_show_pv_60,-1) homepage_reconmend_show_pv_60, coalesce(homepage_reconmend_click_pv_60,-1) homepage_reconmend_click_pv_60, coalesce(homepage_topic_show_pv_60,-1) homepage_topic_show_pv_60, coalesce(homepage_topic_click_pv_60,-1) homepage_topic_click_pv_60, coalesce(homepage_miniapp_show_pv_60,-1) homepage_miniapp_show_pv_60, coalesce(homepage_miniapp_click_pv_60,-1) homepage_miniapp_click_pv_60
        , coalesce(homepage_exposure_pv_90,-1) homepage_exposure_pv_90, coalesce(homepage_click_pv_90,-1) homepage_click_pv_90, coalesce(homepage_feature_show_pv_90,-1) homepage_feature_show_pv_90, coalesce(homepage_feature_click_pv_90,-1) homepage_feature_click_pv_90, coalesce(homepage_banner_show_pv_90,-1) homepage_banner_show_pv_90, coalesce(homepage_banner_click_pv_90,-1) homepage_banner_click_pv_90, coalesce(homepage_reconmend_show_pv_90,-1) homepage_reconmend_show_pv_90, coalesce(homepage_reconmend_click_pv_90,-1) homepage_reconmend_click_pv_90, coalesce(homepage_topic_show_pv_90,-1) homepage_topic_show_pv_90, coalesce(homepage_topic_click_pv_90,-1) homepage_topic_click_pv_90, coalesce(homepage_miniapp_show_pv_90,-1) homepage_miniapp_show_pv_90, coalesce(homepage_miniapp_click_pv_90,-1) homepage_miniapp_click_pv_90

from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where active_days_365>0 and is_current_pay=1


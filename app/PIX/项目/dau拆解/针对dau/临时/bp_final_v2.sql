-- beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v2

select date,user_pseudo_id
       ,case when region in ('United States','Japan','United Kingdom','South Korea','Thailand') then region else 'else' end region
       ,platform
       ,sub_365 sub_no_trial_365
--        ,case when sub_no_trial_year_365>0 then 1
--              when sub_no_trial_month_365>0 then 2
--              when sub_no_trial_other_365>0 then 3
--        else 0 end sub_no_trial_flag_365
       ,active_mins,active_sessions,active_days
       ,`pv_0级tab-修图---保存`,`pv_0级tab-修图---进入`,`pv_0级tab-拍摄---保存`,`pv_0级tab-拍摄---拍摄`,`pv_0级tab-电影---保存`,`pv_0级tab-电影---拍摄`,`pv_0级tab-自拍---进入`,`pv_0级tab-视频---保存`,`pv_0级tab-视频---拍摄`,`pv_0级tab-视频编辑---保存`,`pv_0级tab-视频编辑---进入`,`pv_1级tab-修图-创意--保存`,`pv_1级tab-修图-创意--点击`,`pv_1级tab-修图-滤镜--保存`,`pv_1级tab-修图-滤镜--点击`,`pv_1级tab-修图-编辑--保存`,`pv_1级tab-修图-编辑--点击`,`pv_1级tab-修图-美妆--保存`,`pv_1级tab-修图-美妆--点击`,`pv_1级tab-修图-美颜--保存`,`pv_1级tab-修图-美颜--点击`,`pv_1级tab-修图-高级编辑--点击`,`pv_1级tab-拍摄-AR--保存`,`pv_1级tab-拍摄-AR--拍摄`,`pv_1级tab-拍摄-Look--保存`,`pv_1级tab-拍摄-Look--拍摄`,`pv_1级tab-拍摄-滤镜--保存`,`pv_1级tab-拍摄-滤镜--拍摄`,`pv_1级tab-拍摄-美妆--保存`,`pv_1级tab-拍摄-美妆--拍摄`,`pv_1级tab-拍摄-美颜--保存`
       ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click,max_impression_pv,impression_pv,click_pv,puzzle_click_pv,puzzle_save_pv,pay_function_click_pv,free_function_click_pv,free_function_save_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv,function_num
       ,brand,last_active_days,active_category,life_time_active_days
       ,active_mins_7d,active_sessions_7d,active_mins_90d,active_sessions_90d,active_days_7d,active_days_90d,active_days_14d,active_days_31d,active_days_60d
       ,pay_function_click_pv_31,free_function_click_pv_31,free_function_save_pv_31,aigc_enter_pv_31,aigc_use_pv_31,aigc_save_pv_31,pop_exposure_31,pop_click_31,content_exposure_31,content_click_31,max_module_positon_31,sub_page_enter_31,sub_page_click_31,max_impression_pv_31,impression_pv_31,click_pv_31,pay_duffle_click_pv_31,free_duffle_click_pv_31,free_duffle_save_pv_31,function_num_31
       ,days,pay_duffle_click_ratio,pay_duffle_click_ratio_31,pay_function_click_ratio,pay_function_click_ratio_31
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
where is_paying='un-Paying' and is_consum='un-consumable'

DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2024-01-01');
DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2024-02-28');

-- DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2022-12-01');
-- DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2022-12-25');

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre as


delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre



select date,user_pseudo_id
        ,sum(aigc_enter_pv) aigc_enter_pv
        ,sum(aigc_use_pv) aigc_use_pv
        ,sum(aigc_save_pv) aigc_save_pv
        ,sum(pop_exposure) pop_exposure
        ,sum(pop_click) pop_click
        ,sum(content_exposure) content_exposure
        ,sum(content_click) content_click
        ,sum(max_module_positon) max_module_positon
        ,sum(sub_page_enter) sub_page_enter
        ,sum(sub_page_click) sub_page_click
        ,sum(max_impression_pv) max_impression_pv
        ,sum(impression_pv) impression_pv
        ,sum(click_pv) click_pv
    from
    (
        select date,user_pseudo_id
            ,sum(case when action='enter' then pv end) aigc_enter_pv
            ,sum(case when action='use' then pv end) aigc_use_pv
            ,sum(case when action='save' then pv end) aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
        from `beautyplus-bc0ed.temp.dws_act_aigc_new`
        where date between mDATE_START and mDATE_END
        group by 1,2

        union all

        -- 弹窗功能
        select event_date_hk date,user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,sum(case when event_name in ('home_page_pop_appr_bd') then pv end) AS pop_exposure
            ,sum(case when event_name in ('home_page_pop_clk_bd') then pv end) AS pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
        from `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
        where event_date_hk between mDATE_START and mDATE_END
        group by 1,2

        union all

        -- 首页下滑情况(这个数据比较多估计，可以先join目标用户再算)
        select event_date date,user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,count(case when event_name in ('home_content_show_f_bd') then 1 end) AS content_exposure
            ,count(case when event_name in ('home_content_clk_bd') then 1 end) AS content_click
            ,max(case when event_name in ('home_content_show_f_bd') then cast(module_positon as int64) end) max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
        from `beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new`
        where event_date between mDATE_START and mDATE_END
        group by 1,2

        union all

        -- 订阅页面数据
        select date,user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,count(case when event_name in ('page_event') then 1 end) AS sub_page_enter
            ,count(case when event_name in ('subscription_clk_try') then 1 end) AS sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
        from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
        where date between mDATE_START and mDATE_END
        group by 1,2

        union all

        -- 广告情况
        select event_date date,firebase_id user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,count(case when from_event = 0 and action = 'show' then 1 end) AS max_impression_pv
            ,count(case when from_event = 1 and action = 'show' then 1 end) AS impression_pv
            ,count(case when from_event = 1 and action = 'click' then 1 end) AS click_pv
        from `dataintegration-265403.dwd.dwd_dzp_advertisement_user_detail`
        where event_date between mDATE_START and mDATE_END and app_name='BeautyPlus'
        group by 1,2
    )
group by 1,2
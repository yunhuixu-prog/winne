-- DECLARE mDATE_START DATE DEFAULT '2022-10-01';
-- DECLARE mDATE_END DATE DEFAULT '2024-05-20';
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
-- 评分的没几条数
-- drop table if exists airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre;
-- create table airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre as
delete from airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre where event_date  between mDATE_START and mDATE_END;
insert into airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre
select event_date,user_pseudo_id,event_name
    -- ,func.getParams(event_params,'page_name').string_value page_name
    ,cast(func.getParams(event_params,'score').string_value as int)  score
from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_START as string), cast(mDATE_END as string), 'airbrush', false)
where event_name in ('score_popup_show','score_popup_click'
,'popup_show','popup_click'
,'save_share','camera_save_share')
;

-- drop table if exists airbrush-1324.temp.dws_dz_dau_split_user_other_behave;
-- create table airbrush-1324.temp.dws_dz_dau_split_user_other_behave as

delete from airbrush-1324.temp.dws_dz_dau_split_user_other_behave where date between mDATE_START and mDATE_END;
insert into airbrush-1324.temp.dws_dz_dau_split_user_other_behave

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
        ,sum(force_sub_page_enter) force_sub_page_enter
        ,sum(force_sub_page_click) force_sub_page_click
        ,sum(subscript_sub_page_enter) subscript_sub_page_enter
        ,sum(subscript_sub_page_click) subscript_sub_page_click
        ,sum(other_sub_page_enter) other_sub_page_enter
        ,sum(other_sub_page_click) other_sub_page_click
        ,sum(max_impression_pv) max_impression_pv
        ,sum(impression_pv) impression_pv
        ,sum(click_pv) click_pv
        ,sum(share_pv) share_pv
        ,sum(search_pv) search_pv
        ,sum(eva_imp_pv) eva_imp_pv
        ,sum(eva_pv) eva_pv
        ,sum(high_eva_pv) high_eva_pv
    from
    (
        select event_date as date,user_pseudo_id
            ,sum(case when  event_name LIKE 'ai_%_enter' then pv end) aigc_enter_pv
            ,sum(case when  event_name LIKE 'ai_%_generate' then pv end) aigc_use_pv
            ,sum(case when  event_name LIKE 'ai_%_download' then pv end) aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,0 force_sub_page_enter
            ,0 force_sub_page_click
            ,0 subscript_sub_page_enter
            ,0 subscript_sub_page_click
            ,0 other_sub_page_enter
            ,0 other_sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
            ,0 share_pv
            ,0 search_pv
            ,0 eva_imp_pv
            ,0 eva_pv
            ,0 high_eva_pv
        from `airbrush-1324.stat.dwd_dz_ab_aigc_event`
        where event_date between mDATE_START and mDATE_END
        group by 1,2

        union all

        -- 弹窗功能
        select event_date date,user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,sum(case when event_name in ('popup_show') then 1 end) AS pop_exposure
            ,sum(case when event_name in ('popup_click') then 1 end) AS pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,0 sub_page_enter
            ,0 sub_page_click
            ,0 force_sub_page_enter
            ,0 force_sub_page_click
            ,0 subscript_sub_page_enter
            ,0 subscript_sub_page_click
            ,0 other_sub_page_enter
            ,0 other_sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
            ,0 share_pv
            ,0 search_pv
            ,0 eva_imp_pv
            ,0 eva_pv
            ,0 high_eva_pv
        -- from `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_START as string), cast(mDATE_END as string), 'airbrush', false)
        -- group by 1,2
        from airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre
        where event_name in('popup_show','popup_click')
         group by 1,2

        -- union all

        -- -- 首页下滑情况(这个数据比较多估计，可以先join目标用户再算)
        -- select event_date date,user_pseudo_id
        --     ,0 aigc_enter_pv
        --     ,0 aigc_use_pv
        --     ,0 aigc_save_pv
        --     ,0 pop_exposure
        --     ,0 pop_click
        --     ,count(case when event_name in ('home_content_show_f_bd') then 1 end) AS content_exposure
        --     ,count(case when event_name in ('home_content_clk_bd') then 1 end) AS content_click
        --     ,max(case when event_name in ('home_content_show_f_bd') then cast(module_positon as int64) end) max_module_positon
        --     ,0 sub_page_enter
        --     ,0 sub_page_click
        --     ,0 force_sub_page_enter
        --     ,0 force_sub_page_click
        --     ,0 subscript_sub_page_enter
        --     ,0 subscript_sub_page_click
        --     ,0 other_sub_page_enter
        --     ,0 other_sub_page_click
        --     ,0 max_impression_pv
        --     ,0 impression_pv
        --     ,0 click_pv
        --     ,0 share_pv
        --     ,0 search_pv
        --     ,0 eva_imp_pv
        --     ,0 eva_pv
        --     ,0 high_eva_pv
        -- from `beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new`
        -- where event_date between mDATE_START and mDATE_END
        -- group by 1,2

        union all
        -- 强行弹窗/onboarding：去广告订阅弹窗，防截屏弹窗，订阅页挽留弹窗，订阅策略触发，每日打开弹出订阅
        -- 订阅角标：默认入口，弹窗，自拍页新用户icon，图层编辑，横幅，首页悬浮icon订阅入口，首页默认订阅入口，额度管理默认入口
        -- 打勾/拍照/保存：保存，打勾确认，拍摄，H5页面，蒙太奇添加形象，其他
        SELECT event_date date
            ,user_pseudo_id
            ,0 aigc_enter_pv
            ,0 aigc_use_pv
            ,0 aigc_save_pv
            ,0 pop_exposure
            ,0 pop_click
            ,0 content_exposure
            ,0 content_click
            ,0 max_module_positon
            ,sum(case when event_name in ('w_subscription_enter') then 1 end) AS sub_page_enter
            ,sum(case when event_name in ('w_subscription_click') then 1 end) AS sub_page_click
            --强制弹的
            ,sum(case when event_name='w_subscription_enter' and (source_module in ('p_onboarding')  or source_00 in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021')) then 1 end) force_sub_page_enter
            ,sum(case when event_name='w_subscription_click' and (source_module in ('p_onboarding')  or source_00 in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021')) then 1 end) force_sub_page_click
            --用户主动点的
            ,sum(case when event_name='w_subscription_enter' and (source_module ='p_ads' or source_00 in('hbr','hpbs','home_sub_banner','f_ads_remove','f_vip_icon') or source_11 in('upgrade_subscription')) then 1 end) subscript_sub_page_enter
            ,sum(case when event_name='w_subscription_click' and (source_module ='p_ads' or source_00 in('hbr','hpbs','home_sub_banner','f_ads_remove','f_vip_icon') or source_11 in('upgrade_subscription')) then 1 end) subscript_sub_page_click
            -- 其他的 点了save等用户没有预期弹出的
            ,sum(case when event_name='w_subscription_enter' and source_module not in ('p_onboarding','p_ads')
            and source_00 not in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021','hbr','hpbs','home_sub_banner','f_ads_remove','f_vip_icon') and source_11 not in('upgrade_subscription') then 1 end) other_sub_page_enter
            ,sum(case when event_name='w_subscription_click'and  source_module not in ('p_onboarding','p_ads')
            and source_00 not in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021','hbr','hpbs','home_sub_banner','f_ads_remove','f_vip_icon') and source_11 not in('upgrade_subscription') then 1 end) other_sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
            ,0 share_pv
            ,0 search_pv
            ,0 eva_imp_pv
            ,0 eva_pv
            ,0 high_eva_pv
        FROM
        `airbrush-1324.tmp.sub_client_source`
        WHERE
            event_date between mDATE_START and mDATE_END
            and (event_name IN ('w_subscription_enter','w_subscription_click'))
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
            ,0 force_sub_page_enter
            ,0 force_sub_page_click
            ,0 subscript_sub_page_enter
            ,0 subscript_sub_page_click
            ,0 other_sub_page_enter
            ,0 other_sub_page_click
            ,count(case when from_event = 0 and action = 'show' then 1 end) AS max_impression_pv
            ,count(case when from_event = 1 and action = 'show' then 1 end) AS impression_pv
            ,count(case when from_event = 1 and action = 'click' then 1 end) AS click_pv
            ,0 share_pv
            ,0 search_pv
            ,0 eva_imp_pv
            ,0 eva_pv
            ,0 high_eva_pv
        from `dataintegration-265403.dwd.dwd_dzp_advertisement_user_detail`
        where event_date between mDATE_START and mDATE_END and app_name='AirBrush'
        group by 1,2

        union all

        select
            event_date date
            ,user_pseudo_id
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
            ,0 force_sub_page_enter
            ,0 force_sub_page_click
            ,0 subscript_sub_page_enter
            ,0 subscript_sub_page_click
            ,0 other_sub_page_enter
            ,0 other_sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
             ,sum(case when event_name in ('save_share','camera_save_share') then 1 end) share_pv
            ,0 search_pv
            ,0 eva_imp_pv
            ,0 eva_pv
            ,0 high_eva_pv
        from airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre
        where event_name in ('save_share','camera_save_share')
        group by 1,2

        -- union all

        -- -- 搜索（23年下半年才有）
        -- select event_date date
        --         ,user_pseudo_id
        --         ,0 aigc_enter_pv
        --         ,0 aigc_use_pv
        --         ,0 aigc_save_pv
        --         ,0 pop_exposure
        --         ,0 pop_click
        --         ,0 content_exposure
        --         ,0 content_click
        --         ,0 max_module_positon
        --         ,0 sub_page_enter
        --         ,0 sub_page_click
        --         ,0 force_sub_page_enter
        --         ,0 force_sub_page_click
        --         ,0 subscript_sub_page_enter
        --         ,0 subscript_sub_page_click
        --         ,0 other_sub_page_enter
        --         ,0 other_sub_page_click
        --         ,0 max_impression_pv
        --         ,0 impression_pv
        --         ,0 click_pv
        --         ,0 share_pv
        --         ,sum(pv) as search_pv
        --         ,0 eva_imp_pv
        --         ,0 eva_pv
        --         ,0 high_eva_pv
        -- from airbrush-1324.temp.dwd_search_behavior
        -- where event_date between mDATE_START and mDATE_END
        --     and event_name in ('material_search_content_bd')
        -- group by 1,2

        union all

        select event_date date
            ,user_pseudo_id
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
            ,0 force_sub_page_enter
            ,0 force_sub_page_click
            ,0 subscript_sub_page_enter
            ,0 subscript_sub_page_click
            ,0 other_sub_page_enter
            ,0 other_sub_page_click
            ,0 max_impression_pv
            ,0 impression_pv
            ,0 click_pv
            ,0 share_pv
            ,0 search_pv
            ,sum(case when event_name = 'score_popup_show' then 1 end) eva_imp_pv
            ,sum(case when event_name = 'score_popup_click' then 1 end) eva_pv
            ,sum(case when event_name = 'score_popup_click' and score >=4 then 1 end) high_eva_pv
        from airbrush-1324.temp.dws_dz_dau_split_user_other_behave_pre
        where event_name = 'score_popup_show'
            or (event_name = 'score_popup_click' and score between 1 and 5)
        group by 1,2

    )
group by 1,2
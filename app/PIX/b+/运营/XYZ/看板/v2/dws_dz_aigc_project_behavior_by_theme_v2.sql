
-- drop table if exists `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme`;
-- create table if not exists `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme` as

delete from  `dataintegration-265403.aigc.dws_dz_aigc_project_behavior_by_theme_v2`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.aigc.dws_dz_aigc_project_behavior_by_theme_v2`
(
    app_name
    ,date
    ,platform
    ,country
    ,is_new
    ,is_UA
    ,project_name
    ,status
    ,entry
    ,source
    ,theme_type
    ,theme
    ,theme_id
    ,exposure_uv
    ,click_uv
    ,enter_generate_page_uv
    ,click_generate_uv
    ,save_uv
    ,share_uv

    ,exposure_pv
    ,click_pv
    ,enter_generate_page_pv
    ,click_generate_pv
    ,save_pv
    ,share_pv
    ,generate_photo_num
    ,save_photo_num

    ,sub_uv
    ,sub_pay_uv
    ,sub_revenue
)

with user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)
,
bp_other_subscription_pre as
(
    select e.*,material_name
    from
    (
        select
            'BeautyPlus' app_name
            ,date
            ,platform
            ,country
            ,cur_page_type
            ,s source_feature_content
            ,user_pseudo_id
            ,original_order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`,unnest(SPLIT(source2, '、')) s
        where
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
            and (s like '%TEM%' or s like '%STY%')
    ) e
    join (select app,platform,m_id Material_id,start_date,end_date,max(name) material_name
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where (remark in ('AI style') and theme='TEM') or ( theme='STY') --20251216 修改 remark in ('风格化-AIGC') and
            group by 1,2,3,4,5

            union all

            select 'Beauty Plus Cam' app,platform,m_id Material_id,start_date,end_date,max(name) material_name
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY')) and app='BeautyPlus' and platform='ANDROID'
            group by 1,2,3,4,5
    ) st
    ON e.app_name = st.app
        AND e.platform = st.platform
        AND e.source_feature_content=st.Material_id
        AND e.date >= st.start_date
        AND e.date < st.end_date
)
,
bp_subscription_pre as
(
    select *
        ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_1
            else source2_2
        end source2
        ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_2
            else source2_1
        end theme
    from
    (
        select
            'BeautyPlus' app_name
            ,date
            ,platform
            ,country
            ,cur_page_type
            ,source1
            ,split(source2,'+')[0] source2_1
            ,if(ARRAY_LENGTH(split(source2,'+'))>=2,split(source2,'+')[1],null) source2_2
            ,user_pseudo_id
            ,original_order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
        where
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
    )
    where source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        or source2_2 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
)
,
ab_subscription_pre as
(
    select 'AirBrush' app_name
            ,event_date date
            ,first
            ,second
--             ,third theme -- 主题
            ,REPLACE(third,'_',' ') theme -- 主题
            ,platform
            ,case when is_new='New' then 1 else 0 end is_new
            ,country
            ,is_ua
            ,sub_success_uv,sub_to_paid_uv,sub_to_paid_revenue_sub
    from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and fourth='A' and third not in ('A','all','-') and third is not null
--             and second in (select distinct Ab_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        and sale_status not in ('credit')

    -- 重新写订阅的吧
    select
)
,
subscription as
(
    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,e.is_new
        ,e.is_ua is_UA
        ,s.miniapp project_name
        ,cast(null as string) entry
        ,'H5' source
        ,'All' theme_type
        ,theme
        ,theme theme_id
        ,sum(sub_success_uv) sub_uv
        ,sum(sub_to_paid_uv) sub_pay_uv
        ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from ab_subscription_pre e
    join (select Ab_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.second=s.Ab_sub_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,s.miniapp project_name
        ,cast(null as string) entry
        ,'H5' source
        ,'All' theme_type
        ,theme
        ,theme theme_id
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_subscription_pre e
    left join (select Bp_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.source2=s.Bp_sub_name
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,'AI Filter 1.0' project_name
        ,cast(null as string) entry
        ,case when source_feature_content like '%TEM%' then 'Template'
              when source_feature_content like '%STY%' then 'Style' end source
        ,'All' theme_type
        ,material_name theme
        ,source_feature_content theme_id
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_other_subscription_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,e.is_new
        ,e.is_ua is_UA
        ,s.miniapp project_name
        ,'All' entry
        ,'H5' source
        ,'All' theme_type
        ,theme
        ,theme theme_id
        ,sum(sub_success_uv) sub_uv
        ,sum(sub_to_paid_uv) sub_pay_uv
        ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from ab_subscription_pre e
    join (select Ab_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.second=s.Ab_sub_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,s.miniapp project_name
        ,'All' entry
        ,'H5' source
        ,'All' theme_type
        ,theme
        ,theme theme_id
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_subscription_pre e
    left join (select Bp_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.source2=s.Bp_sub_name
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,'AI Filter 1.0' project_name
        ,'All' entry
        ,case when source_feature_content like '%TEM%' then 'Template'
              when source_feature_content like '%STY%' then 'Style' end source
        ,'All' theme_type
        ,material_name theme
        ,source_feature_content theme_id
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_other_subscription_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10,11,12
)
,
event_result as
(
    select
        e.app_name
        ,e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,project_name
        ,'All' entry
        ,source
        ,coalesce(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('to_video') then 'live_photo'
              when source in ('H5') and project in ('ai_filter','ai_portrait') then if(theme_type = 'livephoto','live_photo',theme_type)
              when source in ('H5') and project in ('puriplus') then machine
              when source in ('Template','Style') then 'photo'
        end,'undefined') theme_type
        ,REGEXP_REPLACE(REGEXP_REPLACE(k, r'live photo\+', ''), r'(_[A-Z]{2})$', '') AS theme
        ,case when source in ('Template','Style') then material_id
              else REGEXP_REPLACE(k,r'live photo\+','')
        end theme_id
        ,count(distinct case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f','beauty_style_imp_bd','material_exposure','impression') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when (event_name in ('h5_home_content_clk_bd','h5_home_content_clk') and project in ('ai_filter','AI_Pet_Portray'))
                                    or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('image','frame') and project in ('ai_portrait','puriplus'))
                                    or (event_name in ('beauty_style_clk_bd','material_click','click')) then e.user_pseudo_id end) click_uv

        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then e.user_pseudo_id end) enter_generate_page_uv
        ,count(distinct case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then e.user_pseudo_id end) generate_uv
        ,count(distinct case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then e.user_pseudo_id end) save_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then e.user_pseudo_id end) share_uv


        ,sum(case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f','beauty_style_imp_bd','material_exposure','impression') then pv end) exposure_pv
        ,sum(case when (event_name in ('h5_home_content_clk_bd','h5_home_content_clk') and project in ('ai_filter','AI_Pet_Portray'))
                                    or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('image','frame') and project in ('ai_portrait','puriplus'))
                                    or (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end) click_pv

        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then pv end) enter_generate_page_pv
        ,sum(case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end) generate_pv
        ,sum(case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then pv end) save_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then pv end) share_pv

        ,sum(case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end*coalesce(pkg_num,1)) generate_photo_num
        ,sum(case when (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume')) then pv
                             when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_video','save_gif')) then pv
                             when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save_all') then coalesce(t.pkg_num,1)*pv
                             when (event_name in ('beautifysave_bd','edit_save','save')) then pv end) save_photo_num
    from
        `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
        left join (select name,project projects,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1,2) t on REGEXP_REPLACE(k,r'live photo\+','')=t.name and e.project_name=t.projects
    group by
        1,2,3,4,5,6,7,8,9,10,11,12

    union all

    select
        e.app_name
        ,e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,project_name
        ,entry
        ,source
        ,coalesce(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('to_video') then 'live_photo'
              when source in ('H5') and project in ('ai_filter','ai_portrait') then if(theme_type = 'livephoto','live_photo',theme_type)
              when source in ('H5') and project in ('puriplus') then machine
              when source in ('Template','Style') then 'photo'
        end,'undefined') theme_type
        ,REGEXP_REPLACE(REGEXP_REPLACE(k, r'live photo\+', ''), r'(_[A-Z]{2})$', '') AS theme
        ,case when source in ('Template','Style') then material_id
              else REGEXP_REPLACE(k,r'live photo\+','')
        end theme_id
        ,count(distinct case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f','beauty_style_imp_bd','material_exposure','impression') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when (event_name in ('h5_home_content_clk_bd','h5_home_content_clk') and project in ('ai_filter','AI_Pet_Portray'))
                                    or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('image','frame') and project in ('ai_portrait','puriplus'))
                                    or (event_name in ('beauty_style_clk_bd','material_click','click')) then e.user_pseudo_id end) click_uv

        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then e.user_pseudo_id end) enter_generate_page_uv
        ,count(distinct case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then e.user_pseudo_id end) generate_uv
        ,count(distinct case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then e.user_pseudo_id end) save_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then e.user_pseudo_id end) share_uv


        ,sum(case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f','beauty_style_imp_bd','material_exposure','impression') then pv end) exposure_pv
        ,sum(case when (event_name in ('h5_home_content_clk_bd','h5_home_content_clk') and project in ('ai_filter','AI_Pet_Portray'))
                                    or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('image','frame') and project in ('ai_portrait','puriplus'))
                                    or (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end) click_pv

        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then pv end) enter_generate_page_pv
        ,sum(case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end) generate_pv
        ,sum(case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then pv end) save_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then pv end) share_pv

        ,sum(case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end*coalesce(pkg_num,1)) generate_photo_num
        ,sum(case when (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume')) then pv
                             when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_video','save_gif')) then pv
                             when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save_all') then coalesce(t.pkg_num,1)*pv
                             when (event_name in ('beautifysave_bd','edit_save','save')) then pv end) save_photo_num
    from
        `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
        left join (select name,project projects,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1,2) t on REGEXP_REPLACE(k,r'live photo\+','')=t.name and e.project_name=t.projects
    group by
        1,2,3,4,5,6,7,8,9,10,11,12
)

select
    e.app_name
    ,e.date
    ,e.platform
    ,e.country
    ,e.is_new
    ,e.is_UA
    ,e.project_name
    ,s.status
    ,e.entry
    ,e.source
    ,e.theme_type
    ,e.theme
    ,e.theme_id
    ,sum(exposure_uv) exposure_uv
    ,sum(click_uv) click_uv
    ,sum(enter_generate_page_uv) enter_generate_page_uv
    ,sum(generate_uv) click_generate_uv
    ,sum(save_uv) save_uv
    ,sum(share_uv) share_uv

    ,sum(exposure_pv) exposure_pv
    ,sum(click_pv) click_pv
    ,sum(enter_generate_page_pv) enter_generate_page_pv
    ,sum(generate_pv) click_generate_pv
    ,sum(save_pv) save_pv
    ,sum(share_pv) share_pv

    ,sum(generate_photo_num) generate_photo_num
    ,sum(save_photo_num) save_photo_num

    ,sum(sub_uv) sub_uv
    ,sum(sub_pay_uv) sub_pay_uv
    ,sum(sub_revenue) sub_revenue
from
(
    select app_name,event_date date,platform,country,is_new,is_UA,project_name,entry,source,theme_type,theme,theme_id
            ,exposure_uv,click_uv
            ,enter_generate_page_uv,generate_uv,save_uv,share_uv

            ,exposure_pv,click_pv
            ,enter_generate_page_pv,generate_pv,save_pv,share_pv,generate_photo_num,save_photo_num
            ,0 sub_uv,0 sub_pay_uv,0.0 sub_revenue
    from event_result

    union all

    select app_name,date,platform,country,is_new,is_UA,project_name,entry,source,theme_type,theme,theme_id
            ,0 exposure_uv,0 click_uv
            ,0 enter_generate_page_uv,0 generate_uv,0 save_uv,0 share_uv

            ,0 exposure_pv,0 click_pv
            ,0 enter_generate_page_pv,0 generate_pv,0 save_pv,0 share_pv,0 generate_photo_num,0 save_photo_num
            ,sub_uv,sub_pay_uv,sub_revenue
    from subscription
) e
left join (select Project,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s
on e.project_name=s.Project
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

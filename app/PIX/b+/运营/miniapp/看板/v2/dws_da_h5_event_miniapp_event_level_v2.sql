-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status`
-- `beautyplus-bc0ed.content_data.credit_good_mapping`
-- 347_ads_dz_miniapp_data
-- 新增进入生成页面，生成按钮点击，目前仅保证9.14后上线的miniapp的数据
-- 新增额度充值弹窗曝光，额度充值点击，额度购买成功
drop table if exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_pre_v2`;
create table if not exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_pre_v2` as

with
event_pre_raw as
(
   select
        event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
        ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'h5_id').string_value h5_id
        ,`dataintegration-265403.func`.getParams(event_params,'page_type').string_value page_type
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)
    where
    case    when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='miniapp' or (`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='Banner' and `dataintegration-265403.func`.getParams(event_params,'内容类型').string_value='miniapp'))
            when event_name='h5_page_event_bd' then `dataintegration-265403.func`.getParams(event_params,'page_id').string_value in('home_page_view','style_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2')
            when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('save','save_poster','save_video','material_save','save_collection','save_all','material_share','homepage_share','share','generate')
            when event_name in ('share_page_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'h5_id').string_value is not null
            when event_name in ('web_view_share_bd') then `dataintegration-265403.func`.getParams(event_params,'page_type').string_value is not null
            when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd','h5_preview_save_bd','h5_result_share_bd') then 1=1
            else 1=0
            end
)

    select
        event_date
        ,platform
        -- ,country
        ,event_name
        ,case   when event_name in ('home_content_show_f_bd','home_content_clk_bd','share_page_clk_bd','web_view_share_bd','home_page_pop_appr_bd','home_page_pop_clk_bd','search_miniapp_appr_bd','search_miniapp_clk_bd') then m.miniapp
                when event_name in ('h5_page_event_bd','h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd','h5_preview_save_bd','h5_result_share_bd') then s.miniapp
                else coalesce(miniapp_content_id,project)
                end miniapp_name
        ,project
        ,miniapp_content_id miniapp_id
        ,s.status
        ,page_id
        ,button_type
        ,module_type
        ,version
        ,from_page
        ,user_pseudo_id
        ,pv
    from
        (
        select
            event_date
            ,platform
            -- ,geo.country country
            ,event_name
            ,project
            ,case
                  when event_name = ('share_page_clk_bd') then h5_id
                  when event_name = ('web_view_share_bd') then page_type
                  when event_name in ('home_content_show_f_bd','home_content_clk_bd') and module_type='Banner' then module_id
                  when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then miniapp_id
            else coalesce(content_id,content_type)
            end miniapp_content_id
            ,module_type
            ,page_id
            ,button_type
            ,if(version>='7.6.020','>=7.6.020','<7.6.020') version
            ,case when event_name not in ('home_content_show_f_bd','home_content_clk_bd','share_page_clk_bd','web_view_share_bd','search_miniapp_appr_bd','search_miniapp_clk_bd') then coalesce(from_page,'unknown')
                  when event_name in ('home_content_show_f_bd','home_content_clk_bd') and module_type='Banner' then 'banner'
                  when event_name in ('home_content_show_f_bd','home_content_clk_bd') and module_type='miniapp' then 'MiniAppTab'
                  when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then 'search'
                  when event_name in ('share_page_clk_bd','web_view_share_bd') then 'unknown'
            end from_page
            ,user_pseudo_id
            ,count(1) pv
        from event_pre_raw
        group by
            1,2,3,4,5,6,7,8,9,10,11

        union all

        SELECT
            event_date_hk event_date
            ,platform
            ,event_name
            ,null project
            ,value_name miniapp_content_id
            ,null module_type
            ,null page_id
            ,null button_type
            ,'>=7.6.020' version  -- 首页miniapp曝光点击7.6.020之前没有数，统一只看7.6.020之后的数，弹窗底表未区分版本，默认定位7.6.020之后
            ,'popup' from_page
            ,user_pseudo_id
            ,pv
        FROM `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
        where
            event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_pop_appr_bd','home_page_pop_clk_bd')
            and key_name='pop_id' and value_name in (select distinct material_id from `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`)
        ) e
        left join (select material_id,max(miniapp) miniapp from `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping` group by 1) m on e.miniapp_content_id=m.material_id
        left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.project=s.buried_miniapp -- 关联非首页事件
;

-- drop table if exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_v2`;
-- create table if not exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_v2` as
delete from  `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_v2`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_v2`
with user_info as
(
    select
        event_date event_date_hk
        ,platform
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        -- event_date_hk between date'2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  -- 修改查询的数据时间
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--         and app_name='BeautyPlus'
    group by 1,2,3,4
)
,
event_result as
(
    select
        e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,miniapp_name
        ,coalesce(e.status,s.status) status
        ,e.version
        ,e.from_page
        ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd') then e.user_pseudo_id end) click_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then e.user_pseudo_id end) exposure_miniapp_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='miniapp' then e.user_pseudo_id end) click_miniapp_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='Banner' then e.user_pseudo_id end) exposure_banner_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='Banner' then e.user_pseudo_id end) click_banner_uv
        ,count(distinct case when event_name in ('home_page_pop_appr_bd') then e.user_pseudo_id end) exposure_popup_uv
        ,count(distinct case when event_name in ('home_page_pop_clk_bd') then e.user_pseudo_id end) click_popup_uv
        ,count(distinct case when event_name in ('search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_search_uv
        ,count(distinct case when event_name in ('search_miniapp_clk_bd') then e.user_pseudo_id end) click_search_uv

        ,count(distinct case when event_name in ('h5_page_event_bd') and page_id='home_page_view' then e.user_pseudo_id end) visit_uv
        ,count(distinct case when event_name in ('h5_page_event_bd') and page_id in ('style_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2') then e.user_pseudo_id end) enter_generate_page_uv -- 目前仅保证了积分miniapp
        ,count(distinct case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='generate' then e.user_pseudo_id end) generate_uv -- 目前仅保证了积分miniapp
        ,count(distinct case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then e.user_pseudo_id end) save_uv
        ,count(distinct case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%share%') or event_name in ('h5_result_share_bd') then e.user_pseudo_id end) share_uv
        ,count(distinct case when event_name in ('share_page_clk_bd','web_view_share_bd') then e.user_pseudo_id end) share_uv_user

        ,sum(case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd') then pv end) exposure_pv
        ,sum(case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd') then pv end) click_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then pv end) exposure_miniapp_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='miniapp' then pv end) click_miniapp_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='Banner' then pv end) exposure_banner_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='Banner' then pv end) click_banner_pv
        ,sum(case when event_name in ('home_page_pop_appr_bd') then pv end) exposure_popup_pv
        ,sum(case when event_name in ('home_page_pop_clk_bd') then pv end) click_popup_pv
        ,sum(case when event_name in ('search_miniapp_appr_bd') then pv end) exposure_search_pv
        ,sum(case when event_name in ('search_miniapp_clk_bd') then pv end) click_search_pv

        ,sum(case when event_name in ('h5_page_event_bd') and page_id='home_page_view' then pv end) visit_pv
        ,sum(case when event_name in ('h5_page_event_bd') and page_id in ('style_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2') then pv end) enter_generate_page_pv -- 目前仅保证了积分miniapp
        ,sum(case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='generate' then pv end) generate_pv -- 目前仅保证了积分miniapp
        ,sum(case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then pv end) save_pv
        ,sum(case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%share%') or event_name in ('h5_result_share_bd') then pv end) share_pv
        ,sum(case when event_name in ('share_page_clk_bd','web_view_share_bd') then pv end) share_pv_user
    from
        `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_pre_v2` e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform
        left join  (select miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.miniapp_name=s.miniapp-- 关联非首页事件
    group by
        1,2,3,4,5,6,7,8,9,10

    union all

    select
        e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,miniapp_name
        ,coalesce(e.status,s.status) status
        ,e.version
        ,'All' from_page
        ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd') then e.user_pseudo_id end) click_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then e.user_pseudo_id end) exposure_miniapp_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='miniapp' then e.user_pseudo_id end) click_miniapp_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='Banner' then e.user_pseudo_id end) exposure_banner_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='Banner' then e.user_pseudo_id end) click_banner_uv
        ,count(distinct case when event_name in ('home_page_pop_appr_bd') then e.user_pseudo_id end) exposure_popup_uv
        ,count(distinct case when event_name in ('home_page_pop_clk_bd') then e.user_pseudo_id end) click_popup_uv
        ,count(distinct case when event_name in ('search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_search_uv
        ,count(distinct case when event_name in ('search_miniapp_clk_bd') then e.user_pseudo_id end) click_search_uv

        ,count(distinct case when event_name in ('h5_page_event_bd') and page_id='home_page_view' then e.user_pseudo_id end) visit_uv
        ,count(distinct case when event_name in ('h5_page_event_bd') and page_id in ('style_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2') then e.user_pseudo_id end) enter_generate_page_uv -- 目前仅保证了积分miniapp
        ,count(distinct case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='generate' then e.user_pseudo_id end) generate_uv -- 目前仅保证了积分miniapp
        ,count(distinct case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then e.user_pseudo_id end) save_uv
        ,count(distinct case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%share%') or event_name in ('h5_result_share_bd') then e.user_pseudo_id end) share_uv
        ,count(distinct case when event_name in ('share_page_clk_bd','web_view_share_bd') then e.user_pseudo_id end) share_uv_user

        ,sum(case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd') then pv end) exposure_pv
        ,sum(case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd') then pv end) click_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then pv end) exposure_miniapp_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='miniapp' then pv end) click_miniapp_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='Banner' then pv end) exposure_banner_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='Banner' then pv end) click_banner_pv
        ,sum(case when event_name in ('home_page_pop_appr_bd') then pv end) exposure_popup_pv
        ,sum(case when event_name in ('home_page_pop_clk_bd') then pv end) click_popup_pv
        ,sum(case when event_name in ('search_miniapp_appr_bd') then pv end) exposure_search_pv
        ,sum(case when event_name in ('search_miniapp_clk_bd') then pv end) click_search_pv

        ,sum(case when event_name in ('h5_page_event_bd') and page_id='home_page_view' then pv end) visit_pv
        ,sum(case when event_name in ('h5_page_event_bd') and page_id in ('style_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2') then pv end) enter_generate_page_pv -- 目前仅保证了积分miniapp
        ,sum(case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='generate' then pv end) generate_pv -- 目前仅保证了积分miniapp
        ,sum(case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then pv end) save_pv
        ,sum(case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%share%') or event_name in ('h5_result_share_bd') then pv end) share_pv
        ,sum(case when event_name in ('share_page_clk_bd','web_view_share_bd') then pv end) share_pv_user
    from
        `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_pre_v2` e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform
        left join  (select miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.miniapp_name=s.miniapp-- 关联非首页事件
    group by
        1,2,3,4,5,6,7,8,9
)

-- daily+miniapp
select
    e.event_date
    ,e.platform
    ,e.country
    ,e.is_new
    ,e.is_UA
    ,e.is_pay
    ,e.miniapp_name
    ,e.status
    ,e.version
    ,e.from_page
    ,exposure_uv
    ,click_uv
    ,exposure_miniapp_uv
    ,click_miniapp_uv
    ,exposure_banner_uv
    ,click_banner_uv
    ,exposure_popup_uv
    ,click_popup_uv
    ,exposure_search_uv
    ,click_search_uv

    ,visit_uv
    ,enter_generate_page_uv
    ,generate_uv
    ,save_uv
    ,share_uv
    ,share_uv_user
    ,exposure_pv
    ,click_pv
    ,exposure_miniapp_pv
    ,click_miniapp_pv
    ,exposure_banner_pv
    ,click_banner_pv
    ,exposure_popup_pv
    ,click_popup_pv
    ,exposure_search_pv
    ,click_search_pv
    ,visit_pv
    ,enter_generate_page_pv
    ,generate_pv
    ,save_pv
    ,share_pv
    ,share_pv_user
from
    event_result e
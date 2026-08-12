-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` 
-- 347_ads_dz_miniapp_data
-- drop table if exists `beautyplus-bc0ed.content_data.dws_da_h5_miniapp_material_content_level`; 
-- create table if not exists `beautyplus-bc0ed.content_data.dws_da_h5_miniapp_material_content_level` as
delete from  `beautyplus-bc0ed.content_data.dws_da_h5_miniapp_material_content_level`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.content_data.dws_da_h5_miniapp_material_content_level`
with user_info as 
(
    select 
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        -- event_date_hk between date'2023-01-01' and date_sub(current_date, interval '1' day)  -- 修改查询的数据时间
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
) 
,
event_pre as
(    
    select 
        *  
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-01-01', date_sub(current_date,interval'1'day))  
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}') 
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)  
    where
        event_name in ('h5_home_content_show_f_bd','h5_home_content_clk_bd','h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd','h5_preview_save_bd','h5_result_share_bd')   
)
,
event_raw as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,case when project = 'BeautyPlus_AI_V3' then 'B+ AI_V3' else s.miniapp end miniapp_name
        ,theme
        ,project
        ,page_id
        ,button_type
        ,user_pseudo_id
        ,pv
    from
        (select
            event_date
            ,platform
            ,geo.country country
            ,event_name
            ,k theme
            ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
            ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
            ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
            ,user_pseudo_id
            ,count(1) pv
        from
            event_pre,unnest(split(`dataintegration-265403.func`.getParams(event_params,'theme').string_value,',')) k
        where
            case    when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') then `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('save','save_poster','save_video','material_save','save_collection','save_all','generate','view','list')
                    else 1=1
                    end
        group by
            1,2,3,4,5,6,7,8,9) e 
        left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.project=s.buried_miniapp -- 关联非首页事件
)

    select
        e.event_date
        ,e.platform
        ,e.country
        ,is_new
        ,miniapp_name
        ,theme
        ,count(distinct case when event_name in ('h5_home_content_show_f_bd') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('h5_home_content_clk_bd') then e.user_pseudo_id end) click_uv
        ,count(distinct case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type in ('generate','list') then e.user_pseudo_id end) generate_uv 
        ,count(distinct case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='view' then e.user_pseudo_id end) view_uv 
        ,count(distinct case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then e.user_pseudo_id end) save_uv
        ,sum(case when event_name in ('h5_home_content_show_f_bd') then pv end) exposure_pv
        ,sum(case when event_name in ('h5_home_content_clk_bd') then pv end) click_pv
        ,sum(case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type in ('generate','list') then pv end) generate_pv 
        ,sum(case when event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type='view' then pv end) view_pv 
        ,sum(case when (event_name in ('h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd') and button_type like '%save%') or event_name in ('h5_preview_save_bd') then pv end) save_pv
    from 
        event_raw e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform
    group by 
        1,2,3,4,5,6

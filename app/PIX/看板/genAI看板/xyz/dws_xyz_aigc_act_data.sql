
-- drop table if exists `dataintegration-265403.temp.dws_xyz_aigc_act_data`;
-- create table if not exists `dataintegration-265403.temp.dws_xyz_aigc_act_data` as

delete from  `dataintegration-265403.temp.dws_xyz_aigc_act_data`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dws_xyz_aigc_act_data`

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
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)

select
    e.app_name
    ,e.event_date date
    ,e.platform
    ,u.country
    ,u.is_new
    ,u.is_UA
    ,project_name
    ,e.user_pseudo_id
    ,sum(case when (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and event_date<='2024-11-18')
                                      or (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and project in ('AI_Pet_Portray') and event_date<='2024-12-13')
                                      or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-11-18' and project not in ('AI_Pet_Portray'))
                                      or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-12-13' and project in ('AI_Pet_Portray'))
                                      or event_name in ('beauty_appr_edit_clk_bd','first_func_enter') then pv end) enter_pv
    ,sum(case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then pv end) use_pv
    ,sum(case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then pv end) save_pv
from
    `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
group by
    1,2,3,4,5,6,7,8


-- drop table if exists `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level`;
-- create table if not exists `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level` as

delete from `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level` where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level`

with
event as
(
    select *
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
       and (
           ((event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and event_date<='2024-11-18')
                                          or (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and project in ('AI_Pet_Portray') and event_date<='2024-12-13')
                                          or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-11-18' and project not in ('AI_Pet_Portray'))
                                          or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-12-13' and project in ('AI_Pet_Portray'))
                                          or event_name in ('beauty_appr_edit_clk_bd','first_func_enter'))
           or (((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                          or
                                      (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                      or
                                      (event_name in ('beauty_style_clk_bd','material_click','click')))
           or ((project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                    or
                                      (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                    or
                                      (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                    or
                                      (event_name in ('beautifysave_bd','edit_save','save')))
        )
)
,
user_info as
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

select  e.app_name
        ,e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,count(distinct case when (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and event_date<='2024-11-18')
                                      or (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and project in ('AI_Pet_Portray') and event_date<='2024-12-13')
                                      or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-11-18' and project not in ('AI_Pet_Portray'))
                                      or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-12-13' and project in ('AI_Pet_Portray'))
                                      or event_name in ('beauty_appr_edit_clk_bd','first_func_enter') then e.user_pseudo_id end) visit_uv
        ,count(distinct case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then e.user_pseudo_id end) click_generate_uv
        ,count(distinct case when (project not in ('puriplus') and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (project in ('puriplus') and event_date<'2024-09-06' and event_name in ('h5_credit_consume_bd','h5_credit_consume'))
                                                or
                                  (project in ('puriplus') and event_date>='2024-09-06' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%')
                                                or
                                  (event_name in ('beautifysave_bd','edit_save','save')) then e.user_pseudo_id end) save_uv
from event e
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
group by 1,2,3,4,5,6




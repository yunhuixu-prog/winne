-- drop table if exists `dataintegration-265403.temp.winne_temp_xyz_project_video_generate`;
-- create table if not exists `dataintegration-265403.temp.winne_temp_xyz_project_video_generate` as

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
        event_date_hk between '2025-01-01' and '2025-06-30'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4,5
)
,creative_user as
(
    select e.app_name,e.event_date,e.project_name
         ,case when (
                        (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
                        and theme_type in ('video'))
                      or
                        (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('to_video'))
                      ) then 'video'
         else 'photo' end theme_type
         ,case when event_name in ('beauty_style_clk_bd', 'material_click','click') then 'style'
          else 'H5' end source
         ,e.user_pseudo_id,sum(e.pv) generate_pv
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    where ((event_name in ('h5_page_button_clk_bd', 'h5_page_button_clk')
                and button_type in
                    ('non_zero_generate_upload', 'zero_generate_upload', 'non_zero_generate', 'zero_generate', 'generate',
                     'list', 'retry', 'upload_new', 'to_video')
                and coalesce(task_id, '-')!='no_task')
                or
                   (event_name in ('beauty_style_clk_bd', 'material_click','click'))
        )
--         and project in ('ai_filter')
    group by 1,2,3,4,5,6
)

select app_name,project_name,theme_type,source
     ,case when generate_pv_1day<=20 then cast(generate_pv_1day as string) else '21:>20' end generate_pv_1day
     ,case when generate_pv_31day<=20 then cast(generate_pv_31day as string) else '21:>20' end generate_pv_31day
     ,count(distinct user_pseudo_id) uv
from
(
    select f.app_name,f.project_name,f.theme_type,f.source,f.user_pseudo_id
        ,sum(case when c.event_date=f.first_generate_date then generate_pv end) generate_pv_1day
        ,sum(generate_pv) generate_pv_31day
    from
    (
        select app_name,project_name,user_pseudo_id,theme_type,source,min(event_date) first_generate_date
        from creative_user
        where project_name='AI Filter 1.0'
        group by 1,2,3,4,5
        having min(event_date) <= date_sub('2025-06-30',interval 30 day)
    ) f
    left join creative_user c
    on f.app_name=c.app_name and f.project_name=c.project_name and f.user_pseudo_id=c.user_pseudo_id and f.theme_type=c.theme_type and f.source=c.source
    where c.event_date between f.first_generate_date and date_add(f.first_generate_date,interval 30 day)
    group by 1,2,3,4,5
)
group by 1,2,3,4,5,6
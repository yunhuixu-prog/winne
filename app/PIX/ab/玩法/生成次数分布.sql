-- drop table if exists `dataintegration-265403.temp.winne_temp_xyz_project_video_generate`;
-- create table if not exists `dataintegration-265403.temp.winne_temp_xyz_project_video_generate` as

with user_info as
(
--     select
--         event_date_hk
--         ,app_name
--         ,platform
--         ,country
--         ,user_pseudo_id
--         ,max(is_new) is_new
--         ,max(is_UA) is_UA
--     from
--         `dataintegration-265403.stat.stat_active_advice_detail_d`
--     where
--         event_date_hk between '2025-10-01' and '2025-10-31'
--         and app_name in ('AirBrush')
--     group by 1,2,3,4,5

    select
        event_date
        ,platform
        ,country,is_ua,is_new
        ,is_paying
        ,user_pseudo_id
    from
        dataintegration-265403.temp.winne_temp_day_type_2
    where
        event_date between '2025-10-01' and '2025-10-31'
)
,creative_user as
(
    select e.event_date
         ,u.is_paying
         ,e.project_name
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
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date and e.platform=u.platform
    where ((event_name in ('h5_page_button_clk_bd', 'h5_page_button_clk')
                and button_type in
                    ('non_zero_generate_upload', 'zero_generate_upload', 'non_zero_generate', 'zero_generate', 'generate',
                     'list', 'retry', 'upload_new', 'to_video')
                and coalesce(task_id, '-')!='no_task')
                or
                   (event_name in ('beauty_style_clk_bd', 'material_click','click'))
        )
        and e.app_name='AirBrush'
--         and project in ('ai_filter')
    group by 1,2,3,4,5,6
)

select is_paying,project_name,theme_type,source
     ,case when is_paying!='now_paying_or_trial' and generate_pv<=20 then cast(generate_pv as string)
           when is_paying!='now_paying_or_trial' and generate_pv>20 then '21:>20'
           when is_paying='now_paying_or_trial' and generate_pv<=100 then cast(generate_pv as string)
           when is_paying='now_paying_or_trial' and generate_pv>100 then '101:>100'
     end generate_pv
     ,count(user_pseudo_id) uv
     ,sum(generate_pv) generate_pv_1
from creative_user
group by 1,2,3,4,5
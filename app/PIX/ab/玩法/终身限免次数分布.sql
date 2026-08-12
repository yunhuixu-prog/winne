drop table if exists `dataintegration-265403.temp.winne_temp_xyz_project_generate`;
create table if not exists `dataintegration-265403.temp.winne_temp_xyz_project_generate` as

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
        event_date between '2025-09-01' and '2025-12-31'
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

select * from creative_user

;
select case when is_paying!='now_paying_or_trial' then 'no_pay' else 'paying' end is_paying,project_name,theme_type,source
     ,count(case when pv_0>0 then user_pseudo_id end) generate_uv
     ,count(case when pv_7>pv_0 then user_pseudo_id end) regenerate_7_uv
     ,count(case when pv_30>pv_0 then user_pseudo_id end) regenerate_30_uv
-- select is_paying
--     ,project_name,theme_type,source
--     ,case when is_paying!='now_paying_or_trial' and pv_30<=50 then cast(pv_30 as string)
--        when is_paying!='now_paying_or_trial' and pv_30>50 then '51:>50'
--        when is_paying='now_paying_or_trial' and pv_30<=100 then cast(pv_30 as string)
--        when is_paying='now_paying_or_trial' and pv_30>100 then '101:>100'
--     end pv_30
--     ,count(user_pseudo_id) uv
-- --     ,sum(pv_0) generate_pv_0
--     ,sum(pv_30) generate_pv_30
from
(
    select a.first_event_date event_date,a.is_paying,a.project_name,a.theme_type,a.source,a.user_pseudo_id
        ,sum(case when b.event_date=a.first_event_date then b.generate_pv end) pv_0
        ,sum(case when b.event_date between a.first_event_date and date_add(a.first_event_date,interval 6 day) then b.generate_pv end) pv_7
        ,sum(case when b.event_date between a.first_event_date and date_add(a.first_event_date,interval 29 day) then b.generate_pv end) pv_30
    from
    (
        select is_paying,project_name,theme_type,source,user_pseudo_id,min(event_date) first_event_date
        from `dataintegration-265403.temp.winne_temp_xyz_project_generate`
        where event_date between '2025-10-01' and '2025-10-31'
        group by 1,2,3,4,5
    ) a
    left join
    (
        select event_date,is_paying,project_name,theme_type,source,user_pseudo_id,generate_pv
        from `dataintegration-265403.temp.winne_temp_xyz_project_generate`
    ) b
    on a.is_paying=b.is_paying and a.project_name=b.project_name and a.theme_type=b.theme_type and a.source=b.source
         and a.user_pseudo_id=b.user_pseudo_id
        and b.event_date between a.first_event_date and date_add(a.first_event_date,interval 29 day)
    group by 1,2,3,4,5,6
)
where project_name='AI Filter 1.0' and source='style'
group by 1,2,3,4

;
select is_paying
    ,project_name,theme_type,source
    ,case when is_paying!='now_paying_or_trial' and pv_30<=50 then cast(pv_30 as string)
       when is_paying!='now_paying_or_trial' and pv_30>50 then '51:>50'
       when is_paying='now_paying_or_trial' and pv_30<=100 then cast(pv_30 as string)
       when is_paying='now_paying_or_trial' and pv_30>100 then '101:>100'
    end pv_30
    ,count(user_pseudo_id) uv
--     ,sum(pv_0) generate_pv_0
    ,sum(pv_30) generate_pv_30
from
(
    select a.first_event_date event_date,a.is_paying,a.project_name,a.theme_type,a.source,a.user_pseudo_id
        ,sum(case when b.event_date=a.first_event_date then b.generate_pv end) pv_0
        ,sum(case when b.event_date between a.first_event_date and date_add(a.first_event_date,interval 6 day) then b.generate_pv end) pv_7
        ,sum(case when b.event_date between a.first_event_date and date_add(a.first_event_date,interval 29 day) then b.generate_pv end) pv_30
    from
    (
        select is_paying,project_name,theme_type,source,user_pseudo_id,min(event_date) first_event_date
        from `dataintegration-265403.temp.winne_temp_xyz_project_generate`
        where event_date between '2025-10-01' and '2025-10-31'
        group by 1,2,3,4,5
    ) a
    left join
    (
        select event_date,is_paying,project_name,theme_type,source,user_pseudo_id,generate_pv
        from `dataintegration-265403.temp.winne_temp_xyz_project_generate`
    ) b
    on a.is_paying=b.is_paying and a.project_name=b.project_name and a.theme_type=b.theme_type and a.source=b.source
         and a.user_pseudo_id=b.user_pseudo_id
        and b.event_date between a.first_event_date and date_add(a.first_event_date,interval 29 day)
    group by 1,2,3,4,5,6
)
where project_name='AI Filter 1.0' and source='style'
group by 1,2,3,4,5


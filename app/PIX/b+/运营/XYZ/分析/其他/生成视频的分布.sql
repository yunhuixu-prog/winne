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
        event_date_hk between '2024-11-18' and '2025-05-17'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4,5
)

select app_name,event_date,project_name,generate_pv,count(distinct user_pseudo_id) uv
from
(
    select e.app_name,e.event_date,e.project_name,e.user_pseudo_id,count(1) generate_pv
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    where (
            (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
            and theme_type in ('video'))
          or
            (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('to_video'))
          )
        and coalesce(task_id,'-')!='no_task'
    group by 1,2,3,4
)
group by 1,2,3,4




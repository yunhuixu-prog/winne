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
        event_date_hk between '2025-01-01' and '2025-06-23'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4,5
)

select e.app_name,e.event_date,e.project_name
     ,case when (
                    (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
                    and theme_type in ('video'))
                  or
                    (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('to_video'))
                  ) then 'video'
     else 'photo' end theme_type
     ,count(distinct e.user_pseudo_id) generate_uv,count(1) generate_pv
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
where (event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
        and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
        and coalesce(task_id,'-')!='no_task')

      or

      (event_name in ('beauty_style_clk_bd','material_click','click'))
group by 1,2,3,4



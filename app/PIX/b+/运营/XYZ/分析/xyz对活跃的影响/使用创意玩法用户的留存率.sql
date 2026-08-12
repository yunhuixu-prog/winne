
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
        event_date_hk between '2025-06-01' and date_add('2025-06-22',interval 1 day)
        and app_name in ('BeautyPlus')
    group by 1,2,3,4,5
)
,
creative_user as
(
select distinct event_date,user_pseudo_id
from
        `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
where event_date between '2025-06-01' and '2025-06-22'
    and case when ((project not in ('AI_Pet_Portray') or (project in ('AI_Pet_Portray') and event_date>'2024-12-13')) and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task')
                                                      or
                                  (project in ('AI_Pet_Portray') and event_name in ('h5_credit_consume_bd','h5_credit_consume') and event_date<='2024-12-13')
                                                  or
                                  (event_name in ('beauty_style_clk_bd','material_click','click')) then 1=1 else 1=0 end
)
,edit_enter as
(
    select distinct event_date,user_pseudo_id
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
    where event_date between '2025-06-01' and '2025-06-22'
        and module='修图' and action='进入'
)
,edit_save as
(
    select distinct event_date,user_pseudo_id
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
    where event_date between '2025-06-01' and '2025-06-22'
        and module='修图' and action='保存'
)
,camera_enter as
(
    select distinct event_date,user_pseudo_id
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
    where event_date between '2025-06-01' and '2025-06-22'
        and module='相机' and action='进入'
)
,camera_save as
(
    select distinct event_date,user_pseudo_id
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
    where event_date between '2025-06-01' and '2025-06-22'
        and module='相机' and action='保存'
)

select u.event_date_hk
    ,if(c.user_pseudo_id is null,0,1) is_creative_ai
    ,if(e1.user_pseudo_id is null,0,1) is_edit_enter
    ,if(e2.user_pseudo_id is null,0,1) is_edit_save
    ,if(e3.user_pseudo_id is null,0,1) is_camera_enter
    ,if(e4.user_pseudo_id is null,0,1) is_camera_save
    ,count(distinct u.user_pseudo_id) dnu
    ,count(distinct c1.user_pseudo_id) dnu_retention_1day
from
(
    select distinct event_date_hk,user_pseudo_id
    from user_info
    where event_date_hk between '2025-06-01' and '2025-06-22'
        and is_new=1
) u
left join creative_user c
on u.event_date_hk=c.event_date and u.user_pseudo_id=c.user_pseudo_id
left join edit_enter e1
on u.event_date_hk=e1.event_date and u.user_pseudo_id=e1.user_pseudo_id
left join edit_save e2
on u.event_date_hk=e2.event_date and u.user_pseudo_id=e2.user_pseudo_id
left join camera_enter e3
on u.event_date_hk=e3.event_date and u.user_pseudo_id=e3.user_pseudo_id
left join camera_save e4
on u.event_date_hk=e4.event_date and u.user_pseudo_id=e4.user_pseudo_id
left join user_info c1
on u.event_date_hk=date_sub(c1.event_date_hk,interval 1 day) and u.user_pseudo_id=c1.user_pseudo_id
group by 1,2,3,4,5,6
order by 1,2,3,4,5,6








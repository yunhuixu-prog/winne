
select app_name,event_date,project_name
     ,count(distinct user_pseudo_id) click_generate_uv
     ,count(distinct case when retention_1>0 then user_pseudo_id end) retention_generate_1_uv
     ,count(distinct case when retention_7>0 then user_pseudo_id end) retention_generate_7_uv
     ,count(distinct case when retention_30>0 then user_pseudo_id end) retention_generate_30_uv
from
(
select a.app_name,a.event_date,a.user_pseudo_id,a.project_name
     ,sum(case when b.event_date between date_add(a.event_date,interval 1 day) and date_add(a.event_date,interval 1 day) then 1 end) retention_1
     ,sum(case when b.event_date between date_add(a.event_date,interval 1 day) and date_add(a.event_date,interval 7 day) then 1 end) retention_7
     ,sum(case when b.event_date between date_add(a.event_date,interval 1 day) and date_add(a.event_date,interval 30 day) then 1 end) retention_30
from
(
    select distinct app_name,event_date,project_name,user_pseudo_id
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
    where event_date between '2024-06-01' and '2024-08-18'
        and ((event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list'))
                          or
            (event_name in ('beauty_style_clk_bd','click')))
) a
left join
(
    select distinct app_name,event_date,user_pseudo_id
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
    where event_date between date_add('2024-06-01',interval 1 day) and date_add('2024-08-18',interval 7 day)
        and ((event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list'))
                          or
            (event_name in ('beauty_style_clk_bd','click')))
) b
on a.app_name=b.app_name and a.user_pseudo_id=b.user_pseudo_id
group by 1,2,3,4
)
where project_name != 'AI Pet Portrait'
group by 1,2,3
order by 1,2,3



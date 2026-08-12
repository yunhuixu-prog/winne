select a.app_name,a.event_date
     ,count(distinct a.user_pseudo_id) uv
     ,count(distinct b.user_pseudo_id) retention_uv
-- select *
from
(
    select distinct app_name,event_date,user_pseudo_id
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
    where event_date between '2024-07-16' and '2024-08-18'
        and ((event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list'))
                          or
            (event_name in ('beauty_style_clk_bd','click')))

--     select app_name,user_pseudo_id,event_date_hk event_date
--     from `dataintegration-265403.stat.stat_active_advice_detail_d`
--     where event_date_hk between '2024-07-16' and '2024-08-18'
--         and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
) a
left join
(
    select app_name,user_pseudo_id,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2024-07-16' and '2024-08-19'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
) b
on a.app_name=b.app_name and a.user_pseudo_id=b.user_pseudo_id and a.event_date=date_sub(b.event_date_hk,interval 1 day)
group by 1,2
order by 1,2
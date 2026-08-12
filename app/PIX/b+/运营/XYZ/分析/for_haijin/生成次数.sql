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
        event_date_hk between '2024-07-27' and '2024-08-26'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)

select u.app_name,case when country in ('Japan','United States','India','South Korea') then country else 'other' end country
    ,count(distinct u.user_pseudo_id) mau
    ,count(distinct x.user_pseudo_id) click_generate_uv
    ,sum(pv) click_generate_pv
from user_info u
left join
(
    select app_name,event_date,user_pseudo_id,sum(pv) pv
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
    where event_date between '2024-07-27' and '2024-08-26'
        and ((event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list'))
                          or
            (event_name in ('beauty_style_clk_bd','click','material_click')))
        and project_name in ('AI Portrait 2.0','AI Filter 1.0','PuriPlus')
    group by 1,2,3
) x
on x.app_name=u.app_name and x.event_date=u.event_date_hk and x.user_pseudo_id=u.user_pseudo_id
group by 1,2
order by 1,2
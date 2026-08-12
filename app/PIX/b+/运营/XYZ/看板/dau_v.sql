-- `dataintegration-265403.temp.dws_dzp_aigc_h5_page_xyz_project_add_dau`
    select
        event_date_hk event_date
        ,app_name
        ,platform
--         ,country
        ,case when country='China'  then 'China Mainland' else country end country
        ,is_new
        ,is_UA
        ,count(distinct user_pseudo_id) dau
        ,0 visit
        ,0 click_generate
        ,0 save
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
        and event_date_hk between '2024-04-30' and (select max(event_date) from `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level`)
    group by 1,2,3,4,5,6

    union all

    select
        event_date
        ,app_name
        ,platform
        ,case when country='China'  then 'China Mainland' else country end country
        ,is_new
        ,is_UA
        ,0 dau
        ,sum(visit_uv) visit
        ,sum(click_generate_uv) click_generate
        ,sum(save_uv) save
    from
        `dataintegration-265403.temp.dwd_ds_h5_page_xyz_visit_level`
    where app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5,6

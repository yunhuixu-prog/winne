
with user_info as
(
    select
        event_date event_date_hk
        ,'BeautyPlus' app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        event_date between '2024-04-30' and '2024-06-27'
--         and app_name='BeautyPlus'
    group by 1,2,3,4,5

    union all

    select
        event_date event_date_hk
        ,'AirBrush' app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        airbrush-1324.temp.dws_dz_active_user_02
    where
        event_date between '2024-04-30' and '2024-06-27'
--         and app_name='AirBrush'
    group by 1,2,3,4,5
)

-- select cast(created_at as date) date,api.gid,api.is_vip,api.order_id,api.host app_name,api.system platform
--     ,fi.last_user_pseudo_id,u.country,u.is_pay
select u.is_pay
    ,count(distinct u.user_pseudo_id) uv
    ,count(distinct api.gid)
    ,count(distinct fi.gid)
    ,count(1) pv
from
(
    select
    from dataintegration-265403.aigc.ods_da_aigc_portrait_artwork_xyz

    union all

    select
    from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz

) api
left join
(
    SELECT event_date_hk,gid,last_user_pseudo_id,'BeautyPlus' app_name
    FROM `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user` WHERE event_date_hk between '2024-04-30' and '2024-06-27'

    union all

    SELECT event_date_hk,gid,last_user_pseudo_id,'AirBrush' app_name
    FROM `airbrush-1324.dim.dim_dzp_portrait_gid_user` WHERE event_date_hk between '2024-04-30' and '2024-06-27'
) fi
on api.gid=fi.gid and api.host=fi.app_name and cast(api.created_at as date)=fi.event_date_hk
left join user_info u
on fi.last_user_pseudo_id=u.user_pseudo_id and fi.app_name=u.app_name and cast(api.created_at as date)=u.event_date_hk
group by 1
order by 1

;
-- 用的埋点的生成口径(差不多能对上，就用这个吧，那个gid和firebaseid对不上)
select event_date,project_name
     ,app_name,country,is_pay
     ,sum(case when data_type='uv' then generate_success end) generate_success_uv
     ,sum(case when data_type='pv' then generate_success end) generate_success_pv
from `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`
where event_date between '2024-04-30' and '2024-06-27' and theme='all' and generate_success>0
group by 1,2,3,4,5
order by 1,2,3,4,5
;

-- 用的埋点的生成口径(差不多能对上，就用这个吧，那个gid和firebaseid对不上)
select event_date,project_name
     ,app_name,is_pay
     ,sum(case when data_type='uv' then generate_success end) generate_success_uv
     ,sum(case when data_type='pv' then generate_success end) generate_success_pv
from `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`
where event_date between '2024-04-30' and '2024-06-27' and theme='all' and generate_success>0
group by 1,2,3,4
order by 1,2,3,4
;

-- 用户生成次数分布(埋点)
select event_date,project,app_name,is_pay
    ,generate_pv
    ,count(distinct user_pseudo_id) uv
from
(
    select event_date,app_name,project,is_pay,user_pseudo_id,count(1) generate_pv
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre_t`
    group by 1,2,3,4,5
)
group by 1,2,3,4,5
order by 1,2,3,4,5


-- 用户生成次数分布
select project,date
    ,api_call
    ,count(distinct gid) uv
from
(
    select 'ai portrait' project,cast(created_at as date) date,gid,count(1) api_call
    from dataintegration-265403.aigc.ods_da_aigc_portrait_artwork_xyz
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3

union all

select project,date
    ,api_call
    ,count(distinct gid) uv
from
(
    select 'ai filter' project,cast(created_at as date) date,gid,count(1) api_call
    from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3

-- AI Filter
select event_date,project_name
     ,case when theme in ('Trending','Food','Scenic Zone') then 'photo'
           when theme in ('Clay','8bit') then 'photo-video'
           else 'video' end theme_type
     ,sum(case when data_type='pv' then generate_success end) generate_success_pv
from `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`
where event_date between '2024-06-01' and '2024-06-30' and theme!='all' and generate_success>0 and project_name='AI Filter 1.0'
group by 1,2,3
order by 1,2,3
;
select cast(created_at as date) date,'AI Filter' project_name
     ,case when style_name in ('Trending','Food','Scenic Zone') then 'photo'
           when style_name in ('Clay','8bit') then 'photo-video'
           else 'video' end theme_type
     ,count(1) generate_success_pv
from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz
where cast(created_at as date) between '2024-06-01' and '2024-06-30'
group by 1,2,3
order by 1,2,3

-- 如果限制X张
select project,date
    ,api_call
    ,count(distinct gid) uv
    ,api_call*count(distinct gid) api_call_all
from
(
    select 'ai filter' project,cast(created_at as date) date,gid,count(1) api_call
    from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz
    where cast(created_at as date) between '2024-06-01' and '2024-06-30'
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3
;
select project,date
    ,api_call
    ,count(distinct gid) uv
    ,api_call*count(distinct gid) api_call_all
from
(
    select 'AI Portrait' project,cast(created_at as date) date,gid,count(1) api_call
    from dataintegration-265403.aigc.ods_da_aigc_portrait_artwork_xyz
    where cast(created_at as date) between '2024-05-01' and '2024-05-30'
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3
;
select project,event_date
    ,is_pay,theme_type,generate_success
    ,count(distinct user_pseudo_id) uv
    ,generate_success*count(distinct user_pseudo_id) api_call_all
from
(
    select project,event_date,user_pseudo_id,is_pay
         ,case when style_name in ('Trending','Food','Scenic Zone') then 'photo'
           when style_name in ('Clay','8bit') then 'photo-video'
           else 'video' end theme_type
         ,count(1) generate_success
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre_t`
    where project in ('ai_filter','ai_portrait')
    group by 1,2,3,4,5
)
group by 1,2,3,4,5
order by 1,2,3,4,5
;

-- 一个用户会用几天
select project,sum(api_days)/count(distinct gid) api_day_per
from
(
    select 'AI Portrait' project,gid,count(distinct cast(created_at as date)) api_days
    from dataintegration-265403.aigc.ods_da_aigc_portrait_artwork_xyz
    where cast(created_at as date) between '2024-05-01' and '2024-05-30'
    group by 1,2

    union all

    select 'ai filter' project,gid,count(distinct cast(created_at as date)) api_days
    from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz
    where cast(created_at as date) between '2024-06-01' and '2024-06-30'
    group by 1,2
)
group by 1


select cast(created_at as date) date,'AI Portrait' project_name
     ,count(1) generate_success_pv
from dataintegration-265403.aigc.ods_da_aigc_portrait_artwork_xyz
where cast(created_at as date) between '2024-05-01' and '2024-05-30'
group by 1,2
order by 1,2


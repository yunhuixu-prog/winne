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
        event_date_hk between '2025-03-20' and '2025-04-19'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)

select a.event_date,a.app_name,b.save_type,generate_uv,generate_pv,save_uv,save_pv,save_photo_num
from
(
    select e.event_date,e.app_name
        ,count(distinct e.user_pseudo_id) generate_uv
        ,count(1) generate_pv
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    left join (select name,project projects,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1,2) t
    on REGEXP_REPLACE(k,r'live photo\+','')=t.name and e.project_name=t.projects
    where project = 'ai_portrait' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
            and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate'
                            ,'list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task'
    group by 1,2
) a
left join
(
    select event_date,app_name
        ,case when save_one=1 and save_all=0 then 'only_save_one'
              when save_one=1 and save_all=1 then 'save_one_and_save_all'
              when save_one=0 and save_all=1 then 'only_save_all'
        end save_type
        ,count(distinct user_pseudo_id) save_uv
        ,sum(save_pv) save_pv
        ,sum(save_photo_num) save_photo_num
    from
    (
        select e.event_date,e.app_name,e.user_pseudo_id
            ,max(if(e.button_type in ('save','save_video','save_gif'),1,0)) save_one
            ,max(if(e.button_type in ('save_all'),1,0)) save_all
            ,sum(pv) save_pv
            ,sum(case when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_video','save_gif')) then pv
                      when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save_all') then coalesce(t.pkg_num,1)*pv
                      end) save_photo_num
        from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
        left join (select name,project projects,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1,2) t
        on REGEXP_REPLACE(k,r'live photo\+','')=t.name and e.project_name=t.projects
        where project = 'ai_portrait' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%'
        group by 1,2,3
    )
    group by 1,2,3
) b
on a.event_date=b.event_date and a.app_name=b.app_name
;



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
        event_date_hk between '2025-03-20' and '2025-04-19'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)

select e.event_date,e.app_name,e.button_type
    ,count(distinct e.user_pseudo_id) save_uv
    ,sum(e.pv) save_pv
    ,sum(case when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_video','save_gif')) then pv
              when (event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save_all') then coalesce(t.pkg_num,1)*pv
              end) save_photo_num
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e,unnest(split(theme,',')) k
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
left join (select name,project projects,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1,2) t
on REGEXP_REPLACE(k,r'live photo\+','')=t.name and e.project_name=t.projects
where project = 'ai_portrait' and event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%'
group by 1,2,3





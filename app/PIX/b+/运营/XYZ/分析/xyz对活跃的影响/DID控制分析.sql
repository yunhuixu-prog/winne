drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre` as

select app_name,event_date,event_name,platform,project,user_pseudo_id
        ,case when event_name in ('h5_page_visit_bd','h5_page_visit','beauty_appr_edit_clk_bd','first_func_enter') then 'visit'
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk','beauty_style_clk_bd', 'material_click') then 'generate_success'
        end event_type
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
where event_date between '2025-06-01' and '2025-06-30'
    and
    (
        event_name in ('h5_page_visit_bd','h5_page_visit','beauty_style_clk_bd', 'material_click','beauty_appr_edit_clk_bd','first_func_enter')

        or

        (event_name in ('h5_page_button_clk_bd', 'h5_page_button_clk')
                and button_type in
                    ('non_zero_generate_upload', 'zero_generate_upload', 'non_zero_generate', 'zero_generate', 'generate',
                     'list', 'retry', 'upload_new', 'to_video')
                and coalesce(task_id, '-')!='no_task')
    )
;

drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user` as

with goal_user as
(
    -- 首次进入/生成XYZ的用户 & 其他活跃用户
    select aa.app_name,aa.user_pseudo_id,aa.date,if(bb.user_pseudo_id is null,0,1) is_xyz_enter,if(cc.user_pseudo_id is null,0,1) is_xyz_generate
    from
    (
        select app_name,user_pseudo_id,min(event_date_hk) date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2025-06-01' and '2025-06-30'
            and app_name in ('BeautyPlus','AirBrush')
        group by 1,2
    ) aa
    left join
    (
        select app_name,user_pseudo_id,min(event_date) date,count(case when event_type='generate_success' then 1 end) generate_success_pv
        from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre`
        where event_date between '2025-06-01' and '2025-06-30'
            and event_type='visit'
        group by 1,2
    ) bb
    on aa.app_name=bb.app_name and aa.user_pseudo_id=bb.user_pseudo_id
    left join
    (
        select app_name,user_pseudo_id
        from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre`
        where event_date between '2025-06-01' and '2025-06-30'
            and event_type='generate_success'
        group by 1,2
    ) cc
    on bb.app_name=cc.app_name and bb.user_pseudo_id=cc.user_pseudo_id
)

select aa.app_name,aa.date,aa.user_pseudo_id,aa.is_xyz_enter,aa.is_xyz_generate
     ,date_diff(aa.event_date_hk,aa.date,day) days
     ,if(bb.user_pseudo_id is null,0,1) is_active
from
(
    select g.*,u.event_date_hk
    from goal_user g
    cross join
    (
        select distinct event_date_hk
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between date_sub('2025-06-01',interval 30 day) and date_add('2025-06-30',interval 7 day)
    ) u
    where u.event_date_hk between date_sub(g.date,interval 30 day) and date_add(g.date,interval 7 day)
) aa
left join
(
    select distinct a.app_name,a.user_pseudo_id,a.date,b.event_date_hk
    from goal_user a
    join
    (
        select app_name,event_date_hk,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between date_sub('2025-06-01',interval 30 day) and date_add('2025-06-30',interval 7 day)
            and app_name in ('BeautyPlus','AirBrush')
    ) b
    on a.app_name=b.app_name and a.user_pseudo_id=b.user_pseudo_id
           and b.event_date_hk between date_sub(a.date,interval 30 day) and date_add(a.date,interval 7 day)
) bb
on aa.app_name=bb.app_name and aa.user_pseudo_id=bb.user_pseudo_id and aa.date=bb.date and aa.event_date_hk=bb.event_date_hk

;

select app_name
     ,case when active_days_30_pre=0 then '0:0'
           when active_days_30_pre=1 then '1:1'
           when active_days_30_pre<=3 then '2:[2,3]'
           when active_days_30_pre<=7 then '3:[4,7]'
           when active_days_30_pre<=15 then '4:[8,15]'
      else '5:[16,30]'
      end active_days_30_pre_type
     ,is_xyz_enter
     ,count(distinct user_pseudo_id) uv
from
(
    select app_name,user_pseudo_id,is_xyz_enter
         ,sum(case when days between -30 and -1 then is_active end) active_days_30_pre
         ,sum(case when days between -7 and -1 then is_active end) active_days_7_pre
         ,sum(case when days between 1 and 7 then is_active end) active_days_7_af
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3

;

with user_agg as
(
    select app_name,user_pseudo_id,is_xyz_enter
         ,sum(case when days between -30 and -1 then is_active end) active_days_30_pre
         ,sum(case when days between -7 and -1 then is_active end) active_days_7_pre
         ,sum(case when days between 1 and 7 then is_active end) active_days_7_af
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
    group by 1,2,3
)

select a.app_name
     ,a.is_xyz_enter
     ,a.days
     ,count(distinct a.user_pseudo_id) uv
     ,sum(a.is_active) active_users
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user` a
join
(
    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=1

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre=0
      and rand()<0.1181

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre=1
      and rand()<0.1100

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre between 2 and 3
      and rand()<0.1417

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre between 4 and 7
      and rand()<0.2074

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre between 8 and 15
      and rand()<0.3351

    union all

    select app_name,user_pseudo_id
    from user_agg
    where is_xyz_enter=0
      and active_days_30_pre>=16
      and rand()<0.5812
) b
on a.app_name=b.app_name and a.user_pseudo_id=b.user_pseudo_id
group by 1,2,3
order by 1,2,3



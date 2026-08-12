drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre` as

-- with
-- event_pre_raw as
-- (
--    select
--         app_name
--         ,event_date
--         ,event_name
--         ,platform
--         ,coalesce(app_info.version,'unknown') version
--         ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
--         ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
-- --         ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
--         ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
--         ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
-- --         ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
-- --         ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
-- --         ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
--         ,user_pseudo_id
--     from
--         `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-06-01', '2025-06-30', 'beautyplus,airbrush', false)
--     where event_name in ('h5_page_visit_bd','h5_page_visit'
--                         ,'h5_page_button_clk_bd','h5_page_button_clk')
-- )
--
-- select *
--      ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'visit'
--               when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'generate_success'
--      end event_type
-- from event_pre_raw
-- where case when event_name in ('h5_page_visit_bd','h5_page_visit') then project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
--         when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task' and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
--         else 1=0
--         end

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

-- 参与XYZ用户与其他用户对比
select a.app_name,a.date,a.user_pseudo_id,a.is_xyz_enter,a.is_xyz_generate
     ,b.last_active_days last_active_days_pre
     ,b.event_date_hk event_date_hk_pre
     ,b.active_mins_7d active_mins_7d_pre,b.active_sessions_7d active_sessions_7d_pre,b.active_days_7d active_days_7d_pre
     ,c.event_date_hk event_date_hk_af
     ,c.active_mins_7d active_mins_7d_af,c.active_sessions_7d active_sessions_7d_af,c.active_days_7d active_days_7d_af
     ,c.first_active_date
from
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
) a
left join
(
    select 'BeautyPlus' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date
         ,DATE_DIFF(event_date_hk,last_active_date,DAY) last_active_days
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between date_sub('2025-06-01', interval 1 day) and date_sub('2025-06-30', interval 1 day)

    union all

    select 'AirBrush' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date
         ,DATE_DIFF(event_date_hk,last_active_date,DAY) last_active_days
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between date_sub('2025-06-01', interval 1 day) and date_sub('2025-06-30', interval 1 day)
) b
on a.user_pseudo_id=b.user_pseudo_id and a.app_name=b.app_name and date_sub(a.date, interval 1 day)=b.event_date_hk
left join
(
    select 'BeautyPlus' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date,last_active_date
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between date_add('2025-06-01', interval 8 day) and date_add('2025-06-30', interval 8 day)

    union all

    select 'AirBrush' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date,last_active_date
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between date_add('2025-06-01', interval 8 day) and date_add('2025-06-30', interval 8 day)
) c
on a.user_pseudo_id=c.user_pseudo_id and a.app_name=c.app_name and date_add(a.date, interval 8 day)=c.event_date_hk
;

select * from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
;
select app_name
     ,case when date_diff(date,first_active_date,day)=0 then 'new'
      else 'old'
      end is_new
     ,is_xyz_enter
     ,if(active_mins_7d_pre<active_mins_7d_af,1,0) is_more_active
     ,count(distinct user_pseudo_id) uv
     ,round(avg(last_active_days_pre),2) last_active_days_pre
     ,round(avg(active_mins_7d_pre),2) active_mins_7d_pre
--      ,round(avg(active_sessions_7d_pre),2) active_sessions_7d_pre
     ,round(avg(active_days_7d_pre),2) active_days_7d_pre
     ,round(avg(active_mins_7d_af),2) active_mins_7d_af
--      ,round(avg(active_sessions_7d_af),2) active_sessions_7d_af
     ,round(avg(active_days_7d_af),2) active_days_7d_af
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
group by 1,2,3,4
order by 1,2,3,4
;
select app_name
     ,case when date_diff(date,first_active_date,day)=0 then 'new'
      else 'old'
      end is_new
     ,is_xyz_enter
     ,count(distinct user_pseudo_id) uv
     ,round(avg(last_active_days_pre),2) last_active_days_pre
     ,round(avg(active_mins_7d_pre),2) active_mins_7d_pre
--      ,round(avg(active_sessions_7d_pre),2) active_sessions_7d_pre
     ,round(avg(active_days_7d_pre),2) active_days_7d_pre
     ,round(avg(active_mins_7d_af),2) active_mins_7d_af
--      ,round(avg(active_sessions_7d_af),2) active_sessions_7d_af
     ,round(avg(active_days_7d_af),2) active_days_7d_af
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
group by 1,2,3
order by 1,2,3
;
select app_name
     ,case when date_diff(date,first_active_date,day)=0 then '1:0'
           when date_diff(date,first_active_date,day)<=7 then '2:(0,7]'
           when date_diff(date,first_active_date,day)<=30 then '3:(7,30]'
           when date_diff(date,first_active_date,day)<=90 then '4:(30,90]'
           when date_diff(date,first_active_date,day)<=180 then '5:(90,180]'
           when date_diff(date,first_active_date,day)<=365 then '6:(180,365]'
      else '7:(365,)'
      end install_day
--      ,case when last_active_days_pre is null then '0:null'
--            when last_active_days_pre=0 then '1:0'
--            when last_active_days_pre<=7 then '2:(0,7]'
--            when last_active_days_pre<=30 then '3:(7,30]'
--            when last_active_days_pre<=90 then '4:(30,90]'
--            when last_active_days_pre<=180 then '5:(90,180]'
--            when last_active_days_pre<=365 then '6:(180,365]'
--       else '7:(365,)'
--       end last_active_days_pre
     ,is_xyz_enter
     ,count(distinct user_pseudo_id) uv
     ,round(avg(last_active_days_pre),2) last_active_days_pre
     ,round(avg(active_mins_7d_pre),2) active_mins_7d_pre
--      ,round(avg(active_sessions_7d_pre),2) active_sessions_7d_pre
     ,round(avg(active_days_7d_pre),2) active_days_7d_pre
     ,round(avg(active_mins_7d_af),2) active_mins_7d_af
--      ,round(avg(active_sessions_7d_af),2) active_sessions_7d_af
     ,round(avg(active_days_7d_af),2) active_days_7d_af
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
group by 1,2,3
order by 1,2,3
;
select app_name
--      ,case when date_diff(date,first_active_date,day)=0 then '1:0'
--            when date_diff(date,first_active_date,day)<=7 then '2:(0,7]'
--            when date_diff(date,first_active_date,day)<=30 then '3:(7,30]'
--            when date_diff(date,first_active_date,day)<=90 then '4:(30,90]'
--            when date_diff(date,first_active_date,day)<=180 then '5:(90,180]'
--            when date_diff(date,first_active_date,day)<=365 then '6:(180,365]'
--       else '7:(365,)'
--       end install_day
     ,case when active_mins_7d_pre is null then '0:null'
           when active_mins_7d_pre=0 then '1:0'
           when active_mins_7d_pre<=3 then '2:(0,3]'
           when active_mins_7d_pre<=5 then '3:(3,5]'
           when active_mins_7d_pre<=10 then '4:(5,10]'
           when active_mins_7d_pre<=20 then '5:(10,20]'
      else '7:(20,)'
      end active_mins_7d_pre_type
     ,is_xyz_enter
     ,count(distinct user_pseudo_id) uv
     ,round(avg(last_active_days_pre),2) last_active_days_pre
     ,round(avg(active_mins_7d_pre),2) active_mins_7d_pre
--      ,round(avg(active_sessions_7d_pre),2) active_sessions_7d_pre
     ,round(avg(active_days_7d_pre),2) active_days_7d_pre
     ,round(avg(active_mins_7d_af),2) active_mins_7d_af
--      ,round(avg(active_sessions_7d_af),2) active_sessions_7d_af
     ,round(avg(active_days_7d_af),2) active_days_7d_af
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user`
group by 1,2,3
order by 1,2,3
;

-- 单个用户
select 'BeautyPlus' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date,last_active_date
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk between date_sub('2025-06-01', interval 8 day) and date_add('2025-06-30', interval 8 day)
and user_pseudo_id='c5a927c630e97419c411171b7dc85fa5'



-- 进入XYZ用户安装时长分布
select aa.app_name
     ,if(bb.user_pseudo_id is null,0,1) is_xyz_enter
     ,case when date_diff(event_date_hk,first_active_date,day)=0 then '1:0'
           when date_diff(event_date_hk,first_active_date,day)<=7 then '2:(0,7]'
           when date_diff(event_date_hk,first_active_date,day)<=30 then '3:(7,30]'
           when date_diff(event_date_hk,first_active_date,day)<=90 then '4:(30,90]'
           when date_diff(event_date_hk,first_active_date,day)<=180 then '5:(90,180]'
           when date_diff(event_date_hk,first_active_date,day)<=365 then '6:(180,365]'
      else '7:(365,)'
      end install_day
     ,count(1) num
from
(
    select 'BeautyPlus' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date,last_active_date
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between '2025-06-01' and '2025-06-30' and last_active_date=event_date_hk

    union all

    select 'AirBrush' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date,last_active_date
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between '2025-06-01' and '2025-06-30' and last_active_date=event_date_hk
) aa
left join
(
    select app_name,user_pseudo_id,event_date
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_active_user_pre`
    where event_date between '2025-06-01' and '2025-06-30'
    and event_type='visit'
    group by 1,2,3
) bb
on aa.app_name=bb.app_name and aa.user_pseudo_id=bb.user_pseudo_id and aa.event_date_hk=bb.event_date
group by 1,2,3
order by 1,2,3

-- 看一下数
select app_name,date
    ,count(distinct user_pseudo_id) uv
     ,avg(active_mins_7d) active_mins_7d,avg(active_sessions_7d) active_sessions_7d,avg(active_days_7d) active_days_7d
from (
    select a.app_name,a.date,a.user_pseudo_id
         ,b.event_date_hk event_date_hk_pre
         ,b.active_mins_7d,b.active_sessions_7d,b.active_days_7d
    from
    (
        select app_name,user_pseudo_id,event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2025-06-01' and '2025-06-30'
        and app_name in ('BeautyPlus','AirBrush')
    ) a
    left join
    (
        select 'BeautyPlus' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date
        from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk between date_sub('2025-06-01', interval 1 day) and date_sub('2025-06-30', interval 1 day)

        union all

        select 'AirBrush' app_name,event_date_hk,user_pseudo_id,active_mins_7d,active_sessions_7d,active_days_7d,first_active_date
        from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk between date_sub('2025-06-01', interval 1 day) and date_sub('2025-06-30', interval 1 day)
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and a.app_name=b.app_name and date_sub(a.date, interval 1 day)=b.event_date_hk
)
group by 1,2
order by 1,2


-- 每天活跃用户的近7天活跃时长分布
select event_date_hk,count(distinct user_pseudo_id) uv,avg(active_mins_7d) active_mins_7d
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk between '2025-06-01' and '2025-06-30' and last_active_date=event_date_hk
group by 1



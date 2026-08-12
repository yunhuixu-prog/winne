delete from `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme_v_report`
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme_v_report`
select * from dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme_v
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
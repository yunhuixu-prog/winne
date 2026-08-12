delete from `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all_function`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all_function`
(
    date,data_type,
    country,platform,is_new,is_UA,app_version,
    feature,sub_feature,
    material_id,material_name,material_icon,paid_type,module,is_available,
    exposure,click,save,sub
)
with material_info as
(
 select  m_id,icon,name,paid_type,available as is_available,start_date
from  `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('104')
and start_date>='2022-01-01'
group by 1,2,3,4,5,6
 )

select date,'uv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature, '' as sub_feature,
    '' material_id,''  material_name, '' as material_icon, 2 as paid_type,module,is_available,
  count(distinct case when   event_action='impression' then user_pseudo_id end) as exposure,
  count(distinct case when   event_action='click' then user_pseudo_id end) as click,
  count(distinct case when   event_action='save' then user_pseudo_id end) as save,
  count(distinct case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
  left join material_info d on a.material_id=d.m_id and a.date=d.start_date
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
union all
select date,'pv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature, '' as sub_feature,
    '' material_id,''  material_name, '' as material_icon, 2 as paid_type,module,is_available,
  count( case when  event_action='impression' then user_pseudo_id end) as exposure,
  count( case when   event_action='click' then user_pseudo_id end) as click,
  count( case when   event_action='save' then user_pseudo_id end) as save,
  count( case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
 left join material_info d on a.material_id=d.m_id and a.date=d.start_date
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
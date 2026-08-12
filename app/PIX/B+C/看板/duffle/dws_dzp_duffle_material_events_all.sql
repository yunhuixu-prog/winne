delete from `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all`   where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all`
with material_info as
(
 select distinct m_id,icon,name,paid_type
from
(
select *
      ,row_number() over(
        partition by m_id order by start_date desc) rn
from  `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('104')
) a
where a.rn=1
 )
select date,'uv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature, case when feature='配方' then '配方'
     else sub_feature end as sub_feature,
    material_id,m.name as material_name, m.icon as material_icon, cast (m.paid_type as int) paid_type,
  count(distinct case when  event_action='impression' then user_pseudo_id end) as exposure,
  count(distinct case when   event_action='click' then user_pseudo_id end) as click,
  count(distinct case when   event_action='save' then user_pseudo_id end) as save,
  count(distinct case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
left join material_info m on a.material_id=m.m_id
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
union all
select date,'pv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature, case when feature='配方' then '配方'
     else sub_feature end as sub_feature,
    material_id,m.name as material_name, m.icon as material_icon,cast (m.paid_type as int) paid_type,
  count( case when  event_action='impression' then user_pseudo_id end) as exposure,
  count( case when   event_action='click' then user_pseudo_id end) as click,
  count( case when   event_action='save' then user_pseudo_id end) as save,
  count( case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
left join material_info m on a.material_id=m.m_id
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

--配方具体来源
union all
select date,'uv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature,  sub_feature,
    material_id,m.name as material_name, m.icon as material_icon, cast (m.paid_type as int) paid_type,
  count(distinct case when  event_action='impression' then user_pseudo_id end) as exposure,
  count(distinct case when   event_action='click' then user_pseudo_id end) as click,
  count(distinct case when   event_action='save' then user_pseudo_id end) as save,
  count(distinct case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
left join material_info m on a.material_id=m.m_id
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
union all
select date,'pv' as data_type,
    country,platform,is_new,is_UA,app_version,
     feature,  sub_feature,
    material_id,m.name as material_name, m.icon as material_icon,cast (m.paid_type as int) paid_type,
  count( case when  event_action='impression' then user_pseudo_id end) as exposure,
  count( case when   event_action='click' then user_pseudo_id end) as click,
  count( case when   event_action='save' then user_pseudo_id end) as save,
  count( case when   event_action='subscription' then user_pseudo_id end) as sub
from
     `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all` a
left join material_info m on a.material_id=m.m_id
where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

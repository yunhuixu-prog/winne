--ads_material_events_all
with mid_rank as
(
select *
      ,row_number() over(
        partition by m_id order by start_date desc) rn
from  `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')
and start_date>='2022-01-01'
) ,
material_info as
(
 select distinct m_id,icon,name,paid_type,case
when creator=''then copyright_owner
when creator is not null then creator
else copyright_owner end as creator,copyright_owner,tag_id
from mid_rank
where rn=1
),
  material_info_new as
(
 select m_id,tag_id,CONCAT
 (
  UPPER(SUBSTRING( TRIM(creator),1,1)),
  SUBSTRING( TRIM(creator),2,100)
 ) as creator
 from material_info
),
  material_info_start_date as
(
 select  m_id,min(start_date) start_date
from mid_rank
group by 1
),
  material_info_available as
(
 select  start_date,m_id,
    case when available ='1' then 'available'
         when available ='0' then 'unavailable'
         else 'unknown'
        end as is_available
from mid_rank
group by 1,2,3
)


select 'BeautyPlus' app_name,date,
   data_type,
    case
    when country in ('South Korea','Thailand','Japan','United States','China','Indonesia') then country
    when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
    else 'general' end as key_country,country,
    trim(feature) as feature,sub_feature,platform,
    material_id,material_name, material_icon,
    case
      when feature='贴纸' then substring( material_name,1,6)
      else tag_id
      end as tag_id,
    case
      when paid_type=1 then 'paid'
      when paid_type=0 then 'free'
      else '' end as paid_type ,c.start_date,is_available,--20240520修改
    app_version,trim(creator) as creator
, sum(exposure) exposure ,sum(click) click,0 check,sum(save) save
,sum(sub) sub,0 sub_to_paid,0 revenue
from
     `beautyplus-bc0ed.Duffle_dataset.dws_dz_material_events_all`  a
   left join material_info_new b on a.material_id=b.m_id
   left join material_info_start_date c on a.material_id=c.m_id
   left join material_info_available d on a.material_id=d.m_id and a.date=d.start_date
   where sub_feature not in ('专题配方','推荐配方','duffle 配方','banner配方')
group by 1 ,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

union all
-- B+C的paid_type均设置为空
select 'Beauty Plus Cam' app_name,date,
   data_type,
    case
    when country in ('South Korea','Thailand','Japan','United States','China','Indonesia') then country
    when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
    else 'general' end as key_country,country,
    trim(feature) as feature,sub_feature,platform,
    material_id,material_name, material_icon,
    case
      when feature='贴纸' then substring( material_name,1,6)
      else tag_id
      end as tag_id,
    '' as paid_type ,c.start_date,is_available,--20240520修改
    app_version,trim(creator) as creator
, sum(exposure) exposure ,sum(click) click,0 check,sum(save) save
,sum(sub) sub,0 sub_to_paid,0 revenue
from
     `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all`  a
   left join material_info_new b on a.material_id=b.m_id
   left join material_info_start_date c on a.material_id=c.m_id
   left join material_info_available d on a.material_id=d.m_id and a.date=d.start_date
   where sub_feature not in ('专题配方','推荐配方','duffle 配方','banner配方')
group by 1 ,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
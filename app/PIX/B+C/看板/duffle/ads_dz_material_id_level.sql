-- 素材view表`beautyplus-bc0ed.Duffle_dataset.ads_dz_material_id_level'
-- background material uv table

with uv_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Background' as feature, material_sub_module as sub_feature, 'null' as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub
from
  `dataintegration-265403.duffle.dws_dz_material_background_info`
where app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
and adopted !='any' and material_is_paid !='any' and material_sub_module !='any' and material_id !='any'
and material_id not in ('1BGG00000026', '1BGG00000023','BP_TEX_00000017', 'BP_TEX_00000031', '1BGG00000025', '1BGG00000021', '1BGG00000022', 'BP_TEX_00000050', 'BP_TEX_00000052', 'BP_TEX_00000049', 'BP_TEX_00000045', '1BGG00000020', '1BGG00000024', 'BP_TEX_00000046')
)
select b.*, c.icon,'/' as is_new
from uv_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('BGT' ,'BGG') )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)


union all
# background material pv table

(with pv_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Background' as feature, material_sub_module as sub_feature, 'null' as material_category, material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub  #pv=uv
from
  `dataintegration-265403.duffle.dws_dz_material_background_info`
where app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
and adopted !='any' and material_is_paid !='any' and material_sub_module !='any' and material_id !='any'
and material_id not in ('1BGG00000026', '1BGG00000023','BP_TEX_00000017', 'BP_TEX_00000031', '1BGG00000025', '1BGG00000021', '1BGG00000022', 'BP_TEX_00000050', 'BP_TEX_00000052', 'BP_TEX_00000049', 'BP_TEX_00000045', '1BGG00000020', '1BGG00000024', 'BP_TEX_00000046')
)
select b.*, c.icon,'/' as is_new
from pv_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('BGT' ,'BGG') )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# text -- template uv table
(
with uv_text_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Text' as feature, 'Text template' as sub_feature, 'null' as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub
FROM
  `dataintegration-265403.duffle.dws_dz_material_text_template_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
and adopted !='any' and material_is_paid !='any' and material_id !='any'
)
select b.*, c.icon,'/' as is_new
from uv_text_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('TEX' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# text -- template pv table
(
with pv_text_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Text' as feature, 'Text template' as sub_feature, 'null' as material_category, material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub  #pv=uv
FROM
  `dataintegration-265403.duffle.dws_dz_material_text_template_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
and adopted !='any' and material_is_paid !='any' and material_id !='any'
)
select b.*, c.icon,'/' as is_new
from pv_text_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('TEX' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# text -- font uv table
(
with uv_font_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Text' as feature, 'Font' as sub_feature, material_type as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, 0 as Sub #font没有sub column, 以0赋值方便union
FROM
  `dataintegration-265403.duffle.dws_dz_material_font_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
  and adopted !='any' and material_is_paid !='any' and  material_type!='any' and material_id !='any'
)
select b.*, c.icon,'/' as is_new
from uv_font_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('FON' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# text -- font pv table
(
with pv_font_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = '0' then 'Available' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Text' as feature, 'Font' as sub_feature, material_type as material_category, material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, 0 as Sub  #pv没有sub column, 以0赋值方便union
FROM
  `dataintegration-265403.duffle.dws_dz_material_font_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
  and adopted !='any' and material_is_paid !='any' and  material_type!='any' and material_id !='any'
)
select b.*, c.icon,'/' as is_new
from pv_font_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('FON' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)

union all

# doodle material uv table
(
with uv_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = 0 then 'Available' when adopted = 1 then 'Unavailable'  end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Doodle' as feature, 'null'  as sub_feature, material_type as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub --,icon,recommend as is_hot
from
  `dataintegration-265403.duffle.dws_dz_material_doodle_info_v`
where app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
--and adopted !='any'
and material_is_paid !='any' and material_id !='any'
and material_type!='any' and recommend !='any'
and material_id not like '%400%'
and material_id is not null
)
select b.*,c.icon,c.is_new
from uv_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('BRU' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)

union all
# doodle material pv table
(
with pv_table as
(
select
  event_date as date, app_id, platform, continent,  sub_continent,country,
  case when adopted = 0 then 'Available'
  when adopted = 1 then 'Unavailable'
  end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Doodle'  as feature, 'null' as sub_feature, material_type as material_category,  material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, case when sub_uv is null then 0 else sub_uv end as Sub --,icon,recommend as is_hot  #pv=uv
from
  `dataintegration-265403.duffle.dws_dz_material_doodle_info_v`
where app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
--and adopted !='any'
and material_is_paid !='any'  and material_id !='any'
and material_type!='any' and recommend !='any'
and material_id not like '%400%'
and material_id is not null
)
select b.*,c.icon,c.is_new
from pv_table b
left join (select  distinct start_date,end_date,theme,m_id,icon,case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('BRU' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)

union all
# template uv table
(
with uv_template_table as
(
select
  date_p as date, app_id, platform, continent, sub_continent,country,
  case when material_is_available = '1' then 'Available'  else 'Unavailable' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Template' as feature, 'null' as sub_feature, material_type as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, subscription_uv as Sub
FROM
  `dataintegration-265403.duffle.dws_dz_material_template_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
   and material_is_paid !='any' and  material_type!='any' and material_id !='any'
)
select b.*, c.icon, c.is_new
from uv_template_table b
left join (select  distinct start_date,end_date,theme,m_id,icon, case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('TEM' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# template pv table
(
with pv_template_table as
(
select
 date_p as date, app_id, platform, continent, sub_continent,country,
  case when material_is_available = '1' then 'Available'  else 'Unavailable' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Template' as feature, 'null' as sub_feature, material_type as material_category, material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, subscription_uv as Sub
FROM
  `dataintegration-265403.duffle.dws_dz_material_template_info`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
  and material_is_paid !='any' and  material_type!='any' and material_id !='any'
)
select b.*, c.icon, c.is_new
from pv_template_table b
left join (select  distinct start_date,end_date,theme,m_id,icon, case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('TEM' ) )c  on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# look uv table
(
with uv_look_table as
(
select
  date_p as date, app_id, platform, continent, sub_continent,country,
  case when material_is_available = '1' then 'Available'  else 'Unavailable' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Look' as feature,  sub_feature, material_type as material_category, material_id,
  'UV' as data_type, save_uv as Save, save_pv as save_temp, click_uv as Click, impression_uv as Exposure, subscription_uv as Sub
FROM
  `dataintegration-265403.duffle.dws_dz_material_look_info_new`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
    and  material_type!='any' and material_id !='any' and material_is_paid !='any' and sub_feature!='any'
)
select b.*, c.icon, c.is_new
from uv_look_table b
left join (select  distinct start_date,end_date,theme,m_id,icon, case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
  else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('LOK' ) )c on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# Look pv table
(
with pv_look_table as
(
select
 date_p as date, app_id, platform, continent, sub_continent,country,
  case when material_is_available = '1' then 'Available'  else 'Unavailable' end as is_available,
  case when material_is_paid = '0' then 'Free' when material_is_paid = '1' then 'Paid' end as is_paid,
  'Look' as feature,  sub_feature, material_type as material_category, material_id,
  'PV' as data_type, save_pv as Save, save_uv as save_temp, click_pv as Click, impression_pv as Exposure, subscription_uv as Sub
FROM
  `dataintegration-265403.duffle.dws_dz_material_look_info_new`
WHERE app_id='BeautyPlus' and platform!='any' and continent!='any' and sub_continent!='any' and country !='any'
   and  material_type!='any' and material_id !='any' and material_is_paid !='any' and sub_feature!='any'
)
select b.*, c.icon, c.is_new
from pv_look_table b
left join (select  distinct start_date,end_date,theme,m_id,icon, case when is_new= 1 then 'new'  else 'not' end as is_new,
 case when app_id='103' then 'IOS'
 else 'ANDROID' END AS platform
  from
 `dataintegration-265403.duffle_fin.dmi_da_materials_info`
where app_id in ('103','104')  and Theme IN ('LOK' ) )c  on (c.m_id=b.material_id and  start_date <=date  and date  < end_date and b.platform=c.platform)
)
union all
# Style table

select
    date,'' app_id, platform, '' continent, '' sub_continent,'' country,
  ifnull(c.duffle_id,a.material_id)  as duffle_id , ifnull(b.is_paid,c.is_paid) as is_paid,
  'Style' as feature,  '' sub_feature,  ifnull(b.material_category,c.material_category) as material_category,  a.material_id,
   data_type,  Save,  save_temp,  Click,  Exposure,  Sub ,ifnull(b.icon,c.icon) as icon, ifnull(b.name,c.name)  as is_new
FROM
  (select a.*except(material_id), case when a.material_id='1STY000000010'then '1STY00000010' else a.material_id end as material_id
  from
    `dataintegration-265403.duffle.dws_dz_material_style_info_v` a) a
left join `dataintegration-265403.duffle.dmi_da_style_materials_info_temp` b
on a.material_id=b.duffle_id
left join `dataintegration-265403.duffle.dmi_da_style_materials_info_temp` c
on a.material_id=c.material_id
where Click>3
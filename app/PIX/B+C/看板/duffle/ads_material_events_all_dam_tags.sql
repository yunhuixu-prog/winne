--ads_material_events_all_dam_tags
with material_info as
(SELECT m_id,en_dam_tags
FROM `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` ,unnest(split(en_dam_tags, ',')) en_dam_tags
where app='BeautyPlus'
and tags is not null
and app='BeautyPlus'
group by 1,2

 )



select a.*, b.en_dam_tags as dam_tags
from
     `beautyplus-bc0ed.view.ads_material_events_all`  a
   left join material_info  b on a.material_id=b.m_id

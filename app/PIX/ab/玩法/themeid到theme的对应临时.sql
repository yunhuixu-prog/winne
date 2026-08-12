SELECT app, platform, m_id AS Material_id, MAX(icon) AS icon, MAX(name) Material_name
  FROM `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
  WHERE app='AirBrush' and m_id='AB_STY_00000140'
  group by 1,2,3
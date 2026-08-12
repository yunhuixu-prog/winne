-- `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme_v`
select
    app_name
    ,date
    ,e.platform
--     ,country
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Brazil','Russia','Bangladesh','Vietnam') then country
          else 'WW'
    end as country
    ,is_new
    ,is_ua
    ,project_name
    ,status
    ,entry
    ,case when source in ('H5','Style','Template') then source else 'Unknown' end source  -- 即把All改为Unknown，如果后续增加了汇总All的话，这里要改掉
    ,case when theme_type='image' then 'photo' else theme_type end theme_type
--     ,case when e.theme like 'Trending%' or e.theme like 'Portrait%' or e.theme like 'Pet%' or e.theme like 'Food%' or e.theme like 'ScenicZone%'
--                 then if(ARRAY_LENGTH(split(replace(theme,' ','_'),'_'))>=2,split(replace(theme,' ','_'),'_')[1],e.theme) else e.theme end theme
    ,coalesce(p.standard_theme,case when e.theme like 'Trending%' or e.theme like 'Portrait%' or e.theme like 'Pet%' or e.theme like 'Food%' or e.theme like 'ScenicZone%' or e.theme like 'Festive%'
                then if(ARRAY_LENGTH(split(replace(theme,' ','_'),'_'))>=2,split(replace(theme,' ','_'),'_')[1],e.theme) else e.theme end) theme
    ,e.theme_id
    ,s.icon
    ,'uv' data_type
    ,t.pkg_num photo_num
    ,sum(exposure_uv) exposure
    ,sum(click_uv) click

    ,sum(enter_generate_page_uv) enter_generate_page
    ,sum(click_generate_uv) click_generate
    ,sum(click_generate_uv) click_generate_change
    ,sum(save_uv) save
    ,sum(save_uv) save_change
    ,sum(save_photo_num) save_photo_num
    ,sum(share_uv) share
    ,sum(sub_uv) sub
    ,sum(sub_pay_uv) sub_pay
    ,sum(sub_revenue) sub_revenue
from
    `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme` e
left join (select project,theme_id,max(theme) standard_theme,max(icon) icon from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_standard_name group by 1,2) p
on e.theme_id=p.theme_id and e.project_name=p.project
left join (
            select app,platform,m_id Material_id,max(icon) icon
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY') or theme='FRA')
            group by 1,2,3

            union all

            select 'Beauty Plus Cam' app,platform,m_id Material_id,max(icon) icon
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY')) and app='BeautyPlus' and platform='ANDROID'
            group by 1,2,3
    ) s on e.app_name = s.app
        AND e.platform = s.platform
        AND e.theme_id=s.Material_id
left join (select name,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1) t on e.theme=t.name
where project_name not in ('Tooniverse') and entry='All'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

union all

select
    app_name
    ,date
    ,e.platform
--     ,country
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Brazil','Russia','Bangladesh','Vietnam') then country
          else 'WW'
    end as country
    ,is_new
    ,is_ua
    ,project_name
    ,status
    ,entry
    ,case when source in ('H5','Style','Template') then source else 'Unknown' end source
    ,case when theme_type='image' then 'photo' else theme_type end theme_type
--     ,case when e.theme like 'Trending%' or e.theme like 'Portrait%' or e.theme like 'Pet%' or e.theme like 'Food%' or e.theme like 'ScenicZone%'
--                 then if(ARRAY_LENGTH(split(replace(theme,' ','_'),'_'))>=2,split(replace(theme,' ','_'),'_')[1],e.theme) else e.theme end theme
    ,coalesce(p.standard_theme,case when e.theme like 'Trending%' or e.theme like 'Portrait%' or e.theme like 'Pet%' or e.theme like 'Food%' or e.theme like 'ScenicZone%' or e.theme like 'Festive%'
                then if(ARRAY_LENGTH(split(replace(theme,' ','_'),'_'))>=2,split(replace(theme,' ','_'),'_')[1],e.theme) else e.theme end) theme
    ,e.theme_id
    ,s.icon
    ,'pv' data_type
    ,t.pkg_num photo_num
    ,sum(exposure_pv) exposure
    ,sum(click_pv) click

    ,sum(enter_generate_page_pv) enter_generate_page
    ,sum(click_generate_pv) click_generate
--     ,sum(coalesce(generate_photo_num,click_generate_pv*coalesce(t.pkg_num,1))) click_generate_change
    ,sum(generate_photo_num) click_generate_change
--     ,sum(click_generate_pv*coalesce(t.pkg_num,1)) click_generate_change
    ,sum(save_pv) save
    ,sum(save_photo_num) save_change
    ,sum(save_photo_num) save_photo_num
    ,sum(share_pv) share
    ,sum(sub_uv) sub
    ,sum(sub_pay_uv) sub_pay
    ,sum(sub_revenue) sub_revenue
from
    `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme` e
left join (select project,theme_id,max(theme) standard_theme,max(icon) icon from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_standard_name group by 1,2) p
on e.theme_id=p.theme_id and e.project_name=p.project
left join (
            select app,platform,m_id Material_id,max(icon) icon
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY') or theme='FRA')
            group by 1,2,3

            union all

            select 'Beauty Plus Cam' app,platform,m_id Material_id,max(icon) icon
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY') or theme='FRA') and app='BeautyPlus' and platform='ANDROID'
            group by 1,2,3
    ) s on e.app_name = s.app
        AND e.platform = s.platform
        AND e.theme_id=s.Material_id
left join (select name,max(num) pkg_num from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg group by 1) t on e.theme=t.name
where project_name not in ('Tooniverse') and entry='All'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

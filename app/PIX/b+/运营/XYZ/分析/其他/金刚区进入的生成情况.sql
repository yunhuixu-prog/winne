
drop table if exists `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre`;
create table if not exists `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre` as

select
    app_name
    ,event_date
    ,event_name
    ,platform
    ,coalesce(app_info.version,'unknown') version
    ,case when `dataintegration-265403.func`.getParams(event_params,'project').string_value='BeautyPlus - PuriPlus' then 'puriplus'
        else `dataintegration-265403.func`.getParams(event_params,'project').string_value end project
    ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
    ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
    ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
    ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
    ,`dataintegration-265403.func`.getParams(event_params,'entry').string_value entry
    ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
    ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
    ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
    ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
    ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value pop_id
    ,`dataintegration-265403.func`.getParams(event_params,'style_id').string_value style_id
    ,`dataintegration-265403.func`.getParams(event_params,'machine').string_value machine
    ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
    ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
    ,`dataintegration-265403.func`.getParams(event_params,'module_position').string_value module_position
    ,`dataintegration-265403.func`.getParams(event_params,'ad_placement').string_value ad_placement
    ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value function
    ,case when app_name = 'AirBrush' then split(`dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value,'=')[1]
          else `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value
     end onelink_source
    ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
    ,user_pseudo_id
    ,event_timestamp
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-16', '2024-07-30', 'beautyplus,beautypluscam', false)
where event_name in ('home_content_show_f_bd','home_content_clk_bd'
                    ,'beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd'
                    ,'beauty_appr_edit_clk_bd','ad_inter_show'
                    )

;
drop table if exists `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`;
create table if not exists `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp` as

select coalesce(a.app_name,b.app_name) app_name
     ,a.type
     ,coalesce(a.platform,b.platform) platform
     ,coalesce(a.event_date,b.event_date) event_date
     ,coalesce(a.user_pseudo_id,b.user_pseudo_id) user_pseudo_id
     ,a.event_timestamp event_timestamp_icon
     ,b.event_timestamp event_timestamp_crayon
--      ,c.event_timestamp event_timestamp_mid
from
(
    select app_name,platform,event_date,user_pseudo_id,event_timestamp,'icon' type
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre` e
    where event_name in ('home_content_clk_bd')
        and module_type='推荐功能'
        and content_type in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='BeautyPlus' and Project='AI Filter 1.0')

--     select app_name,platform,event_date,user_pseudo_id,event_timestamp
--     from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre` e
--     where event_name in ('beauty_appr_edit_clk_bd')
--         and function='风格化'

    union all

            SELECT 'BeautyPlus' app_name
            ,platform
            ,event_date_hk event_date
            ,user_pseudo_id
            ,-1 event_timestamp,'pop' type
        FROM `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
        where
            event_date_hk between '2024-07-16' and '2024-07-30'
            and event_name in ('home_page_pop_appr_bd','home_page_pop_clk_bd')
            and key_name='pop_id' and value_name in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='BeautyPlus' and Project='AI Filter 1.0')

) a
-- left join
-- (
--     select app_name,platform,event_date,user_pseudo_id,event_timestamp
--     from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre` e
--     where event_name in ('ad_inter_show') and ad_placement='inter__album_upload'
-- ) c
-- on a.event_date=c.event_date and a.user_pseudo_id=c.user_pseudo_id and a.app_name=c.app_name and a.platform=c.platform
full join
(
    select app_name,platform,event_date,user_pseudo_id,event_timestamp
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp_pre` e
    where event_name in ('beauty_style_clk_bd') and style_id='BP_STY_00000117'
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id and a.app_name=b.app_name and a.platform=b.platform
;



-- select app_name,event_date,platform
--      ,count(distinct user_pseudo_id) icon_click_uv
--      ,count(distinct case when event_timestamp_crayon<event_timestamp_icon+15000000 and event_timestamp_crayon>event_timestamp_icon-15000000 then user_pseudo_id end) click_crayon_uv
--      ,count(distinct concat(user_pseudo_id,'-',event_timestamp_icon)) icon_click_pv
--      ,count(distinct case when event_timestamp_crayon<event_timestamp_icon+15000000 and event_timestamp_crayon>event_timestamp_icon-15000000 then concat(user_pseudo_id,'-',event_timestamp_icon) end) click_crayon_pv
-- from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
-- where event_timestamp_icon is not null
-- group by 1,2,3
-- order by 1,2,3
-- ;
select app_name,event_date,platform
     ,count(distinct user_pseudo_id) icon_click_uv
     ,count(distinct case when event_timestamp_crayon is not null then user_pseudo_id end) click_crayon_uv
     ,count(distinct concat(user_pseudo_id,'-',event_timestamp_icon)) icon_click_pv
     ,count(distinct case when event_timestamp_crayon is not null then concat(user_pseudo_id,'-',event_timestamp_icon) end) click_crayon_pv
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
where event_timestamp_icon is not null
group by 1,2,3
order by 1,2,3

-- 蜡笔点击中，来自金刚区的有多少
select app_name,event_date,platform
     ,count(distinct user_pseudo_id) click_crayon_uv
     ,count(distinct case when event_timestamp_icon is not null and type='icon' then user_pseudo_id end) icon_click_uv
     ,count(distinct case when event_timestamp_icon is not null and type='pop' then user_pseudo_id end) pop_click_uv
     ,count(distinct case when event_timestamp_icon is null then user_pseudo_id end) other_click_uv
--      ,count(distinct concat(user_pseudo_id,'-',event_timestamp_crayon)) click_crayon_pv
--      ,count(distinct case when event_timestamp_icon is not null then concat(user_pseudo_id,'-',event_timestamp_crayon) end) icon_click_pv
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
where event_timestamp_crayon is not null
group by 1,2,3
order by 1,2,3


-- icon->相册页广告->crayon点击
select app_name,event_date,platform
     ,count(distinct user_pseudo_id) icon_click_uv
     ,count(distinct case when event_timestamp_mid is not null then user_pseudo_id end) ad_uv
     ,count(distinct case when event_timestamp_mid is not null and event_timestamp_crayon is not null then user_pseudo_id end) click_crayon_uv
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
where event_timestamp_icon is not null
group by 1,2,3
order by 1,2,3




select *
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
where event_timestamp1 is null

select *
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior_from_icon_temp`
where event_timestamp is null

select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,user_pseudo_id
        ,event_timestamp
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'style_id').string_value style_id
        ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value function
        ,`dataintegration-265403.func`.getParams(event_params,'ad_placement').string_value ad_placement

from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-16', '2024-07-16', 'beautyplus,beautypluscam', false)
where user_pseudo_id='00018d261668d7b0fc1da491e2cb5b8e'
order by event_timestamp
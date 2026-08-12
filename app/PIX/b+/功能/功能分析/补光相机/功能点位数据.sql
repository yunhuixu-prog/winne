
with event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'module').string_value module
        ,`dataintegration-265403.func`.getParams(event_params,'next_mode_a').string_value next_mode
        ,`dataintegration-265403.func`.getParams(event_params,'camera_mode').string_value camera_mode
        ,`dataintegration-265403.func`.getParams(event_params,'category').string_value category
        ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value material_id
        ,user_pseudo_id
        ,platform
        ,version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-16','2025-03-22','beautyplus',false)
    where event_name in ('glow_cam_appr_bd','glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd'
                        ,'live_on_clk_bd','selfiepage_enter_album_bd','shoot_video_switch_bd')
)
,
user_info as
(
    select
        event_date_hk
        ,platform
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(country) country
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-03-16' and '2025-03-22'
        and app_name='BeautyPlus'
    group by 1,2,3
)

select t.event_date
    ,case when event_name in ('glow_cam_func_clk_bd','live_on_clk_bd','selfiepage_enter_album_bd','shoot_video_switch_bd') then 'func_clk'
          when event_name in ('glow_cam_material_clk_bd') then 'material_clk'
          when event_name in ('glow_cam_save_bd') then 'save'
    end action
    ,case when event_name in ('glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd') then category
          when event_name='live_on_clk_bd' then 'live'
          when event_name='selfiepage_enter_album_bd' then 'album'
          when event_name='shoot_video_switch_bd' then 'video'
    end func
    ,material_id material
    ,t.platform
    ,count(distinct t.user_pseudo_id) uv
    ,count(1) pv
from
    event t
join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform
where
        (
            event_name in ('glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd')
            or (event_name in ('live_on_clk_bd','selfiepage_enter_album_bd') and camera_mode='glow')
            or (event_name in ('shoot_video_switch_bd') and camera_mode='glow' and next_mode='video')
        )
group by 1,2,3,4,5



-- 订阅默认入口
select source_click_position,sum(uv) uv
from
(
select date,source_click_position,count(distinct user_pseudo_id) uv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-03-16' and '2025-03-22'
    and event_name in ('page_event')
    and source_feature_content like 'BP_LIG%'
group by 1,2
)
group by 1

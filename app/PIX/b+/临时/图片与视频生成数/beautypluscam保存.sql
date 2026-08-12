--------- B+C
with event as
(
    select
        -- app_name
        'Beauty Plus Cam' app_name
        ,date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) event_date_hk
        ,`dataintegration-265403.func`.getParams(event_params,'module').string_value module
        -- ,event_date_hk
        ,event_name
        ,event_params
        ,user_pseudo_id
        ,version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01', '2024-12-31', 'Beauty Plus Cam', false)
    where
        event_name in ('selfiesave_bd','movecheck_save_bd','ad_beautifysvclk','beautifysave_bd','iphone_mode_save_bd','stamp_cam_save_bd'
                        ,'arvideosave_bd','video_edit_save_bd'
                        ,'selfie_appr_bd','movie_appr_bd','beauty_appr_bd','iphone_mode_appr_bd','stamp_cam_appr_bd'
                        ,'selfie_video_bd','video_edit_appr_bd')
)
select
    app_name
    ,format_date('%Y-%m',event_date_hk) event_month_hk
    ,event_name
    ,case   when event_name in ('selfiesave_bd','movecheck_save_bd','ad_beautifysvclk','beautifysave_bd')
                     or (event_name in ('iphone_mode_save_bd','stamp_cam_save_bd') and module='拍照') then 'photo save'
            when event_name in ('arvideosave_bd','video_edit_save_bd')
                     or (event_name in ('iphone_mode_save_bd','stamp_cam_save_bd') and module='视频') then 'video save'
            when event_name in ('selfie_appr_bd','movie_appr_bd','beauty_appr_bd')
                     or (event_name in ('iphone_mode_appr_bd','stamp_cam_appr_bd') and module='拍照') then 'photo enter'
            when event_name in ('selfie_video_bd','video_edit_appr_bd')
                     or (event_name in ('iphone_mode_appr_bd','stamp_cam_appr_bd') and module='视频') then 'video enter'
            end label
    ,count(1) pv
from
    event
where (case when event_name in ('beautifysave_bd') then `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.7.010')
          when event_name in ('ad_beautifysvclk') then (not `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.7.010'))
    else 1=1 end)
group by
    1,2,3,4


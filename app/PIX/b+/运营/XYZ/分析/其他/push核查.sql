
    select
        app_name
        ,event_date
        ,platform
        -- ,event_timestamp
        ,TIMESTAMP_TRUNC(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour),hour) hour
        ,count(distinct user_pseudo_id) uv
        ,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-25', '2024-06-27', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd') and geo.country='Japan'
      and func.getParams(event_params,'project').string_value='ai_filter'
      and func.getParams(event_params,'page_id').string_value='home_page_view'
    group by 1,2,3,4
    order by 1,2,3,4

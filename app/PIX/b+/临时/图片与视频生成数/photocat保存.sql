--------- photocat
with event as
(
    select
        -- app_name
        'PhotoCat' app_name
        ,date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) event_date_hk
        -- ,event_date_hk
        ,event_name
        ,event_params
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01', '2024-12-31', 'photocat', false)
    where
        (event_name = 'h5_page_event'
        and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value = 'home_page_view')
        or
        (event_name='h5_page_button_clk'
        and `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('save','save_all'))
)
select
    app_name
    ,format_date('%Y-%m',event_date_hk) event_month_hk
    ,event_name
    ,case   when event_name in ('h5_page_button_clk') then 'photo save'
            when event_name in ('h5_page_event') then 'photo enter'
            end label
    ,count(1) pv
from
    event
group by
    1,2,3,4
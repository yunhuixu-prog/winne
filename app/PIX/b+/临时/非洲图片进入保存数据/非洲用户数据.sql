with events as
(
 SELECT cast(datetime(timestamp_micros(event_timestamp), 'Asia/Singapore') as date)date1
 ,user_pseudo_id
 ,geo.country country
 ,project_id
 ,case when event_name in ('selfie_appr_bd','movie_appr_bd','beauty_appr_bd') then 'photo_enter'
       when event_name in ('movecheck_save_bd','selfiesave_bd','ad_beautifysvclk','beautifysave_bd','photo_edit_save_bd') then 'photo_save'
       when event_name in ('selfie_video_bd') then 'video_enter'
       when event_name in ('arvideosave_bd') then 'video_save'
 end event_name
 ,event_timestamp
 from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01', '2023-12-31', 'beautypluscam,pomelo', false)
 where event_name in ('photo_edit_save_bd',
                       'selfie_appr_bd','movie_appr_bd','beauty_appr_bd',
                       'movecheck_save_bd','selfiesave_bd','ad_beautifysvclk','beautifysave_bd','puzzle_save_bd',
                       'arvideosave_bd','selfie_video_bd')
),
photocat_events as
(
 SELECT cast(datetime(timestamp_micros(event_timestamp), 'Asia/Singapore') as date)date1
 ,user_pseudo_id
 ,geo.country country
 ,project_id
 ,case when event_name in ('h5_page_event') then 'photo_enter'
       when event_name in ('h5_page_button_clk') then 'photo_save'
 end event_name
 ,event_timestamp
 from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01', '2023-12-31', 'photocat', false)
 where  (event_name in ('h5_page_event') and func.getParams(event_params,'page_id').string_value='home_page_view')
        or (event_name in ('h5_page_button_clk') and func.getParams(event_params,'button_type').string_value in ('save','save_all'))
),
country as (
 select distinct fix_firebase_en_name country from `dataintegration-265403.dmi.dmi_ya_country_code`
where firebase_continent='Africa'
)

-- select e.date1,e.project_id,e.event_name,count(distinct e.event_timestamp) pv
-- from events e
-- join country c on e.country = c.country
-- group by 1,2,3
-- order by 1,2,3

-- select e.date1,e.project_id,e.event_name,count(distinct e.event_timestamp) pv
-- from photocat_events e
-- join country c on e.country = c.country
-- group by 1,2,3
-- order by 1,2,3



-- b+c dau
select
    event_date_hk
    ,app_name
    ,count(distinct user_pseudo_id) dau
from
    `dataintegration-265403.stat.stat_active_advice_detail_d` e
join country c on e.country = c.country
where
    event_date_hk between date'2023-01-01' and '2023-12-31'  -- 修改查询的数据时间
    and app_name='Beauty Plus Cam'
group by 1,2
order by 1,2
--
--
-- -- photocat茶树
-- SELECT func.getParams(event_params,'page_id').string_value,count(1)
-- from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-01-01', '2023-12-31', 'photocat', false)
-- where event_name in ('h5_page_button_clk') --and func.getParams(event_params,'button_type').string_value in ('save','save_all')
-- group by 1
--


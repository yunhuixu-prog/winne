select
      event_date
      ,count(distinct user_pseudo_id) uv
from
      `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-01', '2024-06-30', 'photocat', false)
where event_name='h5_page_button_clk' and func.getParams(event_params,'button_type').string_value in ('save','save_all')
group by 1
order by 1

-- 进入首页
select
      event_date
      ,count(distinct user_pseudo_id) uv
from
      `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-01', '2024-06-30', 'photocat', false)
where event_name='h5_page_event' and func.getParams(event_params,'page_id').string_value in ('home_page_view')
group by 1
order by 1

-- dau
select event_date_hk date,count(distinct user_pseudo_id) uv
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk between '2024-06-01' and '2024-06-30' and app_name='PhotoCat'
group by 1
order by 1
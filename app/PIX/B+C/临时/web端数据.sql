
select distinct func.getParams(event_params,'button_type').string_value
from      
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-08', '2024-03-19', 'beautypluscam', false)  
where platform='WEB' and event_name='web_page_button_clk'  --page_view
-- and func.getParams(event_params,'button_type').string_value='page_blog'
limit 10

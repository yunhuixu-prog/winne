-- drop table if exists `dataintegration-265403.temp.dwd_ds_h5_puriplus_generate_call`;
-- create table if not exists `dataintegration-265403.temp.dwd_ds_h5_puriplus_generate_call` as

delete from  `dataintegration-265403.temp.dwd_ds_h5_puriplus_generate_call`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dwd_ds_h5_puriplus_generate_call`


select event_date,count(distinct user_pseudo_id) uv,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus,airbrush', false)
where event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
  and func.getParams(event_params,'project').string_value='puriplus'
  and func.getParams(event_params,'button_type').string_value='generate'
group by 1

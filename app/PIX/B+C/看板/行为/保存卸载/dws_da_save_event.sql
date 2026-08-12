delete from  `beauty-cam-new.event_data.dws_da_save_event`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beauty-cam-new.event_data.dws_da_save_event`
select
    event_date
    ,platform
    ,app_version
    ,is_new
    ,is_UA
    ,user_type
    ,case when country='China' then 'China Mainland' else country end country
    ,if_high
    ,is_pay

    ,coalesce(count(case when event_name='selfiesave_bd' then user_pseudo_id end),0) selfiesave_uv
    ,coalesce(sum(case when event_name='selfiesave_bd' then pv end),0) selfiesave_pv
    ,coalesce(count(case when event_name in ('ad_beautifysvclk','beautifysave_bd') then user_pseudo_id end),0) beautifysave_uv
    ,coalesce(sum(case when event_name in ('ad_beautifysvclk','beautifysave_bd') then pv end),0) beautifysave_pv
    ,coalesce(count(case when event_name='beautifysave_second_bd' then user_pseudo_id end),0) beautifysave_second_uv
    ,coalesce(sum(case when event_name='beautifysave_second_bd' then pv end),0) beautifysave_second_pv
    ,coalesce(count(case when event_name='ai_editor_save_clk_bd' then user_pseudo_id end),0) ai_editor_save_clk_uv
    ,coalesce(sum(case when event_name='ai_editor_save_clk_bd' then pv end),0) ai_editor_save_clk_pv
from
    `beauty-cam-new.event_data.dwd_da_save_event`
where
    event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
and country!=""
and (case when event_name in ('beautifysave_bd') then `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.010')
          when event_name in ('ad_beautifysvclk') then (not `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.010'))
    else 1=1 end)
group by
    1,2,3,4,5,6,7,8,9
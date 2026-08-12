-- drop table if exists `beauty-cam-new.event_data.dws_da_uninstall_event`;
-- create table if not exists `beauty-cam-new.event_data.dws_da_uninstall_event` as
delete from  `beauty-cam-new.event_data.dws_da_uninstall_event`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beauty-cam-new.event_data.dws_da_uninstall_event`
select
    event_date
    ,platform
    ,app_version
    ,event_name
    ,is_new
    ,is_UA
    ,user_type
    ,case when country='China' then 'China Mainland' else country end country
    ,if_high
    ,is_pay
    ,count(user_pseudo_id) uv
    ,sum(pv) pv
from
    `beauty-cam-new.event_data.dwd_da_uninstall_event`
where
    event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by
    1,2,3,4,5,6,7,8,9,10
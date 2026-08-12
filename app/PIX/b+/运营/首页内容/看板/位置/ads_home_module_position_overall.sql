delete from
  beautyplus-bc0ed.temp.ads_home_module_position_overall
where
  Date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into
  beautyplus-bc0ed.temp.ads_home_module_position_overall

-- drop table if exists `beautyplus-bc0ed.temp.ads_home_module_position_overall`;
-- create table `beautyplus-bc0ed.temp.ads_home_module_position_overall` as



select
 'uv' as data_type,app_name,
 event_date as Date,Event_name ,cast(module_positon as int) as Module_position ,Module_type,Content_type,Platform,Version,
--  Region,
 case when Country in ('South Korea','Thailand','Japan','United States') then Country
      when Country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
      else 'WW'
 end as Region,
 Country,
 is_UA,is_New,
 case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.120') and Platform='ANDROID' then 'ANDROID >=7.7.120'
      when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.110') and Platform='IOS' then 'IOS >=7.7.110'
      when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.000') then '>=7.7.000'
 else '<7.7.000'
 end Version_status,
 case when is_pay='Paying' then is_pay
 else 'Non-paying' end as is_Pay,tab_name,
sum(uv)as Amount
from beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new
where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
union all
select
 'pv' as data_type,app_name,
 event_date as Date,Event_name ,cast(module_positon as int) as Module_position ,Module_type,Content_type,Platform,Version,
--  Region,
 case when Country in ('South Korea','Thailand','Japan','United States') then Country
      when Country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
      else 'WW'
 end as Region,
 Country,
 is_UA,is_New,
 case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.120') and Platform='ANDROID' then 'ANDROID >=7.7.120'
      when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.110') and Platform='IOS' then 'IOS >=7.7.110'
      when `dataintegration-265403.func`.compare_is_greater_or_equal_version(Version,'7.7.000') then '>=7.7.000'
 else '<7.7.000'
 end Version_status,
 case when is_pay='Paying' then is_pay
 else 'Non-paying' end as is_Pay,tab_name,
sum(pv)as Amount
from beautyplus-bc0ed.Duffle_dataset.ads_home_module_position_new
where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

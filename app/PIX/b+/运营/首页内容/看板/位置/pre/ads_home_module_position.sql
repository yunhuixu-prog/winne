delete from
  beautyplus-bc0ed.Duffle_dataset.ads_home_module_position
where
  event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into
  beautyplus-bc0ed.Duffle_dataset.ads_home_module_position
select
  event_date,
  event_name,
  module_positon,
  module_type,
  content_type,
  platform,
  is_pay,
  country,
  version,
  is_UA,
  is_new,
  region,
  count(distinct user_pseudo_id) as uv,
  count(*) as pv
from
  beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position
where
  cast(module_positon as int) < 10
  and cast(module_positon as int) > 0
  and event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
group by
  event_date,
  event_name,
  module_positon,
  module_type,
  content_type,
  platform,
  is_pay,
  country,
  version,
  is_UA,
  is_new,
  region
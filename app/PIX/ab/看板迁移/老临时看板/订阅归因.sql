set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;
INSERT OVERWRITE TABLE stat_beauty_plus.filing_adz_pix_airbrush_trial_sub_grads  PARTITION(date_p)

select
  category,
  first,
  second,
  third,
  fourth,
  nvl(duration, 'Total') as duration,
  nvl(platform, 'Total') as platform,
  nvl(is_ua, 'Total') as is_ua,
  nvl(is_new, 'Total') as is_new,
  nvl(country, 'Total') as country,
  sum(enter_uv) enter_uv,
  sum(click_uv) click_uv,
  sum(sub_success_uv) sub_success_uv,
  sum(trial_uv) trial_uv,
  sum(sub_to_paid_uv) sub_to_paid_uv,
  sum(trial_to_paid_uv) trial_to_paid_uv,
  sum(sub_to_paid_revenue) sub_to_paid_revenue,
  sum(sub_to_paid_revenue_cons) sub_to_paid_revenue_cons,
  sum(sub_to_paid_revenue_sub) sub_to_paid_revenue_sub,
  date_p
from
  (
    select
      date_p,
      nvl(category, 'null') category,
      nvl(first, 'null') first,
      nvl(second, 'null') second,
      nvl(third, 'null') third,
      nvl(name, 'unknown') name,
      nvl(fourth, 'null') fourth,
      nvl(sale_status, 'unknown') sale_status,
      nvl(duration, 'unknown') duration,
      nvl(app_version, 'unknown') app_version,
      nvl(platform, 'unknown') platform,
      nvl(is_new, 'unknown') is_new,
      nvl(is_ua, 'unknown') is_ua,
      nvl(country, 'unknown') country,
      enter_uv,
      click_uv,
      sub_success_uv,
      trial_uv,
      sub_to_paid_uv,
      trial_to_paid_uv,
      sub_to_paid_revenue,
      sub_to_paid_revenue_cons,
      sub_to_paid_revenue_sub
    from
      stat_beauty_plus.filing_adz_pix_view_airbrush_trial_sub_grads
    where
      date_p between ${start_time} and ${end_time}
  ) t
group by
  date_p,
  category,
  first,
  second,
  third,
  fourth,
  duration,
  platform,
  is_ua,
  is_new,
  country GROUPING SETS (
    (duration, platform, is_ua, is_new, country, date_p, category, first, second, third, fourth),

    (duration, platform, is_ua, is_new, date_p, category, first, second, third, fourth),
    (duration, platform, is_ua, country, date_p, category, first, second, third, fourth),
    (duration, platform, is_new, country, date_p, category, first, second, third, fourth),
    (duration, is_ua, is_new, country, date_p, category, first, second, third, fourth),
    (platform, is_ua, is_new, country, date_p, category, first, second, third, fourth),

    (duration, platform, is_ua, date_p, category, first, second, third, fourth),
    (duration, platform, is_new, date_p, category, first, second, third, fourth),
    (duration, is_ua, is_new, date_p, category, first, second, third, fourth),
    (platform, is_ua, is_new, date_p, category, first, second, third, fourth),
    (duration, platform, country, date_p, category, first, second, third, fourth),
    (duration, is_ua, country, date_p, category, first, second, third, fourth),
    (platform, is_ua, country, date_p, category, first, second, third, fourth),
    (duration, is_new, country, date_p, category, first, second, third, fourth),
    (platform, is_new, country, date_p, category, first, second, third, fourth),
    (is_ua, is_new, country, date_p, category, first, second, third, fourth),

    (duration, platform, date_p, category, first, second, third, fourth),
    (duration, is_ua, date_p, category, first, second, third, fourth),
    (duration, is_new, date_p, category, first, second, third, fourth),
    (duration, country, date_p, category, first, second, third, fourth),
    (platform, is_ua, date_p, category, first, second, third, fourth),
    (platform, is_new, date_p, category, first, second, third, fourth),
    (platform, country, date_p, category, first, second, third, fourth),
    (is_ua, is_new, date_p, category, first, second, third, fourth),
    (is_ua, country, date_p, category, first, second, third, fourth),
    (is_new, country, date_p, category, first, second, third, fourth),

    (duration, date_p, category, first, second, third, fourth),
    (platform, date_p, category, first, second, third, fourth),
    (is_ua, date_p, category, first, second, third, fourth),
    (is_new, date_p, category, first, second, third, fourth),
    (country, date_p, category, first, second, third, fourth),

    (date_p, category, first, second, third, fourth)
  )
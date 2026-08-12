select
  date_p,
  nvl(platform, 'total') as platform,
  nvl(is_ua, 'total') as is_ua,
  nvl(country, 'total') as country,
  sum(dau) as dau
from(
    select
      date_p,
      dau,
      CASE
        when platform is null then 'unknown'
        else platform
      end as platform,
      CASE
        when is_ua is null then 'unknown'
        else is_ua
      end as is_ua,
      CASE
        when country is null then 'unknown'
        else country
      end as country
    from
      stat_beauty_plus.filing_mdz_subscription_overview_daily
    where
      date_p = ${start_time}
      and app = 'AirBrush'
  ) t1
group by
  date_p,
  platform,
  is_ua,
  country with cube
having
  date_p is not null
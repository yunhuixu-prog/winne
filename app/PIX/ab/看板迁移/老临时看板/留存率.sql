set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;
INSERT OVERWRITE TABLE stat_beauty_plus.filing_adz_pix_airbrush_active_retention  PARTITION(date_p)

select platform,country,is_ua,au,nu,au_next_day_retention,nu_next_day_retention,date_p
from
(
    select
        nvl(platform, 'Total') as platform,
        nvl(country, 'Total') as country,
        nvl(is_ua, 'Total') as is_ua,

        sum(au) au,
        sum(nu) nu,
        sum(au_next_day_retention) au_next_day_retention,
        sum(nu_next_day_retention) nu_next_day_retention,
        date_p
    from
    (
        select
            nvl(platform,'unknown') platform,
            nvl(country,'unknown') country,
            nvl(is_ua,'unknown') is_ua,
            au,
            nu,
            au_next_day_retention,
            nu_next_day_retention,
            date_p
        from
            stat_beauty_plus.filing_adz_pix_view_active_retention
        where
            date_p between ${start_time} and ${end_time}
                and app = 'AirBrush' and report='daily'
    ) t
    group by
      date_p,
      platform,
      country,
      is_ua with cube
) a
where date_p is not null

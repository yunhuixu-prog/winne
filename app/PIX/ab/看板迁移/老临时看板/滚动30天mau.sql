set hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE stat_beauty_plus.bplus_adz_pix_airbrush_rolling_mau  PARTITION(date_p)

select
    date_type,dur,type,
    nvl(platform, 'Total') as platform,
    nvl(country, 'Total') as country,
    nvl(is_ua, 'Total') as is_ua,

    sum(mau) mau,
    sum(mnu) mnu,
    event_date_hk date_p
from
(
    select
        CAST(regexp_replace(event_date_hk, '-', '') AS BIGINT) event_date_hk,
        date_type,dur,type,
        nvl(platform,'unknown') platform,
        nvl(country,'unknown') country,
        nvl(is_ua,'unknown') is_ua,
        mau,
        mnu,
        date_p
    from
        stat_meitu.mpub_ada_retention_rolling_mau
    where
        date_p = ${now_time}
            and app = 'AirBrush'
            and CAST(regexp_replace(event_date_hk, '-', '') AS BIGINT) between ${start_time} and ${end_time}
) t
group by event_date_hk, date_type, dur, type, platform, country, is_ua GROUPING SETS (
    (event_date_hk, date_type, dur, type, platform, country, is_ua),

    (event_date_hk, date_type, dur, type, platform, country),
    (event_date_hk, date_type, dur, type, platform, is_ua),
    (event_date_hk, date_type, dur, type, country, is_ua),

    (event_date_hk, date_type, dur, type, platform),
    (event_date_hk, date_type, dur, type, country),
    (event_date_hk, date_type, dur, type, is_ua),

    (event_date_hk, date_type, dur, type)
)

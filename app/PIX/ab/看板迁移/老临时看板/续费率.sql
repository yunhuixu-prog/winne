set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;
INSERT OVERWRITE TABLE stat_beauty_plus.filing_adz_pix_airbrush_paid_retention  PARTITION(date_p)

select platform,country,is_ua,offer_method,subscription_period,prepare_renew_users,retention_users,date_p
from
(
    select
        nvl(platform, 'Total') as platform,
        nvl(country, 'Total') as country,
        nvl(is_ua, 'Total') as is_ua,
        nvl(offer_method, 'Total') as offer_method,
        if(subscription_period='ALL','Total',subscription_period) subscription_period,

        sum(prepare_renew_users) prepare_renew_users,
        sum(retention_users) retention_users,
        date_p
    from
    (
        select
            nvl(platform,'unknown') platform,
            nvl(country,'unknown') country,
            nvl(offer_method,'unknown') offer_method,
            nvl(subscription_period,'unknown') subscription_period,
            nvl(is_ua,'unknown') is_ua,
            prepare_renew_users,
            retention_users,
            date_p
        from
            stat_beauty_plus.filing_adz_pix_view_paid_retention
        where
            date_p between ${start_time} and ${end_time}
                and app_id = 'AirBrush' and report='daily'
    ) t
    group by
      date_p,
      platform,
      country,
      is_ua,
      offer_method,
      subscription_period with cube
) a
where date_p is not null and subscription_period is not null

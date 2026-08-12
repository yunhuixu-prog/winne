
select date_p,
    sum(prepare_renew_users) prepare_renew_users,
    sum(retention_users) retention_users
from
    stat_beauty_plus.filing_adz_pix_view_paid_retention
where
    date_p = 20250825
        and app_id = 'AirBrush' and report='daily'
        and subscription_period='ALL'
group by date_p
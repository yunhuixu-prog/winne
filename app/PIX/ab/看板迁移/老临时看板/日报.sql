select
    date_p `date`,
	nvl(platform, 'Total') as platform,
    nvl(is_ua, 'Total') as is_ua,
    nvl(country, 'Total') as country,
	sum(dau) dau,
	sum(dnu) dnu,
	sum(valid_trial_users) valid_trial_users,
	sum(valid_paid_users) valid_paid_users,
	sum(trial_users) trial_users,
	sum(trial_to_paid_users) trial_to_paid_users,
    sum(paid_users) paid_users,
	sum(vas) vas,
	sum(cm) cm,

	sum(new_paid_users) new_paid_users,
	sum(new_paid_revenue) new_paid_revenue,
	sum(renewal_users) renewal_users,
	sum(renewal_revenue) renewal_revenue,
	sum(new_return_users) new_return_users,
	sum(new_return_revenue) new_return_revenue,
	sum(promotional_paid_users) promotional_paid_users,
	sum(promotional_paid_revenue) promotional_paid_revenue,
    sum(vaild_standard_paid_users) vaild_standard_paid_users,
	sum(vaild_promotional_paid_users) vaild_promotional_paid_users,
	sum(promotional_to_standard_paid_users) promotional_to_standard_paid_users
from
(
select
	date_p,
	nvl(platform,'unknown') platform,
	nvl(is_ua,'unknown') is_ua,
	nvl(country,'unknown') country,
	dau,
	dnu,
	valid_trial_users,
	valid_paid_users,
	trial_users,
	trial_to_paid_users,
    paid_users,
	vas,
	cm,

	new_paid_users,
	new_paid_revenue,
	renewal_users,
	renewal_revenue,
	new_return_users,
	new_return_revenue,
	promotional_paid_users,
	promotional_paid_revenue,
    vaild_standard_paid_users,
	vaild_promotional_paid_users,
	promotional_to_standard_paid_users
from
	stat_beauty_plus.filing_mdz_subscription_overview_daily
where
	date_p between ${start_time} and ${end_time} and app='AirBrush'
) t
group by
  date_p,
  platform,
  is_ua,
  country with cube
having
  date_p is not null
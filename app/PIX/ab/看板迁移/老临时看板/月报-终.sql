select
    date_p `date`,
	nvl(platform, 'Total') as platform,
    nvl(is_ua, 'Total') as is_ua,
    if(country='All','Total',country) country,
	sum(mau) mau,
	sum(mnu) mnu,
	sum(vas) vas,
	sum(cm) cm,
	sum(trial_users) trial_users,
    sum(paid_users) paid_users,
	sum(trial_to_pay_users) trial_to_pay_users,
	sum(valid_trial_users) valid_trial_users,
	sum(active_valid_trial_users) active_valid_trial_users,
	sum(valid_paid_users) valid_paid_users,
	sum(active_valid_paid_users) active_valid_paid_users,

	sum(new_paid_users) new_paid_users,
	sum(new_paid_revenue) new_paid_revenue,
	sum(renew_paid_users) renew_paid_users,
	sum(renew_paid_revenue) renew_paid_revenue,
	sum(promotional_paid_users) promotional_paid_users,
	sum(promotional_paid_revenue) promotional_paid_revenue,
	sum(promotional_to_standard_paid_users) promotional_to_standard_paid_users,

	sum(uuid_mau) uuid_mau,
	sum(new_user_sub) new_user_sub,
	sum(sub_users) sub_users,
	sum(register_uv) register_uv,
	sum(login_uv) login_uv,
	sum(refund_users) refund_users,
	sum(refund_revenue) refund_revenue
from
(
select
	date_p,
	nvl(platform,'unknown') platform,
	nvl(is_ua,'unknown') is_ua,
	nvl(country,'unknown') country,
	mau,
	mnu,
	vas,
	cm,
	trial_users,
	paid_users,
	trial_to_pay_users,
	new_paid_users,
	new_paid_revenue,
	renew_paid_users,
	uuid_mau,
	renew_paid_revenue,
	active_valid_paid_users,
	valid_trial_users,
	valid_paid_users,
	new_user_sub,
	sub_users,
	promotional_paid_users,
	promotional_paid_revenue,
	promotional_to_standard_paid_users,
	active_valid_trial_users,
	register_uv,
	login_uv,
	refund_users,
	refund_revenue
from
	stat_beauty_plus.filing_amz_pix_view_subscription_overview_monthly
where
	date_p between ${start_time} and ${end_time} and app='AirBrush'
) t
group by
  date_p,
  platform,
  is_ua,
  country with cube
having
  date_p is not null and country is not null
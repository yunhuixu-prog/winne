SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;
insert overwrite table stat_ab.filing_anz_sub_source_event_show PARTITION(date_p)

select
	level,
	os_type,
	country,
	is_new,
	is_ua,
	app_version,
	duration,
	sku,
	first_source,
	second_source,
	third_source,
	fourth_source,
	sub_enter_uv,
	sub_click_uv,
	sub_suc_uv,
	sub_paid_uv,
	sub_paid_ord_amt,
	sub_paid_ord_before_amt,
	sub_trial_uv,
	sub_trial_paid_uv,
	sub_trial_paid_ord_amt,
	sub_trial_paid_ord_before_amt,
	sub_direct_paid_uv,
	sub_direct_paid_ord_amt,
	sub_direct_paid_ord_before_amt,
	date_p
from stat_ab.filing_mnz_sub_source_event_overall_level
where date_p between ${start_time} and ${end_time}
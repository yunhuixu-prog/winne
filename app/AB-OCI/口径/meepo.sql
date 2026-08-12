select
	server_id device_id,
	app_version dimension
from
	stat_sdk.sdk_odz_active
where
	date_p = 20251201
	and app_key_p in ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
	and os_p in ('android','ios')
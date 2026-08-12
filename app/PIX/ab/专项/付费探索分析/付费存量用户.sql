select count(distinct a.uuid) uv,count(distinct case when b.uuid is null then a.uuid end) no_active_uv
from (
    select distinct uuid
    from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
    where event_date_hk = date_sub(current_date(),interval 1 day)
        and app_id='AirBrush'
        and current_trial_day is null
        and current_promotional_paying_period_day is null
        and current_standard_paying_period_day is null
        and past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times-
    trial_times>=2
--         and number_of_days_since_secent_order_has_expired>30
) a
left join (
    select distinct uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date_sub(current_date(),interval 31 day) and date_sub(current_date(),interval 1 day)
        and app_name = 'AirBrush'
) b
on a.uuid=b.uuid

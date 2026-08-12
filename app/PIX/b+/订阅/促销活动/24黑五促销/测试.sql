with sub as
(
    select event_date date
    ,event_timestamp
    ,platform
    ,event_name
    ,user_pseudo_id
    ,country
    ,func.getParams(event_params,'cur_spm').string_value cur_spm
    ,func.getParams(event_params,'sub_user_type').string_value sub_user_type
    ,coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is_trial_open
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-29', '2024-12-03', 'BeautyPlus', false)
    where event_name in  ('subscription_try_suc')
        and (func.getParams(event_params,'cur_spm').string_value like '%1008%'
        or func.getParams(event_params,'cur_spm').string_value like '%1009%')
        and func.getParams(event_params,'sub_user_type').string_value in ('1','2')
        and platform='IOS'
        -- and platform='ANDROID'
        and country='United States'
        -- and coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is not null
    limit 1000
)
, final_output_pre as
(
    select
        a.*,
        b.uuid as new_uuid
    from sub a
    left join `dataintegration-265403.stat.dmi_dz_idmapping` b
    on a.user_pseudo_id = b.key
)

select
    f.*, sub_success_offer_type,sub_success_order_id as original_order_id,
    curr_order_id as order_id,
    sub_success_server_date as standard_order_date,
    sub_success_to_paid_date as purchase_date,
    sub_success_to_paid_order_id as purchase_order_id,
    sub_success_to_paid_revenue as payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
from final_output_pre f
left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s
on f.new_uuid = s.uuid   and f.date between date_sub(sub_success_server_date, interval 1 day) and date_add(sub_success_server_date, interval 1 day)   and s.app_name='BeautyPlus'  --and f.sku_id = s.sku
where  f.event_name in  ('subscription_try_suc')




;
select platform
,event_name
,`beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id
,func.getParams(event_params,'sub_user_type').string_value sub_user_type
,coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is_trial_open,count(1)
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-24', '2024-11-26', 'BeautyPlus', false)
where event_name in  ('subscription_clk_try','subscription_try_suc')
    and (func.getParams(event_params,'cur_spm').string_value like '%1008%'
    or func.getParams(event_params,'cur_spm').string_value like '%1009%')
    and func.getParams(event_params,'sub_user_type').string_value in ('1','2')
    -- and platform='IOS'
    and country='United States'
    -- and coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is not null
group by 1,2,3,4,5
order by 1,2,3,4,5


with event_pre as
(
    select event_date,user_pseudo_id
          ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
          ,coalesce(cast(`dataintegration-265403.func`.getParams(event_params,'credit_amount').string_value as int64),`dataintegration-265403.func`.getParams(event_params,'credit_amount').int_value) credit_amount
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-29', '2024-05-29', 'beautyplus', false)
    where event_name in ('free_credit_receive_suc_bd')
)

select event_date,count(distinct user_pseudo_id) uv,count(1) pv,sum(credit_amount) credit_amount
from event_pre
group by 1
order by 1

select event_date_hk,count(distinct user_pseudo_id) uv
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where app_name='BeautyPlus' and event_date_hk between '2024-03-29' and '2024-05-29'
group by 1
order by 1
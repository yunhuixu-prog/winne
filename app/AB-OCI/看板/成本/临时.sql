select distinct func_name,func_effect
from
    stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
where
    date_p = 20260410
    and app_name_cn='AirBrush'
    and func_name='relight'

;

select
    sum(ord_amt/size(split(get_json_object(big_data,'$.source_1'), ','))) ord_amt,
    -- get_json_object(big_data,'$.source_1'),
    sum(ord_amt) ord_amt
from stat_vip.paid_oda_all_order_summary
WHERE is_subscribe='订阅'
    and pay_date BETWEEN 20260421 AND 20260421
    and app_id_p IN (7329803307041000000)
    and cur_pay_withhold_stage>=1
    and get_json_object(big_data,'$.source_module')='p_edit'
    and get_json_object(big_data,'$.source_0')='f_ai_repair'
    -- and get_json_object(big_data,'$.source_1') = 'f_background_protect'
    -- and get_json_object(big_data,'$.source_1') like '%f_background_protect%'
-- group by get_json_object(big_data,'$.source_1')

;

select distinct func_name,func_effect,first_source,second_source,third_source
from stat_ab.filing_odz_cost_event_detail
where date_p = 20260410
    -- and func_name='ai_replace'
    and first_source='未知'

;

SELECT *
FROM stat_ab.filing_adz_cost_and_sub_overall
WHERE date_p = 20260410 
    and country_name='整体' 
    and os_type='整体'
    and func_effect='整体'
    -- and func_name='Relight'
limit 100

;

SELECT *
FROM stat_ab.filing_adz_cost_event_overall
WHERE date_p = 20260410 
    and country_name='整体' 
    and os_type='整体'
    and func_effect='整体'
limit 100

;

SELECT *
FROM stat_ab.filing_adz_cost_event_distributed_daily
WHERE date_p = 20260410 
    and country_name='整体' 
    and os_type='整体'
    and func_name='Relight'
limit 100

;
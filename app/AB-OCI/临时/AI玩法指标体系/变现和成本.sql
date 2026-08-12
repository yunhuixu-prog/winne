-- 成本
select
    date_p
    ,case when func_name in ('ai_filter','ai_image') then 'ai_filter'
    else func_name
    end func_name
    ,case when func_effect is null or func_effect=''then '未知' else func_effect end func_effect
    ,sum(cost) cost -- IT成本（人民币）
    ,sum(case when cost_type='外采' then cost else 0 end) cost_outsource -- 外采成本（人民币）
    ,sum(case when cost_type='自研' then cost else 0 end) cost_self_research -- 自研成本（人民币）
from
  stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
where
  date_p between ${start_time} AND ${end_time}
  and app_name_cn='AirBrush'
  and func_name in ('ai_filter','ai_image')
group by date_p
    ,case when func_name in ('ai_filter','ai_image') then 'ai_filter'
    else func_name
    end
    ,case when func_effect is null or func_effect=''then '未知' else func_effect end

;

-- 变现
select
    pay_date,
    source_0,source_1,
    sum(ord_amt) ord_amt, -- 订阅毛利（剔除退款，人民币）
    sum(case when type='no_refund' then ord_amt else 0 end) ord_amt_no_refund, -- 订阅毛利（不剔除退款，人民币）
    sum(case when cur_pay_withhold_stage=1 then ord_amt else 0 end) ord_amt_new, -- 新增订阅毛利（剔除退款，人民币）
    sum(case when cur_pay_withhold_stage>1 then ord_amt else 0 end) ord_amt_renewal -- 续费订阅毛利（剔除退款，人民币）
from (
    select
        'no_refund' type,
        pay_date,
        get_json_object(big_data,'$.source_module') as source_module,
        get_json_object(big_data,'$.source_0') as source_0,

        case when get_json_object(big_data,'$.source_0') in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                then get_json_object(big_data,'$.mids_material_id')
            else get_json_object(big_data,'$.source_1')
        end as source_1,
        ord_amt,ord_amt_usd,
        gid,
        device_type as os_type,country_name,cur_pay_withhold_stage
    from stat_vip.paid_oda_all_order_summary
    WHERE is_subscribe='订阅'
        and pay_date BETWEEN ${start_time} AND ${end_time}
        and app_id_p IN (7329803307041000000)
        and cur_pay_withhold_stage>=1

    union all 

    select
        'refund' type,
        refund_date pay_date,
        get_json_object(big_data,'$.source_module') as source_module,
        get_json_object(big_data,'$.source_0') as source_0,

        case when get_json_object(big_data,'$.source_0') in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                then get_json_object(big_data,'$.mids_material_id')
            else get_json_object(big_data,'$.source_1')
        end as source_1,
        -refund_amt ord_amt,-refund_amt_usd ord_amt_usd,
        gid,
        device_type as os_type,country_name,cur_pay_withhold_stage
    from stat_vip.paid_oda_all_order_summary
    WHERE is_subscribe='订阅'
        and refund_date BETWEEN ${start_time} AND ${end_time}
        and app_id_p IN (7329803307041000000)
        and pay_status=6
) t
where source_0='ai_filter'
group by pay_date,
    source_0,source_1
-- 订阅页曝光到付费转化率
SELECT
    date_p
    ,params['source_0'] source_0
    ,case when params['source_0'] in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                then params['mids_material_id']
            else params['source_1'] end source_1
    ,COUNT(DISTINCT case when event_id='w_subscription_enter' then gid else null end) AS sub_enter_uv -- 订阅页曝光数
    ,COUNT(DISTINCT case when event_id='w_subscription_success' then gid else null end) AS sub_suc_uv -- 订阅数(包含试用)
    ,ROUND(COUNT(DISTINCT case when event_id='w_subscription_success' then gid else null end)/ COUNT(DISTINCT case when event_id='w_subscription_enter' then gid else null end),6) AS sub_suc_rate -- 订阅弹窗曝光到订阅转化率
FROM stat_sdk.sdk_odz_source_data
WHERE date_p BETWEEN ${start_time} AND ${end_time}
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND event_id in ('w_subscription_enter','w_subscription_success')
    AND gid IS NOT NULL
    AND params['source_0']='ai_filter'
GROUP BY date_p
    ,params['source_0']
    ,case when params['source_0'] in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                then params['mids_material_id']
            else params['source_1'] end

;
select
    date_p,s_0 source_0,s_1 source_1
    ,COUNT(distinct case when event_id='sub_enter' then gid end) sub_enter_uv -- 订阅页曝光数
    ,COUNT(distinct case when event_id='sub_suc' then gid end) sub_suc_uv -- 订阅数
    ,COUNT(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_paid_uv -- 订阅付费数
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between ${start_time} and ${end_time}
    and s_0='ai_filter'
group by date_p,s_0,s_1


-- 月SKU首次续费率
select  pay_date
        ,t1.period_type period_type
        ,t1.source_0 source_0,t1.source_1 source_1
        ,count(distinct t1.contract_id) num_0 -- 首次订阅数
        ,count(distinct t3.contract_id) num_1 -- 首次续费数
        ,round(count(distinct t3.contract_id)/count(distinct t1.contract_id),4) renewal_rate -- 首次续费率
from
(select   contract_id
            ,device_type as os_type
            ,country_name
            ,period_type
            ,ord_amt
            ,pay_date
            ,gid
            ,cur_pay_withhold_stage
            ,get_json_object(big_data,'$.source_module') as source_module
            ,get_json_object(big_data,'$.source_0') as source_0

            ,case when get_json_object(big_data,'$.source_0') in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                then get_json_object(big_data,'$.mids_material_id')
            else get_json_object(big_data,'$.source_1')
            end as source_1
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=${now_time}
        and pay_date BETWEEN ${start_time} AND ${end_time}
        and app_id_p IN (7329803307041000000)
        and cur_pay_withhold_stage=1
        and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
        and contract_id<>0   -- 续期型订单的contract_id不等于0
)t1
left join
(
    select    contract_id
            ,period_type
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=${now_time}
            and app_id_p IN (7329803307041000000)
            and cur_pay_withhold_stage=2
            and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
            and contract_id<>0   -- 续期型订单的contract_id不等于0
)t3
on t1.contract_id=t3.contract_id and t1.period_type=t3.period_type
where t1.source_0='ai_filter' and t1.period_type='月'
group by pay_date,t1.source_0,t1.source_1,t1.period_type


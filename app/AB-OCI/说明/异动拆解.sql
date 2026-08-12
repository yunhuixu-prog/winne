-- 新增订阅异动拆解
-- 1.拆解到试用和非试用，用来定位产生问题的日期
select 
    period_type -- 订单周期类型
    ,pay_date -- 支付日期
    ,count(distinct gid) new_pay_uv
    ,count(distinct case when cur_pay_stage=1 then gid end) new_pay_uv_no_trial
    ,count(distinct case when cur_pay_stage=2 then gid end) new_pay_uv_trial
    ,sum(ord_amt_usd) new_pay_gmv_usd
    ,sum(case when cur_pay_stage=1 then ord_amt_usd end) new_pay_gmv_usd_no_trial
    ,sum(case when cur_pay_stage=2 then ord_amt_usd end) new_pay_gmv_usd_trial
from stat_vip.paid_oda_all_order_summary
where app_id_p IN (7329803307041000000) -- 应用，此为必须字段
    and pay_date between 20260713 and 20260809 -- 支付日期
    and product_sub_line = 'AirBrush' -- 产品子线，此为必须字段
    and is_subscribe='订阅' -- 是否订阅，此为必须字段
    and country_name='巴西'
    and cur_pay_withhold_stage=1
group by period_type,pay_date
;
-- 2.拆解到来源
select 
    -- period_type -- 订单周期类型
    pay_date -- 支付日期
    ,get_json_object(big_data,'$.source_module') source_module
    ,get_json_object(big_data,'$.source_0') source_0
    ,get_json_object(big_data,'$.source_1') source_1
    ,count(distinct gid) new_pay_uv
    ,sum(ord_amt_usd) new_pay_gmv_usd
from stat_vip.paid_oda_all_order_summary
where app_id_p IN (7329803307041000000) -- 应用，此为必须字段
    and pay_date between 20260713 and 20260809 -- 支付日期
    and product_sub_line = 'AirBrush' -- 产品子线，此为必须字段
    and is_subscribe='订阅' -- 是否订阅，此为必须字段
    and country_name='巴西'
    and cur_pay_withhold_stage=1
    and cur_pay_stage=1
group by pay_date
    ,get_json_object(big_data,'$.source_module')
    ,get_json_object(big_data,'$.source_0')
    ,get_json_object(big_data,'$.source_1')

;
-- 续订异动拆解
select
    period_type -- 订单周期类型
    ,invalid_date -- 到期日期
    ,case when invalid_date between 20260713 and 20260719 then 'w0713'
        when invalid_date between 20260720 and 20260726 then 'w0720'
        when invalid_date between 20260727 and 20260802 then 'w0727'
        when invalid_date between 20260803 and 20260809 then 'w0803'
    end invalid_date_type
    ,case when cur_pay_withhold_stage<=5 then cur_pay_withhold_stage else 999 end cur_pay_withhold_stage
    ,count(distinct contract_id) expire_ord_cnt -- 到期订单数
    ,count(distinct renew_contract_id) renew_ord_cnt -- 续订订单数
    ,sum(renew_ord_amt_usd) renew_gmv_usd -- 续订收入（美元毛利）
from (
    select
        t1.period_type
        ,t1.cur_pay_withhold_stage
        ,t1.invalid_date
        ,t1.contract_id
        ,t3.contract_id as renew_contract_id
        ,t3.ord_amt_usd as renew_ord_amt_usd
    from (
        select
            contract_id
            ,period_type
            ,cur_pay_withhold_stage
            ,cast(substr(invalid_time,1,8) as bigint) as invalid_date
        from stat_vip.paid_oda_vip_all_order
        where date_p=20260809 -- 用最新分区
            and app_id_p in (7329803307041000000)
            and commodity_id_P not in (-1)
            and order_type='2' -- 续期订阅
            and contract_id<>0
            and cur_pay_withhold_stage>=1 -- 付费单（不含试用）
            and cast(substr(invalid_time,1,8) as bigint) between 20260713 and 20260809 -- 到期日期
            and country_name='巴西'
            and period_type='月'
    ) t1
    left join (
        select
            contract_id
            ,period_type
            ,cur_pay_withhold_stage
            ,ord_amt_usd
        from stat_vip.paid_oda_vip_all_order
        where date_p=20260809 -- 用最新分区
            and app_id_p in (7329803307041000000)
            and commodity_id_P not in (-1)
            and order_type='2' -- 续期订阅
            and contract_id<>0
            and cur_pay_withhold_stage>1 -- 续订单
            and pay_date >= 20260713
            and country_name='巴西'
    ) t3
    on t1.contract_id=t3.contract_id
        and t1.period_type=t3.period_type
        and t1.cur_pay_withhold_stage=t3.cur_pay_withhold_stage-1
) t
group by period_type,invalid_date
,case when cur_pay_withhold_stage<=5 then cur_pay_withhold_stage else 999 end


;

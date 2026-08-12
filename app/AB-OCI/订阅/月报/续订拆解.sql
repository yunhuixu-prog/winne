select  
        substr(invalid_date,1,6) as invalid_date
        ,os_type
        ,case when country_code in ('美国','巴西','英国') then country_code else '其他' end as country_code
        ,period_type
        ,cur_pay_withhold_stage
        ,count(distinct contract_id) num_0
        ,count(distinct contract_id2) num_1
        ,sum(t2.ord_amt_usd) gmv_usd
        -- ,count(distinct contract_id2)/count(distinct contract_id) ratio
from
    (
        select   os_type
                ,country_code
                ,period_type
                ,invalid_date
                ,cur_pay_withhold_stage
                ,t1.contract_id
                ,t2.contract_id as contract_id2
                ,t2.ord_amt_usd
        from
        (   
            -- 上月到期订单量
            SELECT  contract_id
                   ,case when cur_pay_withhold_stage<=5 then cur_pay_withhold_stage else 999 end cur_pay_withhold_stage
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end as os_type
                   ,nvl(country_name,'未知') as country_code
                   ,period_type
                   ,substr(invalid_time,1,8) as invalid_date
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}               -- 历史分区可能有问题，用最新分区
                --   and pay_date<=20260331   -- 月应续费看板上限制了前一个月之前的订单，非当月的
                  and substr(pay_date,1,6)<substr(invalid_time,1,6)
                  and substr(invalid_time,1,8) between 20250101 and 20260331
                  and cur_pay_withhold_stage>=1
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and app_id_p IN (7329803307041000000)
                  and commodity_id_P not in (-1)
            group by contract_id
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end
                   ,nvl(country_name,'未知')
                   ,period_type
                   ,case when cur_pay_withhold_stage<=5 then cur_pay_withhold_stage else 999 end
                   ,substr(invalid_time,1,8)
        )t1
    left join
        (
            SELECT  contract_id,pay_date,ord_amt_usd
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}            -- 历史分区可能有问题，用最新分区
                  and pay_date between 20250101 and 20260331
                  and cur_pay_withhold_stage>1
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and app_id_p IN (7329803307041000000)
                  and commodity_id_P not in (-1)
            group by contract_id,pay_date,ord_amt_usd
        )t2
    on t1.contract_id=t2.contract_id and substr(t1.invalid_date,1,6)=substr(t2.pay_date,1,6) -- 到期月有付费，可以调整
    -- group by os_type,country_code,period_type,invalid_date,t1.contract_id,t2.contract_id,cur_pay_withhold_stage,t2.ord_amt_usd
    )t
group by substr(invalid_date,1,6),os_type
    ,case when country_code in ('美国','巴西','英国') then country_code else '其他' end,period_type
    ,cur_pay_withhold_stage
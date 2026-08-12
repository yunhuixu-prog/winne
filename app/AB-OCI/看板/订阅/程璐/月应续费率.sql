
insert overwrite table stat_vip.vip_amz_middle_renewsoci PARTITION(date_p=${start_time})
select  nvl(os_type,'整体') os_type
        ,nvl(country_code,'整体') country_code
        ,nvl(geographic_subdivision_v2,'整体') geographic_subdivision_v2
        ,nvl(pay_channel,'整体') pay_channel
        ,nvl(app_type,'整体') app_type
        ,nvl(period_type,'整体') period_type
        ,count(distinct contract_id) num_0
        ,count(distinct contract_id2) num_1
from
    (
        select   os_type
                ,country_code
                ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
                ,t1.app_type as app_type
                ,period_type
                ,pay_channel
                ,t1.contract_id as contract_id
                ,t2.contract_id as contract_id2
        from
        (   -- 上月到期订单量
            SELECT  contract_id
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end as os_type
                   ,product_sub_line as  app_type
                   ,nvl(country_name,'未知') as country_code
                   ,period_type
                   ,pay_channel
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}               -- 历史分区可能有问题，用最新分区
                  and pay_date<=${last_end}
                  and substr(invalid_time,1,8)>=${start_time}  -- current("yyyyMM01")-1
                  and substr(invalid_time,1,8)<=${end_time}      -- current("yyyyMMdd")-1
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and cur_pay_withhold_stage>=1
                  and app_id_p not in (-1)
                  and commodity_id_P not in (-1)
            group by contract_id
                   ,case when os_type='android' and pay_channel='google' then 'google'
                                  when os_type in ('android','androidpad') then 'android'
                                  when os_type in ('ios','ipad') then 'ios'
                                  else os_type end
                   ,product_sub_line
                   ,nvl(country_name,'未知')
                   ,period_type
                   ,pay_channel
        )t1
    left join
        (
            SELECT  contract_id
                   ,product_sub_line as app_type
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p=${now_time}            -- 历史分区可能有问题，用最新分区
                  and pay_date>=${start_time}  -- current("yyyyMM01")-1
                  and pay_date<=${end_time}      -- current("yyyyMMdd")-1
                  and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                  and contract_id<>0   -- 续期型订单的contract_id不等于0
                  and cur_pay_withhold_stage>1
                  and app_id_p not in (-1)
                  and commodity_id_P not in (-1)
            group by contract_id,product_sub_line
        )t2
    on t1.contract_id=t2.contract_id and lower(t1.app_type)=lower(t2.app_type)
    left join
            (select sdk_country_name
                    ,geographic_subdivision_v2
                from stat_sdk.dim_rna_ip_location
                where date_p=${now_time}
                group by sdk_country_name,geographic_subdivision_v2
            )t22
    on t1.country_code=t22.sdk_country_name
    group by os_type,country_code,nvl(geographic_subdivision_v2,'东亚'),t1.app_type,period_type,t1.contract_id,t2.contract_id,pay_channel
    )t
group by os_type,country_code,geographic_subdivision_v2,app_type,period_type,pay_channel with cube

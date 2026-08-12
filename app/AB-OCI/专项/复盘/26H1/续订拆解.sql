-- 续费

select date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end date_h
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code 
        else '其他' 
        end country_code
        ,period_type
        ,sum(num_0) num_0
        ,sum(num_1) num_1
from stat_vip.vip_amz_middle_renewsoci
where date_p between 20250101 and 20250630
    and os_type='整体' 
    -- and country_code!='整体'
    and geographic_subdivision_v2='整体'
    and pay_channel='整体'
    and app_type='AirBrush'
    -- and period_type='整体'
group by date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code else '其他' 
        end
        ,period_type

union all 

select date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end date_h
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code 
        else '其他' 
        end country_code
        ,period_type
        ,sum(num_0) num_0
        ,sum(num_1) num_1
from stat_vip.vip_amz_middle_renewsoci
where date_p between 20250701 and 20251231
    and os_type='整体' 
    -- and country_code!='整体'
    and geographic_subdivision_v2='整体'
    and pay_channel='整体'
    and app_type='AirBrush'
    -- and period_type='整体'
group by date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code else '其他' 
        end
        ,period_type

union all 

select date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end date_h
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code 
        else '其他' 
        end country_code
        ,period_type
        ,sum(num_0) num_0
        ,sum(num_1) num_1
from stat_vip.vip_amz_middle_renewsoci
where date_p between 20260101 and 20260630
    and os_type='整体' 
    -- and country_code!='整体'
    and geographic_subdivision_v2='整体'
    and pay_channel='整体'
    and app_type='AirBrush'
    -- and period_type='整体'
group by date_p
        ,case when date_p between 20250101 and 20250630 then '2025H1'
            when date_p between 20250701 and 20251231 then '2025H2'
            when date_p between 20260101 and 20260630 then '2026H1'
        end
        ,case when country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code else '其他' 
        end
        ,period_type

;
-- 进一步拆解

select 
    substr(invalid_date,1,6) months
    ,case when invalid_date between 20250101 and 20250630 then '2025H1'
          when invalid_date between 20250701 and 20251231 then '2025H2'
          when invalid_date between 20260101 and 20260630 then '2026H1'
    end pay_h
    ,country_name
    ,period_type
    ,cur_pay_withhold_stage
    ,sum(num) num
    ,sum(direct_renew_num) direct_renew_num
    ,sum(after_renew_num) after_renew_num
    ,sum(renew_num_30) renew_num_30
    ,sum(dismiss_no_renew_num) dismiss_no_renew_num
    ,sum(gid_num) gid_num
    ,sum(renew_gid_num_30) renew_gid_num_30
    ,sum(renew_year_gid_num_30) renew_year_gid_num_30
    ,sum(renew_month_gid_num_30) renew_month_gid_num_30
    ,sum(renew_week_gid_num_30) renew_week_gid_num_30
from (
select  t1.invalid_date invalid_date
        -- ,t1.os_type os_type
        ,t1.country_name country_name
        ,t1.period_type period_type
        ,case when t1.cur_pay_withhold_stage<=5 then t1.cur_pay_withhold_stage else 999 end cur_pay_withhold_stage
        ,count(distinct t1.contract_id) num
        ,count(distinct case when t3.contract_id is not null and t3.pay_date<=t1.invalid_date then t1.contract_id else null end) direct_renew_num -- 当天续费
        ,count(distinct case when t3.contract_id is not null and t3.pay_date>t1.invalid_date then t1.contract_id else null end) after_renew_num -- 之后续费
        ,count(distinct case when t3.contract_id is not null and meitu_datediff(t3.pay_date,t1.invalid_date) <= 30 then t1.contract_id else null end) renew_num_30 -- 有效日期后续费
        ,count(distinct t1.gid) gid_num -- 总用户数
        ,count(distinct t4.gid) renew_gid_num_30 -- 有效日期后续费30天内
        ,count(distinct case when t4.period_type='年' then t4.gid end) renew_year_gid_num_30 -- 有效日期后续费30天内年续费
        ,count(distinct case when t4.period_type='月' then t4.gid end) renew_month_gid_num_30 -- 有效日期后续费30天内月续费
        ,count(distinct case when t4.period_type='周' then t4.gid end) renew_week_gid_num_30 -- 有效日期后续费30天内周续费
        ,count(distinct case when t2.dismiss_date is not null and t3.contract_id is null then t1.contract_id else null end) dismiss_no_renew_num -- 解约未续费
        -- ,count(distinct case when t2.dismiss_date is null and t3.contract_id is null then t1.contract_id else null end) no_dismiss_no_renew_num -- 未解约未续费
from
        (select   contract_id
                    ,device_type as os_type
                    ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
                    else '其他' end as country_name
         			,period_type
                    ,ord_amt
                    ,pay_date
                    ,gid
                    ,cur_pay_stage  as cur_withhold_stage
                    ,cur_pay_withhold_stage
                    ,substr(invalid_time,1,8) as invalid_date
                    ,pay_status
                    ,pay_channel
            from stat_vip.paid_oda_vip_all_order
            WHERE date_p=20260630
                    and cur_pay_withhold_stage>=1     -- 当前订单代扣期数(不包含试用单)
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
                    -- and pay_date between 20260101 and 20260430   -- 历史自 2021；上界与 date_p 一致
                    and substr(invalid_time,1,8) between 20250101 and 20260630  -- current("yyyyMM01")-1
        )t1
LEFT JOIN (
        -- 解约信息(之前应该是缺失的，不要看历史了)
        SELECT  contract_id
                ,CAST(dismiss_date AS BIGINT)  as dismiss_date
        FROM stat_vip.paid_oda_vip_tb_contract
        WHERE date_p =20260630
                and app_id_p not in(-1)
                AND dismiss_date>=20240101
                AND contract_status = 3
                and commodity_id_P not in (-1)
        group by contract_id,dismiss_date
        ) t2
    ON t1.contract_id = t2.contract_id
    AND t2.dismiss_date >= t1.pay_date
    -- AND t2.dismiss_date <= t1.invalid_date
left join
        (
            select    contract_id
                    ,cur_pay_withhold_stage
                    ,period_type
                    ,pay_date
            from stat_vip.paid_oda_vip_all_order
            WHERE date_p=20260630
                    and cur_pay_withhold_stage>1
                    and pay_date >= 20250101
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
        )t3
on t1.contract_id=t3.contract_id and t1.period_type=t3.period_type and t1.cur_pay_withhold_stage=t3.cur_pay_withhold_stage-1
left join
        (
            select    contract_id
                    ,cur_pay_withhold_stage
                    ,period_type
                    ,pay_date
                    ,gid
            from stat_vip.paid_oda_vip_all_order
            WHERE date_p=20260630
                    and cur_pay_withhold_stage>=1
                    and pay_date >= 20250101
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
        )t4
on t1.gid = t4.gid 
   and meitu_datediff(t4.pay_date,t1.invalid_date) >= 0
   and meitu_datediff(t4.pay_date,t1.invalid_date) <= 30
group by t1.invalid_date,t1.country_name,t1.period_type
    ,case when t1.cur_pay_withhold_stage<=5 then t1.cur_pay_withhold_stage else 999 end
) t
group by 
    substr(invalid_date,1,6)
    ,case when invalid_date between 20250101 and 20250630 then '2025H1'
          when invalid_date between 20250701 and 20251231 then '2025H2'
          when invalid_date between 20260101 and 20260630 then '2026H1'
    end
    ,country_name
    ,period_type
    ,cur_pay_withhold_stage



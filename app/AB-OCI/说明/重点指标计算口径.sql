-- 订阅核心指标
select
    sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_usd     -- 每日毛利（不剔除退款，美元）
    ,sum(ord_amt_usd) as gmv_usd_no_refund     -- 核心指标：每日毛利（剔除退款，美元）
    ,sum(ord_before_amt_usd) as gmv_before_usd_no_refund      -- 核心指标：每日分成前收入（剔除退款，美元）
    ,count(distinct case when type='no_refund' and cur_pay_stage=1 then gid else null end) as new_member           -- 新增会员（含免费试用)
    ,count(distinct case when type='no_refund' and cur_pay_stage=1 and cur_pay_withhold_stage=0 and order_type=2 then gid else null end) as trial_member           -- 新增试用会员
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then gid else null end) as new_pay_member   -- 新增付费会员
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then gid else null end) as renew_member   -- 续费会员数
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=1 then gid else null end) as pay_member   -- 付费会员数（包括新增和续费）
    ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_amt_usd else null end) new_pay_gmv_usd -- 新增付费毛利（不剔除退款，美元）
    ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_before_amt_usd else null end) new_pay_gmv_before_usd -- 新增付费分成前收入（不剔除退款，美元）
    ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_amt_usd else null end) renew_gmv_usd -- 续费毛利（不剔除退款，美元）
    ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_before_amt_usd else null end) renew_gmv_before_usd -- 续费分成前收入（不剔除退款，美元）
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then notify_pay_id else null end) as new_pay_notifyid   -- 新增付费订单
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then notify_pay_id else null end) as renew_notifyid   -- 续费订单
from
(
    select 'no_refund' type
        ,notify_pay_id
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,period_type
        ,pay_date
        ,ord_amt,ord_before_amt
        ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
        ,gid
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,order_type
        ,invalid_date
        ,pay_status
        ,case when pay_channel is null or pay_channel = '' then '未知'
                else pay_channel end as pay_channel
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date between ${start_time} and ${end_time}
--                 and create_date <= pay_date  -- 和中台表每天收入统一口径，尽量保证每天数值不变，但不同订单分区仍会有较小差距
        and product_sub_line = 'AirBrush'
        and is_subscribe='订阅'

    union all

    select 'refund' type
        ,notify_pay_id
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,period_type
        ,refund_date pay_date
        ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
        ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
        ,gid
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,order_type
        ,invalid_date
        ,pay_status
        ,case when pay_channel is null or pay_channel = '' then '未知'
                else pay_channel end as pay_channel
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and refund_date between ${start_time} and ${end_time}
--                 and create_date <= refund_date  -- 和中台表每天收入统一口径，保证每天数值不变，但不同订单分区仍会有较小差距
        and product_sub_line = 'AirBrush'
        and is_subscribe='订阅'
        and pay_status=6
) t1
left join
-- 国家id关联国家名称
(
    select sdk_country_name
            ,geographic_subdivision_v2
    from stat_sdk.dim_rna_ip_location
    where date_p=${now_time}
    group by sdk_country_name,geographic_subdivision_v2
) t22
on t1.country_code=t22.sdk_country_name

;

-- DAU
SELECT
    a.date_p -- 日期
    ,count(distinct a.final_id) as dau
    ,count(distinct case when new_device.final_id IS NOT NULL then a.final_id else null end) as dnu
FROM
(
    SELECT date_p, os_p, country_id, final_id
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
) a
LEFT JOIN
-- 国家id关联国家名称
(
    SELECT DISTINCT id, name
    FROM stat_sdk.dim_rna_ip_location
    WHERE level='1' and date_p is not null
) c
ON a.country_id = c.id
LEFT JOIN
-- 关联新用户
(
    SELECT final_id, date_p
    FROM stat_sdk.sdk_odz_new_device_info
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
)new_device
ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
group by a.date_p

;

-- DAU的订阅状态（当前是否订阅，历史是否订阅）
SELECT
    a.gid
    ,a.date_p
    -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
    ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed -- 当前是否订阅
    -- 历史订阅
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt -- 历史试用订阅次数
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt -- 历史付费订阅次数
FROM (
        SELECT date_p, os_p, country_id, final_id gid
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
) a
LEFT JOIN (
    select
        gid
        ,pay_date
        ,invalid_date
        ,period_type
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,ord_amt_usd
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= ${end_date}
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
) o
ON a.gid = o.gid
GROUP BY
    a.gid,
    a.date_p

;

-- 新增订阅来源统计
select
    date_p
    ,third_source -- 三级来源归因
    ,count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv -- 订阅页进入人数
    ,count(distinct case when event_id='sub_suc' then gid end) sub_suc_uv -- 订阅成功人数
    ,count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_suc_to_paid_uv -- 付费订阅成功人数
    ,sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_suc_to_paid_gmv -- 分摊后订阅毛利（美元）
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between ${start_date} and ${end_date}
group by date_p,third_source

;

-- 功能使用统计
SELECT date_p,sub_func_level2_name
    ,count(distinct case when event_type='进入' then gid end) enter_uv -- 进入人数
    ,count(distinct case when event_type='打勾' then gid end) use_uv -- 打勾人数
    ,count(distinct case when event_type='保存' then gid end) save_uv -- 保存人数
    ,SUM(case when event_type='进入' then cnt end) enter_pv -- 进入次数
    ,SUM(case when event_type='打勾' then cnt end) use_pv -- 打勾次数
    ,SUM(case when event_type='保存' then cnt end) save_pv -- 保存次数
FROM stat_sdk.airbrush_mdz_tool_behavior_detail
WHERE date_p between ${start_date} and ${end_date}
    AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
    AND tool_level in ('2')
GROUP BY date_p,sub_func_level2_name

;

-- 续费
select country_name
    ,sum(num) num
    ,sum(direct_renew_num) direct_renew_num
    ,sum(after_renew_num) after_renew_num
    ,sum(dismiss_no_renew_num) dismiss_no_renew_num
    ,sum(no_dismiss_no_renew_num) no_dismiss_no_renew_num
from (
select  t1.pay_date pay_date
        -- ,t1.os_type os_type
        ,t1.country_name country_name
        -- ,t1.period_type period_type
        ,count(distinct t1.contract_id) num
        ,count(distinct case when t3.contract_id is not null and t3.pay_date<=t1.invalid_date then t1.contract_id else null end) direct_renew_num -- 当天续费
        ,count(distinct case when t3.contract_id is not null and t3.pay_date>t1.invalid_date then t1.contract_id else null end) after_renew_num -- 有效日期后续费
        ,count(distinct case when t2.dismiss_date is not null and t3.contract_id is null then t1.contract_id else null end) dismiss_no_renew_num -- 解约未续费
        ,count(distinct case when t2.dismiss_date is null and t3.contract_id is null then t1.contract_id else null end) no_dismiss_no_renew_num -- 未解约未续费
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
            WHERE date_p=20260601
                    and cur_pay_withhold_stage>=1     -- 当前订单代扣期数(不包含试用单)
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
                    and pay_date between 20260101 and 20260430   -- 历史自 2021；上界与 date_p 一致
                    -- and substr(invalid_time,1,8) between 20260101 and 20260531  -- current("yyyyMM01")-1
                    and period_type='月'
        )t1
LEFT JOIN (
        -- 解约信息:注意只用contractid匹配可能出现解约的不是当前订单，是之后的订单(之前应该是缺失的，不要看历史了)
        SELECT  contract_id
                ,CAST(dismiss_date AS BIGINT)  as dismiss_date
        FROM stat_vip.paid_oda_vip_tb_contract
        WHERE date_p =20260601
                and app_id_p not in(-1)
                AND dismiss_date>=20260101
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
            WHERE date_p=20260601
                    and cur_pay_withhold_stage>1
                    and pay_date >= 20260101
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
                    and period_type='月'    
        )t3
on t1.contract_id=t3.contract_id and t1.period_type=t3.period_type and t1.cur_pay_withhold_stage=t3.cur_pay_withhold_stage-1
group by t1.pay_date,t1.country_name
) t
group by country_name


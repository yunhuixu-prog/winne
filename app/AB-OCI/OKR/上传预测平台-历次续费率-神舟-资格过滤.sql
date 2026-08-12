-- 神舟临时查询：分 pay_date / 国家 / 端 / period_type 的第 1～52 次续费率
-- 观察截止日与分区 date_p 一致时，请把三处 20260510 改成与 ${now_time} 相同。
-- 资格：第 k 次续费率仅统计首订日起已满 k 个计费周期（周+7k 天、月+k 月、年+12k 月、季+3k 月）的合约，避免新 cohort 拉高期续费率失真。

SELECT
      pay_date
      ,os_type
      ,country_name
      ,period_type
      ,CASE WHEN denom_1 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_1 AS DOUBLE) / CAST(denom_1 AS DOUBLE) END AS rr_1
      ,CASE WHEN denom_2 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_2 AS DOUBLE) / CAST(denom_2 AS DOUBLE) END AS rr_2
      ,CASE WHEN denom_3 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_3 AS DOUBLE) / CAST(denom_3 AS DOUBLE) END AS rr_3
      ,CASE WHEN denom_4 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_4 AS DOUBLE) / CAST(denom_4 AS DOUBLE) END AS rr_4
      ,CASE WHEN denom_5 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_5 AS DOUBLE) / CAST(denom_5 AS DOUBLE) END AS rr_5
      ,CASE WHEN denom_6 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_6 AS DOUBLE) / CAST(denom_6 AS DOUBLE) END AS rr_6
      ,CASE WHEN denom_7 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_7 AS DOUBLE) / CAST(denom_7 AS DOUBLE) END AS rr_7
      ,CASE WHEN denom_8 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_8 AS DOUBLE) / CAST(denom_8 AS DOUBLE) END AS rr_8
      ,CASE WHEN denom_9 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_9 AS DOUBLE) / CAST(denom_9 AS DOUBLE) END AS rr_9
      ,CASE WHEN denom_10 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_10 AS DOUBLE) / CAST(denom_10 AS DOUBLE) END AS rr_10
      ,CASE WHEN denom_11 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_11 AS DOUBLE) / CAST(denom_11 AS DOUBLE) END AS rr_11
      ,CASE WHEN denom_12 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_12 AS DOUBLE) / CAST(denom_12 AS DOUBLE) END AS rr_12
      ,CASE WHEN denom_13 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_13 AS DOUBLE) / CAST(denom_13 AS DOUBLE) END AS rr_13
      ,CASE WHEN denom_14 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_14 AS DOUBLE) / CAST(denom_14 AS DOUBLE) END AS rr_14
      ,CASE WHEN denom_15 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_15 AS DOUBLE) / CAST(denom_15 AS DOUBLE) END AS rr_15
      ,CASE WHEN denom_16 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_16 AS DOUBLE) / CAST(denom_16 AS DOUBLE) END AS rr_16
      ,CASE WHEN denom_17 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_17 AS DOUBLE) / CAST(denom_17 AS DOUBLE) END AS rr_17
      ,CASE WHEN denom_18 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_18 AS DOUBLE) / CAST(denom_18 AS DOUBLE) END AS rr_18
      ,CASE WHEN denom_19 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_19 AS DOUBLE) / CAST(denom_19 AS DOUBLE) END AS rr_19
      ,CASE WHEN denom_20 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_20 AS DOUBLE) / CAST(denom_20 AS DOUBLE) END AS rr_20
      ,CASE WHEN denom_21 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_21 AS DOUBLE) / CAST(denom_21 AS DOUBLE) END AS rr_21
      ,CASE WHEN denom_22 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_22 AS DOUBLE) / CAST(denom_22 AS DOUBLE) END AS rr_22
      ,CASE WHEN denom_23 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_23 AS DOUBLE) / CAST(denom_23 AS DOUBLE) END AS rr_23
      ,CASE WHEN denom_24 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_24 AS DOUBLE) / CAST(denom_24 AS DOUBLE) END AS rr_24
      ,CASE WHEN denom_25 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_25 AS DOUBLE) / CAST(denom_25 AS DOUBLE) END AS rr_25
      ,CASE WHEN denom_26 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_26 AS DOUBLE) / CAST(denom_26 AS DOUBLE) END AS rr_26
      ,CASE WHEN denom_27 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_27 AS DOUBLE) / CAST(denom_27 AS DOUBLE) END AS rr_27
      ,CASE WHEN denom_28 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_28 AS DOUBLE) / CAST(denom_28 AS DOUBLE) END AS rr_28
      ,CASE WHEN denom_29 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_29 AS DOUBLE) / CAST(denom_29 AS DOUBLE) END AS rr_29
      ,CASE WHEN denom_30 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_30 AS DOUBLE) / CAST(denom_30 AS DOUBLE) END AS rr_30
      ,CASE WHEN denom_31 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_31 AS DOUBLE) / CAST(denom_31 AS DOUBLE) END AS rr_31
      ,CASE WHEN denom_32 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_32 AS DOUBLE) / CAST(denom_32 AS DOUBLE) END AS rr_32
      ,CASE WHEN denom_33 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_33 AS DOUBLE) / CAST(denom_33 AS DOUBLE) END AS rr_33
      ,CASE WHEN denom_34 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_34 AS DOUBLE) / CAST(denom_34 AS DOUBLE) END AS rr_34
      ,CASE WHEN denom_35 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_35 AS DOUBLE) / CAST(denom_35 AS DOUBLE) END AS rr_35
      ,CASE WHEN denom_36 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_36 AS DOUBLE) / CAST(denom_36 AS DOUBLE) END AS rr_36
      ,CASE WHEN denom_37 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_37 AS DOUBLE) / CAST(denom_37 AS DOUBLE) END AS rr_37
      ,CASE WHEN denom_38 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_38 AS DOUBLE) / CAST(denom_38 AS DOUBLE) END AS rr_38
      ,CASE WHEN denom_39 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_39 AS DOUBLE) / CAST(denom_39 AS DOUBLE) END AS rr_39
      ,CASE WHEN denom_40 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_40 AS DOUBLE) / CAST(denom_40 AS DOUBLE) END AS rr_40
      ,CASE WHEN denom_41 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_41 AS DOUBLE) / CAST(denom_41 AS DOUBLE) END AS rr_41
      ,CASE WHEN denom_42 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_42 AS DOUBLE) / CAST(denom_42 AS DOUBLE) END AS rr_42
      ,CASE WHEN denom_43 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_43 AS DOUBLE) / CAST(denom_43 AS DOUBLE) END AS rr_43
      ,CASE WHEN denom_44 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_44 AS DOUBLE) / CAST(denom_44 AS DOUBLE) END AS rr_44
      ,CASE WHEN denom_45 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_45 AS DOUBLE) / CAST(denom_45 AS DOUBLE) END AS rr_45
      ,CASE WHEN denom_46 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_46 AS DOUBLE) / CAST(denom_46 AS DOUBLE) END AS rr_46
      ,CASE WHEN denom_47 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_47 AS DOUBLE) / CAST(denom_47 AS DOUBLE) END AS rr_47
      ,CASE WHEN denom_48 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_48 AS DOUBLE) / CAST(denom_48 AS DOUBLE) END AS rr_48
      ,CASE WHEN denom_49 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_49 AS DOUBLE) / CAST(denom_49 AS DOUBLE) END AS rr_49
      ,CASE WHEN denom_50 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_50 AS DOUBLE) / CAST(denom_50 AS DOUBLE) END AS rr_50
      ,CASE WHEN denom_51 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_51 AS DOUBLE) / CAST(denom_51 AS DOUBLE) END AS rr_51
      ,CASE WHEN denom_52 = 0 THEN CAST(NULL AS DOUBLE) ELSE CAST(numer_52 AS DOUBLE) / CAST(denom_52 AS DOUBLE) END AS rr_52
FROM (
    SELECT
          f.pay_date
          ,f.os_type
          ,f.country_name
          ,f.period_type
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 7) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 3) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 1) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 1 then f.contract_id end) AS denom_1
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 7) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 3) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 1) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 2 then f.contract_id end) AS numer_1
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 14) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 6) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 2) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 2 then f.contract_id end) AS denom_2
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 14) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 6) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 2) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 3 then f.contract_id end) AS numer_2
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 9) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 3) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 3 then f.contract_id end) AS denom_3
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 9) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 3) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 4 then f.contract_id end) AS numer_3
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 28) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 4) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 4 then f.contract_id end) AS denom_4
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 28) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 4) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 5 then f.contract_id end) AS numer_4
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 35) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 60) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 15) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 5) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 5 then f.contract_id end) AS denom_5
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 35) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 60) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 15) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 5) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 6 then f.contract_id end) AS numer_5
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 72) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 18) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 6) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 6 then f.contract_id end) AS denom_6
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 72) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 18) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 6) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 7 then f.contract_id end) AS numer_6
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 49) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 7) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 7 then f.contract_id end) AS denom_7
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 49) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 7) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 8 then f.contract_id end) AS numer_7
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 56) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 96) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 8) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 8 then f.contract_id end) AS denom_8
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 56) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 96) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 8) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 9 then f.contract_id end) AS numer_8
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 63) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 108) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 27) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 9) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 9 then f.contract_id end) AS denom_9
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 63) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 108) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 27) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 9) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 10 then f.contract_id end) AS numer_9
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 70) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 120) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 30) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 10) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 10 then f.contract_id end) AS denom_10
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 70) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 120) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 30) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 10) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 11 then f.contract_id end) AS numer_10
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 77) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 132) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 33) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 11) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 11 then f.contract_id end) AS denom_11
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 77) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 132) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 33) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 11) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 12 then f.contract_id end) AS numer_11
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 144) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 12 then f.contract_id end) AS denom_12
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 144) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 12) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 13 then f.contract_id end) AS numer_12
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 91) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 156) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 39) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 13) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 13 then f.contract_id end) AS denom_13
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 91) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 156) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 39) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 13) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 14 then f.contract_id end) AS numer_13
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 98) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 168) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 14) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 14 then f.contract_id end) AS denom_14
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 98) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 168) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 14) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 15 then f.contract_id end) AS numer_14
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 105) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 180) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 45) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 15) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 15 then f.contract_id end) AS denom_15
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 105) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 180) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 45) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 15) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 16 then f.contract_id end) AS numer_15
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 112) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 192) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 16) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 16 then f.contract_id end) AS denom_16
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 112) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 192) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 16) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 17 then f.contract_id end) AS numer_16
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 119) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 204) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 51) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 17) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 17 then f.contract_id end) AS denom_17
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 119) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 204) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 51) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 17) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 18 then f.contract_id end) AS numer_17
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 126) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 216) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 54) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 18) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 18 then f.contract_id end) AS denom_18
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 126) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 216) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 54) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 18) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 19 then f.contract_id end) AS numer_18
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 133) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 228) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 57) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 19) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 19 then f.contract_id end) AS denom_19
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 133) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 228) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 57) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 19) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 20 then f.contract_id end) AS numer_19
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 140) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 240) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 60) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 20) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 20 then f.contract_id end) AS denom_20
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 140) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 240) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 60) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 20) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 21 then f.contract_id end) AS numer_20
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 147) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 252) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 63) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 21 then f.contract_id end) AS denom_21
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 147) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 252) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 63) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 21) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 22 then f.contract_id end) AS numer_21
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 154) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 264) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 66) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 22) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 22 then f.contract_id end) AS denom_22
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 154) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 264) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 66) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 22) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 23 then f.contract_id end) AS numer_22
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 161) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 276) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 69) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 23) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 23 then f.contract_id end) AS denom_23
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 161) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 276) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 69) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 23) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 24 then f.contract_id end) AS numer_23
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 168) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 288) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 72) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 24 then f.contract_id end) AS denom_24
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 168) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 288) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 72) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 24) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 25 then f.contract_id end) AS numer_24
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 175) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 300) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 75) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 25) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 25 then f.contract_id end) AS denom_25
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 175) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 300) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 75) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 25) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 26 then f.contract_id end) AS numer_25
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 182) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 312) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 78) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 26) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 26 then f.contract_id end) AS denom_26
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 182) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 312) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 78) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 26) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 27 then f.contract_id end) AS numer_26
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 189) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 324) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 81) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 27) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 27 then f.contract_id end) AS denom_27
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 189) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 324) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 81) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 27) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 28 then f.contract_id end) AS numer_27
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 196) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 336) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 28) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 28 then f.contract_id end) AS denom_28
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 196) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 336) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 84) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 28) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 29 then f.contract_id end) AS numer_28
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 203) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 348) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 87) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 29) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 29 then f.contract_id end) AS denom_29
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 203) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 348) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 87) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 29) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 30 then f.contract_id end) AS numer_29
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 210) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 360) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 90) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 30) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 30 then f.contract_id end) AS denom_30
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 210) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 360) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 90) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 30) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 31 then f.contract_id end) AS numer_30
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 217) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 372) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 93) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 31) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 31 then f.contract_id end) AS denom_31
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 217) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 372) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 93) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 31) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 32 then f.contract_id end) AS numer_31
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 224) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 384) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 96) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 32) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 32 then f.contract_id end) AS denom_32
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 224) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 384) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 96) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 32) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 33 then f.contract_id end) AS numer_32
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 231) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 396) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 99) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 33) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 33 then f.contract_id end) AS denom_33
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 231) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 396) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 99) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 33) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 34 then f.contract_id end) AS numer_33
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 238) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 408) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 102) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 34) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 34 then f.contract_id end) AS denom_34
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 238) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 408) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 102) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 34) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 35 then f.contract_id end) AS numer_34
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 245) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 420) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 105) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 35) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 35 then f.contract_id end) AS denom_35
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 245) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 420) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 105) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 35) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 36 then f.contract_id end) AS numer_35
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 252) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 432) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 108) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 36 then f.contract_id end) AS denom_36
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 252) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 432) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 108) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 36) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 37 then f.contract_id end) AS numer_36
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 259) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 444) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 111) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 37) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 37 then f.contract_id end) AS denom_37
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 259) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 444) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 111) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 37) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 38 then f.contract_id end) AS numer_37
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 266) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 456) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 114) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 38) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 38 then f.contract_id end) AS denom_38
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 266) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 456) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 114) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 38) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 39 then f.contract_id end) AS numer_38
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 273) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 468) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 117) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 39) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 39 then f.contract_id end) AS denom_39
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 273) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 468) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 117) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 39) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 40 then f.contract_id end) AS numer_39
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 280) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 480) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 120) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 40) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 40 then f.contract_id end) AS denom_40
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 280) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 480) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 120) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 40) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 41 then f.contract_id end) AS numer_40
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 287) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 492) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 123) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 41) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 41 then f.contract_id end) AS denom_41
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 287) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 492) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 123) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 41) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 42 then f.contract_id end) AS numer_41
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 294) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 504) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 126) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 42 then f.contract_id end) AS denom_42
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 294) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 504) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 126) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 42) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 43 then f.contract_id end) AS numer_42
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 301) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 516) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 129) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 43) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 43 then f.contract_id end) AS denom_43
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 301) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 516) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 129) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 43) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 44 then f.contract_id end) AS numer_43
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 308) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 528) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 132) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 44) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 44 then f.contract_id end) AS denom_44
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 308) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 528) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 132) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 44) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 45 then f.contract_id end) AS numer_44
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 315) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 540) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 135) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 45) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 45 then f.contract_id end) AS denom_45
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 315) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 540) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 135) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 45) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 46 then f.contract_id end) AS numer_45
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 322) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 552) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 138) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 46) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 46 then f.contract_id end) AS denom_46
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 322) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 552) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 138) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 46) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 47 then f.contract_id end) AS numer_46
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 329) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 564) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 141) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 47) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 47 then f.contract_id end) AS denom_47
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 329) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 564) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 141) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 47) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 48 then f.contract_id end) AS numer_47
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 336) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 576) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 144) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 48 then f.contract_id end) AS denom_48
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 336) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 576) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 144) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 48) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 49 then f.contract_id end) AS numer_48
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 343) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 588) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 147) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 49) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 49 then f.contract_id end) AS denom_49
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 343) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 588) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 147) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 49) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 50 then f.contract_id end) AS numer_49
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 350) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 600) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 150) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 50) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 50 then f.contract_id end) AS denom_50
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 350) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 600) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 150) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 50) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 51 then f.contract_id end) AS numer_50
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 357) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 612) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 153) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 51) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 51 then f.contract_id end) AS denom_51
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 357) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 612) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 153) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 51) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 52 then f.contract_id end) AS numer_51
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 364) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 624) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 156) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 52) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 52 then f.contract_id end) AS denom_52
      ,count(distinct case when (
      case
        when f.period_type rlike '周' then date_add(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 364) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '年' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 624) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        when f.period_type rlike '季' then add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 156) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
        else add_months(to_date(from_unixtime(unix_timestamp(cast(f.pay_date as string),'yyyyMMdd'))), 52) <= to_date(from_unixtime(unix_timestamp(cast(20260510 as string),'yyyyMMdd')))
      end
    ) and coalesce(m.max_stage,1) >= 53 then f.contract_id end) AS numer_52
    FROM (
            SELECT contract_id
                  ,device_type AS os_type
                  ,CASE WHEN country_name IN ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') THEN country_name ELSE '其他' END AS country_name
                  ,period_type
                  ,pay_date
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p = 20260510
              AND cur_pay_withhold_stage = 1
              AND order_type = '2'
              AND contract_id <> 0
              AND app_id_p IN (7329803307041000000)
              AND commodity_id_p NOT IN (-1)
              AND pay_date BETWEEN 20230101 AND 20260430
         ) f
    LEFT JOIN (
            SELECT contract_id
                  ,period_type
                  ,MAX(cur_pay_withhold_stage) AS max_stage
            FROM stat_vip.paid_oda_vip_all_order
            WHERE date_p = 20260510
              AND order_type = '2'
              AND contract_id <> 0
              AND app_id_p IN (7329803307041000000)
              AND commodity_id_p NOT IN (-1)
            GROUP BY contract_id, period_type
         ) m
      ON f.contract_id = m.contract_id AND f.period_type = m.period_type
    GROUP BY f.pay_date, f.os_type, f.country_name, f.period_type
) x
;
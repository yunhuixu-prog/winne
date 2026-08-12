set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_ada_money_all_country PARTITION(date_p)

SELECT
  -- 月度
  a.month_goal goal_month,
  b.gmv_real gmv_real_month,
  b.mon_pro pro_month,
  -- 季度
  a.season_goal goal_quar,
  b.gmv_real_quar gmv_real_quar,
  b.qur_pro pro_quar,
  -- 年度
  a.year_goal goal_year,
  b.gmv_real_year gmv_real_year,
  b.year_pro pro_year,

  substr(a.date_p, 1, 8) as date_p
FROM
(
    -- 目 标
    SELECT
      SUM(month_v) AS month_goal,
      SUM(season_v) AS season_goal,
      SUM(year_v) AS year_goal
    ,CASE
        WHEN substr(date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
        WHEN substr(date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
        WHEN substr(date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
        WHEN substr(date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
      END AS dt_quar,
      '2026' AS dt_year,
      date_p
    FROM
      stat_ab.filing_ana_2026okr_target_country
    WHERE
      type='收入'
    GROUP BY
      CASE
        WHEN substr(date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
        WHEN substr(date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
        WHEN substr(date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
        WHEN substr(date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
      END,
      date_p
) a
LEFT JOIN
(
    -- 实际 值
    SELECT
      mon,
      dt_quar,
      dt_year,
      gmv_real,
      mt_date_progress(date_p_pro, 'm') mon_pro,
      mt_date_progress(cast(date_p_pro AS string), 'q') qur_pro,
      mt_date_progress(cast(date_p_pro AS string), 'y') year_pro,
      SUM(gmv_real) over(PARTITION BY dt_quar ORDER BY mon) gmv_real_quar,
      SUM(gmv_real) over(PARTITION BY dt_year ORDER BY mon) gmv_real_year
    FROM
      (
        SELECT
          mon
        ,dt_quar
        ,dt_year
        ,SUM(gmv_real) gmv_real
        ,MAX(date_p_pro) date_p_pro
        FROM
          (
            SELECT
			  CASE
                WHEN substr(pay_date, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(pay_date, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(pay_date, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(pay_date, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END AS dt_quar
			  ,substr(pay_date, 1, 4) dt_year
              ,substr(pay_date, 1, 6) AS mon -- 付费月份
              ,pay_date date_p_pro
              ,SUM(ord_amt_usd) AS gmv_real -- 每天收入
            FROM
              stat_vip.paid_oda_vip_all_order
            WHERE
               date_p =  ${start_time} -- 取数日期
             AND substr(create_time,1,8) <= ${start_time}
             AND pay_date between 20260101 and ${start_time}
             AND app_id_p IN (7329803307041000000)
             AND commodity_id_P not in (-1)
            GROUP BY
              CASE
                WHEN substr(pay_date, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(pay_date, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(pay_date, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(pay_date, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END
			  ,substr(pay_date, 1, 4)
              ,substr(pay_date, 1,6)
              ,pay_date
            UNION ALL
              -- 以下代码功能：按照退款日（而非这单的付款日）计算退款，例如1月收入10元，3月退款2元，那么1月计10元收入，3月计-2元收入
            SELECT
			  CASE
                WHEN substr(refund_time, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(refund_time, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(refund_time, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(refund_time, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END AS dt_quar
			  ,substr(refund_time, 1, 4) dt_year
			  ,substr(refund_time, 1, 6) AS mon
              ,substr(refund_time,1, 8) date_p_pro
			  ,SUM(-refund_amt_usd) AS gmv_real
            FROM
              stat_vip.paid_oda_vip_all_order
            WHERE
              date_p =  ${start_time} -- 取数日期
              AND substr(create_time,1,8) <= ${start_time}
              AND substr(refund_time,1,8) BETWEEN 20260101 and ${start_time}
              and app_id_p IN (7329803307041000000)
              and commodity_id_P not in (-1)
              and pay_status=6
            GROUP BY
			  CASE
                WHEN substr(refund_time, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(refund_time, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(refund_time, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(refund_time, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END
			  ,substr(refund_time, 1, 4)
              ,substr(refund_time, 1, 6)
              ,substr(refund_time,1, 8)
      ) s
      GROUP BY mon ,dt_quar ,dt_year
    ) t
) b
ON substr(a.date_p, 1, 6) = b.mon

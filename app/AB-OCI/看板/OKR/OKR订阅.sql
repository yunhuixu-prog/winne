set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_adz_money_okr_all_country PARTITION(date_p)

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
  substr(a.date_p, 1, 8) as target_date,

  ${start_time} as date_p
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
            substr(date_p,1,6) mon
            ,CASE
                WHEN substr(date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END AS dt_quar
            ,substr(date_p, 1, 4) dt_year
            ,sum(v.gmv_real_to-coalesce(w.gmv_real_pre,0)) gmv_real
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(MAX(date_p) AS STRING),'yyyyMMdd'),'yyyyMMdd') date_p_pro
        FROM
        (
            SELECT date_p
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_to
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and ${start_time}
                and os_type='整体'
                and country_code='整体'
                and period_type='整体'
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) v
        left join
        (
            SELECT CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT) date_p_pre
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_pre
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and ${start_time}
                and os_type='整体'
                and country_code='整体'
                and period_type='整体'
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) w
        on v.date_p=w.date_p_pre
        GROUP BY substr(date_p,1,6)
            ,CASE
                WHEN substr(date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END
            ,substr(date_p, 1, 4)
    ) t
) b
ON substr(a.date_p, 1, 6) = b.mon

set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_adz_money_active_okr_by_country PARTITION(date_p)

SELECT
  '收入' type,
  a.country,
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
  -- 订阅无滚动30天口径
  0 as actual_value_month_roll_30,
  0 as actual_value_quar_roll_30,
  0 as actual_value_year_roll_30,

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
      country,
      date_p
    FROM
      stat_ab.filing_rna_2026okr_by_country
    WHERE
      type='收入'
    GROUP BY
      CASE
        WHEN substr(date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
        WHEN substr(date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
        WHEN substr(date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
        WHEN substr(date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
      END,
      country,
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
      country,
      SUM(gmv_real) over(PARTITION BY country, dt_quar ORDER BY mon) gmv_real_quar,
      SUM(gmv_real) over(PARTITION BY country, dt_year ORDER BY mon) gmv_real_year
    FROM
      (
        SELECT
            substr(v.date_p,1,6) mon
            ,case when v.country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then v.country_code
                else '其他' end as country
            ,CASE
                WHEN substr(v.date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(v.date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(v.date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(v.date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END AS dt_quar
            ,substr(v.date_p, 1, 4) dt_year
            ,sum(v.gmv_real_to-coalesce(w.gmv_real_pre,0)) gmv_real
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(MAX(v.date_p) AS STRING),'yyyyMMdd'),'yyyyMMdd') date_p_pro
        FROM
        (
            SELECT date_p
                ,country_code
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_to
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and ${start_time}
                and os_type='整体'
                -- and country_code='整体'
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
                ,country_code
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_pre
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and ${start_time}
                and os_type='整体'
                -- and country_code='整体'
                and period_type='整体'
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) w
        on v.date_p=w.date_p_pre and v.country_code=w.country_code
        GROUP BY substr(v.date_p,1,6)
            ,case when v.country_code in ('整体','美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then v.country_code
                else '其他' end
            ,CASE
                WHEN substr(v.date_p, 1, 6) IN (202601, 202602, 202603) THEN 'Q1'
                WHEN substr(v.date_p, 1, 6) IN (202604, 202605, 202606) THEN 'Q2'
                WHEN substr(v.date_p, 1, 6) IN (202607, 202608, 202609) THEN 'Q3'
                WHEN substr(v.date_p, 1, 6) IN (202610, 202611, 202612) THEN 'Q4'
              END
            ,substr(v.date_p, 1, 4)
    ) t
) b
ON substr(a.date_p, 1, 6) = b.mon and a.country = b.country

UNION ALL

-- MAU/MNU：每月同时产出自然月去重 + 滚动30天去重
-- MAU 季/年：取该季/年内最新月（季已结束=季末月，年已结束=12月）
-- MNU（含自然/渠道）季/年：累计，与订阅一致
SELECT
  a.type,
  a.country,
  -- 月度
  a.month_goal goal_month,
  b.actual_value actual_value_month,
  b.mon_pro pro_month,
  -- 季度
  a.season_goal goal_quar,
  b.actual_value_quar actual_value_quar,
  b.qur_pro pro_quar,
  -- 年度
  a.year_goal goal_year,
  b.actual_value_year actual_value_year,
  b.year_pro pro_year,
  substr(a.date_p, 1, 8) as target_date,
  b.actual_value_roll_30 as actual_value_month_roll_30,
  b.actual_value_quar_roll_30 as actual_value_quar_roll_30,
  b.actual_value_year_roll_30 as actual_value_year_roll_30,

  ${start_time} as date_p
FROM
(
    SELECT
      type,
      SUM(month_v) AS month_goal,
      SUM(season_v) AS season_goal,
      SUM(year_v) AS year_goal,
      country,
      date_p
    FROM
      stat_ab.filing_rna_2026okr_by_country
    WHERE
      type IN ('MAU', 'MNU','MNU_non_organic','MNU_organic')
    GROUP BY
      type,
      country,
      date_p
) a
LEFT JOIN
(
    SELECT
      mon,
      type,
      country,
      actual_value,
      actual_value_roll_30,
      mt_date_progress(date_p_pro, 'm') mon_pro,
      mt_date_progress(cast(date_p_pro AS string), 'q') qur_pro,
      mt_date_progress(cast(date_p_pro AS string), 'y') year_pro,
      CASE
        WHEN type = 'MAU' THEN
          MAX(CASE WHEN mon = max_mon_quar THEN actual_value END)
            OVER (PARTITION BY type, country, dt_quar)
        ELSE
          SUM(actual_value) OVER (
            PARTITION BY type, country, dt_quar
            ORDER BY mon
          )
      END AS actual_value_quar,
      CASE
        WHEN type = 'MAU' THEN
          MAX(CASE WHEN mon = max_mon_year THEN actual_value END)
            OVER (PARTITION BY type, country, dt_year)
        ELSE
          SUM(actual_value) OVER (
            PARTITION BY type, country, dt_year
            ORDER BY mon
          )
      END AS actual_value_year,
      CASE
        WHEN type = 'MAU' THEN
          MAX(CASE WHEN mon = max_mon_quar THEN actual_value_roll_30 END)
            OVER (PARTITION BY type, country, dt_quar)
        ELSE
          SUM(actual_value_roll_30) OVER (
            PARTITION BY type, country, dt_quar
            ORDER BY mon
          )
      END AS actual_value_quar_roll_30,
      CASE
        WHEN type = 'MAU' THEN
          MAX(CASE WHEN mon = max_mon_year THEN actual_value_roll_30 END)
            OVER (PARTITION BY type, country, dt_year)
        ELSE
          SUM(actual_value_roll_30) OVER (
            PARTITION BY type, country, dt_year
            ORDER BY mon
          )
      END AS actual_value_year_roll_30
    FROM
    (
        SELECT
          mon,
          dt_quar,
          dt_year,
          country,
          date_p_pro,
          type,
          actual_value,
          actual_value_roll_30,
          MAX(mon) OVER (PARTITION BY type, country, dt_quar) AS max_mon_quar,
          MAX(mon) OVER (PARTITION BY type, country, dt_year) AS max_mon_year
        FROM
        (
            SELECT
              mon,
              CASE
                WHEN mon IN ('202601', '202602', '202603') THEN 'Q1'
                WHEN mon IN ('202604', '202605', '202606') THEN 'Q2'
                WHEN mon IN ('202607', '202608', '202609') THEN 'Q3'
                WHEN mon IN ('202610', '202611', '202612') THEN 'Q4'
              END AS dt_quar,
              substr(mon, 1, 4) dt_year,
              country,
              date_p_pro,
              type,
              actual_value,
              actual_value_roll_30
            FROM
            (
                -- 分国家：自然月 + 滚动30天
                SELECT
                  mon,
                  CASE
                    WHEN country IN ('美国', '英国', '巴西', '墨西哥', '西班牙', '加拿大', '澳大利亚')
                      THEN country
                    ELSE '其他'
                  END AS country,
                  MAX(date_p_pro) AS date_p_pro,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' THEN final_id END) AS mau,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_new = 'New' THEN final_id END) AS mnu,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_ua = 'non-Organic' AND is_new = 'New' THEN final_id END) AS mnu_non_organic,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_ua = 'Organic' AND is_new = 'New' THEN final_id END) AS mnu_organic,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' THEN final_id END) AS mau_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_new = 'New' THEN final_id END) AS mnu_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_ua = 'non-Organic' AND is_new = 'New' THEN final_id END) AS mnu_non_organic_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_ua = 'Organic' AND is_new = 'New' THEN final_id END) AS mnu_organic_roll_30
                FROM
                (
                    SELECT
                      m.mon,
                      d.final_id,
                      c.country,
                      d.scope,
                      FROM_UNIXTIME(
                        UNIX_TIMESTAMP(CAST(MAX(d.date_p) AS string), 'yyyyMMdd'),
                        'yyyyMMdd'
                      ) AS date_p_pro,
                      MAX(d.is_ua) AS is_ua,
                      MIN(CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END) AS is_new
                    FROM
                    (
                        -- 月份边界：自然月 [月初, min(月末, start_time)]；滚动30天 [end-29, end]
                        SELECT
                          mon,
                          CAST(CONCAT(mon, '01') AS bigint) AS cal_start,
                          CASE
                            WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                            ELSE CAST(
                              DATE_FORMAT(
                                LAST_DAY(
                                  FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                ),
                                'yyyyMMdd'
                              ) AS bigint
                            )
                          END AS cal_end,
                          CAST(
                            DATE_FORMAT(
                              DATE_SUB(
                                FROM_UNIXTIME(
                                  UNIX_TIMESTAMP(
                                    CAST(
                                      CASE
                                        WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                                        ELSE CAST(
                                          DATE_FORMAT(
                                            LAST_DAY(
                                              FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                            ),
                                            'yyyyMMdd'
                                          ) AS bigint
                                        )
                                      END AS string
                                    ),
                                    'yyyyMMdd'
                                  )
                                ),
                                29
                              ),
                              'yyyyMMdd'
                            ) AS bigint
                          ) AS roll_start,
                          CASE
                            WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                            ELSE CAST(
                              DATE_FORMAT(
                                LAST_DAY(
                                  FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                ),
                                'yyyyMMdd'
                              ) AS bigint
                            )
                          END AS roll_end
                        FROM
                        (
                            SELECT distinct substr(date_p,1,6) as mon
                            FROM stat_ab.filing_rna_2026okr_by_country
                        ) month_dim
                        WHERE mon <= SUBSTR(CAST(${start_time} AS string), 1, 6)
                    ) m
                    JOIN
                    (
                        SELECT
                          date_p,
                          final_id,
                          country_id,
                          is_ua,
                          'cal' AS scope,
                          substr(CAST(date_p AS string), 1, 6) AS mon
                        FROM stat_sdk.sdk_odz_active
                        WHERE date_p BETWEEN 20260101 AND ${start_time}
                          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                          AND os_p IS NOT NULL

                        UNION ALL

                        SELECT
                          a.date_p,
                          a.final_id,
                          a.country_id,
                          a.is_ua,
                          'roll' AS scope,
                          m2.mon
                        FROM
                        (
                            SELECT date_p, final_id, country_id, is_ua
                            FROM stat_sdk.sdk_odz_active
                            WHERE date_p BETWEEN 20251203 AND ${start_time}
                              AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                              AND os_p IS NOT NULL
                        ) a
                        JOIN
                        (
                            SELECT
                              mon,
                              CAST(
                                DATE_FORMAT(
                                  DATE_SUB(
                                    FROM_UNIXTIME(
                                      UNIX_TIMESTAMP(
                                        CAST(
                                          CASE
                                            WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                                            ELSE CAST(
                                              DATE_FORMAT(
                                                LAST_DAY(
                                                  FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                                ),
                                                'yyyyMMdd'
                                              ) AS bigint
                                            )
                                          END AS string
                                        ),
                                        'yyyyMMdd'
                                      )
                                    ),
                                    29
                                  ),
                                  'yyyyMMdd'
                                ) AS bigint
                              ) AS roll_start,
                              CASE
                                WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                                ELSE CAST(
                                  DATE_FORMAT(
                                    LAST_DAY(
                                      FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                    ),
                                    'yyyyMMdd'
                                  ) AS bigint
                                )
                              END AS roll_end
                            FROM
                            (
                                SELECT distinct substr(date_p,1,6) as mon
                                FROM stat_ab.filing_rna_2026okr_by_country
                            ) md
                            WHERE mon <= SUBSTR(CAST(${start_time} AS string), 1, 6)
                        ) m2
                          ON a.date_p BETWEEN m2.roll_start AND m2.roll_end
                    ) d
                      ON (
                        (d.scope = 'cal' AND d.mon = m.mon AND d.date_p BETWEEN m.cal_start AND m.cal_end)
                        OR (d.scope = 'roll' AND d.mon = m.mon)
                      )
                    LEFT JOIN
                    (
                        SELECT DISTINCT date_p, final_id, country_id
                        FROM stat_sdk.sdk_odz_new_device_info
                        WHERE date_p BETWEEN 20251203 AND ${start_time}
                          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                          AND os_p IS NOT NULL
                    ) n
                      ON d.final_id = n.final_id
                     AND d.date_p = n.date_p
                     AND d.country_id = n.country_id
                    LEFT JOIN
                    (
                        SELECT DISTINCT id AS country_id, name AS country
                        FROM stat_sdk.dim_rna_ip_location
                        WHERE level = '1' AND date_p IS NOT NULL
                    ) c
                      ON d.country_id = c.country_id
                    GROUP BY m.mon, d.final_id, c.country, d.scope
                ) user_month
                GROUP BY mon, CASE
                    WHEN country IN ('美国', '英国', '巴西', '墨西哥', '西班牙', '加拿大', '澳大利亚')
                      THEN country
                    ELSE '其他'
                  END
            ) country_metric
            LATERAL VIEW stack(
              4,
              'MAU', mau, mau_roll_30,
              'MNU', mnu, mnu_roll_30,
              'MNU_non_organic', mnu_non_organic, mnu_non_organic_roll_30,
              'MNU_organic', mnu_organic, mnu_organic_roll_30
            ) metric_stack AS type, actual_value, actual_value_roll_30

            UNION ALL

            -- 整体单独去重
            SELECT
              mon,
              CASE
                WHEN mon IN ('202601', '202602', '202603') THEN 'Q1'
                WHEN mon IN ('202604', '202605', '202606') THEN 'Q2'
                WHEN mon IN ('202607', '202608', '202609') THEN 'Q3'
                WHEN mon IN ('202610', '202611', '202612') THEN 'Q4'
              END AS dt_quar,
              substr(mon, 1, 4) dt_year,
              '整体' country,
              date_p_pro,
              type,
              actual_value,
              actual_value_roll_30
            FROM
            (
                SELECT
                  mon,
                  MAX(date_p_pro) AS date_p_pro,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' THEN final_id END) AS mau,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_new = 'New' THEN final_id END) AS mnu,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_ua = 'non-Organic' AND is_new = 'New' THEN final_id END) AS mnu_non_organic,
                  COUNT(DISTINCT CASE WHEN scope = 'cal' AND is_ua = 'Organic' AND is_new = 'New' THEN final_id END) AS mnu_organic,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' THEN final_id END) AS mau_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_new = 'New' THEN final_id END) AS mnu_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_ua = 'non-Organic' AND is_new = 'New' THEN final_id END) AS mnu_non_organic_roll_30,
                  COUNT(DISTINCT CASE WHEN scope = 'roll' AND is_ua = 'Organic' AND is_new = 'New' THEN final_id END) AS mnu_organic_roll_30
                FROM
                (
                    SELECT
                      m.mon,
                      d.final_id,
                      d.scope,
                      FROM_UNIXTIME(
                        UNIX_TIMESTAMP(CAST(MAX(d.date_p) AS string), 'yyyyMMdd'),
                        'yyyyMMdd'
                      ) AS date_p_pro,
                      MAX(d.is_ua) AS is_ua,
                      MIN(CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END) AS is_new
                    FROM
                    (
                        SELECT
                          mon,
                          CAST(CONCAT(mon, '01') AS bigint) AS cal_start,
                          CASE
                            WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                            ELSE CAST(
                              DATE_FORMAT(
                                LAST_DAY(
                                  FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                ),
                                'yyyyMMdd'
                              ) AS bigint
                            )
                          END AS cal_end
                        FROM
                        (
                            SELECT distinct substr(date_p,1,6) as mon
                            FROM stat_ab.filing_rna_2026okr_by_country
                        ) month_dim
                        WHERE mon <= SUBSTR(CAST(${start_time} AS string), 1, 6)
                    ) m
                    JOIN
                    (
                        SELECT
                          date_p,
                          final_id,
                          is_ua,
                          'cal' AS scope,
                          substr(CAST(date_p AS string), 1, 6) AS mon
                        FROM stat_sdk.sdk_odz_active
                        WHERE date_p BETWEEN 20260101 AND ${start_time}
                          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                          AND os_p IS NOT NULL

                        UNION ALL

                        SELECT
                          a.date_p,
                          a.final_id,
                          a.is_ua,
                          'roll' AS scope,
                          m2.mon
                        FROM
                        (
                            SELECT date_p, final_id, is_ua
                            FROM stat_sdk.sdk_odz_active
                            WHERE date_p BETWEEN 20251203 AND ${start_time}
                              AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                              AND os_p IS NOT NULL
                        ) a
                        JOIN
                        (
                            SELECT
                              mon,
                              CAST(
                                DATE_FORMAT(
                                  DATE_SUB(
                                    FROM_UNIXTIME(
                                      UNIX_TIMESTAMP(
                                        CAST(
                                          CASE
                                            WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                                            ELSE CAST(
                                              DATE_FORMAT(
                                                LAST_DAY(
                                                  FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                                ),
                                                'yyyyMMdd'
                                              ) AS bigint
                                            )
                                          END AS string
                                        ),
                                        'yyyyMMdd'
                                      )
                                    ),
                                    29
                                  ),
                                  'yyyyMMdd'
                                ) AS bigint
                              ) AS roll_start,
                              CASE
                                WHEN mon = SUBSTR(CAST(${start_time} AS string), 1, 6) THEN ${start_time}
                                ELSE CAST(
                                  DATE_FORMAT(
                                    LAST_DAY(
                                      FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(mon, '01'), 'yyyyMMdd'))
                                    ),
                                    'yyyyMMdd'
                                  ) AS bigint
                                )
                              END AS roll_end
                            FROM
                            (
                                SELECT distinct substr(date_p,1,6) as mon
                                FROM stat_ab.filing_rna_2026okr_by_country
                            ) md
                            WHERE mon <= SUBSTR(CAST(${start_time} AS string), 1, 6)
                        ) m2
                          ON a.date_p BETWEEN m2.roll_start AND m2.roll_end
                    ) d
                      ON (
                        (d.scope = 'cal' AND d.mon = m.mon AND d.date_p BETWEEN m.cal_start AND m.cal_end)
                        OR (d.scope = 'roll' AND d.mon = m.mon)
                      )
                    LEFT JOIN
                    (
                        SELECT DISTINCT date_p, final_id
                        FROM stat_sdk.sdk_odz_new_device_info
                        WHERE date_p BETWEEN 20251203 AND ${start_time}
                          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                          AND os_p IS NOT NULL
                    ) n
                      ON d.final_id = n.final_id
                     AND d.date_p = n.date_p
                    GROUP BY m.mon, d.final_id, d.scope
                ) user_month
                GROUP BY mon
            ) all_metric
            LATERAL VIEW stack(
              4,
              'MAU', mau, mau_roll_30,
              'MNU', mnu, mnu_roll_30,
              'MNU_non_organic', mnu_non_organic, mnu_non_organic_roll_30,
              'MNU_organic', mnu_organic, mnu_organic_roll_30
            ) metric_stack AS type, actual_value, actual_value_roll_30
        ) metric_actual
    ) with_max_mon
) b
  ON substr(a.date_p, 1, 6) = b.mon
 AND a.type = b.type
 AND a.country = b.country

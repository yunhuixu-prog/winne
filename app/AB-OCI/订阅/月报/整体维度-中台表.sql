SELECT
      mon
      ,os_type,country_code,period_type
      ,gmv_real 
    FROM
      (
        SELECT
            substr(date_p,1,6) mon
            ,v.os_type,v.country_code,v.period_type
            ,sum(v.gmv_real_to-coalesce(w.gmv_real_pre,0)) gmv_real
        FROM
        (
            SELECT date_p
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_to
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20250101 and 20250630
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'

            union all 

            SELECT date_p
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_to
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20250701 and 20251231
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) v
        left join
        (
            SELECT CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT) date_p_pre
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_pre
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20250101 and 20250630
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'

            union all 

            SELECT CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT) date_p_pre
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_pre
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20250701 and 20251231
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) w
        on v.date_p=w.date_p_pre and v.os_type=w.os_type and v.country_code=w.country_code and v.period_type=w.period_type
        GROUP BY substr(date_p,1,6),v.os_type,v.country_code,v.period_type
    ) t

union all 

SELECT
      mon
      ,os_type,country_code,period_type
      ,gmv_real 
    FROM
      (
        SELECT
            substr(date_p,1,6) mon
            ,v.os_type,v.country_code,v.period_type
            ,sum(v.gmv_real_to-coalesce(w.gmv_real_pre,0)) gmv_real
        FROM
        (
            SELECT date_p
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_to
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and 20260331
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) v
        left join
        (
            SELECT CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT) date_p_pre
                ,os_type,country_code,period_type
                ,gmv_year_usd-refund_gmv_year_usd gmv_real_pre
            FROM stat_vip.vip_adz_middle_income_dayoci
            WHERE date_p between 20260101 and 20260331
                -- and os_type='整体'
                and country_code in ('整体','美国','巴西','英国')
                and period_type in ('整体','年','月','周')
                and pay_channel='整体'
                and geographic_subdivision_v2='整体'
                and ocean_name='整体'
                and product_sub_line='AirBrush'
                and type='订阅'
        ) w
        on v.date_p=w.date_p_pre and v.os_type=w.os_type and v.country_code=w.country_code and v.period_type=w.period_type
        GROUP BY substr(date_p,1,6),v.os_type,v.country_code,v.period_type
    ) t
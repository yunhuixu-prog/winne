WITH 
indicators_tmp AS (
    select app_type
            ,month
            ,nvl(period_type,'未知') as period_type
            ,country_name
            ,country_type
            ,sum(moth_valid_menber ) as moth_valid_menber 
    from
    (
            select 'AirBrush' as app_type
                ,period_type as period_type
                ,valid_menber moth_valid_menber
                ,date_p as month
                ,country_code as country_name
                ,geographic_subdivision_v2 as country_type
            from stat_vip.vip_amz_middle_income_monthoci
            where  date_p>=${time_0}  and date_p<=${time_1} 
                and product_line in ('整体')
                and product_sub_line in ('AirBrush')
                and os_type IN ('整体')
                and pay_channel IN ('整体')
                and type in ('订阅')
                and ocean_name='整体'
    )a
   where a.app_type not in ('其他')
   group by app_type,month,nvl(period_type,'未知'),country_name,country_type
),
t1 AS (
    SELECT
        month
        ,app_type
        ,period_type
        ,country_name
        ,country_type
        ,sum(moth_valid_menber) as moth_valid_menber
    FROM
        indicators_tmp
    WHERE
        month = ${time_1}   -- 当月分区current("yyyyMM01")
    group by month
        ,app_type
        ,period_type
        ,country_name
        ,country_type
),
t2 AS (
select
    date_p as month
    ,country_name
    ,country_type
    ,'AirBrush' AS app_type
    ,nvl(period_type,'未知') as  period_type
    ,sum(moth_new_valid_member) as moth_new_valid_member
from
         stat_vip.vip_amz_new_valid_member
where
        date_p = ${time_1}  -- 当月分区
    and app_type='AirBrush'
    and ocean_name='整体'
group by date_p,
    country_name,
    country_type,
    nvl(period_type,'未知')

),
-- 第2步：获取上个月的有效会员数
last AS (
    SELECT
        app_type,
        period_type,
        -- 核心指标：上月有效会员数
        country_name,
        country_type,
        sum(moth_valid_menber) as last_moth_valid_menber
    FROM
        indicators_tmp
    WHERE
        month = ${time_0} -- 注意：这里是上个月的分区current("yyyyMM01")-2，请根据实际情况修改
    group by
        app_type,
        period_type,
        country_name,
        country_type 
)

insert overwrite table stat_ab.filing_amz_valid_member_breakdown partition (date_p = ${time_1})
-- 第3步：最终计算（重构为最简单的多路JOIN结构）
SELECT
    t1.month,
    t1.app_type,
    COALESCE(t1.moth_valid_menber, 0) AS moth_valid_menber,          -- 本月有效会员数
    COALESCE(t2.moth_new_valid_member, 0) AS moth_new_valid_member,      -- 本月新增有效会员数
    COALESCE(last.last_moth_valid_menber, 0) AS last_moth_valid_menber,     -- 上月有效会员数

    -- 计算公式1：本月留存会员数(rentention_member)
    (COALESCE(t1.moth_valid_menber, 0) - COALESCE(t2.moth_new_valid_member, 0)) AS rentention_member,

    -- 计算公式2：本月流失会员数(churned_member)
    (COALESCE(last.last_moth_valid_menber, 0) + COALESCE(t2.moth_new_valid_member, 0) - COALESCE(t1.moth_valid_menber, 0)) AS churned_member,

    -- 计算公式3：本月净新增会员数(net_new_member)
    (COALESCE(t2.moth_new_valid_member, 0) - (COALESCE(last.last_moth_valid_menber, 0) + COALESCE(t2.moth_new_valid_member, 0) - COALESCE(t1.moth_valid_menber, 0))) AS net_new_member,

    -- 计算公式4：本月月有效留存率(rentention_rate)
    CASE
        WHEN COALESCE(last.last_moth_valid_menber, 0) > 0 
        THEN (COALESCE(t1.moth_valid_menber, 0) - COALESCE(t2.moth_new_valid_member, 0)) * 1.0 / COALESCE(last.last_moth_valid_menber, 0)
        ELSE 0
    END AS rentention_rate,
    t1.period_type as period_type,
    t1.country_name,
    t1.country_type
FROM 
    t1
LEFT JOIN 
    t2
    ON t1.month = t2.month
    AND t1.app_type = t2.app_type
    AND t1.period_type = t2.period_type
    and t1.country_name= t2.country_name
    and t1.country_type=t2.country_type
LEFT JOIN 
    last
    ON t1.app_type = last.app_type
    AND t1.period_type = last.period_type
    and t1.country_name= last.country_name
    and t1.country_type=last.country_type
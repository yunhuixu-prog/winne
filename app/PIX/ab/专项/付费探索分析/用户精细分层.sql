-- 订阅习惯（例如爱好年月，订阅次数、价格敏感-是否折扣单）、订阅价值（历史订阅金额，过期时长）、安装时长
-- 活跃习惯（间歇性、持续性）、活跃度（高中低流失）、功能使用习惯（深度 or 广度）、功能需求（近30日保存，会员权益保存）
drop table if exists dataintegration-265403.temp.winne_temp_pay_detail_type;
create table dataintegration-265403.temp.winne_temp_pay_detail_type as

-- delete from `dataintegration-265403.temp.winne_temp_pay_detail_type` where active_date between '2025-01-01' and '2025-12-31';
-- insert into `dataintegration-265403.temp.winne_temp_pay_detail_type`

WITH
active AS (
    select app_name,
            event_date_hk
            ,platform
            ,user_pseudo_id
            ,uuid
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between date_sub('2025-01-01',interval 30 day) and '2025-12-31'
            and app_name = 'AirBrush'
        group by 1,2,3,4,5
),
pay AS (
    select
            app_id,uuid,standard_order_date,order_id,payment_price_usd,sku,subscription_period,order_status,subscription_user_type,is_in_grace_in_his
            ,case when subscription_period ='lifetime' then date_sub(current_date(),interval 0 day) else standard_order_expire_date end standard_order_expire_date
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where
            app_id = 'AirBrush'
            and order_status in (0,1,2)
            and event_date_hk=date_sub(current_date(),interval 1 day) -- 254165704
),
portrait AS (
    select user_pseudo_id
            ,first_active_date
        from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk=date_sub(current_date(),interval 1 day)
),
sub AS (
    select event_date,user_pseudo_id
       ,MAX(case when event_name='sub_suc' then 1 end) is_subscribe_today
       ,MAX(case when event_name='trial' then 1 end) is_trial_today
       ,MAX(case when event_name='trial_to_paid' then 1 end) is_trial_to_paid_today
       ,MAX(case when event_name='sub_suc' then sku end) today_sub_sku
       ,MAX(case when event_name='sub_suc' then sku_type end) today_sub_period
       ,MAX(case when event_name='sub_to_paid' then payment_price_usd end) today_sub_amt
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('sub_suc','sub_to_paid','trial','trial_to_paid')
    group by 1,2
),
-- 1. 基础活跃打标：计算当次活跃距离上一次活跃的间隔天数（用于后续求方差）
user_active_gaps AS (
    SELECT
        user_pseudo_id,
        event_date_hk,
        -- 计算距上一次活跃的天数差
        DATE_DIFF(event_date_hk, LAG(event_date_hk, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_date_hk), DAY) AS gap_days
    FROM active
),

-- 2. 近30天活跃指标计算模块 (非等值自连接 + 聚合)
active_30d_metrics AS (
    SELECT
        t1.user_pseudo_id,
        t1.event_date_hk,
        -- 近30天活跃天数
        COUNT(DISTINCT t2.event_date_hk) AS active_days_30d,
        -- 近30天活跃周数 (通过 年份*100 + 周数 拼接去重)
        COUNT(DISTINCT EXTRACT(ISOYEAR FROM t2.event_date_hk) * 100 + EXTRACT(ISOWEEK FROM t2.event_date_hk)) AS active_weeks_30d,
        -- 近30天活跃间隔的方差 (如果只有1天活跃则为0或NULL)
        VAR_POP(t2.gap_days) AS gap_variance_30d  -- STDDEV
    FROM user_active_gaps t1
    LEFT JOIN user_active_gaps t2
        ON t1.user_pseudo_id = t2.user_pseudo_id
        -- 核心限制：取过去29天到当天的记录
        AND t2.event_date_hk BETWEEN date_sub(t1.event_date_hk, interval 29 day) AND t1.event_date_hk
    where t1.event_date_hk between '2025-01-01' and '2025-12-31'
    GROUP BY
        t1.user_pseudo_id,
        t1.event_date_hk
),

-- 3. 订阅订单指标计算模块 (关联聚合)
order_metrics AS (
    SELECT
        a.user_pseudo_id,
        a.event_date_hk,
        -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
        MAX(CASE WHEN a.event_date_hk > o.standard_order_date  and a.event_date_hk <= o.standard_order_expire_date THEN 1 ELSE 0 END) AS is_subscribed,

        -- 当天订阅状态
--         MAX(CASE WHEN o.standard_order_date = a.event_date_hk AND o.subscription_user_type in ('intro_trial','trial','first_time_subscription','first_time_return_subscription') THEN 1 ELSE 0 END) AS is_subscribe_today,
--         SUM(CASE WHEN o.standard_order_date = a.event_date_hk AND o.subscription_user_type in ('intro_trial','trial','first_time_subscription','first_time_return_subscription') THEN o.payment_price_usd ELSE 0.0 END) AS today_sub_amt,
--         MAX(CASE WHEN o.standard_order_date = a.event_date_hk AND o.subscription_user_type in ('intro_trial','trial','first_time_subscription','first_time_return_subscription') THEN o.sku ELSE NULL END) AS today_sub_sku,
--         MAX(CASE WHEN o.standard_order_date = a.event_date_hk AND o.subscription_user_type in ('intro_trial','trial','first_time_subscription','first_time_return_subscription') THEN o.subscription_period ELSE NULL END) AS today_sub_period,

        -- 历史订阅次数与金额
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status = 0 THEN 1 ELSE 0 END) AS hist_trial_cnt,
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) THEN 1 ELSE 0 END) AS hist_pay_cnt,
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) AND o.subscription_period = '1-year' THEN 1 ELSE 0 END) AS hist_year_pay_cnt,
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) AND o.subscription_period = '1-year' THEN o.payment_price_usd ELSE 0.0 END) AS hist_year_pay_amt,
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) AND o.subscription_period = '1-month' THEN 1 ELSE 0 END) AS hist_month_pay_cnt,
        SUM(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) AND o.subscription_period = '1-month' THEN o.payment_price_usd ELSE 0.0 END) AS hist_month_pay_amt,

        -- 历史最近一次的过期时间 (在当前活跃日期之前产生的所有订单的过期时间取MAX)
        MAX(CASE WHEN o.standard_order_date < a.event_date_hk THEN o.standard_order_expire_date ELSE NULL END) AS recent_expire_date,
        MAX(CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2) THEN o.standard_order_expire_date ELSE NULL END) AS recent_expire_pay_date,
        split(
            MAX(
                CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2)
                THEN concat(CAST(o.standard_order_date AS STRING), '||', COALESCE(o.sku, ''))
                ELSE NULL END
            ),
            '||'
        )[SAFE_OFFSET(1)] AS recent_pay_sku,
        split(
            MAX(
                CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2)
                THEN concat(CAST(o.standard_order_date AS STRING), '||', COALESCE(o.subscription_period, ''))
                ELSE NULL END
            ),
            '||'
        )[SAFE_OFFSET(1)] AS recent_pay_period,
        CAST(
            split(
                MAX(
                    CASE WHEN o.standard_order_date < a.event_date_hk AND o.order_status in (1,2)
                    THEN concat(CAST(o.standard_order_date AS STRING), '||', COALESCE(CAST(o.payment_price_usd AS STRING), '0.0'))
                    ELSE NULL END
                ),
                '||'
            )[SAFE_OFFSET(1)]
        AS FLOAT64) AS recent_pay_amt,
        CAST(
            split(
                MAX(
                    CASE WHEN o.standard_order_date < a.event_date_hk
                    THEN concat(CAST(o.standard_order_expire_date AS STRING), '||', COALESCE(CAST(o.is_in_grace_in_his AS STRING), '0.0'))
                    ELSE NULL END
                ),
                '||'
            )[SAFE_OFFSET(1)]
        AS FLOAT64) AS recent_pay_grace,
FROM active a
    LEFT JOIN pay o
        ON a.uuid = o.uuid
    GROUP BY
        a.user_pseudo_id,
        a.event_date_hk
)

-- 4. 最终主表组装：以活跃表为主体，关联特征模块与画像表
SELECT
    a.event_date_hk AS active_date,                     -- 活跃日期
    a.user_pseudo_id,                                   -- 活跃用户id

    -- 订阅情况
    COALESCE(o.is_subscribed, 0) AS is_subscribed,      -- 当前是否订阅 (1=是, 0=否)
    COALESCE(s.is_subscribe_today, 0) AS is_subscribe_today,  -- 行为：当天是否花钱买订阅
    s.today_sub_sku,                                          -- 当天订阅的SKU
    case when s.today_sub_period='12m' then '1-year'
         when s.today_sub_period='1m' then '1-month'
         when s.today_sub_period='3m' then '3-month'
         when s.today_sub_period='weekly' then '1-week'
    else s.today_sub_period
    end today_sub_period,                                   -- 当天订阅的类型
    s.is_trial_today,
    s.is_trial_to_paid_today,
    s.today_sub_amt,                                        -- 当天订阅的总金额
    o.recent_pay_sku,                                       -- 历史最近一笔订单的SKU
    o.recent_pay_period,                                    -- 历史最近一笔订单的类型
    o.recent_pay_amt,                                       -- 历史最近一笔订单的金额
    o.recent_pay_grace,                                     -- 历史最近一笔订单的宽限期
    COALESCE(o.hist_trial_cnt, 0) AS hist_trial_cnt,        -- 历史试用次数
    COALESCE(o.hist_pay_cnt, 0) AS hist_pay_cnt,            -- 历史付费次数
    COALESCE(o.hist_year_pay_cnt, 0) AS hist_year_pay_cnt,  -- 历史年付费次数
    COALESCE(o.hist_year_pay_amt, 0.0) AS hist_year_pay_amt, -- 历史年付费金额
    COALESCE(o.hist_month_pay_cnt, 0) AS hist_month_pay_cnt, -- 历史月付费次数
    COALESCE(o.hist_month_pay_amt, 0.0) AS hist_month_pay_amt, -- 历史月付费金额
    o.recent_expire_date,                               -- 历史订阅过最近一次的过期时间
    o.recent_expire_pay_date,                           -- 历史付费过最近一次的过期时间

    -- 近30天活跃情况
    COALESCE(m.active_days_30d, 1) AS active_days_30d,  -- 近30天活跃天数
    COALESCE(m.active_weeks_30d, 1) AS active_weeks_30d,-- 近30天活跃周数
    m.gap_variance_30d, -- 近30天活跃天数间隔的方差

    -- 画像安装情况
    DATE_DIFF(a.event_date_hk, p.first_active_date, DAY) AS install_days -- 安装天数
FROM active a
LEFT JOIN portrait p
    ON a.user_pseudo_id = p.user_pseudo_id
LEFT JOIN active_30d_metrics m
    ON a.user_pseudo_id = m.user_pseudo_id
    AND a.event_date_hk = m.event_date_hk
LEFT JOIN order_metrics o
    ON a.user_pseudo_id = o.user_pseudo_id
    AND a.event_date_hk = o.event_date_hk
LEFT JOIN sub s
    ON a.user_pseudo_id = s.user_pseudo_id
    AND a.event_date_hk = s.event_date
where a.event_date_hk between '2025-01-01' and '2025-12-31'
;

with sub AS (
    select event_date,user_pseudo_id
       ,MAX(case when event_name='w_subscription_enter' then 1 end) is_sub_enter
       ,COUNT(case when event_name='w_subscription_enter' then 1 end) sub_enter_pv
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('w_subscription_enter')
    group by 1,2
)
-- 订阅前进入订阅页次数
select
    case when DATE_DIFF(active_date, recent_expire_date, DAY)<=30 then '1:1~30 expire'
--           when DATE_DIFF(active_date, recent_expire_date, DAY)<=90 then '2:31~90 expire'
        else '2:30+ expire' end expire_days_type
    ,case when coalesce(hist_pay_cnt,0)<=1 then cast(coalesce(hist_pay_cnt,0) as string)
        else '2:>=2' end hist_pay_cnt
    ,case when active_days_30d<=3 then '1:1~3 active days'
          when active_days_30d<=10 then '2:4~10 active days'
        else '3:>10 active' end active_days_30d
     ,case when sub_enter_pv<=2 then sub_enter_pv else 999 end sub_enter_pv
    ,count(1) uv
from dataintegration-265403.temp.winne_temp_pay_detail_type d
left join sub s
on d.active_date=s.event_date and d.user_pseudo_id=s.user_pseudo_id
where is_subscribed=0 and (hist_trial_cnt>0 or hist_pay_cnt>0)  -- 选取当前非订阅期，且历史有订阅过的用户
    and install_days>30
    and active_date between '2025-01-01' and '2025-12-31'
    and is_subscribe_today=1
group by 1,2,3,4

;
select
    case when DATE_DIFF(active_date, recent_expire_date, DAY)<=30 then '1:1~30 expire'
--           when DATE_DIFF(active_date, recent_expire_date, DAY)<=90 then '2:31~90 expire'
        else '2:30+ expire' end expire_days_type
    ,case when coalesce(hist_pay_cnt,0)<=1 then cast(coalesce(hist_pay_cnt,0) as string)
        else '2:>=2' end hist_pay_cnt
    ,case when active_days_30d<=3 then '1:1~3 active days'
          when active_days_30d<=10 then '2:4~10 active days'
        else '3:>10 active' end active_days_30d
     ,case when active_weeks_30d>=3 and round(gap_variance_30d)<=9 then 'continuous'
          when active_weeks_30d<=2 and round(gap_variance_30d)>=49 then 'intermittent'
        else 'else' end active_type
    ,count(1) uv
    ,count(case when s.is_sub_enter=1 then 1 end) sub_enter_uv
    ,count(case when is_subscribe_today=1 then 1 end) sub_uv
    ,count(case when coalesce(today_sub_amt,0)>0 then 1 end) pay_uv
from dataintegration-265403.temp.winne_temp_pay_detail_type d
left join sub s
on d.active_date=s.event_date and d.user_pseudo_id=s.user_pseudo_id
where is_subscribed=0 and (hist_trial_cnt>0 or hist_pay_cnt>0)  -- 选取当前非订阅期，且历史有订阅过的用户
    and install_days>30
    and active_date between '2025-01-01' and '2025-12-31'
group by 1,2,3,4

;

-- 比较本次订阅和上次的差别
select
    case when DATE_DIFF(active_date, recent_expire_date, DAY)<=30 then '1:1~30 expire'
--           when DATE_DIFF(active_date, recent_expire_date, DAY)<=90 then '2:31~90 expire'
        else '2:30+ expire' end expire_days_type
    ,case when coalesce(hist_pay_cnt,0)<=1 then cast(coalesce(hist_pay_cnt,0) as string)
        else '2:>=2' end hist_pay_cnt
    ,case when active_days_30d<=3 then '1:1~3 active days'
          when active_days_30d<=10 then '2:4~10 active days'
        else '3:>10 active' end active_days_30d
--      ,case when active_weeks_30d>=3 and round(gap_variance_30d)<=9 then 'continuous'
--           when active_weeks_30d<=2 and round(gap_variance_30d)>=49 then 'intermittent'
--         else 'else' end active_type
     ,today_sub_period,recent_pay_period
     ,if(today_sub_period=recent_pay_period,1,0) is_same_period
     ,case when (today_sub_amt-recent_pay_amt)/recent_pay_amt>=0.01 then 'more'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<0.01 and (today_sub_amt-recent_pay_amt)/recent_pay_amt>-0.01 then 'nearly_equal'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=-0.01 then 'less'
        end price_more_or_less
        ,case when (today_sub_amt-recent_pay_amt)/recent_pay_amt<-0.4 then '1:<-0.4'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=-0.3 then '2:-0.4~-0.3'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=-0.2 then '3:-0.3~-0.2'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=-0.1 then '4:-0.2~-0.1'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=-0.01 then '5:-0.1~-0.01'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=0.01 then '6:-0.01~0.01'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=0.1 then '7:0.01~0.1'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt<=0.3 then '8:0.1~0.3'
              when (today_sub_amt-recent_pay_amt)/recent_pay_amt>0.3 then '9:>0.3'
        end price_gap
    ,count(1) uv
    ,count(case when is_trial_today=1 then 1 end) trial_uv
    ,count(case when coalesce(today_sub_amt,0)>0 then 1 end) paid_uv
    ,count(case when is_trial_to_paid_today=1 then 1 end) trial_to_paid_uv
from dataintegration-265403.temp.winne_temp_pay_detail_type
where is_subscribed=0 and (hist_trial_cnt>0 or hist_pay_cnt>0)  -- 选取当前非订阅期，且历史有订阅过的用户
    and install_days>30
    and is_subscribe_today=1
    and active_date between '2025-01-01' and '2025-12-31'
group by 1,2,3,4,5,6,7,8
;

-- 宽限期
select
    count(1) uv
    ,count(case when recent_pay_grace=1 then 1 end) grace_uv
    ,count(case when is_subscribe_today=1 then 1 end) sub_uv
    ,count(case when coalesce(today_sub_amt,0)>0 then 1 end) pay_uv
from dataintegration-265403.temp.winne_temp_pay_detail_type d
where is_subscribed=0 and (hist_trial_cnt>0 or hist_pay_cnt>0)  -- 选取当前非订阅期，且历史有订阅过的用户
    and DATE_DIFF(active_date, recent_expire_date, DAY)<=30
    and active_days_30d>3
    and hist_pay_cnt>=2
    and active_date between '2025-01-01' and '2025-12-31'


-- 新指标3
-- 消耗付费积分
-- 批量替换 '2025-07-31' 为最新月末

with pay_credit as
(
    select distinct date_trunc(date, month) event_month,user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
    where credit_num>0 and date between '2022-11-01' and '2025-07-31'
)
,
-- 单购
credit_purchase as
(
    select
        event_date
        ,order_id
        ,user_id gid
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=1 -- 积分充值
        and app_name='BeautyPlus'
        and payment_price_usd>0
        and event_date between '2022-11-01' and '2025-07-31'
)
,
-- 订阅有效期用户
sub_status as
(
    select distinct original_order_id,order_id,uuid,event_month
    from beautyplus-bc0ed.temp.dws_aigc_sub_status_monthly m
)
,
-- 月活
active as
(
    select distinct date_trunc(event_date_hk, month) event_month,user_pseudo_id,gid,uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2022-11-01' and '2025-07-31'
)
,
-- 月活且 当月购买积分或订阅有效期
active_sub_or_purchase as
(
    select distinct event_month,'credit' type,user_pseudo_id
    from credit_purchase a
    join active b on a.gid=b.gid and date_trunc(a.event_date, month) = b.event_month

    union all

    select distinct a.event_month,'sub' type,user_pseudo_id
    from sub_status a
    join active b on a.uuid=b.uuid and a.event_month = b.event_month
)
,
-- 月活且 当月消耗积分或订阅有效期
active_sub_or_pay as
(
    select distinct a.event_month,'credit' type,a.user_pseudo_id
    from pay_credit a
    join active b on a.user_pseudo_id=b.user_pseudo_id and a.event_month = b.event_month

    union all

    select distinct a.event_month,'sub' type,user_pseudo_id
    from sub_status a
    join active b on a.uuid=b.uuid and a.event_month = b.event_month
)
,
-- （GenAI的生成）去重复人数（限制付费订阅）
use_pay as
(
    select distinct a.event_month,a.user_pseudo_id
    from
    (
        select distinct date_trunc(date, month) event_month, user_pseudo_id
        from `beautyplus-bc0ed.temp.dws_act_aigc_new`
            where action ='use' and date between '2022-11-01' and '2025-07-31'
            and function not in ('AI Zodiac Persona', 'AI Image Photo', 'BeautyPlus_AI V3', 'AI Pair Photo')
    ) a
    join (select * from active_sub_or_pay where type='sub') b
    on a.event_month=b.event_month and a.user_pseudo_id=b.user_pseudo_id

    union all

    select distinct date_trunc(date, month) event_month,user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
    where credit_num>0 and date between '2022-11-01' and '2025-07-31'
)

-- -- 指标3
-- select a.event_month,a.status_purchase_num,coalesce(b.use_num,0) use_num
-- from
-- (
--     select event_month,count(distinct user_pseudo_id) status_purchase_num
--     from active_sub_or_purchase
--     group by 1
-- ) a
-- left join
-- (
--     select event_month,count(distinct user_pseudo_id) use_num
--     from use_pay
--     group by 1
-- ) b
-- on a.event_month=b.event_month
-- 指标3_2
select a.event_month,a.status_pay_num,coalesce(b.use_num,0) use_num
from
(
    select event_month,count(distinct user_pseudo_id) status_pay_num
    from active_sub_or_pay
    group by 1
) a
left join
(
    select event_month,count(distinct user_pseudo_id) use_num
    from use_pay
    group by 1
) b
on a.event_month=b.event_month
order by 1
-- 其他指标
-- 续订
-- https://data.int.pixocial.com/bifrost/#/526
-- 新增
-- https://data.int.pixocial.com/bifrost/#/91

-- -- GenAI保存人数
-- select count(distinct user_pseudo_id) uv
-- from `beautyplus-bc0ed.temp.dws_act_aigc_new`
-- where action='save' and date between '2024-04-01' and '2025-07-31'





--行为
-- 批量替换 '2025-07-31' 为最新月末
-- 批量替换 '2025-07-01' 为最新月初

with pay_credit as
(
    select distinct date_trunc(date, month) event_month,user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
    where credit_num>0 and date between '2022-11-01' and '2025-07-31'
)
,
-- -- 单购
-- credit_purchase as
-- (
--     select
--         event_date
--         ,order_id
--         ,user_id gid
--         ,credit_num
--         ,payment_price_usd
--     from
--         `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
--     where
--         record_type=1 -- 积分充值
--         and app_name='BeautyPlus'
--         and payment_price_usd>0
--         and event_date between '2022-11-01' and '2025-07-31'
-- )
-- ,
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
-- -- 月活且 当月购买积分或订阅有效期
-- active_sub_or_purchase as
-- (
--     select distinct event_month,'credit' type,user_pseudo_id
--     from credit_purchase a
--     join active b on a.gid=b.gid and date_trunc(a.event_date, month) = b.event_month
--
--     union all
--
--     select distinct a.event_month,'sub' type,user_pseudo_id
--     from sub_status a
--     join active b on a.uuid=b.uuid and a.event_month = b.event_month
-- )
-- ,
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


-- select count(distinct a.user_pseudo_id) uv,sum(a.pv) pv
--         ,count(distinct c.user_pseudo_id) status_pay_and_ai_save_uv
-- from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
-- join `dataintegration-265403.stat.stat_active_advice_detail_d`  b
-- on a.event_date=b.event_date_hk and a.user_pseudo_id=b.user_pseudo_id
-- left join (select distinct user_pseudo_id from active_sub_or_pay where event_month='2024-05-01') c on a.user_pseudo_id=c.user_pseudo_id
-- -- where a.event_date between '2024-02-26' and '2024-02-26'
-- where a.event_date between '2024-05-01' and '2025-07-31'
--     and b.app_name = 'BeautyPlus'
--     and action='保存'
--     and (
--             (module='修图' and class = '美颜' and mark = 1)
--             or (module='拍摄' and class = '美颜' and mark = 1)
--             or (module='视频编辑' and class = '美颜' and mark = 1)
--             or (module='修图' and function in ('AI增强','AI扩展','照片修复','风格化','AI创意','消除笔','AR','抠图','去背景','虚化') and mark = 2)
--         )
--
--
-- select count(distinct a.user_pseudo_id) uv
--         ,count(distinct c.user_pseudo_id) status_pay_and_ai_save_uv
-- from
-- (
--     select distinct date_trunc(date, month) event_month, user_pseudo_id
--     from `beautyplus-bc0ed.temp.dws_act_aigc_new`
--         where action ='save' and date between '2024-05-01' and '2025-07-31'
-- ) a
-- left join (select distinct user_pseudo_id from active_sub_or_pay where event_month='2024-05-01') c on a.user_pseudo_id=c.user_pseudo_id
-- -- where a.event_date between '2024-02-26' and '2024-02-26'

-- 先跑完订阅有效期的表再跑这个
select a.event_month,count(distinct a.user_pseudo_id) uv,sum(pv) pv
        ,count(distinct c.user_pseudo_id) status_pay_and_ai_save_uv
from
(
    select date_trunc(a.event_date, month) event_month,a.user_pseudo_id,sum(pv) pv
    from
    (
        select event_date,user_pseudo_id,sum(pv) pv
        from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
        where event_date between '2025-07-01' and '2025-07-31'
            and action='保存'
            and (
                    (module='修图' and class = '美颜' and mark = 1)
                    or (module='拍摄' and class = '美颜' and mark = 1)
                    or (module='视频编辑' and class = '美颜' and mark = 1)
                    or (module='修图' and function in ('AI增强','AI扩展','照片修复','风格化','AI创意','消除笔','AR','抠图','去背景','虚化') and mark = 2)
                )
        group by 1,2

        union all

        select date event_date, user_pseudo_id,sum(pv) pv
        from `beautyplus-bc0ed.temp.dws_act_aigc_new`
        where action ='save'
            and date between '2025-07-01' and '2025-07-31'
        group by 1,2
    ) a
    join `dataintegration-265403.stat.stat_active_advice_detail_d`  b
    on a.event_date=b.event_date_hk and a.user_pseudo_id=b.user_pseudo_id
    where b.app_name = 'BeautyPlus'
    group by 1,2
) a
left join (select distinct event_month,user_pseudo_id from active_sub_or_pay where event_month between '2025-07-01' and '2025-07-31') c
on a.user_pseudo_id=c.user_pseudo_id and a.event_month=c.event_month
group by 1







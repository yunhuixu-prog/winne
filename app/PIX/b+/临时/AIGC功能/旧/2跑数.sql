-- 除新指标3
-- 消耗付费积分
-- 批量替换 '2025-07-31' 为最新月末
-- 最下面两段指标均需要用到上面的视图，跑一个的时候注释掉另外一个
with pay_credit as
(
    select distinct date_trunc(date, month) event_month,user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
    where credit_num>0 and date between '2022-11-01' and '2025-07-31'
)
,
first_pay_credit as
(
    select user_pseudo_id,date_trunc(min(date), month) first_event_month
    from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
    where credit_num>0 and date between '2022-11-01' and '2025-07-31'
    group by 1
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
        and credit_num>0
        and event_date between '2022-11-01' and '2025-07-31'
)
,
-- AIGC会员购买
sub as
(
    select a.*
    from
    (
        select distinct date_trunc(date, month) event_month, a.user_pseudo_id, payment_price_usd, order_id, original_order_id
    --     from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
        from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
    --     join `dataintegration-265403.stat.stat_active_advice_detail_d` b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =date and event_date_hk>='2022-12-01'
        where
        ( source2 in ('AIArt', 'AISketch', 'AI Motion Comic', 'AI Style Morph Pet', 'AI Extend_Custom', 'AI Extend_Original') or source2 like '%AIR%' or source2 like '%ai_portrait%' or source2 like '%ai_filter%')
        and event_name='subscription_try_suc'
        and standard_order_date is not null
        and purchase_date is not null
    --        and original_order_id=order_id
    --        and date between '2022-12-01' and '2025-07-31'
    ) a
    join
    (
         select order_id,'sub' period
         from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
         where app_id ='BeautyPlus'
         and order_status = 1
    ) b on a.order_id=b.order_id
)
,
-- aigc功能使用
use as
(
    select distinct date_trunc(date, month) event_month,user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_act_aigc_new`
    where action='use' and date between date_sub('2022-11-01',interval 1 month) and '2025-07-31'
--         and function not in ('AI Zodiac Persona','AI Image Photo','AI Pet Portray','BeautyPlus_AI V3','AI Pair Photo')

--     union all
--
--     select date,user_pseudo_id
--     from `beautyplus-bc0ed.temp.dws_credit_aigc_new`
--     where date between '2022-11-01' and '2025-07-31'
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
    select distinct event_month,user_pseudo_id
    from credit_purchase a
    join active b on a.gid=b.gid and date_trunc(a.event_date, month) = b.event_month

    union all

    select distinct a.event_month,user_pseudo_id
    from sub_status a
    join active b on a.uuid=b.uuid and a.event_month = b.event_month
)
,
-- 所有的订单续费情况
renewal_uv as
(
    select
    date_trunc(end_date, month) event_month,
    s.original_order_id,
--     ranks,
    uuid,
    if(next_start_date > start_date
    and next_start_date <= date_add(end_date,interval 1 day) and subscription_period = next_subscription_period,s.original_order_id,null)id1,
    if(next_start_date2 > start_date
    and next_start_date2 <= date_add(end_date,interval 1 day),s.original_order_id,null)id2
    from
    (
        select
        s1.standard_order_date start_date,
        s1.standard_order_expire_date end_date,
        lead(s1.standard_order_date) over(partition by s1.original_order_id order by s1.standard_order_date) as next_start_date,
--         row_number() over(partition by s1.original_order_id order by s1.standard_order_date) as ranks,
        lead(s1.standard_order_date) over(partition by s1.uuid order by s1.standard_order_date) as next_start_date2,
        lead(s1.subscription_period) over(partition by s1.original_order_id order by s1.standard_order_date) as next_subscription_period,
        s1.original_order_id,
        uuid,
        s1.platform,
        s2.fix_firebase_en_name country,
        s1.is_ua,
        s1.app_id,
        s1.subscription_period
        from
        (
            select *
            from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
            where order_status in (1,2)
            and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
            and offer_method = 'normal'
            and app_id='BeautyPlus'
        )s1
        left join
        (
            select distinct key, fix_firebase_en_name
            from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key
        )s2
        on s1.country = s2.key
    )s
)
,
-- aigc功能续费率
aigc_renewal as
(
    select r.event_month, s.original_order_id, s.user_pseudo_id, r.id1, r.id2
    from sub s
    join renewal_uv r on s.original_order_id=r.original_order_id
)
,
all_renewal_and_active as
(
    select distinct r.event_month, a.user_pseudo_id, r.id1, r.id2
    from renewal_uv r
    join active a
    on r.event_month=a.event_month and r.uuid=a.uuid
)

--指标1,2 : 全部的GenAI功能带来的会员购买人数,全部的GenAI功能带来的新增付费人数
select event_month
     ,sum(case when types='sub' then user_num end) sub_num
     ,sum(user_num) sub_credit_num
from
(
    select event_month,'sub' types,count(distinct user_pseudo_id) user_num,count(distinct original_order_id) order_num
    from sub
    group by 1

    union all

    select p.event_month,'credit' types,count(distinct p.user_pseudo_id) user_num,0 order_num
    from pay_credit p
    join first_pay_credit f on p.event_month=f.first_event_month and p.user_pseudo_id=f.user_pseudo_id
    group by 1
)
group by 1
order by 1
;
-- -- 指标3 : 当月活跃用户中处于会员状态或者当月单购过的用户数 ,（GenAI的生成）去重复人数
-- select a.event_month,a.status_num,coalesce(b.use_num,0) use_num
-- from
-- (
--     select event_month,count(distinct user_pseudo_id) status_num
--     from active_sub_or_purchase
--     group by 1
-- ) a
-- left join
-- (
--     select event_month,count(distinct user_pseudo_id) use_num
--     from use
--     group by 1
-- ) b
-- on a.event_month=b.event_month
-- ;
-- -- 指标5,6 : 之前通过 G enAI 功能的订阅在本月到期的用户数，之前通过 GenAI 功能的订阅在本月到期且续费的用户数，之前通过 GenAI 功能的订阅在本月到期且续费，同时上个月还使用过GenAI 功能 的用户数
-- select a.event_month,count(distinct a.user_pseudo_id) expire_num
--         ,count(distinct case when id2 is not null then a.user_pseudo_id end) renewal_num
--         ,count(distinct case when id2 is not null and b.user_pseudo_id is not null then a.user_pseudo_id end) renewal_and_use_num
-- from aigc_renewal a
-- left join use b on date_sub(a.event_month,interval 1 month)=b.event_month and a.user_pseudo_id=b.user_pseudo_id
-- -- where ranks=1
-- group by 1
-- order by 1;

-- 新指标6/指标7：本月使用过GenAI功能且本月会员到期用户数，满足分母条件且本月续费用户数
select a.event_month,count(distinct a.user_pseudo_id) expire_and_use_num
        ,count(distinct case when id2 is not null then a.user_pseudo_id end) renewal_and_use_num
-- from aigc_renewal a
from all_renewal_and_active a
join use b on a.event_month=b.event_month and a.user_pseudo_id=b.user_pseudo_id
group by 1
order by 1;




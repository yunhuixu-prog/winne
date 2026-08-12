
-- 额度管理页曝光人数及他们充值积分的均值标准差
select platform,round(sum(ab_num)/count(distinct event_date),0) ab_num
        ,round(sum(topup_num)/count(distinct event_date),0) topup_num
--         ,round(sum(sub_num)/count(distinct event_date),0) sub_num
        ,round(sum(credit_avg)/count(distinct event_date),4) credit_avg
        ,round(sum(credit_std)/count(distinct event_date),4) credit_std
from
(
select
    a.event_date,
    a.platform,
    count(distinct hwgid) ab_num,
    count(distinct user_id) topup_num,
    AVG(coalesce(credit_num,0)) as credit_avg,STDDEV(coalesce(credit_num,0)) credit_std
--     ,count(distinct uuid) sub_num
from
(
    select
        event_date
        ,platform
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-11-09','2023-12-09','beautyplus', false)
    where event_name in ('credit_page_bd')
    group by 1,2,3
) a
left join
(
    select
        event_date
        ,platform
        ,user_id
        ,sum(credit_num) credit_num
        ,sum(payment_price_usd) payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=1 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date between '2023-11-09' and '2023-12-09'
    group by
        1,2,3
) b
on a.event_date=b.event_date and a.platform=b.platform and a.hwgid=b.user_id
-- left join
-- (
--   select date,platform,uuid
--     from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
--     -- left join `dataintegration-265403.stat.dmi_dz_idmapping` b on a.uuid = b.uuid
--     where date>='2023-11-09' and date<='2023-12-09'
--         -- and platform='ANDROID'
--         -- and sub_user_type='4' --新用户
--         -- and country in ('South Korea', 'Thailand', 'Japan', 'United States')
--         and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
--     group by 1,2,3
-- ) c
-- on a.event_date=c.date and a.platform=c.platform and a.hwgid=c.uuid
group by 1,2
)
group by 1


-- 额度管理页曝光人数及他们充值积分的均值标准差
-- 匹配前一天还未订阅状态(后续加上这次不加了)
select platform,round(sum(ab_num)/count(distinct event_date),0) ab_num
        -- ,round(sum(topup_num)/count(distinct event_date),0) topup_num
        ,round(sum(sub_num)/count(distinct event_date),0) sub_num
        -- ,round(sum(credit_avg)/count(distinct event_date),4) credit_avg
        -- ,round(sum(credit_std)/count(distinct event_date),4) credit_std
from
(
select
    a.event_date,
    a.platform,
    count(distinct a.user_pseudo_id) ab_num,
    -- count(distinct user_id) topup_num,
    -- AVG(coalesce(credit_num,0)) as credit_avg,STDDEV(coalesce(credit_num,0)) credit_std,
    count(distinct c.user_pseudo_id) sub_num
from
(
    select
        event_date
        ,platform
        -- ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-11-09','2023-12-09','beautyplus', false)
    where event_name in ('credit_page_bd')
    group by 1,2,3
) a
-- left join
-- (
--     select
--         event_date
--         ,platform
--         ,user_id
--         ,sum(credit_num) credit_num
--         ,sum(payment_price_usd) payment_price_usd
--     from
--         `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
--     where
--         record_type=1 -- 积分消耗
--         and app_name='BeautyPlus'
--         and event_date between '2023-11-09' and '2023-12-09'
--     group by
--         1,2,3
-- ) b
-- on a.event_date=b.event_date and a.platform=b.platform and a.hwgid=b.user_id
left join
(
  select date,platform,user_pseudo_id
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
    -- left join `dataintegration-265403.stat.dmi_dz_idmapping` b on a.uuid = b.uuid
    where date>='2023-11-09' and date<='2023-12-09'
        -- and platform='ANDROID'
        -- and sub_user_type='4' --新用户
        -- and country in ('South Korea', 'Thailand', 'Japan', 'United States')
        and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    group by 1,2,3
) c
on a.event_date=c.date and a.platform=c.platform and a.user_pseudo_id=c.user_pseudo_id
group by 1,2
)
group by 1

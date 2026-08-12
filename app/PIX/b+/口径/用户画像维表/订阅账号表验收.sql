-- 目前问题 退订逻辑更改

select distinct event_date_hk
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-03-12' and '2024-03-12'
    and app_id='BeautyPlus'


-- 抽取单条记录查看和订单表查对

select *
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-03-12' and '2024-03-12'
    and app_id='BeautyPlus'
limit 10

select *
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where app_id='BeautyPlus'
    and order_status=0
    and standard_order_date='2024-02-01'
limit 10

-- uuid:574265491, 741198977, 642754733, 748811109, 299845614, 296018303
-- 299845614退订用户有问题
select *
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where app_id='BeautyPlus'
    and uuid='299845614'
--     and type='discount'
order by order_date


select *
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-01-01' and '2024-03-31'
    and app_id='BeautyPlus'
    and uuid='299845614'
order by event_date_hk

select *
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-01-01' and '2024-03-31'
    and app_id='BeautyPlus'
    and days_to_next_automatic_deduction!=current_subscription_expired_day
limit 10


-- 订阅开始天数+到期天数
select current_sub_sku_type
        ,coalesce(current_promotional_paying_period_day,current_standard_paying_type)+
        current_subscription_expired_day total_days
        ,count(1)
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk between '2024-03-12' and '2024-03-12'
    and app_id='BeautyPlus'
group by 1,2


-- 整体数据核对
select count(1),count(distinct uuid)
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where app_id='BeautyPlus'
    and order_status=0
    and standard_order_date='2024-03-12'

select count(1),count(distinct uuid)
from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
where event_date_hk = '2024-03-12'
    and app_id='BeautyPlus'
    and current_trial_day=0



-- past_sub_1year_sku_type_times 包括试用
-- promotional_paying_times 促销根据哪个字段确认的：type
-- current_promotional_paying_period_day 促销又是根据哪个字段确认的
-- valid_promotional_paying_day：包含未生效的时间，需要剔除
-- 取消次数是怎么判断的：






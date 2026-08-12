-- 订阅表逻辑
select *
FROM
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
 where original_order_id='420000485553421'
 order by order_date

-- 典型：420000485553421


select *
FROM
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
join
(
select distinct original_order_id
FROM
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
 where order_status in (0)
--  and offer_method like 'trial%'
-- and original_order_id=next_order_id
limit 1000
) b
on a.original_order_id=b.original_order_id
where a.order_status>=1


-- 统计的是首次订阅（即一个original order id中的第一个order id）的情况
-- 首次订阅人数，首次订阅付费人数（只包含一部分），首次订阅是试用人数，首次订阅是促销价付费人数，首次订阅是标准价付费人数等
-- 研究下sub_revenue365的逻辑(试用没有，只有订阅付费才有，和sub_revenue的区别：限制了订单时间是在一年内，要是看一年内的数据就没啥区别了)
select *
FROM
 `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_event_v4` a
join
(
select distinct original_order_id
FROM
 `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_event_v4`
 where order_status in (0)
--  and offer_method like 'trial%'
-- and original_order_id=next_order_id
limit 1000
) b
on a.original_order_id=b.original_order_id
where a.order_status>=1

select *
from `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_event_v4`
where original_order_id='500000747079873' --and sub_event in ('sub_revenue_365')
order by order_id

-- sub_revenue365



-- 统计的是首次订阅是试用/促销价的转化情况
`dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_cr_v4`



-- 预测表逻辑
-- 1.续订率计算（分不同期数）（仅包含周，月，季）
select *
from `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`
where standard_order_date='2021-10-16' and app_id='BeautyPlus' and is_UA='Organic' and country='India' and platform='IOS'
  and subscription_user_type='repeated_renewal' and subscription_period='1-month'
order by period

select distinct subscription_user_type,subscription_period
from `dataintegration-265403.roas_dataset_v4.dws_da_new_use_sub_rate_v4`
-- 那试用的续订率是啥，试用下subscription_period仍然是正价sku的时长不是试用时间

-- 2.用来计算付费率，如试用/混合试用/促销-标准价付费
select distinct subscription_period
from `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`



-- 3.订单id维度【订单日期，安装1年内】预测的付费率，价格，续订率，收入（仅包含周，月，季）
select original_order_id,count(distinct order_id) num
FROM
 `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4`
group by original_order_id
having num>2
limit 10

-- 举例（每一个order_id都会有）
select *
FROM
 `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_id_v4`
where original_order_id='GPA.3309-4341-4000-96178'
order by order_date


-- 4.计算每一天的预测收入（仅包含周，月，季）（当天开始的订单的预测收入相加+之前开始的订单且仍在订单有效期的订单的预测收入相加）
--  即当天在订单有效期的所有订单的预测收入
--  如果有退订咋办，哦不过这个是付费的状态，不存在退订，除非是退款
-- 指标：install_date,order_date
select *
FROM
 `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4`
limit 10


-- 5.install date（怎么有年的，年是不是就不预测了） - date 一段时间的订阅人数，订阅收入，[date，install+365]预测收入，无cost，install uv
select *
from `dataintegration-265403.roas_dataset_v4.dws_da_new_sub_ltv_v4`
-- from `dataintegration-265403.roas_dataset_v4.dws_da_ua_sub_ltv_v4`
limit 10

-- 6.加入新增用户uv
`dataintegration-265403.roas_dataset_v4.ads_da_new_install_sub_v4`
-- 7.加入cost
`dataintegration-265403.roas_dataset_v4.ads_da_new_roas_pre_v4`

-- 8.后续有按不同粒度汇总，日周月报（周报即投放日期看7天以上）

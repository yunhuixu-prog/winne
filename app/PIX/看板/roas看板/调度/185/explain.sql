-- 0`dataintegration-265403.user_ltv.dws_gather_new_retention_daily`
-- 和 1`dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`
-- 计算现有的 分国家/年月类型/订阅用户身份等 订阅日期，订阅人数，续订n期人数
-- 2python模型
-- 根据现有的预测 分国家/年月类型/订阅用户身份等 对数拟合参数，R2，及累计续订期数
-- 3`dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
-- 计算 分国家/年月类型/订阅用户身份等 每一期的续订率，生命周期内累计续订期数（max_LT），累计续订率（LT）
select *
from dataintegration-265403.user_ltv.dws_dz_new_forecast_retention
where date='2023-01-01' and app_id='BeautyPlus' and country='all'
and platform='ANDROID' and is_UA='all'
and subscription_user_type='first_time_subscription' and subscription_period='1-month'
order by period
-- 4`dataintegration-265403.user_ltv.dws_dz_new_ltv_id`
-- 计算每笔订单（首次订阅/首次回流订阅）实际/预测 365/终身 LTV，记录的orginal_order_id，date等都是首次订阅当天的，续费的不在


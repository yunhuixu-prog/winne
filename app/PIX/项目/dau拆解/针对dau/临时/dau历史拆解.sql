-- select app_name,event_date
--      ,count(distinct user_pseudo_id) dau
--      ,count(distinct case when is_paying='Paying' then user_pseudo_id end) paying_dau
--      ,count(distinct case when is_consum='consumables' then user_pseudo_id end) consume_dau
-- from `dataintegration-265403.temp.dau_type`
-- group by 1,2
-- order by 1,2


-- -- 单个用户测试
-- select *
-- from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
-- where date = '2023-03-05'
--     and is_paying='Paying' and sub_365>=1 and user_pseudo_id='43B9325479EF4A8E985C074594C52508'
--
-- select event_date_hk,app_name,user_pseudo_id,uuid --435157
--     from `dataintegration-265403.stat.stat_active_advice_detail_d`
--     where event_date_hk = '2023-03-05'
--         and app_name in ('BeautyPlus')  -- 'AirBrush',
--         and user_pseudo_id='43B9325479EF4A8E985C074594C52508'
--     group by 1,2,3,4
--
-- select
--         app_id app_name,uuid,standard_order_date,sum(payment_price_usd) sub_revenue
--     from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
--     where standard_order_date between '2023-03-05' and DATE_ADD('2023-03-05',interval 365 day)  -- 最多预测未来一年
--         and app_id in('BeautyPlus')
--         and order_status in (1,2)
--         and uuid='435157'  --656038150
-- group by 1,2,3
--
-- select
--         *
--     from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
--     where standard_order_date between '2023-03-05' and DATE_ADD('2023-03-05',interval 365 day)  -- 最多预测未来一年
--         and app_id in('BeautyPlus')
--         and order_status in (1,2)
--         and uuid='435157'
-- order by standard_order_date

-- 历史数据评估（一年/3个月前才能评估）
select app_name,date
     ,case when is_paying='paying' and is_consum='un-consumable' then 'now_only_sub'
           when is_paying='un-Paying' and is_consum='consumables' then 'now_only_consume'
           when is_paying='paying' and is_consum='consumables' then 'now_sub_consume'
           when is_paying='un-Paying' and is_consum='un-consumable' then 'now_nopaying'
     end types
     ,count(distinct user_pseudo_id) dau
     -- 当前收入指标
     ,round(sum(sub_revenue),2) now_sub_revenue
     ,round(sum(consum_revenue),2) now_consume_revenue
     ,round(sum(revenue),2) now_all_revenue
     -- 未来预测指标
     ,count(distinct case when sub_365>=1 then user_pseudo_id end) future_sub_dau_365
     ,count(distinct case when sub_365=0 then user_pseudo_id end) future_nosub_dau_365
     ,count(distinct case when credit_365>=1 then user_pseudo_id end) future_consume_dau_365
     ,count(distinct case when credit_365=0 then user_pseudo_id end) future_noconsume_dau_365
     ,round(sum(case when sub_revenue_365<=1000 then sub_revenue_365 end),2) future_sub_revenue_365
     ,round(sum(credit_revenue_365),2) future_consume_revenue_365

     ,count(distinct case when sub_90>=1 then user_pseudo_id end) future_sub_dau_90
     ,count(distinct case when sub_90=0 then user_pseudo_id end) future_nosub_dau_90
     ,count(distinct case when credit_90>=1 then user_pseudo_id end) future_consume_dau_90
     ,count(distinct case when credit_90=0 then user_pseudo_id end) future_noconsume_dau_90
     ,round(sum(case when sub_revenue_90<=500 then sub_revenue_90 end),2) future_sub_revenue_90
     ,round(sum(credit_revenue_90),2) future_consume_revenue_90

     ,round(sum(max_revenue_90),2) future_max_revenue_90

--      ,count(distinct case when is_current_pay=1 then user_pseudo_id end) paying_dau_1  -- 用的表只有24年后开始有数，无语
--      ,count(distinct case when is_current_consume=1 then user_pseudo_id end) consume_dau_1
-- select *
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
-- from airbrush-1324.temp.dws_dz_dau_split_final_user_behave
-- where date between '2024-01-01' and '2024-03-31' -- 用来对数
where (date between '2023-03-01' and '2023-03-31')
     or (date between '2024-01-01' and '2024-01-15')
--     and is_paying='Paying'
group by 1,2,3
order by 1,2,3


-- 加入试用逻辑
select app_name,date
     ,is_current_trial
     ,count(distinct user_pseudo_id) dau
     -- 当前收入指标
     ,round(sum(sub_revenue),2) now_sub_revenue
     ,round(sum(consum_revenue),2) now_consume_revenue
     ,round(sum(revenue),2) now_all_revenue
     -- 未来预测指标
     ,count(distinct case when sub_365>=1 then user_pseudo_id end) future_sub_dau_365
     ,count(distinct case when sub_365=0 then user_pseudo_id end) future_nosub_dau_365
     ,count(distinct case when credit_365>=1 then user_pseudo_id end) future_consume_dau_365
     ,count(distinct case when credit_365=0 then user_pseudo_id end) future_noconsume_dau_365
     ,round(sum(case when sub_revenue_365<=1000 then sub_revenue_365 end),2) future_sub_revenue_365
     ,round(sum(credit_revenue_365),2) future_consume_revenue_365

     ,count(distinct case when sub_90>=1 then user_pseudo_id end) future_sub_dau_90
     ,count(distinct case when sub_90=0 then user_pseudo_id end) future_nosub_dau_90
     ,count(distinct case when credit_90>=1 then user_pseudo_id end) future_consume_dau_90
     ,count(distinct case when credit_90=0 then user_pseudo_id end) future_noconsume_dau_90
     ,round(sum(case when sub_revenue_90<=500 then sub_revenue_90 end),2) future_sub_revenue_90
     ,round(sum(credit_revenue_90),2) future_consume_revenue_90

     ,round(sum(case when date>='2024-01-01' then max_revenue_90 end),2) future_max_revenue_90

--      ,count(distinct case when is_current_pay=1 then user_pseudo_id end) paying_dau_1  -- 用的表只有24年后开始有数，无语
--      ,count(distinct case when is_current_consume=1 then user_pseudo_id end) consume_dau_1
-- select *
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
-- from airbrush-1324.temp.dws_dz_dau_split_final_user_behave
where date between '2024-01-01' and '2024-01-15' -- 用来对数
-- where (date between '2023-03-01' and '2023-03-31')
--      or (date between '2024-01-01' and '2024-01-15')
    and is_paying='Un-Paying' and is_consum='Un-consumable'
group by 1,2,3
order by 1,2,3


-- select app_name,date
--      ,count(distinct user_pseudo_id) dau
--      -- 当前收入指标
--      -- 未来预测指标
--      ,round(sum(sub_revenue_365),2) future_sub_revenue_365
--      ,round(sum(case when sub_revenue_365<=200 then sub_revenue_365 end),2) future_sub_revenue_365
-- from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
-- -- where date between '2024-01-01' and '2024-03-31' -- 用来对数
-- where date between '2023-03-01' and '2023-03-31'
-- group by 1,2
-- order by 1,2

-- 我和静静完全一样，和军成的 paying差不太多，trial差很多
select app_name,date
     ,count(distinct user_pseudo_id) dau
     -- 当前收入指标
     -- 未来预测指标
     ,count(distinct case when is_paying='paying' then user_pseudo_id end) paying_dau --静静

     ,count(distinct case when is_current_pay=1 then user_pseudo_id end) paying_dau_1  -- 军成的表
     ,count(distinct case when is_current_sub=1 then user_pseudo_id end) paying_dau_2 -- 我算的

     ,count(distinct case when is_current_trial_pre=1 then user_pseudo_id end) trial_dau_1 -- 我算的
     ,count(distinct case when is_current_trial=1 then user_pseudo_id end) trial_dau_2  -- 军成的表

     ,count(distinct case when is_consum='consumables' then user_pseudo_id end) consume_dau --静静
     ,count(distinct case when is_current_consume=1 then user_pseudo_id end) consume_dau_1 -- 我算的
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave
where date between '2024-01-01' and '2024-03-31' -- 用来对数
-- where date between '2023-03-01' and '2023-03-31'
group by 1,2
order by 1,2



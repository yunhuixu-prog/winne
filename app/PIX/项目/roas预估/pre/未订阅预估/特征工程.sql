-- 放入模型的数据过滤调近7天未活跃的数据，评估好会有多少损失
-- 小于7天的数据
-- 活跃数据缺失情况(因为还未活跃，无活跃数据)
-- 主要是在第0天缺失，因为未安装，1-6天占比很少，可以直接过滤
-- 大于7天的数据
-- 未来会订阅的用户，7天后约有50%近7天无活跃数据，天数需要重新指定

select if(sub_no_trial_365>0,1,0) sub_no_trial_365,date_diff(date,Attributed_Touch_Date,DAY) days
     ,count(case when active_days is null or active_days=0 then 1 end)/count(1) not_active_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 --and date_diff(date,Attributed_Touch_Date,DAY)<=7
group by 1,2
order by 1,2


-- 天数选定逻辑-当前未订阅，未来会订阅的用户，近X天用户未活跃，未来用户会产生订阅行为的概率小于x
-- 取近31天，预测上限80%，后续再加一个近90天活跃吧

select last_active_days,count(1)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where sub_now=0 and sub_no_trial_365>0
group by 1
order by 1


-- 剔除近7天活跃无的其他指标缺失情况，算了看python吧
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 and active_days > 0
limit 10

-- 近7天
-- 样本平衡比例
select
    date_diff(date,Attributed_Touch_Date,DAY) days,
--      round(count(case when sub_no_trial_365>0 then 1 end)/count(1),4) sub_ratio,
--      round(count(case when sub_no_trial_365=0 then 1 end)/count(1),4) nosub_ratio,
     round(count(case when sub_no_trial_365>0 then 1 end)/count(case when sub_no_trial_365=0 then 1 end),4) sub_nosub_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 7
group by 1
order by 1


-- 寻找初步筛选范围(get_out_ratio近可能小)(可以用or叠加看一下条件，python看一下相关系数吧)
select date_diff(date,Attributed_Touch_Date,DAY) days
     -- ,round(count(case when last_active_days<=31 then 1 end)/count(1),2) get_ratio
    --  ,round(count(case when sub_page_enter>0 then 1 end)/count(1),2) get_ratio
     ,round(count(case when (date_diff(date,Attributed_Touch_Date,DAY)<=6 and sub_page_enter>0)
                        or (date_diff(date,Attributed_Touch_Date,DAY)>=7 and active_days>0)
                then 1 end)/count(1),2) get_ratio
--      ,round(count(case when last_active_days>31 then 1 end)/count(1),2) get_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0 and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 7
group by 1
order by 1
-- 剔除后样本平衡比例
select
--     date_diff(date,Attributed_Touch_Date,DAY) days,
--      round(count(case when sub_no_trial_365>0 then 1 end)/count(1),4) sub_ratio,
--      round(count(case when sub_no_trial_365=0 then 1 end)/count(1),4) nosub_ratio,
     round(count(case when sub_no_trial_365>0 then 1 end)/count(case when sub_no_trial_365=0 then 1 end),4) sub_nosub_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0
    and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 7
    and ((date_diff(date,Attributed_Touch_Date,DAY)<=6 and sub_page_enter>0)
                        or (date_diff(date,Attributed_Touch_Date,DAY)>=7 and active_days>0))
-- group by 1
-- order by 1



-- final目的：每天需要放入的样本太多，airflow读取不了
-- 指标：1.筛掉后有多少数据；2.筛掉的用户有多少未来是会订阅的
select if(sub_no_trial_365>0,1,0),count(1)
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
    where Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 547 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
            and sub_now=0
            and last_active_days<=31
)
group by 1
order by 1
;
select date_diff(date,Attributed_Touch_Date,DAY) days
     ,count(1) pv_all,round(sum(sub_revenue_365),2) revenue_all
     ,round(count(case when last_active_days<=90 then 1 end)/count(1),4) last_active_days_get_uv_ratio
     ,round(sum(case when last_active_days<=90 then sub_revenue_365 end)/sum(sub_revenue_365),4) last_active_days_get_revenue_ratio

--      ,round(count(case when active_days_31d>2 then 1 end)/count(1),4) active_days_31_get_uv_ratio
--      ,round(sum(case when active_days_31d>2 then sub_revenue_365 end)/sum(sub_revenue_365),4) active_days_31_get_revenue_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
where Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 547 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0
        and sub_no_trial_365>0
group by 1
order by 1
;
-- sub_revenue_365分布
select case when sub_revenue_365<=10 then '<=10'
            when sub_revenue_365<=50 then '<=50'
            when sub_revenue_365<=100 then '<=100'
            when sub_revenue_365<=150 then '<=150'
        else '>150'
        end type,count(1)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
where Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 547 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0
        and sub_no_trial_365>0
group by 1

-- 数据预处理
-- 缺失情况以及缺失值填充
-- 数值型分段处理
--


-- 组合指标
-- 1.pay_duffle_click_pv/(pay_duffle_click_pv+free_duffle_click_pv)
-- 2.



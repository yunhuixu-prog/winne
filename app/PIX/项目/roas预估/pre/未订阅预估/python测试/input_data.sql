-- 量级
select date_diff(date,Attributed_Touch_Date,DAY) days
  ,count(distinct user_pseudo_id) num
  ,count(distinct case when sub_now=0 and sub_no_trial_365>0 then user_pseudo_id end) nosub_futuresub_num
  ,count(distinct case when sub_now=0 and sub_no_trial_365=0 then user_pseudo_id end) nosub_futurenosub_num
  ,count(distinct case when sub_now>0 and is_sub_now=0 then user_pseudo_id end) sub_nownosub_num
  ,count(distinct case when sub_now>0 and is_sub_now=1 then user_pseudo_id end) sub_nowsub_num

from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
group by 1
order by 1


-- 训练数据（有偏）
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0

    union all

    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0
    and rand()<0.01
)
group by 1

-- 训练数据（有偏）（分安装天数）
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0 and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6

    union all

    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0 and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
    and rand()<0.04
)
group by 1


-- 训练数据（无偏）（模型效果差，不知道是不是正样本不够的原因，但是不能全放进去啊啊啊啊啊啊啊）
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0 and date_diff(date,Attributed_Touch_Date,DAY)<=7
    and rand()<0.1

    union all

    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0 and date_diff(date,Attributed_Touch_Date,DAY)<=7
    and rand()<0.1
)
group by 1


-- 训练数据（对称）
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-04-30' and sub_now=0 and sub_no_trial_365>0 and date_diff(date,Attributed_Touch_Date,DAY)<=7

    union all

    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-04-30' and sub_now=0 and sub_no_trial_365=0 and date_diff(date,Attributed_Touch_Date,DAY)<=7
    and rand()<0.005
)
group by 1



-- 评估数据（初筛使得尽量平衡一些）
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
    select *
         ,date_diff(date,Attributed_Touch_Date,DAY) days
         ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
               else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
         end pay_duffle_click_ratio
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where Attributed_Touch_Date='2023-01-01' and sub_now=0 and sub_no_trial_365>0
--     and date_diff(date,Attributed_Touch_Date,DAY)<=7
    and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
    and last_active_days<=31
)
group by 1;


-- 量级查看
select days,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where Attributed_Touch_Date='2023-01-01'
    and sub_now=0
    and date_diff(date,Attributed_Touch_Date,DAY)>7 and date_diff(date,Attributed_Touch_Date,DAY)<=90
)
group by 1
order by 1

select days,count(1)
from
(
    select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-04-30' and sub_now=0 and sub_no_trial_365>0
)
group by 1
order by 1




-- final
select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
select *
    ,date_diff(date,Attributed_Touch_Date,DAY) days
    ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
       else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
 end pay_duffle_click_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0
and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6

union all

select *
    ,date_diff(date,Attributed_Touch_Date,DAY) days
    ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
       else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
 end pay_duffle_click_ratio
from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0
and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
and rand()<0.04
)
group by 1


select if(sub_no_trial_365>0,1,0) sub_no_trial_365,count(1)
from
(
select *
    ,date_diff(date,Attributed_Touch_Date,DAY) days
    ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
       else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
 end pay_duffle_click_ratio
from `airbrush-1324.temp.dws_dz_roi_predict_model_input`
where date<='2023-06-30' and sub_now=0 and sub_no_trial_365>0
and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
and rand()<0.1

union all

select *
    ,date_diff(date,Attributed_Touch_Date,DAY) days
    ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
       else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
 end pay_duffle_click_ratio
from `airbrush-1324.temp.dws_dz_roi_predict_model_input`
where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0
and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
and rand()<0.004
)
group by 1





-- 选择用户
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
where active_days>5 and `pv_0级tab-修图---保存`>0
limit 10

-- 匹配到firebaseid的用户
-- `airbrush-1324.temp.dws_dz_roi_predict_0_goal_users`
select Attributed_Touch_Date,count(1)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
group by 1
order by 1
;

-- `airbrush-1324.temp.dws_dz_roi_predict_first_week_user_behave`
select Attributed_Touch_Date,date,count(1)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
group by 1,2
order by 1,2
;
select date,count(distinct Attributed_Touch_Date)
-- select Attributed_Touch_Date,count(distinct date)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
group by 1
order by 1
;
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
where user_pseudo_id='86308112BD6C41FA91A62AEBF1D2C1A3'
order by date
;

-- `airbrush-1324.temp.dws_dz_roi_predict_now_user_behave`
select Attributed_Touch_Date,date,count(1)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave
group by 1,2
order by 1,2
;
select date,count(distinct Attributed_Touch_Date)
-- select Attributed_Touch_Date,count(distinct date)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave
group by 1
order by 1
;
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave
where user_pseudo_id='86308112BD6C41FA91A62AEBF1D2C1A3'
order by date
;

-- `airbrush-1324.temp.dws_dz_roi_predict_now_user_sub`
select types,Attributed_Touch_Date,count(distinct date),count(1),count(distinct user_pseudo_id),sum(sub_revenue_now),sum(sub_revenue_365)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
where Attributed_Touch_Date between '2024-03-01' and '2024-03-24' and date='2024-03-24'
group by 1,2
order by 1,2
;
select date,count(distinct Attributed_Touch_Date)
-- select Attributed_Touch_Date,count(distinct date)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
group by 1
order by 1
;
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
where user_pseudo_id='8FC261C2245F4AA5AC2A8950676F09D5'  -- 8FC261C2245F4AA5AC2A8950676F09D5(10个月后才订阅) 57B906E179BA460FB114B6B0E9B5B8BB
order by date
;

-- `airbrush-1324.temp.dws_dz_roi_predict_model_input_1`
select Attributed_Touch_Date,date,count(1),count(distinct user_pseudo_id)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
group by 1,2
order by 1,2
;
select date,count(distinct Attributed_Touch_Date)
-- select Attributed_Touch_Date,count(distinct date)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
group by 1
order by 1
;
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
where user_pseudo_id='86308112BD6C41FA91A62AEBF1D2C1A3'
order by date
;


-- 模型输出
select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_sample_evaluate_test
order by days



select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_sample_evaluate
order by days


select distinct date,Attributed_Touch_Date
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
order by 1,2


select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
where Attributed_Touch_Date between '2023-03-19' and '2023-03-19'


select days,sum(predict_sub_revenue_365),sum(sub_revenue_365),sum(predict_sub_revenue_365)/sum(sub_revenue_365)-1
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
group by 1
order by 1


-- 模型放入样本量估计
 select if(sub_no_trial_365>0,1,0),count(1)
 from
 (
    select *,0 random
        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
        where Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
            and sub_now=0 and sub_no_trial_365>0

        union all

        select *,rand() random
        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
        where Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
            and sub_now=0 and sub_no_trial_365=0
            and rand()<0.004 -- 可以调整
 )
 group by 1
;

 select if(sub_no_trial_365>0,'sub','no sub'),if(days between 0 and 6,'0-6','7-365'),count(1)
 from
 (
    select *,0 random
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6

    union all

    select *,0 random
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
        and rand()<0.05

    union all

    select *,rand() random
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
        and rand()<0.04 -- 可以调整

    union all

    select *,rand() random
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and Attributed_Touch_Date between DATE_SUB('2024-03-20', INTERVAL 458 DAY) and DATE_SUB('2024-03-20', INTERVAL 365 DAY)
        and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
        and rand()<0.002 -- 可以调整
 )
 group by 1,2
;

 -- 需要预测的的样本量把控
select if(sub_no_trial_365>0,1,0),count(1)
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and Attributed_Touch_Date = DATE_SUB('2024-03-20', INTERVAL 1+365 DAY)
            and sub_now=0 and days >= 7*0 and days < 7*(0+1)
)
group by 1
;
select if(sub_no_trial_365>0,1,0),count(1)
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='ua' and date = DATE_SUB('2024-03-23', INTERVAL 0 DAY)
            and sub_now=0 and days >= 30*11 and days < 30*(11+1)
)
group by 1
;

select if(sub_no_trial_365>0,1,0),count(1)
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='new' and Attributed_Touch_Date = DATE_SUB('2024-03-20', INTERVAL 0+365 DAY)
            and sub_now=0 and days >= 7*0 and days < 7*(0+1)
)
group by 1
;
select if(sub_no_trial_365>0,1,0),count(1)
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
    where types='new' and date = DATE_SUB('2024-03-23', INTERVAL 0 DAY)
            and sub_now=0 and days >= 7*0 and days < 7*(0+1)
)
group by 1
;


-- 预测效果评估（评估前先统一thred的值吧）
select days,num,sub_revenue_365,predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else predict_sub_revenue_365/sub_revenue_365
  end predict_suc
from
(
  select days,count(1) num,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
--   from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
--   from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
  from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
  group by 1
)
order by 1
;
select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
where user_pseudo_id='1EE7F0B5DC5245B48A9E770D68D45F12' --d13410309e029561a2791efbc3a98d35
order by days
;
select *
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input
where user_pseudo_id='1EE7F0B5DC5245B48A9E770D68D45F12'
order by date
;
select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_sample_evaluate_test
order by days

-- 重制预测表
select distinct Attributed_Touch_Date
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
;
delete from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
                        where Attributed_Touch_Date = '2023-01-15'

-- ab
 select if(sub_no_trial_365>0,1,0),count(1)
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
        and rand()<0.5

        union all

        select *
            ,date_diff(date,Attributed_Touch_Date,DAY) days
            ,case when free_duffle_click_pv is null and pay_duffle_click_pv is null then null
               else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
         end pay_duffle_click_ratio
        from `airbrush-1324.temp.dws_dz_roi_predict_model_input`
        where date<='2023-06-30' and sub_now=0 and sub_no_trial_365=0
        and date_diff(date,Attributed_Touch_Date,DAY) between 1 and 6
        and rand()<0.001
 )
 group by 1


-- final
select types,App_Name,Attributed_Touch_Date,date,user_pseudo_id,count(1)
from `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV`
group by 1,2,3,4,5
having count(1)>1

select types,App_Name,Attributed_Touch_Date,date,count(distinct user_pseudo_id),sum(predict_sub_revenue_365),sum(predict_sub_revenue)
from `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV`
-- where date between '2024-04-01' and '2024-04-10'
-- where Attributed_Touch_Date between '2023-03-19' and '2023-03-20'
where date between '2024-04-10' and '2024-04-18' and Attributed_Touch_Date between '2024-04-01' and '2024-04-18'
    and types='ua' and App_Name='BeautyPlus'
group by 1,2,3,4
order by 1,2,3,4

select Attributed_Touch_Date,date,sum(predict_sub_revenue_365)
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
-- from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
-- from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue
-- from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
-- where Attributed_Touch_Date between '2023-03-19' and '2023-03-20'
where date between '2024-04-10' and '2024-04-18' and Attributed_Touch_Date between '2024-04-01' and '2024-04-18'
group by 1,2
order by 1,2

select Attributed_Touch_Date,date,user_pseudo_id,count(1)
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
-- from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
-- from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue
-- from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
-- where Attributed_Touch_Date between '2023-03-19' and '2023-03-20'
where date between '2024-04-10' and '2024-04-18' and Attributed_Touch_Date between '2024-04-01' and '2024-04-18'
group by 1,2,3
having count(1)>1

select count(distinct user_pseudo_id)
  ,count(distinct case when predict_sub_revenue_365>0 then user_pseudo_id end)
  ,sum(predict_sub_revenue_365)
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
where date = '2024-04-10' and Attributed_Touch_Date = '2024-04-10'
-- and predict_sub_revenue_365>0

select *
from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
where date = '2024-04-14'
     and days = 357 and user_pseudo_id='CFF034811FFF4C2390081CD9BBF2FA31'
-- and predict_sub_revenue_365>0


select types,Attributed_Touch_Date,date,sum(sub_revenue_365)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
where Attributed_Touch_Date between '2023-03-19' and '2023-03-20' and sub_now=0
    and types='ua'
group by 1,2,3
order by 1,2,3



-- 一年内订阅天数分布情况（限制一年内订阅的用户）

select pay_day,count(distinct user_pseudo_id) num
from
(
    select Attributed_Touch_Date,user_pseudo_id,max(date_diff(date,Attributed_Touch_Date,DAY))+2 pay_day
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
    where types='new' and Attributed_Touch_Date between '2023-01-01' and '2023-04-01'
        and sub_365>0 and sub_now=0
    group by 1,2

    union all

    select Attributed_Touch_Date,user_pseudo_id,1 pay_day
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
    where types='new' and Attributed_Touch_Date between '2023-01-01' and '2023-04-01'
        and sub_365>0 and date_diff(date,Attributed_Touch_Date,DAY)=0 and sub_now>0
    group by 1,2
)
group by 1
order by 1

-- 安装天数订阅比例
-- 总人数
select count(distinct user_pseudo_id)
from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
where types='new' and Attributed_Touch_Date between '2023-01-01' and '2023-04-01'
    and date_diff(date,Attributed_Touch_Date,DAY)=0
-- group by 1,2


-- 留存
select count(distinct user_pseudo_id) total_num
     ,count(distinct case when is_retain_7_14>0 then user_pseudo_id end) retain_7_14_num
     ,count(distinct case when is_retain_7_14=0 then user_pseudo_id end) no_retain_7_14_num
from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
where types='new' and Attributed_Touch_Date between '2023-01-01' and '2023-04-01'
    and date_diff(date,Attributed_Touch_Date,DAY)=0



-- 进入数据
select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where sub_no_trial_7>0
            and rand()<1 and days = 2 and sub_now = 0

        union all

        select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where sub_no_trial_7=0
            and rand()<0.00015 and days = 2 and sub_now = 0


select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where is_retain_7_14>0
            and rand()<1 and days = 2


        union all

        select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where is_retain_7_14=0
            and rand()<0.00015 and days = 2


select if(is_retain_7_14>0,1,0),count(1)
from
(
select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where is_retain_7_14>0 and Attributed_Touch_Date between '2024-03-01' and '2024-04-01'
            and rand()<0.05
            and days = 2


        union all

        select *except(user_pseudo_id)
        from beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
        where is_retain_7_14=0 and Attributed_Touch_Date between '2024-03-01' and '2024-04-01'
            and rand()<0.05
            and days = 2
)
group by 1


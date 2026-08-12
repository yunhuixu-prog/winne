-- 汇总
select date_trunc(event_date, month) event_date
    ,a.platform
    ,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
    ,sum(DAU) DAU
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    event_date between '2023-01-01' and '2025-12-31'
group by
    1,2,3,4,5

;
-- 一级归因
select date_trunc(event_date, month) event_date
    ,platform
--     ,is_new,is_ua
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country
    ,first
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2023-01-01' and '2025-12-31'
    and category='First Source'
--     and first='Edit'
group by 1,2,3,4 --,5,6


;
-- 二级归因
select date_trunc(event_date, month) event_date
    ,platform
--     ,is_new,is_ua
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country
    ,first
    ,second
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2023-01-01' and '2025-12-31'
    and category='Second Source'
--     and first='Else'  -- Else,Edit
--     and second='Onboarding'
group by 1,2,3,4,5 --,6,7


;
-- 三级归因
select date_trunc(event_date, month) event_date
    ,platform
--     ,is_new,is_ua
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country
    ,first
    ,second
    ,third
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2023-01-01' and '2025-12-31'
    and category='Third Source'
    and first='Edit'  -- Else,Edit
    and second in ('Material','Retouch','Edit')
group by 1,2,3,4,5,6 --,7,8


;
-- 四级归因
select date_trunc(event_date, month) event_date
    ,platform
--     ,is_new,is_ua
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country
    ,first
    ,second
    ,third
    ,fourth
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2023-01-01' and '2025-12-31'
    and category='Fourth Source'
    and first='Edit'  -- Else,Edit
    -- and second='Retouch' --Retouch,Material,Edit
    and third in ('Reshape','Resize','Eraser') -- Makeup,Muscle,Hair
group by 1,2,3,4,5,6,7 --,8,9
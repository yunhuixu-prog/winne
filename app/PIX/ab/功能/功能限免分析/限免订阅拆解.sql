-- 汇总
select event_date
    ,case when event_date between '2025-08-29' and '2025-09-04' then '1:0829~0904'
          when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,a.platform,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
    ,sum(DAU) DAU
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    event_date between '2025-08-29' and '2025-09-18'
group by
    1,2,3,4,5,6


;
-- 一级归因
select event_date
    ,case when event_date between '2025-08-29' and '2025-09-04' then '1:0829~0904'
          when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,platform,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,first
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2025-08-29' and '2025-09-18'
    and category='First Source'
--     and first='Edit'
group by 1,2,3,4,5,6,7


;
-- 二级归因
select event_date
    ,case when event_date between '2025-08-29' and '2025-09-04' then '1:0829~0904'
          when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,platform,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,first
    ,second
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2025-08-29' and '2025-09-18'
    and category='Second Source'
--     and first='Else'  -- Else,Edit
--     and second='Onboarding'
group by 1,2,3,4,5,6,7,8


;
-- 三级归因
select event_date
    ,case when event_date between '2025-08-29' and '2025-09-04' then '1:0829~0904'
          when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,platform,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,first
    ,second
    ,third
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2025-08-29' and '2025-09-18'
    and category='Third Source'
    and first='Edit'  -- Else,Edit
    and second='Material' --Retouch,Material,Edit
group by 1,2,3,4,5,6,7,8,9


;
-- 四级归因
select event_date
    ,case when event_date between '2025-08-29' and '2025-09-04' then '1:0829~0904'
          when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,platform,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,first
    ,second
    ,third
    ,fourth
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2025-08-29' and '2025-09-18'
    and category='Fourth Source'
    and first='Edit'  -- Else,Edit
    and second='Retouch' --Retouch,Material,Edit
    and third in ('Hair') -- Makeup,Muscle,Hair
group by 1,2,3,4,5,6,7,8,9,10

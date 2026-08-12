drop table if exists `dataintegration-265403.temp.winne_temp_cuxiao_source`;
create table if not exists `dataintegration-265403.temp.winne_temp_cuxiao_source` as

with eves_pre as (
    select event_date,user_pseudo_id,platform,event_name,duration,payment_price_usd
        ,first,second,third,fourth
    from `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
    where
        (
            (event_date between '2025-12-29' and '2026-01-04') -- 24，周日-周六
            or (event_date between '2025-12-22' and '2025-12-28') -- 25，周一-周日
            or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
        )
)
,user_info as
(
    select distinct
        event_date
        ,platform,is_new,is_ua,country
        ,is_paying,install_days
        ,user_pseudo_id
    from dataintegration-265403.temp.winne_temp_day_type_2
    where
        (
            (event_date between '2025-12-29' and '2026-01-04') -- 24，周日-周六
            or (event_date between '2025-12-22' and '2025-12-28') -- 25，周一-周日
            or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
        )
)

select e.*,u.is_new,u.is_ua,u.country,u.is_paying,u.install_days
from eves_pre e
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date and e.platform=u.platform
;



select date_label,platform
    ,is_new,is_ua
--     ,country
    ,is_paying,first,second
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_click_uv) sub_click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_success_to_paid_uv) sub_success_to_paid_uv
    ,round(sum(sub_success_to_paid_gmv),2) sub_success_to_paid_gmv
from
(
    select
        event_date,
        case
            when event_date between '2025-12-29' and '2026-01-04' then '25 新年'
            when event_date between '2025-12-22' and '2025-12-28' then '25 圣诞'
            when event_date between '2025-12-15' and '2025-12-21' then '25 Benchmark'
        end date_label
        ,platform
        ,is_new,is_ua
        ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
        ,is_paying
        ,case when install_days<=30 then '1:1~30'
            when install_days<=180 then '2:31~180'
            when install_days<=365 then '3:181~365'
            else '4:365+'
        end install_days_type
        ,CASE
            WHEN first in ('Edit','Operations') THEN first
            ELSE 'Else'
        END first
        ,'All' second
        ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name ='w_subscription_click' then user_pseudo_id end) sub_click_uv
        ,count(distinct case when event_name ='sub_suc' then user_pseudo_id end) sub_success_uv
        ,count(distinct case when event_name ='sub_to_paid' then user_pseudo_id end) sub_success_to_paid_uv
        ,sum(case when event_name = 'sub_to_paid' then payment_price_usd else 0 end) sub_success_to_paid_gmv
    from dataintegration-265403.temp.winne_temp_cuxiao_source
    where
        (
            (event_date between '2025-12-29' and '2026-01-04') -- 24，周日-周六
            or (event_date between '2025-12-22' and '2025-12-28') -- 25，周一-周日
            or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
        )
        and first!='A' and second='A'
    group by 1,2,3,4,5,6,7,8,9,10

    union all

    select
        event_date,
        case
            when event_date between '2025-12-29' and '2026-01-04' then '25 新年'
            when event_date between '2025-12-22' and '2025-12-28' then '25 圣诞'
            when event_date between '2025-12-15' and '2025-12-21' then '25 Benchmark'
        end date_label
        ,platform
        ,is_new,is_ua
        ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
        ,is_paying
        ,case when install_days<=30 then '1:1~30'
            when install_days<=180 then '2:31~180'
            when install_days<=365 then '3:181~365'
            else '4:365+'
        end install_days_type
        ,CASE
            WHEN first in ('Edit','Operations') THEN first
            ELSE 'Else'
        END first
        ,CASE
            WHEN first in ('Edit') and second in ('Retouch','Edit','Material') THEN third
            WHEN first in ('Edit') and second in ('hpp','sub_to_guide') THEN second
            WHEN first in ('Operations') THEN second
            WHEN first in ('Else') and second in ('p_onboarding','p_update_first_launch','home_sub_banner') then second
            ELSE 'Else'
        END second
        ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name ='w_subscription_click' then user_pseudo_id end) sub_click_uv
        ,count(distinct case when event_name ='sub_suc' then user_pseudo_id end) sub_success_uv
        ,count(distinct case when event_name ='sub_to_paid' then user_pseudo_id end) sub_success_to_paid_uv
        ,sum(case when event_name = 'sub_to_paid' then payment_price_usd else 0 end) sub_success_to_paid_gmv
    from dataintegration-265403.temp.winne_temp_cuxiao_source --,unnest(split(source_00,',')) s
    where
        (
            (event_date between '2025-12-29' and '2026-01-04') -- 24，周日-周六
            or (event_date between '2025-12-22' and '2025-12-28') -- 25，周一-周日
            or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
        )
        and first!='A' and second!='A' and (third!='A' or third is null) and fourth='A'
    group by 1,2,3,4,5,6,7,8,9,10
)
group by 1,2,3,4,5,6,7


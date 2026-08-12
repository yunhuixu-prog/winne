-- YAU及arpdau(废弃，重新算，但是暂时不需要丫的浪费时间)
with active AS (
    select app_name,
            event_date_hk
            ,platform
            ,user_pseudo_id
            ,uuid
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            -- 含年末+1天，便于计算当日活跃用户的「次日是否仍活跃」
            event_date_hk between '2025-01-01' and date_add('2025-12-31', interval 1 day)
            and app_name = 'AirBrush'
        group by 1,2,3,4,5
),
pay AS (
    select
        standard_order_date,uuid,sum(payment_price_usd) payment
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where
        app_id = 'AirBrush'
        and order_status in (0,1,2)
        and event_date_hk=date_sub(current_date(),interval 1 day)
        and standard_order_date between '2025-01-01' and '2025-12-31'
    group by 1,2
)

select 
    a.country,a.platform,a.install_days_type,a.is_paying,a.active_days_30d
    ,a.uv,a.yau
    ,a.retention_d1_uv,a.retention_d1_rate
    ,b.payment
from 
(
select
    case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country,
    a.platform
    ,case when install_days<=1 then '0:new-users'
         when install_days<=30 then '1:1~30 users'
        else '2:30+ users' end install_days_type
    ,case when d.is_subscribed = 1 then 'now_paying_or_trial'
                  when d.hist_pay_cnt >= 1 or d.hist_trial_cnt >= 1 then 'his_paying'
    else 'no paying'
    end is_paying
    ,case when d.active_days_30d<=3 then '1:1~3 active days'
          when d.active_days_30d<=10 then '2:4~10 active days'
        else '3:>10 active' end active_days_30d
    ,count(1) uv
    ,count(distinct a.user_pseudo_id) yau
    -- 次日留存：当日活跃且次日仍活跃的用户日数 / 当日活跃用户日数
    ,count(case when a1.user_pseudo_id is not null then 1 end) retention_d1_uv
    ,round(safe_divide(
        count(case when a1.user_pseudo_id is not null then 1 end),
        count(1)
    ), 4) retention_d1_rate
from active a
left join dataintegration-265403.temp.winne_temp_pay_detail_type d
on a.event_date_hk=d.active_date and a.user_pseudo_id=d.user_pseudo_id
left join active a1
on a.user_pseudo_id = a1.user_pseudo_id
and a.event_date_hk = date_sub(a1.event_date_hk, interval 1 day)
where a.event_date_hk between '2025-01-01' and '2025-12-31'
group by 1,2,3,4,5
) a
left join (
    select country,platform,install_days_type,is_paying,active_days_30d
        ,round(sum(payment),2) payment
    from  
    (
    select
        a.uuid
        ,max(case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end) country
        ,max(a.platform) platform
        ,max(case when install_days<=1 then '0:new-users'
            when install_days<=30 then '1:1~30 users'
            else '2:30+ users' end) install_days_type
        ,max(case when d.is_subscribed = 1 then 'now_paying_or_trial'
                    when d.hist_pay_cnt >= 1 or d.hist_trial_cnt >= 1 then 'his_paying'
        else 'no paying'
        end) is_paying
        ,max(case when d.active_days_30d<=3 then '1:1~3 active days'
            when d.active_days_30d<=10 then '2:4~10 active days'
            else '3:>10 active' end) active_days_30d
    from active a
    left join dataintegration-265403.temp.winne_temp_pay_detail_type d
    on a.event_date_hk=d.active_date and a.user_pseudo_id=d.user_pseudo_id
    where a.event_date_hk between '2025-01-01' and '2025-12-31'
    group by 1
    ) a
    left join pay s
    on a.uuid=s.uuid
    group by 1,2,3,4,5
) b 
on a.country=b.country and a.platform=b.platform and a.install_days_type=b.install_days_type and a.is_paying=b.is_paying and a.active_days_30d=b.active_days_30d


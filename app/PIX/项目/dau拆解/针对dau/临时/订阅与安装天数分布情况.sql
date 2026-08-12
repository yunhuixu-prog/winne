-- 订阅天数分布
-- 首次活跃 & 首次订阅 的时间差
with first_active as(select event_date_hk date,user_pseudo_id,uuid
 from
 `dataintegration-265403.stat.stat_active_advice_detail_d`
 where
app_name='AirBrush' --BeautyPlus
and is_new=1
and event_date_hk between '2022-01-01' and '2022-03-31' )
,
first_sub as(select uuid,min(standard_order_date) date
from
`dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where
app_id='AirBrush' and order_status in (1,2)
group by 1)
select --a.date,
date_diff(s.date, a.date,day) diff,count(distinct user_pseudo_id)
from first_active a left join first_sub s
on a.uuid=s.uuid and a.date<=s.date
group by 1
order by 1

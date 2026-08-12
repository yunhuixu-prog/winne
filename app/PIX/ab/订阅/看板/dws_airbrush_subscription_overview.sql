DECLARE start INT64 DEFAULT 0;
delete from
`airbrush-1324.stat.dws_airbrush_subscription_overview`
where
event_date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day)
and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  ;



 insert into  `airbrush-1324.stat.dws_airbrush_subscription_overview`
select s1.event_date,s1.country,s1.platform,s1.app_version,s1.is_new,
if(s1.is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(s1.is_ua = 'Organic','Organic',null)) is_ua,
s1.duration,
count(distinct if(s1.event_name = 'w_subscription_enter' and s1.duration is null,s1.user_pseudo_id,null)) enter_uv,
count(distinct if(s1.event_name = 'w_subscription_click',s1.user_pseudo_id,null)) click_uv,
count(distinct if(s1.event_name = 'sub_suc',s1.user_pseudo_id,null)) sub_success_uv,
count(distinct if(s1.event_name = 'DAU',s1.user_pseudo_id,null)) DAU,
count(distinct if(s1.event_name = 'trial',s1.user_pseudo_id,null)) trial_uv,
count(distinct if(s1.event_name = 'sub_to_paid',s1.user_pseudo_id,null)) sub_to_paid_uv,
count(distinct if(s1.event_name = 'trial_to_paid',s1.user_pseudo_id,null)) trial_to_paid_uv,
sum(if(s1.event_name = 'sub_to_paid',s1.payment_price_usd,0))sub_to_paid_revenue,
sum(case when s1.event_name = 'sub_to_paid'and (duration like 'times%' or duration='credit')  then s1.payment_price_usd else 0 end )sub_to_paid_revenue_cons,
sum(case when s1.event_name = 'sub_to_paid'and duration not like 'times%' and duration <> 'credit' then s1.payment_price_usd else 0 end )sub_to_paid_revenue_sub,
count(distinct case when s1.event_name = 'sub_to_paid'and (duration like 'times%' or duration='credit') then s1.user_pseudo_id else null end )sub_to_paid_uv_cons,
count(distinct case when s1.event_name = 'sub_to_paid'and duration not like 'times%' and duration <> 'credit' then s1.user_pseudo_id else null end )sub_to_paid_uv_sub

from
(select event_date,user_pseudo_id,event_name,payment_price_usd,
max(country)country,
max(platform)platform,
max(app_version)app_version,
max(is_new)is_new,
max(is_ua)is_ua,
max(duration)duration
from `airbrush-1324.stat.dws_airbrush_trial_sub`
where source_module = 'all'
and event_date >= date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day)
and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4
)s1
group by 1,2,3,4,5,6,7

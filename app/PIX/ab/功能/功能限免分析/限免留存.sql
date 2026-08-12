with eves as (
select
    event_date,country,platform,user_pseudo_id,is_ua,user_type,is_new
    ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3,function4
FROM
  `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
WHERE
    event_date between '2025-08-20' and '2025-11-17'
    and app_name='AirBrush'
    and function0='修图'
    and case function_level when '1' then function1 is not null
    when '2' then function1 is not null and function2 is not null
    when '3' then function1 is not null and function2 is not null and function3 is not null
    when '4' then function1 is not null and function2 is not null and function3 is not null and function4 is not null
    when '5' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null
    when '6' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null and function6 is not null
    end
 )
,active as
(
    select
        distinct event_date_hk, user_pseudo_id, platform
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    where
        event_date_hk between '2025-08-20' and date_add('2025-11-17',interval 1 day)
        and  app_name = 'AirBrush'
)

select e.event_date,e.platform
--     ,case when event_date between '2025-08-20' and '2025-09-09' then '2:0903~0909'
--           when event_date between '2025-09-10' and '2025-09-16' then '2:0910~0916'
--           when event_date between '2025-09-17' and '2025-09-23' then '3:0917~0923'
--     end week
    ,action,function2,count(distinct e.user_pseudo_id) uv,count(distinct a.user_pseudo_id) retention_uv
from eves e
left join active a
on e.user_pseudo_id=a.user_pseudo_id and a.platform=e.platform and e.event_date=date_sub(event_date_hk,interval 1 day)
where function_level='2' and function2 in ('Hair','Muscle','AI Replace')
group by 1,2,3,4 --,5

-- union all
--
-- select e.event_date,e.platform
-- --     ,case when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
-- --           when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
-- --     end week
--     ,action,function2,count(distinct e.user_pseudo_id) uv,count(distinct a.user_pseudo_id) retention_uv
-- from eves e
-- left join active a
-- on e.user_pseudo_id=a.user_pseudo_id and a.platform=e.platform and e.event_date=date_sub(event_date_hk,interval 1 day)
-- where function_level='2' and function2 in ('Hair','Muscle','AI Replace') and e.event_date between '2025-09-05' and '2025-09-18'
-- group by 1,2,3,4 --,5
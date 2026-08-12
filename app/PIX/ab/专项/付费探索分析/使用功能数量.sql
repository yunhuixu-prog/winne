-- 新用户onboarding订阅后的付费/免费功能使用情况和付费率的关系
with function_use as
(
    select
        event_date,country,platform,user_pseudo_id,is_ua,user_type,is_new,app_version
        ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3,paid_type
    FROM
      `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
    WHERE
        event_date between '2025-01-01' and '2025-12-31'
        and app_name='AirBrush'
        and function0='修图' and function_level in ('1','2','3')
        and case function_level when '1' then function1 is not null
        when '2' then function1 is not null and function2 is not null
        when '3' then function1 is not null and function2 is not null and function3 is not null
        end
)
,
users as
(
    select is_paying,event_date,user_pseudo_id,country,platform,is_new,is_ua
                ,install_days,expire_days,expire_active_days
                ,is_sub_enter,is_sub,is_sub_to_paid
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-01-01' and '2025-12-31'
)
,onboarding_sub as
(
    select distinct event_date,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name = 'sub_suc'
        and source_00 = 'p_onboarding'
)
,sub as
(
    select distinct event_name,event_date,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('sub_to_paid','sub_suc')
)
-- 点击功能数量
select is_onboarding,is_paying,install_days_type,click_func_num,use_func_num
     ,sum(uv) uv
     ,sum(sub_uv) sub_uv
     ,sum(paid_uv) paid_uv
from
(
select e.event_date
       ,if(os.user_pseudo_id is null,0,1) is_onboarding
       ,e.is_paying
       ,case when e.is_new=1 then '0:new-users'
              when e.install_days<=30 then '1:1~30 users'
              when e.install_days<=90 then '2:31~90 users'
              when e.install_days<=365 then '3:91~365 users'
        else '4:365+ users' end install_days_type
        ,case when coalesce(f.click_func_num,0) <= 5 then cast(coalesce(f.click_func_num,0) as string)
              when f.click_func_num <= 10 then '6:6~10'
              when f.click_func_num <= 20 then '7:11~20'
        else '8:>20' end click_func_num
        ,case when coalesce(f.use_func_num,0) <= 5 then cast(coalesce(f.use_func_num,0) as string)
              when f.use_func_num <= 10 then '6:6~10'
              when f.use_func_num <= 20 then '7:11~20'
        else '8:>20' end use_func_num
        ,count(distinct e.user_pseudo_id) uv
        ,count(distinct case when s.event_name='sub_suc' then e.user_pseudo_id end) sub_uv
        ,count(distinct case when s.event_name='sub_to_paid' then e.user_pseudo_id end) paid_uv
from users e
left join onboarding_sub os
on e.user_pseudo_id=os.user_pseudo_id and e.event_date=os.event_date
left join sub s
on e.user_pseudo_id=s.user_pseudo_id and e.event_date=s.event_date
left join
(
    select event_date,user_pseudo_id
        ,count(distinct case when action='点击' then function2 end) click_func_num
        ,count(distinct case when action='使用' then function2 end) use_func_num
--         ,count(distinct case when action='点击' and paid_type in ('Paid','Free & Paid') then function2 end) click_paid_func_num
--         ,count(distinct case when action='使用' and paid_type in ('Paid','Free & Paid') then function2 end) use_paid_func_num
--         ,count(distinct case when action='使用' and paid_type in ('Free') then function2 end) use_free_func_num
    from function_use
    where function_level='2'
    group by 1,2
) f
on e.event_date=f.event_date and e.user_pseudo_id=f.user_pseudo_id
group by 1,2,3,4,5,6
)
group by 1,2,3,4,5
;
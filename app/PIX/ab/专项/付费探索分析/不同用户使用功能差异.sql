-- 订阅过期vs订阅中，其实也就是用了一些免费功能罢了，好像也没啥
with function_use as
(
    select
        event_date,country,platform,user_pseudo_id,is_ua,user_type,is_new,app_version
        ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3
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
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-01-01' and '2025-12-31'
        and ((is_paying in ('his_paying','his_trial','no paying') and is_sub=0) or is_paying='now_paying_or_trial')
)

select is_paying,install_days_type,sum(uv) uv
from
(
    select event_date,is_paying
         ,case when is_new=1 then '0:new-users'
                when install_days<=30 then '1:1~30 users'
                when install_days<=90 then '2:31~90 users'
                when install_days<=365 then '3:91~365 users'
           else '4:365+ users' end install_days_type
         ,count(distinct user_pseudo_id) uv
    from users
    group by 1,2,3
)
group by 1,2
;

select is_paying,install_days_type,function_level,first_func,second_func,third_func
    ,sum(func_enter_uv) func_enter_uv
    ,sum(func_use_uv) func_use_uv
    ,sum(func_save_uv) func_save_uv
    ,sum(func_enter_pv) func_enter_pv
    ,sum(func_use_pv) func_use_pv
    ,sum(func_save_pv) func_save_pv
from
(
    select u.event_date,u.is_paying
    --        ,u.is_new,u.is_ua,u.platform
           ,case when u.is_new=1 then '0:new-users'
                when install_days<=30 then '1:1~30 users'
                when install_days<=90 then '2:31~90 users'
                when install_days<=365 then '3:91~365 users'
           else '4:365+ users' end install_days_type
           ,f.function_level
           ,f.function1 first_func,f.function2 second_func,f.function3 third_func
           ,count(distinct case when action = '点击' then u.user_pseudo_id end) func_enter_uv
           ,count(distinct case when action = '使用' then u.user_pseudo_id end) func_use_uv
           ,count(distinct case when action = '保存' then u.user_pseudo_id end) func_save_uv
           ,count(case when action = '点击' then 1 end) func_enter_pv
           ,count(case when action = '使用' then 1 end) func_use_pv
           ,count(case when action = '保存' then 1 end) func_save_pv
    from users u
    left join function_use f
    on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
    -- where f.function_level in ('1')
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6
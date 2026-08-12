-- 不同层级订阅率
select is_paying,install_days_type,expire_days_type
    ,sum(uv) uv
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_uv) sub_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
from
(
    select event_date,is_paying
        ,case when is_new=1 then '0:new-users'
              when install_days<=30 then '1:1~30 users'
              when install_days<=90 then '2:31~90 users'
              when install_days<=365 then '3:91~365 users'
        else '4:365+ users' end install_days_type
        ,case when is_paying='no paying' then '0:no paying'
              when expire_days<=7 then '1:0~7 expire'
              when expire_days<=30 then '2:8~30 expire'
              when expire_days<=90 then '3:31~90 expire'
              when expire_days<=365 then '4:91~365 expire'
        else '5:365+ expire' end expire_days_type
        ,count(distinct user_pseudo_id) uv
        ,count(distinct case when is_sub_enter=1 then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when is_sub=1 then user_pseudo_id end) sub_uv
        ,count(distinct case when is_sub_to_paid=1 then user_pseudo_id end) sub_to_paid_uv
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-01-01' and '2025-12-31'
    group by 1,2,3,4
)
group by 1,2,3

;

drop table if exists dataintegration-265403.temp.winne_temp_sub_event;
create table dataintegration-265403.temp.winne_temp_sub_event as

select event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01','2025-12-31','airbrush',false)
where
    event_name in ('w_subscription_success','w_subscription_click','w_subscription_enter','edit_enter','edit_save')

;


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
                ,is_sub_enter,is_sub,is_sub_to_paid
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-01-01' and '2025-12-31'
)
,sub as
(
    select event_date,user_pseudo_id
        ,source_module,source_00,source_11
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2024-01-01' and '2025-12-31'
        and event_name = 'sub_suc'
)
,sub_event as
(
    select event_date,event_name,user_pseudo_id
        ,source_module,source_00,source_11
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('sub_suc','w_subscription_enter','sub_to_paid')
)

-- 使用功能数量和订阅率的关系-分层
select is_paying,install_days_type,click_func_num
     ,sum(uv) uv
     ,sum(sub_uv) sub_uv
from
(
select u.event_date,u.is_paying
       ,case when u.is_new=1 then '0:new-users'
              when u.install_days<=30 then '1:1~30 users'
              when u.install_days<=90 then '2:31~90 users'
              when u.install_days<=365 then '3:91~365 users'
        else '4:365+ users' end install_days_type
        ,case when f.click_func_num <= 5 then cast(f.click_func_num as string)
              when f.click_func_num <= 10 then '6:6~10'
              when f.click_func_num <= 20 then '7:11~20'
        else '8:>20' end click_func_num
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when u.is_sub=1 then u.user_pseudo_id end) sub_uv
from users u
-- left join
-- (
--     select distinct event_date,event_name,user_pseudo_id
--     from sub_event
-- ) s
-- on u.event_date=s.event_date and u.user_pseudo_id=s.user_pseudo_id
left join
(
    select event_date,user_pseudo_id
        ,count(distinct case when action='点击' then function2 end) click_func_num
        ,count(distinct case when action='使用' then function2 end) use_func_num
    from function_use
    where function_level='2'
    group by 1,2
) f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
group by 1,2,3,4
)
group by 1,2,3
;

-- 不同分层用户付费链路
select is_paying,platform,expire_days_type
     ,sum(uv) uv
     ,sum(sub_enter_uv) sub_enter_uv
     ,sum(sub_enter_edit_uv) sub_enter_edit_uv
     ,sum(sub_enter_force_uv) sub_enter_force_uv
     ,sum(sub_suc_uv) sub_suc_uv
     ,sum(sub_suc_edit_uv) sub_suc_edit_uv
     ,sum(sub_suc_force_uv) sub_suc_force_uv
     ,sum(edit_enter_uv) edit_enter_uv
--      ,sum(edit_save_uv) edit_save_uv
--      ,sum(function_click_uv) function_click_uv
     ,sum(function_use_uv) function_use_uv
     ,sum(function_save_uv) function_save_uv
     ,sum(f_edit_click_uv) f_edit_click_uv
     ,sum(f_edit_use_uv) f_edit_use_uv
     ,sum(f_edit_save_uv) f_edit_save_uv
     ,sum(f_retouch_click_uv) f_retouch_click_uv
     ,sum(f_retouch_use_uv) f_retouch_use_uv
     ,sum(f_retouch_save_uv) f_retouch_save_uv
from
(
select u.event_date
        ,u.is_paying,u.platform
--         ,case when u.is_new=1 then '0:new-users'
--               when u.install_days<=30 then '1:1~30 users'
--               when u.install_days<=90 then '2:31~90 users'
--               when u.install_days<=365 then '3:91~365 users'
--         else '4:365+ users' end install_days_type
        ,case when is_paying='no paying' then '0:no paying'
              when expire_days<=7 then '1:0~7 expire'
              when expire_days<=30 then '2:8~30 expire'
              when expire_days<=90 then '3:31~90 expire'
              when expire_days<=365 then '4:91~365 expire'
        else '5:365+ expire' end expire_days_type
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when s.event_name='w_subscription_enter' then u.user_pseudo_id end) sub_enter_uv
        ,count(distinct case when s.event_name='w_subscription_enter'
                                      and source_module='p_edit' and source_00 not in ('hpp','sub_to_guide') then u.user_pseudo_id end) sub_enter_edit_uv
        ,count(distinct case when s.event_name='w_subscription_enter'
                                      and (source_module in ('p_update_first_launch','p_onboarding') or source_00 in ('sub_to_guide')) then u.user_pseudo_id end) sub_enter_force_uv
        ,count(distinct case when s.event_name='sub_suc' then u.user_pseudo_id end) sub_suc_uv
        ,count(distinct case when s.event_name='sub_suc'
                                      and source_module='p_edit' and source_00 not in ('hpp','sub_to_guide') then u.user_pseudo_id end) sub_suc_edit_uv
        ,count(distinct case when s.event_name='sub_suc'
                                      and (source_module in ('p_update_first_launch','p_onboarding') or source_00 in ('sub_to_guide')) then u.user_pseudo_id end) sub_suc_force_uv
        ,count(distinct case when e.event_name='edit_enter' then u.user_pseudo_id end) edit_enter_uv
--         ,count(distinct case when e.event_name='edit_save' then u.user_pseudo_id end) edit_save_uv
--         ,count(distinct case when f.function_level='1' and action='点击' then u.user_pseudo_id end) function_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' then u.user_pseudo_id end) function_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' then u.user_pseudo_id end) function_save_uv
        ,count(distinct case when f.function_level='1' and action='点击' and function1='Edit' then u.user_pseudo_id end) f_edit_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' and function1='Edit' then u.user_pseudo_id end) f_edit_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' and function1='Edit' then u.user_pseudo_id end) f_edit_save_uv
        ,count(distinct case when f.function_level='1' and action='点击' and function1='Retouch' then u.user_pseudo_id end) f_retouch_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' and function1='Retouch' then u.user_pseudo_id end) f_retouch_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' and function1='Retouch' then u.user_pseudo_id end) f_retouch_save_uv
from users u
left join sub_event s
on u.event_date=s.event_date and u.user_pseudo_id=s.user_pseudo_id
left join
(
    select distinct event_date,user_pseudo_id,event_name
    from dataintegration-265403.temp.winne_temp_sub_event
    where event_date between '2025-01-01' and '2025-12-31' and event_name in ('edit_enter','edit_save')
) e
on u.event_date=e.event_date and u.user_pseudo_id=e.user_pseudo_id
left join function_use f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
where u.is_paying in ('his_paying','his_trial')
group by 1,2,3,4
)
group by 1,2,3
order by 1,2,3
;
-- 新用户付费链路
-- 核心行为分国家
select country
     ,sum(uv) uv
     ,sum(sub_enter_uv) sub_enter_uv
     ,sum(sub_enter_edit_uv) sub_enter_edit_uv
     ,sum(sub_enter_onboarding_uv) sub_enter_onboarding_uv
     ,sum(sub_suc_uv) sub_suc_uv
     ,sum(sub_suc_edit_uv) sub_suc_edit_uv
     ,sum(sub_suc_onboarding_uv) sub_suc_onboarding_uv
     ,sum(sub_paid_uv) sub_paid_uv
     ,sum(sub_paid_edit_uv) sub_paid_edit_uv
     ,sum(sub_paid_onboarding_uv) sub_paid_onboarding_uv
     ,sum(edit_enter_uv) edit_enter_uv
--      ,sum(edit_save_uv) edit_save_uv
--      ,sum(function_click_uv) function_click_uv
     ,sum(function_use_uv) function_use_uv
     ,sum(function_save_uv) function_save_uv
     ,sum(f_edit_click_uv) f_edit_click_uv
     ,sum(f_edit_use_uv) f_edit_use_uv
     ,sum(f_edit_save_uv) f_edit_save_uv
     ,sum(f_retouch_click_uv) f_retouch_click_uv
     ,sum(f_retouch_use_uv) f_retouch_use_uv
     ,sum(f_retouch_save_uv) f_retouch_save_uv
from
(
select u.event_date
        ,case when u.country in ('Brazil', 'United States', 'United Kingdom') then u.country else 'else' end country
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when s.event_name='w_subscription_enter' then u.user_pseudo_id end) sub_enter_uv
        ,count(distinct case when s.event_name='w_subscription_enter'
                                      and source_module='p_edit' and source_00 not in ('hpp','sub_to_guide') then u.user_pseudo_id end) sub_enter_edit_uv
        ,count(distinct case when s.event_name='w_subscription_enter'
                                      and source_module = 'p_onboarding' then u.user_pseudo_id end) sub_enter_onboarding_uv
        ,count(distinct case when s.event_name='sub_suc' then u.user_pseudo_id end) sub_suc_uv
        ,count(distinct case when s.event_name='sub_suc'
                                      and source_module='p_edit' and source_00 not in ('hpp','sub_to_guide') then u.user_pseudo_id end) sub_suc_edit_uv
        ,count(distinct case when s.event_name='sub_suc'
                                      and source_module = 'p_onboarding' then u.user_pseudo_id end) sub_suc_onboarding_uv
        ,count(distinct case when s.event_name='sub_to_paid' then u.user_pseudo_id end) sub_paid_uv
        ,count(distinct case when s.event_name='sub_to_paid'
                                      and source_module='p_edit' and source_00 not in ('hpp','sub_to_guide') then u.user_pseudo_id end) sub_paid_edit_uv
        ,count(distinct case when s.event_name='sub_to_paid'
                                      and source_module = 'p_onboarding' then u.user_pseudo_id end) sub_paid_onboarding_uv
        ,count(distinct case when e.event_name='edit_enter' then u.user_pseudo_id end) edit_enter_uv
--         ,count(distinct case when e.event_name='edit_save' then u.user_pseudo_id end) edit_save_uv
--         ,count(distinct case when f.function_level='1' and action='点击' then u.user_pseudo_id end) function_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' then u.user_pseudo_id end) function_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' then u.user_pseudo_id end) function_save_uv
        ,count(distinct case when f.function_level='1' and action='点击' and function1='Edit' then u.user_pseudo_id end) f_edit_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' and function1='Edit' then u.user_pseudo_id end) f_edit_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' and function1='Edit' then u.user_pseudo_id end) f_edit_save_uv
        ,count(distinct case when f.function_level='1' and action='点击' and function1='Retouch' then u.user_pseudo_id end) f_retouch_click_uv
        ,count(distinct case when f.function_level='1' and action='使用' and function1='Retouch' then u.user_pseudo_id end) f_retouch_use_uv
        ,count(distinct case when f.function_level='1' and action='保存' and function1='Retouch' then u.user_pseudo_id end) f_retouch_save_uv
from users u
left join sub_event s
on u.event_date=s.event_date and u.user_pseudo_id=s.user_pseudo_id
left join
(
    select distinct event_date,user_pseudo_id,event_name
    from dataintegration-265403.temp.winne_temp_sub_event
    where event_date between '2025-01-01' and '2025-12-31' and event_name in ('edit_enter','edit_save')
) e
on u.event_date=e.event_date and u.user_pseudo_id=e.user_pseudo_id
left join function_use f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
where u.is_new=1
group by 1,2
)
group by 1
;






-- 长期未付费用户如何付费（占大头，但订阅率极低）
-- 使用功能情况、使用功能数量，使用新的功能及和订阅的关系
-- 使用新功能是否能促进订阅率，以及使用的是什么新功能
select is_new
     ,sum(uv) uv
     ,sum(sub_uv) sub_uv
from
(
select u.event_date,f.is_new
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when u.is_sub=1 then u.user_pseudo_id end) sub_uv
from users u
join
(
    select now.event_date,now.user_pseudo_id
--          ,now.function2
         ,max(if(pre.function2 is null,1,0)) is_new
    from
    (
        select event_date,user_pseudo_id,function2
        from function_use
        where function_level='2' and action='使用'
        group by 1,2,3
    ) now
    left join
    (
        select event_date,user_pseudo_id,function2
        from function_use
        where function_level='2' and action='使用'
        group by 1,2,3
    ) pre
    on now.user_pseudo_id=pre.user_pseudo_id and pre.event_date between date_sub(now.event_date,interval 30 day) and date_sub(now.event_date,interval 1 day)
        and now.function2=pre.function2
    join
    (
        select distinct event_date,user_pseudo_id
        from users
    ) u
    on now.user_pseudo_id=u.user_pseudo_id and u.event_date between date_sub(now.event_date,interval 30 day) and date_sub(now.event_date,interval 1 day)
    group by 1,2
) f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
where u.is_paying='no paying' and u.install_days>30
group by 1,2
)
group by 1
;
-- 使用的是什么新功能
select function2
     ,sum(uv) uv
     ,sum(sub_uv) sub_uv
from
(
select u.event_date,f.function2
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when u.is_sub=1 then u.user_pseudo_id end) sub_uv
from users u
join
(
    select now.event_date,now.user_pseudo_id
         ,now.function2
         ,max(if(pre.function2 is null,1,0)) is_new
    from
    (
        select event_date,user_pseudo_id,function2
        from function_use
        where function_level='2' and action='使用'
        group by 1,2,3
    ) now
    left join
    (
        select event_date,user_pseudo_id,function2
        from function_use
        where function_level='2' and action='使用'
        group by 1,2,3
    ) pre
    on now.user_pseudo_id=pre.user_pseudo_id and pre.event_date between date_sub(now.event_date,interval 30 day) and date_sub(now.event_date,interval 1 day)
        and now.function2=pre.function2
    join
    (
        select distinct event_date,user_pseudo_id
        from users
    ) u
    on now.user_pseudo_id=u.user_pseudo_id and u.event_date between date_sub(now.event_date,interval 30 day) and date_sub(now.event_date,interval 1 day)
    group by 1,2,3
) f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
where u.is_paying='no paying' and u.install_days>30 and f.is_new=1
group by 1,2
)
group by 1

;







-- 订阅过用户付费情景-权益，sku，价格，弹了几次订阅页才订阅的，在哪里弹的
select is_paying
        ,if(source_00_pre=source_00,1,0) is_same
        ,source_module_pre,source_00_pre,source_module,source_00
        ,sum(uv) uv
--         ,sum(sub_uv) sub_uv
from
(
    select a.event_date,a.is_paying,a.expire_days_type
         ,a.source_module source_module_pre,a.source_00 source_00_pre -- ,a.source_11 source_11_pre
         ,b.source_module,b.source_00 -- ,b.source_11
         ,count(distinct a.user_pseudo_id) uv
--          ,count(distinct b.user_pseudo_id) sub_uv
    from
    (
        select u.event_date,u.is_paying
            ,case when is_paying='no paying' then 'no paying'
                  when expire_days<=7 then '0~7 expire'
                  when expire_days<=30 then '8~30 expire'
                  when expire_days<=90 then '31~90 expire'
                  when expire_days<=365 then '91~365 expire'
            else '365+ expire' end expire_days_type
            ,u.user_pseudo_id
            ,s.event_date sub_date,s.source_module,s.source_00,s.source_11
            ,row_number() over(partition by u.event_date,u.user_pseudo_id order by s.event_date desc) ranks
        from users u
        left join sub s
        on u.user_pseudo_id=s.user_pseudo_id and u.event_date>s.event_date
        where u.is_paying in ('his_trial','his_paying') and s.user_pseudo_id is not null
    ) a
    join sub b
    on a.user_pseudo_id=b.user_pseudo_id and a.event_date=b.event_date
    where a.ranks=1
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6
;



-- 不同层级用户订阅触发功能个数和订阅率的关系
with users as
(
    select is_paying,event_date,user_pseudo_id,country,platform,is_new,is_ua
                ,install_days,expire_days,expire_active_days
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-01-01' and '2025-12-31'
)
,sub_event as
(
    select event_date,event_name,user_pseudo_id,source_module,source_0,source_1
        ,array_length(SPLIT(coalesce(source_1,source_0), ',')) source_num
--         ,array_length(SPLIT(source_0, ',')) source_0_num
--         ,array_length(SPLIT(source_1, ',')) source_1_num
    from dataintegration-265403.temp.winne_temp_sub_event
    where event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('w_subscription_success','w_subscription_click','w_subscription_enter')
--         and source_module='p_edit'
)

select
--     is_paying
--     ,install_days_type,expire_days_type
    source_module,source_0
    ,source_num
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_uv) sub_uv
from
(
    select s.event_date
--         ,is_paying
--         ,case when is_new=1 then '0:new-users'
--               when install_days<=30 then '1:1~30 users'
--               when install_days<=90 then '2:31~90 users'
--               when install_days<=365 then '3:91~365 users'
--         else '4:365+ users' end install_days_type
--         ,case when is_paying='no paying' then '0:no paying'
--               when expire_days<=7 then '1:0~7 expire'
--               when expire_days<=30 then '2:8~30 expire'
--               when expire_days<=90 then '3:31~90 expire'
--               when expire_days<=365 then '4:91~365 expire'
--         else '5:365+ expire' end expire_days_type
        ,source_module,source_0
        ,case when source_num<=5 or source_num is null then source_num else 999 end source_num
        ,count(distinct case when event_name='w_subscription_enter' then s.user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name='w_subscription_success' then s.user_pseudo_id end) sub_uv
    from sub_event s
    join users u
    on u.event_date=s.event_date and u.user_pseudo_id=s.user_pseudo_id
    group by 1,2,3,4
)
group by 1,2,3



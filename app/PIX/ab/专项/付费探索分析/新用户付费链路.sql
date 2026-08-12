drop table if exists `dataintegration-265403.temp.winne_temp_new_user_event`;
create table `dataintegration-265403.temp.winne_temp_new_user_event` as

with pre_event as
(
    select event_date
         ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'first_func').string_value first_func
        ,`dataintegration-265403.func`.getParams(event_params,'second_func').string_value second_func
        ,`dataintegration-265403.func`.getParams(event_params,'page_name').string_value page_name
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'position').string_value position
        ,`dataintegration-265403.func`.getParams(event_params,'source_module').string_value source_module
        ,`dataintegration-265403.func`.getParams(event_params,'source_0').string_value source_0
        ,`dataintegration-265403.func`.getParams(event_params,'source_1').string_value source_1
        ,`dataintegration-265403.func`.getParams(event_params,'album_type').string_value album_type
        ,user_pseudo_id
        ,event_timestamp
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-01','2025-12-31','airbrush',false)
    WHERE event_name in
            (
            'enter_onboarding','click_onboarding'
            ,'w_subscription_success','w_subscription_enter'
            ,'homepage_view','homepage_func_click' -- func,position
            ,'popup_show','popup_click' -- page_name='homepage'
            ,'album_click','edit_enter'
            ,'first_func_enter' -- first_func
            ,'second_func_enter' -- second_func
            ,'second_func_use' -- second_func
            ,'edit_save'
            )
)
,event as
(
    select event_date,user_pseudo_id,event_timestamp
        ,case
              when event_name='homepage_func_click' and position in ('album') and func='album_out' then 'homepage_click_album_out'
              when event_name='homepage_func_click' and position in ('album') and func in ('album_all','camera','album_add') then 'homepage_click_album_all'
              when event_name='homepage_func_click' and position in ('album') and func='album_center' then 'homepage_click_album_center'
              when event_name='homepage_func_click' and position in ('tool') then 'homepage_click_tool'
              when event_name='homepage_func_click' and position not in ('album','tool') then 'homepage_click_other'
              when event_name='album_click' and album_type in ('album') then 'album_page_click'
              when event_name='popup_show' and page_name in ('homepage') then 'popup_show'
              when event_name='popup_click' and page_name in ('homepage') then 'popup_click'
              when event_name='first_func_enter' and first_func not in ('retouch','edit') then concat('firsts_func_click_',second_func)
              when event_name='second_func_enter' and first_func in ('retouch','edit') then concat('second_func_click_',second_func)
              when event_name='second_func_use' then concat('second_func_use_',second_func)
              when event_name in ('edit_save') then event_name
        else 'no_need' end event_name
    from pre_event
)
,group_event as
(
    select event_date,user_pseudo_id,event_name,event_timestamp
            ,sum(if(event_name!=coalesce(pre_event_name,''),1,0)) over(partition by event_date,user_pseudo_id order by event_timestamp) group_event_rank
    from
    (
        select event_date,user_pseudo_id,event_name,event_timestamp
    --          ,row_number() over(partition by event_date,user_pseudo_id order by event_timestamp) event_rank
             ,lag(event_name) over(partition by event_date,user_pseudo_id order by event_timestamp) pre_event_name
        from event
        where event_name!='no_need'
    )
)
,
user_behavior_seq as
(
    select event_date,user_pseudo_id,group_event_rank,event_name
         ,count(1) nums,min(event_timestamp) start_event_timestamp
    from group_event
    group by 1,2,3,4
)

select event_date,user_pseudo_id
        ,STRING_AGG(case when nums=1 then event_name
              when nums>1 then concat(event_name,'*',cast(nums as string))
        end,',' order by group_event_rank) seq_has_times
        ,STRING_AGG(event_name,',' order by group_event_rank) seq
from user_behavior_seq
where group_event_rank<=10
group by 1,2
;

select seq,count(distinct e.user_pseudo_id) uv
from `dataintegration-265403.temp.winne_temp_new_user_event` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where u.is_new=1
group by 1
order by 2 desc

;

with users as
(
    select is_paying,event_date,user_pseudo_id,country,platform,is_new,is_ua
                ,install_days,expire_days,expire_active_days
                ,is_sub_enter,is_sub,is_sub_to_paid
    from `dataintegration-265403.temp.winne_temp_day_type_2`
    where event_date between '2025-12-01' and '2025-12-31'
        and is_new = 1
)
,onboarding_sub as
(
    select distinct event_date,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-12-01' and '2025-12-31'
        and event_name = 'sub_suc'
        and source_00 = 'p_onboarding'
)
,sub as
(
    select distinct event_name,event_date,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-12-01' and '2025-12-31'
        and event_name in ('sub_suc','sub_to_paid')
)
,paid as
(
    select distinct event_name,event_date,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-12-01' and '2025-12-31'
        and event_name in ('sub_to_paid')
)
,function_use as
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

-- 次日留存，是否订阅
select
     if(os.user_pseudo_id is null,0,1) is_onboarding_sub
     ,if(se.seq is not null,split(se.seq,',')[0],null) s1
     ,if(array_length(split(seq,','))>1,split(seq,',')[1],null) s2
     ,if(array_length(split(seq,','))>2,split(seq,',')[2],null) s3
     ,if(array_length(split(seq,','))>3,split(seq,',')[3],null) s4
--      ,if(array_length(split(seq,','))>4,split(seq,',')[4],null) s5
--      ,if(array_length(split(seq,','))>5,split(seq,',')[5],null) s6
--      ,if(array_length(split(seq,','))>6,split(seq,',')[6],null) s7
--      ,if(array_length(split(seq,','))>7,split(seq,',')[7],null) s8
     ,count(distinct e.user_pseudo_id) uv
     ,count(distinct case when s.event_name='sub_suc' then s.user_pseudo_id end) sub_uv
     ,count(distinct case when s.event_name='sub_to_paid' then s.user_pseudo_id end) sub_paid_uv
     ,count(distinct c1.user_pseudo_id) retention_uv
from users e
left join
(
    select event_date,user_pseudo_id
        ,case when split(seq,',')[0] in ('homepage_click_album_out','homepage_click_album_all','homepage_click_album_center'
                                        ,'homepage_click_tool','homepage_click_other','popup_show') then seq
              when split(seq,',')[0] not in ('homepage_click_album_out','homepage_click_album_all','homepage_click_album_center'
                                        ,'homepage_click_tool','homepage_click_other','popup_show') then split(seq,',')[0]
        end seq
    from `dataintegration-265403.temp.winne_temp_new_user_event`
) se
on e.user_pseudo_id=se.user_pseudo_id and e.event_date=se.event_date
left join onboarding_sub os
on e.user_pseudo_id=os.user_pseudo_id and e.event_date=os.event_date
left join sub s
on e.user_pseudo_id=s.user_pseudo_id and e.event_date=s.event_date
left join `dataintegration-265403.stat.stat_active_advice_detail_d` c1
on e.user_pseudo_id=c1.user_pseudo_id and e.event_date=date_sub(c1.event_date_hk,interval 1 day)
group by 1,2,3,4,5 -- ,6,7,8,9


;
-- 排查
select e.*
from `dataintegration-265403.temp.winne_temp_new_user_event` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where u.is_new=1 and seq='homepage_click_album_out,second_func_click_hair_dye'
;
select event_date
         ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'first_func').string_value first_func
        ,`dataintegration-265403.func`.getParams(event_params,'second_func').string_value second_func
        ,`dataintegration-265403.func`.getParams(event_params,'page_name').string_value page_name
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'position').string_value position
        ,`dataintegration-265403.func`.getParams(event_params,'source_module').string_value source_module
        ,`dataintegration-265403.func`.getParams(event_params,'source_0').string_value source_0
        ,`dataintegration-265403.func`.getParams(event_params,'source_1').string_value source_1
        ,`dataintegration-265403.func`.getParams(event_params,'album_type').string_value album_type
        ,user_pseudo_id
        ,event_timestamp
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-01','2025-12-31','airbrush',false)
    WHERE user_pseudo_id='bda71558ad4208512ea2453ec208cfb1'
    order by event_timestamp
;

-- 是否点击某个功能对付费率的影响
select first_func,second_func,is_click
     ,sum(uv) uv
     ,sum(paid_uv) paid_uv
from
(
select e.event_date
        ,fl.first_func,fl.second_func
        ,if(f.user_pseudo_id is null,0,1) is_click
        ,count(distinct e.user_pseudo_id) uv
        ,count(distinct s.user_pseudo_id) paid_uv
from users e
join onboarding_sub os
on e.user_pseudo_id=os.user_pseudo_id and e.event_date=os.event_date
left join paid s
on e.user_pseudo_id=s.user_pseudo_id and e.event_date=s.event_date
cross join (select distinct function1 first_func,function2 second_func from function_use where function_level in ('2') and action = '点击') fl
left join
(
    select event_date,user_pseudo_id
           ,function1 first_func,function2 second_func
    from function_use
    where function_level in ('2') and action = '点击'
    group by 1,2,3,4
) f
on e.event_date=f.event_date and e.user_pseudo_id=f.user_pseudo_id and fl.first_func=f.first_func and fl.second_func=f.second_func
group by 1,2,3,4
)
group by 1,2,3
;
select first_func,second_func,third_func,is_click
     ,sum(uv) uv
     ,sum(paid_uv) paid_uv
from
(
select e.event_date
        ,fl.first_func,fl.second_func,fl.third_func
        ,if(f.user_pseudo_id is null,0,1) is_click
        ,count(distinct e.user_pseudo_id) uv
        ,count(distinct s.user_pseudo_id) paid_uv
from users e
join onboarding_sub os
on e.user_pseudo_id=os.user_pseudo_id and e.event_date=os.event_date
left join paid s
on e.user_pseudo_id=s.user_pseudo_id and e.event_date=s.event_date
cross join (select distinct function1 first_func,function2 second_func,function3 third_func from function_use where function_level in ('3') and action = '点击') fl
left join
(
    select event_date,user_pseudo_id
           ,function1 first_func,function2 second_func,function3 third_func
    from function_use
    where function_level in ('3') and action = '点击'
    group by 1,2,3,4,5
) f
on e.event_date=f.event_date and e.user_pseudo_id=f.user_pseudo_id and fl.first_func=f.first_func and fl.second_func=f.second_func and fl.third_func=f.third_func
group by 1,2,3,4,5
)
group by 1,2,3,4
;
-- 用户的点击欲望是比较高的，但是打勾欲望比较低，而打勾率直接影响了付费率，因此需要提高打勾率，看下什么功能的打勾率不行
select function_level,first_func,second_func
    ,sum(func_enter_uv) func_enter_uv
    ,sum(func_use_uv) func_use_uv
    ,sum(func_save_uv) func_save_uv
--     ,sum(func_enter_pv) func_enter_pv
--     ,sum(func_use_pv) func_use_pv
--     ,sum(func_save_pv) func_save_pv
from
(
    select u.event_date
           ,f.function_level
           ,f.function1 first_func,f.function2 second_func
           ,count(distinct case when action = '点击' then u.user_pseudo_id end) func_enter_uv
           ,count(distinct case when action = '使用' then u.user_pseudo_id end) func_use_uv
           ,count(distinct case when action = '保存' then u.user_pseudo_id end) func_save_uv
           ,count(case when action = '点击' then 1 end) func_enter_pv
           ,count(case when action = '使用' then 1 end) func_use_pv
           ,count(case when action = '保存' then 1 end) func_save_pv
    from users u
    join onboarding_sub os
    on u.user_pseudo_id=os.user_pseudo_id and u.event_date=os.event_date
    left join function_use f
    on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
    where f.function_level in ('2')
    group by 1,2,3,4
)
group by 1,2,3




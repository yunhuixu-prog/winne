-- 依赖用户精细分层：dataintegration-265403.temp.winne_temp_pay_detail_type
drop table if exists dataintegration-265403.temp.winne_temp_face_free_analysis;
create table dataintegration-265403.temp.winne_temp_face_free_analysis as

with active AS (
    select app_name,
            event_date_hk
            ,platform
            ,user_pseudo_id
            ,max(country) country
            ,max(is_new) is_new
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between date_sub('2026-01-01',interval 30 day) and date_add('2026-02-28',interval 1 day)
            and app_name = 'AirBrush'
        group by 1,2,3,4
)
,function_use_detail as (
    select
        event_date,country,platform,user_pseudo_id,is_ua,user_type,is_new,app_version
        ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3
    FROM
      `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
    WHERE
        event_date between '2026-01-01' and '2026-02-28'
        and app_name='AirBrush'
        and function0='修图' and function_level in ('1','2','3')
        and case function_level when '1' then function1 is not null
        when '2' then function1 is not null and function2 is not null
        when '3' then function1 is not null and function2 is not null and function3 is not null
        end
)
,function_use as (
    select
        event_date,user_pseudo_id
        ,count(case when function_level='1' and action='使用' then 1 end) function_use_pv
        ,count(case when function_level='1' and action='保存' then 1 end) function_save_pv
        ,count(case when function_level='2' and action='点击' and function1='Retouch' and function2='Face' then 1 end) face_click_pv
        ,count(case when function_level='2' and action='使用' and function1='Retouch' and function2='Face' then 1 end) face_use_pv
        ,count(case when function_level='2' and action='保存' and function1='Retouch' and function2='Face' then 1 end) face_save_pv
    FROM
      `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
    WHERE
        event_date between date_sub('2026-01-01', interval 30 day) and '2026-02-28'
        and app_name='AirBrush'
        and function0='修图' and function_level in ('1','2','3')
        and case function_level when '1' then function1 is not null
        when '2' then function1 is not null and function2 is not null
        when '3' then function1 is not null and function2 is not null and function3 is not null
        end
    group by 1,2
)
,function_use_face_30d as (
    select
        a.event_date_hk,
        a.user_pseudo_id,
        coalesce(sum(f.face_click_pv), 0) as face_click_30d_pv
    from active a
    left join function_use f
        on a.user_pseudo_id = f.user_pseudo_id
        and f.event_date between date_sub(a.event_date_hk, interval 30 day) and date_sub(a.event_date_hk, interval 1 day)
    where a.event_date_hk between '2026-01-01' and '2026-02-28'
    group by 1, 2
),
function_new as (
    select now.event_date,now.user_pseudo_id
         ,max(if(pre.function2 is null,1,0)) is_new
    from
    (
        select event_date,user_pseudo_id,function2
        from function_use_detail
        where function_level='2' and action='使用'
        group by 1,2,3
    ) now
    left join
    (
        select event_date,user_pseudo_id,function2
        from function_use_detail
        where function_level='2' and action='使用'
        group by 1,2,3
    ) pre
    on now.user_pseudo_id=pre.user_pseudo_id and pre.event_date between date_sub(now.event_date,interval 30 day) and date_sub(now.event_date,interval 1 day)
        and now.function2=pre.function2
    group by 1,2
)
,sub AS (
    select event_date,user_pseudo_id
       ,MAX(case when event_name='w_subscription_enter' then 1 end) is_sub_enter
       ,COUNT(case when event_name='w_subscription_enter' then 1 end) sub_enter_pv
       ,MAX(case when event_name='sub_suc' then 1 end) is_sub
       ,MAX(case when event_name='sub_to_paid' then payment_price_usd end) sub_amt
       -- face功能
       ,MAX(case when event_name='w_subscription_enter' and source_00='f_face' then 1 end) is_sub_enter_face
       ,MAX(case when event_name='sub_suc' and source_00='f_face' then 1 end) is_sub_face
       ,MAX(case when event_name='sub_to_paid' and source_00='f_face' then payment_price_usd end) sub_amt_face
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2026-01-01' and '2026-02-28'
        and event_name in ('sub_suc','sub_to_paid','w_subscription_enter')
    group by 1,2
)

select
    case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country,
    a.platform
    ,case when a.is_new=1 then '0:新用户'
          when install_days<=30 then '1:1~30 users'
          when install_days<=365 then '2:31~365 users'
        else '3:365+ users' end install_days_type
    ,case when d.is_subscribed = 1 then 'now_paying_or_trial'
                  when d.hist_pay_cnt >= 1 or d.hist_trial_cnt >= 1 then 'his_paying'
    else 'no paying'
    end is_paying
    ,case when d.active_days_30d=1 then '1:0 active days'
          when d.active_days_30d<=4 then '2:2~4 active days'
          when d.active_days_30d<=10 then '3:5~10 active days'
        else '4:>10 active' end active_days_30d
    ,case when f_new.is_new=1 then 1 else 0 end is_use_new
    ,case when coalesce(f30.face_click_30d_pv,0)=0 then '过去30天未进入Face'
        else '过去30天进入Face' end face_click_30d_type
    -- face使用情况分层
    ,case when coalesce(f.face_click_pv,0)=0 then '未进入Face'
          when coalesce(s.is_sub_enter_face,0)>=1 then 'Face被拦截'
          when coalesce(s.is_sub_enter_face,0)=0 then 'Face未被拦截'
    else '其他'
    end face_use_type
    ,case when s.is_sub=1 then 1 else 0 end is_sub
    ,case when s.is_sub_face=1 then 1 else 0 end is_sub_face
    ,case when coalesce(f.face_save_pv,0)<=2 then coalesce(f.face_save_pv,0) else 999 end face_save_pv
    ,count(1) uv
    ,count(case when a1.user_pseudo_id is not null then 1 end) retention_1_uv
    ,count(case when s.is_sub=1 then 1 end) sub_uv
    ,count(case when s.sub_amt>0 then 1 end) pay_uv
    ,round(sum(s.sub_amt),2) sub_amt
    ,count(case when s.is_sub_face=1 then 1 end) sub_face_uv
    ,count(case when s.sub_amt_face>0 then 1 end) pay_face_uv
    ,round(sum(s.sub_amt_face),2) sub_amt_face
from active a
left join dataintegration-265403.temp.winne_temp_pay_detail_type d
on a.event_date_hk=d.active_date and a.user_pseudo_id=d.user_pseudo_id
left join sub s
on a.event_date_hk=s.event_date and a.user_pseudo_id=s.user_pseudo_id
left join function_use f
on a.event_date_hk=f.event_date and a.user_pseudo_id=f.user_pseudo_id
left join function_use_face_30d f30
on a.event_date_hk=f30.event_date_hk and a.user_pseudo_id=f30.user_pseudo_id
left join function_new f_new
on a.event_date_hk=f_new.event_date and a.user_pseudo_id=f_new.user_pseudo_id
left join active a1 
on a.user_pseudo_id=a1.user_pseudo_id and a.event_date_hk=date_sub(a1.event_date_hk,interval 1 day)
where a.event_date_hk between '2026-01-01' and '2026-02-28'
group by 1,2,3,4,5,6,7,8,9,10,11

;

select country,platform,install_days_type,is_paying
    ,active_days_30d,is_use_new,face_click_30d_type
    ,sum(case when is_paying in ('his_paying','no paying') then uv end) uv
    ,sum(case when is_paying in ('his_paying','no paying') and face_use_type!='未进入Face' then uv end) face_enter_uv
    ,sum(case when is_paying in ('his_paying','no paying') then sub_uv end) sub_uv
    ,sum(case when is_paying in ('his_paying','no paying') then pay_uv end) pay_uv
    ,round(sum(case when is_paying in ('his_paying','no paying') then sub_amt end),2) sub_amt
    ,round(sum(case when is_sub_face=1 and is_paying in ('his_paying','no paying') then sub_amt_face end),2) max_revenue_lose
    ,round(sum(case when is_sub_face=1 and is_paying in ('his_paying','no paying') and face_save_pv<=1 then sub_amt_face end),2) min_revenue_lose_1
    ,round(sum(case when is_sub_face=1 and is_paying in ('his_paying','no paying') and face_save_pv<=2 then sub_amt_face end),2) min_revenue_lose_2

    ,sum(case when is_paying in ('his_paying','no paying') and face_use_type='Face被拦截' then retention_1_uv end) face_blocked_uv_retention
    ,sum(case when is_paying in ('his_paying','no paying') and face_use_type='Face被拦截' then uv end) face_blocked_uv
    ,sum(case when is_paying in ('his_paying','no paying') and face_use_type='Face未被拦截' then retention_1_uv end) face_not_blocked_uv_retention
    ,sum(case when is_paying in ('his_paying','no paying') and face_use_type='Face未被拦截' then uv end) face_not_entered_uv
from dataintegration-265403.temp.winne_temp_face_free_analysis
group by 1,2,3,4,5,6,7



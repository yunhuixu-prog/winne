-- 依赖用户精细分层：dataintegration-265403.temp.winne_temp_pay_detail_type

with active AS (
    select app_name,
            event_date_hk
            ,platform
            ,user_pseudo_id
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between date_sub('2025-01-01',interval 30 day) and date_add('2025-12-31',interval 1 day)
            and app_name = 'AirBrush'
        group by 1,2,3,4
)
,function_use as
(
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
        -- 下界提前29天，便于年初活跃日计算「过去30天」Face使用次数
        event_date between date_sub('2025-01-01', interval 29 day) and '2025-12-31'
        and app_name='AirBrush'
        and function0='修图' and function_level in ('1','2','3')
        and case function_level when '1' then function1 is not null
        when '2' then function1 is not null and function2 is not null
        when '3' then function1 is not null and function2 is not null and function3 is not null
        end
    group by 1,2
),
-- 每个活跃日：过去30天（含当日）内 function_level='2' & action='使用' & Retouch-Face 的使用次数
,function_use_face_30d as (
    select
        a.event_date_hk,
        a.user_pseudo_id,
        coalesce(sum(f.face_use_pv), 0) as face_use_30d_pv
    from active a
    left join function_use f
        on a.user_pseudo_id = f.user_pseudo_id
        and f.event_date between date_sub(a.event_date_hk, interval 29 day) and a.event_date_hk
    where a.event_date_hk between '2025-01-01' and '2025-12-31'
    group by 1, 2
),
sub AS (
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
        and event_date between '2025-01-01' and '2025-12-31'
        and event_name in ('sub_suc','sub_to_paid','w_subscription_enter')
    group by 1,2
)

-- 订阅前进入订阅页次数
select
    case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country,
    a.platform
    ,case when install_days<=1 then '0:新用户'
          when install_days<=30 then '1:1~30 users'
          when install_days<=365 then '2:31~365 users'
        else '3:365+ users' end install_days_type
    ,case when d.is_subscribed = 1 then 'now_paying_or_trial'
                  when d.hist_pay_cnt >= 1 or d.hist_trial_cnt >= 1 then 'his_paying'
    else 'no paying'
    end is_paying
    ,case when d.active_days_30d<=3 then '1:1~3 active days'
          when d.active_days_30d<=10 then '2:4~10 active days'
        else '3:>10 active' end active_days_30d
    -- ,case when DATE_DIFF(d.active_date, d.recent_expire_date, DAY)<=30 then '1:1~30 expire'
    --       when DATE_DIFF(d.active_date, d.recent_expire_date, DAY)<=90 then '2:31~90 expire'
    --     else '3:90+ expire' end expire_days_type
    -- ,case when coalesce(d.hist_pay_cnt,0)<=1 then cast(coalesce(d.hist_pay_cnt,0) as string)
    --     else '2:>=2' end hist_pay_cnt
    -- face使用情况分层
    -- ,case when coalesce(f.face_click_pv,0)=0 then '1:未进入Face'
    --       when coalesce(f.face_click_pv,0)>=1 and coalesce(f.face_use_pv,0)=0 then '2:进入Face但未打勾'
    --       when coalesce(f.face_use_pv,0)>=1 and coalesce(f.face_save_pv,0)=0 and coalesce(s.is_sub_enter_face,0)>=1 then '3-1:打勾Face被拦截未保存'
    --       when coalesce(f.face_use_pv,0)>=1 and coalesce(s.is_sub_enter_face,0)=0 then '3-2:打勾Face未被拦截'
    --       when coalesce(f.face_save_pv,0)>=1 then '4:Face成功保存'
    -- end face_use_type
    ,case when coalesce(f.face_click_pv,0)=0 then '未进入Face'
          when coalesce(s.is_sub_enter_face,0)>=1 then 'Face被拦截'
          when coalesce(s.is_sub_enter_face,0)=0 then 'Face未被拦截'
    end face_use_type
    ,case when s.is_sub=1 then 1 else 0 end is_sub
    ,case when s.is_sub_face=1 then 1 else 0 end is_sub_face
    ,case when coalesce(f.face_click_pv,0)<=2 then coalesce(f.face_click_pv,0) else 999 end face_click_pv
    ,count(1) uv
    ,count(case when a1.user_pseudo_id is not null then 1 end) retention_1_uv
    ,count(case when s.is_sub=1 then 1 end) sub_uv
    ,count(case when s.sub_amt>0 then 1 end) pay_uv
    ,round(sum(s.sub_amt),2) sub_amt
    ,count(case when s.is_sub_face=1 then 1 end) sub_face_uv
    ,count(case when s.sub_amt_face>0 then 1 end) pay_face_uv
    ,round(sum(s.sub_amt_face),2) sub_amt_face
    ,count(case when f.face_click_pv>=1 then 1 end) face_click_uv
    ,sum(f.face_click_pv) face_click_pv
    -- 当日活跃用户在过去30天（含当日）内 Retouch-Face「使用」总次数（按用户日汇总后再按分层求和）
    ,sum(coalesce(f30.face_use_30d_pv, 0)) face_use_30d_pv
from active a
left join dataintegration-265403.temp.winne_temp_pay_detail_type d
on a.event_date_hk=d.active_date and a.user_pseudo_id=d.user_pseudo_id
left join sub s
on a.event_date_hk=s.event_date and a.user_pseudo_id=s.user_pseudo_id
left join function_use f
on a.event_date_hk=f.event_date and a.user_pseudo_id=f.user_pseudo_id
left join function_use_face_30d f30
on a.event_date_hk=f30.event_date_hk and a.user_pseudo_id=f30.user_pseudo_id
left join active a1 
on a.user_pseudo_id=a1.user_pseudo_id and a.event_date_hk=date_sub(a1.event_date_hk,interval 1 day)
where a.event_date_hk between '2025-01-01' and '2025-12-31'
group by 1,2,3,4,5,6,7,8,9


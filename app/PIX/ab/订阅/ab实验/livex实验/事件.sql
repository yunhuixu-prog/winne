drop table if exists `dataintegration-265403.temp.winne_temp_air_livex_user_seq`;
create table `dataintegration-265403.temp.winne_temp_air_livex_user_seq` as

with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
--     ,,timestamp_micros(event_timestamp) times
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,coalesce(func.getParams(event_params,'SKU').string_value,func.getParams(event_params,'sku').string_value) sku
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getParams(event_params,'content').string_value content
    ,func.getParams(event_params,'type').string_value type
    ,func.getParams(event_params,'prf_fail_reason').string_value prf_fail_reason
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success','appstore_pay_fail'
        ,'question_pop_show','question_pop_submit','question_proplan_show','question_pop_sub_success'
        ,'livex_ai_agent_show','livex_ai_agent_sub_click','livex_ai_agent_sub_success','livex_ai_agent_sub_fail')
    and _table_suffix between '20260216' and '20260323'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between '2026-02-17' and'2026-03-22'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
)
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('28580','28582')
      and _table_suffix between '20260216' and '20260323'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between '2026-02-17' and'2026-03-22'
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2026-02-17' and'2026-03-22'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.device_id,e.platform,e.ab_code,e.enter_abtest_date,e.event_timestamp,e.user_pseudo_id
            ,row_number() over(partition by e.device_id order by event_timestamp) ranks
        from  act fa
        join
           enter_test e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code,country)
        ,c.is_new,c.country
        ,b.ab_code,b.enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
    join enter b
    on a.device_id= b.device_id
    join act c on a.user_pseudo_id= c.user_pseudo_id and a.date=c.event_date_hk
--     where b.enter_abtest_date  <= a.date -- 事件发生的日期均 >= 进入实验日期
    where b.event_timestamp-150000 <= a.event_timestamp

    union all

    select distinct enter_abtest_date date
    ,b.platform,c.user_pseudo_id
    ,'enter_abtest' event_name
    ,b.device_id
    ,b.event_timestamp
    ,cast(null as string) source_module
    ,cast(null as string) source_0
    ,cast(null as string) source_1
    ,cast(null as string) duration
    ,cast(null as string) sku
    ,cast(null as string) order_id
    ,cast(null as string) type
    ,cast(null as string) content
    ,cast(null as string) prf_fail_reason
    ,null pv
    ,c.is_new,c.country
    ,b.ab_code,b.enter_abtest_date
    from enter b
    join act c on b.user_pseudo_id= c.user_pseudo_id and b.enter_abtest_date=c.event_date_hk
)
select * from fe

;

-- with group_event as
-- (
--     select date,device_id,event_name,event_timestamp,ab_code
--             ,sum(if(event_name!=coalesce(pre_event_name,''),1,0)) over(partition by device_id order by event_timestamp) group_event_rank
--     from
--     (
--         select date,device_id,event_timestamp,ab_code
--              ,case when event_name in ('question_proplan_show','question_pop_sub_success') then concat(event_name,'-',content)
-- --                    when event_name in ('w_subscription_enter') then concat(event_name,'-',source_0)
--              else event_name end event_name
--     --          ,row_number() over(partition by event_date,device_id order by event_timestamp) event_rank
--              ,lag(event_name) over(partition by device_id order by event_timestamp) pre_event_name
--         from `dataintegration-265403.temp.winne_temp_air_livex_user_seq`
-- --         where user_pseudo_id='7759387390884A3CB99133190763DADA'
--     )
-- )
-- ,
-- user_behavior_seq as
-- (
--     select device_id,group_event_rank,event_name,ab_code
--          ,count(1) nums,min(event_timestamp) start_event_timestamp
--     from group_event
--     group by 1,2,3,4
-- )
-- ,user_behavior_seqs as
-- (
--     select device_id,ab_code
--             ,STRING_AGG(case when nums=1 then event_name
--                   when nums>1 then concat(event_name,'*',cast(nums as string))
--             end,',' order by group_event_rank) seq_has_times
--             ,STRING_AGG(event_name,',' order by group_event_rank) seq
--     from user_behavior_seq
--     where group_event_rank<=10
--     group by 1,2
-- )
--
-- select u.ab_code
--      ,if(s.device_id is null,0,1) is_sub
--      ,seq
--      ,count(distinct u.device_id) uv
-- from user_behavior_seqs u
-- left join (select distinct device_id,ab_code from `dataintegration-265403.temp.winne_temp_air_livex_user_seq` where event_name = 'w_subscription_success') s
-- on u.device_id=s.device_id and u.ab_code=s.ab_code
-- group by 1,2,3
--
-- ;

select
    a.date,
    a.platform
    ,case when ab_code in ('28580') then '对照组'
         when ab_code in ('28582') then '实验组'
        end code
    ,a.ab_code
--     ,a.enter_abtest_date
    -- 付费
    --分层
--     ,a.duration
--     ,a.is_new
--     ,case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
    ,a.event_name
    ,if(b.event_name='question_pop_show','question','livex') pop_show
    ,a.sku
    ,case when a.content in ('1','2','3','straight','question','trial_7','promotional','null') or a.content is null then a.content
    else 'others' end content
    ,count(distinct a.device_id) uv
from `dataintegration-265403.temp.winne_temp_air_livex_user_seq` a
left join
(
    select device_id,max(event_name) event_name
    from `dataintegration-265403.temp.winne_temp_air_livex_user_seq` where event_name in ('livex_ai_agent_show','question_pop_show')
    group by device_id
) b
on a.device_id = b.device_id
group by 1,2,3,4,5,6,7,8
;
--
-- select
--     case when ab_code in ('28580') then '对照组'
--          when ab_code in ('28582') then '实验组'
--         end code
--     --分层
-- --     ,a.duration
-- --     ,a.is_new
-- --     ,case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
--     ,a.sku
--     ,case when a.event_timestamp-b.event_timestamp <= 1000000*30 then '1:<=30s'
--           when a.event_timestamp-b.event_timestamp <= 1000000*60 then '2:30~1min'
--           when a.event_timestamp-b.event_timestamp <= 1000000*60*5 then '3:1min~5min'
--           when a.event_timestamp-b.event_timestamp <= 1000000*60*15 then '4:5min~15min'
--           when a.event_timestamp-b.event_timestamp > 1000000*60*15 then '5:>15min'
-- --           when a.event_timestamp-b.event_timestamp <= 1000000*60*60*24 then '5:1h~24h'
-- --           when a.event_timestamp-b.event_timestamp > 1000000*60*60*24 then '6:>24h'
--     end sub_time
--     ,count(distinct a.device_id) uv
-- from
-- (
--     select date,event_timestamp,device_id,sku,ab_code,duration
--     from `dataintegration-265403.temp.winne_temp_air_livex_user_seq`
--     where event_name='w_subscription_success'
-- ) a
-- left join
-- (
--     select date,event_timestamp,device_id
--     from `dataintegration-265403.temp.winne_temp_air_livex_user_seq`
--     where event_name='enter_abtest'
-- ) b
-- on a.device_id=b.device_id
-- group by 1,2,3

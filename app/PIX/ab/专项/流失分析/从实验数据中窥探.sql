drop table if exists `dataintegration-265403.temp.new_user_behavior_analysis_winne`;
create table if not exists `dataintegration-265403.temp.new_user_behavior_analysis_winne` as

with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
    ,func.getParams(event_params,'trace_info').string_value as trace_info
    ,func.getParams(event_params,'first_func').string_value as first_func
    ,func.getParams(event_params,'second_func').string_value as second_func
    ,func.getParams(event_params,'third_func').string_value as third_func
    ,func.getParams(event_params,'prf_first_func').string_value as prf_first_func
    ,func.getParams(event_params,'prf_second_func').string_value as prf_second_func
    ,func.getParams(event_params,'prf_third_func').string_value as prf_third_func
    ,func.getParams(event_params,'prf_material_type').string_value as prf_material_type
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
    ,func.getParams(event_params,'SKU').string_value as sku
    ,func.getParams(event_params,'order_id').string_value as order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-20','2025-07-26','airbrush',true)
where
    event_name in ('edit_enter','edit_save','w_subscription_enter','w_subscription_click','w_subscription_success'
    ,'first_func_enter','second_func_enter','third_func_enter','first_func_use','second_func_use','third_func_use'
    )
--     and _table_suffix between '20250719' and '20250727'
--    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-07-20' and'2025-07-26'
)
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
  --  ,event_timestamp
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-20','2025-07-26','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11075','11076')
--       and _table_suffix between '20250719' and '20250727'
--    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-07-20' and'2025-07-26'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code),b.ab_code,b.date enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
         join enter_test b on a.user_pseudo_id= b.user_pseudo_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,trace_rank as
(
    select *
        , row_number() over(partition by user_pseudo_id order by event_timestamp) trace_rank
        , row_number() over(partition by date,user_pseudo_id order by event_timestamp) trace_day_rank
    from
    (
        select date, platform, user_pseudo_id, trace_info, min(event_timestamp) event_timestamp
        from fe
        where event_name='edit_enter'
        and trace_info is not null
        group by 1,2,3,4
    )
)
,active as
(
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-07-20' and'2025-07-26'
        and  app_name = 'AirBrush'
)

select f.*,a.uuid,a.is_new
--      ,t.trace_rank,t.trace_day_rank
from fe f
join active a on f.date = a.event_date_hk and f.user_pseudo_id = a.user_pseudo_id
-- left join trace_rank t
-- on f.date=t.date and f.platform=t.platform and f.user_pseudo_id=t.user_pseudo_id and f.trace_info=t.trace_info
;



select date,ab_code,platform
       ,count(distinct case when event_name = 'edit_enter' then user_pseudo_id end) edit_enter_uv
       ,count(distinct case when event_name in ('first_func_use','second_func_use','third_func_use') then user_pseudo_id end) edit_use_uv
       ,count(distinct case when event_name = 'edit_save' then user_pseudo_id end) edit_save_uv
       ,count(case when event_name = 'edit_enter' then 1 end) edit_enter_pv
       ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) edit_use_pv
       ,count(case when event_name = 'edit_save' then 1 end) edit_save_pv
from `dataintegration-265403.temp.new_user_behavior_analysis_winne`
where date_diff(date,enter_abtest_date,day)=0 and is_new=1
group by 1,2,3
;


with save_func as
(
    select distinct 'first' levels,date,platform,ab_code,user_pseudo_id,event_timestamp,f func
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`,unnest(split(prf_first_func,',')) f
    where event_name in ('edit_save')
        and date_diff(date,enter_abtest_date,day)=0
        and is_new=1

    union all

    select distinct 'second' levels,date,platform,ab_code,user_pseudo_id,event_timestamp,f func
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`,unnest(split(prf_second_func,',')) f
    where event_name in ('edit_save')
        and date_diff(date,enter_abtest_date,day)=0
        and is_new=1

    union all

    select distinct 'third' levels,date,platform,ab_code,user_pseudo_id,event_timestamp,f func
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`,unnest(split(prf_third_func,',')) f
    where event_name in ('edit_save')
        and date_diff(date,enter_abtest_date,day)=0
        and is_new=1
)
,
enter_use_func as
(
    select date,ab_code,platform
            ,'first' levels
            ,first_func
            ,'All' second_func
            ,'All' third_func
            ,first_func func
            ,count(distinct case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then user_pseudo_id end) fuc_enter_uv
            ,count(distinct case when event_name in ('first_func_use','second_func_use','third_func_use') then user_pseudo_id end) func_use_uv
            ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) fuc_enter_pv
            ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) func_use_pv
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`
    where date_diff(date,enter_abtest_date,day)=0
        and is_new=1
        and event_name in ('first_func_enter','first_func_use')
    group by 1,2,3,4,5,6,7,8

    union all

    select date,ab_code,platform
            ,'second' levels
            ,first_func
            ,second_func
            ,'All' third_func
            ,second_func func
            ,count(distinct case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then user_pseudo_id end) fuc_enter_uv
            ,count(distinct case when event_name in ('first_func_use','second_func_use','third_func_use') then user_pseudo_id end) func_use_uv
            ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) fuc_enter_pv
            ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) func_use_pv
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`
    where date_diff(date,enter_abtest_date,day)=0
        and is_new=1
        and event_name in ('second_func_enter','second_func_use')
    group by 1,2,3,4,5,6,7,8

    union all

    select date,ab_code,platform
            ,'third' levels
            ,first_func
            ,second_func
            ,fi third_func
            ,fi func
            ,count(distinct case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then user_pseudo_id end) fuc_enter_uv
            ,count(distinct case when event_name in ('first_func_use','second_func_use','third_func_use') then user_pseudo_id end) func_use_uv
            ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) fuc_enter_pv
            ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) func_use_pv
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`,unnest(split(third_func,',')) fi
    where date_diff(date,enter_abtest_date,day)=0
        and is_new=1
        and event_name in ('third_func_enter','third_func_use')
    group by 1,2,3,4,5,6,7,8
)

select e.levels,e.date,e.platform,e.ab_code,e.first_func,e.second_func,e.third_func
    ,e.fuc_enter_uv,e.func_use_uv,e.fuc_enter_pv,e.func_use_pv
    ,coalesce(s.save_uv) save_uv,coalesce(s.save_pv) save_pv
from enter_use_func e
-- 可能不同一级二级下的功能名字有一样的，只关联func就重合了，算多了就
left join
(
    select levels,date,platform,ab_code,func
        ,count(distinct user_pseudo_id) save_uv
        ,count(1) save_pv
    from save_func
    group by 1,2,3,4,5
) s
on e.levels=s.levels and e.date=s.date and e.platform=s.platform and e.ab_code=s.ab_code and e.func=s.func


;




select a.date,a.platform,a.ab_code
    ,count(distinct a.user_pseudo_id) edit_enter_uv
    ,count(distinct b.user_pseudo_id) edit_use_uv
    ,count(distinct c.user_pseudo_id) edit_save_uv_1
    ,count(distinct case when b.user_pseudo_id is not null then c.user_pseudo_id end) edit_save_uv_2
from
(
    -- 进入编辑器的用户
    select distinct date,platform,ab_code,user_pseudo_id
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`
    where event_name='edit_enter' and date_diff(date,enter_abtest_date,day)=0 and is_new=1
) a
left join
(
    -- 打勾的用户
    select date,platform,ab_code,user_pseudo_id,count(1) edit_use_pv
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`
    where event_name in ('first_func_use','second_func_use','third_func_use') and date_diff(date,enter_abtest_date,day)=0 and is_new=1
    group by 1,2,3,4
) b
on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id
left join
(
    -- 进入功能的用户
    select date,platform,ab_code,user_pseudo_id,count(1) edit_save_pv
    from `dataintegration-265403.temp.new_user_behavior_analysis_winne`,unnest(split(prf_first_func,',')) fi
    where event_name in ('edit_save') and is_new=1
    group by 1,2,3,4
) c
on a.date=c.date and a.platform=c.platform and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3







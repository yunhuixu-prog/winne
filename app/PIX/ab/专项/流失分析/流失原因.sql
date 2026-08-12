drop table if exists `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`;
create table if not exists `dataintegration-265403.temp.winne_user_thurn_behavior_analysis` as

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
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('edit_enter','edit_save','w_subscription_enter','w_subscription_click','w_subscription_success'
    ,'first_func_enter','second_func_enter','third_func_enter','first_func_use','second_func_use','third_func_use'
    ,'trial_info'
    )
    and _table_suffix between'20250802' and '20250810'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-03' and'2025-08-09'
)
,active as
(
    -- 活跃表
    select
        event_date_hk, user_pseudo_id, platform, uuid, is_new
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-08-03' and'2025-08-09'
        and  app_name = 'AirBrush'
)
,trace_rank as
(
    select *
--         , row_number() over(partition by user_pseudo_id order by event_timestamp) trace_rank
        , row_number() over(partition by date,user_pseudo_id order by event_timestamp) trace_rank
    from
    (
        select date, platform, user_pseudo_id, trace_info, min(event_timestamp) event_timestamp
        from eves
        where event_name='edit_enter'
        and trace_info is not null
        group by 1,2,3,4
    )
)

select f.*,a.uuid,a.is_new,t.trace_rank
from eves f
join active a on f.date = a.event_date_hk and f.user_pseudo_id = a.user_pseudo_id
left join trace_rank t
on f.date=t.date and f.platform=t.platform and f.user_pseudo_id=t.user_pseudo_id and f.trace_info=t.trace_info
;


-- 新用户进入编辑后，打勾/不打勾用户 使用功能/子功能的分布
select platform,is_use,types,first_func,second_func,third_func
     ,round(sum(click_uv)/7) click_uv
     ,round(sum(click_pv)/7) click_pv
from
(
select a.date,a.platform
    ,if(b.user_pseudo_id is null,0,1) is_use
    ,c.types,c.first_func,c.second_func,c.third_func
    ,count(distinct a.user_pseudo_id) click_uv
    ,sum(c.pv) click_pv
from
(
    -- 进入编辑器的用户
    select distinct date,platform,user_pseudo_id
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name='edit_enter' and is_new=1
) a
left join
(
    -- 打勾的用户
    select distinct date,platform,user_pseudo_id
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('first_func_use','second_func_use','third_func_use')
) b
on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id
join
(
    -- 进入功能的用户
    select date,platform,'一级' types,user_pseudo_id,first_func,'All' second_func,'All' third_func,count(1) pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('first_func_enter')
    group by 1,2,3,4,5,6,7

    union all

    select date,platform,'二级' types,user_pseudo_id,first_func,second_func,'All' third_func,count(1) pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('second_func_enter')
    group by 1,2,3,4,5,6,7

    union all

    select date,platform,'三级' types,user_pseudo_id,first_func,second_func,third_func,count(1) pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('third_func_enter')
    group by 1,2,3,4,5,6,7
) c
on a.date=c.date and a.platform=c.platform and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6
;


-- 新用户点击打勾后，为什么没有保存
select platform,sub_enter_pv
     ,round(sum(uv)/7) uv
     ,round(sum(save_uv)/7) save_uv
from
(
select a.date,a.platform
    ,coalesce(b.sub_enter_pv,0) sub_enter_pv
    ,count(distinct a.user_pseudo_id) uv
    ,count(distinct c.user_pseudo_id) save_uv
from
(
    -- 打勾的用户
    select distinct date,platform,user_pseudo_id
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('first_func_use','second_func_use','third_func_use') and is_new=1
) a
left join
(
    -- 在edit下弹出订阅弹窗的次数
    select date,platform,user_pseudo_id,count(1) sub_enter_pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('w_subscription_enter') and source_module='p_edit'
    group by 1,2,3
) b
on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id
left join
(
    -- 是否保存
    select date,platform,user_pseudo_id,count(1) pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('edit_save')
    group by 1,2,3
) c
on a.date=c.date and a.platform=c.platform and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3
)
group by 1,2
order by 1,2
;



-- 新用户进入订阅页后的行为
with first_sub_enter as
(
    select date,platform,user_pseudo_id,min(event_timestamp) timestamp_start
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('w_subscription_enter') and source_module='p_edit' and is_new=1
    group by 1,2,3
)

select platform,is_edit_enter,is_edit_save,is_enter_func,func_use_pv,sub_enter_pv,is_sub_suc
    ,round(sum(uv)/7) uv
from
(
select date,platform
     ,if(edit_enter_pv>0,1,0) is_edit_enter
     ,if(edit_save_pv>0,1,0) is_edit_save
     ,if(coalesce(enter_first_func_pv,0)+coalesce(enter_second_func_pv,0)+coalesce(enter_third_func_pv,0)>0,1,0) is_enter_func
--      ,if(func_use_pv>0,1,0) is_func_use
     ,coalesce(func_use_pv,0) func_use_pv
     ,coalesce(sub_enter_pv,0) sub_enter_pv
     ,if(sub_success_pv>0,1,0) is_sub_suc
     ,count(distinct user_pseudo_id) uv
from
(
    select a.date,a.platform,a.user_pseudo_id
        ,count(case when b.event_name in ('edit_enter') then 1 end) edit_enter_pv
        ,count(case when b.event_name in ('edit_save') then 1 end) edit_save_pv
        ,count(case when b.event_name in ('w_subscription_enter') and source_module='p_edit' then 1 end) sub_enter_pv
        ,count(case when b.event_name in ('w_subscription_success') and source_module='p_edit' then 1 end) sub_success_pv
        ,count(case when b.event_name in ('first_func_enter') then 1 end) enter_first_func_pv
        ,count(case when b.event_name in ('second_func_enter') then 1 end) enter_second_func_pv
        ,count(case when b.event_name in ('third_func_enter') then 1 end) enter_third_func_pv
        ,count(case when b.event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) func_use_pv
    from first_sub_enter a
    left join `dataintegration-265403.temp.winne_user_thurn_behavior_analysis` b
    on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and b.event_timestamp>a.timestamp_start
    group by 1,2,3
)
group by 1,2,3,4,5,6,7,8
)
group by 1,2,3,4,5,6,7
;



-- 新用户进入X次订阅页后的行为
with first_sub_enter as
(
    select distinct date,platform,user_pseudo_id,event_timestamp,row_number() over(partition by date,user_pseudo_id order by event_timestamp) ranks
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('w_subscription_enter') and source_module='p_edit' and is_new=1
)

select platform,ranks,is_edit_enter,is_edit_save,is_enter_func,is_func_use,is_sub_enter,is_sub_suc
    ,round(sum(uv)/7) uv
from
(
select date,platform,ranks
     ,if(edit_enter_pv>0,1,0) is_edit_enter
     ,if(edit_save_pv>0,1,0) is_edit_save
     ,if(coalesce(enter_first_func_pv,0)+coalesce(enter_second_func_pv,0)+coalesce(enter_third_func_pv,0)>0,1,0) is_enter_func
     ,if(func_use_pv>0,1,0) is_func_use
--      ,coalesce(func_use_pv,0) func_use_pv
     ,if(sub_enter_pv>0,1,0) is_sub_enter
--      ,coalesce(sub_enter_pv,0) sub_enter_pv
     ,if(sub_success_pv>0,1,0) is_sub_suc
     ,count(distinct user_pseudo_id) uv
from
(
    select a.date,a.platform,a.ranks,a.user_pseudo_id
        ,count(case when b.event_name in ('edit_enter') then 1 end) edit_enter_pv
        ,count(case when b.event_name in ('edit_save') then 1 end) edit_save_pv
        ,count(case when b.event_name in ('w_subscription_enter') and source_module='p_edit' then 1 end) sub_enter_pv
        ,count(case when b.event_name in ('w_subscription_success') and source_module='p_edit' then 1 end) sub_success_pv
        ,count(case when b.event_name in ('first_func_enter') then 1 end) enter_first_func_pv
        ,count(case when b.event_name in ('second_func_enter') then 1 end) enter_second_func_pv
        ,count(case when b.event_name in ('third_func_enter') then 1 end) enter_third_func_pv
        ,count(case when b.event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) func_use_pv
    from first_sub_enter a
    left join `dataintegration-265403.temp.winne_user_thurn_behavior_analysis` b
    on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id and b.event_timestamp>a.event_timestamp
    group by 1,2,3,4
)
group by 1,2,3,4,5,6,7,8,9
)
group by 1,2,3,4,5,6,7,8
;






-- 未订阅的用户要弹几次
select platform,is_sub,sub_enter_pv
     ,round(sum(uv)/7) uv
from
(
select a.date,a.platform
    ,if(c.user_pseudo_id is not null,1,0) is_sub
    ,coalesce(b.sub_enter_pv,0) sub_enter_pv
    ,count(distinct a.user_pseudo_id) uv
from
(
    -- 进入编辑器的用户
    select distinct date,platform,user_pseudo_id
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('edit_enter') and is_new=1
) a
left join
(
    -- 在edit下弹出订阅弹窗的次数
    select date,platform,user_pseudo_id,count(1) sub_enter_pv
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('w_subscription_enter') and source_module='p_edit'
    group by 1,2,3
) b
on a.date=b.date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id
left join
(
    -- 是否订阅
    select date,platform,user_pseudo_id
    from `dataintegration-265403.temp.winne_user_thurn_behavior_analysis`
    where event_name in ('w_subscription_success') and source_module='p_edit'
    group by 1,2,3
) c
on a.date=c.date and a.platform=c.platform and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4
)
group by 1,2,3
order by 1,2,3

-- 老口径
select event_date,event_name,platform
    ,func.getParams(event_params,'type').string_value type
    ,func.getParams(event_params,'button').string_value button
    ,case when func.getParams(event_params,'is_vip').string_value in ('1','true') then 1 else 0 end is_vip
    ,case when func.getParams(event_params,'is_platform_vip').string_value in ('1','true') then 1 else 0 end is_platform_vip
    ,case when func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then 1 else 0 end is_tripartite_vip
    ,count(1) pv
    ,count(distinct user_pseudo_id) uv
--     ,count(distinct case when event_name='user_vip_status'
--                   and func.getParams(event_params,'is_platform_vip').string_value in ('1','true')
--                   and func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then user_pseudo_id end) platform_and_tripartite_vip_uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-11-02','airbrush',false)
where
    event_name in  ('user_vip_status')
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
group by 1,2,3,4,5,6,7,8
;

select event_date,event_timestamp
    ,func.getUserprop(user_properties,'hwgid').string_value hwgid
    ,func.getUserprop(user_properties,'original_order_id').string_value original_order_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-11-02','airbrush',false)
where
    event_name in  ('user_vip_status')
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
    and func.getParams(event_params,'is_platform_vip').string_value not in ('1','true')
    and func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true')

;

-- 新口径
select date_p event_date,event_id event_name,platform,type,button,is_vip,is_platform_vip,is_tripartite_vip
    ,count(1) pv,count(distinct gid) uv
from
(
    select date_p,event_id
        ,sdk_type platform
        ,params['type'] type
        ,params['button'] button
        ,case when params['is_vip'] in ('1','true') then 1 else 0 end is_vip
        ,case when params['is_platform_vip'] in ('1','true') then 1 else 0 end is_platform_vip
        ,case when params['is_tripartite_vip'] in ('1','true') then 1 else 0 end is_tripartite_vip
        ,gid
    from stat_sdk.sdk_odz_source_data
    where date_p between 20251029 and 20260120
        and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and event_id in  ('user_vip_status')
        and app_version>='7.19.0'
) a
group by date_p,event_id,platform,type,button,is_vip,is_platform_vip,is_tripartite_vip
;
-- 'restore_purchase_popup_show','restore_purchase_popup_click',


-- 中台无会员三方有会员明细
with vip_status as
(
    select
        sdk_type,
        date_p,`time`,gid
        ,params['uid'] uid
        ,params['saasid'] saasid
        ,params['gid'] gid_order
        ,params['otid'] otid
        ,params['reason'] reason
    from stat_sdk.sdk_odz_source_data
    where date_p between 20251112 and 20251204
        and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and event_id in  ('user_vip_status')
        and app_version>='7.20.0'
        and params['is_platform_vip'] not in ('1','true')
        and params['is_tripartite_vip'] in ('1','true')
)
,
pop as
(
    select
        sdk_type,gid,
        min(case when event_id = 'restore_purchase_popup_show' then date_p end) first_pop_date,
        max(case when event_id = 'restore_purchase_popup_click' then 1 else 0 end) is_pop_click,
        max(case when event_id = 'restore_purchase_click' then 1 else 0 end) is_restore_click,
        max(case when event_id = 'restore_purchase_success' then 1 else 0 end) is_restore_success
    from stat_sdk.sdk_odz_source_data
    where date_p between 20251029 and 20251204
        and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and (
                (event_id='restore_purchase_popup_show' and params['type']='恢复购买提醒')
                    or
                (event_id='restore_purchase_popup_click' and params['button']='continue' and params['type']='恢复购买提醒')
                    or
                event_id in ('restore_purchase_click','restore_purchase_success')
            )
        and app_version>='7.19.0'
    group by sdk_type,gid
)
select v.date_p event_date
	,v.sdk_type sdk_type
    ,v.`time` `time`
    ,v.gid gid
    ,v.uid uid
    ,v.saasid saasid
    ,v.gid_order gid_order
    ,v.otid otid
    ,v.first_otid
    ,c.order_id tid
    ,v.reason reason
	,if(p.first_pop_date is NULL,0,1) is_pop
    ,p.first_pop_date first_pop_date
    ,nvl(p.is_restore_click,0) is_restore_click
    ,nvl(p.is_restore_success,0) is_restore_success
from (select *,SPLIT(COALESCE(vip_status.otid,'无'), ',')[0] first_otid from vip_status) v
left join (select * from pop) p
on v.gid=p.gid and v.sdk_type=p.sdk_type
-- where vip_status.gid is not NULL and vip_status.original_order_id is not NULL
-- otid取最新tid
left join (
    select contract_id,order_id
          from stat_vip.paid_oda_vip_all_order
          WHERE date_p=20251204
                and app_id_p IN (7329803307041000000, 7329803307042000000)
                and commodity_id_P not in (-1)
                and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0
                and last_order_flag=1

    select contract_id,order_id
          from stat_vip.paid_sda_vip_tb_contract
          WHERE date_p=20251204
                and app_id_p IN (7329803307041000000, 7329803307042000000)
                and commodity_id_P not in (-1)
                and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0
                and last_order_flag=1
) c
on v.first_otid=c.contract_id
order by v.date_p,v.gid

;
select vip_status.date_p,vip_status.sdk_type
    ,count(distinct vip_status.gid) uv
    ,count(1) pv
    ,count(distinct case when vip_status.original_order_id is NULL then vip_status.gid end) uv_no_order
    ,count(distinct case when pop.first_pop_date is not NULL then vip_status.gid end) uv_has_pop
    ,count(case when vip_status.original_order_id is NULL then 1 end) pv_no_order
    ,count(case when pop.gid is not NULL then 1 end) pv_has_pop
from vip_status
left join pop
on vip_status.gid=pop.gid and vip_status.sdk_type=pop.sdk_type
group by vip_status.date_p,vip_status.sdk_type

;

-- 测试
select event_date,event_name,platform
    ,func.getUserprop(user_properties,'hwgid').string_value gid
    ,func.getParams(event_params,'type').string_value type
    ,func.getParams(event_params,'button').string_value button
    ,case when func.getParams(event_params,'is_vip').string_value in ('1','true') then 1 else 0 end is_vip
    ,case when func.getParams(event_params,'is_platform_vip').string_value in ('1','true') then 1 else 0 end is_platform_vip
    ,case when func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then 1 else 0 end is_tripartite_vip
    ,user_pseudo_id
--     ,count(distinct case when event_name='user_vip_status'
--                   and func.getParams(event_params,'is_platform_vip').string_value in ('1','true')
--                   and func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then user_pseudo_id end) platform_and_tripartite_vip_uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-30','2025-10-30','airbrush',false)
where
    event_name in  ('user_vip_status')
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
    and func.getParams(event_params,'is_platform_vip').string_value not in ('1','true')
    and func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true')
;
select event_date,event_name,platform,event_timestamp
    ,func.getUserprop(user_properties,'hwgid').string_value gid
    ,func.getParams(event_params,'type').string_value type
    ,func.getParams(event_params,'button').string_value button
    ,case when func.getParams(event_params,'is_vip').string_value in ('1','true') then 1 else 0 end is_vip
    ,case when func.getParams(event_params,'is_platform_vip').string_value in ('1','true') then 1 else 0 end is_platform_vip
    ,case when func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then 1 else 0 end is_tripartite_vip
    ,user_pseudo_id
--     ,count(distinct case when event_name='user_vip_status'
--                   and func.getParams(event_params,'is_platform_vip').string_value in ('1','true')
--                   and func.getParams(event_params,'is_tripartite_vip').string_value in ('1','true') then user_pseudo_id end) platform_and_tripartite_vip_uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-20','2025-10-30','airbrush',false)
where
    event_name in  ('restore_purchase_popup_show','restore_purchase_popup_click','user_vip_status')
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0')
    and user_pseudo_id='cba4a0f40998060642dad1747149dabd'
--     and func.getUserprop(user_properties,'hwgid').string_value='2657171984'
order by event_timestamp


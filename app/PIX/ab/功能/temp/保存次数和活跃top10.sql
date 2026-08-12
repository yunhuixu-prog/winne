drop table if exists `dataintegration-265403.temp.winne_save_and_active_top_10`;
create table if not exists `dataintegration-265403.temp.winne_save_and_active_top_10` as

with save as
(
    select user_pseudo_id,country,count(1) save_pv
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-10-31','airbrush',false)
    where
        event_name = 'edit_save'
--         and country='United States'
    group by 1,2
)
,active as
(
     select
        user_pseudo_id,country,count(distinct event_date_hk) active_days
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-10-01' and '2025-10-31'
        and app_name = 'AirBrush'
--         and country='United States'
    group by 1,2
)
,active_uuid as
(
     select
        distinct uuid,user_pseudo_id
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-10-01' and '2025-10-31'
        and app_name = 'AirBrush'
--         and country='United States'
)
,vpu as
(
--     select distinct original_order_id,uuid
--     from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
--     where event_date_hk='2025-11-10'
--         and order_status in (1,2)
--         and app_id='AirBrush'
--         and offer_method = 'normal'
--         and standard_refund_date is null
--         and standard_order_date<='2025-10-31'
--         and (standard_order_expire_date>='2025-10-01' or subscription_period ='lifetime')
    select distinct uuid,original_order_id
    from dataintegration-265403.dwd.dwd_map_subscription_order_detail
    where event_date='2025-10-01'
        and app_name='AirBrush'
        and is_valid_paid_order_his=1
--         and country='United States'
)
,vpu_and_active as
(
    select distinct a.user_pseudo_id,v.uuid
    from vpu v
    join active_uuid a
    on v.uuid=a.uuid
)

select a.user_pseudo_id,a.country
    ,a.active_days
    ,coalesce(s.save_pv,0) save_pv
    ,if(v.user_pseudo_id is not null,1,0) is_valid_paid
    ,v.uuid valid_uid
from active a
left join save s
on a.user_pseudo_id=s.user_pseudo_id and a.country=s.country
left join vpu_and_active v
on a.user_pseudo_id=v.user_pseudo_id


;

select
    case when save_pv<=200 then save_pv else 999 end save_pv_type
    ,count(1) mau
    ,sum(save_pv) save_pv
from `dataintegration-265403.temp.winne_save_and_active_top_10`
where country='United States'
group by 1
order by 1 desc
;
select
    active_days active_days_type
    ,count(1) mau
    ,sum(active_days) active_days
from `dataintegration-265403.temp.winne_save_and_active_top_10`
where country='United States'
group by 1
order by 1 desc
;

select
    count(1) mau
--     ,count(distinct case when is_valid_paid=1 then user_pseudo_id end) valid_mau
    ,count(distinct case when is_valid_paid=1 then valid_uid end) valid_mau_1
from `dataintegration-265403.temp.winne_save_and_active_top_10`
-- where save_pv>=150
where active_days>=9
    and country='United States'



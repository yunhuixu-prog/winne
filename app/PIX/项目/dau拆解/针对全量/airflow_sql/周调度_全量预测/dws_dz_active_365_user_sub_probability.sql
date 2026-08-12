-- drop table if exists dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability;
-- create table dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability as


delete from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability where date = '{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}';
insert into dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability

select a.event_date_hk date,a.gid,a.uuid,coalesce(b.predit_sub_365_proba,c.predit_sub_365_proba,d.predit_sub_365_proba) predit_sub_365_proba,'BeautyPlus' app_name
from
(
    select aa.event_date_hk,aa.gid,bb.uuid
    from
    (
        select event_date_hk,gid
        from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
        where event_date_hk='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.gid=bb.key
) a
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
    group by 1,2
) b
on a.uuid=b.uuid
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
    group by 1,2
) c
on a.uuid=c.uuid
left join
(
    select gid,uuid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
    where app_name in ('BeautyPlus')
        and date = date_sub('{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}',interval 7 day)
) d
on a.gid=d.gid and a.uuid=d.uuid

union all

select a.event_date_hk date,a.gid,a.uuid,coalesce(b.predit_sub_365_proba,c.predit_sub_365_proba,d.predit_sub_365_proba) predit_sub_365_proba,'AirBrush' app_name
from
(
    select aa.event_date_hk,aa.gid,bb.uuid
    from
    (
        select event_date_hk,gid
        from `airbrush-1324.dim.dim_dzp_portrait_gid_user`
        where event_date_hk='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.gid=bb.key
) a
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from airbrush-1324.temp.ads_dz_his_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
    group by 1,2
) b
on a.uuid=b.uuid
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}'
    group by 1,2
) c
on a.uuid=c.uuid
left join
(
    select gid,uuid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
    where app_name in ('AirBrush')
        and date = date_sub('{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5)).strftime("%Y-%m-%d") }}',interval 7 day)
) d
on a.gid=d.gid and a.uuid=d.uuid

--                            (
--                                 select max(date)
--                                 from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
--                                 where date between '{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--                                                 and '{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=6)).strftime("%Y-%m-%d") }}'
--                             )
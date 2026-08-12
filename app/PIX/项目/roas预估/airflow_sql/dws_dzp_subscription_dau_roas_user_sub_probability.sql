
delete from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability where date = '{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability

select a.date,a.uuid,a.install_days_type,a.sub_type,coalesce(b.predit_sub_365_proba,d.predit_sub_365_proba) predit_sub_365_proba,'BeautyPlus' app_name
from
(
    select distinct date,uuid,install_days_type,sub_type
    from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave_v
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
) a
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2
) b
on a.uuid=b.uuid
left join
(
    select distinct uuid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
    where app_name in ('BeautyPlus')
        and date = date_sub('{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 1 day)
) d
on a.uuid=d.uuid

union all

select a.date,a.uuid,a.install_days_type,a.sub_type,coalesce(b.predit_sub_365_proba,d.predit_sub_365_proba) predit_sub_365_proba,'AirBrush' app_name
from
(
    select distinct date,uuid,install_days_type,sub_type
    from airbrush-1324.temp.dws_dz_dau_split_and_roas_final_user_behave_v
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
) a
left join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
    where date='{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2
) b
on a.uuid=b.uuid
left join
(
    select distinct uuid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
    where app_name in ('AirBrush')
        and date = date_sub('{{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 1 day)
) d
on a.uuid=d.uuid


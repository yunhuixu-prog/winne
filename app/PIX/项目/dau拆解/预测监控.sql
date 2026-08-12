-- roas预测监控:ab<0.05,b+<0.05
select app_name,date
        ,count(distinct uuid) uv,count(distinct case when predict_sub_att_365_from_now is null then uuid end) null_uv
        ,count(distinct case when predict_sub_att_365_from_now is null then uuid end)/count(distinct uuid) null_ratio
from dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict
where date between '2024-09-01' and '2024-09-19' and is_current_pay=0 and days<=60
group by 1,2
order by 1,2

-- dau预测监控:ab<0.05,b+<0.2
select app_name,date
        ,count(distinct user_pseudo_id) uv,count(distinct case when predit_sub_365_proba is null then user_pseudo_id end) null_uv
        ,count(distinct case when predit_sub_365_proba is null then user_pseudo_id end)/count(distinct user_pseudo_id) null_ratio
from dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info
where date between '2024-09-01' and '2024-09-19' and is_current_sub=0 and is_current_consume=0
group by 1,2
order by 1,2

-- dau&roas预测监控
select app_name,date
        ,count(distinct uuid) uv,count(distinct case when predit_sub_365_proba is null then uuid end) null_uv
        ,count(distinct case when predit_sub_365_proba is null then uuid end)/count(distinct uuid) null_ratio
from dataintegration-265403.subscription.dws_dzp_subscription_dau_roas_user_sub_probability
where date between '2024-09-01' and '2024-09-19'
group by 1,2
order by 1,2


-- 全量预测监控:ab<0.1,b+<
select app_name,date
        ,count(distinct gid) uv,count(distinct case when predit_sub_365_proba is null then gid end) null_uv
        ,count(distinct case when predit_sub_365_proba is null then gid end)/count(distinct gid) null_ratio
from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
where date between '2024-09-01' and '2024-09-19'
group by 1,2
order by 1,2



-- 预测产出表监控
select 'dau' type,'BeautyPlus' app_name,date
       ,case when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 and is_edit_selfi_7=1 then 'else_1_2_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 and is_edit_selfi_7=0 then 'else_1_2_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 and is_edit_selfi_7=1 then 'else_3_4_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 and is_edit_selfi_7=0 then 'else_3_4_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_3_4_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_3_4_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 and is_edit_selfi_7=1 then 'else_5_6_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 and is_edit_selfi_7=0 then 'else_5_6_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_5_6_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_5_6_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_5_6_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_0_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=1 then 'else_7_10_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=0 then 'else_7_10_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_7_10_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_7_10_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_7_10_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_7_10_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=1 then 'else_7_10_0_0_0_0_0_0_1_1'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_1_0'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=0 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_his' and install_days_type between 1 and 4 then 'trial_his_1_4_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 5 and 6 then 'trial_his_5_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=1 then 'trial_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'trial_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'trial_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'trial_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'trial_his_7_10_0_0_0_0_0_0_0_0'
                   when sub_type = 'sub_his' and install_days_type between 1 and 6 then 'sub_his_1_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=1 then 'sub_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'sub_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'sub_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'sub_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'sub_his_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_now' then 'trial_now_1_10_all_all_all_all_all_all_all_all'
             else null
             end model_type
    ,count(distinct uuid)
from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
where date >= '2024-09-01'
group by 1,2,3,4
union all
select 'dau' type,'AirBrush' app_name,date
       ,case when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 then 'else_1_2_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 then 'else_3_4_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 then 'else_3_4_0_0_1_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 then 'else_5_6_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 then 'else_5_6_0_0_1_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_5_6_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_0_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=1 then 'else_7_10_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=0 then 'else_7_10_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_7_10_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_7_10_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_7_10_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_7_10_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=1 then 'else_7_10_0_0_0_0_0_0_1_1'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_1_0'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=0 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_his' and install_days_type between 1 and 4 then 'trial_his_1_4_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 5 and 6 then 'trial_his_5_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=1 then 'trial_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'trial_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'trial_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'trial_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'trial_his_7_10_0_0_0_0_0_0_0_0'
                   when sub_type = 'sub_his' and install_days_type between 1 and 6 then 'sub_his_1_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=1 then 'sub_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'sub_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'sub_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'sub_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'sub_his_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_now' then 'trial_now_1_10_all_all_all_all_all_all_all_all'
             else null
             end model_type
    ,count(distinct uuid)
from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
where date >= '2024-09-01'
group by 1,2,3,4
union all
select 'his' type,'BeautyPlus' app_name,date
       ,case when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 and is_edit_selfi_7=1 then 'else_1_2_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 and is_edit_selfi_7=0 then 'else_1_2_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 and is_edit_selfi_7=1 then 'else_3_4_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 and is_edit_selfi_7=0 then 'else_3_4_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_3_4_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_3_4_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 and is_edit_selfi_7=1 then 'else_5_6_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 and is_edit_selfi_7=0 then 'else_5_6_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_5_6_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_5_6_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_5_6_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_0_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=1 then 'else_7_10_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=0 then 'else_7_10_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_7_10_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_7_10_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_7_10_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_7_10_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=1 then 'else_7_10_0_0_0_0_0_0_1_1'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_1_0'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=0 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_his' and install_days_type between 1 and 4 then 'trial_his_1_4_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 5 and 6 then 'trial_his_5_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=1 then 'trial_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'trial_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'trial_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'trial_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'trial_his_7_10_0_0_0_0_0_0_0_0'
                   when sub_type = 'sub_his' and install_days_type between 1 and 6 then 'sub_his_1_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=1 then 'sub_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'sub_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'sub_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'sub_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'sub_his_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_now' then 'trial_now_1_10_all_all_all_all_all_all_all_all'
             else null
             end model_type
    ,count(distinct uuid)
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
where EXTRACT(DAYOFWEEK FROM date) = 5
group by 1,2,3,4
union all
select 'his' type,'AirBrush' app_name,date
       ,case when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 then 'else_1_2_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=1 then 'else_3_4_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 3 and 4 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 then 'else_3_4_0_0_1_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=1 then 'else_5_6_1_all_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 then 'else_5_6_0_0_1_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_5_6_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 5 and 6 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0 then 'else_5_6_0_0_0_0_0_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=1 then 'else_7_10_1_1_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=1 and is_edit_selfi_7=0 then 'else_7_10_1_0_all_all_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=1 then 'else_7_10_0_0_1_1_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=1 and is_edit_selfi_30=0 then 'else_7_10_0_0_1_0_all_all_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=1 then 'else_7_10_0_0_0_0_1_1_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=1 and is_edit_selfi_60=0 then 'else_7_10_0_0_0_0_1_0_all_all'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=1 then 'else_7_10_0_0_0_0_0_0_1_1'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=1 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_1_0'
                   when sub_type = 'else' and install_days_type between 7 and 10 and is_active_7=0 and is_edit_selfi_7=0
                                                                                and is_active_30=0 and is_edit_selfi_30=0
                                                                                and is_active_60=0 and is_edit_selfi_60=0
                                                                                and is_active_90=0 and is_edit_selfi_90=0 then 'else_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_his' and install_days_type between 1 and 4 then 'trial_his_1_4_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 5 and 6 then 'trial_his_5_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=1 then 'trial_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'trial_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'trial_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'trial_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'trial_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'trial_his_7_10_0_0_0_0_0_0_0_0'
                   when sub_type = 'sub_his' and install_days_type between 1 and 6 then 'sub_his_1_6_all_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=1 then 'sub_his_7_10_1_all_all_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=1 then 'sub_his_7_10_0_0_1_all_all_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=1 then 'sub_his_7_10_0_0_0_0_1_all_all_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=1 then 'sub_his_7_10_0_0_0_0_0_0_1_all'
                   when sub_type = 'sub_his' and install_days_type between 7 and 10 and is_active_7=0 and is_active_30=0
                                                                                        and is_active_60=0 and is_active_90=0 then 'sub_his_7_10_0_0_0_0_0_0_0_0'

                   when sub_type = 'trial_now' then 'trial_now_1_10_all_all_all_all_all_all_all_all'
             else null
             end model_type
    ,count(distinct uuid)
from airbrush-1324.temp.ads_dz_his_split_predict_sub_365
where EXTRACT(DAYOFWEEK FROM date) = 5
group by 1,2,3,4


-- temp
select event_date_hk,count(distinct user_pseudo_id),count(distinct case when first_active_date<'2022-01-01' then user_pseudo_id end)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk = '2024-07-05' and last_active_date>=date_sub(event_date_hk,interval 365 day)
group by 1
order by 1



-- 真实情况
-- 第二天活跃用户
select  a.date
--      sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
--     ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
from
(
    select date,sub_365,uuid
             ,sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
             ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
--       from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-05-01' and '2023-05-01'
) a
left join
(
    select uuid,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02'
      and app_name in ('BeautyPlus')
--       and app_name in ('AirBrush')
    group by 1,2
) b
on a.uuid=b.uuid and date_add(a.date,interval 1 day)=b.event_date_hk
-- where b.uuid is not null
group by 1
order by 1
;
select  a.date,sub_type
--      sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
--     ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
from
(
    select date,sub_365,uuid
             ,sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
             ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
--       from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-05-01' and '2023-05-01'
) a
left join
(
    select uuid,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02'
      and app_name in ('BeautyPlus')
--       and app_name in ('AirBrush')
    group by 1,2
) b
on a.uuid=b.uuid and date_add(a.date,interval 1 day)=b.event_date_hk
-- where b.uuid is not null
group by 1,2
order by 1,2
;
select  a.date,model_type
--      sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
--     ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
from
(
    select date,sub_365,uuid
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
             ,sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
             ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
--       from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-05-01' and '2023-05-01'
) a
left join
(
    select uuid,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02'
      and app_name in ('BeautyPlus')
--       and app_name in ('AirBrush')
    group by 1,2
) b
on a.uuid=b.uuid and date_add(a.date,interval 1 day)=b.event_date_hk
-- where b.uuid is not null
group by 1,2
order by 1,2




-- 预测表现
-- 部分用户会预测多次的处理一下
select uuid,count(1)
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
group by 1
having count(1)>1;
select *
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
where uuid='665637113';

drop table if exists beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba;
create table beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba as
select date,uuid,sub_365,install_days_type
       ,is_active_7,is_edit_selfi_7
       ,is_active_30,is_edit_selfi_30
       ,is_active_60,is_edit_selfi_60
       ,is_active_90,is_edit_selfi_90
       ,sub_type
       ,max(predit_sub_365_proba) predit_sub_365_proba
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
;

DECLARE thred FLOAT64 DEFAULT 0.25;
select date
       -- 查准查全率
       ,count(distinct uuid) uv
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
       ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
group by 1
order by 1
;
select date,sub_type
       -- 查准查全率
       ,count(distinct uuid) uv
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
       ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
group by 1,2
order by 1,2
;
select date
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
        -- 查准查全率
        ,count(distinct uuid) uv
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
        ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
-- where sub_type='else'
group by 1,2
order by 1,2




-- 第二天活跃用户预测表现
DECLARE thred FLOAT64 DEFAULT 0.1;
select  date,sub_type
        ,round(sum(case when sub_365=1 then 1 end)/sum(1),4) as sub_ratio
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
        ,sum(1) uv
        ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
from
(
    select date,uuid,sub_365,sub_type,predit_sub_365_proba
         ,install_days_type
    from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
    where date between '2023-05-01' and '2023-05-01'
        and sub_type='else'
) a
left join
(
    select uuid
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02' and app_name in ('BeautyPlus')
    group by uuid
) b
on a.uuid=b.uuid
where b.uuid is not null
group by 1,2
order by 1,2



-- 不同thred表现

-- DECLARE thred FLOAT64 DEFAULT 0.0;
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_his_split_predict_thred;
-- create table beautyplus-bc0ed.temp.dws_dz_his_split_predict_thred as

DECLARE thred FLOAT64 DEFAULT 0.0;

WHILE thred <= 1.0 DO
delete from beautyplus-bc0ed.temp.dws_dz_his_split_predict_thred where thredshod = thred;
insert into beautyplus-bc0ed.temp.dws_dz_his_split_predict_thred

select  date,thred thredshod,sub_type,if(install_days_type<=6,'1-6','7-10') install_days_type
        ,'all' is_active_af_1
        ,sum(1) uv
        ,sum(case when sub_365=1 then 1 end) real_sub_365_uv
        ,sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end) real_and_predict_sub_365_uv
        ,sum(case when predit_sub_365_proba>=thred then 1 end) predict_sub_365_uv
from
(
    select date,uuid,sub_365,sub_type,predit_sub_365_proba
         ,install_days_type
    from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
    where date between '2023-05-01' and '2023-05-01'
) a
group by 1,2,3,4,5

union all

select  date,thred thredshod,sub_type,if(install_days_type<=6,'1-6','7-10') install_days_type
        ,'yes' is_active_af_1
        ,sum(1) uv
        ,sum(case when sub_365=1 then 1 end) real_sub_365_uv
        ,sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end) real_and_predict_sub_365_uv
        ,sum(case when predit_sub_365_proba>=thred then 1 end) predict_sub_365_uv
from
(
    select date,uuid,sub_365,sub_type,predit_sub_365_proba
         ,install_days_type
    from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365_proba
    where date between '2023-05-01' and '2023-05-01'
) a
left join
(
    select uuid,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02' and app_name in ('BeautyPlus')
    group by 1,2
) b
on a.uuid=b.uuid and date_add(a.date,interval 1 day)=b.event_date_hk
where b.uuid is not null
group by 1,2,3,4,5
;
SET thred = thred+0.05;

END WHILE;


select 'BeautyPlus' app_name,date,sub_type,install_days_type,is_active_af_1,round(thredshod,2) thredshod
    ,uv,real_sub_365_uv,real_and_predict_sub_365_uv,predict_sub_365_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_predict_thred
order by 1,2,3,4,5








-- 特征重要性
select homepage_exposure_pv_30
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30' and sub_type='else' --and install_days_type<=4
group by 1
order by 1




-- test
-- 看哪个modeltype没顾及到
select
      -- model_type
     sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
    ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
from
(
    select date,sub_365,uuid
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
             ,sub_type,install_days_type,is_active_7,is_active_30,is_active_60,is_active_90
             ,is_edit_selfi_7,is_edit_selfi_30,is_edit_selfi_60,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
--       from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-05-01' and '2023-05-01'
) a
left join
(
    select uuid,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2023-05-02' and '2023-05-02'
      and app_name in ('BeautyPlus')
--       and app_name in ('AirBrush')
    group by 1,2
) b
on a.uuid=b.uuid and date_add(a.date,interval 1 day)=b.event_date_hk
-- where b.uuid is not null
where a.model_type is null
-- group by 1
-- order by 1

group by 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,4,5,6,7,8,9,10










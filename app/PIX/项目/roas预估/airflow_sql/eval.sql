-- 预测输入表量级
select  model_type
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
      from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave_v
--       from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-01-01' and '2023-01-31'
)
group by 1
order by 1
;
-- 预测输出表评估
DECLARE thred FLOAT64 DEFAULT 0.25;
select
-- date,
case when sub_type = 'else' and install_days_type between 1 and 2 and is_active_7=1 and is_edit_selfi_7=1 then 'else_1_2_1_1_all_all_all_all_all_all'
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
             end model_type,
        -- 查准查全率
        count(distinct uuid) uv
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
        ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
        ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
        ,round(avg(predit_sub_365_proba),4) predit_sub_365_proba
from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
--       from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
-- where date='2023-01-10'
-- and sub_type='else'
group by 1
order by 1

-- delete from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365 where date='2023-01-02'

-- roas调整的预测输出评估（roas预估只用到了前7天的预测效果其实。后面的都是根据比例换算的。咋整）
-- 阈值选择
select app_name
      ,types
      ,sub_type
     ,days
       ,count(1) uv
       ,count(case when predit_sub_365_proba is null then 1 end) null_uv
       ,round(sum(predit_sub_365_proba)) as predict_sub_uv

       -- 真实订阅的用户
--        ,count(case when sub_365_from_att>=1 then 1 end) as real_sub_uv
       ,count(case when sub_att_365_from_now>=1 then 1 end) as real_sub_from_now_uv
from
(
    select types,app_name,date,Attributed_Touch_Date,days,is_current_trial,past_sub_times,trial_times
        ,uuid
        ,sub_att_365
        ,sub_att_365_from_now
        ,case when sub_att_365<20 then sub_revenue_att_365_from_now else 0 end sub_revenue_att_365_from_now
        ,sub_revenue_att_365_from_now_avg
        ,sub_type
         ,case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end predit_sub_365_proba
    from `dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict`
    where is_current_pay=0
        and app_name='BeautyPlus'
--         and app_name='AirBrush'
        and sub_type is not null
        and (date='2023-01-01' or date='2023-01-09' or date='2023-01-10'
                or date='2023-02-01' or date='2023-03-01' or date='2023-04-01' or date='2023-05-01' or date='2023-06-01' or date='2023-07-01')
)
group by 1,2,3,4
order by 1,2,3,4
;
-- DECLARE thred FLOAT64 DEFAULT 0.25;
select app_name
      -- ,sub_type
      -- ,types
     -- ,Attributed_Touch_Date
     ,days
     --   ,case when is_current_trial = 1 then 'trial_now'
     --         when past_sub_times-trial_times>0 then 'sub_his'
     --         when trial_times>0 then 'trial_his'
     --         else 'else'
     --    end sub_type
       -- 查准查全率
      --  ,count(distinct uuid) uv_check
       ,count(1) uv
       ,count(case when predit_sub_365_proba is null then 1 end) null_uv
      --  ,if(count(case when sub_365_from_att>=1 then 1 end)=0, 0.0, round(count(case when sub_365_from_att>=1 and predit_sub_365_proba>=thred then 1 end)/count(case when sub_365_from_att>=1 then 1 end),4)) as recall
      --  ,if(count(case when predit_sub_365_proba>=thred then 1 end)=0, 0.0, round(count(case when sub_365_from_att>=1 and predit_sub_365_proba>=thred then 1 end)/count(case when predit_sub_365_proba>=thred then 1 end),4)) as accuracy
--        ,count(case when predit_sub_365_proba>=thred then 1 end) as predict_sub_uv
--        ,round(sum(case when predit_sub_365_proba>=thred then predit_sub_365_proba end)) as predict_sub_uv
       ,round(sum(case when types='ua' and app_name='BeautyPlus' and sub_type='else' then predit_sub_365_proba*0.015
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_now' then predit_sub_365_proba*0.85
                       when types='ua' and app_name='BeautyPlus' and sub_type='sub_his' then predit_sub_365_proba*0.2
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_his' then predit_sub_365_proba*0.1

                       when types='ua' and app_name='AirBrush' and sub_type='else' then predit_sub_365_proba*0.024
                       when types='ua' and app_name='AirBrush' and sub_type='trial_now' then predit_sub_365_proba*0.6
                       when types='ua' and app_name='AirBrush' and sub_type='sub_his' then predit_sub_365_proba*0.2
                       when types='ua' and app_name='AirBrush' and sub_type='trial_his' then predit_sub_365_proba*0.25
              when types='new' and app_name='BeautyPlus' and sub_type='else' then predit_sub_365_proba*0.025
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_now' then predit_sub_365_proba*0.9
                       when types='new' and app_name='BeautyPlus' and sub_type='sub_his' then predit_sub_365_proba*0.5
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_his' then predit_sub_365_proba*0.2

                       when types='new' and app_name='AirBrush' and sub_type='else' then predit_sub_365_proba*0.045
                       when types='new' and app_name='AirBrush' and sub_type='trial_now' then predit_sub_365_proba*0.8
                       when types='new' and app_name='AirBrush' and sub_type='sub_his' then predit_sub_365_proba*0.6
                       when types='new' and app_name='AirBrush' and sub_type='trial_his' then predit_sub_365_proba*0.3
        end)) as predict_sub_uv
--        ,round(sum(case when predit_sub_365_proba>=thred then predit_sub_365_proba end)*0.14) as predict_sub_uv

       -- 真实订阅的用户
--        ,count(case when sub_365_from_att>=1 then 1 end) as real_sub_uv
       ,count(case when sub_att_365_from_now>=1 then 1 end) as real_sub_from_now_uv

       -- 订阅收入
       ,round(sum(case when types='ua' and app_name='BeautyPlus' and sub_type='else' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.015
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_now' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.85
                       when types='ua' and app_name='BeautyPlus' and sub_type='sub_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.2
                       when types='ua' and app_name='BeautyPlus' and sub_type='trial_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.1

                       when types='ua' and app_name='AirBrush' and sub_type='else' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.024
                       when types='ua' and app_name='AirBrush' and sub_type='trial_now' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.6
                       when types='ua' and app_name='AirBrush' and sub_type='sub_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.2
                       when types='ua' and app_name='AirBrush' and sub_type='trial_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.25
              when types='new' and app_name='BeautyPlus' and sub_type='else' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.025
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_now' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.9
                       when types='new' and app_name='BeautyPlus' and sub_type='sub_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.5
                       when types='new' and app_name='BeautyPlus' and sub_type='trial_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.2

                       when types='new' and app_name='AirBrush' and sub_type='else' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.045
                       when types='new' and app_name='AirBrush' and sub_type='trial_now' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.8
                       when types='new' and app_name='AirBrush' and sub_type='sub_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.6
                       when types='new' and app_name='AirBrush' and sub_type='trial_his' then predit_sub_365_proba*sub_revenue_att_365_from_now_avg*0.3
        end)) as predict_sub_revenue_att_365_from_now
       ,round(sum(sub_revenue_att_365_from_now)) sub_revenue_att_365_from_now
from
(
    select types,app_name,date,Attributed_Touch_Date,days,is_current_trial,past_sub_times,trial_times
        ,uuid
        ,sub_att_365
        ,sub_att_365_from_now
        ,case when sub_att_365<20 then sub_revenue_att_365_from_now else 0 end sub_revenue_att_365_from_now
        ,sub_revenue_att_365_from_now_avg
        ,sub_type
--         ,predit_sub_365_proba
         ,case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end predit_sub_365_proba
--          -- 均匀分布
--          ,round(case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end*(365-days)/365,4) predit_sub_365_proba
--          -- 对数分布
--          ,round(LN(EXP(1)-(EXP(1)-1)/364*days)*case when install_days_type>=7 and sub_type='else' then predit_sub_365_proba*0.6 else predit_sub_365_proba end,4) predit_sub_365_proba
    from `dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict`
    where is_current_pay=0
--         and app_name='BeautyPlus'
        and app_name='AirBrush'
        and (date='2023-01-01' or date='2023-01-09' or date='2023-01-10'
                or date='2023-02-01' or date='2023-03-01' or date='2023-04-01' or date='2023-05-01' or date='2023-06-01' or date='2023-07-01')
)
-- where sub_type='else'
-- group by 1,2,3,4
-- order by 1,2,4,3
-- group by 1,2,3
-- order by 1,2,3
group by 1,2
order by 1,2
;
-- 加入已订阅用户预测+目前实际收入
select app_name
      ,types
     -- ,Attributed_Touch_Date
     ,days
     ,count(1) uv
     ,count(case when predit_sub_365_proba is null then 1 end) null_uv
     -- 当前未订阅用户订阅概率预测
     ,round(sum(case when is_current_pay=0 then predict_sub_att_365_from_now end)) predict_sub_att_365_from_now
     ,count(case when is_current_pay=0 and sub_att_365_from_now>=1 then 1 end) as real_sub_from_now_uv
     -- 当前未订阅用户 未来收入预测
     ,round(sum(case when is_current_pay=0 then predict_sub_revenue_att_365_from_now end)) predict_sub_revenue_att_365_from_now_no_pay
     ,round(sum(case when is_current_pay=0 then sub_revenue_att_365_from_now end)) sub_revenue_att_365_from_now_no_pay
     -- 当前已订阅用户 未来收入预测
     ,round(sum(case when is_current_pay=1 then predict_order_revenue end)) predict_sub_revenue_att_365_from_now_pay
     ,round(sum(case when is_current_pay=1 then sub_revenue_att_365_from_now end)) sub_revenue_att_365_from_now_pay
     -- 当前实际收入+未来收入预测（包括已订阅和未订阅）
     ,round(sum(case
                    when is_current_pay = 0 then predict_sub_revenue_att_365_from_now
                    when is_current_pay = 1 then predict_order_revenue end
            )+sum(sub_revenue_att_365_to_now)) predict_sub_revenue_att_365
--      ,round(sum(sub_revenue_att_365_from_now+sub_revenue_att_365_to_now)) sub_revenue_att_365
     ,round(sum(sub_revenue_att_365)) sub_revenue_att_365
from dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict
where sub_att_365<20
group by 1,2,3
order by 1,2,3
;

-- 交付的表
select types -- ua/new
     ,app_name -- app
     ,date -- 观测日期
     ,Attributed_Touch_Date -- 投放日期（观测日期一年内）
     ,uuid -- 用户id
     ,case when is_current_pay=0 then predict_sub_revenue_att_365_from_now when is_current_pay=1 then predict_order_revenue end predict_sub_revenue_att_365_from_now -- 预测 观测日至（投放日+1年）的订阅收入
from dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict



-- dau预估
DECLARE thred FLOAT64 DEFAULT 0.25;
select date
       -- 查准查全率
       ,count(distinct uuid) uv
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when sub_365=1 then 1 end),4) as recall
       ,round(sum(case when sub_365=1 and predit_sub_365_proba>=thred then 1 end)/sum(case when predit_sub_365_proba>=thred then 1 end),4) as accuracy
       ,round(sum(case when predit_sub_365_proba>=thred then 1 end)/sum(1),4) as predict_sub_ratio
from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365
where
group by 1
order by 1
;

-- 和看板对数
select date,count(distinct uuid),sum(sub_revenue_365_from_att),sum(sub_revenue_att_365_from_now)
from dataintegration-265403.temp.dws_dz_roas_goal_user_sub_uuid
where Attributed_Touch_Date='2023-01-01' and app_name='BeautyPlus' and types='new'
group by 1
order by 1


-- 缺失值情况
select *
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
where predit_sub_365_proba is null and Attributed_Touch_Date>='2023-01-01' and is_current_pay=0
limit 10
;
-- 缺失值来源
select a.date,a.days,count(distinct a.uuid) uv,count(distinct case when b.uuid is null then a.uuid end) null_uv
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict a
left join beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave b
on a.date=b.date and a.uuid=b.uuid and a.is_current_pay=0 --and a.days between 7 and 30
    and a.predit_sub_365_proba is null and a.app_name='BeautyPlus'
group by 1,2
order by 1,2
;
-- select a.date,a.uuid,a.sub_type,a.install_days_type
--      ,a.is_active_7,a.is_edit_selfi_7,a.is_active_30,a.is_edit_selfi_30
--      ,a.is_active_60,a.is_edit_selfi_60,a.is_active_90,a.is_edit_selfi_90
select a.date,a.sub_type,a.install_days_type
     ,a.is_active_7,a.is_edit_selfi_7,a.is_active_30,a.is_edit_selfi_30
     ,a.is_active_60,a.is_edit_selfi_60,a.is_active_90,a.is_edit_selfi_90
     ,count(distinct a.uuid)
from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave_v a
left join beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_365 b
on a.date=b.date and a.uuid=b.uuid
where b.uuid is null and a.date='2023-01-01'
-- limit 100
group by 1,2,3,4,5,6,7,8,9,10,11

-- 投放用户来多少天订阅的
select types,a.app_name,a.date,days
    ,count(distinct a.uuid) uv,count(distinct case when c.uuid is not null then a.uuid end) choose_uv
    ,count(distinct case when sub_365_from_att>0 then a.uuid end) sub_uv
    ,count(distinct case when sub_365_from_att>0 and c.uuid is not null then a.uuid end) choose_sub_uv
from dataintegration-265403.temp.dws_dz_roas_goal_user_sub_uuid a
join beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave b on a.uuid=b.uuid and a.date=b.date
left join beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave c on a.uuid=c.uuid and a.date=c.date
where a.date between '2023-01-01' and '2023-01-01' and a.app_name='BeautyPlus' and types='new'
    and b.is_current_pay=0
group by 1,2,3,4
order by 1,2,3,4
;
-- 预测输入表检查
select types,app_name,date
    ,count(distinct uuid) uv
    ,count(distinct Attributed_Touch_Date) days
    ,count(distinct case when sub_365_from_att>0 then uuid end) sub_uv
    ,count(distinct case when last_active_days<=60 then uuid end) sub_uv
from dataintegration-265403.temp.dws_dz_roas_goal_user_sub_uuid
where date between '2023-01-01' and '2023-01-31'
group by 1,2,3
order by 1,2,3
;
select date,count(1) pv,count(distinct uuid) uv
  ,count(distinct case when last_active_days=0 then uuid end) ac_uv
  ,count(distinct case when last_active_days<=60 then uuid end) ac_uv_60
  ,count(distinct case when last_active_days<=90 then uuid end) ac_uv_90
from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave
where date between '2023-01-01' and '2023-01-31'
group by 1
;
select date,count(1) pv,count(distinct uuid) uv
  ,count(distinct case when last_active_days=0 then uuid end) ac_uv
  ,count(distinct case when last_active_days<=60 then uuid end) ac_uv
from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave_v
where date between '2023-01-01' and '2023-01-31'
group by 1
;
-- 加入已订阅用户后是否异常
-- 有多少uuid对应多比order_id
select app_name,date,Attributed_Touch_Date,types,uuid,count(distinct order_id),count(1)
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
group by 1,2,3,4,5
having count(1)>1

-- 有order_id的用户是否均是当前订阅用户:有些用户当前正订阅，但订阅的订单不是归因订单
select is_current_pay,is_current_trial,order_status,count(distinct uuid)
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
-- where order_id is not null
group by 1,2,3

-- 异常订单查看
select *
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
-- where is_current_pay=0 and is_current_trial=0 and order_status in (1,2)
where is_current_pay=1 and order_status is null

select *
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where uuid='632688641'

-- 每天已订阅用户预测的收入和看板里预测的收入对数
select app_name,date,Attributed_Touch_Date,types,count(distinct uuid),count(distinct order_id),sum(revenue)
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
where types='new' and date='2023-01-01' and is_current_pay=1
group by 1,2,3,4
order by 1,2,3,4

select app_id,install_date,order_date,sum(revenue),sum(uv)
-- select *
from `dataintegration-265403.roas_dataset_v4.dws_da_new_forecast_revenue_every_day_v4`
where order_date = '2023-01-01'
--   and install_date='2022-01-02'
group by 1,2,3
order by 1,2,3

-- 两个app可以对应一个uuid吗
select *
from dataintegration-265403.temp.dws_dz_roas_sub_365_from_att_predict
where uuid='637450272' and types='new' and Attributed_Touch_Date='2022-07-11'

select *
from `dataintegration-265403.stat.dmi_dz_idmapping`
where uuid='637450272'

select distinct app_name,user_pseudo_id,category,mobile_brand_name,mobile_model_name,mobile_os_hardware_model,operating_system,operating_system_version
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2022-07-10', '2022-07-12', 'beautyplus,airbrush', false)
where user_pseudo_id in ('1657485995266-8628948508786292878'
,'1657486426342-6890793904207751658'
,'1edfed2a581dc8125a3a16a5a88aa3cc'
,'2556111164'
,'2556096820'
,'399c56434d94b778eb22897af728326f'
,'736c76b4-fbb8-431a-8bd9-4cf4cbdc59d5'
,'ac81e297fbf4c796ac0bb0bd683456bb'
,'e1ccdb0fbdf7fe20')

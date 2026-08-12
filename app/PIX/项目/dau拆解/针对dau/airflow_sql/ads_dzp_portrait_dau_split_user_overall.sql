-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=365+14)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists dataintegration-265403.portrait.ads_dzp_portrait_dau_split_user_overall;
-- create table dataintegration-265403.portrait.ads_dzp_portrait_dau_split_user_overall as

delete from dataintegration-265403.portrait.ads_dzp_portrait_dau_split_user_overall where date between mDATE_START and mDATE_END;
insert into dataintegration-265403.portrait.ads_dzp_portrait_dau_split_user_overall
(
    app_name,date,platform,country,is_UA,is_new,app_version,types,detail_type,dau
    ,current_sub_revenue,current_consume_revenue,current_ad_revenue,current_all_revenue
    ,future_sub_365,future_nosub_365,future_sub_revenue_365,future_revenue_365
    ,future_sub_90,future_nosub_90,future_sub_revenue_90,future_revenue_90
    ,predit_null,predit_sub_365,predit_sub_365_adjust
)

with users as
(
    select event_date_hk,app_name,user_pseudo_id,max(platform) platform,max(country) country,max(is_UA) is_UA,max(is_new) is_new,max(app_version) app_version
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3
)

select a.app_name,a.date,b.platform,b.country,b.is_UA,b.is_new,b.app_version
     ,case when is_current_sub=1 or is_current_consume=1 then 'now_pay'
           when is_current_sub=0 and is_current_consume=0 then 'now_no_pay'
     end types
     -- 历史收入指标、当前试用情况
     ,case when is_current_sub=1 or is_current_consume=1 then 'now_pay'
           when is_current_trial = 1 then 'now_trial'
           when past_sub_times-trial_times>0 then 'his_sub'
           when trial_times>0 then 'his_only_trial'
           else 'else'
     end detail_type
     ,count(distinct a.user_pseudo_id) dau
     -- 当前收入指标
     ,round(sum(current_sub_revenue),2) current_sub_revenue
     ,round(sum(current_consume_revenue),2) current_consume_revenue
     ,round(sum(current_ad_revenue),2) current_ad_revenue
     ,round(sum(current_sub_revenue)+sum(current_consume_revenue)+sum(current_ad_revenue),2) current_all_revenue
     -- 未来指标-真实
     ,count(distinct case when future_sub_365>=1 then a.user_pseudo_id end) future_sub_365
     ,count(distinct case when future_sub_365=0 then a.user_pseudo_id end) future_nosub_365
     ,round(sum(case when future_sub_revenue_365<=500 then future_sub_revenue_365 end),2) future_sub_revenue_365
--      ,count(distinct case when future_credit_365>=1 then user_pseudo_id end) future_consume_365
--      ,count(distinct case when future_credit_365=0 then user_pseudo_id end) future_noconsume_365
--      ,round(sum(future_credit_revenue_365),2) future_consume_revenue_365
     ,round(coalesce(sum(case when future_sub_revenue_365<=500 then future_sub_revenue_365 end),0)+coalesce(sum(future_credit_revenue_365),0)+coalesce(sum(future_max_revenue_365),0),2) future_revenue_365

     ,count(distinct case when future_sub_90>=1 then a.user_pseudo_id end) future_sub_90
     ,count(distinct case when future_sub_90=0 then a.user_pseudo_id end) future_nosub_90
     ,round(sum(case when future_sub_revenue_90<=500 then future_sub_revenue_90 end),2) future_sub_revenue_90
--      ,count(distinct case when future_credit_90>=1 then user_pseudo_id end) future_consume_90
--      ,count(distinct case when future_credit_90=0 then user_pseudo_id end) future_noconsume_90
--      ,round(sum(future_credit_revenue_90),2) future_consume_revenue_90
     ,round(coalesce(sum(case when future_sub_revenue_90<=500 then future_sub_revenue_90 end),0)+coalesce(sum(future_credit_revenue_90),0)+coalesce(sum(future_max_revenue_90),0),2) future_revenue_90

--      ,round(sum(future_max_revenue_90),2) future_max_revenue_90
     -- 未来指标-预测
     ,count(distinct case when predit_sub_365_proba is null then a.user_pseudo_id end) predit_null
     ,round(sum(case when is_current_sub=1 or is_current_consume=1 then 0 else predit_sub_365_proba end),2) predit_sub_365
     ,round(sum(case when is_current_sub=1 or is_current_consume=1 then 0 else predit_sub_365_proba_adjust end),2) predit_sub_365_adjust
from dataintegration-265403.portrait.dws_dzp_portrait_dau_split_user_detail_sub_info a
join users b
on a.app_name=b.app_name and a.date=b.event_date_hk and a.user_pseudo_id=b.user_pseudo_id
group by 1,2,3,4,5,6,7,8,9
order by 1,2,3,4,5,6,7,8,9


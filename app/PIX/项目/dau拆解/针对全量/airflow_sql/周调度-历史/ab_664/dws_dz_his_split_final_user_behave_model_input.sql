-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑

-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists airbrush-1324.temp.dws_dz_his_split_final_user_behave;
-- create table airbrush-1324.temp.dws_dz_his_split_final_user_behave as

-- DECLARE mDATE_START DATE DEFAULT '2023-01-02';
-- DECLARE mDATE_END DATE DEFAULT '2023-01-31';
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=368)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=359)).strftime("%Y-%m-%d") }}';
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from airbrush-1324.temp.dws_dz_his_split_final_user_behave where date = mDATE;
insert into airbrush-1324.temp.dws_dz_his_split_final_user_behave

with goal_users_pre as
(
    select event_date_hk,user_pseudo_id
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
    -- from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk = mDATE
        and last_active_date>='2022-01-01'  -- ab有太多22年之前现在还活跃的用户了
)
,
-- gid_firebase_id as
-- (
--     select 'AirBrush' app_name,event_date_hk,gid,last_user_pseudo_id
--     from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
--     where event_date_hk = mDATE
--         and last_active_date>='2022-01-01'  -- ab有太多22年之前现在还活跃的用户了
-- )
-- ,
uuid_firebase_id as
(
    select key,uuid
    from `dataintegration-265403.stat.dmi_dz_idmapping`
)
,
goal_users as
(
    select 'AirBrush' app_name,gu.event_date_hk,gu.user_pseudo_id,uu.uuid
    from goal_users_pre gu
    left join uuid_firebase_id uu
    on gu.user_pseudo_id=uu.key
)
,
his_sub_event as
(
    -- 该死这个表2024年之前没有数
    select event_date_hk,app_id app_name,uuid,if(current_trial_day is not null,1,0) is_current_trial
            ,current_trial_day
            ,is_current_subscription_cancelled
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times
            ,cancel_subscription_times
            ,refund_subscription_times
            ,promotional_paying_times
    from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
    where event_date_hk>='2024-01-01' and event_date_hk = mDATE and app_id in ('AirBrush')

    union all

    select event_date_hk,app_id app_name,uuid,if(current_trial_day is not null,1,0) is_current_trial
            ,current_trial_day
            ,is_current_subscription_cancelled
            ,if(coalesce(current_promotional_paying_period_day,current_standard_paying_period_day) is not null,1,0) is_current_pay
            -- 历史订阅信息
            ,past_sub_1year_sku_type_times+past_sub_1month_sku_type_times+past_sub_6month_sku_type_times+past_sub_2week_sku_type_times+past_sub_1week_sku_type_times+past_sub_3month_sku_type_times past_sub_times
            ,trial_times
            ,cancel_subscription_times
            ,refund_subscription_times
            ,promotional_paying_times
    from `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp`
    where event_date_hk<'2024-01-01' and event_date_hk = mDATE and app_id in ('AirBrush')
)
,
sub_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE and DATE_ADD(mDATE,interval 365 day)  -- 最多预测未来一年
        and app_id in('AirBrush')
        and order_status in (1,2)
    group by 1,2,3
)
,
credit_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) credit_revenue
    from `dataintegration-265403.purchase.dwd_da_purchase_daily`
    where standard_order_date between mDATE and DATE_ADD(mDATE,interval 365 day)  -- 最多预测未来一年
        and app_id in('AirBrush')
        and order_status in (1,2)  -- 这个确认下
    group by 1,2,3
)
,
ad_event as
(
    -- 仅2024开始有数
    select event_date,app_name,user_pseudo_id,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where event_date between mDATE and DATE_ADD(mDATE,interval 365 day)
        and event_date>='2024-01-01'
        and app_name in ('AirBrush')
    group by 1,2,3
)
,
behave_event as
(
    select 'AirBrush' app_name,*
    from airbrush-1324.temp.dws_dz_his_split_user_behave
    where date = mDATE

--     union all
--
--     select 'AirBrush' app_name,*
--     from airbrush-1324.temp.dws_dz_dau_split_user_behave
--     where date between mDATE_START and mDATE_END
)
,
future_sub_pay as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) sub_365  -- 一年内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) sub_90  -- 90天内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then 1 end) sub_30  -- 30天内是否有过订阅付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) sub_7  -- 7天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then sub_revenue end) sub_revenue_365  -- 一年内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then sub_revenue end) sub_revenue_90  -- 90天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then sub_revenue end) sub_revenue_30  -- 30天内是否有过订阅付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then sub_revenue end) sub_revenue_7  -- 7天内是否有过订阅付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk = mDATE
    ) a
    cross join sub_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
,
future_credit_pay as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.uuid
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) credit_365  -- 一年内是否有过积分付费行为
        ,count(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) credit_90  -- 90天内是否有过积分付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then credit_revenue end) credit_revenue_365  -- 一年内是否有过积分付费行为
        ,sum(case when b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then credit_revenue end) credit_revenue_90  -- 90天内是否有过积分付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk = mDATE
    ) a
    cross join credit_event b
    where b.standard_order_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
,
future_ad_revenue as
(
    select a.date event_date_hk
        ,b.app_name
        ,b.user_pseudo_id
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) max_365  -- 一年内是否有过订阅付费行为
        ,count(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) max_90  -- 90天内是否有过订阅付费行为
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then max_revenue end) max_revenue_365  -- 一年内是否有过订阅付费行为
        ,sum(case when b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then max_revenue end) max_revenue_90  -- 90天内是否有过订阅付费行为
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk = mDATE
    ) a
    cross join ad_event  b
    where b.event_date between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
    group by 1,2,3
)
-- ,
-- future_active as
-- (
--     select a.date event_date_hk
--         ,b.app_name
--         ,b.user_pseudo_id
--         ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY) then 1 end) active_365  -- 一年内是否有过活跃
--         ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 90 DAY) then 1 end) active_90  -- 90天内是否有过活跃
--         ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 30 DAY) then 1 end) active_30  -- 30天内是否有过活跃
--         ,count(case when b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 7 DAY) then 1 end) active_7  -- 7天内是否有过活跃
--     from
--     (
--         select distinct event_date_hk date
--         from `dataintegration-265403.stat.stat_active_advice_detail_d`
--         where event_date_hk = mDATE
--     ) a
--     cross join `dataintegration-265403.stat.stat_active_advice_detail_d` b
--     where b.app_name = 'AirBrush' and b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
--     group by 1,2,3
-- )
-- ,
-- dau_type as
-- (
--     select app_name,event_date event_date_hk,user_pseudo_id
--         ,max(is_paying) is_paying,max(is_consum) is_consum
--         ,max(sub_revenue) sub_revenue,max(consum_revenue) consum_revenue,max(revenue) revenue
--     from `dataintegration-265403.temp.dau_type`
--     where app_name in ('AirBrush')
--     group by 1,2,3
-- )

select *, CAST(FLOOR(RAND() * 6) AS INT64) bucket
from
(
select g.event_date_hk date,g.app_name,g.uuid
        -- g
        ,max(is_current_trial) is_current_trial
        ,max(current_trial_day) current_trial_day
        ,max(is_current_subscription_cancelled) is_current_subscription_cancelled
        ,max(is_current_pay) is_current_pay
        ,max(past_sub_times) past_sub_times
        ,max(trial_times) trial_times
        ,max(cancel_subscription_times) cancel_subscription_times
        ,max(refund_subscription_times) refund_subscription_times
        ,max(promotional_paying_times) promotional_paying_times
        ,count(distinct g.user_pseudo_id) id_num
        -- 预测指标
        ,max(sub_365) sub_365
        ,max(sub_90) sub_90
        ,max(sub_30) sub_30
        ,max(sub_7) sub_7
        ,max(sub_revenue_365) sub_revenue_365
        ,max(sub_revenue_90) sub_revenue_90
        ,max(sub_revenue_30) sub_revenue_30
        ,max(sub_revenue_7) sub_revenue_7
        ,max(credit_365) credit_365
        ,max(credit_90) credit_90
        ,max(credit_revenue_365) credit_revenue_365
        ,max(credit_revenue_90) credit_revenue_90
        -- fa,fac
        ,sum(fa.max_365) max_365,max(fa.max_90) max_90,max(fa.max_revenue_365) max_revenue_365,max(fa.max_revenue_90) max_revenue_90
        -- ,sum(fac.active_365) active_365,sum(fac.active_90) active_90,sum(fac.active_30) active_30,sum(fac.active_7) active_7

        -- b
        , max(is_new) is_new, max(is_ua) is_ua, max(media_source) media_source, max(android_level) android_level, max(permanent_country) permanent_country, max(platform) platform, max(brand) brand, max(model) model, max(phone_price) phone_price, max(language) language, max(operating_system) operating_system, min(first_active_date) first_active_date, max(install_days) install_days, max(last_active_date) last_active_date, min(last_active_days) last_active_days, sum(active_mins_90d) active_mins_90d, sum(active_sessions_90d) active_sessions_90d, sum(active_mins_7d) active_mins_7d, sum(active_sessions_7d) active_sessions_7d, max(active_category) active_category, sum(life_time_active_days) life_time_active_days, sum(active_days_90d) active_days_90d, sum(active_days_7d) active_days_7d, sum(active_days_60) active_days_60, sum(active_days_30) active_days_30, sum(active_days_14) active_days_14, sum(active_days_365) active_days_365, sum(holiday_active_days_365) holiday_active_days_365, sum(weekend_active_days_365) weekend_active_days_365, sum(weekend_include_five_active_days_365) weekend_include_five_active_days_365, sum(holiday_active_days_365)/sum(active_days_365) holiday_active_ratio, sum(weekend_active_days_365)/sum(active_days_365) weekend_active_ratio, sum(weekend_include_five_active_days_365)/sum(active_days_365) weekend_include_five_active_ratio

      ,sum(`pv_camera_enter-all-all`) as `pv_camera_enter-all-all`, sum(`pv_camera_save-Filter-all`) as `pv_camera_save-Filter-all`, sum(`pv_camera_save-all-all`) as `pv_camera_save-all-all`, sum(`pv_camera_taken-Filter-all`) as `pv_camera_taken-Filter-all`, sum(`pv_camera_taken-all-all`) as `pv_camera_taken-all-all`, sum(`pv_edit_enter-AI Style-all`) as `pv_edit_enter-AI Style-all`, sum(`pv_edit_enter-Creative-all`) as `pv_edit_enter-Creative-all`, sum(`pv_edit_enter-Filter-all`) as `pv_edit_enter-Filter-all`, sum(`pv_edit_enter-Hair-all`) as `pv_edit_enter-Hair-all`, sum(`pv_edit_enter-Makeup-all`) as `pv_edit_enter-Makeup-all`, sum(`pv_edit_enter-Mykit-all`) as `pv_edit_enter-Mykit-all`, sum(`pv_edit_enter-Presets-all`) as `pv_edit_enter-Presets-all`, sum(`pv_edit_enter-Retouch-all`) as `pv_edit_enter-Retouch-all`, sum(`pv_edit_enter-Tools-all`) as `pv_edit_enter-Tools-all`, sum(`pv_edit_enter-all-all`) as `pv_edit_enter-all-all`, sum(`pv_edit_save-AI Style-all`) as `pv_edit_save-AI Style-all`, sum(`pv_edit_save-Creative-all`) as `pv_edit_save-Creative-all`, sum(`pv_edit_save-Filter-all`) as `pv_edit_save-Filter-all`, sum(`pv_edit_save-Hair-all`) as `pv_edit_save-Hair-all`, sum(`pv_edit_save-Makeup-all`) as `pv_edit_save-Makeup-all`, sum(`pv_edit_save-Presets-all`) as `pv_edit_save-Presets-all`, sum(`pv_edit_save-Retouch-all`) as `pv_edit_save-Retouch-all`, sum(`pv_edit_save-Tools-all`) as `pv_edit_save-Tools-all`, sum(`pv_edit_save-all-all`) as `pv_edit_save-all-all`, sum(`pv_edit_save-其他-all`) as `pv_edit_save-其他-all`, sum(`pv_edit_use-AI Style-all`) as `pv_edit_use-AI Style-all`, sum(`pv_edit_use-Creative-all`) as `pv_edit_use-Creative-all`, sum(`pv_edit_use-Filter-all`) as `pv_edit_use-Filter-all`, sum(`pv_edit_use-Hair-all`) as `pv_edit_use-Hair-all`, sum(`pv_edit_use-Makeup-all`) as `pv_edit_use-Makeup-all`, sum(`pv_edit_use-Presets-all`) as `pv_edit_use-Presets-all`, sum(`pv_edit_use-Retouch-all`) as `pv_edit_use-Retouch-all`, sum(`pv_edit_use-Tools-all`) as `pv_edit_use-Tools-all`
     ,sum(`pv_func_video_enter-reshape`) as `pv_func_video_enter-reshape`, sum(`pv_func_video_use-foundation`) as `pv_func_video_use-foundation`, sum(`pv_func_video_enter-firm`) as `pv_func_video_enter-firm`, sum(`pv_func_video_enter-acne`) as `pv_func_video_enter-acne`, sum(`pv_func_video_use-sculpt`) as `pv_func_video_use-sculpt`, sum(`pv_func_video_enter-clarity`) as `pv_func_video_enter-clarity`, sum(`pv_func_video_use-brighten`) as `pv_func_video_use-brighten`, sum(`pv_func_video_use-reshape`) as `pv_func_video_use-reshape`, sum(`pv_func_video_use-matte`) as `pv_func_video_use-matte`, sum(`pv_func_video_enter-dark_circle`) as `pv_func_video_enter-dark_circle`, sum(`pv_func_video_enter-stretch`) as `pv_func_video_enter-stretch`, sum(`pv_video_magic_status-open`) as `pv_video_magic_status-open`, sum(`pv_video_save-skin_tone`) as `pv_video_save-skin_tone`, sum(`pv_func_video_enter-smooth`) as `pv_func_video_enter-smooth`, sum(`pv_func_video_enter-sculpt`) as `pv_func_video_enter-sculpt`, sum(`pv_video_save-whiten`) as `pv_video_save-whiten`, sum(`pv_func_video_use-clarity`) as `pv_func_video_use-clarity`, sum(`pv_video_save-acne`) as `pv_video_save-acne`, sum(`pv_video_save-reshape`) as `pv_video_save-reshape`, sum(`pv_video_save-contouring`) as `pv_video_save-contouring`, sum(`pv_video_save-brighten`) as `pv_video_save-brighten`, sum(`pv_func_video_enter-makeup`) as `pv_func_video_enter-makeup`, sum(`pv_func_video_use-makeup`) as `pv_func_video_use-makeup`, sum(`pv_func_video_enter-foundation`) as `pv_func_video_enter-foundation`, sum(`pv_video_save-stretch`) as `pv_video_save-stretch`, sum(`pv_video_save-overview`) as `pv_video_save-overview`, sum(`pv_video_start_edit-overview`) as `pv_video_start_edit-overview`, sum(`pv_func_video_enter-matte`) as `pv_func_video_enter-matte`, sum(`pv_func_video_use-firm`) as `pv_func_video_use-firm`, sum(`pv_func_video_use-whiten`) as `pv_func_video_use-whiten`, sum(`pv_video_save-matte`) as `pv_video_save-matte`, sum(`pv_video_save-foundation`) as `pv_video_save-foundation`, sum(`pv_func_video_enter-whiten`) as `pv_func_video_enter-whiten`, sum(`pv_func_video_enter-brighten`) as `pv_func_video_enter-brighten`, sum(`pv_func_video_use-stretch`) as `pv_func_video_use-stretch`, sum(`pv_video_save-firm`) as `pv_video_save-firm`, sum(`pv_video_save-dark_circle`) as `pv_video_save-dark_circle`, sum(`pv_func_video_use-smooth`) as `pv_func_video_use-smooth`, sum(`pv_video_magic_status-close`) as `pv_video_magic_status-close`, sum(`pv_func_video_use-skin_tone`) as `pv_func_video_use-skin_tone`, sum(`pv_video_save-sculpt`) as `pv_video_save-sculpt`, sum(`pv_func_video_use-dark_circle`) as `pv_func_video_use-dark_circle`, sum(`pv_func_video_use-acne`) as `pv_func_video_use-acne`, sum(`pv_video_save-smooth`) as `pv_video_save-smooth`, sum(`pv_func_video_use-contouring`) as `pv_func_video_use-contouring`, sum(`pv_video_save-clarity`) as `pv_video_save-clarity`, sum(`pv_func_video_enter-contouring`) as `pv_func_video_enter-contouring`, sum(`pv_func_video_enter-skin_tone`) as `pv_func_video_enter-skin_tone`, sum(`pv_video_save-makeup`) as `pv_video_save-makeup`
     ,sum(`pv_edit_enter-Creative-Background`) as `pv_edit_enter-Creative-Background`, sum(`pv_edit_enter-Creative-Colors`) as `pv_edit_enter-Creative-Colors`, sum(`pv_edit_enter-Creative-Glitter`) as `pv_edit_enter-Creative-Glitter`, sum(`pv_edit_enter-Creative-Sparkle`) as `pv_edit_enter-Creative-Sparkle`, sum(`pv_edit_enter-Creative-Text`) as `pv_edit_enter-Creative-Text`, sum(`pv_edit_enter-Hair-Bangs`) as `pv_edit_enter-Hair-Bangs`, sum(`pv_edit_enter-Hair-HairDye`) as `pv_edit_enter-Hair-HairDye`, sum(`pv_edit_enter-Hair-Hairline`) as `pv_edit_enter-Hair-Hairline`, sum(`pv_edit_enter-Hair-Hairstyles`) as `pv_edit_enter-Hair-Hairstyles`, sum(`pv_edit_enter-Makeup-Blush`) as `pv_edit_enter-Makeup-Blush`, sum(`pv_edit_enter-Makeup-BuildLooks`) as `pv_edit_enter-Makeup-BuildLooks`, sum(`pv_edit_enter-Makeup-Contour`) as `pv_edit_enter-Makeup-Contour`, sum(`pv_edit_enter-Makeup-Eyebrows`) as `pv_edit_enter-Makeup-Eyebrows`, sum(`pv_edit_enter-Makeup-Eyecolor`) as `pv_edit_enter-Makeup-Eyecolor`, sum(`pv_edit_enter-Makeup-Eyelashes`) as `pv_edit_enter-Makeup-Eyelashes`, sum(`pv_edit_enter-Makeup-Eyeliner`) as `pv_edit_enter-Makeup-Eyeliner`, sum(`pv_edit_enter-Makeup-Eyeshadow`) as `pv_edit_enter-Makeup-Eyeshadow`, sum(`pv_edit_enter-Makeup-Lips`) as `pv_edit_enter-Makeup-Lips`, sum(`pv_edit_enter-Makeup-Sets`) as `pv_edit_enter-Makeup-Sets`, sum(`pv_edit_enter-Mykit-AI Retouch`) as `pv_edit_enter-Mykit-AI Retouch`, sum(`pv_edit_enter-Mykit-Acne`) as `pv_edit_enter-Mykit-Acne`, sum(`pv_edit_enter-Mykit-Adjust`) as `pv_edit_enter-Mykit-Adjust`, sum(`pv_edit_enter-Mykit-Align`) as `pv_edit_enter-Mykit-Align`, sum(`pv_edit_enter-Mykit-Background`) as `pv_edit_enter-Mykit-Background`, sum(`pv_edit_enter-Mykit-Bangs`) as `pv_edit_enter-Mykit-Bangs`, sum(`pv_edit_enter-Mykit-Blur`) as `pv_edit_enter-Mykit-Blur`, sum(`pv_edit_enter-Mykit-Bokeh`) as `pv_edit_enter-Mykit-Bokeh`, sum(`pv_edit_enter-Mykit-Brighten`) as `pv_edit_enter-Mykit-Brighten`, sum(`pv_edit_enter-Mykit-Colors`) as `pv_edit_enter-Mykit-Colors`, sum(`pv_edit_enter-Mykit-Contour`) as `pv_edit_enter-Mykit-Contour`, sum(`pv_edit_enter-Mykit-DarkCircles`) as `pv_edit_enter-Mykit-DarkCircles`, sum(`pv_edit_enter-Mykit-Details`) as `pv_edit_enter-Mykit-Details`, sum(`pv_edit_enter-Mykit-Enhance`) as `pv_edit_enter-Mykit-Enhance`, sum(`pv_edit_enter-Mykit-Eraser`) as `pv_edit_enter-Mykit-Eraser`, sum(`pv_edit_enter-Mykit-Filter`) as `pv_edit_enter-Mykit-Filter`, sum(`pv_edit_enter-Mykit-Firm`) as `pv_edit_enter-Mykit-Firm`, sum(`pv_edit_enter-Mykit-Foundation`) as `pv_edit_enter-Mykit-Foundation`, sum(`pv_edit_enter-Mykit-Glitter`) as `pv_edit_enter-Mykit-Glitter`, sum(`pv_edit_enter-Mykit-HairDye`) as `pv_edit_enter-Mykit-HairDye`, sum(`pv_edit_enter-Mykit-Hairline`) as `pv_edit_enter-Mykit-Hairline`, sum(`pv_edit_enter-Mykit-Hairstyles`) as `pv_edit_enter-Mykit-Hairstyles`, sum(`pv_edit_enter-Mykit-Highlighter`) as `pv_edit_enter-Mykit-Highlighter`, sum(`pv_edit_enter-Mykit-Iris`) as `pv_edit_enter-Mykit-Iris`, sum(`pv_edit_enter-Mykit-Magic`) as `pv_edit_enter-Mykit-Magic`, sum(`pv_edit_enter-Mykit-Makeup`) as `pv_edit_enter-Mykit-Makeup`, sum(`pv_edit_enter-Mykit-Matte`) as `pv_edit_enter-Mykit-Matte`, sum(`pv_edit_enter-Mykit-Presets`) as `pv_edit_enter-Mykit-Presets`, sum(`pv_edit_enter-Mykit-Prism`) as `pv_edit_enter-Mykit-Prism`,sum(`pv_edit_enter-Mykit-Relight`) as `pv_edit_enter-Mykit-Relight`, sum(`pv_edit_enter-Mykit-Reshape`) as `pv_edit_enter-Mykit-Reshape`, sum(`pv_edit_enter-Mykit-Resize`) as `pv_edit_enter-Mykit-Resize`, sum(`pv_edit_enter-Mykit-Sculpt`) as `pv_edit_enter-Mykit-Sculpt`, sum(`pv_edit_enter-Mykit-SkinTone`) as `pv_edit_enter-Mykit-SkinTone`, sum(`pv_edit_enter-Mykit-Smooth`) as `pv_edit_enter-Mykit-Smooth`, sum(`pv_edit_enter-Mykit-Stamp`) as `pv_edit_enter-Mykit-Stamp`, sum(`pv_edit_enter-Mykit-Stretch`) as `pv_edit_enter-Mykit-Stretch`, sum(`pv_edit_enter-Mykit-Text`) as `pv_edit_enter-Mykit-Text`, sum(`pv_edit_enter-Mykit-Texture`) as `pv_edit_enter-Mykit-Texture`, sum(`pv_edit_enter-Mykit-Vignette`) as `pv_edit_enter-Mykit-Vignette`, sum(`pv_edit_enter-Mykit-Whiten`) as `pv_edit_enter-Mykit-Whiten`, sum(`pv_edit_enter-Retouch-AI Retouch`) as `pv_edit_enter-Retouch-AI Retouch`, sum(`pv_edit_enter-Retouch-Acne`) as `pv_edit_enter-Retouch-Acne`, sum(`pv_edit_enter-Retouch-Align`) as `pv_edit_enter-Retouch-Align`, sum(`pv_edit_enter-Retouch-Brighten`) as `pv_edit_enter-Retouch-Brighten`, sum(`pv_edit_enter-Retouch-Contour`) as `pv_edit_enter-Retouch-Contour`, sum(`pv_edit_enter-Retouch-DarkCircles`) as `pv_edit_enter-Retouch-DarkCircles`, sum(`pv_edit_enter-Retouch-Details`) as `pv_edit_enter-Retouch-Details`, sum(`pv_edit_enter-Retouch-Firm`) as `pv_edit_enter-Retouch-Firm`, sum(`pv_edit_enter-Retouch-Foundation`) as `pv_edit_enter-Retouch-Foundation`, sum(`pv_edit_enter-Retouch-Highlighter`) as `pv_edit_enter-Retouch-Highlighter`, sum(`pv_edit_enter-Retouch-Iris`) as `pv_edit_enter-Retouch-Iris`, sum(`pv_edit_enter-Retouch-Magic`) as `pv_edit_enter-Retouch-Magic`, sum(`pv_edit_enter-Retouch-Matte`) as `pv_edit_enter-Retouch-Matte`, sum(`pv_edit_enter-Retouch-Reshape`) as `pv_edit_enter-Retouch-Reshape`, sum(`pv_edit_enter-Retouch-Resize`) as `pv_edit_enter-Retouch-Resize`, sum(`pv_edit_enter-Retouch-Sculpt`) as `pv_edit_enter-Retouch-Sculpt`, sum(`pv_edit_enter-Retouch-SkinTone`) as `pv_edit_enter-Retouch-SkinTone`, sum(`pv_edit_enter-Retouch-Smooth`) as `pv_edit_enter-Retouch-Smooth`, sum(`pv_edit_enter-Retouch-Texture`) as `pv_edit_enter-Retouch-Texture`, sum(`pv_edit_enter-Retouch-Whiten`) as `pv_edit_enter-Retouch-Whiten`, sum(`pv_edit_enter-Tools-AI Replace`) as `pv_edit_enter-Tools-AI Replace`, sum(`pv_edit_enter-Tools-Adjust`) as `pv_edit_enter-Tools-Adjust`, sum(`pv_edit_enter-Tools-Blur`) as `pv_edit_enter-Tools-Blur`, sum(`pv_edit_enter-Tools-Bokeh`) as `pv_edit_enter-Tools-Bokeh`, sum(`pv_edit_enter-Tools-Enhance`) as `pv_edit_enter-Tools-Enhance`, sum(`pv_edit_enter-Tools-Eraser`) as `pv_edit_enter-Tools-Eraser`, sum(`pv_edit_enter-Tools-Prism`) as `pv_edit_enter-Tools-Prism`, sum(`pv_edit_enter-Tools-Relight`) as `pv_edit_enter-Tools-Relight`, sum(`pv_edit_enter-Tools-Stamp`) as `pv_edit_enter-Tools-Stamp`, sum(`pv_edit_enter-Tools-Stretch`) as `pv_edit_enter-Tools-Stretch`, sum(`pv_edit_enter-Tools-Vignette`) as `pv_edit_enter-Tools-Vignette`, sum(`pv_edit_save-Creative-Background`) as `pv_edit_save-Creative-Background`, sum(`pv_edit_save-Creative-Colors`) as `pv_edit_save-Creative-Colors`, sum(`pv_edit_save-Creative-Glitter`) as `pv_edit_save-Creative-Glitter`, sum(`pv_edit_save-Creative-Sparkle`) as `pv_edit_save-Creative-Sparkle`, sum(`pv_edit_save-Creative-Text`) as `pv_edit_save-Creative-Text`,sum(`pv_edit_save-Hair-Bangs`) as `pv_edit_save-Hair-Bangs`,
sum(`pv_edit_save-Hair-HairDye`) as `pv_edit_save-Hair-HairDye`, sum(`pv_edit_save-Hair-Hairline`) as `pv_edit_save-Hair-Hairline`,
sum(`pv_edit_save-Hair-Hairstyles`) as `pv_edit_save-Hair-Hairstyles`, sum(`pv_edit_save-Makeup-Blush`) as `pv_edit_save-Makeup-Blush`,
sum(`pv_edit_save-Makeup-Contour`) as `pv_edit_save-Makeup-Contour`, sum(`pv_edit_save-Makeup-Eyebrows`) as `pv_edit_save-Makeup-Eyebrows`, sum(`pv_edit_save-Makeup-Eyecolor`) as `pv_edit_save-Makeup-Eyecolor`, sum(`pv_edit_save-Makeup-Eyelashes`) as `pv_edit_save-Makeup-Eyelashes`, sum(`pv_edit_save-Makeup-Eyeliner`) as `pv_edit_save-Makeup-Eyeliner`, sum(`pv_edit_save-Makeup-Eyeshadow`) as `pv_edit_save-Makeup-Eyeshadow`, sum(`pv_edit_save-Makeup-Lips`) as `pv_edit_save-Makeup-Lips`, sum(`pv_edit_save-Makeup-Sets`) as `pv_edit_save-Makeup-Sets`, sum(`pv_edit_save-Retouch-AI Retouch`) as `pv_edit_save-Retouch-AI Retouch`, sum(`pv_edit_save-Retouch-Acne`) as `pv_edit_save-Retouch-Acne`, sum(`pv_edit_save-Retouch-Align`) as `pv_edit_save-Retouch-Align`, sum(`pv_edit_save-Retouch-Brighten`) as `pv_edit_save-Retouch-Brighten`, sum(`pv_edit_save-Retouch-Contour`) as `pv_edit_save-Retouch-Contour`, sum(`pv_edit_save-Retouch-DarkCircles`) as `pv_edit_save-Retouch-DarkCircles`, sum(`pv_edit_save-Retouch-Details`) as `pv_edit_save-Retouch-Details`, sum(`pv_edit_save-Retouch-Firm`) as `pv_edit_save-Retouch-Firm`, sum(`pv_edit_save-Retouch-Foundation`) as `pv_edit_save-Retouch-Foundation`, sum(`pv_edit_save-Retouch-Highlighter`) as `pv_edit_save-Retouch-Highlighter`, sum(`pv_edit_save-Retouch-Iris`) as `pv_edit_save-Retouch-Iris`, sum(`pv_edit_save-Retouch-Magic`) as `pv_edit_save-Retouch-Magic`, sum(`pv_edit_save-Retouch-Matte`) as `pv_edit_save-Retouch-Matte`, sum(`pv_edit_save-Retouch-Reshape`) as `pv_edit_save-Retouch-Reshape`, sum(`pv_edit_save-Retouch-Resize`) as `pv_edit_save-Retouch-Resize`, sum(`pv_edit_save-Retouch-Sculpt`) as `pv_edit_save-Retouch-Sculpt`, sum(`pv_edit_save-Retouch-SkinTone`) as `pv_edit_save-Retouch-SkinTone`, sum(`pv_edit_save-Retouch-Smooth`) as `pv_edit_save-Retouch-Smooth`, sum(`pv_edit_save-Retouch-Texture`) as `pv_edit_save-Retouch-Texture`, sum(`pv_edit_save-Retouch-Whiten`) as `pv_edit_save-Retouch-Whiten`, sum(`pv_edit_save-Tools-AI Replace`) as `pv_edit_save-Tools-AI Replace`, sum(`pv_edit_save-Tools-Adjust`) as `pv_edit_save-Tools-Adjust`, sum(`pv_edit_save-Tools-Blur`) as `pv_edit_save-Tools-Blur`, sum(`pv_edit_save-Tools-Bokeh`) as `pv_edit_save-Tools-Bokeh`, sum(`pv_edit_save-Tools-Enhance`) as `pv_edit_save-Tools-Enhance`, sum(`pv_edit_save-Tools-Eraser`) as `pv_edit_save-Tools-Eraser`, sum(`pv_edit_save-Tools-Prism`) as `pv_edit_save-Tools-Prism`, sum(`pv_edit_save-Tools-Relight`) as `pv_edit_save-Tools-Relight`, sum(`pv_edit_save-Tools-Stamp`) as `pv_edit_save-Tools-Stamp`, sum(`pv_edit_save-Tools-Stretch`) as `pv_edit_save-Tools-Stretch`, sum(`pv_edit_save-Tools-Vignette`) as `pv_edit_save-Tools-Vignette`, sum(`pv_edit_use-Creative-Background`) as `pv_edit_use-Creative-Background`, sum(`pv_edit_use-Creative-Colors`) as `pv_edit_use-Creative-Colors`, sum(`pv_edit_use-Creative-Glitter`) as `pv_edit_use-Creative-Glitter`, sum(`pv_edit_use-Creative-Sparkle`) as `pv_edit_use-Creative-Sparkle`, sum(`pv_edit_use-Creative-Text`) as `pv_edit_use-Creative-Text`, sum(`pv_edit_use-Hair-Bangs`) as `pv_edit_use-Hair-Bangs`, sum(`pv_edit_use-Hair-HairDye`) as `pv_edit_use-Hair-HairDye`, sum(`pv_edit_use-Hair-Hairline`) as `pv_edit_use-Hair-Hairline`, sum(`pv_edit_use-Hair-Hairstyles`) as `pv_edit_use-Hair-Hairstyles`, sum(`pv_edit_use-Makeup-Blush`) as `pv_edit_use-Makeup-Blush`, sum(`pv_edit_use-Makeup-BuildLooks`) as `pv_edit_use-Makeup-BuildLooks`, sum(`pv_edit_use-Makeup-Contour`) as `pv_edit_use-Makeup-Contour`, sum(`pv_edit_use-Makeup-Eyebrows`) as `pv_edit_use-Makeup-Eyebrows`, sum(`pv_edit_use-Makeup-Eyecolor`) as `pv_edit_use-Makeup-Eyecolor`, sum(`pv_edit_use-Makeup-Eyelashes`) as `pv_edit_use-Makeup-Eyelashes`, sum(`pv_edit_use-Makeup-Eyeliner`) as `pv_edit_use-Makeup-Eyeliner`, sum(`pv_edit_use-Makeup-Eyeshadow`) as `pv_edit_use-Makeup-Eyeshadow`, sum(`pv_edit_use-Makeup-Lips`) as `pv_edit_use-Makeup-Lips`, sum(`pv_edit_use-Makeup-Sets`) as `pv_edit_use-Makeup-Sets`, sum(`pv_edit_use-Retouch-AI Retouch`) as `pv_edit_use-Retouch-AI Retouch`, sum(`pv_edit_use-Retouch-Acne`) as `pv_edit_use-Retouch-Acne`, sum(`pv_edit_use-Retouch-Align`) as `pv_edit_use-Retouch-Align`, sum(`pv_edit_use-Retouch-Brighten`) as `pv_edit_use-Retouch-Brighten`, sum(`pv_edit_use-Retouch-Contour`) as `pv_edit_use-Retouch-Contour`, sum(`pv_edit_use-Retouch-DarkCircles`) as `pv_edit_use-Retouch-DarkCircles`, sum(`pv_edit_use-Retouch-Details`) as `pv_edit_use-Retouch-Details`, sum(`pv_edit_use-Retouch-Firm`) as `pv_edit_use-Retouch-Firm`, sum(`pv_edit_use-Retouch-Foundation`) as `pv_edit_use-Retouch-Foundation`, sum(`pv_edit_use-Retouch-Highlighter`) as `pv_edit_use-Retouch-Highlighter`, sum(`pv_edit_use-Retouch-Iris`) as `pv_edit_use-Retouch-Iris`, sum(`pv_edit_use-Retouch-Magic`) as `pv_edit_use-Retouch-Magic`, sum(`pv_edit_use-Retouch-Matte`) as `pv_edit_use-Retouch-Matte`, sum(`pv_edit_use-Retouch-Reshape`) as `pv_edit_use-Retouch-Reshape`, sum(`pv_edit_use-Retouch-Resize`) as `pv_edit_use-Retouch-Resize`, sum(`pv_edit_use-Retouch-Sculpt`) as `pv_edit_use-Retouch-Sculpt`, sum(`pv_edit_use-Retouch-SkinTone`) as `pv_edit_use-Retouch-SkinTone`, sum(`pv_edit_use-Retouch-Smooth`) as `pv_edit_use-Retouch-Smooth`, sum(`pv_edit_use-Retouch-Texture`) as `pv_edit_use-Retouch-Texture`, sum(`pv_edit_use-Retouch-Whiten`) as `pv_edit_use-Retouch-Whiten`, sum(`pv_edit_use-Tools-AI Replace`) as `pv_edit_use-Tools-AI Replace`, sum(`pv_edit_use-Tools-Adjust`) as `pv_edit_use-Tools-Adjust`, sum(`pv_edit_use-Tools-Blur`) as `pv_edit_use-Tools-Blur`, sum(`pv_edit_use-Tools-Bokeh`) as `pv_edit_use-Tools-Bokeh`, sum(`pv_edit_use-Tools-Enhance`) as `pv_edit_use-Tools-Enhance`, sum(`pv_edit_use-Tools-Eraser`) as `pv_edit_use-Tools-Eraser`, sum(`pv_edit_use-Tools-Prism`) as `pv_edit_use-Tools-Prism`, sum(`pv_edit_use-Tools-Relight`) as `pv_edit_use-Tools-Relight`, sum(`pv_edit_use-Tools-Stamp`) as `pv_edit_use-Tools-Stamp`, sum(`pv_edit_use-Tools-Stretch`) as `pv_edit_use-Tools-Stretch`,sum(`pv_edit_use-Tools-Vignette`) as `pv_edit_use-Tools-Vignette`,sum(`pv_camera_enter-all-all_30`) as `pv_camera_enter-all-all_30`, sum(`pv_camera_save-Filter-all_30`) as `pv_camera_save-Filter-all_30`, sum(`pv_camera_save-all-all_30`) as `pv_camera_save-all-all_30`, sum(`pv_camera_taken-Filter-all_30`) as `pv_camera_taken-Filter-all_30`, sum(`pv_camera_taken-all-all_30`) as `pv_camera_taken-all-all_30`, sum(`pv_edit_enter-AI Style-all_30`) as `pv_edit_enter-AI Style-all_30`, sum(`pv_edit_enter-Creative-all_30`) as `pv_edit_enter-Creative-all_30`, sum(`pv_edit_enter-Filter-all_30`) as `pv_edit_enter-Filter-all_30`, sum(`pv_edit_enter-Hair-all_30`) as `pv_edit_enter-Hair-all_30`, sum(`pv_edit_enter-Makeup-all_30`) as `pv_edit_enter-Makeup-all_30`, sum(`pv_edit_enter-Mykit-all_30`) as `pv_edit_enter-Mykit-all_30`, sum(`pv_edit_enter-Presets-all_30`) as `pv_edit_enter-Presets-all_30`, sum(`pv_edit_enter-Retouch-all_30`) as `pv_edit_enter-Retouch-all_30`, sum(`pv_edit_enter-Tools-all_30`) as `pv_edit_enter-Tools-all_30`, sum(`pv_edit_enter-all-all_30`) as `pv_edit_enter-all-all_30`, sum(`pv_edit_save-AI Style-all_30`) as `pv_edit_save-AI Style-all_30`, sum(`pv_edit_save-Creative-all_30`) as `pv_edit_save-Creative-all_30`, sum(`pv_edit_save-Filter-all_30`) as `pv_edit_save-Filter-all_30`, sum(`pv_edit_save-Hair-all_30`) as `pv_edit_save-Hair-all_30`, sum(`pv_edit_save-Makeup-all_30`) as `pv_edit_save-Makeup-all_30`,
sum(`pv_edit_save-Presets-all_30`) as `pv_edit_save-Presets-all_30`, sum(`pv_edit_save-Retouch-all_30`) as `pv_edit_save-Retouch-all_30`, sum(`pv_edit_save-Tools-all_30`) as `pv_edit_save-Tools-all_30`, sum(`pv_edit_save-all-all_30`) as `pv_edit_save-all-all_30`, sum(`pv_edit_save-其他-all_30`) as `pv_edit_save-其他-all_30`, sum(`pv_edit_use-AI Style-all_30`) as `pv_edit_use-AI Style-all_30`, sum(`pv_edit_use-Creative-all_30`) as `pv_edit_use-Creative-all_30`, sum(`pv_edit_use-Filter-all_30`) as `pv_edit_use-Filter-all_30`, sum(`pv_edit_use-Hair-all_30`) as `pv_edit_use-Hair-all_30`, sum(`pv_edit_use-Makeup-all_30`) as `pv_edit_use-Makeup-all_30`, sum(`pv_edit_use-Presets-all_30`) as `pv_edit_use-Presets-all_30`, sum(`pv_edit_use-Retouch-all_30`) as `pv_edit_use-Retouch-all_30`, sum(`pv_edit_use-Tools-all_30`) as `pv_edit_use-Tools-all_30`, sum(`pv_func_video_enter-reshape_30`) as `pv_func_video_enter-reshape_30`, sum(`pv_func_video_use-foundation_30`) as `pv_func_video_use-foundation_30`, sum(`pv_func_video_enter-firm_30`) as `pv_func_video_enter-firm_30`, sum(`pv_func_video_enter-acne_30`) as `pv_func_video_enter-acne_30`, sum(`pv_func_video_use-sculpt_30`) as `pv_func_video_use-sculpt_30`, sum(`pv_func_video_enter-clarity_30`) as `pv_func_video_enter-clarity_30`, sum(`pv_func_video_use-brighten_30`) as `pv_func_video_use-brighten_30`, sum(`pv_func_video_use-reshape_30`) as `pv_func_video_use-reshape_30`, sum(`pv_func_video_use-matte_30`) as `pv_func_video_use-matte_30`, sum(`pv_func_video_enter-dark_circle_30`) as `pv_func_video_enter-dark_circle_30`, sum(`pv_func_video_enter-stretch_30`) as `pv_func_video_enter-stretch_30`, sum(`pv_video_magic_status-open_30`) as `pv_video_magic_status-open_30`, sum(`pv_video_save-skin_tone_30`) as `pv_video_save-skin_tone_30`, sum(`pv_func_video_enter-smooth_30`) as `pv_func_video_enter-smooth_30`,sum(`pv_func_video_enter-sculpt_30`) as `pv_func_video_enter-sculpt_30`, sum(`pv_video_save-whiten_30`) as `pv_video_save-whiten_30`, sum(`pv_func_video_use-clarity_30`) as `pv_func_video_use-clarity_30`, sum(`pv_video_save-acne_30`) as `pv_video_save-acne_30`, sum(`pv_video_save-reshape_30`) as `pv_video_save-reshape_30`, sum(`pv_video_save-contouring_30`) as `pv_video_save-contouring_30`, sum(`pv_video_save-brighten_30`) as `pv_video_save-brighten_30`, sum(`pv_func_video_enter-makeup_30`) as `pv_func_video_enter-makeup_30`, sum(`pv_func_video_use-makeup_30`) as `pv_func_video_use-makeup_30`, sum(`pv_func_video_enter-foundation_30`) as `pv_func_video_enter-foundation_30`, sum(`pv_video_save-stretch_30`) as `pv_video_save-stretch_30`, sum(`pv_video_save-overview_30`) as `pv_video_save-overview_30`, sum(`pv_video_start_edit-overview_30`) as `pv_video_start_edit-overview_30`, sum(`pv_func_video_enter-matte_30`) as `pv_func_video_enter-matte_30`, sum(`pv_func_video_use-firm_30`) as `pv_func_video_use-firm_30`, sum(`pv_func_video_use-whiten_30`) as `pv_func_video_use-whiten_30`, sum(`pv_video_save-matte_30`) as `pv_video_save-matte_30`, sum(`pv_video_save-foundation_30`) as `pv_video_save-foundation_30`, sum(`pv_func_video_enter-whiten_30`) as `pv_func_video_enter-whiten_30`, sum(`pv_func_video_enter-brighten_30`) as `pv_func_video_enter-brighten_30`, sum(`pv_func_video_use-stretch_30`) as `pv_func_video_use-stretch_30`, sum(`pv_video_save-firm_30`) as `pv_video_save-firm_30`, sum(`pv_video_save-dark_circle_30`) as `pv_video_save-dark_circle_30`, sum(`pv_func_video_use-smooth_30`) as `pv_func_video_use-smooth_30`, sum(`pv_video_magic_status-close_30`) as `pv_video_magic_status-close_30`, sum(`pv_func_video_use-skin_tone_30`) as `pv_func_video_use-skin_tone_30`, sum(`pv_video_save-sculpt_30`) as `pv_video_save-sculpt_30`, sum(`pv_func_video_use-dark_circle_30`) as `pv_func_video_use-dark_circle_30`, sum(`pv_func_video_use-acne_30`) as `pv_func_video_use-acne_30`, sum(`pv_video_save-smooth_30`) as `pv_video_save-smooth_30`, sum(`pv_func_video_use-contouring_30`) as `pv_func_video_use-contouring_30`, sum(`pv_video_save-clarity_30`) as `pv_video_save-clarity_30`, sum(`pv_func_video_enter-contouring_30`) as `pv_func_video_enter-contouring_30`, sum(`pv_func_video_enter-skin_tone_30`) as `pv_func_video_enter-skin_tone_30`,
sum(`pv_video_save-makeup_30`) as `pv_video_save-makeup_30`


,sum(`pv_camera_enter-all-all_60`) as `pv_camera_enter-all-all_60`, sum(`pv_camera_save-Filter-all_60`) as `pv_camera_save-Filter-all_60`, sum(`pv_camera_save-all-all_60`) as `pv_camera_save-all-all_60`,
sum(`pv_camera_taken-Filter-all_60`) as `pv_camera_taken-Filter-all_60`, sum(`pv_camera_taken-all-all_60`) as `pv_camera_taken-all-all_60`, sum(`pv_edit_enter-AI Style-all_60`) as `pv_edit_enter-AI Style-all_60`, sum(`pv_edit_enter-Creative-all_60`) as `pv_edit_enter-Creative-all_60`, sum(`pv_edit_enter-Filter-all_60`) as `pv_edit_enter-Filter-all_60`, sum(`pv_edit_enter-Hair-all_60`) as `pv_edit_enter-Hair-all_60`, sum(`pv_edit_enter-Makeup-all_60`) as `pv_edit_enter-Makeup-all_60`, sum(`pv_edit_enter-Mykit-all_60`) as `pv_edit_enter-Mykit-all_60`, sum(`pv_edit_enter-Presets-all_60`) as `pv_edit_enter-Presets-all_60`, sum(`pv_edit_enter-Retouch-all_60`) as `pv_edit_enter-Retouch-all_60`, sum(`pv_edit_enter-Tools-all_60`) as `pv_edit_enter-Tools-all_60`, sum(`pv_edit_enter-all-all_60`) as `pv_edit_enter-all-all_60`, sum(`pv_edit_save-AI Style-all_60`) as `pv_edit_save-AI Style-all_60`, sum(`pv_edit_save-Creative-all_60`) as `pv_edit_save-Creative-all_60`, sum(`pv_edit_save-Filter-all_60`) as `pv_edit_save-Filter-all_60`, sum(`pv_edit_save-Hair-all_60`) as `pv_edit_save-Hair-all_60`, sum(`pv_edit_save-Makeup-all_60`) as `pv_edit_save-Makeup-all_60`, sum(`pv_edit_save-Presets-all_60`) as `pv_edit_save-Presets-all_60`, sum(`pv_edit_save-Retouch-all_60`) as `pv_edit_save-Retouch-all_60`, sum(`pv_edit_save-Tools-all_60`) as `pv_edit_save-Tools-all_60`, sum(`pv_edit_save-all-all_60`) as `pv_edit_save-all-all_60`, sum(`pv_edit_save-其他-all_60`) as `pv_edit_save-其他-all_60`, sum(`pv_edit_use-AI Style-all_60`) as `pv_edit_use-AI Style-all_60`, sum(`pv_edit_use-Creative-all_60`) as `pv_edit_use-Creative-all_60`, sum(`pv_edit_use-Filter-all_60`) as `pv_edit_use-Filter-all_60`, sum(`pv_edit_use-Hair-all_60`) as `pv_edit_use-Hair-all_60`, sum(`pv_edit_use-Makeup-all_60`) as `pv_edit_use-Makeup-all_60`, sum(`pv_edit_use-Presets-all_60`) as `pv_edit_use-Presets-all_60`, sum(`pv_edit_use-Retouch-all_60`) as `pv_edit_use-Retouch-all_60`, sum(`pv_edit_use-Tools-all_60`) as `pv_edit_use-Tools-all_60`, sum(`pv_func_video_enter-reshape_60`) as `pv_func_video_enter-reshape_60`, sum(`pv_func_video_use-foundation_60`) as `pv_func_video_use-foundation_60`, sum(`pv_func_video_enter-firm_60`) as `pv_func_video_enter-firm_60`, sum(`pv_func_video_enter-acne_60`) as `pv_func_video_enter-acne_60`, sum(`pv_func_video_use-sculpt_60`) as `pv_func_video_use-sculpt_60`, sum(`pv_func_video_enter-clarity_60`) as `pv_func_video_enter-clarity_60`, sum(`pv_func_video_use-brighten_60`) as `pv_func_video_use-brighten_60`, sum(`pv_func_video_use-reshape_60`) as `pv_func_video_use-reshape_60`, sum(`pv_func_video_use-matte_60`) as `pv_func_video_use-matte_60`, sum(`pv_func_video_enter-dark_circle_60`) as `pv_func_video_enter-dark_circle_60`, sum(`pv_func_video_enter-stretch_60`) as `pv_func_video_enter-stretch_60`, sum(`pv_video_magic_status-open_60`) as `pv_video_magic_status-open_60`, sum(`pv_video_save-skin_tone_60`) as `pv_video_save-skin_tone_60`, sum(`pv_func_video_enter-smooth_60`) as `pv_func_video_enter-smooth_60`,sum(`pv_func_video_enter-sculpt_60`) as `pv_func_video_enter-sculpt_60`, sum(`pv_video_save-whiten_60`) as `pv_video_save-whiten_60`, sum(`pv_func_video_use-clarity_60`) as `pv_func_video_use-clarity_60`, sum(`pv_video_save-acne_60`) as `pv_video_save-acne_60`, sum(`pv_video_save-reshape_60`) as `pv_video_save-reshape_60`, sum(`pv_video_save-contouring_60`) as `pv_video_save-contouring_60`, sum(`pv_video_save-brighten_60`) as `pv_video_save-brighten_60`, sum(`pv_func_video_enter-makeup_60`) as `pv_func_video_enter-makeup_60`, sum(`pv_func_video_use-makeup_60`) as `pv_func_video_use-makeup_60`, sum(`pv_func_video_enter-foundation_60`) as `pv_func_video_enter-foundation_60`, sum(`pv_video_save-stretch_60`) as `pv_video_save-stretch_60`, sum(`pv_video_save-overview_60`) as `pv_video_save-overview_60`, sum(`pv_video_start_edit-overview_60`) as `pv_video_start_edit-overview_60`, sum(`pv_func_video_enter-matte_60`) as `pv_func_video_enter-matte_60`, sum(`pv_func_video_use-firm_60`) as `pv_func_video_use-firm_60`, sum(`pv_func_video_use-whiten_60`) as `pv_func_video_use-whiten_60`, sum(`pv_video_save-matte_60`) as `pv_video_save-matte_60`, sum(`pv_video_save-foundation_60`) as `pv_video_save-foundation_60`, sum(`pv_func_video_enter-whiten_60`) as `pv_func_video_enter-whiten_60`, sum(`pv_func_video_enter-brighten_60`) as `pv_func_video_enter-brighten_60`, sum(`pv_func_video_use-stretch_60`) as `pv_func_video_use-stretch_60`, sum(`pv_video_save-firm_60`) as `pv_video_save-firm_60`, sum(`pv_video_save-dark_circle_60`) as `pv_video_save-dark_circle_60`, sum(`pv_func_video_use-smooth_60`) as `pv_func_video_use-smooth_60`, sum(`pv_video_magic_status-close_60`) as `pv_video_magic_status-close_60`, sum(`pv_func_video_use-skin_tone_60`) as `pv_func_video_use-skin_tone_60`, sum(`pv_video_save-sculpt_60`) as `pv_video_save-sculpt_60`, sum(`pv_func_video_use-dark_circle_60`) as `pv_func_video_use-dark_circle_60`, sum(`pv_func_video_use-acne_60`) as `pv_func_video_use-acne_60`, sum(`pv_video_save-smooth_60`) as `pv_video_save-smooth_60`, sum(`pv_func_video_use-contouring_60`) as `pv_func_video_use-contouring_60`, sum(`pv_video_save-clarity_60`) as `pv_video_save-clarity_60`, sum(`pv_func_video_enter-contouring_60`) as `pv_func_video_enter-contouring_60`, sum(`pv_func_video_enter-skin_tone_60`) as `pv_func_video_enter-skin_tone_60`,
sum(`pv_video_save-makeup_60`) as `pv_video_save-makeup_60`

,sum(`pv_camera_enter-all-all_90`) as `pv_camera_enter-all-all_90`, sum(`pv_camera_save-Filter-all_90`) as `pv_camera_save-Filter-all_90`, sum(`pv_camera_save-all-all_90`) as `pv_camera_save-all-all_90`,
sum(`pv_camera_taken-Filter-all_90`) as `pv_camera_taken-Filter-all_90`, sum(`pv_camera_taken-all-all_90`) as `pv_camera_taken-all-all_90`, sum(`pv_edit_enter-AI Style-all_90`) as `pv_edit_enter-AI Style-all_90`, sum(`pv_edit_enter-Creative-all_90`) as `pv_edit_enter-Creative-all_90`, sum(`pv_edit_enter-Filter-all_90`) as `pv_edit_enter-Filter-all_90`, sum(`pv_edit_enter-Hair-all_90`) as `pv_edit_enter-Hair-all_90`, sum(`pv_edit_enter-Makeup-all_90`) as `pv_edit_enter-Makeup-all_90`, sum(`pv_edit_enter-Mykit-all_90`) as `pv_edit_enter-Mykit-all_90`, sum(`pv_edit_enter-Presets-all_90`) as `pv_edit_enter-Presets-all_90`, sum(`pv_edit_enter-Retouch-all_90`) as `pv_edit_enter-Retouch-all_90`, sum(`pv_edit_enter-Tools-all_90`) as `pv_edit_enter-Tools-all_90`, sum(`pv_edit_enter-all-all_90`) as `pv_edit_enter-all-all_90`, sum(`pv_edit_save-AI Style-all_90`) as `pv_edit_save-AI Style-all_90`, sum(`pv_edit_save-Creative-all_90`) as `pv_edit_save-Creative-all_90`, sum(`pv_edit_save-Filter-all_90`) as `pv_edit_save-Filter-all_90`, sum(`pv_edit_save-Hair-all_90`) as `pv_edit_save-Hair-all_90`, sum(`pv_edit_save-Makeup-all_90`) as `pv_edit_save-Makeup-all_90`, sum(`pv_edit_save-Presets-all_90`) as `pv_edit_save-Presets-all_90`, sum(`pv_edit_save-Retouch-all_90`) as `pv_edit_save-Retouch-all_90`, sum(`pv_edit_save-Tools-all_90`) as `pv_edit_save-Tools-all_90`, sum(`pv_edit_save-all-all_90`) as `pv_edit_save-all-all_90`, sum(`pv_edit_save-其他-all_90`) as `pv_edit_save-其他-all_90`, sum(`pv_edit_use-AI Style-all_90`) as `pv_edit_use-AI Style-all_90`, sum(`pv_edit_use-Creative-all_90`) as `pv_edit_use-Creative-all_90`, sum(`pv_edit_use-Filter-all_90`) as `pv_edit_use-Filter-all_90`, sum(`pv_edit_use-Hair-all_90`) as `pv_edit_use-Hair-all_90`, sum(`pv_edit_use-Makeup-all_90`) as `pv_edit_use-Makeup-all_90`, sum(`pv_edit_use-Presets-all_90`) as `pv_edit_use-Presets-all_90`, sum(`pv_edit_use-Retouch-all_90`) as `pv_edit_use-Retouch-all_90`, sum(`pv_edit_use-Tools-all_90`) as `pv_edit_use-Tools-all_90`, sum(`pv_func_video_enter-reshape_90`) as `pv_func_video_enter-reshape_90`, sum(`pv_func_video_use-foundation_90`) as `pv_func_video_use-foundation_90`, sum(`pv_func_video_enter-firm_90`) as `pv_func_video_enter-firm_90`, sum(`pv_func_video_enter-acne_90`) as `pv_func_video_enter-acne_90`, sum(`pv_func_video_use-sculpt_90`) as `pv_func_video_use-sculpt_90`, sum(`pv_func_video_enter-clarity_90`) as `pv_func_video_enter-clarity_90`, sum(`pv_func_video_use-brighten_90`) as `pv_func_video_use-brighten_90`, sum(`pv_func_video_use-reshape_90`) as `pv_func_video_use-reshape_90`, sum(`pv_func_video_use-matte_90`) as `pv_func_video_use-matte_90`, sum(`pv_func_video_enter-dark_circle_90`) as `pv_func_video_enter-dark_circle_90`, sum(`pv_func_video_enter-stretch_90`) as `pv_func_video_enter-stretch_90`, sum(`pv_video_magic_status-open_90`) as `pv_video_magic_status-open_90`, sum(`pv_video_save-skin_tone_90`) as `pv_video_save-skin_tone_90`, sum(`pv_func_video_enter-smooth_90`) as `pv_func_video_enter-smooth_90`,sum(`pv_func_video_enter-sculpt_90`) as `pv_func_video_enter-sculpt_90`, sum(`pv_video_save-whiten_90`) as `pv_video_save-whiten_90`, sum(`pv_func_video_use-clarity_90`) as `pv_func_video_use-clarity_90`, sum(`pv_video_save-acne_90`) as `pv_video_save-acne_90`, sum(`pv_video_save-reshape_90`) as `pv_video_save-reshape_90`, sum(`pv_video_save-contouring_90`) as `pv_video_save-contouring_90`, sum(`pv_video_save-brighten_90`) as `pv_video_save-brighten_90`, sum(`pv_func_video_enter-makeup_90`) as `pv_func_video_enter-makeup_90`, sum(`pv_func_video_use-makeup_90`) as `pv_func_video_use-makeup_90`, sum(`pv_func_video_enter-foundation_90`) as `pv_func_video_enter-foundation_90`, sum(`pv_video_save-stretch_90`) as `pv_video_save-stretch_90`, sum(`pv_video_save-overview_90`) as `pv_video_save-overview_90`, sum(`pv_video_start_edit-overview_90`) as `pv_video_start_edit-overview_90`, sum(`pv_func_video_enter-matte_90`) as `pv_func_video_enter-matte_90`, sum(`pv_func_video_use-firm_90`) as `pv_func_video_use-firm_90`, sum(`pv_func_video_use-whiten_90`) as `pv_func_video_use-whiten_90`, sum(`pv_video_save-matte_90`) as `pv_video_save-matte_90`, sum(`pv_video_save-foundation_90`) as `pv_video_save-foundation_90`, sum(`pv_func_video_enter-whiten_90`) as `pv_func_video_enter-whiten_90`, sum(`pv_func_video_enter-brighten_90`) as `pv_func_video_enter-brighten_90`, sum(`pv_func_video_use-stretch_90`) as `pv_func_video_use-stretch_90`, sum(`pv_video_save-firm_90`) as `pv_video_save-firm_90`, sum(`pv_video_save-dark_circle_90`) as `pv_video_save-dark_circle_90`, sum(`pv_func_video_use-smooth_90`) as `pv_func_video_use-smooth_90`, sum(`pv_video_magic_status-close_90`) as `pv_video_magic_status-close_90`, sum(`pv_func_video_use-skin_tone_90`) as `pv_func_video_use-skin_tone_90`, sum(`pv_video_save-sculpt_90`) as `pv_video_save-sculpt_90`, sum(`pv_func_video_use-dark_circle_90`) as `pv_func_video_use-dark_circle_90`, sum(`pv_func_video_use-acne_90`) as `pv_func_video_use-acne_90`, sum(`pv_video_save-smooth_90`) as `pv_video_save-smooth_90`, sum(`pv_func_video_use-contouring_90`) as `pv_func_video_use-contouring_90`, sum(`pv_video_save-clarity_90`) as `pv_video_save-clarity_90`, sum(`pv_func_video_enter-contouring_90`) as `pv_func_video_enter-contouring_90`, sum(`pv_func_video_enter-skin_tone_90`) as `pv_func_video_enter-skin_tone_90`,
sum(`pv_video_save-makeup_90`) as `pv_video_save-makeup_90`

        , sum(aigc_enter_pv) aigc_enter_pv, sum(aigc_use_pv) aigc_use_pv, sum(aigc_save_pv) aigc_save_pv,
        sum(pop_exposure) pop_exposure, sum(pop_click) pop_click,
        sum(content_exposure) content_exposure, sum(content_click) content_click, sum(max_module_positon) max_module_positon, sum(sub_page_enter) sub_page_enter, sum(sub_page_click) sub_page_click, sum(force_sub_page_enter) force_sub_page_enter, sum(force_sub_page_click) force_sub_page_click, sum(subscript_sub_page_enter) subscript_sub_page_enter, sum(subscript_sub_page_click) subscript_sub_page_click, sum(other_sub_page_enter) other_sub_page_enter, sum(other_sub_page_click) other_sub_page_click, sum(max_impression_pv) max_impression_pv, sum(impression_pv) impression_pv, sum(click_pv) click_pv, sum(aigc_enter_pv_30) aigc_enter_pv_30, sum(aigc_use_pv_30) aigc_use_pv_30, sum(aigc_save_pv_30) aigc_save_pv_30, sum(pop_exposure_30) pop_exposure_30, sum(pop_click_30) pop_click_30, sum(content_exposure_30) content_exposure_30, sum(content_click_30) content_click_30, sum(max_module_positon_30) max_module_positon_30, sum(sub_page_enter_30) sub_page_enter_30, sum(sub_page_click_30) sub_page_click_30, sum(force_sub_page_enter_30) force_sub_page_enter_30, sum(force_sub_page_click_30) force_sub_page_click_30, sum(subscript_sub_page_enter_30) subscript_sub_page_enter_30, sum(subscript_sub_page_click_30) subscript_sub_page_click_30, sum(other_sub_page_enter_30) other_sub_page_enter_30, sum(other_sub_page_click_30) other_sub_page_click_30, sum(max_impression_pv_30) max_impression_pv_30, sum(impression_pv_30) impression_pv_30, sum(click_pv_30) click_pv_30, sum(aigc_enter_pv_60) aigc_enter_pv_60, sum(aigc_use_pv_60) aigc_use_pv_60, sum(aigc_save_pv_60) aigc_save_pv_60, sum(pop_exposure_60) pop_exposure_60, sum(pop_click_60) pop_click_60, sum(content_exposure_60) content_exposure_60, sum(content_click_60) content_click_60, sum(max_module_positon_60) max_module_positon_60, sum(sub_page_enter_60) sub_page_enter_60, sum(sub_page_click_60) sub_page_click_60, sum(force_sub_page_enter_60) force_sub_page_enter_60, sum(force_sub_page_click_60) force_sub_page_click_60, sum(subscript_sub_page_enter_60) subscript_sub_page_enter_60, sum(subscript_sub_page_click_60) subscript_sub_page_click_60, sum(other_sub_page_enter_60) other_sub_page_enter_60, sum(other_sub_page_click_60) other_sub_page_click_60, sum(max_impression_pv_60) max_impression_pv_60, sum(impression_pv_60) impression_pv_60, sum(click_pv_60) click_pv_60, sum(aigc_enter_pv_90) aigc_enter_pv_90, sum(aigc_use_pv_90) aigc_use_pv_90, sum(aigc_save_pv_90) aigc_save_pv_90, sum(pop_exposure_90) pop_exposure_90, sum(pop_click_90) pop_click_90, sum(content_exposure_90) content_exposure_90, sum(content_click_90) content_click_90, sum(max_module_positon_90) max_module_positon_90, sum(sub_page_enter_90) sub_page_enter_90, sum(sub_page_click_90) sub_page_click_90, sum(force_sub_page_enter_90) force_sub_page_enter_90, sum(force_sub_page_click_90) force_sub_page_click_90, sum(subscript_sub_page_enter_90) subscript_sub_page_enter_90, sum(subscript_sub_page_click_90) subscript_sub_page_click_90, sum(other_sub_page_enter_90) other_sub_page_enter_90, sum(other_sub_page_click_90) other_sub_page_click_90, sum(max_impression_pv_90) max_impression_pv_90, sum(impression_pv_90) impression_pv_90, sum(click_pv_90) click_pv_90, sum(grow_aigc_enter_pv) grow_aigc_enter_pv, sum(grow_aigc_use_pv) grow_aigc_use_pv, sum(grow_aigc_save_pv) grow_aigc_save_pv, sum(grow_pop_exposure) grow_pop_exposure, sum(grow_pop_click) grow_pop_click, sum(grow_content_exposure) grow_content_exposure, sum(grow_content_click) grow_content_click, sum(grow_max_module_positon) grow_max_module_positon, sum(grow_sub_page_enter) grow_sub_page_enter, sum(grow_sub_page_click) grow_sub_page_click, sum(force_grow_sub_page_enter) force_grow_sub_page_enter, sum(force_grow_sub_page_click) force_grow_sub_page_click, sum(subscript_grow_sub_page_enter) subscript_grow_sub_page_enter, sum(subscript_grow_sub_page_click) subscript_grow_sub_page_click, sum(other_grow_sub_page_enter) other_grow_sub_page_enter, sum(other_grow_sub_page_click) other_grow_sub_page_click, sum(grow_max_impression_pv) grow_max_impression_pv, sum(grow_impression_pv) grow_impression_pv, sum(grow_click_pv) grow_click_pv,
        -- --  sum(puzzle_click_pv) puzzle_click_pv, sum(puzzle_save_pv) puzzle_save_pv, sum(puzzle_click_pv_30) puzzle_click_pv_30, sum(puzzle_save_pv_30) puzzle_save_pv_30, sum(puzzle_click_pv_60) puzzle_click_pv_60, sum(puzzle_save_pv_60) puzzle_save_pv_60, sum(puzzle_click_pv_90) puzzle_click_pv_90, sum(puzzle_save_pv_90) puzzle_save_pv_90,
         sum(pay_function_click_pv) pay_function_click_pv, sum(free_function_click_pv) free_function_click_pv, sum(free_function_save_pv) free_function_save_pv, sum(pay_function_click_pv_30) pay_function_click_pv_30, sum(free_function_click_pv_30) free_function_click_pv_30, sum(free_function_save_pv_30) free_function_save_pv_30, sum(pay_function_click_pv_60) pay_function_click_pv_60, sum(free_function_click_pv_60) free_function_click_pv_60, sum(free_function_save_pv_60) free_function_save_pv_60, sum(pay_function_click_pv_90) pay_function_click_pv_90, sum(free_function_click_pv_90) free_function_click_pv_90, sum(free_function_save_pv_90) free_function_save_pv_90, sum(grow_pay_function_click_pv) grow_pay_function_click_pv, sum(grow_free_function_click_pv) grow_free_function_click_pv, sum(grow_free_function_save_pv) grow_free_function_save_pv, sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv, sum(pay_duffle_click_pv_30) pay_duffle_click_pv_30, sum(free_duffle_click_pv_30) free_duffle_click_pv_30, sum(free_duffle_save_pv_30) free_duffle_save_pv_30, sum(pay_duffle_click_pv_60) pay_duffle_click_pv_60, sum(free_duffle_click_pv_60) free_duffle_click_pv_60, sum(free_duffle_save_pv_60) free_duffle_save_pv_60, sum(pay_duffle_click_pv_90) pay_duffle_click_pv_90, sum(free_duffle_click_pv_90) free_duffle_click_pv_90, sum(free_duffle_save_pv_90) free_duffle_save_pv_90, sum(grow_pay_duffle_click_pv) grow_pay_duffle_click_pv, sum(grow_free_duffle_click_pv) grow_free_duffle_click_pv, sum(grow_free_duffle_save_pv) grow_free_duffle_save_pv, sum(function_num) function_num, sum(function_num_pre) function_num_pre, sum(function_num_30) function_num_30, sum(function_num_60) function_num_60, sum(function_num_90) function_num_90, sum(grow_function_num) grow_function_num, sum(grow_edit_enter_pv) grow_edit_enter_pv, sum(grow_edit_save_pv) grow_edit_save_pv, sum(grow_take_photo_pv) grow_take_photo_pv, sum(grow_take_photo_save_pv) grow_take_photo_save_pv, --sum(grow_selftake_enter_pv) grow_selftake_enter_pv,
          sum(grow_take_video_pv) grow_take_video_pv, sum(grow_take_video_save_pv) grow_take_video_save_pv, sum(homepage_exposure_pv) homepage_exposure_pv
        --  sum(homepage_click_pv) homepage_click_pv, sum(homepage_feature_show_pv) homepage_feature_show_pv, sum(homepage_feature_click_pv) homepage_feature_click_pv, sum(homepage_banner_show_pv) homepage_banner_show_pv, sum(homepage_banner_click_pv) homepage_banner_click_pv, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv, sum(homepage_topic_show_pv) homepage_topic_show_pv, sum(homepage_topic_click_pv) homepage_topic_click_pv, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv, sum(homepage_exposure_pv_30) homepage_exposure_pv_30, sum(homepage_click_pv_30) homepage_click_pv_30, sum(homepage_feature_show_pv_30) homepage_feature_show_pv_30, sum(homepage_feature_click_pv_30) homepage_feature_click_pv_30, sum(homepage_banner_show_pv_30) homepage_banner_show_pv_30, sum(homepage_banner_click_pv_30) homepage_banner_click_pv_30, sum(homepage_reconmend_show_pv_30) homepage_reconmend_show_pv_30, sum(homepage_reconmend_click_pv_30) homepage_reconmend_click_pv_30, sum(homepage_topic_show_pv_30) homepage_topic_show_pv_30, sum(homepage_topic_click_pv_30) homepage_topic_click_pv_30, sum(homepage_miniapp_show_pv_30) homepage_miniapp_show_pv_30, sum(homepage_miniapp_click_pv_30) homepage_miniapp_click_pv_30, sum(homepage_exposure_pv_60) homepage_exposure_pv_60, sum(homepage_click_pv_60) homepage_click_pv_60, sum(homepage_feature_show_pv_60) homepage_feature_show_pv_60, sum(homepage_feature_click_pv_60) homepage_feature_click_pv_60, sum(homepage_banner_show_pv_60) homepage_banner_show_pv_60, sum(homepage_banner_click_pv_60) homepage_banner_click_pv_60, sum(homepage_reconmend_show_pv_60) homepage_reconmend_show_pv_60, sum(homepage_reconmend_click_pv_60) homepage_reconmend_click_pv_60, sum(homepage_topic_show_pv_60) homepage_topic_show_pv_60, sum(homepage_topic_click_pv_60) homepage_topic_click_pv_60, sum(homepage_miniapp_show_pv_60) homepage_miniapp_show_pv_60, sum(homepage_miniapp_click_pv_60) homepage_miniapp_click_pv_60, sum(homepage_exposure_pv_90) homepage_exposure_pv_90, sum(homepage_click_pv_90) homepage_click_pv_90, sum(homepage_feature_show_pv_90) homepage_feature_show_pv_90, sum(homepage_feature_click_pv_90) homepage_feature_click_pv_90, sum(homepage_banner_show_pv_90) homepage_banner_show_pv_90, sum(homepage_banner_click_pv_90) homepage_banner_click_pv_90, sum(homepage_reconmend_show_pv_90) homepage_reconmend_show_pv_90, sum(homepage_reconmend_click_pv_90) homepage_reconmend_click_pv_90, sum(homepage_topic_show_pv_90) homepage_topic_show_pv_90, sum(homepage_topic_click_pv_90) homepage_topic_click_pv_90, sum(homepage_miniapp_show_pv_90) homepage_miniapp_show_pv_90, sum(homepage_miniapp_click_pv_90) homepage_miniapp_click_pv_90
from
(
    select g.event_date_hk,g.app_name,g.user_pseudo_id,g.uuid
         ,coalesce(is_current_trial,0) is_current_trial
         ,current_trial_day
         ,is_current_subscription_cancelled
         ,coalesce(is_current_pay,0) is_current_pay
         ,coalesce(past_sub_times,0) past_sub_times
         ,coalesce(trial_times,0) trial_times
         ,coalesce(cancel_subscription_times,0) cancel_subscription_times
         ,coalesce(refund_subscription_times,0) refund_subscription_times
         ,coalesce(promotional_paying_times,0) promotional_paying_times
         -- 预测指标
         ,coalesce(sub_365,0) sub_365
         ,coalesce(sub_90,0) sub_90
         ,coalesce(sub_30,0) sub_30
         ,coalesce(sub_7,0) sub_7
         ,coalesce(sub_revenue_365,0) sub_revenue_365
         ,coalesce(sub_revenue_90,0) sub_revenue_90
         ,coalesce(sub_revenue_30,0) sub_revenue_30
         ,coalesce(sub_revenue_7,0) sub_revenue_7
         ,coalesce(credit_365,0) credit_365
         ,coalesce(credit_90,0) credit_90
         ,coalesce(credit_revenue_365,0) credit_revenue_365
         ,coalesce(credit_revenue_90,0) credit_revenue_90
    from goal_users g
    left join his_sub_event hs
    on g.event_date_hk=hs.event_date_hk and g.app_name=hs.app_name and g.uuid=hs.uuid
    left join future_sub_pay fs
    on g.event_date_hk=fs.event_date_hk and g.app_name=fs.app_name and g.uuid=fs.uuid
    left join future_credit_pay fc
    on g.event_date_hk=fc.event_date_hk and g.app_name=fc.app_name and g.uuid=fc.uuid
) g
left join behave_event b
on g.event_date_hk=b.date and g.app_name=b.app_name and g.user_pseudo_id=b.user_pseudo_id
-- left join dau_type d
-- on g.event_date_hk=d.event_date_hk and g.app_name=d.app_name and g.user_pseudo_id=d.user_pseudo_id
left join future_ad_revenue fa
on g.event_date_hk=fa.event_date_hk and g.app_name=fa.app_name and g.user_pseudo_id=fa.user_pseudo_id
-- left join future_active fac
-- on g.event_date_hk=fac.event_date_hk and g.app_name=fac.app_name and g.user_pseudo_id=fac.user_pseudo_id
-- left join gid_firebase_id gi
-- on g.event_date_hk=gi.event_date_hk and g.app_name=gi.app_name and g.user_pseudo_id=gi.last_user_pseudo_id
group by 1,2,3
)
;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;

-- 需要保证历史取的一年内收入也能正确，不然放入预测的数据就不对了，因此调度的时候近1年的数据都要重跑
-- DECLARE mDATE_START DATE DEFAULT '2023-03-01';
-- DECLARE mDATE_END DATE DEFAULT '2023-03-31';

DECLARE mDATE_START DATE DEFAULT '2023-02-01';
DECLARE mDATE_END DATE DEFAULT '2023-02-28';

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2;
-- create table beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2 as

delete from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2 where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2

with goal_users_pre as
(
    select event_date_hk,user_pseudo_id
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between mDATE_START and mDATE_END
        and first_active_date>='2022-01-01'
)
,
-- gid_firebase_id as
-- (
--     select 'BeautyPlus' app_name,event_date_hk,gid,last_user_pseudo_id
--     from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
--     where event_date_hk between mDATE_START and mDATE_END
--         and first_active_date>='2022-01-01'
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
    select 'BeautyPlus' app_name,gu.event_date_hk,gu.user_pseudo_id,uu.uuid
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
    where event_date_hk>='2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus')

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
    where event_date_hk<'2024-01-01' and event_date_hk between mDATE_START and mDATE_END and app_id in ('BeautyPlus')
)
,
sub_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) sub_revenue
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)  -- 最多预测未来一年
        and app_id in('BeautyPlus')
        and order_status in (1,2)
    group by 1,2,3
)
,
credit_event as
(
    select
        app_id app_name,uuid,standard_order_date,sum(payment_price_usd) credit_revenue
    from `dataintegration-265403.purchase.dwd_da_purchase_daily`
    where standard_order_date between mDATE_START and DATE_ADD(mDATE_END,interval 365 day)  -- 最多预测未来一年
        and app_id in('BeautyPlus')
        and order_status in (1,2)  -- 这个确认下
    group by 1,2,3
)
,
ad_event as
(
    -- 仅2024开始有数
    select event_date,app_name,user_pseudo_id,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where event_date between '2024-01-01' and DATE_ADD(mDATE_END,interval 365 day)
        and app_name in ('BeautyPlus')
    group by 1,2,3
)
,
behave_event as
(
    select 'BeautyPlus' app_name,*
    from beautyplus-bc0ed.temp.dws_dz_his_split_user_behave
    where date between mDATE_START and mDATE_END

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
        where event_date_hk between mDATE_START and mDATE_END
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
        where event_date_hk between mDATE_START and mDATE_END
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
        where event_date_hk between mDATE_START and mDATE_END
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
--         where event_date_hk between mDATE_START and mDATE_END
--     ) a
--     cross join `dataintegration-265403.stat.stat_active_advice_detail_d` b
--     where b.app_name = 'BeautyPlus' and b.event_date_hk between DATE_ADD(a.date, INTERVAL 1 DAY) and DATE_ADD(a.date, INTERVAL 365 DAY)
--     group by 1,2,3
-- )
-- ,
-- dau_type as
-- (
--     select app_name,event_date event_date_hk,user_pseudo_id
--         ,max(is_paying) is_paying,max(is_consum) is_consum
--         ,max(sub_revenue) sub_revenue,max(consum_revenue) consum_revenue,max(revenue) revenue
--     from `dataintegration-265403.temp.dau_type`
--     where app_name in ('BeautyPlus')
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
--         ,sum(fac.active_365) active_365,sum(fac.active_90) active_90,sum(fac.active_30) active_30,sum(fac.active_7) active_7

        -- b
        , max(is_new) is_new, max(is_ua) is_ua, max(media_source) media_source, max(android_level) android_level, max(permanent_country) permanent_country, max(platform) platform, max(brand) brand, max(model) model, max(phone_price) phone_price, max(language) language, max(operating_system) operating_system, min(first_active_date) first_active_date, max(install_days) install_days, max(last_active_date) last_active_date, min(last_active_days) last_active_days, sum(active_mins_90d) active_mins_90d, sum(active_sessions_90d) active_sessions_90d, sum(active_mins_7d) active_mins_7d, sum(active_sessions_7d) active_sessions_7d, max(active_category) active_category, sum(life_time_active_days) life_time_active_days, sum(active_days_90d) active_days_90d, sum(active_days_7d) active_days_7d, sum(active_days_60) active_days_60, sum(active_days_30) active_days_30, sum(active_days_14) active_days_14, sum(active_days_365) active_days_365, sum(holiday_active_days_365) holiday_active_days_365, sum(weekend_active_days_365) weekend_active_days_365, sum(weekend_include_five_active_days_365) weekend_include_five_active_days_365, sum(holiday_active_days_365)/sum(active_days_365) holiday_active_ratio, sum(weekend_active_days_365)/sum(active_days_365) weekend_active_ratio, sum(weekend_include_five_active_days_365)/sum(active_days_365) weekend_include_five_active_ratio
        , sum(pv_tab0_edit_entry) pv_tab0_edit_entry, sum(pv_tab0_edit_save) pv_tab0_edit_save, sum(pv_tab0_movie_save) pv_tab0_movie_save, sum(pv_tab0_movie_shoot) pv_tab0_movie_shoot, sum(pv_tab0_selfie_entry) pv_tab0_selfie_entry, sum(pv_tab0_shoot_save) pv_tab0_shoot_save, sum(pv_tab0_shoot_shoot) pv_tab0_shoot_shoot, sum(pv_tab0_video_save) pv_tab0_video_save, sum(pv_tab0_video_shoot) pv_tab0_video_shoot, sum(pv_tab0_videoedit_entry) pv_tab0_videoedit_entry, sum(pv_tab0_videoedit_save) pv_tab0_videoedit_save, sum(pv_tab1_edit_beauty_click) pv_tab1_edit_beauty_click, sum(pv_tab1_edit_beauty_save) pv_tab1_edit_beauty_save, sum(pv_tab1_edit_creative_click) pv_tab1_edit_creative_click, sum(pv_tab1_edit_creative_save) pv_tab1_edit_creative_save, sum(pv_tab1_edit_edit_click) pv_tab1_edit_edit_click, sum(pv_tab1_edit_edit_save) pv_tab1_edit_edit_save, sum(pv_tab1_edit_filter_click) pv_tab1_edit_filter_click, sum(pv_tab1_edit_filter_save) pv_tab1_edit_filter_save, sum(pv_tab1_edit_makeup_click) pv_tab1_edit_makeup_click, sum(pv_tab1_edit_makeup_save) pv_tab1_edit_makeup_save, sum(pv_tab1_edit_senioredit_click) pv_tab1_edit_senioredit_click, sum(pv_tab1_shoot_ar_save) pv_tab1_shoot_ar_save, sum(pv_tab1_shoot_ar_shoot) pv_tab1_shoot_ar_shoot, sum(pv_tab1_shoot_beauty_save) pv_tab1_shoot_beauty_save, sum(pv_tab1_shoot_filter_save) pv_tab1_shoot_filter_save, sum(pv_tab1_shoot_filter_shoot) pv_tab1_shoot_filter_shoot, sum(pv_tab1_shoot_look_save) pv_tab1_shoot_look_save, sum(pv_tab1_shoot_look_shoot) pv_tab1_shoot_look_shoot, sum(pv_tab1_shoot_makeup_save) pv_tab1_shoot_makeup_save, sum(pv_tab1_shoot_makeup_shoot) pv_tab1_shoot_makeup_shoot, sum(pv_tab2_edit_beauty_AIbeauty_click) pv_tab2_edit_beauty_AIbeauty_click, sum(pv_tab2_edit_beauty_AIbeauty_save) pv_tab2_edit_beauty_AIbeauty_save, sum(pv_tab2_edit_beauty_Threedimensionalface_click) pv_tab2_edit_beauty_Threedimensionalface_click, sum(pv_tab2_edit_beauty_Threedimensionalface_save) pv_tab2_edit_beauty_Threedimensionalface_save, sum(pv_tab2_edit_beauty_detail_click) pv_tab2_edit_beauty_detail_click, sum(pv_tab2_edit_beauty_detail_save) pv_tab2_edit_beauty_detail_save, sum(pv_tab2_edit_beauty_doublechin_click) pv_tab2_edit_beauty_doublechin_click, sum(pv_tab2_edit_beauty_doublechin_save) pv_tab2_edit_beauty_doublechin_save, sum(pv_tab2_edit_beauty_evenskin_click) pv_tab2_edit_beauty_evenskin_click, sum(pv_tab2_edit_beauty_evenskin_save) pv_tab2_edit_beauty_evenskin_save, sum(pv_tab2_edit_beauty_expression_click) pv_tab2_edit_beauty_expression_click, sum(pv_tab2_edit_beauty_expression_save) pv_tab2_edit_beauty_expression_save, sum(pv_tab2_edit_beauty_eyecatching_click) pv_tab2_edit_beauty_eyecatching_click, sum(pv_tab2_edit_beauty_eyecatching_save) pv_tab2_edit_beauty_eyecatching_save, sum(pv_tab2_edit_beauty_eyedilated_click) pv_tab2_edit_beauty_eyedilated_click, sum(pv_tab2_edit_beauty_eyedilated_save) pv_tab2_edit_beauty_eyedilated_save, sum(pv_tab2_edit_beauty_facecolor_click) pv_tab2_edit_beauty_facecolor_click, sum(pv_tab2_edit_beauty_facecolor_save) pv_tab2_edit_beauty_facecolor_save, sum(pv_tab2_edit_beauty_faceslimming_click) pv_tab2_edit_beauty_faceslimming_click, sum(pv_tab2_edit_beauty_faceslimming_save) pv_tab2_edit_beauty_faceslimming_save, sum(pv_tab2_edit_beauty_faciallighting_click) pv_tab2_edit_beauty_faciallighting_click, sum(pv_tab2_edit_beauty_faciallighting_save) pv_tab2_edit_beauty_faciallighting_save, sum(pv_tab2_edit_beauty_facialreshaping_click) pv_tab2_edit_beauty_facialreshaping_click, sum(pv_tab2_edit_beauty_facialreshaping_save) pv_tab2_edit_beauty_facialreshaping_save, sum(pv_tab2_edit_beauty_hairdressing_click) pv_tab2_edit_beauty_hairdressing_click, sum(pv_tab2_edit_beauty_hairdressing_save) pv_tab2_edit_beauty_hairdressing_save, sum(pv_tab2_edit_beauty_lightendarkcircle_click) pv_tab2_edit_beauty_lightendarkcircle_click, sum(pv_tab2_edit_beauty_lightendarkcircle_save) pv_tab2_edit_beauty_lightendarkcircle_save, sum(pv_tab2_edit_beauty_microdermabrasion_click) pv_tab2_edit_beauty_microdermabrasion_click, sum(pv_tab2_edit_beauty_microdermabrasion_save) pv_tab2_edit_beauty_microdermabrasion_save, sum(pv_tab2_edit_beauty_narrownose_click) pv_tab2_edit_beauty_narrownose_click, sum(pv_tab2_edit_beauty_narrownose_save) pv_tab2_edit_beauty_narrownose_save, sum(pv_tab2_edit_beauty_oneclickbeauty_click) pv_tab2_edit_beauty_oneclickbeauty_click, sum(pv_tab2_edit_beauty_oneclickbeauty_save) pv_tab2_edit_beauty_oneclickbeauty_save, sum(pv_tab2_edit_beauty_orthodontics_click) pv_tab2_edit_beauty_orthodontics_click, sum(pv_tab2_edit_beauty_orthodontics_save) pv_tab2_edit_beauty_orthodontics_save, sum(pv_tab2_edit_beauty_removieacne_click) pv_tab2_edit_beauty_removieacne_click, sum(pv_tab2_edit_beauty_removieacne_save) pv_tab2_edit_beauty_removieacne_save, sum(pv_tab2_edit_beauty_removieshine_click) pv_tab2_edit_beauty_removieshine_click, sum(pv_tab2_edit_beauty_removieshine_save) pv_tab2_edit_beauty_removieshine_save, sum(pv_tab2_edit_beauty_removiewrinkles_click) pv_tab2_edit_beauty_removiewrinkles_click, sum(pv_tab2_edit_beauty_removiewrinkles_save) pv_tab2_edit_beauty_removiewrinkles_save, sum(pv_tab2_edit_beauty_shape_click) pv_tab2_edit_beauty_shape_click, sum(pv_tab2_edit_beauty_shape_save) pv_tab2_edit_beauty_shape_save, sum(pv_tab2_edit_beauty_shrinkhead_click) pv_tab2_edit_beauty_shrinkhead_click, sum(pv_tab2_edit_beauty_shrinkhead_save) pv_tab2_edit_beauty_shrinkhead_save, sum(pv_tab2_edit_beauty_teethwhitening_click) pv_tab2_edit_beauty_teethwhitening_click, sum(pv_tab2_edit_beauty_teethwhitening_save) pv_tab2_edit_beauty_teethwhitening_save, sum(pv_tab2_edit_creative_background_click) pv_tab2_edit_creative_background_click, sum(pv_tab2_edit_creative_background_save) pv_tab2_edit_creative_background_save, sum(pv_tab2_edit_creative_formula_click) pv_tab2_edit_creative_formula_click, sum(pv_tab2_edit_creative_formula_save) pv_tab2_edit_creative_formula_save, sum(pv_tab2_edit_creative_graffiti_click) pv_tab2_edit_creative_graffiti_click, sum(pv_tab2_edit_creative_graffiti_save) pv_tab2_edit_creative_graffiti_save, sum(pv_tab2_edit_creative_sticker_click) pv_tab2_edit_creative_sticker_click, sum(pv_tab2_edit_creative_sticker_save) pv_tab2_edit_creative_sticker_save, sum(pv_tab2_edit_creative_text_click) pv_tab2_edit_creative_text_click, sum(pv_tab2_edit_creative_text_save) pv_tab2_edit_creative_text_save, sum(pv_tab2_edit_edit_AIenhance_click) pv_tab2_edit_edit_AIenhance_click, sum(pv_tab2_edit_edit_AIenhance_save) pv_tab2_edit_edit_AIenhance_save, sum(pv_tab2_edit_edit_AIextension_click) pv_tab2_edit_edit_AIextension_click, sum(pv_tab2_edit_edit_AIextension_save) pv_tab2_edit_edit_AIextension_save, sum(pv_tab2_edit_edit_adjustment_click) pv_tab2_edit_edit_adjustment_click, sum(pv_tab2_edit_edit_ar_click) pv_tab2_edit_edit_ar_click, sum(pv_tab2_edit_edit_ar_save) pv_tab2_edit_edit_ar_save, sum(pv_tab2_edit_edit_blur_click) pv_tab2_edit_edit_blur_click, sum(pv_tab2_edit_edit_blur_save) pv_tab2_edit_edit_blur_save, sum(pv_tab2_edit_edit_clone_click) pv_tab2_edit_edit_clone_click, sum(pv_tab2_edit_edit_clone_save) pv_tab2_edit_edit_clone_save, sum(pv_tab2_edit_edit_composition_click) pv_tab2_edit_edit_composition_click, sum(pv_tab2_edit_edit_composition_save) pv_tab2_edit_edit_composition_save, sum(pv_tab2_edit_edit_cutout_click) pv_tab2_edit_edit_cutout_click, sum(pv_tab2_edit_edit_cutout_save) pv_tab2_edit_edit_cutout_save, sum(pv_tab2_edit_edit_dispersion_click) pv_tab2_edit_edit_dispersion_click, sum(pv_tab2_edit_edit_dispersion_save) pv_tab2_edit_edit_dispersion_save, sum(pv_tab2_edit_edit_elimination_click) pv_tab2_edit_edit_elimination_click, sum(pv_tab2_edit_edit_elimination_save) pv_tab2_edit_edit_elimination_save, sum(pv_tab2_edit_edit_mosaic_click) pv_tab2_edit_edit_mosaic_click, sum(pv_tab2_edit_edit_mosaic_save) pv_tab2_edit_edit_mosaic_save, sum(pv_tab2_edit_edit_photorepair_click) pv_tab2_edit_edit_photorepair_click, sum(pv_tab2_edit_edit_photorepair_save) pv_tab2_edit_edit_photorepair_save, sum(pv_tab2_edit_edit_stylization_click) pv_tab2_edit_edit_stylization_click, sum(pv_tab2_edit_edit_stylization_save) pv_tab2_edit_edit_stylization_save, sum(pv_tab2_shoot_beauty_bigeyes_save) pv_tab2_shoot_beauty_bigeyes_save, sum(pv_tab2_shoot_beauty_eyecatching_save) pv_tab2_shoot_beauty_eyecatching_save, sum(pv_tab2_shoot_beauty_facecolor_save) pv_tab2_shoot_beauty_facecolor_save, sum(pv_tab2_shoot_beauty_faceslimming_save) pv_tab2_shoot_beauty_faceslimming_save, sum(pv_tab2_shoot_beauty_microdermabrasion_save) pv_tab2_shoot_beauty_microdermabrasion_save, sum(pv_tab2_shoot_beauty_oneclickbody_save) pv_tab2_shoot_beauty_oneclickbody_save, sum(pv_tab2_shoot_beauty_removieacnefreckles_save) pv_tab2_shoot_beauty_removieacnefreckles_save, sum(pv_tab2_shoot_beauty_removiedarkcircles_save) pv_tab2_shoot_beauty_removiedarkcircles_save, sum(pv_tab2_shoot_beauty_removienasolabial_save) pv_tab2_shoot_beauty_removienasolabial_save, sum(pv_tab2_shoot_beauty_shrinkhead_save) pv_tab2_shoot_beauty_shrinkhead_save, sum(pv_tab2_shoot_beauty_softhair_save) pv_tab2_shoot_beauty_softhair_save, sum(pv_tab2_shoot_beauty_teethwhitening_save) pv_tab2_shoot_beauty_teethwhitening_save, sum(pv_tab2_shoot_beauty_thinnose_save) pv_tab2_shoot_beauty_thinnose_save, sum(pv_tab2_shoot_makeup_blush_save) pv_tab2_shoot_makeup_blush_save, sum(pv_tab2_shoot_makeup_blush_shoot) pv_tab2_shoot_makeup_blush_shoot, sum(pv_tab2_shoot_makeup_contactlenses_save) pv_tab2_shoot_makeup_contactlenses_save, sum(pv_tab2_shoot_makeup_contactlenses_shoot) pv_tab2_shoot_makeup_contactlenses_shoot, sum(pv_tab2_shoot_makeup_dyehair_save) pv_tab2_shoot_makeup_dyehair_save, sum(pv_tab2_shoot_makeup_dyehair_shoot) pv_tab2_shoot_makeup_dyehair_shoot, sum(pv_tab2_shoot_makeup_eyebrow_save) pv_tab2_shoot_makeup_eyebrow_save, sum(pv_tab2_shoot_makeup_eyebrow_shoot) pv_tab2_shoot_makeup_eyebrow_shoot, sum(pv_tab2_shoot_makeup_eyelash_save) pv_tab2_shoot_makeup_eyelash_save, sum(pv_tab2_shoot_makeup_eyelash_shoot) pv_tab2_shoot_makeup_eyelash_shoot, sum(pv_tab2_shoot_makeup_eyeshadow_save) pv_tab2_shoot_makeup_eyeshadow_save, sum(pv_tab2_shoot_makeup_eyeshadow_shoot) pv_tab2_shoot_makeup_eyeshadow_shoot, sum(pv_tab2_shoot_makeup_freckle_save) pv_tab2_shoot_makeup_freckle_save, sum(pv_tab2_shoot_makeup_freckle_shoot) pv_tab2_shoot_makeup_freckle_shoot, sum(pv_tab2_shoot_makeup_lipstick_save) pv_tab2_shoot_makeup_lipstick_save, sum(pv_tab2_shoot_makeup_lipstick_shoot) pv_tab2_shoot_makeup_lipstick_shoot, sum(pv_tab2_shoot_makeup_lyingsilkworm_save) pv_tab2_shoot_makeup_lyingsilkworm_save, sum(pv_tab2_shoot_makeup_lyingsilkworm_shoot) pv_tab2_shoot_makeup_lyingsilkworm_shoot, sum(pv_tab2_shoot_makeup_trimming_save) pv_tab2_shoot_makeup_trimming_save, sum(pv_tab2_shoot_makeup_trimming_shoot) pv_tab2_shoot_makeup_trimming_shoot, sum(pv_tab0_edit_entry_30) pv_tab0_edit_entry_30, sum(pv_tab0_edit_save_30) pv_tab0_edit_save_30, sum(pv_tab0_movie_save_30) pv_tab0_movie_save_30, sum(pv_tab0_movie_shoot_30) pv_tab0_movie_shoot_30, sum(pv_tab0_selfie_entry_30) pv_tab0_selfie_entry_30, sum(pv_tab0_shoot_save_30) pv_tab0_shoot_save_30, sum(pv_tab0_shoot_shoot_30) pv_tab0_shoot_shoot_30, sum(pv_tab0_video_save_30) pv_tab0_video_save_30, sum(pv_tab0_video_shoot_30) pv_tab0_video_shoot_30, sum(pv_tab0_videoedit_entry_30) pv_tab0_videoedit_entry_30, sum(pv_tab0_videoedit_save_30) pv_tab0_videoedit_save_30, sum(pv_tab1_edit_beauty_click_30) pv_tab1_edit_beauty_click_30, sum(pv_tab1_edit_beauty_save_30) pv_tab1_edit_beauty_save_30, sum(pv_tab1_edit_creative_click_30) pv_tab1_edit_creative_click_30, sum(pv_tab1_edit_creative_save_30) pv_tab1_edit_creative_save_30, sum(pv_tab1_edit_edit_click_30) pv_tab1_edit_edit_click_30, sum(pv_tab1_edit_edit_save_30) pv_tab1_edit_edit_save_30, sum(pv_tab1_edit_filter_click_30) pv_tab1_edit_filter_click_30, sum(pv_tab1_edit_filter_save_30) pv_tab1_edit_filter_save_30, sum(pv_tab1_edit_makeup_click_30) pv_tab1_edit_makeup_click_30, sum(pv_tab1_edit_makeup_save_30) pv_tab1_edit_makeup_save_30, sum(pv_tab1_edit_senioredit_click_30) pv_tab1_edit_senioredit_click_30, sum(pv_tab1_shoot_ar_save_30) pv_tab1_shoot_ar_save_30, sum(pv_tab1_shoot_ar_shoot_30) pv_tab1_shoot_ar_shoot_30, sum(pv_tab1_shoot_beauty_save_30) pv_tab1_shoot_beauty_save_30, sum(pv_tab1_shoot_filter_save_30) pv_tab1_shoot_filter_save_30, sum(pv_tab1_shoot_filter_shoot_30) pv_tab1_shoot_filter_shoot_30, sum(pv_tab1_shoot_look_save_30) pv_tab1_shoot_look_save_30, sum(pv_tab1_shoot_look_shoot_30) pv_tab1_shoot_look_shoot_30, sum(pv_tab1_shoot_makeup_save_30) pv_tab1_shoot_makeup_save_30, sum(pv_tab1_shoot_makeup_shoot_30) pv_tab1_shoot_makeup_shoot_30, sum(pv_tab0_edit_entry_60) pv_tab0_edit_entry_60, sum(pv_tab0_edit_save_60) pv_tab0_edit_save_60, sum(pv_tab0_movie_save_60) pv_tab0_movie_save_60, sum(pv_tab0_movie_shoot_60) pv_tab0_movie_shoot_60, sum(pv_tab0_selfie_entry_60) pv_tab0_selfie_entry_60, sum(pv_tab0_shoot_save_60) pv_tab0_shoot_save_60, sum(pv_tab0_shoot_shoot_60) pv_tab0_shoot_shoot_60, sum(pv_tab0_video_save_60) pv_tab0_video_save_60, sum(pv_tab0_video_shoot_60) pv_tab0_video_shoot_60, sum(pv_tab0_videoedit_entry_60) pv_tab0_videoedit_entry_60, sum(pv_tab0_videoedit_save_60) pv_tab0_videoedit_save_60, sum(pv_tab1_edit_beauty_click_60) pv_tab1_edit_beauty_click_60, sum(pv_tab1_edit_beauty_save_60) pv_tab1_edit_beauty_save_60, sum(pv_tab1_edit_creative_click_60) pv_tab1_edit_creative_click_60, sum(pv_tab1_edit_creative_save_60) pv_tab1_edit_creative_save_60, sum(pv_tab1_edit_edit_click_60) pv_tab1_edit_edit_click_60, sum(pv_tab1_edit_edit_save_60) pv_tab1_edit_edit_save_60, sum(pv_tab1_edit_filter_click_60) pv_tab1_edit_filter_click_60, sum(pv_tab1_edit_filter_save_60) pv_tab1_edit_filter_save_60, sum(pv_tab1_edit_makeup_click_60) pv_tab1_edit_makeup_click_60, sum(pv_tab1_edit_makeup_save_60) pv_tab1_edit_makeup_save_60, sum(pv_tab1_edit_senioredit_click_60) pv_tab1_edit_senioredit_click_60, sum(pv_tab1_shoot_ar_save_60) pv_tab1_shoot_ar_save_60, sum(pv_tab1_shoot_ar_shoot_60) pv_tab1_shoot_ar_shoot_60, sum(pv_tab1_shoot_beauty_save_60) pv_tab1_shoot_beauty_save_60, sum(pv_tab1_shoot_filter_save_60) pv_tab1_shoot_filter_save_60, sum(pv_tab1_shoot_filter_shoot_60) pv_tab1_shoot_filter_shoot_60, sum(pv_tab1_shoot_look_save_60) pv_tab1_shoot_look_save_60, sum(pv_tab1_shoot_look_shoot_60) pv_tab1_shoot_look_shoot_60, sum(pv_tab1_shoot_makeup_save_60) pv_tab1_shoot_makeup_save_60, sum(pv_tab1_shoot_makeup_shoot_60) pv_tab1_shoot_makeup_shoot_60, sum(pv_tab0_edit_entry_90) pv_tab0_edit_entry_90, sum(pv_tab0_edit_save_90) pv_tab0_edit_save_90, sum(pv_tab0_movie_save_90) pv_tab0_movie_save_90, sum(pv_tab0_movie_shoot_90) pv_tab0_movie_shoot_90, sum(pv_tab0_selfie_entry_90) pv_tab0_selfie_entry_90, sum(pv_tab0_shoot_save_90) pv_tab0_shoot_save_90, sum(pv_tab0_shoot_shoot_90) pv_tab0_shoot_shoot_90, sum(pv_tab0_video_save_90) pv_tab0_video_save_90, sum(pv_tab0_video_shoot_90) pv_tab0_video_shoot_90, sum(pv_tab0_videoedit_entry_90) pv_tab0_videoedit_entry_90, sum(pv_tab0_videoedit_save_90) pv_tab0_videoedit_save_90, sum(pv_tab1_edit_beauty_click_90) pv_tab1_edit_beauty_click_90, sum(pv_tab1_edit_beauty_save_90) pv_tab1_edit_beauty_save_90, sum(pv_tab1_edit_creative_click_90) pv_tab1_edit_creative_click_90, sum(pv_tab1_edit_creative_save_90) pv_tab1_edit_creative_save_90, sum(pv_tab1_edit_edit_click_90) pv_tab1_edit_edit_click_90, sum(pv_tab1_edit_edit_save_90) pv_tab1_edit_edit_save_90, sum(pv_tab1_edit_filter_click_90) pv_tab1_edit_filter_click_90, sum(pv_tab1_edit_filter_save_90) pv_tab1_edit_filter_save_90, sum(pv_tab1_edit_makeup_click_90) pv_tab1_edit_makeup_click_90, sum(pv_tab1_edit_makeup_save_90) pv_tab1_edit_makeup_save_90, sum(pv_tab1_edit_senioredit_click_90) pv_tab1_edit_senioredit_click_90, sum(pv_tab1_shoot_ar_save_90) pv_tab1_shoot_ar_save_90, sum(pv_tab1_shoot_ar_shoot_90) pv_tab1_shoot_ar_shoot_90, sum(pv_tab1_shoot_beauty_save_90) pv_tab1_shoot_beauty_save_90, sum(pv_tab1_shoot_filter_save_90) pv_tab1_shoot_filter_save_90, sum(pv_tab1_shoot_filter_shoot_90) pv_tab1_shoot_filter_shoot_90, sum(pv_tab1_shoot_look_save_90) pv_tab1_shoot_look_save_90, sum(pv_tab1_shoot_look_shoot_90) pv_tab1_shoot_look_shoot_90, sum(pv_tab1_shoot_makeup_save_90) pv_tab1_shoot_makeup_save_90, sum(pv_tab1_shoot_makeup_shoot_90) pv_tab1_shoot_makeup_shoot_90
        , sum(aigc_enter_pv) aigc_enter_pv, sum(aigc_use_pv) aigc_use_pv, sum(aigc_save_pv) aigc_save_pv, sum(pop_exposure) pop_exposure, sum(pop_click) pop_click, sum(content_exposure) content_exposure, sum(content_click) content_click, sum(max_module_positon) max_module_positon, sum(sub_page_enter) sub_page_enter, sum(sub_page_click) sub_page_click, sum(force_sub_page_enter) force_sub_page_enter, sum(force_sub_page_click) force_sub_page_click, sum(subscript_sub_page_enter) subscript_sub_page_enter, sum(subscript_sub_page_click) subscript_sub_page_click, sum(other_sub_page_enter) other_sub_page_enter, sum(other_sub_page_click) other_sub_page_click, sum(max_impression_pv) max_impression_pv, sum(impression_pv) impression_pv, sum(click_pv) click_pv, sum(aigc_enter_pv_30) aigc_enter_pv_30, sum(aigc_use_pv_30) aigc_use_pv_30, sum(aigc_save_pv_30) aigc_save_pv_30, sum(pop_exposure_30) pop_exposure_30, sum(pop_click_30) pop_click_30, sum(content_exposure_30) content_exposure_30, sum(content_click_30) content_click_30, sum(max_module_positon_30) max_module_positon_30, sum(sub_page_enter_30) sub_page_enter_30, sum(sub_page_click_30) sub_page_click_30, sum(force_sub_page_enter_30) force_sub_page_enter_30, sum(force_sub_page_click_30) force_sub_page_click_30, sum(subscript_sub_page_enter_30) subscript_sub_page_enter_30, sum(subscript_sub_page_click_30) subscript_sub_page_click_30, sum(other_sub_page_enter_30) other_sub_page_enter_30, sum(other_sub_page_click_30) other_sub_page_click_30, sum(max_impression_pv_30) max_impression_pv_30, sum(impression_pv_30) impression_pv_30, sum(click_pv_30) click_pv_30, sum(aigc_enter_pv_60) aigc_enter_pv_60, sum(aigc_use_pv_60) aigc_use_pv_60, sum(aigc_save_pv_60) aigc_save_pv_60, sum(pop_exposure_60) pop_exposure_60, sum(pop_click_60) pop_click_60, sum(content_exposure_60) content_exposure_60, sum(content_click_60) content_click_60, sum(max_module_positon_60) max_module_positon_60, sum(sub_page_enter_60) sub_page_enter_60, sum(sub_page_click_60) sub_page_click_60, sum(force_sub_page_enter_60) force_sub_page_enter_60, sum(force_sub_page_click_60) force_sub_page_click_60, sum(subscript_sub_page_enter_60) subscript_sub_page_enter_60, sum(subscript_sub_page_click_60) subscript_sub_page_click_60, sum(other_sub_page_enter_60) other_sub_page_enter_60, sum(other_sub_page_click_60) other_sub_page_click_60, sum(max_impression_pv_60) max_impression_pv_60, sum(impression_pv_60) impression_pv_60, sum(click_pv_60) click_pv_60, sum(aigc_enter_pv_90) aigc_enter_pv_90, sum(aigc_use_pv_90) aigc_use_pv_90, sum(aigc_save_pv_90) aigc_save_pv_90, sum(pop_exposure_90) pop_exposure_90, sum(pop_click_90) pop_click_90, sum(content_exposure_90) content_exposure_90, sum(content_click_90) content_click_90, sum(max_module_positon_90) max_module_positon_90, sum(sub_page_enter_90) sub_page_enter_90, sum(sub_page_click_90) sub_page_click_90, sum(force_sub_page_enter_90) force_sub_page_enter_90, sum(force_sub_page_click_90) force_sub_page_click_90, sum(subscript_sub_page_enter_90) subscript_sub_page_enter_90, sum(subscript_sub_page_click_90) subscript_sub_page_click_90, sum(other_sub_page_enter_90) other_sub_page_enter_90, sum(other_sub_page_click_90) other_sub_page_click_90, sum(max_impression_pv_90) max_impression_pv_90, sum(impression_pv_90) impression_pv_90, sum(click_pv_90) click_pv_90, sum(grow_aigc_enter_pv) grow_aigc_enter_pv, sum(grow_aigc_use_pv) grow_aigc_use_pv, sum(grow_aigc_save_pv) grow_aigc_save_pv, sum(grow_pop_exposure) grow_pop_exposure, sum(grow_pop_click) grow_pop_click, sum(grow_content_exposure) grow_content_exposure, sum(grow_content_click) grow_content_click, sum(grow_max_module_positon) grow_max_module_positon, sum(grow_sub_page_enter) grow_sub_page_enter, sum(grow_sub_page_click) grow_sub_page_click, sum(force_grow_sub_page_enter) force_grow_sub_page_enter, sum(force_grow_sub_page_click) force_grow_sub_page_click, sum(subscript_grow_sub_page_enter) subscript_grow_sub_page_enter, sum(subscript_grow_sub_page_click) subscript_grow_sub_page_click, sum(other_grow_sub_page_enter) other_grow_sub_page_enter, sum(other_grow_sub_page_click) other_grow_sub_page_click, sum(grow_max_impression_pv) grow_max_impression_pv, sum(grow_impression_pv) grow_impression_pv, sum(grow_click_pv) grow_click_pv, sum(puzzle_click_pv) puzzle_click_pv, sum(puzzle_save_pv) puzzle_save_pv, sum(puzzle_click_pv_30) puzzle_click_pv_30, sum(puzzle_save_pv_30) puzzle_save_pv_30, sum(puzzle_click_pv_60) puzzle_click_pv_60, sum(puzzle_save_pv_60) puzzle_save_pv_60, sum(puzzle_click_pv_90) puzzle_click_pv_90, sum(puzzle_save_pv_90) puzzle_save_pv_90, sum(pay_function_click_pv) pay_function_click_pv, sum(free_function_click_pv) free_function_click_pv, sum(free_function_save_pv) free_function_save_pv, sum(pay_function_click_pv_30) pay_function_click_pv_30, sum(free_function_click_pv_30) free_function_click_pv_30, sum(free_function_save_pv_30) free_function_save_pv_30, sum(pay_function_click_pv_60) pay_function_click_pv_60, sum(free_function_click_pv_60) free_function_click_pv_60, sum(free_function_save_pv_60) free_function_save_pv_60, sum(pay_function_click_pv_90) pay_function_click_pv_90, sum(free_function_click_pv_90) free_function_click_pv_90, sum(free_function_save_pv_90) free_function_save_pv_90, sum(grow_pay_function_click_pv) grow_pay_function_click_pv, sum(grow_free_function_click_pv) grow_free_function_click_pv, sum(grow_free_function_save_pv) grow_free_function_save_pv, sum(pay_duffle_click_pv) pay_duffle_click_pv, sum(free_duffle_click_pv) free_duffle_click_pv, sum(free_duffle_save_pv) free_duffle_save_pv, sum(pay_duffle_click_pv_30) pay_duffle_click_pv_30, sum(free_duffle_click_pv_30) free_duffle_click_pv_30, sum(free_duffle_save_pv_30) free_duffle_save_pv_30, sum(pay_duffle_click_pv_60) pay_duffle_click_pv_60, sum(free_duffle_click_pv_60) free_duffle_click_pv_60, sum(free_duffle_save_pv_60) free_duffle_save_pv_60, sum(pay_duffle_click_pv_90) pay_duffle_click_pv_90, sum(free_duffle_click_pv_90) free_duffle_click_pv_90, sum(free_duffle_save_pv_90) free_duffle_save_pv_90, sum(grow_pay_duffle_click_pv) grow_pay_duffle_click_pv, sum(grow_free_duffle_click_pv) grow_free_duffle_click_pv, sum(grow_free_duffle_save_pv) grow_free_duffle_save_pv, sum(function_num) function_num, sum(function_num_pre) function_num_pre, sum(function_num_30) function_num_30, sum(function_num_60) function_num_60, sum(function_num_90) function_num_90, sum(grow_function_num) grow_function_num, sum(grow_edit_enter_pv) grow_edit_enter_pv, sum(grow_edit_save_pv) grow_edit_save_pv, sum(grow_take_photo_pv) grow_take_photo_pv, sum(grow_take_photo_save_pv) grow_take_photo_save_pv, sum(grow_selftake_enter_pv) grow_selftake_enter_pv, sum(grow_take_video_pv) grow_take_video_pv, sum(grow_take_video_save_pv) grow_take_video_save_pv, sum(homepage_exposure_pv) homepage_exposure_pv, sum(homepage_click_pv) homepage_click_pv, sum(homepage_feature_show_pv) homepage_feature_show_pv, sum(homepage_feature_click_pv) homepage_feature_click_pv, sum(homepage_banner_show_pv) homepage_banner_show_pv, sum(homepage_banner_click_pv) homepage_banner_click_pv, sum(homepage_reconmend_show_pv) homepage_reconmend_show_pv, sum(homepage_reconmend_click_pv) homepage_reconmend_click_pv, sum(homepage_topic_show_pv) homepage_topic_show_pv, sum(homepage_topic_click_pv) homepage_topic_click_pv, sum(homepage_miniapp_show_pv) homepage_miniapp_show_pv, sum(homepage_miniapp_click_pv) homepage_miniapp_click_pv, sum(homepage_exposure_pv_30) homepage_exposure_pv_30, sum(homepage_click_pv_30) homepage_click_pv_30, sum(homepage_feature_show_pv_30) homepage_feature_show_pv_30, sum(homepage_feature_click_pv_30) homepage_feature_click_pv_30, sum(homepage_banner_show_pv_30) homepage_banner_show_pv_30, sum(homepage_banner_click_pv_30) homepage_banner_click_pv_30, sum(homepage_reconmend_show_pv_30) homepage_reconmend_show_pv_30, sum(homepage_reconmend_click_pv_30) homepage_reconmend_click_pv_30, sum(homepage_topic_show_pv_30) homepage_topic_show_pv_30, sum(homepage_topic_click_pv_30) homepage_topic_click_pv_30, sum(homepage_miniapp_show_pv_30) homepage_miniapp_show_pv_30, sum(homepage_miniapp_click_pv_30) homepage_miniapp_click_pv_30, sum(homepage_exposure_pv_60) homepage_exposure_pv_60, sum(homepage_click_pv_60) homepage_click_pv_60, sum(homepage_feature_show_pv_60) homepage_feature_show_pv_60, sum(homepage_feature_click_pv_60) homepage_feature_click_pv_60, sum(homepage_banner_show_pv_60) homepage_banner_show_pv_60, sum(homepage_banner_click_pv_60) homepage_banner_click_pv_60, sum(homepage_reconmend_show_pv_60) homepage_reconmend_show_pv_60, sum(homepage_reconmend_click_pv_60) homepage_reconmend_click_pv_60, sum(homepage_topic_show_pv_60) homepage_topic_show_pv_60, sum(homepage_topic_click_pv_60) homepage_topic_click_pv_60, sum(homepage_miniapp_show_pv_60) homepage_miniapp_show_pv_60, sum(homepage_miniapp_click_pv_60) homepage_miniapp_click_pv_60, sum(homepage_exposure_pv_90) homepage_exposure_pv_90, sum(homepage_click_pv_90) homepage_click_pv_90, sum(homepage_feature_show_pv_90) homepage_feature_show_pv_90, sum(homepage_feature_click_pv_90) homepage_feature_click_pv_90, sum(homepage_banner_show_pv_90) homepage_banner_show_pv_90, sum(homepage_banner_click_pv_90) homepage_banner_click_pv_90, sum(homepage_reconmend_show_pv_90) homepage_reconmend_show_pv_90, sum(homepage_reconmend_click_pv_90) homepage_reconmend_click_pv_90, sum(homepage_topic_show_pv_90) homepage_topic_show_pv_90, sum(homepage_topic_click_pv_90) homepage_topic_click_pv_90, sum(homepage_miniapp_show_pv_90) homepage_miniapp_show_pv_90, sum(homepage_miniapp_click_pv_90) homepage_miniapp_click_pv_90
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
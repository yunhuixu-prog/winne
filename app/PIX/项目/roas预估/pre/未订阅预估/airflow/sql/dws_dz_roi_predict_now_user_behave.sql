-- beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave
-- -- 初始化
-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave as

-- 非初始化
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave where date = mDATE;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave


-- 选择观测投放日期至投放日期一年内
with goal_users as
(
    select types,Attributed_Touch_Date,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    where Attributed_Touch_Date between DATE_SUB(mDATE, INTERVAL 364 DAY) and mDATE
    group by 1,2,3
)
,
behave_pre as
(
    select event_date,a.mark, a.module, a.class, a.function
        , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
                when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
                when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
                when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
                when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
                when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
                when a.mark=0 and a.module ='自拍' and a.event_name_cn='自拍页展现' then '进入'
                when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
                when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
                else a.action
          end action
        , a.user_pseudo_id
        , a.pv
        , b.mark mark_c, b.module module_c, b.class class_c, b.function function_c, b.is_pay, b.is_function
    from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
    left join beautyplus-bc0ed.temp.dmi_da_class_is_pay b
    on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
    where event_date between date_sub(mDATE,interval 30 day) and mDATE
        and a.mark in (0, 1, 2)
)
,
-- 近31天付费非付费功能使用情况及成长情况
pay_function as
(
    select user_pseudo_id,pay_function_click_pv_31,free_function_click_pv_31,free_function_save_pv_31
    from
    (
        select user_pseudo_id
                , sum (case when is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv_31
                , sum (case when is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv_31
                , sum (case when is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv_31
        from behave_pre
        where is_function = '功能'
          and mark=2
          and action in ('点击', '保存', '拍摄')
          and event_date between date_sub(mDATE, interval 30 day) and mDATE
        group by 1
    )
)
,
-- 近31天2级功能使用情况（统计指标）
function_use as
(
    select user_pseudo_id,count(distinct function) function_num_31
    from behave_pre
    where mark=2 and action in ('点击','拍摄')
        and event_date between date_sub(mDATE, interval 30 day) and mDATE
    group by 1
)
,
other_behave as
(
    select user_pseudo_id
        ,sum(aigc_enter_pv) aigc_enter_pv_31
        ,sum(aigc_use_pv) aigc_use_pv_31
        ,sum(aigc_save_pv) aigc_save_pv_31
        ,sum(pop_exposure) pop_exposure_31
        ,sum(pop_click) pop_click_31
        ,sum(content_exposure) content_exposure_31
        ,sum(content_click) content_click_31
        ,sum(max_module_positon) max_module_positon_31
        ,sum(sub_page_enter) sub_page_enter_31
        ,sum(sub_page_click) sub_page_click_31
        ,sum(max_impression_pv) max_impression_pv_31
        ,sum(impression_pv) impression_pv_31
        ,sum(click_pv) click_pv_31
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre
    where date between date_sub(mDATE,interval 30 day) and mDATE
    group by 1
)
,
-- 近31天付费素材指标
-- beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
pay_duffle as
(
    select user_pseudo_id,pay_duffle_click_pv_31,free_duffle_click_pv_31,free_duffle_save_pv_31
    from
    (
        select user_pseudo_id
                , sum (case when paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_31
                , sum (case when paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_31
                , sum (case when paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_31
        from beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
        where date_p between date_sub(mDATE,interval 30 day) and mDATE
        group by 1
    )
)
,
user_profile as
(
    select u.*,g.types,g.Attributed_Touch_Date
    from goal_users g
    join
    (
        select user_pseudo_id
            ,brand,model
            ,DATE_DIFF(event_date_hk,last_active_date,DAY) last_active_days
            ,last_app_version,active_category
            ,life_time_active_days
            ,active_mins_7d,active_sessions_7d,active_days_7d
            ,active_mins_90d,active_sessions_90d,active_days_90d
        from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk=mDATE
    ) u
    on g.user_pseudo_id=u.user_pseudo_id
)
,
active as
(
    select user_pseudo_id
        ,count(distinct case when event_date_hk between date_sub(mDATE, interval 6 day) and mDATE
                then event_date_hk end) active_days_7d
        ,count(distinct event_date_hk) active_days_90d
        ,count(distinct case when event_date_hk between date_sub(mDATE, interval 13 day) and mDATE
                then event_date_hk end) active_days_14d
        ,count(distinct case when event_date_hk between date_sub(mDATE, interval 30 day) and mDATE
                then event_date_hk end) active_days_31d
        ,count(distinct case when event_date_hk between date_sub(mDATE, interval 59 day) and mDATE
                then event_date_hk end) active_days_60d
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between date_sub(mDATE,interval 89 day) and mDATE
        and app_name='BeautyPlus'
    group by 1
)

select cast(mDATE as date) as date,g.types,g.Attributed_Touch_Date,g.user_pseudo_id
    ,u.*except(user_pseudo_id,active_days_7d,active_days_90d,types,Attributed_Touch_Date)
    ,coalesce(u.active_days_7d,a.active_days_7d) active_days_7d
    ,coalesce(u.active_days_90d,a.active_days_90d) active_days_90d
    ,a.*except(user_pseudo_id,active_days_7d,active_days_90d)
    ,pf.*except(user_pseudo_id)
    ,o.*except(user_pseudo_id)
    ,pd.*except(user_pseudo_id)
    ,f.function_num_31
from goal_users g
left join user_profile u
on g.user_pseudo_id=u.user_pseudo_id and g.types=u.types and g.Attributed_Touch_Date=u.Attributed_Touch_Date
left join active a
on g.user_pseudo_id=a.user_pseudo_id
left join pay_function pf
on g.user_pseudo_id=pf.user_pseudo_id
left join other_behave o
on g.user_pseudo_id=o.user_pseudo_id
left join pay_duffle pd
on g.user_pseudo_id=pd.user_pseudo_id
left join function_use f
on g.user_pseudo_id=f.user_pseudo_id
;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;




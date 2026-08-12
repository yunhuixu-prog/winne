-- beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis
drop table if exists beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis;
create table if not exists beautyplus-bc0ed.temp.dws_dz_user_lifetime_project_analysis as

with goal_users as
(
    select types,App_Name,Platform,Attributed_Touch_Date,id,max(user_pseudo_id) user_pseudo_id,max(region) region
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    where types='new' and Attributed_Touch_Date between '2023-01-01' and '2024-04-01'
    group by 1,2,3,4,5
)
,
sub_event as
(
    select a.types,a.Attributed_Touch_Date,a.user_pseudo_id,a.region,a.Platform,b.standard_order_date,b.product,b.order_id,b.payment_price_usd,b.standard_order_expire_date,b.order_status,b.subscription_period
    from goal_users a
    left join dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.uuid=a.id
    where types='new' and (b.Attributed_Touch_Time=a.Attributed_Touch_Date or b.Attributed_Touch_Time is null)  -- 以uuid为口径的新用户
)
,
sub_label as
(
    select b.types,a.date,b.Attributed_Touch_Date
    --          ,a.AppsFlyer_ID
         ,b.user_pseudo_id
--         ,count(distinct case when b.standard_order_date<=a.date and product='subscription' then b.order_id end) sub_now  -- 截止目前用户是否有过订阅（包括试用）
--         ,IFNULL(round(sum(case when b.standard_order_date<=a.date and product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_now  -- 截止目前用户订阅收入
--         ,max(case when b.standard_order_date<=a.date and standard_order_expire_date>=a.date and b.product='subscription' then 1 else 0 end) is_sub_now  -- 当前用户是否订阅状态（包括试用）

        ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 7 DAY) and b.product='subscription' then b.order_id end) sub_7  -- 投放一年内是否有过订阅行为（包括试用）
        ,count(distinct case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 7 DAY) and b.order_status!=0 and b.product='subscription'  then b.order_id end) sub_no_trial_7  -- 投放一年内是否有过订阅行为（不包括试用）
        ,IFNULL(round(sum(case when b.standard_order_date < date_add(b.Attributed_Touch_Date,INTERVAL 7 DAY) and b.product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_7
    from
    (
        select distinct event_date_hk date
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk between '2023-01-01' and date_add('2024-04-01',INTERVAL 7 DAY)
    ) a
    cross join sub_event b
    where a.date between b.Attributed_Touch_Date and DATE_ADD(Attributed_Touch_Date, INTERVAL 7 DAY)
    group by 1,2,3,4
)
,
retain_7 as
(
    select Attributed_Touch_Date,g.user_pseudo_id
            ,coalesce(max(case when a.event_date_hk between date_add(g.Attributed_Touch_Date,INTERVAL 7 DAY)
                    and date_add(g.Attributed_Touch_Date,INTERVAL 13 DAY) then 1 else 0 end),0) is_retain_7_14
            ,coalesce(max(case when a.event_date_hk = date_add(g.Attributed_Touch_Date,INTERVAL 7 DAY) then 1 else 0 end),0) is_retain_7
    from goal_users g
    left join
    (
        select distinct event_date_hk,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where app_name='BeautyPlus' and event_date_hk between '2023-01-01' and date_add('2024-04-01',INTERVAL 14 DAY)
    ) a
    on g.user_pseudo_id=a.user_pseudo_id
    group by 1,2
)

select a.types,a.date,a.Attributed_Touch_Date,a.user_pseudo_id
        ,case when region in ('United States','Japan','United Kingdom','South Korea','Thailand') then region else 'else' end region
        ,platform,sub_now,sub_revenue_now,is_sub_now
--         ,sub_365,sub_no_trial_365,sub_revenue_365
        ,active_mins,active_sessions,active_days
        ,`pv_0级tab-修图---保存`,`pv_0级tab-修图---进入`,`pv_0级tab-拍摄---保存`,`pv_0级tab-拍摄---拍摄`,`pv_0级tab-电影---保存`,`pv_0级tab-电影---拍摄`,`pv_0级tab-自拍---进入`,`pv_0级tab-视频---保存`,`pv_0级tab-视频---拍摄`,`pv_0级tab-视频编辑---保存`,`pv_0级tab-视频编辑---进入`,`pv_1级tab-修图-创意--保存`,`pv_1级tab-修图-创意--点击`,`pv_1级tab-修图-滤镜--保存`,`pv_1级tab-修图-滤镜--点击`,`pv_1级tab-修图-编辑--保存`,`pv_1级tab-修图-编辑--点击`,`pv_1级tab-修图-美妆--保存`,`pv_1级tab-修图-美妆--点击`,`pv_1级tab-修图-美颜--保存`,`pv_1级tab-修图-美颜--点击`,`pv_1级tab-修图-高级编辑--点击`,`pv_1级tab-拍摄-AR--保存`,`pv_1级tab-拍摄-AR--拍摄`,`pv_1级tab-拍摄-Look--保存`,`pv_1级tab-拍摄-Look--拍摄`,`pv_1级tab-拍摄-滤镜--保存`,`pv_1级tab-拍摄-滤镜--拍摄`,`pv_1级tab-拍摄-美妆--保存`,`pv_1级tab-拍摄-美妆--拍摄`,`pv_1级tab-拍摄-美颜--保存`
        ,aigc_enter_pv,aigc_use_pv,aigc_save_pv,pop_exposure,pop_click,content_exposure,content_click,max_module_positon,sub_page_enter,sub_page_click,max_impression_pv,impression_pv,click_pv,puzzle_click_pv,puzzle_save_pv,pay_function_click_pv,free_function_click_pv,free_function_save_pv,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv,function_num
        ,brand,last_active_days,active_category,life_time_active_days
        ,active_mins_7d,active_sessions_7d,active_mins_90d,active_sessions_90d,active_days_7d,active_days_90d,active_days_14d,active_days_31d,active_days_60d
        ,pay_function_click_pv_31,free_function_click_pv_31,free_function_save_pv_31,aigc_enter_pv_31,aigc_use_pv_31,aigc_save_pv_31,pop_exposure_31,pop_click_31,content_exposure_31,content_click_31,max_module_positon_31,sub_page_enter_31,sub_page_click_31,max_impression_pv_31,impression_pv_31,click_pv_31,pay_duffle_click_pv_31,free_duffle_click_pv_31,free_duffle_save_pv_31,function_num_31
        ,days,pay_duffle_click_ratio,pay_duffle_click_ratio_31,pay_function_click_ratio,pay_function_click_ratio_31
        ,case when coalesce(pop_exposure,0)=0 then null
               else round(coalesce(pop_click,0)/coalesce(pop_exposure,0),4)
         end pop_click_ratio
         ,case when coalesce(content_exposure,0)=0 then null
               else round(coalesce(content_click,0)/coalesce(content_exposure,0),4)
         end content_click_ratio
         ,case when coalesce(sub_page_enter,0)=0 then null
               else round(coalesce(sub_page_click,0)/coalesce(sub_page_enter,0),4)
         end sub_page_click_ratio
        ,b.sub_7,b.sub_no_trial_7,b.sub_revenue_7
        ,r.is_retain_7_14,r.is_retain_7
from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input a
left join sub_label b
on a.types=b.types and a.date=b.date and a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id
left join retain_7 r
on a.Attributed_Touch_Date=r.Attributed_Touch_Date and a.user_pseudo_id=r.user_pseudo_id
where a.types='new' and a.days between 0 and 6 --and a.sub_now=0



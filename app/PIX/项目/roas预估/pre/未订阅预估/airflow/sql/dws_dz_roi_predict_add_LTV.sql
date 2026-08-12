-- `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV`
-- 汇总所有预测场景用户的LTV
-- 当天的就不预测了吧。。。太不稳定了
-- 建议在最终的预测结果里加个限制。就是超过多少就不要了，比如超过cost的30%就取上限（那当天的也可以有了），或者大于当天uv的多少就限制更合理点？
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
-- DECLARE mDATE_START DATE DEFAULT '2024-04-10';
-- DECLARE mDATE_END DATE DEFAULT '2024-04-18';

-- drop table if exists `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV`;
-- create table if not exists `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV` as

delete from `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV` where date between mDATE_START and mDATE_END;
insert into `dataintegration-265403.temp.dws_dz_roi_predict_add_LTV`


with
bp_user_info as
(
    select types,App_Name,Attributed_Touch_Date,user_pseudo_id
        ,max(Platform) Platform
        ,max(region) country
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    where Attributed_Touch_Date between DATE_SUB(mDATE_START, INTERVAL 364 DAY) and mDATE_END
    group by 1,2,3,4
)
,
bp_no_sub_user_info as
(
    select distinct a.*,b.date
    from bp_user_info a
    join beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub b
    on a.types=b.types and a.Attributed_Touch_Date=b.Attributed_Touch_Date
        and a.user_pseudo_id=b.user_pseudo_id
    where b.date between b.Attributed_Touch_Date and DATE_ADD(b.Attributed_Touch_Date, INTERVAL 364 DAY)
        and b.sub_now=0 and b.date between mDATE_START and mDATE_END
        and date_diff(b.date,b.Attributed_Touch_Date,DAY)>0
)
,
ab_user_info as
(
    select types,App_Name,Attributed_Touch_Date,user_pseudo_id
        ,max(Platform) Platform
        ,max(region) country
    from airbrush-1324.temp.dws_dz_roi_predict_0_goal_users
    where Attributed_Touch_Date between DATE_SUB(mDATE_START, INTERVAL 364 DAY) and mDATE_END
    group by 1,2,3,4
)
,
ab_no_sub_user_info as
(
    select distinct a.*,b.date
    from ab_user_info a
    join airbrush-1324.temp.dws_dz_roi_predict_now_user_sub b
    on a.types=b.types and a.Attributed_Touch_Date=b.Attributed_Touch_Date
        and a.user_pseudo_id=b.user_pseudo_id
    where b.date between b.Attributed_Touch_Date and DATE_ADD(b.Attributed_Touch_Date, INTERVAL 364 DAY)
        and b.sub_now=0 and b.date between mDATE_START and mDATE_END
        and date_diff(b.date,b.Attributed_Touch_Date,DAY)>0
)
,
LTV as
(
    select app_id,country,platform
         ,count(distinct uuid) uv
         ,round(sum(LTV365_actual_forecast)/count(1),4) LTV365_actual_forecast  -- 订单开始之后的365天，不是投放后的365天
         ,round(sum(LTV_actual_forecast)/count(1),4) LTV_actual_forecast
    from `dataintegration-265403.user_ltv.dws_dz_new_ltv_id`
    where date between DATE_SUB(mDATE_END, INTERVAL 90 DAY) and mDATE_END
    group by 1,2,3
)


-- select types,App_Name,Attributed_Touch_Date,date
--     ,sum(predict_sub_revenue_365)
--     ,sum(predict_sub_revenue)
--     ,sum(predict_sub_revenue_v2)
-- from
-- (
select u.types,u.App_Name,u.Attributed_Touch_Date,u.date,u.user_pseudo_id
        ,u.country,u.Platform
        ,coalesce(a.predict_sub_revenue_365,0) predict_sub_revenue_365
--         ,if(a.predict_sub_revenue_365>0,LTV_actual_forecast,0.0) predict_sub_revenue
        ,if(a.predict_sub_revenue_365>0,GREATEST(LTV_actual_forecast,predict_sub_revenue_365),0.0) predict_sub_revenue  -- 感觉会影响平衡，再看吧改起来很快
from
(
    select *
    from bp_no_sub_user_info

    union all

    select *
    from ab_no_sub_user_info
) u
left join
(
    -- b+ ua
    select 'ua' types,'BeautyPlus' App_Name,Attributed_Touch_Date,date,user_pseudo_id,min(predict_sub_revenue_365) predict_sub_revenue_365
    from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
    where date between mDATE_START and mDATE_END and days>0
    group by 1,2,3,4,5

    union all

    -- b+ new
    select 'new' types,'BeautyPlus' App_Name,Attributed_Touch_Date,date,user_pseudo_id,min(predict_sub_revenue_365) predict_sub_revenue_365
    from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
    where date between mDATE_START and mDATE_END and days>0
    group by 1,2,3,4,5

    union all

    -- ab + ua
    select 'ua' types,'AirBrush' App_Name,Attributed_Touch_Date,date,user_pseudo_id,min(predict_sub_revenue_365) predict_sub_revenue_365
    from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue
    where date between mDATE_START and mDATE_END and days>0
    group by 1,2,3,4,5

    union all

    -- ab + new
    select 'new' types,'AirBrush' App_Name,Attributed_Touch_Date,date,user_pseudo_id,min(predict_sub_revenue_365) predict_sub_revenue_365
    from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
    where date between mDATE_START and mDATE_END and days>0
    group by 1,2,3,4,5
) a
on u.App_Name=a.App_Name and u.types=a.types and u.Attributed_Touch_Date=a.Attributed_Touch_Date
       and u.user_pseudo_id=a.user_pseudo_id and u.date=a.date
left join LTV b
on u.App_Name=b.app_id and u.country=b.country and u.Platform=b.platform

-- )
-- group by 1,2,3,4
-- having sum(predict_sub_revenue_365) is not null
-- order by 5 desc
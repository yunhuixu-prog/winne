
-- drop table if exists dataintegration-265403.temp.dws_dz_roas_predict_goal_users;
-- create table dataintegration-265403.temp.dws_dz_roas_predict_goal_users as

delete from dataintegration-265403.temp.dws_dz_roas_predict_goal_users where Attributed_Touch_Date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into dataintegration-265403.temp.dws_dz_roas_predict_goal_users

-- ua部分修改了afid为id
select 'ua' types,a.App_Name,UPPER(a.Platform) Platform,a.Attributed_Touch_Date,a.AppsFlyer_ID id,s.user_pseudo_id
--     ,max(case when permanent_country in ('United States','Japan','United Kingdom','South Korea','Thailand') then permanent_country else 'else' end) region
    ,max(permanent_country) region
from
(
    select App_Name,Attributed_Touch_Date_hk Attributed_Touch_Date,AppsFlyer_ID,Platform
    from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
    where App_Name in ('BeautyPlus','AirBrush') and Attributed_Touch_Date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}'
        and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
) a
-- 由于不同id的对应问题，可能会过滤调部分数据，记一下会过滤多少%
join
(
    select 'BeautyPlus' app_name,platform,user_pseudo_id,first_appsflyer_id,last_appsflyer_id,permanent_country
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

    union all

    select 'AirBrush' app_name,platform,user_pseudo_id,first_appsflyer_id,last_appsflyer_id,permanent_country
    from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
) s
on UPPER(a.Platform)=s.platform
  AND a.AppsFlyer_ID=s.first_appsflyer_id
  AND a.App_Name=s.app_name
group by 1,2,3,4,5,6

union all

SELECT 'new' types,app_name App_Name
      ,upper(Platform) as Platform,event_date_hk as Attributed_Touch_Date,uuid id,user_pseudo_id
--     ,max(case when country in ('United States','Japan','United Kingdom','South Korea','Thailand') then country else 'else' end) region
      ,max(country) region
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
where app_name in ('BeautyPlus','AirBrush') and is_new = 1 -- 限制新增用户
    and event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}'
                        and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by
  1,2,3,4,5,6




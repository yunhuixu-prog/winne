
drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users;
create table beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users as


select a.App_Name,UPPER(a.Platform) Platform,a.Attributed_Touch_Date,a.AppsFlyer_ID,s.user_pseudo_id
    ,max(case when permanent_country in ('United States','Japan','United Kingdom','South Korea','Thailand') then permanent_country else 'else' end) region  -- 换成全量表后可以再决定需不需要
from
(
    select App_Name,Attributed_Touch_Date,AppsFlyer_ID,Platform
    from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
    where App_Name='BeautyPlus' and Attributed_Touch_Date<='2023-03-31'
        and Attributed_Touch_Date>='2023-01-01'
) a
join
(
    select platform,user_pseudo_id,first_appsflyer_id,last_appsflyer_id,permanent_country
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk='2024-03-04'
) s
on UPPER(a.Platform)=s.platform
  AND a.AppsFlyer_ID=s.first_appsflyer_id
group by 1,2,3,4,5


-- select Attributed_Touch_Date,count(distinct AppsFlyer_ID),count(distinct user_pseudo_id)
-- from beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users
-- group by 1

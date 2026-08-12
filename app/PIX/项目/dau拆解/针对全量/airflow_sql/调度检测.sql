-- 是否有漏的或者重复的以及是否有一年的订阅
select date,count(uuid),count(distinct uuid),count(case when sub_365>0 then uuid end)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
from airbrush-1324.temp.dws_dz_his_split_final_user_behave
group by 1
order by 1

-- 验证指标是否有
select * from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date='2023-07-01'
-- and pv_tab0_edit_entry>0  -- 核心行为
and pop_exposure_90>0  -- other行为
-- and holiday_active_days_365>0 -- 节日行为
limit 10

select * from airbrush-1324.temp.dws_dz_his_split_final_user_behave
where date='2024-07-08'
-- and `pv_camera_enter-all-all`  -- 核心行为
and pop_exposure_90>0  -- other行为
-- and holiday_active_days_365>0 -- 节日行为
limit 10

select date,count(uuid),count(distinct uuid)
    ,count(distinct case when sub_365>0 then uuid end)
    ,count(distinct case when `pv_camera_enter-all-all`>0 then uuid end)
    ,count(distinct case when pop_exposure_90>0 then uuid end)
    ,count(distinct case when holiday_active_days_365>0 then uuid end)
from airbrush-1324.temp.dws_dz_his_split_final_user_behave
group by 1
order by 1



-- 预测检测,看量级和比例

select date,count(1),count(distinct uuid),count(distinct case when predit_sub_365_proba>0.2 then uuid end)
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
-- from airbrush-1324.temp.ads_dz_his_split_predict_sub_365
group by 1
order by 1

select date,install_days_type,count(1),count(distinct uuid),count(distinct case when predit_sub_365_proba>0.2 then uuid end)
from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
group by 1,2
order by 1,2


select app_name,date,count(distinct gid)
  ,count(distinct case when predit_sub_365_proba is null then gid end)
  ,count(distinct case when predit_sub_365_proba<0.2 then gid end)
  ,count(distinct case when predit_sub_365_proba>=0.2 then gid end)
from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
group by 1,2


-- 两次预测重合度
select coalesce(a.app_name,b.app_name) app_name
     ,count(distinct case when b.gid is not null then a.gid end) uv_ab
     ,count(distinct case when b.gid is null then a.gid end) uv_a
     ,count(distinct case when a.gid is null then b.gid end) uv_b
from
(
    select app_name,date,gid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
    where date='2024-11-14' and predit_sub_365_proba<0.05
) a
full join
(
    select app_name,date,gid,predit_sub_365_proba
    from dataintegration-265403.subscription.dws_wzp_subscription_active_365_user_sub_probability
    where date='2024-11-07' and predit_sub_365_proba<0.05
) b
on a.app_name=b.app_name and a.gid=b.gid
group by 1


-- test
select a.event_date_hk date,a.gid,b.uuid,predit_sub_365_proba,'BeautyPlus' app_name
from
(
    select aa.event_date_hk,aa.gid,bb.uuid
    from
    (
        select event_date_hk,gid
        from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
        where event_date_hk='2024-07-01'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.gid=bb.key
) a
right join
(
    select date,uuid,max(predit_sub_365_proba) predit_sub_365_proba
    from beautyplus-bc0ed.temp.ads_dz_his_split_predict_sub_365
    where date='2024-07-01'
    group by 1,2
) b
on a.uuid=b.uuid
where a.uuid is null

limit 1000


select key,uuid
from `dataintegration-265403.stat.dmi_dz_idmapping`
where uuid='738137325'

select event_date_hk,gid,last_active_date,*
        from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
        where event_date_hk='2024-07-01'
        and gid='3057424520'
          -- and last_active_date>=date_sub(event_date_hk,interval 365 day)
limit 100


-- firebase维表和gid维表的对应
select count(distinct a.gid),count(distinct b.user_pseudo_id)
     ,count(distinct a.uuid),count(distinct b.uuid)
from
(
    select aa.event_date_hk,aa.gid,bb.uuid
    from
    (
        select event_date_hk,gid
        from `airbrush-1324.dim.dim_dzp_portrait_gid_user`
        where event_date_hk='2024-07-08'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.gid=bb.key
) a
left join
(
    select aa.event_date_hk,aa.user_pseudo_id,bb.uuid
    from
    (
        select event_date_hk,user_pseudo_id
        from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk='2024-07-08'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.user_pseudo_id=bb.key
) b
on a.uuid=b.uuid

-- firebase维表和静静的表的对应
select count(distinct a.uuid),count(distinct b.uuid)
from
(
    select aa.event_date_hk,aa.user_pseudo_id,bb.uuid
    from
    (
        select event_date_hk,user_pseudo_id
        from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk='2024-07-08'
          and last_active_date>=date_sub(event_date_hk,interval 365 day)
    ) aa
    join
    (
        select key,uuid
        from `dataintegration-265403.stat.dmi_dz_idmapping`
    ) bb
    on aa.user_pseudo_id=bb.key
) a
left join
(
    select uuid from airbrush-1324.temp.dws_dz_his_split_final_user_behave
    where date='2024-07-08'
) b
on a.uuid=b.uuid

-- 静静的表和预测表对应
select count(distinct a.uuid),count(distinct b.uuid)
from
(
    select uuid from airbrush-1324.temp.dws_dz_his_split_final_user_behave
    where date='2024-07-08'
) a
left join
(
    select uuid from airbrush-1324.temp.ads_dz_his_split_predict_sub_365
    where date='2024-07-08'
) b
on a.uuid=b.uuid

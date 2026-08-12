`beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
-- 目前问题，last_firebase有点问题（已解决）

-- 查询记录天数
select distinct event_date_hk
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
;
select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
where event_date_hk between '2024-01-01' and '2024-04-03'
  and first_country!=last_country and last_active_date>'2024-01-01' and first_active_date>'2023-01-01'
limit 10
;
select *
from
(
    select event_date_hk,gid,count(user_pseudo_id) num
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2024-02-20' and '2024-03-20'
    group by 1,2
)
where num>1
limit 10

-- 和firebaseid对应，gid少一点，合理
select 'firebase' flag,count(1),count(distinct user_pseudo_id)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk = '2024-02-20'
  and last_active_date='2024-02-20'

union all

select 'gid' flag,count(1),count(distinct gid)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
where event_date_hk = '2024-02-20'
  and last_active_date='2024-02-20'


-- 查询单个用户记录情况以及是否记录正确
-- 2636715139,2641129112,2616746372,2531073005
select *
-- select event_date_hk,first_active_date,last_active_date,active_category
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
where event_date_hk between '2023-01-01' and '2024-04-03'
  and gid='2293441824'
order by event_date_hk

select *
-- select event_date_hk,user_pseudo_id,app_version,country,user_type,is_UA
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where gid='2293441824'
order by event_date_hk

-- 查询afid
select *
from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
where AppsFlyer_ID='1673553515998-3394184251410521967'


-- 查询当天活跃和活跃表是否能对上（差不多）
-- 结果：2313243
select count(distinct gid)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
where event_date_hk = '2024-02-20'
  and last_active_date='2024-02-20'

-- 结果：2423241
select count(distinct gid)
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk = '2024-02-20' and app_name='BeautyPlus'

-- 首次活跃当天量级
select count(distinct user_pseudo_id)
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk = '2024-02-20' and is_new=1

select is_new,count(distinct user_pseudo_id)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk = '2024-02-20'
  and first_active_date='2024-02-20'
group by 1








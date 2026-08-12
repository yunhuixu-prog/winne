
select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
limit 10

-- 查询记录天数
select distinct event_date_hk
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`


-- 查询单个用户记录情况以及是否记录正确
select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where user_pseudo_id='80340c55239ffb827fdeda7b83ce1f5e'

select *
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk between '2023-01-01' and '2023-04-03'
  and user_pseudo_id='80340c55239ffb827fdeda7b83ce1f5e'

select *
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where user_pseudo_id='80340c55239ffb827fdeda7b83ce1f5e'


-- 查询afid
select *
from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
where AppsFlyer_ID='1673553515998-3394184251410521967'

-- 查询每天量级，2亿多
select count(1),count(distinct user_pseudo_id)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk='2024-02-20'

select count(1),count(distinct user_pseudo_id)
from `beautyplus-bc0ed.ods.ods_da_all_device`
where event_date_hk='2024-02-20' and first_launch_date>='2022-01-01'


-- 查询当天活跃和活跃表是否能对上（差不多）
-- 结果：2760318
select count(distinct user_pseudo_id)
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk = '2024-02-20'
  and last_active_date='2024-02-20'

-- 结果：2759612
select count(distinct user_pseudo_id)
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



-- 其他指标验收




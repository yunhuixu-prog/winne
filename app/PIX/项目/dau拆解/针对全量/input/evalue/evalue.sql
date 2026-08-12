-- 评估取多久的全量用户
select count(distinct a.user_pseudo_id) uv
    ,count(distinct case when first_active_date>='2021-01-01' then a.user_pseudo_id end) uv_after_2021
    ,count(distinct case when first_active_date>='2022-01-01' then a.user_pseudo_id end) uv_after_2022
    ,count(distinct case when first_active_date>='2023-01-01' then a.user_pseudo_id end) uv_after_2023
from
(
    select user_pseudo_id,event_date_hk
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between '2024-03-01' and '2024-03-31'
        and app_name='BeautyPlus'
) a
left join
(
    select user_pseudo_id,event_date_hk,first_active_date
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where event_date_hk between '2024-03-01' and '2024-03-31'
          --and first_active_date>='2021-01-01'
) b
on a.user_pseudo_id=b.user_pseudo_id and a.event_date_hk=b.event_date_hk




-- 选取2022年后每天的全量用户量级
select count(1)
     ,count(case when first_active_date>='2021-01-01' then 1 end) uv_after_2021
     ,count(case when first_active_date>='2022-01-01' then 1 end) uv_after_2022
     ,count(case when first_active_date>='2023-01-01' then 1 end) uv_after_2023
from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
where event_date_hk = '2024-03-31'


-- behave表评估
select count(1),count(distinct user_pseudo_id)
from beautyplus-bc0ed.temp.dws_dz_his_split_user_behave
where date between '2023-03-01' and '2023-03-01'
        and last_active_days=0
limit 10


-- sub_behave表评估
select count(1),count(distinct user_pseudo_id)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-01'
--         and last_active_days=0
--         and is_paying='un-Paying' and is_consum='un-consumable'  -- 限制了当天活跃的
        and is_current_pay=0
limit 10

-- 单个用户查看
select *
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where
--     date between '2023-03-01' and '2023-03-01' and last_active_days=0 and is_current_pay=0 and sub_365>0
    date between '2023-03-01' and '2023-03-31'
--         and is_paying='un-Paying' and is_consum='un-consumable'  -- 限制了当天活跃的
         and user_pseudo_id='3675ba46a264507b351b849026a2ef58'
order by date


-- 预测放入模型数据量级
select sub_type,if(sub_365>0,1,0),count(1),count(distinct user_pseudo_id)
from
(
    select sub_type,sub_365,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
    where date between '2023-01-01' and '2023-03-30'
        and sub_365>0
        and rand()<0.8
        and sub_type='else'
        and install_days_type = 1

    union all

    select sub_type,sub_365,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
    where date between '2023-01-01' and '2023-03-30'
        and sub_365=0
        and rand()<0.1
        and sub_type='else'
        and install_days_type = 1
        and bucket=1
)
group by 1,2


-- 预测样本量级

select count(1)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
-- where date = DATE_SUB({0}, INTERVAL {1}+90 DAY)
where date = '2023-03-31' and sub_type='else'
    and last_active_days_type=1
    -- and is_new=0
    and install_days_type = 1


--
-- -- 牛逼居然有用户有行为但无活跃,b7c92a43557a7c79008fd4586335a179
-- select *
-- from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
-- where event_date between date_sub('2023-03-01',interval 6 day) and '2023-03-01'
--     and a.mark in (0, 1, 2) and user_pseudo_id='b7c92a43557a7c79008fd4586335a179'
--
-- select user_pseudo_id,event_date_hk
--     from `dataintegration-265403.stat.stat_active_advice_detail_d`
--     where event_date_hk between date_sub('2023-03-01',interval 6 day) and '2023-03-01'
--         and app_name='BeautyPlus'
--         and user_pseudo_id='b7c92a43557a7c79008fd4586335a179'





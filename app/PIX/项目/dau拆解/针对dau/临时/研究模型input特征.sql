-- 查看样本量
select sub_type,if(sub_365>0,1,0),count(1),count(distinct user_pseudo_id)
  from
  (
      select sub_type,sub_365,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
    where date between '2023-01-01' and '2023-03-31'
        and sub_365>0
        and rand()<1
        and sub_type='else'
--         and is_new=1
        and install_days between 1 and 7

    union all

    select sub_type,sub_365,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
    where date between '2023-01-01' and '2023-03-31'
        and sub_365=0
        and rand()<0.015
        and sub_type='else'
--         and is_new=1
        and install_days between 1 and 7
  )
  group by 1,2

-- select if(sub_no_trial_365>0,1,0),count(1),count(distinct user_pseudo_id)
--   from
--   (
--       select sub_no_trial_365,user_pseudo_id
--     from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
--     where Attributed_Touch_Date between '2023-01-01' and '2023-03-31'
--         and sub_no_trial_365>0
--         and rand()<1
--         and sub_now=0
-- --         and is_new=1
--         and days between 0 and 6
--
--     union all
--
--     select sub_no_trial_365,user_pseudo_id
--     from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
--     where Attributed_Touch_Date between '2023-01-01' and '2023-03-31'
--         and sub_no_trial_365=0
--         and rand()<0.015
--         and sub_now=0
-- --         and is_new=1
--         and days between 0 and 6
--   )
--   group by 1

-- select *
-- from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v a
-- right join beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v b
-- on a.date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id
-- where a.sub_type='else' and a.date = '2023-03-01' and install_days=1 and a.user_pseudo_id is null and b.days=0
-- limit 10
--
-- select *
-- from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v b
-- where b.Attributed_Touch_Date='2023-02-01' and date between '2023-01-01' and '2023-03-31'
-- --     and b.days=0
-- --     and sub_now=0
--     and user_pseudo_id='1D8CA8D37828434CA6D65A2B22E974E9'
-- limit 10
--
-- select *
-- from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v a
-- where a.date between '2023-01-01' and '2023-03-31'
--     and a.sub_type='else'
--     and user_pseudo_id='1D8CA8D37828434CA6D65A2B22E974E9'
-- limit 10


select if(sub_365>0,1,0),count(1)
  from
  (
        select sub_365
        from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
        -- where date = DATE_SUB({0}, INTERVAL {1}+90 DAY)
        where date = '2023-03-15' and sub_type='else'
  )
  group by 1


-- 分类型预测评估
-- 不同订阅状态预估分布(新用户如果当前未订阅的话，未来90天付费很少了吧)
select sub_type
     ,case when sub_type='else' then install_days_type
           else sub_type
      end install_days_type
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
  from
  (
      select date,sub_365,sub_type,is_new
             ,install_days
             ,case when install_days between 1 and 3 then '1:1-3'
                   when install_days between 4 and 7 then '2:4-7'
                   when install_days between 8 and 14 then '3:8-14'
                   when install_days between 15 and 30 then '4:15-30'
                   when install_days between 31 and 60 then '5:31-60'
                   when install_days between 61 and 90 then '6:61-90'
                   when install_days between 91 and 180 then '7:91-180'
                   when install_days between 181 and 365 then '8:181-365'
                   when install_days between 366 and 730 then '9:366-730'
             else '91:731+'
             end install_days_type
      from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
      where date between '2023-01-01' and '2023-03-31'
  )
--   where is_new=0 or (is_new=1 and install_days_type='1:1-3')
  group by 1,2
  order by 1,2


select *
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
where date = '2023-03-01' and sub_365>0 and sub_type='else' and install_days between 1 and 7


-- 查看特征对订阅的关系
select if(sub_365>0,1,0) sub_365,sum()
from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
where date between '2023-02-01' and '2023-03-31'
    and sub_type='else'
    and install_days between 1 and 7




-- 90天预测

-- select sub_type,if(sub_90>0,1,0),count(1)
--   from
--   (
--       select sub_90,sub_type
--       from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
--       where date between '2024-01-01' and '2024-01-14'
--           and sub_90>0
-- --           and rand()<0.1
--
--       union all
--
--       select sub_90,sub_type
--       from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
--       where date between '2024-01-01' and '2024-01-14'
--           and sub_90=0
--           and rand()<0.005
--   )
--   group by 1,2
--   order by 1,2

-- select if(sub_90>0,1,0),count(1)
--   from
--   (
--         select sub_90
--         from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
--         -- where date = DATE_SUB({0}, INTERVAL {1}+90 DAY)
--         where date = '2024-01-15' and sub_type='else'
--   )
--   group by 1

-- select is_new,sub_type,count(1)/count(distinct date) uv
--      ,count(case when sub_90>0 then 1 end)/count(distinct date) sub_90_uv
--   from
--   (
--       select date,sub_90,sub_type,is_new
--       from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
--       where date between '2024-01-01' and '2024-01-15'
--   )
  group by 1,2
  order by 1,2




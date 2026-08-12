select sub_type
--      ,case when sub_type='else' then install_days_type
--            else sub_type
--       end install_days_type
--      ,case when sub_type='else' then last_active_days_type
--            else sub_type
--       end last_active_days_type
     ,case when install_days_type between 1 and 2 then '1-2'
           when install_days_type between 3 and 4 then '3-4'
           when install_days_type between 5 and 6 then '5-6'
           when install_days_type between 7 and 10 then '7-10'
     end install_days_type
     ,cast(is_active_7 as string) is_active_7
     ,cast(is_edit_selfi_7 as string) is_edit_selfi_7
     ,case when is_active_7 = 1 then 'all' else cast(is_active_30 as string) end is_active_30
     ,case when is_active_7 = 1 then 'all' else cast(is_edit_selfi_30 as string) end is_edit_selfi_30
     ,case when is_active_7 = 1 or is_active_30 = 1 then 'all' else cast(is_active_60 as string) end is_active_60
     ,case when is_active_7 = 1 or is_active_30 = 1 then 'all' else cast(is_edit_selfi_60 as string) end is_edit_selfi_60
     ,case when is_active_7 = 1 or is_active_30 = 1 or is_active_60 = 1 then 'all' else cast(is_active_90 as string) end is_active_90
     ,case when is_active_7 = 1 or is_active_30 = 1 or is_active_60 = 1 then 'all' else cast(is_edit_selfi_90 as string) end is_edit_selfi_90
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
  from
  (
      select date,sub_365,sub_type
             ,install_days,install_days_type
             ,is_active_7,is_edit_selfi_7
             ,is_active_30,is_edit_selfi_30
             ,is_active_60,is_edit_selfi_60
             ,is_active_90,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_v
      where date between '2023-01-01' and '2023-04-30'
  )
--   where is_new=0 or (is_new=1 and install_days_type='1:1-3')
  group by 1,2,3,4,5,6,7,8,9,10
  order by 1,2,3,4,5,6,7,8,9,10

-- 无活跃有订阅的
select sub_type,install_days_type,is_active_7,is_active_90
        ,round(count(1)/count(distinct date)) uv
        ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365
        ,round(count(case when coalesce(active_365,0)=0 and sub_365>0 then 1 end)/count(distinct date)) no_active_sub_365
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-03-31'
group by 1,2,3,4
order by 1,2,3,4

-- 3月4月数据差异
select date,sub_365,sub_type
     ,install_days,install_days_type
     ,is_active_7,is_edit_selfi_7
     ,is_active_30,is_edit_selfi_30
     ,is_active_60,is_edit_selfi_60
     ,is_active_90,is_edit_selfi_90
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_v
where date between '2023-01-01' and '2023-04-30'











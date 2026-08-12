
-- 分类型预测评估
-- 不同订阅状态预估分布(新用户如果当前未订阅的话，未来90天付费很少了吧)
select sub_type
--      ,case when sub_type='else' then install_days_type
--            else sub_type
--       end install_days_type
--      ,case when sub_type='else' then last_active_days_type
--            else sub_type
--       end last_active_days_type
     ,install_days_type
     ,is_active_7
     ,is_edit_selfi_7
--      ,is_active_30
--      ,is_edit_selfi_30
--      ,is_active_60
--      ,is_edit_selfi_60
     ,is_active_90
     ,is_edit_selfi_90
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
      where date between '2023-01-01' and '2023-03-31'
  )
--   where is_new=0 or (is_new=1 and install_days_type='1:1-3')
  group by 1,2,3,4,5,6 --,7,8,9,10
  order by 1,2,3,4,5,6 --,7,8,9,10



-- 不同文字性特征与结果的关系
select
--     platform,
--      permanent_country,
--      brand,
--      is_ua,
     model
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
  from
  (
      select date,sub_365,is_new
             ,install_days
             ,last_active_days,permanent_country,platform,brand,is_ua,model
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
      where date between '2023-03-01' and '2023-03-31' and is_current_trial = 0 and past_sub_times=0
  )
  group by 1
  order by 1



--brand
select brand
     ,case when brand in ('Infinix','Tecno','itel','Nokia') then 2
        when brand in ('Vivo','Realme','Huawei','LG','Lenovo') then 3
        when brand in ('OPPO','Xiaomi','OnePlus') then 4
        when brand in ('Samsung','Sharp','Honor','POCO') then 5
        when brand in ('Sony') then 6
        when brand in ('Motorola','Google') then 7
        when brand in ('Apple') then 8
        when brand in ('Epik') then 9
        else 3
     end brand_t
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-31'
limit 10

-- model
select distinct model
     ,case when model like '%iPhone%' then if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'')
        else 'else'
     end model_1_pre
     ,case when model like '%iPhone%' then concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],''))
        else 'else'
     end model_2_pre

    ,case when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('4s','4','4c') then 4
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('5s','5','5c') then 5
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('6s','6','6c') then 6
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('7s','7','7c') then 7
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('8s','8','8c') then 8
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('SE','XR','X','XS') then 10
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('11') then 11
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('12') then 12
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('13') then 13
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('14') then 14
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('15') then 15
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') in ('16') then 16
          when model like '%iPhone%' and if(ARRAY_LENGTH(SPLIT(model, ' '))>=2,SPLIT(model, ' ')[1],'') = '' then 14
        else 1
     end model_1
     ,case when model like '%iPhone%'
                and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('mini') then 2
           when model like '%iPhone%'
                and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Plus') then 4
           when model like '%iPhone%'
                and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('Pro','Max') then 5
           when model like '%iPhone%'
                and concat(if(ARRAY_LENGTH(SPLIT(model, ' '))>=3,SPLIT(model, ' ')[2],''),if(ARRAY_LENGTH(SPLIT(model, ' '))>=4,SPLIT(model, ' ')[3],'')) in ('ProMax') then 6
           when model like '%iPhone%' then 3
        else 1
     end model_2

from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-31' and model like '%iPhone%'
limit 10

-- permanent_country

select brand
     ,case when permanent_country in ('Nigeria','India','Iran','Pakistan','Egypt','Cambodia','Bangladesh','Myanmar (Burma)') then 1
         when permanent_country in ('Indonesia','Thailand','Philippines','Mexico','Malaysia','United Arab Emirates','France','Peru'
            ,'Saudi Arabia','Colombia','Taiwan','Russia','Argentina','Hong Kong','South Africa','Dominican Republic'
            ,'Greece','Kuwait','Ukraine','Azerbaijan','Serbia','Ecuador','Lebanon','Hungary','Jordan','Kazakhstan') then 2
         when permanent_country in ('Vietnam','Japan','Turkey','South Korea','Brazil','United Kingdom','Germany','Singapore','Spain','Italy'
            ,'Netherlands','Chile','Romania','Belgium','Poland','Cyprus','Portugal','Sweden') then 3
         when permanent_country in ('United States','Canada','Australia','Israel','Switzerland','Austria') then 4
         when permanent_country in ('Türkiye') then 5
         else 2
     end region
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-31'
limit 10



-- 分类型样本分布
select function_num  --function_num_pre,grow_function_num
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
     ,round(count(case when sub_365>0 then 1 end)/count(1),3) sub_365_ratio
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-31'
    and is_current_pay=0
group by 1
order by 1

-- case when function_num between 0 and 3 then function_num
--      when function_num between 4 and 9 then 4
--      when function_num between 10 and 20 then 5
--      when function_num between 21 and 34 then 6
--      when function_num >= 35 then 7
-- end function_num_type

-- case when function_num_pre between 0 and 3 then function_num_pre
--      when function_num_pre between 4 and 9 then 4
--      when function_num_pre between 10 and 25 then 5
--      when function_num_pre between 26 and 40 then 6
--      when function_num_pre >= 40 then 7
-- end function_num_pre_type

-- case when grow_function_num <-35 then -7
--      when grow_function_num between -35 and -20 then -6
--      when grow_function_num between -19 and -10 then -5
--      when grow_function_num between -9 and -4 then -4
--      when grow_function_num between -3 and 3 then grow_function_num
--      when grow_function_num between 4 and 9 then 4
--      when grow_function_num between 10 and 20 then 5
--      when grow_function_num between 21 and 35 then 6
--      when grow_function_num >= 36 then 7
-- end grow_function_num_type


select case when pay_duffle_click_ratio <= 0.01 then 1
     when pay_duffle_click_ratio > 0.01 and pay_duffle_click_ratio <= 0.05 then 2
     when pay_duffle_click_ratio > 0.05 and pay_duffle_click_ratio <= 0.1 then 3
     when pay_duffle_click_ratio > 0.1 and pay_duffle_click_ratio <= 0.2 then 4
     when pay_duffle_click_ratio > 0.2 and pay_duffle_click_ratio <= 0.3 then 5
     when pay_duffle_click_ratio > 0.3 and pay_duffle_click_ratio <= 0.4 then 6
     when pay_duffle_click_ratio > 0.4 and pay_duffle_click_ratio <= 0.5 then 7
     when pay_duffle_click_ratio > 0.5 and pay_duffle_click_ratio <= 0.6 then 8
     when pay_duffle_click_ratio > 0.6 and pay_duffle_click_ratio <= 0.8 then 9
     when pay_duffle_click_ratio > 0.8 and pay_duffle_click_ratio <= 1 then 10
end pay_duffle_click_ratio_type
  --function_num_pre,grow_function_num
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
     ,round(count(case when sub_365>0 then 1 end)/count(1),3) sub_365_ratio
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-03-01' and '2023-03-31'
group by 1
order by 1


-- case when pay_duffle_click_ratio = 0 then 0
--      when pay_duffle_click_ratio > 0 and pay_duffle_click_ratio <= 0.01 then 2
--      when pay_duffle_click_ratio > 0.01 and pay_duffle_click_ratio <= 0.05 then 3
--      when pay_duffle_click_ratio > 0.05 and pay_duffle_click_ratio <= 0.1 then 4
--      when pay_duffle_click_ratio > 0.1 and pay_duffle_click_ratio <= 0.2 then 5
--      when pay_duffle_click_ratio > 0.2 and pay_duffle_click_ratio <= 0.3 then 6
--      when pay_duffle_click_ratio > 0.3 and pay_duffle_click_ratio <= 0.4 then 7
--      when pay_duffle_click_ratio > 0.4 and pay_duffle_click_ratio <= 0.5 then 8
--      when pay_duffle_click_ratio > 0.5 and pay_duffle_click_ratio <= 0.6 then 9
--      when pay_duffle_click_ratio > 0.6 and pay_duffle_click_ratio <= 0.7 then 10
--      when pay_duffle_click_ratio > 0.7 and pay_duffle_click_ratio <= 0.8 then 11
--      when pay_duffle_click_ratio > 0.8 and pay_duffle_click_ratio <= 0.9 then 12
--      when pay_duffle_click_ratio > 0.9 and pay_duffle_click_ratio < 1 then 13
--      when pay_duffle_click_ratio = 1 then 1  -- 比例为1时订阅率反而更低了
-- end pay_duffle_click_ratio_type

case when pay_function_click_ratio = 0 then 1
     when pay_function_click_ratio > 0 and pay_function_click_ratio <= 0.05 then 2
     when pay_function_click_ratio > 0.05 and pay_function_click_ratio <= 0.1 then 3
     when pay_function_click_ratio > 0.1 and pay_function_click_ratio <= 0.2 then 4
     when pay_function_click_ratio > 0.2 and pay_function_click_ratio <= 0.3 then 5
     when pay_function_click_ratio > 0.3 and pay_function_click_ratio <= 0.4 then 6
     when pay_function_click_ratio > 0.4 and pay_function_click_ratio <= 0.5 then 7
     when pay_function_click_ratio > 0.5 and pay_function_click_ratio <= 0.6 then 8
     when pay_function_click_ratio > 0.6 and pay_function_click_ratio <= 0.7 then 9
     when pay_function_click_ratio > 0.7 and pay_function_click_ratio <= 0.8 then 10
     when pay_function_click_ratio > 0.8 and pay_function_click_ratio <= 0.9 then 11
     when pay_function_click_ratio > 0.9 and pay_function_click_ratio < 1 then 12
     when pay_function_click_ratio = 1 then 0
end pay_function_click_ratio_type

case when sub_page_click_ratio = 0 then 1
     when sub_page_click_ratio > 0 and sub_page_click_ratio <= 0.1 then 2
     when sub_page_click_ratio > 0.1 and sub_page_click_ratio <= 0.2 then 3
     when sub_page_click_ratio > 0.2 and sub_page_click_ratio <= 0.3 then 4
     when sub_page_click_ratio > 0.3 and sub_page_click_ratio <= 0.4 then 5
     when sub_page_click_ratio > 0.4 and sub_page_click_ratio <= 0.5 then 6
     when sub_page_click_ratio > 0.5 and sub_page_click_ratio <= 0.7 then 7
     when sub_page_click_ratio > 0.7 and sub_page_click_ratio < 1 then 8
     when sub_page_click_ratio = 1 then 9
end sub_page_click_ratio_type



select install_days  --function_num_pre,grow_function_num
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
     ,round(count(case when sub_365>0 then 1 end)/count(1),4) sub_365_ratio
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-03-01' and '2023-03-31'
    and is_current_pay=0
group by 1
order by 1



select days
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
     ,round(count(case when sub_365>0 then 1 end)/count(1),3) sub_365_ratio
  from
  (
      select date,sub_365,sub_type,is_new
             ,install_days+last_active_days days
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-03-01' and '2023-03-31' and sub_type='else'
  )
  group by 1
  order by 1



-- 筛除部分样本
select install_days,if(sub_365>0,'pay','free') sub_365
     ,count(1) pv
--      ,count(case when `pv_0级tab-修图---进入`>0 then 1 end) get_pv
--      ,round(count(case when `pv_0级tab-修图---进入`>0 then 1 end)/count(1),2) get_ratio
--      ,count(case when `pv_0级tab-修图---进入`>0 or coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)=0 then 1 end) get_pv
--      ,round(count(case when `pv_0级tab-修图---进入`>0 or coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)=0 then 1 end)/count(1),2) get_ratio
     ,count(case when coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)>0 then 1 end) get_pv
     ,round(count(case when coalesce(`pv_0级tab-修图---进入`,0)+coalesce(`pv_0级tab-自拍---进入`,0)>0 then 1 end)/count(1),2) get_ratio
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-03-01' and '2023-03-31'
    and sub_type='else'
--     and install_days_type = 2
group by 1,2
order by 1,2


-- 选择多少天未活跃的
select last_active_days
    ,round(count(1)/count(distinct date)) uv
    ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
    ,round(count(case when sub_365>0 then 1 end)/count(1),3) sub_365_ratio
from
(
    select date,sub_365,sub_type,is_new
         ,install_days,last_active_days
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
    where date between '2023-01-01' and '2023-03-31' and sub_type='else'
)
group by 1
order by 1


-- 30号很久未活跃的用户在31号的活跃情况

select  last_active_days_type_pre
        ,count(distinct a.user_pseudo_id) uv
        ,round(count(distinct case when sub_365>0 then a.user_pseudo_id end)) sub_365_uv
        ,round(count(distinct case when sub_365>0 then a.user_pseudo_id end)/count(distinct a.user_pseudo_id),3) sub_365_ratio
from
(
    select user_pseudo_id,sub_365,sub_type,is_new
         ,install_days,install_days_type,last_active_days
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_v
    where date between '2023-03-31' and '2023-03-31' and sub_type='else'
        and last_active_days=0
) a
left join
(
    select user_pseudo_id,last_active_days last_active_days_pre,last_active_days_type last_active_days_type_pre
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2_v
    where date between '2023-03-30' and '2023-03-30'
) b
on a.user_pseudo_id=b.user_pseudo_id
group by 1
order by 1




-- 大概在多久订阅的
-- 奇怪的点：近7天无活跃的用户，如果7天内活跃了，订阅率高于近7天有活跃的用户
-- 推测原因：换了账号
select sub_type
--      ,case when sub_type='else' then install_days_type
--            else sub_type
--       end install_days_type
--      ,case when sub_type='else' then last_active_days_type
--            else sub_type
--       end last_active_days_type
     ,install_days_type
     ,is_active_7
     ,is_edit_selfi_7
--      ,is_active_30
--      ,is_edit_selfi_30
--      ,is_active_60
--      ,is_edit_selfi_60
     ,is_active_90
     ,is_edit_selfi_90
     ,if(gid is null,0,1) has_gid
     ,round(count(1)/count(distinct date)) uv
     ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365_uv
     ,round(count(case when sub_90>0 then 1 end)/count(distinct date)) sub_90_uv
     ,round(count(case when sub_30>0 then 1 end)/count(distinct date)) sub_30_uv
     ,round(count(case when sub_7>0 then 1 end)/count(distinct date)) sub_7_uv
     ,round(count(case when active_365>0 then 1 end)/count(distinct date)) active_365_uv
     ,round(count(case when active_90>0 then 1 end)/count(distinct date)) active_90_uv
     ,round(count(case when active_30>0 then 1 end)/count(distinct date)) active_30_uv
     ,round(count(case when active_7>0 then 1 end)/count(distinct date)) active_7_uv
  from
  (
      select date,gid,sub_365,sub_90,sub_30,sub_7
             ,active_365,active_90,active_30,active_7
             ,sub_type
             ,install_days,install_days_type
             ,is_active_7,is_edit_selfi_7
             ,is_active_30,is_edit_selfi_30
             ,is_active_60,is_edit_selfi_60
             ,is_active_90,is_edit_selfi_90
      from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
      where date between '2023-01-01' and '2023-03-31'
  )
--   where is_new=0 or (is_new=1 and install_days_type='1:1-3')
  group by 1,2,3,4,5,6,7 --,7,8,9,10
  order by 1,2,3,4,5,6,7 --,7,8,9,10



-- 有多少用户没活跃，但是有了订阅(说明换了账号)
select sub_type,install_days_type,is_active_7,is_active_90
        ,round(count(1)/count(distinct date)) uv
        ,round(count(case when sub_365>0 then 1 end)/count(distinct date)) sub_365
        ,round(count(case when coalesce(active_365,0)=0 and sub_365>0 then 1 end)/count(distinct date)) no_active_sub_365
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-03-31'
group by 1,2,3,4
order by 1,2,3,4


-- 没有gid的原因
select user_pseudo_id
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where gid is null and install_days_type=1
limit 1000

select event_date_hk,user_pseudo_id,gid
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk between '2023-01-01' and '2023-03-31'
    and user_pseudo_id='4B2B4F9B6A0740AFB84C85AA5E669EEC'
order by 1
-- 7302be1cbc31714566f5c86451c28a2a

-- 有1/6的用户没有gid啊，为什么
select count(distinct user_pseudo_id),count(distinct case when gid is null then user_pseudo_id end)
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk between '2023-01-01' and '2023-03-31' and app_name='BeautyPlus'



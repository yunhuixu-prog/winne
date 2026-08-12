-- 结论：null值两大可能：1.安装日期还没活跃（只能舍弃了，都没数毕竟）；2.近7天无活跃

select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_behave
    where date between '2023-01-01' and '2023-06-30'
    and user_pseudo_id='4389A3ED567E4CAABE69BAD363FA0072'

-- 查找对应afid
select *
from
(
select App_Name,Platform,Attributed_Touch_Date,AppsFlyer_ID,max(user_pseudo_id) user_pseudo_id,max(region) region
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users group by 1,2,3,4
) where user_pseudo_id= '4389A3ED567E4CAABE69BAD363FA0072'


-- afid:1676566238418-6328853
-- 根据afid查找订单
select *
from dataintegration-265403.temp.temp_roi_predict_sub_lable_pre
where AppsFlyer_ID='1676566238418-6328853'


-- 查看模型输入里用户情况
select *,date_diff(date,Attributed_Touch_Date,DAY) days
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input
    where date<='2023-06-30'
    and user_pseudo_id='4389A3ED567E4CAABE69BAD363FA0072'


-- 查看活跃情况
select *
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk >='2023-02-16'
        and app_name='BeautyPlus'
        and  user_pseudo_id='4389A3ED567E4CAABE69BAD363FA0072'



select Attributed_Touch_Date,count(distinct user_pseudo_id),count(distinct id)
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    where Attributed_Touch_Date between '2024-03-01' and '2024-03-24' and types='new'
    group by 1
    order by 1

select sum(payment_price_usd)
from dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v
where app_id='BeautyPlus' and Attributed_Touch_Time = '2024-03-01' and standard_order_date<='2024-03-24'


-- sub和roas看板收入对不上的原因，roas看板收入的投放日期是投放表里的Attributed_Touch_Date_hk，sub是投放表里的Attributed_Touch_Date
with goal_users as
(
    select types,App_Name,Platform,Attributed_Touch_Date,id,max(user_pseudo_id) user_pseudo_id,max(region) region
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    group by 1,2,3,4,5
)

select a.types,a.Attributed_Touch_Date,sum(b.payment_price_usd)
from goal_users a
left join dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v b
    on b.app_id=a.App_Name
      AND b.platform=a.Platform
      AND b.AppsFlyer_ID=a.id
where a.types='ua' and a.Attributed_Touch_Date='2024-03-02' and b.standard_order_date<='2024-03-24' and product='subscription'
group by 1,2

select a.types,b.Attributed_Touch_Time Attributed_Touch_Date,sum(b.payment_price_usd)
from goal_users a
left join dataintegration-265403.temp.dwd_dz_roi_predict_0_sub_lable_v b
    on b.app_id=a.App_Name
      AND b.platform=a.Platform
      AND b.AppsFlyer_ID=a.id
where a.types='ua' and b.Attributed_Touch_Time='2024-03-02' and b.standard_order_date<='2024-03-24' and product='subscription'
group by 1,2

select a.types,b.Attributed_Touch_Time Attributed_Touch_Date,sum(b.payment_price_usd)
from goal_users a
left join dataintegration-265403.temp.dwd_dz_roi_predict_0_new_sub_lable_v b
    on b.app_id=a.App_Name
      AND b.platform=a.Platform
      AND b.uuid=a.id
where a.types='new' and b.Attributed_Touch_Time='2024-03-01' and b.standard_order_date<='2024-03-24' and product='subscription'
group by 1,2

-- select App_Name,Platform,id,count(1)
-- from goal_users
-- where types='ua' and Attributed_Touch_Date='2024-03-02'
-- group by 1,2,3
-- having count(1)>1
--

-- select *
-- from goal_users
-- where types='ua' and Attributed_Touch_Date='2024-03-02' and standard_order_date<='2024-03-24' and product='subscription'
-- and id=''







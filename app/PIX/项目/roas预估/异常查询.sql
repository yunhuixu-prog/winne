select *
from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
limit 100

-- 找出未来会订阅的用户检测订阅事件是否写错
select *
from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
-- where sub_365_from_att>0 and Attributed_Touch_Date='2023-07-07'
-- where sub_365_from_att>0 and Attributed_Touch_Date='2023-07-07' and is_current_pay=0
where sub_365_from_att=0 and Attributed_Touch_Date='2023-07-07' and is_current_trial>0
limit 100

select types,date,Attributed_Touch_Date,count(1),count(distinct uuid),count(distinct case when install_days is null then uuid end)
from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
group by 1,2,3
order by 1,2,3

select
    *
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2023-07-01' and '2024-07-30'  -- 最多预测未来一年
    and app_id in('BeautyPlus')
    and uuid='711253944'
order by standard_order_date

-- 取一个uuid看每个观测天的情况
select *
from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
where uuid='753942469' -- 768088722,711314622
order by date

-- 取一个uuid看是否会有多天都被算作投放日
select uuid,count(distinct Attributed_Touch_Date)
from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
group by 1
having count(distinct Attributed_Touch_Date)>1

-- ua的是否包含在了new里
select *
from
(
    select distinct Attributed_Touch_Date,uuid
    from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
    where types='ua'
) a
left join
(
    select distinct Attributed_Touch_Date,uuid
    from beautyplus-bc0ed.temp.dws_dz_roas_final_user_behave
    where types='new'
) b
on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.uuid=b.uuid
where b.uuid is null

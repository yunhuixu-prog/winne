-- 续订取消时间分布
select app_id,platform,subscription_period
--      ,case when cancel_start_day<=0 then '0:0'
--            when cancel_start_day between 1 and 3  then '1:1-3'
--            when cancel_start_day between 4 and 7  then '2:4-7'
--            when cancel_start_day between 8 and 30  then '3:8-30'
--            when cancel_start_day between 31 and 90  then '4:31-90'
--            when cancel_start_day between 91 and 180  then '5:91-180'
--            when cancel_start_day between 181 and 365  then '6:181-365'
--            when cancel_start_day > 365  then '7:366+'
--      end cancel_days
    ,case when cancel_start_day<=0 then 0 else cancel_start_day end cancel_start_day
    ,count(distinct order_id) order_num
from dataintegration-265403.temp.renewal_order_id_loss_data
where standard_order_expire_date<='2024-09-30' and is_final_cancell=1
group by 1,2,3,4
order by 1,2,3,4
;

-- 取消续订近7天活跃情况
select is_active_7,count(distinct uuid) uv
from dataintegration-265403.temp.renewal_order_id_loss_data
where is_now_cancell=0 and is_cancell_future_7=1 and date_diff(date,standard_order_date,day)>=7
group by 1
order by 1
;
select is_active_7,count(distinct uuid) uv
from dataintegration-265403.temp.renewal_order_id_loss_data
where is_today_cancell=1 and date_diff(date,standard_order_date,day)>=7
group by 1
order by 1
;
select is_active_now,count(distinct uuid) uv
from dataintegration-265403.temp.renewal_order_id_loss_data
where is_today_cancell=1
group by 1
order by 1
;

-- 正负样本量选取
-- 次日流失
select app_id,is_cancell_future_1,count(distinct uuid) uv,count(1) pv
from dataintegration-265403.temp.renewal_order_id_loss_data
where date between '2023-06-01' and '2024-09-30'
    and is_now_cancell=0
    and is_refund=0
    and is_active_7=1
    and date_diff(date,standard_order_date,day)>=7
    and (is_cancell_future_1=1
            or (is_final_cancell=0 and rand()<0.01)
    )
group by 1,2
order by 1,2

-- 次三日流失
select app_id,is_cancell_future_3,count(distinct uuid) uv,count(1) pv
from dataintegration-265403.temp.renewal_order_id_loss_data
where date between '2023-06-01' and '2024-09-30'
    and is_now_cancell=0
    and is_refund=0
    and is_active_7=1
    and date_diff(date,standard_order_date,day)>0
    and (date_diff(standard_cancel_date,date,day) = 3
--     and (is_cancell_future_3=1
            or (is_final_cancell=0 and rand()<0.01)
    )
group by 1,2
order by 1,2

-- 次7日流失
select app_id,is_cancell_future_7,count(distinct uuid) uv,count(1) pv
from dataintegration-265403.temp.renewal_order_id_loss_data
where date between '2023-06-01' and '2024-09-30'
    and is_now_cancell=0
    and is_refund=0
    and is_active_7=1
    and date_diff(date,standard_order_date,day)>0
    and (date_diff(standard_cancel_date,date,day) = 7
--     and (is_cancell_future_7=1
            or (is_final_cancell=0 and rand()<0.005)
    )
group by 1,2
order by 1,2



drop table if exists beautyplus-bc0ed.temp.renewal_order_loss_behave_part;
create table beautyplus-bc0ed.temp.renewal_order_loss_behave_part as
select *except(date,uuid,app_id,loss_type,subscription_period)
    ,case when subscription_period='1-week' then 1
          when subscription_period='1-month' then 2
          when subscription_period='3-month' then 3
          when subscription_period='6-month' then 4
          when subscription_period='1-year' then 5
    end subscription_period
from beautyplus-bc0ed.temp.renewal_order_loss_behave where loss_type='loss af 1 day'

drop table if exists airbrush-1324.temp.renewal_order_loss_behave_part;
create table airbrush-1324.temp.renewal_order_loss_behave_part as
select *except(date,uuid,app_id,loss_type,subscription_period)
    ,case when subscription_period='1-week' then 1
          when subscription_period='1-month' then 2
          when subscription_period='3-month' then 3
          when subscription_period='6-month' then 4
          when subscription_period='1-year' then 5
    end subscription_period
from airbrush-1324.temp.renewal_order_loss_behave where loss_type='loss af 1 day'

-- temp
select loss_type,is_cancell_future_1,is_cancell_future_3,is_cancell_future_7,count(distinct uuid) uv,count(1) pv
from beautyplus-bc0ed.temp.renewal_order_loss_behave
group by 1,2,3,4
;
select loss_type,is_cancell_future_1,is_cancell_future_3,is_cancell_future_7,count(distinct uuid) uv,count(1) pv
from airbrush-1324.temp.renewal_order_loss_behave
group by 1,2,3,4




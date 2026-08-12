-- 方案一：单独计算续订n期的续订率，用对数函数拟合。问题：1.对于已经发生了X期续订的，还用没有发生X期续订时的对X+1期的续订预估

-- 均值续订率预估
select date,app_id,subscription_period,avg(LT)
from `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
where date>='2024-05-15'
--     and app_id='BeautyPlus'
--     and country='Russia' and platform='IOS' and is_UA='Organic'
--     and subscription_user_type='first_time_return_subscription'
    and subscription_period='1-month'
--     and subscription_period='1-year'
group by 1,2,3
order by 2,1,3
-- 单比订单续订率预估汇总
select date,app_id,subscription_period
    ,sum(LTV_pure_forecast) -- 订单初期预测
    ,sum(LTV_real_renewal) -- 订单截止 目前date-至今 真实
from `dataintegration-265403.user_ltv.dws_dz_new_ltv_id`
where date>='2023-01-01'
--     and app_id='BeautyPlus'
--     and country='Russia' and platform='IOS' and is_UA='Organic'
--     and subscription_user_type='first_time_return_subscription'
    and subscription_period='1-month'
--     and subscription_period='1-year'
group by 1,2,3
order by 2,1,3

-- 方案二：不单独计算续订n期的续订率，统一看成订阅率等比序列求和，不区分当前续订期数 计算续订率均值
select date,app_id,platform,subscription_period,country,subscription_user_type,is_ua
--         ,by_period
        ,sum(sample) sample,sum(renewal_num) renewal_num
        ,sum(renewal_num)/sum(sample) renewal_ratio
        ,1/(1-count(case when is_renewal=1 then 1 end)/count(1)) predict_LT
from dataintegration-265403.temp.ltv_renewal_predict
group by 1,2,3,4,5,6
having sum(renewal_num)<sum(sample) and sum(sample)>1000


-- 稳定性检查
select '方案二-分期' types,date,app_id,subscription_period,round(avg(predict_LT),4) predict_LT
from
(
    select date,app_id,'All' platform,subscription_period,'All' country,subscription_user_type,'All' is_ua,by_period
            ,round(1/(1-sum(renewal_num)/sum(sample)),4) predict_LT
    from dataintegration-265403.temp.ltv_renewal_predict
    where date between '2023-01-01' and '2024-09-20'
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('1-month','1-week','1-year','3-month')
    group by 1,2,3,4,5,6,7,8
    having sum(renewal_num)<sum(sample)
)
group by 1,2,3,4

union all

select '方案二-不分期' types,date,app_id,subscription_period,round(avg(predict_LT),4) predict_LT
from
(
    select date,app_id,'All' platform,subscription_period,'All' country,subscription_user_type,'All' is_ua
            ,round(1/(1-sum(renewal_num)/sum(sample)),4) predict_LT
    from dataintegration-265403.temp.ltv_renewal_predict
    where date between '2023-01-01' and '2024-09-20'
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('1-month','1-week','1-year','3-month')
    group by 1,2,3,4,5,6,7
    having sum(renewal_num)<sum(sample)
)
group by 1,2,3,4

union all

select '方案一现有' types,date,app_id,subscription_period,round(avg(LT),4) predict_LT
from `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
where date between '2023-01-01' and '2024-09-20'
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
    and country='all' and platform='all' and is_UA='all' and period=1.0
group by 1,2,3,4


-- 方案一分期看下
select '方案二-分期' types,date,app_id,subscription_period,case when by_period<=3 then cast(by_period as string) else '>3' end by_period,round(avg(predict_LT),4) predict_LT
from
(
    select date,app_id,'All' platform,subscription_period,'All' country,subscription_user_type,'All' is_ua,by_period
            ,round(1/(1-sum(renewal_num)/sum(sample)),4) predict_LT
    from dataintegration-265403.temp.ltv_renewal_predict
    where date between '2023-01-01' and '2024-09-20'
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('1-month','1-week','1-year','3-month')
    group by 1,2,3,4,5,6,7,8
    having sum(renewal_num)<sum(sample)
)
group by 1,2,3,4,5




-- 几种方案历史评估比较
select app_id,subscription_period,observe_period
     ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
    end country
    ,platform
    ,'方案一' types
    ,count(1) sample
    ,round(sum(coalesce(predict0_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict0_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-01-31' and is_expired=0
-- where date>='2022-01-01' and date<='2022-01-31' and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5

union all

select app_id,subscription_period,observe_period
     ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
    end country
    ,platform
    ,'方案一-衍生' types
    ,count(1) sample
    ,round(sum(coalesce(predict0_c_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict0_c_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-01-31' and is_expired=0
-- where date>='2022-01-01' and date<='2022-01-31' and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5

union all

select app_id,subscription_period,observe_period
    ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
    end country
    ,platform
    ,'方案二-1' types
    ,count(1) sample
    ,round(sum(coalesce(predict1_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict1_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-01-31' and is_expired=0
-- where date>='2022-01-01' and date<='2022-01-31' and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5

union all

select app_id,subscription_period,observe_period
    ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
    end country
    ,platform
    ,'方案二-2' types
    ,count(1) sample
    ,round(sum(coalesce(predict2_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict2_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-01-31' and is_expired=0
-- where date>='2022-01-01' and date<='2022-01-31' and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5

union all

select app_id,subscription_period,observe_period
    ,case when country in ('Japan','United States','South Korea','Thailand','Indonesia','India','Brazil') then country
               when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
               else 'other'
    end country
    ,platform
    ,'方案一+方案二' types
    ,count(1) sample
    ,round(sum(coalesce(predict_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from
(
    select app_id,subscription_period,observe_period,country,platform
         ,observe_to_now_LT_real_renewal,LTV_real_renewal
         ,case when observe_period<=2 and subscription_period!='1-year' then predict0_LT_reg
               when observe_period>2 or subscription_period='1-year' then predict1_LT_reg
          end predict_LT_reg
        ,case when observe_period<=2 and subscription_period!='1-year' then predict0_LTV
               when observe_period>2 or subscription_period='1-year' then predict1_LTV
          end predict_LTV
    from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
    where date>='2023-01-01' and date<='2023-01-31' and is_expired=0
    -- where date>='2022-01-01' and date<='2022-01-31' and is_expired=0
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('1-month','1-week','1-year','3-month')
)
group by 1,2,3,4,5




-- 分天看
select app_id,subscription_period,observe_period,date
    ,'方案一' types
    ,count(1) sample
    ,round(sum(coalesce(predict0_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict0_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where DATE_TRUNC(date, MONTH) = date
    and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5
-- order by 1,4,2,3,5

union all

select app_id,subscription_period,observe_period,date
    ,'方案一-衍生' types
    ,count(1) sample
    ,round(sum(coalesce(predict0_c_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict0_c_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where DATE_TRUNC(date, MONTH) = date
    and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5
-- order by 1,4,2,3,5

union all

select app_id,subscription_period,observe_period,date
    ,'方案二-1' types
    ,count(1) sample
    ,round(sum(coalesce(predict1_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict1_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where DATE_TRUNC(date, MONTH) = date
    and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5
-- order by 1,4,2,3,5

union all

select app_id,subscription_period,observe_period,date
    ,'方案二-2' types
    ,count(1) sample
    ,round(sum(coalesce(predict2_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict2_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where DATE_TRUNC(date, MONTH) = date
    and is_expired=0
    and app_id in ('BeautyPlus','AirBrush')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3,4,5
-- order by 1,4,2,3,5

union all

select app_id,subscription_period,observe_period,date
    ,'方案一+方案二' types
    ,count(1) sample
    ,round(sum(coalesce(predict_LT_reg,0.0))) predict_LT_reg_sum
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))) real_LT_reg_sum
    ,round(sum(coalesce(predict_LTV,0.0))) predict_LTV_sum
    ,round(sum(coalesce(LTV_real_renewal,0.0))) real_LTV_sum
from
(
    select date,app_id,subscription_period,observe_period,country,platform
         ,observe_to_now_LT_real_renewal,LTV_real_renewal
         ,case when observe_period<=2 and subscription_period!='1-year' then predict0_LT_reg
               when observe_period>2 or subscription_period='1-year' then predict1_LT_reg
          end predict_LT_reg
        ,case when observe_period<=2 and subscription_period!='1-year' then predict0_LTV
               when observe_period>2 or subscription_period='1-year' then predict1_LTV
          end predict_LTV
    from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
    where DATE_TRUNC(date, MONTH) = date
        and is_expired=0
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('1-month','1-week','1-year','3-month')
)
group by 1,2,3,4,5
-- order by 1,4,2,3,5




-- 示例
select date,original_order_day,app_id,country,platform,is_UA,subscription_period,subscription_user_type
       ,original_order_id,payment_price_usd,by_observe_order_date,by_observe_order_id,by_observe_order_period,observe_period,is_expired
       ,LT_real_renewal,by_observe_LT_real_renewal,by_observe_LTV_real_renewal,observe_to_now_LTV_real_renewal
       ,observe_to_now_LT_real_renewal,predict0_LT_reg,predict0_c_LT_reg,predict1_LT_reg,predict2_LT_reg
       ,LTV_real_renewal,predict0_LTV,predict0_c_LTV,predict1_LTV,predict2_LTV
from `dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv`
where date>='2022-12-01' and original_order_id='GPA.3375-4087-7969-91360' --560000996804682
order by original_order_day,date
;
select original_order_id,order_id,order_status,payment_price_usd,standard_order_date,standard_order_expire_date,subscription_user_type
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where original_order_id='GPA.3375-4087-7969-91360'
order by standard_order_date
;
-- 比较几种算得得真实收入
select date,original_order_day,app_id,country,platform,is_UA,subscription_period,subscription_user_type
       ,original_order_id,payment_price_usd,by_observe_order_date,by_observe_order_id,by_observe_order_period,observe_period,is_expired
       ,LTV_real_renewal,by_observe_LTV_real_renewal,observe_to_now_LTV_real_renewal
       ,LTV_real_renewal_all,by_observe_LTV_real_renewal_all,observe_to_now_LTV_real_renewal_all
       ,predict0_LT_reg,predict0_c_LT_reg,predict1_LT_reg,predict2_LT_reg
from `dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv`
where original_order_id='GPA.3375-4087-7969-91360' and date='2023-01-01' --GPA.3359-5944-8072-53720
order by original_order_day,date
;
-- 过期订单
select app_id,date,is_expired,count(distinct original_order_id) order_num
from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-01-31'
    and app_id in ('BeautyPlus','AirBrush','VCUS')
    and subscription_period in ('1-month','1-week','1-year','3-month')
group by 1,2,3





-- 测试
select app_id,subscription_period,observe_period,country,platform
--     ,count(1) sample
    ,round(sum(coalesce(predict0_LT_reg,0.0))/count(1),4) predict0_LT_reg
    ,round(sum(coalesce(predict0_c_LT_reg,0.0))/count(1),4) predict0_c_LT_reg
    ,round(sum(coalesce(predict1_LT_reg,0.0))/count(1),4) predict1_LT_reg
    ,round(sum(coalesce(predict2_LT_reg,0.0))/count(1),4) predict2_LT_reg
    ,round(sum(coalesce(observe_to_now_LT_real_renewal,0.0))/count(1),4) real_LT_reg
--     ,round(sum(coalesce(predict0_LTV_reg,0.0))/count(1),4) predict0_LTV_reg
--     ,round(sum(coalesce(predict1_LTV_reg,0.0))/count(1),4) predict1_LTV_reg
--     ,round(sum(coalesce(predict2_LTV_reg,0.0))/count(1),4) predict2_LTV_reg
--     ,round(sum(coalesce(observe_to_now_LTV_real_renewal,0.0))/count(1),4) real_LTV_reg
    ,round(sum(coalesce(by_observe_LTV_real_renewal,0.0))/count(1),4) by_observe_LTV_real_renewal
    ,round(sum(coalesce(predict0_LTV,0.0))/count(1),4) predict0_LTV
    ,round(sum(coalesce(predict1_LTV,0.0))/count(1),4) predict1_LTV
    ,round(sum(coalesce(predict2_LTV,0.0))/count(1),4) predict2_LTV
    ,round(sum(coalesce(LTV_real_renewal,0.0))/count(1),4) LTV_real_renewal

from dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv
where date>='2023-01-01' and date<='2023-03-01' and is_expired=0
    and app_id in ('BeautyPlus','AirBrush','AirVid','VCUS')
    and subscription_period in ('1-month','1-week','1-year','3-month','6-month')
group by 1,2,3,4,5

select *
from `dataintegration-265403.temp.temp_dws_dz_first_order_id_ltv`
where by_observe_order_period>0 and is_expired=0 and app_id in ('AirBrush') and subscription_period='1-month'
and original_order_day='2022-12-01' and by_observe_order_date='2023-02-01'
limit 100



select *
from `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
where date='2023-01-01'
  and app_id='Pomelo'
  and country='all'
  -- and platform='all'
  -- and is_UA='all'
  -- and subscription_user_type='first_time_return_subscription' and subscription_period='1-week'


select period,period_rate
from  `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
-- where date = '2022-11-24'
--     and app_id='BeautyPlus'
--     and country='others' and platform='ANDROID' and is_UA='Organic'
--     and subscription_user_type='first_time_subscription'
--     and subscription_period='1-month'
where date = '2022-04-22'
    and app_id='AirBrush'
    and country='Brazil' and platform='ANDROID' and is_UA='Organic'
    and subscription_user_type='first_time_return_subscription'
    and subscription_period='3-month'
;
select sum(period_rate),sum(period_rate/0.35123783134853986)
from  `dataintegration-265403.user_ltv.dws_dz_new_forecast_retention`
where date = '2022-04-22'
    and app_id='AirBrush'
    and country='Brazil' and platform='ANDROID' and is_UA='Organic'
    and subscription_user_type='first_time_return_subscription'
    and subscription_period='3-month'
    and period>2


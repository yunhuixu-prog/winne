-- 再订阅用户价格区间
-- 最高和最低价格区间
select subscription_period
        ,case when order_num<=2 then cast(order_num as string)
              when order_num<=5 then '3:3~5'
              when order_num<=10 then '4:6~10'
        else '5:>10' end order_num
        ,case when subscription_period='1-year' and avg_price<=20 then '1:<=20'
              when subscription_period='1-year' and avg_price<=30 then '2:21~30'
              when subscription_period='1-year' and avg_price<=40 then '3:31~40'
              when subscription_period='1-year' and avg_price<=50 then '4:41~50'
              when subscription_period='1-year' then '5:>50'
              when subscription_period='1-month' and avg_price<=3 then '1:<=3'
              when subscription_period='1-month' and avg_price<=5 then '2:4~5'
              when subscription_period='1-month' and avg_price<=8 then '3:6~8'
              when subscription_period='1-month' and avg_price<=12 then '4:9~12'
              when subscription_period='1-month' then '5:>12'
        end avg_price
        ,case when subscription_period='1-year' and (max_price-min_price)/avg_price>1 then '1:>1'
              when subscription_period='1-year' and (max_price-min_price)/avg_price>0.5 then '2:0.5~1'
              when subscription_period='1-year' and (max_price-min_price)/avg_price>0.3 then '3:0.3~0.5'
              when subscription_period='1-year' and (max_price-min_price)/avg_price>0.1 then '4:0.1~0.3'
              when subscription_period='1-year' and (max_price-min_price)/avg_price>0.1 then '5:<0.1'

              when subscription_period='1-month' and (max_price-min_price)/avg_price>1 then '1:>1'
              when subscription_period='1-month' and (max_price-min_price)/avg_price>0.5 then '2:0.5~1'
              when subscription_period='1-month' and (max_price-min_price)/avg_price>0.3 then '3:0.3~0.5'
              when subscription_period='1-month' and (max_price-min_price)/avg_price>0.1 then '4:0.1~0.3'
              when subscription_period='1-month' and (max_price-min_price)/avg_price>0.1 then '5:<0.1'
        end gap_price
        ,count(distinct uuid) uv
from
(
    select uuid,subscription_period
         ,max(price) max_price,min(price) min_price,avg(price) avg_price
         ,count(distinct o_original_order_id) order_num
    from
    (
        select
           uuid,standard_order_date,subscription_period,o_original_order_id,max(payment_price_usd) price
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where app_id ='AirBrush'
            and event_date_hk='2026-03-11'
--             and standard_order_date >= '2024-01-01'
            and payment_price_usd > 0
            and order_status in (1,2)
        group by 1,2,3,4
    )
    group by 1,2
)
group by 1,2,3,4

;
-- 与前一次价格 & SKU相比等
select subscription_period
        ,case when subscription_period='1-year' and pre_avg_price<=20 then '1:<=20'
              when subscription_period='1-year' and pre_avg_price<=30 then '2:21~30'
              when subscription_period='1-year' and pre_avg_price<=40 then '3:31~40'
              when subscription_period='1-year' and pre_avg_price<=50 then '4:41~50'
              when subscription_period='1-year' then '5:>50'
              when subscription_period='1-month' and pre_avg_price<=3 then '1:<=3'
              when subscription_period='1-month' and pre_avg_price<=5 then '2:4~5'
              when subscription_period='1-month' and pre_avg_price<=8 then '3:6~8'
              when subscription_period='1-month' and pre_avg_price<=12 then '4:9~12'
              when subscription_period='1-month' then '5:>12'
        end pre_avg_price
        ,case when price>pre_avg_price then 'more'
              when price=pre_avg_price then 'equal'
              when price<pre_avg_price then 'less'
        end price_more_or_less
        ,case when (price-pre_avg_price)/pre_avg_price<-0.5 then '1:<-0.5'
              when (price-pre_avg_price)/pre_avg_price<=-0.3 then '2:-0.5~-0.3'
              when (price-pre_avg_price)/pre_avg_price<=-0.1 then '3:-0.3~-0.1'
              when (price-pre_avg_price)/pre_avg_price<=-0.05 then '4:-0.1~-0.05'
              when  (price-pre_avg_price)/pre_avg_price<=0.05 then '5:-0.05~0.05'
              when (price-pre_avg_price)/pre_avg_price<=0.1 then '6:0.05~0.1'
              when (price-pre_avg_price)/pre_avg_price<=0.3 then '7:0.1~0.3'
              when (price-pre_avg_price)/pre_avg_price<=0.5 then '8:0.3~0.5'
              when (price-pre_avg_price)/pre_avg_price>0.5 then '9:>0.5'
        end gap
        ,count(1) order_num
from
(
    select uuid,subscription_period,price
        ,avg(price) over(partition by uuid,subscription_period order by standard_order_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) pre_avg_price
    from
    (
        select
           uuid,standard_order_date,subscription_period,o_original_order_id,max(payment_price_usd) price
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where app_id ='AirBrush'
            and event_date_hk='2026-03-11'
--             and standard_order_date >= '2024-01-01'
            and payment_price_usd > 0
            and order_status in (1,2)
        group by 1,2,3,4
    )
)
where pre_avg_price is not null
group by 1,2,3,4

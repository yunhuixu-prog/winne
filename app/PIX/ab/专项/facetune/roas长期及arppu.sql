with
base as
(
    select
      attributed_date
      ,sum(amount) cost
      ,sum(install_uv) install_uv
      ,sum(dau) dau
      ,sum(dnu) dnu
    from dataintegration-265403.view.dws_dz_roas_dashboard_daily_v6
    where app_name='AirBrush'
        and attributed_date between '2024-01-01' and '2024-10-31'
        and attributed_id_type='ua'
        and date_diff(look_date,attributed_date,day)=365+8
        and is_skan=0
--         and first_country='United States'
    group by 1
)
,pay_rank as
(
    SELECT
        attributed_date,attributed_id,event_date,subscription_period,payment_price_usd
        ,order_status,subscription_user_type
        ,date_diff(event_date,attributed_date,day) interval_day
        ,row_number() over(partition by attributed_date,attributed_id order by event_date) sub_rank
    FROM
        `dataintegration-265403.dwd.dwd_dzp_roas_user_detail`
    WHERE
        app_name='AirBrush'
    AND attributed_id_type = 'ua'
    AND attributed_date between '2024-01-01' and '2024-10-31'
        AND date_diff(event_date,attributed_date,day) between 0 and 365+8
    AND is_pay_1d = 1
    AND product = 'subscription'
    AND order_status in (1,2)
    AND is_skan=0
--     and first_country='United States'
)

select interval_day
    ,count(attributed_date) days
    ,round(sum(cost)/count(attributed_date),2) cost
    ,round(sum(install_uv)/count(attributed_date),2) install_uv
    ,round(sum(dau)/count(attributed_date),2) dau
    ,round(sum(pay_uv)/count(attributed_date),2) pay_uv
    ,round(sum(revenue)/count(attributed_date),2) revenue
    ,round(sum(new_pay_uv)/count(attributed_date),2) new_pay_uv
    ,round(sum(new_pay_year_uv)/count(attributed_date),2) new_pay_year_uv
    ,round(sum(new_pay_month_uv)/count(attributed_date),2) new_pay_month_uv
    ,round(sum(new_revenue)/count(attributed_date),2) new_revenue
    ,round(sum(new_year_revenue)/count(attributed_date),2) new_year_revenue
    ,round(sum(new_month_revenue)/count(attributed_date),2) new_month_revenue
    ,round(sum(renewal_revenue)/count(attributed_date),2) renewal_revenue
    ,round(sum(renewal_year_revenue)/count(attributed_date),2) renewal_year_revenue
    ,round(sum(renewal_month_revenue)/count(attributed_date),2) renewal_month_revenue
from
(
    select a.attributed_date,a.cost,a.install_uv,a.dnu,a.dau
         ,a.interval_day
         ,b.pay_uv,b.revenue
         ,b.new_pay_uv,b.new_pay_year_uv,b.new_pay_month_uv
         ,b.new_revenue,b.new_year_revenue,b.new_month_revenue
         ,b.renewal_revenue,b.renewal_year_revenue,b.renewal_month_revenue
    from
    (
        select b.*,l.interval_day
        from base b
        cross join (SELECT num interval_day FROM UNNEST(GENERATE_ARRAY(0, 365+8)) AS num) l
    )a
    left join
    (
        select attributed_date
                ,interval_day
                ,count(distinct attributed_id) pay_uv
                ,sum(payment_price_usd) revenue
                ,count(distinct case when sub_rank=1 then attributed_id end) new_pay_uv
                ,count(distinct case when sub_rank=1 and subscription_period='1-year' then attributed_id end) new_pay_year_uv
                ,count(distinct case when sub_rank=1 and subscription_period='1-month' then attributed_id end) new_pay_month_uv
                ,sum(case when sub_rank=1 then payment_price_usd end) new_revenue
                ,sum(case when sub_rank=1 and subscription_period='1-year' then payment_price_usd end) new_year_revenue
                ,sum(case when sub_rank=1 and subscription_period='1-month' then payment_price_usd end) new_month_revenue
                ,sum(case when sub_rank>1 then payment_price_usd end) renewal_revenue
                ,sum(case when sub_rank>1 and subscription_period='1-year' then payment_price_usd end) renewal_year_revenue
                ,sum(case when sub_rank>1 and subscription_period='1-month' then payment_price_usd end) renewal_month_revenue
        from pay_rank
        group by 1,2
    ) b
    on a.attributed_date=b.attributed_date and a.interval_day=b.interval_day
)
where attributed_date between '2024-10-01' and '2024-10-31'
group by 1
order by 1

;
-- 投放新用户长期arppu
with
pay_rank as
(
    SELECT
        attributed_date,attributed_id,event_date,subscription_period,payment_price_usd
        ,order_status,subscription_user_type,order_id
        ,date_diff(event_date,attributed_date,day) interval_day
        ,row_number() over(partition by attributed_date,attributed_id order by event_date) sub_rank
    FROM
        `dataintegration-265403.dwd.dwd_dzp_roas_user_detail`
    WHERE
        app_name='AirBrush'
    AND attributed_id_type = 'ua'
    AND attributed_date between '2024-10-01' and '2024-10-31'
    AND date_diff(event_date,attributed_date,day)>=0
    AND is_pay_1d = 1
    AND product = 'subscription'
    AND order_status in (1,2)
    AND is_skan=0
)
,
sub_payment as
(
    select a.attributed_date,a.attributed_id
        ,a.subscription_period
        ,date_diff(b.event_date,a.event_date,day) interval_day
        ,sum(b.payment_price_usd) payment
        ,count(distinct b.order_id) order_num
        ,sum(case when b.subscription_period=a.subscription_period then b.payment_price_usd end) same_payment
        ,count(distinct case when b.subscription_period=a.subscription_period then b.order_id end) same_order_num
    from
    (
        select attributed_date,attributed_id,event_date,subscription_period,payment_price_usd,interval_day
        from pay_rank
        where sub_rank=1
    ) a
    left join
    (
        select attributed_date,attributed_id,event_date,subscription_period,payment_price_usd,interval_day,order_id
        from pay_rank
    ) b
    on a.attributed_date=b.attributed_date and a.attributed_id=b.attributed_id
--     where b.event_date between date_add(a.event_date,interval 0 day) and date_add(a.event_date,interval 364 day)
    group by 1,2,3,4
)

select a.subscription_period
     ,a.interval_day
     ,b.pay_uv,b.payment,b.order_num,b.same_payment,b.same_order_num
from
(
    select b.subscription_period,l.interval_day
    from (select '1-year' subscription_period union all select '1-month' subscription_period) b
    cross join (SELECT num interval_day FROM UNNEST(GENERATE_ARRAY(0, 365+8)) AS num) l
)a
left join
(
    select subscription_period,interval_day
            ,count(attributed_id) pay_uv
            ,sum(payment) payment
            ,sum(order_num) order_num
            ,sum(same_payment) same_payment
            ,sum(same_order_num) same_order_num
    from sub_payment
    group by 1,2
) b
on a.subscription_period=b.subscription_period and a.interval_day=b.interval_day
order by 1,2


;
-- 看国家占比估算facetune的年月占比
select sum(uv),sum(uv_uni),sum(uv_bra)
from (
    select a.standard_order_date
        ,count(distinct a.uuid) uv
        ,count(distinct case when country='United States' then a.uuid end) uv_uni
        ,count(distinct case when country='Brazil' then a.uuid end) uv_bra
    from
    (
        select standard_order_date,platform,subscription_period,uuid,original_order_id,order_id,payment_price_usd,country
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and '2024-10-31'
            and app_id in('AirBrush')
            and subscription_user_type in ('first_time_subscription','first_time_return_subscription') --
            -- and platform='IOS'
    ) a
    group by 1

)

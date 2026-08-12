select case when purchase_date between '2025-06-02' and '2025-06-08' then '0602-0608'
            when purchase_date between '2025-06-09' and '2025-06-15' then '0609-0615'
        end period
    ,purchase_date
    ,case when date_diff(purchase_date,standard_order_date,day)=7 then 7
           when date_diff(purchase_date,standard_order_date,day)=3 then 3
           when date_diff(purchase_date,standard_order_date,day)=0 then 0
    else -1
    end trial_days
    ,sub_user_type
    ,case when country in ('United States','Thailand','South Korea','Japan') then country else 'WW'
    end country
    ,count(distinct original_order_id) uv,round(sum(payment_price_usd),2) bookings
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
WHERE purchase_date between '2025-06-02' and '2025-06-15'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
    and purchase_date is not null
group by 1,2,3,4,5

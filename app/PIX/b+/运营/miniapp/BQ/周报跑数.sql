
select event_date
    ,sum(user_num_topup) user_num_topup
    ,sum(payment_price_usd_topup) payment_price_usd_topup
    ,sum(user_num_use) user_num_use
    ,sum(payment_price_usd_use) payment_price_usd_use
from
(
    select
        event_date
        ,count(distinct user_id) user_num_topup
        -- ,sum(credit_num) credit_num_topup
        ,round(sum(payment_price_usd),2) payment_price_usd_topup
        ,0 user_num_use
        -- ,0 credit_num_use
        ,0.0 payment_price_usd_use
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type in (1)
        and app_name='BeautyPlus'
        and event_date between '2023-12-01' and '2024-01-04'
        and payment_price_usd!=0
    group by
        1

    union all

    select
        event_date
        ,0 user_num_topup
        -- ,0 credit_num_topup
        ,0.0 payment_price_usd_topup
        ,count(distinct user_id) user_num_use
        -- ,sum(credit_num) credit_num_use
        ,round(sum(payment_price_usd),2) payment_price_usd_use
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type in (2)
        and app_name='BeautyPlus'
        and event_date between '2023-12-01' and '2024-01-04'
        and payment_price_usd!=0
    group by
        1
)
group by 1
order by 1

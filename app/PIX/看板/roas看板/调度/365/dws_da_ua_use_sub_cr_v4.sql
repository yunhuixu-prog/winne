-- -- cr
-- 预测收入的当月cr应该使用上上个月的cr实际值，因为上上个月会有部分付费在上个月
-- 该部分数据可用于渠道用户的ROAS 看板

--create or replace table  `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4` as


delete
from `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`
where 1=1;

insert into `dataintegration-265403.roas_dataset_v4.dws_da_ua_use_sub_cr_v4`


with county_cost_top20 as
    ( -- 选取支出前15的国家
    select
       distinct date_month,product, platform,Country_Name
    from
    (
        SELECT
            date_month,product, platform,  fix_firebase_en_name Country_Name
            , sum(amount_spent_usd) amount_spent_usd
            ,row_number() over(partition by date_month,product, platform order by sum(amount_spent_usd) desc) as num
        from
        (
            select
                date_trunc(date,month) date_month,product, platform, Country_Name,amount_spent_usd
            FROM `finance-268602.roi_dataset.dws_dz_campgain_info`
        )a left join (select distinct key,  fix_firebase_en_name from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key) b on a.Country_Name = b.key
        group by 1,2,3,4
    )a
    where num<=15
)

,sub as (
    select
        date_trunc(standard_order_date,month) date_month
        , app_id, platform, country,subscription_period
           --促销优惠类型为仅免费试用的 Trial to standard CR
        ,sum(case when  sub_event  =  'install_first_sub_is_trial'  and offer_method = 'trial' and next_offer_method  ='-' then uv else 0 end ) install_first_trial_uv
        ,sum(case when  sub_event ='install_first_time_trial_to_standard_paid' and offer_method = 'trial'
            and next_order_status in ('1','2')  and next_offer_method ='normal' then uv else 0 end ) install_first_trial_to_standard_paid_uv
        --促销优惠类型为mix 的 Trial to standard CR
        ,sum(case when  sub_event  =  'install_first_sub_is_trial' and  offer_method like '%mix%'  and next_offer_method  ='-' then uv  else 0 end ) install_first_mix_trial_uv
        ,sum(case when  sub_event  =  'install_first_time_trial_to_standard_paid' and order_status = 0 and  offer_method like '%mix%'
            and next_order_status in ('1','2')  and next_offer_method ='normal'  then uv else 0 end ) install_first_mix_trial_to_standard_paid_uv
        -- 优惠价转正价付费 Promotional to standard CR
        ,sum(case when  sub_event  = 'install_first_sub_is_promotional' and order_status in (1,2)
                and offer_method <> 'normal'and next_offer_method  ='-' then uv else 0 end ) install_first_promotional_uv
        ,sum(case when  sub_event  = 'install_first_sub_is_promotional_to_standard_paid'
            and offer_method <> 'normal'and next_offer_method = 'normal' then uv else 0  end ) install_first_promotional_to_standard_paid_uv


    from
   (
   select
        app_id, platform, country,subscription_period, standard_order_date
        ,sub_event
        ,subscription_user_type, order_status, offer_method
        ,next_subscription_user_type, next_order_status, next_offer_method
        ,count(original_order_id) as uv
    from
       `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_event_v4`
    group by 1,2,3,4,5,6,7,8,9,10,11,12

    union  all

    select
        app_id, platform, country,subscription_period, standard_order_date
            ,sub_event
        ,subscription_user_type, order_status, offer_method
        , next_subscription_user_type, cast(next_order_status as string) next_order_status, next_offer_method
        ,count(original_order_id) as uv
    from
        `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_cr_v4`
    group by 1,2,3,4,5,6,7,8,9,10,11,12
   )t

group by 1,2,3,4,5
)

,country_paid as
( --   取 月度trial to pay 大于10的国家

        SELECT
           distinct date_month
            ,app_id, platform, country,subscription_period

        FROM sub
        where
            install_first_trial_to_standard_paid_uv>10
)
,country as
( -- 选取支出排名前15,uv 大于10的国家
    select
        m.date_month,m.product,m.platform,m.Country_Name
    from
        county_cost_top20 m
        join
        country_paid n
          on m.product=n.app_id and m.platform=n.platform and m.Country_Name=n.country and m.date_month = n.date_month
)
select
     a.date_month
    ,a.app_id
    ,a.platform
    ,IFNUll(c.Country_Name,'else') as country
    ,a.subscription_period
    ,sum(install_first_trial_uv) install_first_trial_uv
    ,sum(install_first_trial_to_standard_paid_uv ) install_first_trial_to_standard_paid_uv

    ,sum(install_first_mix_trial_uv) install_first_mix_trial_uv
    ,sum(install_first_mix_trial_to_standard_paid_uv) install_first_mix_trial_to_standard_paid_uv

    ,sum( install_first_promotional_uv)  install_first_promotional_uv
    ,sum( install_first_promotional_to_standard_paid_uv) install_first_promotional_to_standard_paid_uv


from
    sub a
    left join country c on a.date_month =  c.date_month and a.app_id = c.product and a.platform = c.platform and a.country= c.Country_Name
group by 1,2,3,4,5


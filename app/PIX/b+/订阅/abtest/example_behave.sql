
with 
event as(
  select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
    where app_name in ('BeautyPlus') 
    and event_date>='2023-01-04' and event_date<='2023-01-11'
    and cast(meepo_abcode as string) in ('9990')
    and device_id is not null --limit 100
),
abcode as (

SELECT
        date_p, ab_code, field as device_id, country_id, case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new,
        case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as event_timestamp
      FROM
        `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
      WHERE
      date_p>='2023-01-04' and date_p<='2023-01-11'
      and cast(ab_code as string) in ('9990')
      and field_type = 3 --field是3 device-id
      and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
      --limit 100
      --and field='70D5792E-F62E-4A14-9AD0-3DE6897C8A5B'
      --order by date_p 
)

select event_date,
   m.platform,
    case
       when cast(ab_code as string) in ('9988', '9990')then '对照组'
       else '实验组'
      end as code,
    m.event_name,
    m.key,
    count(distinct m.device_id)
from

(
    SELECT 
        cast(m.event_date as string) event_date ,
        event_timestamp,
        platform,
        country,
        event_name,
        '' as key,
        user_pseudo_id,
        device_id ,
        count(1) as pv
    FROM
    event m 
    where m.event_name in  ('coupon_pop_appr_bd','trial_pop_appr_bd','vip_cancel_page_imp_bd')
    group by 1,2,3,4,5,6,7,8

    union all 

    SELECT 
        cast(m.event_date as string) event_date ,
        event_timestamp,
        platform,
        country,
        event_name,
        k.value.string_value as key,
        user_pseudo_id,
        device_id ,
        count(1) as pv
    FROM
    event m ,unnest(event_params) k
    where event_name in ('coupon_pop_clk_bd','trial_pop_clk_bd','vip_cancel_payment_survey_bd','vip_cancel_payment_survey_other_reasons_bd')
                and k.key in ('type','reason','content')
    group by 1,2,3,4,5,6,7,8

    union all
    SELECT 
        cast(m.event_date as string) event_date ,
        event_timestamp,
        platform,
        country,
        event_name,
        k.value.string_value as key,
        user_pseudo_id,
        device_id ,
        count(1) as pv
    FROM
    event m ,unnest(event_params) k
    where m.event_name in ('page_event','subscription_clk_try','subscription_try_suc')
    and  k.key in ('discount_cutdown')
    group by 1,2,3,4,5,6,7,8
)m
left join abcode a
on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.event_timestamp
group by 1,2,3,4,5
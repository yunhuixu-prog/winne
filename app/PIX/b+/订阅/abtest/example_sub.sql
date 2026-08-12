--价格调整实验
--订阅来源表
with 
event as(
  select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` ,unnest(agg) as s
    where date>='2023-09-15' and date<='2023-10-07'
   -- and meepo_abcode>=10146 and  meepo_abcode<=10153
    --and cast(meepo_abcode as string) in ('9992', '9993','9994')
    and device_id is not null
    and source2<>'OnboardingPage'
    --limit 100
),
--实验用户表
abcode as (

SELECT
        date_p, ab_code, field as device_id, country_id, case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new,
        case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as event_timestamp
      FROM
        `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
      WHERE
      date_p>='2023-09-15' and date_p<='2023-10-07'
      and ab_code>=10188 and  ab_code<=10206
      --and cast(ab_code as string) in ('9992', '9993','9994')
      and field_type = 3 --field是3 device-id
      and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
      --and field='70D5792E-F62E-4A14-9AD0-3DE6897C8A5B'
      --order by date_p 
     -- limit 100
),
--取初次用户订阅类型
user_user_tag as 
(
SELECT 
date ,
m.platform,
user_pseudo_id,
 m.device_id ,
 sub_user_type
    FROM
      event m
           join abcode a
        on  m.device_id=a.device_id  and m.platform=a.platform and m.date=a.date_p
group by 
1,2,3,4,5
),
--订阅来源表关联实验用户
user_tag as 
(
SELECT 
m.date ,
    case
       when ab_code =10146 or ab_code =10150  then '对照组'
       when ab_code =10147 or ab_code =10151 then '实验组A'
       when ab_code =10148 or ab_code =10152 then '实验组B'
       else '实验组C'
      end as code,
m.event_timestamp,
m.platform,
case when m.country in ('United States','Turkey','South Korea','Japan') then m.country 
   else 'Others' end as country,
is_new,
m.event_name,
m.user_pseudo_id,
 m.device_id ,
 standard_order_date,
 purchase_date,
 payment_price_usd,
 sku,
 sku_type,sku_tag,b.sub_user_type,
count(1) as pv
    FROM
      event m
           join abcode a
        on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.event_timestamp
      left join user_user_tag b on m.device_id=b.device_id  and m.platform=b.platform
group by 
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
)
select  date,
case when  event_name in ('page_event') then 'sub enter'
  when  event_name in ('subscription_clk_try') then 'sub click'
  else event_name end as event_name,
 a.platform, 
a.country ,is_new,
code,sku_type,sku,sub_user_type,sku_tag,
count(distinct a.device_id) uv
from
  user_tag a
where 
    event_name not in ('subscription_try_suc')
    group by 1,2,3,4,5,6,7,8,9,10
union all
select  date,'sub_success' as event_name,
 a.platform, 
a.country ,is_new,
code,sku_type,sku,sub_user_type,sku_tag,
count(distinct a.device_id) uv
from
  user_tag a
where standard_order_date is not null
and event_name in ('subscription_try_suc')
    group by 1,2,3,4,5,6,7,8,9,10
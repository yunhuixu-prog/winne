
    DECLARE start INT64 DEFAULT 0;
 delete from  `airbrush-1324.stat.dws_airbrush_trial_sub`
   where event_date between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  ;

insert into  `airbrush-1324.stat.dws_airbrush_trial_sub`

  with sub_sku_info as(
      select s1.*,
   case when s2.trial_duration = 0 then 'no_trial'
       when s2.trial_duration != 0 then 'has_trial'
       when s2.trial_duration is null then  'no_trial'
       end as sku_has_trial,

        case
    when   s1.duration = 'annual' then '12m'
    when s1.duration = '3month' then '3m'
    when s1.duration = '1month' then '1m'
    when s1.duration  is not null then s1.duration
    else  CONCAT(s2.duration,s2.duration_unit)

    end AS sku_type,
       s3.uuid as new_uuid
  from
  (select distinct *
    from `airbrush-1324.tmp.sub_client_source`
  where event_name in  ('w_subscription_success','w_subscription_click')
  and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
  )s1
  left join (select distinct product_id,platform,trial_duration,duration,duration_unit from `airbrush-1324.dmi.dmi_aa_sku_info`) s2 on s1.sku = s2.product_id
  AND s1.platform=s2.platform
  left join `dataintegration-265403.stat.dmi_dz_idmapping` s3 on s1.user_pseudo_id = s3.key
  )
  ,

subscription_pre as
(
SELECT
  event_date,
  platform,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'sub_suc' as event_name, --订阅成功：之后用服务端  包含试用和直接付费
source_module,source_00,sale_status,duration,source_11,is_new,is_ua,
  user_pseudo_id,
  0 as payment_price_usd
FROM `airbrush-1324.stat.dws_airbrush_trial_sub_sku_info`
  where standard_order_date is not null
  and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

 union all

 SELECT
  event_date,
  platform,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'sub_to_paid' as event_name,--订阅到付费人数：包含试用转付费和直接付费
  source_module,source_00,sale_status,duration,source_11,is_new,is_ua,
  user_pseudo_id,
  payment_price_usd
FROM `airbrush-1324.stat.dws_airbrush_trial_sub_sku_info`

  where standard_order_date is not null and purchase_date is not null
  and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

union all

SELECT
  event_date,
  platform,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'trial' as event_name,   --试用人数
  source_module,source_00,sale_status,duration,source_11,is_new,is_ua,
  user_pseudo_id,
  0 as payment_price_usd
FROM `airbrush-1324.stat.dws_airbrush_trial_sub_sku_info`
  WHERE standard_order_date is not null and  order_status = 0  -- sku_has_trial IN ('has_trial')  --剔除改条件 by 2023.9.14 by zm
  and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

union all

SELECT
  event_date,
  platform,
  app_version,
  country,
  sku_type,
  sku_has_trial,
  sku,
  'trial_to_paid' as event_name,  --试用转付费人数
  source_module,source_00,sale_status,duration,source_11,is_new,is_ua,
  user_pseudo_id,
  payment_price_usd
FROM `airbrush-1324.stat.dws_airbrush_trial_sub_sku_info`
  where  standard_order_date is not null and  purchase_date is not null  and order_status = 0   --剔除改条件 by 2023.9.14 by zm
  and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)

-- select event_date,
-- user_pseudo_id,
-- payment_price_usd ,
-- sku_type,
-- sku_has_trial,
-- sku,
-- event_name,
-- country,
-- source_module,
-- 'all'source_00,
-- sale_status,
-- duration,
-- 'all'source_11,
-- max(platform)platform,
-- max(app_version)app_version,
-- max(is_new)is_new,
-- max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
-- from subscription_pre
-- where event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

-- group by 1,2,3,4,5,6,7,8,9,10,11,12,13

-- union all


-- --功能
-- select event_date,
-- user_pseudo_id,
-- payment_price_usd ,
-- sku_type,
-- sku_has_trial,
-- sku,
-- event_name,
-- country,
-- source_module,
-- source_00,
-- sale_status,
-- duration,
-- 'all'source_11,
-- max(platform)platform,
-- max(app_version)app_version,
-- max(is_new)is_new,
-- max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
-- from subscription_pre
-- where event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
-- group by 1,2,3,4,5,6,7,8,9,10,11,12,13

-- union ALL

select event_date,  --三级
user_pseudo_id,
payment_price_usd ,
sku_type,
sku_has_trial,
sku,
event_name,
country,
source_module,
source_00,
sale_status,
duration,
source_11,
max(platform)platform,
max(app_version)app_version,
max(is_new)is_new,
max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
from subscription_pre
where event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

union ALL

select event_date,
user_pseudo_id,
payment_price_usd ,
sku_type,
sku_has_trial,
sku,
event_name,
country,
'all'source_module,
'all'source_00,
sale_status,
duration,
'all'source_11,
max(platform)platform,
max(app_version)app_version,
max(is_new)is_new,
max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
from subscription_pre
where event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

union ALL

select event_date,
user_pseudo_id,
0 as payment_price_usd ,
if(source_00 = 'f_annual_recommend_2021','12m',sku_type)sku_type,
if(source_00 = 'f_annual_recommend_2021','no_trial',sku_has_trial)sku_has_trial,
sku,
event_name,
country,
'all'source_module,
'all'source_00,
sale_status,
if(source_00 = 'f_annual_recommend_2021','annual',duration)duration,
'all'source_11,
max(platform)platform,
max(app_version)app_version,
max(is_new)is_new,
max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
from sub_sku_info
where event_name = 'w_subscription_click'
and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

-- union all

-- select event_date,
-- user_pseudo_id,
-- 0 as payment_price_usd ,
-- if(source_00 = 'f_annual_recommend_2021','12m',sku_type)sku_type,
-- if(source_00 = 'f_annual_recommend_2021','no_trial',sku_has_trial)sku_has_trial,
-- sku,
-- event_name,
-- country,
-- source_module,
-- 'all'source_00,
-- sale_status,
-- if(source_00 = 'f_annual_recommend_2021','annual',duration)duration,
-- 'all'source_11,
-- max(platform)platform,
-- max(app_version)app_version,
-- max(is_new)is_new,
-- max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
-- from sub_sku_info
-- where event_name = 'w_subscription_click'
-- and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
-- group by 1,2,3,4,5,6,7,8,9,10,11,12,13

-- union all


-- --功能
-- select event_date,
-- user_pseudo_id,
-- 0 as payment_price_usd ,
-- if(source_00 = 'f_annual_recommend_2021','12m',sku_type)sku_type,
-- if(source_00 = 'f_annual_recommend_2021','no_trial',sku_has_trial)sku_has_trial,
-- sku,
-- event_name,
-- country,
-- source_module,
-- source_00,
-- sale_status,
-- if(source_00 = 'f_annual_recommend_2021','annual',duration)duration,
-- 'all'source_11,
-- max(platform)platform,
-- max(app_version)app_version,
-- max(is_new)is_new,
-- max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
-- from sub_sku_info
-- where event_name = 'w_subscription_click'
-- and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
-- group by 1,2,3,4,5,6,7,8,9,10,11,12,13

union ALL

select event_date,  --三级
user_pseudo_id,
0 as payment_price_usd ,
if(source_00 = 'f_annual_recommend_2021','12m',sku_type)sku_type,
if(source_00 = 'f_annual_recommend_2021','no_trial',sku_has_trial)sku_has_trial,
sku,
event_name,
country,
source_module,
source_00,
sale_status,
if(source_00 = 'f_annual_recommend_2021','annual',duration)duration,
source_11,
max(platform)platform,
max(app_version)app_version,
max(is_new)is_new,
max(if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) )is_ua
from sub_sku_info
where event_name = 'w_subscription_click'
and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13

union ALL

select event_date,
user_pseudo_id,
0 as payment_price_usd ,
'-'sku_type,
'-'sku_has_trial,
'-'sku,
event_name,
country,
source_module,
source_00,
sale_status,
duration,
source_11,
platform,
app_version,
is_new,
if(is_ua in ('Non-Organic','non-Organic'),'non-Organic',if(is_ua = 'Organic','Organic',null)) is_ua
from `airbrush-1324.tmp.dws_airbrush_users_slice`
where event_name in ('w_subscription_enter','DAU')
and event_date  between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval 14 day) and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'


with 
user_tag as (
SELECT
        date_p, cast(ab_code as string) code, field as device_id, country_id, case when is_app_new= 'new user' when is_app_new='1' then 'old user' end as is_new,
        case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
      FROM
        `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
      WHERE
      date_p>='2023-01-04' and date_p<='2023-01-25'
      and cast(ab_code as string) in ('9988', '9989','9990','9991')
      and field_type = 3 --field是3 device-id
      and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
),
event as(
  select distinct
cast(m.event_date as string) event_date ,
receive_time as event_timestamp,
country,
event_name,
func.getParams(event_params,'discount_cutdown').string_value as is_sku_fold,
func.getParams(event_params,'sub_tag').string_value as module_position,
 m.device_id 
    FROM
     `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`m
    join user_tag a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.receive_time>=a.timestamp 
    where app_name in ('BeautyPlus') 
    and event_date>='2023-01-04' and event_date<='2023-01-25'
    and event_name in ('page_event','subscription_clk_try','subscription_try_suc')
    and cast(meepo_abcode as string) in ('9988', '9989','9990','9991')
    and m.device_id is not null
),
paid_event as 
(
SELECT
h.*,g.subscription_user_type as purchase_subscription_user_type,g.sku_price
FROM
 `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_abtest_add` h
 left join `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`  g
 on h.purchase_date=g.standard_order_date and h.new_uuid=g.uuid and h.purchase_order_id=g.order_id
 where h.event_name in ('subscription_try_suc') and h.standard_order_date is not null and h.purchase_date is not null  
 and g.order_status != 3
 and date>='2023-01-01' and date<='2023-01-25' 
),
subscription_event as 
(
SELECT  
a.*except(payment_price_usd), 0 as payment_price_usd,0 as paid_LTV365,0 as sku_price 
FROM 
`beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_abtest_add` a 
 WHERE  date>='2023-01-01' and date<='2023-01-25' 
),
subscription_pre as 
(

 SELECT
  date,
  timestamp,
  device_id,
  platform,
  --country,
  sku_type,
  sku_has_trial,
  sku,
  sku_price,
 payment_price_usd,
 LTV365 as paid_LTV365,
  purchase_date,
  'sub_success_to_paid' as event_name,
  source2,
  agg,
  user_pseudo_id,
  new_uuid,
  cur_page_type
FROM paid_event

 union all

SELECT
  date,
  timestamp,
  device_id,
  platform,
  --country,
  sku_type,
  sku_has_trial,
  sku,
  sku_price,
  payment_price_usd,
   paid_LTV365,
  purchase_date,
   event_name,
  source2,
  agg,
  user_pseudo_id,
  new_uuid,
  cur_page_type
FROM subscription_event
  where event_name in ('subscription_try_suc') and standard_order_date is not null 
  
 union all 
 
 SELECT
  date,
  timestamp,
  device_id,
  platform,
  --country,
  sku_type,
  sku_has_trial,
  sku,
  sku_price,
  payment_price_usd,
  paid_LTV365,
  purchase_date,
  event_name,
  source2,
  agg,
  user_pseudo_id,
  new_uuid,
  cur_page_type
FROM subscription_event
where event_name in ('subscription_clk_try','page_event')
  
),
sub_category_user as
(
 select
 g.date,
 g.platform,
 --g.country,
 g.code,
 g.sku_type,
 g.sku_has_trial,
 g.sku,
 g.sku_price,
 g.event_name,
 g.source2,
 g.category1,
 g.category2,
g.category2_cn,
 g.is_new,
 g.user_pseudo_id,
 g.device_id,
 new_uuid,
 g.purchase_date,
 g.payment_price_usd as payment_price_usd,
 g.paid_LTV365,
 g.cur_page_type,
 g.timestamp
 from    
    (select
        a.date,
        a.platform,
        --u.country,
        u.code,
        a.sku_type,
        a.sku_has_trial,
        a.sku,
        a.sku_price,
        a.event_name,
        source2,
        a.category1,
  case 
  when b.english_name is not null then b.english_name 
  when a.category1 in ('feature','material') then 'others'
  else a.category2 end as category2,
  case 
  when b.chinese_name is not null then b.chinese_name
  when a.category1 in ('feature','material') then '其他'
  else a.category2 end as category2_cn,
        u.is_new,
        a.user_pseudo_id,
        a.device_id,
        new_uuid,
        a.payment_price_usd,
        paid_LTV365,
        purchase_date,
        cur_page_type,
        a.timestamp
        from 
            (SELECT
              distinct  
              date,
              timestamp,
              device_id,
              platform,
              --country,
              sku_type,
              sku_has_trial,
              sku,
              sku_price,
              payment_price_usd,
              paid_LTV365,
              event_name,
              source2,
              s.category1,
              s.category2,
              user_pseudo_id,
              new_uuid,
              purchase_date,
              cur_page_type
              
            FROM
              subscription_pre,unnest(agg) as s
              
              )a
        --关联实验时机 
        join user_tag u
        on a.device_id=u.device_id  and a.timestamp>=u.timestamp

        --维度功能名称映射表
        left join
          `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b on a.category2=b.key
    )g
),
final_output as
(  SELECT distinct
      date,
      m.platform,
      '订阅挽留1.1' as experiment,
      case
       when m.code in ('9988','9990') then '对照组'
      -- when m.code in ('9993') then '实验组A'
       else '实验组'
      end as code,
      --m.country,
      m.event_name,
      source2,
     category1,
       category2,
       category2_cn,
      sku_type,
      sku,
      sku_price,
      is_new,
      payment_price_usd,
      paid_LTV365,
      m.device_id,
      cur_page_type,
      module_position,
       is_sku_fold
  from sub_category_user m 
  left join event a on  m.device_id=a.device_id  and m.timestamp=a.event_timestamp --and m.event_name=a.event_name 
  where  
  category2 in ('订阅页挽留策略-试用弹窗','订阅页挽留策略-优惠弹窗','订阅页挽留策略')
  or is_sku_fold is not null
  --group by 1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19
)

select 
     experiment,
    'category2'  as data_tye,
    a.date,
a.platform,a.code,a.event_name,sku_type,sku,is_new,category1,category2,
category2_cn, module_position,is_sku_fold,
  count(distinct device_id) as uv, count(device_id) as pv
  from final_output a
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14

    union all

  select  
     experiment,
     data_tye,    
    date,
platform,code,'revenue' event_name,sku_type,sku,is_new,category1,category2,category2_cn, module_position,is_sku_fold,
  sum(payment_price_usd) revenue, sum(payment_price_usd) revenue 
  from
  (select     
     experiment,
    'category2' as data_tye,
    date,
platform,code,event_name,sku_type,sku,is_new,category1,category2,category2_cn, module_position,
      is_sku_fold,
   device_id,payment_price_usd,
   case 
   when (paid_LTV365 is null and sku_type='12m') then payment_price_usd when  (paid_LTV365 is null and sku_type='1m') then payment_price_usd*3.84 else paid_LTV365 end as paid_LTV365
   from final_output 
   group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
   group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
--aigc订阅
--create table if not exists  `beautyplus-bc0ed.temp.dws_sub_aigc_new`  as 
delete from beautyplus-bc0ed.temp.dws_sub_aigc_new where date>= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}';
insert into  beautyplus-bc0ed.temp.dws_sub_aigc_new 
select  date
,case when source2 like '%AIR%' then 'Avatar'
      when source2 like '%ai_portrait%' then 'AI Portrait 2.0'
      when source2 like '%ai_filter%' then 'AI Filter 1.0'
else source2
 end as function,
     'sub success'action,b.platform,case when is_new=1 then 'New-user' else 'Old-user' end as is_new,b.country,is_UA, count(distinct a.user_pseudo_id) as uv,SUM(0) revenue
     from 
   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =date and event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'--and event_date_hk<"2023-03-01"
where

    ( source2 in ('AIArt','AISketch','AI Motion Comic','AI Style Morph Pet','AI Extend_Custom','AI Extend_Original') or source2 like '%AIR%' or source2 like '%ai_portrait%' or source2 like '%ai_filter%')
   and event_name='subscription_try_suc'
   and standard_order_date is not null
   and date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7
union all
select  date,
case when source2 like '%AIR%' then 'Avatar'
     when source2 like '%ai_portrait%' then 'AI Portrait 2.0'
     when source2 like '%ai_filter%' then 'AI Filter 1.0'
else source2
 end as function,
     'sub success to paid'action,b.platform,case when is_new=1 then 'New-user' else 'Old-user' end as is_new,b.country,is_UA, count(distinct a.user_pseudo_id) as uv,SUM(payment_price_usd) as revenue
     from
   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
join `dataintegration-265403.stat.stat_active_advice_detail_d` b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =date and event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}' --and event_date_hk<"2023-03-01"
where

      ( source2 in ('AIArt','AISketch','AI Motion Comic','AI Style Morph Pet','AI Extend_Custom','AI Extend_Original') or source2 like '%AIR%' or source2 like '%ai_portrait%' or source2 like '%ai_filter%')
   and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
   and date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'
group by 1,2,3,4,5,6,7
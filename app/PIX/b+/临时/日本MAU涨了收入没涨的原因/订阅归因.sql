SELECT
    '0:dau' as event_name,
--     a.event_date_hk as date,
    date_trunc(a.event_date_hk, month) event_month,
    case when a.event_date_hk<='2024-06-30' then '24上半年' else '24下半年' end year,
    a.platform,
    '' as sku_has_trial,
    a.country,
    case when a.is_new=1 then 'New-user' else 'Old-user' end as is_new,
    a.is_UA as is_ua,
    '' as category1,
    count(distinct a.user_pseudo_id) as value
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`  a
where a.event_date_hk between '2024-01-01' and '2024-12-31'
        and a.app_name = 'BeautyPlus'
        and a.country='Japan'
group by 1,2,3,4,5,6,7 ,8,9

union all

select
    '1:sub_enter' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('page_event')
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9

union all

select
    '2:sub_suc' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9

union all

select
    '3:sub_suc_to_paid' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9

;

-- 拆分1.5级
select
    '1:sub_enter' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('page_event')
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10

union all

select
    '2:sub_suc' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10

union all

select
    '3:sub_suc_to_paid' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,case when a.date<='2024-06-30' then '24上半年' else '24下半年' end year
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10

;
-- 拆分二级
select event_name
    ,case when event_month<='2024-06-30' then '24上半年' else '24下半年' end year
    ,platform,sku_has_trial,country,is_new,is_UA,category1,module,category2
    ,sum(value) value
from
(
select
    '1:sub_enter' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,case
      when b.english_name is not null then b.english_name
      when g.category2 like '%ai_filter%' then 'ai_filter'
      when g.category2 like '%ai_portrait%' then 'ai_portrait'
      when g.category2 like '%puriplus%' then 'puriplus'
      else g.category2 end as category2
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join
(
    select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category,max(catetory3) category3
    from `dataintegration-265403.dim.dim_aa_content_dict`
    where key is not null
    group by 1
) b
on g.category2=b.key
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('page_event')
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10

union all

select
    '2:sub_suc' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,case
      when b.english_name is not null then b.english_name
      when g.category2 like '%ai_filter%' then 'ai_filter'
      when g.category2 like '%ai_portrait%' then 'ai_portrait'
      when g.category2 like '%puriplus%' then 'puriplus'
      else g.category2 end as category2
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join
(
    select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category,max(catetory3) category3
    from `dataintegration-265403.dim.dim_aa_content_dict`
    where key is not null
    group by 1
) b
on g.category2=b.key
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10

union all

select
    '3:sub_suc_to_paid' event_name
--     ,a.date
    ,date_trunc(a.date, month) event_month
    ,a.platform
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
    else 'no_trial'
    end sku_has_trial
    ,case when u.country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam','Philippines') then u.country
          else 'WW'
    end as country
    ,case when u.is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,u.is_UA
    ,g.category1
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
     else 'others' end as module
    ,case
      when b.english_name is not null then b.english_name
      when g.category2 like '%ai_filter%' then 'ai_filter'
      when g.category2 like '%ai_portrait%' then 'ai_portrait'
      when g.category2 like '%puriplus%' then 'puriplus'
      else g.category2 end as category2
    ,count(distinct a.user_pseudo_id) as value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,UNNEST(agg) g
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
left join
(
    select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category,max(catetory3) category3
    from `dataintegration-265403.dim.dim_aa_content_dict`
    where key is not null
    group by 1
) b
on g.category2=b.key
where
    a.date between '2024-01-01' and '2024-12-31'
    and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and u.country='Japan'
group by
    1,2,3,4,5,6,7 ,8,9,10
)
group by
    1,2,3,4,5,6,7 ,8,9,10


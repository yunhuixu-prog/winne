-- beautyplus-bc0ed.temp.ads_content_revenue_overall


-- 弹窗（首页归因逻辑，包括了xyz的弹窗）
select date,platform,country_label region,'popup' types,'sub' revenue_types
  ,sum(Sub) uv,sum(Sub_Pay) pay_uv,sum(Revenue) revenue
from beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data_ds
where metric_type='UV' and date>='2023-01-01' and content_id='all'
group by 1,2,3

-- 内容(首页归因逻辑，包括banner，专题，topbanner，推荐配方，金刚区)（包括了xyz的banner，金刚区）
union all

select event_date date,platform,region,'content' types,'sub' revenue_types
    ,sum(Sub) uv,sum(Sub_Pay) pay_uv,sum(Revenue) revenue
from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`
where level_type='content_id' and data_type='uv' and event_date>='2023-01-01'
    and module in ('Banner','专题','推荐配方','推荐配方入口','轮播图','金刚区')
group by 1,2,3

-- xyz+miniapp订阅，计算玩法区，miniapp专属入口和搜索入口，即剔除banner，金刚区，弹窗入口的订阅收入
union all

select  date,platform
        ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
        ,'miniapp' types,'sub' revenue_types
        ,count(distinct original_order_id) uv
        ,count(distinct case when purchase_date is not null then original_order_id end) pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) revenue
     from
   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) k
where k.category1='H5'
--     (source2 in ('AIArt','AISketch','AI Motion Comic','AI Style Morph Pet','AI Extend_Custom','AI Extend_Original') or source2 like '%AIR%' or source2 like '%ai_portrait%' or source2 like '%ai_filter%')
   and event_name='subscription_try_suc'
   and standard_order_date is not null
   and date>='2023-01-01'
group by 1,2,3

-- miniapp积分后端，pay_uv统计为gid维度，免费积分消耗不算
union all

select event_date date,platform
        ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
        ,'miniapp' types,'credit' revenue_types
        ,count(distinct user_id) uv
        ,count(distinct user_id) pay_uv
        ,sum(payment_price_usd) revenue
from `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
where record_type=2 -- 积分消耗
    and app_name='BeautyPlus'
    and miniapp_name not in ('AI Repair','SnapID ID')
    and credit_num>0
     and event_date>='2023-01-01'
group by 1,2,3

union all

-- 搜索收入单独计算，不算xyz，不包括首页搜索功能
select date_p,platform
     ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
     ,'search' types,'sub' revenue_types
     ,count(distinct user_pseudo_id) uv
     ,count(distinct case when paid14>0 then user_pseudo_id end) pay_uv
     ,sum(paid14) revenue
from
     `dataintegration-265403.duffle.dwd_dz_material_events_sub2paid` a,unnest(material_info) k
where
     app_code = 'BP'
   and date_p>='2023-01-01'
   and event_name = 'subscription_try_suc' and k.material_type in ('BP_cat_TEM_SCH','BP_cat_STI_SCH','BP_cat_BRU_SCH','BP_cat_FIL_SCH','BP_cat_TEX_SCH')
group by 1,2,3

union all

-- 首页搜索功能的订阅
select  date,platform
        ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
        ,'search' types,'sub' revenue_types
        ,count(distinct original_order_id) uv
        ,count(distinct case when purchase_date is not null then original_order_id end) pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) revenue
     from
   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) k
where k.category1='content' and k.category2='HomePage Search'
   and regexp_contains(source2,'搜索[,，][0-9]{4}')
   and event_name='subscription_try_suc'
   and standard_order_date is not null
   and date>='2023-01-01'
group by 1,2,3


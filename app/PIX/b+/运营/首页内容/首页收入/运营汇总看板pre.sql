-- beautyplus-bc0ed.temp.ads_content_revenue_overall


-- 弹窗
select date,platform,country_label region,'popup' types,'sub' revenue_types,sum(Sub_Pay) pay_uv,sum(Revenue) revenue
from beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data_ds
where metric_type='UV' and date>='2023-01-01' and content_id='all'
group by 1,2,3

-- 内容
union all

select event_date date,platform,region,'content' types,'sub' revenue_types,sum(Sub_Pay) pay_uv,sum(Revenue) revenue
from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`
where level_type='content_id' and data_type='uv' and event_date>='2023-01-01'
group by 1,2,3

-- miniapp订阅，逻辑上会和内容有重复的，未计算收入
union all

select event_date date,platform
        ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
        ,'miniapp' types,'sub' revenue_types,sum(sub_pay) pay_uv,sum(sub_revenue) revenue
from `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`
where data_type='uv' and event_date>='2023-01-01' and from_page='All'
group by 1,2,3

-- miniapp积分前端
union all

select event_date date,platform
        ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
        ,'miniapp' types,'credit' revenue_types,sum(credit_use) pay_uv,sum(payment_price_usd) revenue
from `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`
where data_type='uv' and event_date>='2023-01-01' and from_page='All'
group by 1,2,3

-- -- miniapp积分后端，由于积分表只有gid，暂不统计pay_uv
-- union all
--
-- select event_date date,platform
--         ,case when country in ('South Korea','Thailand','Japan','United States') then country
--           when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
--           else 'WW'
--         end as region
--         ,'miniapp' types,'credit' revenue_types,0 pay_uv,sum(payment_price_usd) revenue
-- from `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
-- where record_type=2 -- 积分消耗
--     and app_name='BeautyPlus'
--     and miniapp_name not in ('AI Repair')
--      and event_date>='2023-01-01'
-- group by 1,2,3

-- -- search未计算收入
-- union all
--
-- select event_date,platform,case when country='Other English Speaking Country' then 'WW' else country end country,'search' types,'sub' revenue_types,0 sub_pay,0 revenue
-- from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`
-- where event_date>='2023-01-01'
-- group by 1,2,3

union all

-- 搜索收入单独计算，搜索看板未加
select date_p,platform
     ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
        end as region
     ,'search' types,'sub' revenue_types
     ,count(distinct case when paid14>0 then user_pseudo_id end) pay_uv,sum(paid14) revenue
from
     `dataintegration-265403.duffle.dwd_dz_material_events_sub2paid` a,unnest(material_info) k
where
     app_code = 'BP'
   and date_p>='2023-01-01'
   and event_name = 'subscription_try_suc' and k.material_type in ('BP_cat_TEM_SCH','BP_cat_STI_SCH')
group by 1,2,3


-- banner
-- select event_date date,platform,'topbanner' content
--     ,case when event_name='home_content_show_f_bd' then '1:Content Exposure'
--           when event_name='home_content_clk_bd' then '2:Content Click'
--     end event_name
--     ,count(distinct user_pseudo_id) uv,count(1) pv
-- from `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content`
-- where event_date>='2025-02-13' and module_id='BP_TB_00000008' and event_name in ('home_content_show_f_bd','home_content_clk_bd')
-- group by 1,2,3,4

select event_date date,platform,'topbanner' content
    ,case when event_name='home_content_show_f_bd' then '1:Content Exposure'
          when event_name='home_content_clk_bd' then '2:Content Click'
    end event_name
    ,count(distinct user_pseudo_id) uv,count(1) pv
from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where event_date between '2025-02-13' and '2025-02-17'
  and app_name = 'BeautyPlus'
  and event_name in ('home_content_show_f_bd','home_content_clk_bd')
  and content_type='BP_TB_00000040'
group by 1,2,3,4

union all
-- 弹窗
select event_date_hk date,platform,'pop' content
  -- ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
  ,case when event_name='home_page_pop_appr_bd' then '1:Content Exposure'
        when event_name='home_page_pop_clk_bd' then '2:Content Click'
  end event_name
  ,count(distinct user_pseudo_id) uv,sum(pv) pv
from beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event
where event_date_hk between '2025-02-13' and '2025-02-17' and value_name in ('BP_POP_00001642')
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001642') then 'pop'
        when source2='BP_TB_00000040' then 'topbanner'
  end content
  ,case when event_name='page_event' then '3:Sub Enter'
        when event_name='subscription_clk_try' then '4:Sub Click'
  end event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-02-13' and '2025-02-17' and source2 in ('BP_POP_00001642','BP_TB_00000040') and event_name in ('page_event','subscription_clk_try')
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001642') then 'pop'
        when source2='BP_TB_00000040' then 'topbanner'
  end content
  ,'5:Sub Suc' event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-02-13' and '2025-02-17' and source2 in ('BP_POP_00001642','BP_TB_00000040') and event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001642') then 'pop'
        when source2='BP_TB_00000040' then 'topbanner'
  end content
  ,'6:Sub To Paid' event_name
  ,count(distinct user_pseudo_id) uv,round(sum(source_amount_proportion*payment_price_usd),2) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-02-13' and '2025-02-17' and source2 in ('BP_POP_00001642','BP_TB_00000040')
  and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
group by 1,2,3,4

-- push
union all

-- select event_date date
--     ,case when event_name='notification_foreground' then '1:Content Exposure'
--           when event_name='notification_open' then '1:Content Click'
--     end event_name
--     ,platform
--     ,'push' content
--     ,count(distinct user_pseudo_id) uv,count(1) pv
-- from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-13', '2025-02-17', 'BeautyPlus', false)
-- where event_name in ('notification_foreground','notification_open')
--     and (`dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_140%'
--         or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_141%'
--         or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_142%'
--         )
-- group by 1,2,3,4

select event_date date
  ,platform,'push' content
  ,case when event_name='arrive' then '1:Content Exposure'
        when event_name='open' then '2:Content Click'
  end event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.dwd.dwd_dzp_behavior_push_detail`
where event_date between '2025-02-13' and '2025-02-17' and app_name='BeautyPlus'
  and push_id in ('PUSH_140','PUSH_141','PUSH_142')
  and event_name in ('arrive','open')
group by 1,2,3,4

union all
-- push订阅限制条件：打开时间一个小时内的第一个订阅事件且订阅来源是首页-其他入口（无content和click，prepage是首页）
select event_date date
  ,platform
  ,'push' content
  ,case when event_name='page_event' then '3:Sub Enter'
        when event_name='subscription_clk_try' then '4:Sub Click'
  end event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.temp.valentine_push_sub_data_temp`
where event_date between '2025-02-13' and '2025-02-17' and source2 in ('首页-其他入口') and event_name in ('page_event','subscription_clk_try')
group by 1,2,3,4

union all

select event_date date
  ,platform
  ,'push' content
  ,'5:Sub Suc' event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.temp.valentine_push_sub_data_temp`
where event_date between '2025-02-13' and '2025-02-17' and source2 in ('首页-其他入口') and event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3,4

union all

select event_date date
  ,platform
  ,'push' content
  ,'6:Sub To Paid' event_name
  ,count(distinct user_pseudo_id) uv,round(sum(source_amount_proportion*payment_price_usd),2) pv
from `dataintegration-265403.temp.valentine_push_sub_data_temp`
where event_date between '2025-02-13' and '2025-02-17' and source2 in ('首页-其他入口') and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
group by 1,2,3,4


;


-- banner pop去重曝光
select date,count(distinct user_pseudo_id) uv
from
(
    select event_date date,platform,'topbanner' content,user_pseudo_id
    from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
    where event_date between '2025-02-13' and '2025-02-17'
      and app_name = 'BeautyPlus'
      and event_name in ('home_content_show_f_bd')
      and content_type='BP_TB_00000040'
    group by 1,2,3,4

    union all
    -- 弹窗
    select event_date_hk date,platform,'pop' content,user_pseudo_id
    from beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event
    where event_date_hk between '2025-02-13' and '2025-02-17'
      and value_name in ('BP_POP_00001642')
      and event_name in ('home_page_pop_appr_bd')
    group by 1,2,3,4

--     union all
--     -- push
--     select event_date date,platform,'push' content,user_pseudo_id
--     from `dataintegration-265403.dwd.dwd_dzp_behavior_push_detail`
--     where event_date between '2025-02-13' and '2025-02-17' and app_name='BeautyPlus'
--       and push_id in ('PUSH_140','PUSH_141','PUSH_142')
--       and event_name in ('arrive')
--     group by 1,2,3,4
)
group by 1
order by 1

--版本
select event_date date,count(distinct user_pseudo_id)
from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where event_date between '2025-02-13' and '2025-02-17'
  and app_name = 'BeautyPlus'
  and event_name in ('home_content_show_f_bd')
  and content_type='BP_TB_00000040'
  and ((platform='IOS' and version>='7.7.171') or (platform='ANDROID' and version>='7.7.120'))
group by 1
order by 1
;
select
    event_date_hk event_date
    ,count(distinct user_pseudo_id) dau
from
    `dataintegration-265403.stat.stat_active_advice_detail_d`
where app_name in ('BeautyPlus')
    and event_date_hk between '2025-02-13' and '2025-02-17'
    and ((platform='IOS' and app_version>='7.7.171') or (platform='ANDROID' and app_version>='7.7.120'))
group by 1
order by 1




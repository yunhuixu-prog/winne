-- banner
-- select event_date date,platform,'topbanner' content
--     ,case when event_name='home_content_show_f_bd' then '1:Content Exposure'
--           when event_name='home_content_clk_bd' then '2:Content Click'
--     end event_name
--     ,count(distinct user_pseudo_id) uv,count(1) pv
-- from `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content`
-- where event_date>='2025-04-18' and module_id='BP_TB_00000008' and event_name in ('home_content_show_f_bd','home_content_clk_bd')
-- group by 1,2,3,4

select event_date date,platform,'topbanner' content
    ,case when event_name='home_content_show_f_bd' then '1:Content Exposure'
          when event_name='home_content_clk_bd' then '2:Content Click'
    end event_name
    ,count(distinct user_pseudo_id) uv,count(1) pv
from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where event_date between '2025-04-18' and '2025-04-21'
  and app_name = 'BeautyPlus'
  and event_name in ('home_content_show_f_bd','home_content_clk_bd')
  and content_type='BP_TB_00000068'
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
where event_date_hk between '2025-04-18' and '2025-04-21' and value_name in ('BP_POP_00001668')
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001668') then 'pop'
        when source2='BP_TB_00000068' then 'topbanner'
  end content
  ,case when event_name='page_event' then '3:Sub Enter'
        when event_name='subscription_clk_try' then '4:Sub Click'
  end event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-04-18' and '2025-04-21' and source2 in ('BP_POP_00001668','BP_TB_00000068') and event_name in ('page_event','subscription_clk_try')
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001668') then 'pop'
        when source2='BP_TB_00000068' then 'topbanner'
  end content
  ,'5:Sub Suc' event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-04-18' and '2025-04-21' and source2 in ('BP_POP_00001668','BP_TB_00000068') and event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3,4

union all

select date
  ,platform
  ,case when source2 in ('BP_POP_00001668') then 'pop'
        when source2='BP_TB_00000068' then 'topbanner'
  end content
  ,'6:Sub To Paid' event_name
  ,count(distinct user_pseudo_id) uv,round(sum(source_amount_proportion*payment_price_usd),2) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2025-04-18' and '2025-04-21' and source2 in ('BP_POP_00001668','BP_TB_00000068')
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
-- from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-18', '2025-04-21', 'BeautyPlus', false)
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
where event_date between '2025-04-18' and '2025-04-21' and app_name='BeautyPlus'
  and push_id in ('PUSH_187','PUSH_188','PUSH_189')
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
from `dataintegration-265403.temp.resurrection_push_sub_data_temp`
where event_date between '2025-04-18' and '2025-04-21' and source2 in ('首页-其他入口') and event_name in ('page_event','subscription_clk_try')
group by 1,2,3,4

union all

select event_date date
  ,platform
  ,'push' content
  ,'5:Sub Suc' event_name
  ,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.temp.resurrection_push_sub_data_temp`
where event_date between '2025-04-18' and '2025-04-21' and source2 in ('首页-其他入口') and event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3,4

union all

select event_date date
  ,platform
  ,'push' content
  ,'6:Sub To Paid' event_name
  ,count(distinct user_pseudo_id) uv,round(sum(source_amount_proportion*payment_price_usd),2) pv
from `dataintegration-265403.temp.resurrection_push_sub_data_temp`
where event_date between '2025-04-18' and '2025-04-21' and source2 in ('首页-其他入口') and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
group by 1,2,3,4


;


-- banner pop去重曝光
select a.date,banner_and_pop_distinct_uv,pop_uv,topbanner_uv,dau,dau_version
from
(
    select date,count(distinct user_pseudo_id) banner_and_pop_distinct_uv
    from
    (
        select event_date date,platform,'topbanner' content,user_pseudo_id
        from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
        where event_date between '2025-04-18' and '2025-04-21'
          and app_name = 'BeautyPlus'
          and event_name in ('home_content_show_f_bd')
          and content_type='BP_TB_00000068'
        group by 1,2,3,4

        union all
        -- 弹窗
        select event_date_hk date,platform,'pop' content,user_pseudo_id
        from beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event
        where event_date_hk between '2025-04-18' and '2025-04-21'
          and value_name in ('BP_POP_00001668')
          and event_name in ('home_page_pop_appr_bd')
        group by 1,2,3,4

    --     union all
    --     -- push
    --     select event_date date,platform,'push' content,user_pseudo_id
    --     from `dataintegration-265403.dwd.dwd_dzp_behavior_push_detail`
    --     where event_date between '2025-04-18' and '2025-04-21' and app_name='BeautyPlus'
    --       and push_id in ('PUSH_140','PUSH_141','PUSH_142')
    --       and event_name in ('arrive')
    --     group by 1,2,3,4
    )
    group by 1
) a
left join
(
    select event_date_hk date,count(distinct user_pseudo_id) pop_uv
    from beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event
    where event_date_hk between '2025-04-18' and '2025-04-21' and value_name in ('BP_POP_00001668')
        and event_name='home_page_pop_appr_bd'
    group by 1
) b
on a.date=b.date
left join
(
    select event_date date,count(distinct user_pseudo_id) topbanner_uv
    from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
    where event_date between '2025-04-18' and '2025-04-21'
      and app_name = 'BeautyPlus'
      and event_name in ('home_content_show_f_bd')
      and content_type='BP_TB_00000068'
--       and ((platform='IOS' and version>='7.7.171') or (platform='ANDROID' and version>='7.7.120'))
    group by 1
) c
on a.date=c.date
left join
(
    select
        event_date_hk date
        ,count(distinct user_pseudo_id) dau
        ,count(distinct case when ((platform='IOS' and app_version>='7.7.171') or (platform='ANDROID' and app_version>='7.7.120')) then user_pseudo_id end) dau_version
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where app_name in ('BeautyPlus')
        and event_date_hk between '2025-04-18' and '2025-04-21'
--         and ((platform='IOS' and app_version>='7.7.171') or (platform='ANDROID' and app_version>='7.7.120'))
        and country in ('United States','Canada', 'Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom', 'Mexico', 'Brazil', 'Argentina', 'Colombia', 'Peru', 'Australia', 'New Zealand', 'Philippines', 'Lebanon'
                )
    group by 1
) d
on a.date=d.date
order by a.date





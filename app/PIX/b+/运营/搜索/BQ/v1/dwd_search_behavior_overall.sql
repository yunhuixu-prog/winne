-- drop table if exists `beautyplus-bc0ed.temp.dwd_search_behavior_overall`;
-- create table if not exists `beautyplus-bc0ed.temp.dwd_search_behavior_overall` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`
(
country, lang, source, platform, material_type, event_date, search_pv, search_uv, search_clk, search_result
, material_imp, material_clk, material_save, trending_word_clk, search_content_clk, trending_search, nontrending_search, subscription_try_suc
, beauty_feature_or_shop_or_home_pv, beauty_feature_or_shop_or_home_uv, sub_uv, sub_pay_uv, sub_revenue
)

with search_event_pre as
(
    select
        country
        ,source
        ,platform
--         ,source_material_type
--         ,material_type
        ,coalesce(material_type,source_material_type) material_type
        ,event_date
        ,event_name
        ,lang
        ,sum(pv) pv
        ,count(distinct user_pseudo_id) uv
    from
        beautyplus-bc0ed.temp.dwd_search_behavior
    where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
        and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by
        1,2,3,4,5,6,7
)
,
search_result as -- 在搜索两分钟以内曝光的配方/贴纸，认为本次搜索有结果
(
    select
        s.country
        ,s.lang
        ,s.source
        ,s.platform
        ,s.source_material_type
        ,s.event_date
        ,count(distinct cast(s.event_time as string)||s.user_pseudo_id) search_clk
        ,count(distinct case when r.user_pseudo_id is not null then cast(s.event_time as string)||s.user_pseudo_id end) search_result
    from
        (select
            country
            ,lang
            ,source
            ,platform
            ,source_material_type
            ,event_date
            ,event_time
            ,word_content
            ,user_pseudo_id
        from
            beautyplus-bc0ed.temp.dwd_search_behavior
        where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
            and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('material_search_content_bd')
        group by
            1,2,3,4,5,6,7,8,9) s
        left join   (select
                        country
                        ,lang
                        ,source
                        ,platform
                        ,event_date
                        ,event_time
                        ,word_content
                        ,user_pseudo_id
                    from
                        beautyplus-bc0ed.temp.dwd_search_behavior
                    where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
                        and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
                        and event_name in ('beauty_template_material_appr_bd','beauty_sticker_imp_bd','search_miniapp_appr_bd'
                                            ,'search_func_appr_bd','beauty_doodle_imp_bd','beauty_filter_imp_bd','selfie_filter_imp_bd','beauty_text_imp_bd')
                    group by
                        1,2,3,4,5,6,7,8) r on s.country=r.country and s.lang=r.lang and s.event_date=r.event_date and s.user_pseudo_id=r.user_pseudo_id
                                        and s.source=r.source and s.word_content=r.word_content and s.platform=r.platform
--                                         and s.event_time+interval'15'second <= r.event_time
                                        and s.event_time+interval'15'second >= r.event_time
                                        and s.event_time-interval'1'second <= r.event_time
    group by
        1,2,3,4,5,6
)
,
trending_keyword as
(
    select
        s.country
        ,s.lang
        ,s.source
        ,s.source_material_type
        ,s.event_date
        ,s.platform
        ,sum(case when h.word_content is not null then pv end) trending_search
        ,sum(case when h.word_content is null then pv end) nontrending_search
    from
        beautyplus-bc0ed.temp.dwd_search_behavior s
        left join   (select
                        country
                        ,lang
                        ,platform
                        ,word_content
                        ,event_date
                    from
                        beautyplus-bc0ed.temp.dwd_search_behavior
                    where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
                        and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
                        and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
                    group by
                        1,2,3,4,5
                    ) h on s.country=h.country and s.lang=h.lang and s.word_content=h.word_content and s.event_date=h.event_date and s.platform=h.platform
    where s.event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
        and s.event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('material_search_content_bd')
    group by
        1,2,3,4,5,6
)
,sub_event as
(
    select country
         ,platform
         ,case when k.material_type in ('BP_cat_TEM_SCH') then 'template'
            when k.material_type in ('BP_cat_STI_SCH') then 'sticker'
            when k.material_type in ('BP_cat_BRU_SCH') then 'brush'
            when k.material_type in ('BP_cat_FIL_SCH') then 'filter'
            when k.material_type in ('BP_cat_TEX_SCH') then 'text'
            end material_type
         ,date_p event_date
         ,'total' source
         ,count(distinct user_pseudo_id) sub_uv
         ,count(distinct case when paid14>0 then user_pseudo_id end) sub_pay_uv
         ,sum(paid14) sub_revenue
    from
         `dataintegration-265403.duffle.dwd_dz_material_events_sub2paid` a,unnest(material_info) k
    where
         app_code = 'BP'
       and date_p between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
                    and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
       and event_name = 'subscription_try_suc' and k.material_type in ('BP_cat_TEM_SCH','BP_cat_STI_SCH','BP_cat_BRU_SCH','BP_cat_FIL_SCH','BP_cat_TEX_SCH')
    group by 1,2,3,4,5

    union all

    -- 首页搜索功能的订阅
    select  country
         ,platform
         ,'function' material_type
         ,date event_date
         ,'total' source
         ,count(distinct original_order_id) uv
         ,count(distinct case when purchase_date is not null then original_order_id end) pay_uv
         ,round(sum(case when purchase_date is not null then payment_price_usd end),2) revenue
         from
       `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) k
    where k.category1='content' and k.category2='HomePage Search'
       and regexp_contains(source2,'搜索[,，][0-9]{4}')
       and event_name='subscription_try_suc'
       and standard_order_date is not null
       and date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}'
                    and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2,3,4,5
)

select
--     p.country
    case when p.country in ('South Korea','Thailand','Japan','United States','Spain','Germany','Italy','France','Russia','Indonesia','Turkey','Vietnam') then p.country
        when p.country in ('Portugal','Brazil') then 'Portugal Language'
          when p.country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'Other English Speaking Country'
    end as country
    ,p.lang
    ,p.source
    ,p.platform
--     ,p.source_material_type source_material_type
    ,p.material_type
    ,p.event_date

    ,sum(case when event_name='material_search_button_clk_bd' then pv end) search_pv
    ,sum(case when event_name='material_search_button_clk_bd' then uv end) search_uv
    ,max(search_clk) search_clk
    ,max(search_result) search_result

    ,sum(case when event_name in ('beauty_template_material_appr_bd','beauty_sticker_imp_bd','search_miniapp_appr_bd','search_func_appr_bd','beauty_doodle_imp_bd','beauty_filter_imp_bd','selfie_filter_imp_bd','beauty_text_imp_bd') then pv end) material_imp
    ,sum(case when event_name in ('beauty_template_material_clk_bd','beau_clk_sticker_use_bd','search_miniapp_clk_bd','search_func_clk_bd','beau_clk_doodle_use_bd','beauty_filter_click_bd','selfie_filter_click_bd','beau_clk_text_use_bd') then pv end) material_clk
    ,sum(case when event_name in ('beautifysave_bd','selfiesave_bd','beau_sticker_save_bd','beau_doodle_save_bd','beau_text_save_bd') then pv end) material_save

    ,sum(case when event_name in ('trending_word_clk_bd') then pv end) trending_word_clk
    ,sum(case when event_name in ('material_search_content_bd') then pv end) search_content_clk
    ,max(trending_search) trending_search
    ,max(nontrending_search) nontrending_search
    ,sum(case when event_name in ('subscription_try_suc') then uv end) subscription_try_suc
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd','homepageappr_bd') or (event_name='page_event' and p.source='shop_page_search') then pv end) beauty_feature_or_shop_or_home_pv
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd','homepageappr_bd') or (event_name='page_event' and p.source='shop_page_search') then uv end) beauty_feature_or_shop_or_home_uv
    ,0 sub_uv
    ,0 sub_pay_uv
    ,0.0 sub_revenue
    from
    search_event_pre p
    left join search_result r on p.country=r.country and p.source=r.source and p.material_type=r.source_material_type
        and p.event_date=r.event_date and p.platform=r.platform and p.lang=r.lang
    left join trending_keyword t on p.country=t.country and p.source=t.source and p.material_type=t.source_material_type
        and p.event_date=t.event_date and p.platform=t.platform and p.lang=t.lang
group by 1,2,3,4,5,6

union all

select country,null lang,source,platform,material_type,event_date
        ,0 search_pv,0 search_uv,0 search_clk,0 search_result
        ,0 material_imp,0 material_clk,0 material_save
        ,0 trending_word_clk,0 search_content_clk,0 trending_search,0 nontrending_search
        ,0 subscription_try_suc,0 beauty_feature_or_shop_or_home_pv,0 beauty_feature_or_shop_or_home_uv
        ,sub_uv,sub_pay_uv,sub_revenue
from sub_event
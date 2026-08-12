-- drop table if exists `beautyplus-bc0ed.temp.dwd_search_behavior_word_content`;
-- create table if not exists `beautyplus-bc0ed.temp.dwd_search_behavior_word_content` as
-- 还没改，无语死了忙死了
delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_word_content`
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_word_content`


with search_event_pre as
(
    select
        country
        ,source
        ,platform
        ,source_material_type
        ,event_date
        ,event_name
        ,sum(pv) pv
        ,count(distinct user_pseudo_id) uv
    from
        beautyplus-bc0ed.temp.dwd_search_behavior
    where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by
        1,2,3,4,5,6
)
,
search_result as -- 在搜索两分钟以内曝光的配方/贴纸，认为本次搜索有结果
(
    select
        s.country
        ,s.source
        ,s.platform
        ,s.source_material_type
        ,s.event_date
        ,count(distinct cast(s.event_time as string)||s.user_pseudo_id) search_clk
        ,count(distinct case when r.user_pseudo_id is not null then cast(s.event_time as string)||s.user_pseudo_id end) search_result
    from
        (select
            country
            ,source
            ,platform
            ,source_material_type
            ,event_date
            ,event_time
            ,user_pseudo_id
        from
            beautyplus-bc0ed.temp.dwd_search_behavior
        where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
            and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('material_search_content_bd')
        group by
            1,2,3,4,5,6,7) s
        left join   (select
                        country
                        ,source
                        ,platform
                        ,source_material_type
                        ,event_date
                        ,event_time
                        ,user_pseudo_id
                    from
                        beautyplus-bc0ed.temp.dwd_search_behavior
                    where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
                        and event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
                        and event_name in ('beauty_template_material_appr_bd','beauty_sticker_imp_bd')
                    group by
                        1,2,3,4,5,6,7) r on s.country=r.country and s.event_date=r.event_date and s.user_pseudo_id=r.user_pseudo_id
                                        and s.source=r.source and s.source_material_type=r.source_material_type and s.platform=r.platform
--                                         and s.event_time+interval'15'second <= r.event_time
                                        and s.event_time+interval'15'second >= r.event_time
                                        and s.event_time-interval'1'second <= r.event_time
    group by
        1,2,3,4,5
)
,
user_active as
(
    select
        case when country in ('Japan','South Korea','Thailand','United States') then country else 'Other English Speaking Country' end country
        ,platform
        ,event_date_hk
        ,count(user_pseudo_id) active_users
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name='BeautyPlus'
    group by
        1,2,3
)

select
    p.country
    ,p.source
    ,p.platform
    ,p.source_material_type material_type
    ,p.event_date
    ,case when p.source='total' and p.source_material_type ='total' then active_users else null end active_users
    ,sum(case when event_name='page_event' and p.source='total' and p.source_material_type ='total' then pv end) beauty_pv
    ,sum(case when event_name='page_event' and p.source='total' and p.source_material_type ='total' then uv end) beauty_uv
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd') or (event_name='page_event' and p.source='shop_page_search') then pv end) beauty_feature_or_shop_pv
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd') or (event_name='page_event' and p.source='shop_page_search') then uv end) beauty_feature_or_shop_uv

    ,sum(case when event_name='material_search_button_clk_bd' then pv end) search_pv
    ,sum(case when event_name='material_search_button_clk_bd' then uv end) search_uv
    ,max(search_clk) search_clk
    ,max(search_result) search_result

    ,sum(case when event_name in ('beauty_template_material_appr_bd','beauty_sticker_imp_bd') then pv end) material_imp
    ,sum(case when event_name in ('beauty_template_material_clk_bd','beau_clk_sticker_use_bd') then pv end) material_clk
    ,sum(case when event_name in ('beautifysave_bd','beau_sticker_save_bd') then pv end) material_save


    ,sum(case when event_name in ('trending_word_clk_bd') then pv end) trending_word_clk
    ,sum(case when event_name in ('material_search_content_bd') then pv end) search_content_clk
    ,max(trending_search) trending_search
    ,max(nontrending_search) nontrending_search
    ,sum(case when event_name in ('subscription_try_suc') then pv end) subscription_try_suc
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd','homepageappr_bd') or (event_name='page_event' and p.source='shop_page_search') then pv end) beauty_feature_or_shop_or_home_pv
    ,sum(case when event_name in ('beauty_appr_tab_clk_bd','homepageappr_bd') or (event_name='page_event' and p.source='shop_page_search') then uv end) beauty_feature_or_shop_or_home_uv
from
    search_event_pre p
    left join search_result r on p.country=r.country and p.source=r.source and p.source_material_type=r.source_material_type
        and p.event_date=r.event_date and p.platform=r.platform
    left join trending_keyword t on p.country=t.country and p.source=t.source and p.source_material_type=t.source_material_type
        and p.event_date=t.event_date and p.platform=t.platform
    join user_active u on p.country=u.country and p.event_date=u.event_date_hk and p.platform=u.platform
group by
    p.country
    ,p.source
    ,p.platform
    ,p.source_material_type
    ,p.event_date
    ,case when p.source='total' and p.source_material_type ='total' then active_users end

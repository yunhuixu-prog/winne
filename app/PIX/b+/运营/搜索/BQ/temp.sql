drop table if exists `beautyplus-bc0ed.temp.dwd_search_behavior`;
create table if not exists `beautyplus-bc0ed.temp.dwd_search_behavior` as

with search_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_pseudo_id
        ,country
        ,platform
        ,version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-02-27',
        '2024-03-10','beautyplus',true)
    where version>='7.6.030'
)
,
dwd_search_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,platform
,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
,`dataintegration-265403.func`.getParams(event_params,'word_content').string_value word_content
,`dataintegration-265403.func`.getParams(event_params,'template_id').string_value template_id
,`dataintegration-265403.func`.getParams(event_params,'tem_tag').string_value tem_tag
,`dataintegration-265403.func`.getParams(event_params,'贴纸素材ID').string_value sticker_id
,`dataintegration-265403.func`.getParams(event_params,'贴纸分类ID').string_value sticker_tag
,`dataintegration-265403.func`.getParams(event_params,'mids_material_tag').string_value mids_material_tag
,`dataintegration-265403.func`.getParams(event_params,'mids_material').string_value mids_material
,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value sub_feature
,`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value cur_spm
        ,user_pseudo_id
        ,country
        ,count(1) pv
    from
        search_event
    where
    (
        event_name in   ('material_search_button_clk_bd'
                        ,'trending_word_imp_bd'
                        ,'trending_word_clk_bd'
                        ,'material_search_content_bd'
                        ,'beauty_template_material_appr_bd'
                        ,'beauty_template_material_clk_bd'
                        ,'beauty_sticker_imp_bd'
                        ,'beau_clk_sticker_use_bd'
                        ,'search_func_appr_bd'
                        ,'search_func_clk_bd'
                        ,'subscription_try_suc'
                        ,'beautifysave_bd'
                        ,'beau_sticker_save_bd'
                        ,'beauty_appr_tab_clk_bd'
                        ,'page_event'
                        ,'beauty_appr_bd')
    ) or
    (event_name in ('homepageappr_bd') and version>='7.7.010')
        --and func.getParams(event_params,'project').string_value in ('AI_art','AI_sketch','AI_motion_comic','AI_style_morph_pet','BeautyPlus_AI')
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
)
,
user_info as
(
    select distinct
        event_date_hk
        ,platform
        ,user_pseudo_id
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date'2024-02-27'
        and '2024-03-10'
        and app_name='BeautyPlus'
)
-- 订阅页面，订阅事件，tab点击等还没有区分source和material type，where条件估计也不对，有时间看下
select
    event_date
    ,timestamp_add(timestamp_micros(event_timestamp), interval 8 hour) event_time
    ,event_name
    ,t.platform platform
    ,case   when event_name in ('beautifysave_bd','subscription_try_suc','beauty_appr_bd','beau_sticker_save_bd') then 'total'
            when event_name in ('beauty_appr_tab_clk_bd') then 'func_page_search'
            when event_name in ('page_event') and regexp_contains(cur_spm,'1012_04|1012_02') then 'shop_page_search'
            when event_name in ('homepageappr_bd') then 'home_page_search'
            when event_name in ('page_event') and regexp_contains(cur_spm,'1005') then 'total'
            when event_name in ('search_func_appr_bd','search_func_clk_bd') then 'home_page_search'
            else source end source
    ,case   when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd','beautifysave_bd') then 'template'
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd','beau_sticker_save_bd') then 'sticker'
            when sub_feature in ('配方') then 'template'
            when sub_feature in ('贴纸') then 'sticker'
            when regexp_contains(cur_spm,'1012_04') then 'template'
            when regexp_contains(cur_spm,'1012_02') then 'sticker'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_TEM_SCH') then 'template'
            when event_name in ('subscription_try_suc') and mids_material_tag in ('BP_cat_STI_SCH') then 'sticker'
            end material_type
    ,case   when event_name in ('beautifysave_bd','subscription_try_suc','beauty_appr_bd','beau_sticker_save_bd') then 'total'
            when event_name in ('homepageappr_bd') then 'all'
            when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd') and source not in ('home_page_search') then 'template'
            when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd') and source in ('home_page_search') then 'all'
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd') and source not in ('home_page_search') then 'sticker'
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd') and source in ('home_page_search') then 'all'
            when sub_feature in ('配方') then 'template'
            when sub_feature in ('贴纸') then 'sticker'
            when regexp_contains(cur_spm,'1012_04') then 'template'
            when regexp_contains(cur_spm,'1012_02') then 'sticker'
            when regexp_contains(cur_spm,'1005') then 'total'
            when event_name in ('search_func_appr_bd','search_func_clk_bd') then 'all'
            else material_type
            end source_material_type
    ,word_content
    ,coalesce(template_id,sticker_id) material_id
    ,coalesce(tem_tag,sticker_tag) material_tag
    ,mids_material_tag
    ,mids_material
    ,t.user_pseudo_id user_pseudo_id
--     ,case when country in ('Japan','South Korea','Thailand','United States') then country else 'Other English Speaking Country' end country
    ,case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'Other English Speaking Country'
    end as country
    ,pv
from
    dwd_search_event t
join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform
where
    case    when event_name in ('beauty_template_material_appr_bd','beauty_template_material_clk_bd','beautifysave_bd') then tem_tag='BP_cat_TEM_SCH'
            when event_name in ('subscription_try_suc') then mids_material_tag in ('BP_cat_TEM_SCH','BP_cat_STI_SCH')
            when event_name in ('beauty_sticker_imp_bd','beau_clk_sticker_use_bd','beau_sticker_save_bd') then sticker_tag in ('BP_cat_DST_SCH','BP_cat_STI_SCH')
            when event_name in ('beauty_appr_tab_clk_bd') then sub_feature in ('贴纸','配方')
            when event_name in ('page_event') then regexp_contains(cur_spm,'1012_04|1012_02|1005') -- 配方商店页 1012_04, 贴纸商店页 1012_02, 修图编辑页 1005
            else 1=1
            end





-- drop table if exists `beautyplus-bc0ed.temp.dwd_search_behavior_overall`;
-- create table if not exists `beautyplus-bc0ed.temp.dwd_search_behavior_overall` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`
where event_date>='2024-02-27'
    and event_date<='2024-03-10';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`

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
    where event_date >= '2024-02-27'
        and event_date <= '2024-03-10'
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
        where event_date >= '2024-02-27'
            and event_date <= '2024-03-10'
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
                    where event_date >= '2024-02-27'
                        and event_date <= '2024-03-10'
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
trending_keyword as
(
    select
        s.country
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
                        ,platform
                        ,word_content
                        ,event_date
                    from
                        beautyplus-bc0ed.temp.dwd_search_behavior
                    where event_date >= '2024-02-27'
                        and event_date <= '2024-03-10'
                        and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
                    group by
                        1,2,3,4
                    ) h on s.country=h.country and s.word_content=h.word_content and s.event_date=h.event_date and s.platform=h.platform
    where s.event_date >= '2024-02-27'
        and s.event_date <= '2024-03-10'
        and event_name in ('material_search_content_bd')
    group by
        1,2,3,4,5
)
,
user_active as
(
    select
--         case when country in ('Japan','South Korea','Thailand','United States') then country else 'Other English Speaking Country' end country
        case when country in ('South Korea','Thailand','Japan','United States') then country
              when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
              else 'Other English Speaking Country'
        end as country
        ,platform
        ,event_date_hk
        ,count(user_pseudo_id) active_users
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-02-27'
        and '2024-03-10'
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
    ,sum(case when event_name in ('subscription_try_suc') then uv end) subscription_try_suc
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





-- drop table if exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`;
-- create table if not exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`
where event_date>='2024-02-27'
    and event_date<='2024-03-10';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`

with hot_keyword as -- 剔除热搜词
(
    select
        country
        ,word_content
        ,event_date
        ,platform
        ,source_material_type material_type
    from
        beautyplus-bc0ed.temp.dwd_search_behavior
    where event_date >='2024-02-27'
        and event_date<='2024-03-10'
        and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
    group by
        1,2,3,4,5
)



select
    s.country
    ,trim(lower(s.word_content)) word_content
    ,s.source_material_type material_type
    ,s.event_date
    ,s.platform
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from
    beautyplus-bc0ed.temp.dwd_search_behavior s
    left join hot_keyword h on s.country=h.country and s.word_content=h.word_content and s.event_date=h.event_date and s.source_material_type=h.material_type and s.platform=h.platform
where s.event_date >='2024-02-27'
    and s.event_date<='2024-03-10'
    and event_name in ('material_search_content_bd')
    and h.word_content is null
group by
    1,2,3,4,5



-- drop table if exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`;
-- create table if not exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`
where event_date>='2024-02-27'
    and event_date<='2024-03-10';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`

select
    country
    ,word_content
    ,event_date
    ,platform
    ,source_material_type material_type
    ,sum(case when event_name='trending_word_imp_bd' then pv else 0 end) imp_cnt
    ,sum(case when event_name='trending_word_clk_bd' then pv else 0 end) clk_cnt
    ,count(distinct case when event_name='trending_word_imp_bd' then user_pseudo_id end) imp_uv
    ,count(distinct case when event_name='trending_word_clk_bd' then user_pseudo_id end) clk_uv
from
    beautyplus-bc0ed.temp.dwd_search_behavior
where event_date>='2024-02-27'
    and event_date<='2024-03-10'
    and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
group by
    1,2,3,4,5











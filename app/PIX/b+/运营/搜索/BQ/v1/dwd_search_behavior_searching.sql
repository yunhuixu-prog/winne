-- drop table if exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`;
-- create table if not exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`  
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_searching`
(
country, lang, word_content, material_type, event_date, platform, pv, uv
)

with hot_keyword as -- 剔除热搜词
(
    select
        country
        ,word_content
        ,event_date
        ,platform
        ,lang
        ,source_material_type material_type
    from 
        beautyplus-bc0ed.temp.dwd_search_behavior
    where event_date >='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
    group by
        1,2,3,4,5,6
)



select
--     s.country
     case when s.country in ('South Korea','Thailand','Japan','United States','Spain','Germany','Italy','France','Russia','Indonesia','Turkey','Vietnam') then s.country
          when s.country in ('Portugal','Brazil') then 'Portugal Language'
          when s.country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'Other English Speaking Country'
     end as country
    ,s.lang
    ,trim(lower(s.word_content)) word_content
    ,s.source_material_type material_type
    ,s.event_date
    ,s.platform
    ,sum(pv) pv
    ,count(distinct user_pseudo_id) uv
from 
    beautyplus-bc0ed.temp.dwd_search_behavior s
    left join hot_keyword h on s.country=h.country and s.word_content=h.word_content and s.lang=h.lang
        and s.event_date=h.event_date and s.source_material_type=h.material_type and s.platform=h.platform
where s.event_date >='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and s.event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_name in ('material_search_content_bd')
    and h.word_content is null
group by
    1,2,3,4,5,6


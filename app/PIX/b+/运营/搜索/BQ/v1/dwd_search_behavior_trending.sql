-- drop table if exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`;
-- create table if not exists `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending` as

delete from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`  
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset.dwd_search_behavior_trending`
(
country, lang, word_content, event_date, platform, material_type, imp_cnt, clk_cnt, imp_uv, clk_uv
)
select
--     country
    case when country in ('South Korea','Thailand','Japan','United States','Spain','Germany','Italy','France','Russia','Indonesia','Turkey','Vietnam') then country
        when country in ('Portugal','Brazil') then 'Portugal Language'
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'Other English Speaking Country'
    end as country
    ,lang
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
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
    and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_name in ('trending_word_imp_bd','trending_word_clk_bd')
group by
    1,2,3,4,5,6


select distinct event_name,source,material_type,source_material_type
from beautyplus-bc0ed.temp.dwd_search_behavior


select source,material_type,sum(search_uv) search_uv
    ,sum(search_pv) search_pv
    ,sum(beauty_feature_or_shop_or_home_uv) beauty_feature_or_shop_or_home_uv
    ,sum(beauty_feature_or_shop_or_home_pv) beauty_feature_or_shop_or_home_pv
    ,sum(search_clk) search_clk
    ,sum(search_result) search_result
    ,sum(trending_search) trending_search
    ,sum(nontrending_search) nontrending_search
    ,sum(trending_word_clk) trending_word_clk
    ,sum(search_content_clk) search_content_clk
    ,sum(material_imp) material_imp
    ,sum(material_clk) material_clk
    ,sum(material_save) material_save
    ,sum(subscription_try_suc) subscription_try_suc
from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`
where event_date='2024-05-12'
group by 1,2
order by 1,2


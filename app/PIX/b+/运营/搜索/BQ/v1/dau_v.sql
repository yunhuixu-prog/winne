-- `beautyplus-bc0ed.temp.dwd_search_behavior_overall_add_dau`
    select
        event_date_hk event_date
        ,platform
        ,case when country in ('South Korea','Thailand','Japan','United States','Spain','Germany','Italy','France','Russia','Indonesia','Turkey','Vietnam') then country
              when country in ('Portugal','Brazil') then 'Portugal Language'
              when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
              else 'Other English Speaking Country'
         end as country
        ,count(distinct user_pseudo_id) dau
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where app_name in ('BeautyPlus')
        and event_date_hk between '2024-01-01' and (select max(event_date) from `beautyplus-bc0ed.event_dataset.dwd_search_behavior_overall`)
    group by 1,2,3
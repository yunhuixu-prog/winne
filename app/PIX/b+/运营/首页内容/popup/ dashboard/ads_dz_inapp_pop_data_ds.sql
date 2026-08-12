-- beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data_ds

with pop as
(  
    select
        date
        ,id
        ,max(title) title
        ,max(country) country
    from 
        `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
    where theme in ('机内推送') 
        and date>='2022-02-09' 
    group by 1,2
)
,
pop_weight as 
(
    select
        rid
        ,updated_at
        ,weight -- AW配置的弹窗曝光权重
    from
        (select
            *
            ,row_number () over (partition by rid order by updated_at desc) as ranking
        from 
            `dataintegration-265403.dmi.dim_da_marvel_popup`
        ) c
    where 
        -- c.rid='BP_POP_00001489'
        -- and 
        date(c.updated_at)>='2022-02-09' 
        and c.ranking=1 
)
,
data as 
(
    select 'BeautyPlus' app_name
        ,m.event_date_hk
        ,m.platform
        ,m.country
        ,m.value_name
        ,m.version
        ,case when m.is_new in ('New users','New-user') then 'New-user'
              when m.is_new in ('Old users','Old-user') then 'Old-user'
        end is_new
        ,case when m.content_title is null then n.title else m.content_title end as content_title
        ,case when m.content_country is null then n.country else m.content_country end as content_country
        -- ,content_country
        ,weight
        ,event_name
        ,uv
        ,pv
        ,revenue
    from `beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data`  m
        left join pop n on  m.value_name=n.id and m.event_date_hk=n.date
        left join pop_weight nw on m.value_name=nw.rid

    union all

    select 'Beauty Plus Cam' app_name
        ,m.event_date_hk
        ,m.platform
        ,m.country
        ,m.value_name
        ,m.version
        ,case when m.is_new in ('New users','New-user') then 'New-user'
              when m.is_new in ('Old users','Old-user') then 'Old-user'
        end is_new
        ,case when m.content_title is null then n.title else m.content_title end as content_title
        ,case when m.content_country is null then n.country else m.content_country end as content_country
        -- ,content_country
        ,weight
        ,event_name
        ,uv
        ,pv
        ,revenue
    from `beauty-cam-new.duffle.ads_dzp_duffle_inapp_pop_date`  m
        left join pop n on  m.value_name=n.id and m.event_date_hk=n.date
        left join pop_weight nw on m.value_name=nw.rid
)
--BP_POP_00000035

-- select date,platform,content_id,content_title,sum(Exposure),sum(Sub)
-- from 
-- (
select t.*,last_title,tp.type,tp.start_month,tp.name
from 
(
    select
        'UV' AS metric_type
        ,app_name
        ,event_date_hk as date
        ,platform
        ,case when country='China' then 'China Mainland' else country end country
--         ,case when country in ('United States','Thailand','Japan','South Korea') then country else 'WW' end country_label
        ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam') then country
--               when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
              when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
              else 'WW'
        end as country_label
        ,version
        ,is_new
        /* is_new, version,event_name,key_name */
        ,value_name as content_id
        ,content_title
        ,content_country
        ,weight
        ,sum(case when event_name in ('home_page_pop_appr_bd') then uv end) AS Exposure
        ,sum(case when event_name in ('home_page_pop_clk_bd') then uv end) AS Click
        ,sum(case when event_name in ('sub_suc') then uv end) AS Sub
        ,sum(case when event_name in ('sub_to_paid') then uv end) AS Sub_Pay
        ,sum(case when event_name in ('sub_to_paid') then revenue end) AS Revenue
    from
        data
    group by
        1,2,3,4,5,6,7,8,9,10,11,12
    union all
    select
        'PV' AS metric_type
        ,app_name
        ,event_date_hk as date
        ,platform
        ,case when country='China' then 'China Mainland' else country end country
--         ,case when country in ('United States','Thailand','Japan','South Korea') then country else 'WW' end country_label
        ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia','Vietnam') then country
--               when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
              when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
              else 'WW'
        end as country_label
        ,version
        ,is_new
        /* is_new, version,event_name,key_name */
        ,value_name as content_id
        ,content_title
        ,content_country
        ,weight
        ,sum(case when event_name in ('home_page_pop_appr_bd') then PV end) AS Exposure
        ,sum(case when event_name in ('home_page_pop_clk_bd') then PV end) AS Click
        ,sum(case when event_name in ('sub_suc') then uv end) AS Sub
        ,sum(case when event_name in ('sub_to_paid') then uv end) AS Sub_Pay
        ,sum(case when event_name in ('sub_to_paid') then revenue end) AS Revenue
    from 
        data
    group by 
        1,2,3,4,5,6,7,8,9,10,11,12
) t 
left join 
(
    select
        id
        ,title last_title
    from
        (select
            *
            ,row_number () over (partition by id order by date desc) as ranking
        from 
            `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
        where theme in ('机内推送') 
            and date>='2022-02-09' 
        ) c
    where c.ranking=1
) l 
on t.content_id = l.id
left join (select id,max(type) type,max(format_date('%Y-%m', start_date)) start_month,max(name) name from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_pop_type_mapping` where id is not null group by 1) tp
on t.content_id=tp.id
-- )
-- where content_id='BP_POP_00001495' and metric_type = 'UV'
-- group by 1,2,3,4

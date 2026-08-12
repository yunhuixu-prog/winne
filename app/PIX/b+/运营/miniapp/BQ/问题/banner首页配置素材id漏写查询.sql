with
event_raw as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,version
        ,m.miniapp
        ,miniapp_content_id miniapp_id
        ,module_type
        ,content_type
        ,user_pseudo_id
        ,pv
    from
        (
        select
            event_date
            ,platform
            ,geo.country country
            ,event_name
            ,version
            ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
            ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
            ,case when event_name in ('home_content_show_f_bd','home_content_clk_bd') and `dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='Banner' then `dataintegration-265403.func`.getParams(event_params,'模块ID').string_value
            else coalesce(`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value)
            end miniapp_content_id
            ,user_pseudo_id
            ,count(1) pv
        from
        (
            select
                *
            from
                `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-20', '2023-12-20', 'beautyplus', false)
                -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-06', '2023-12-28')
                -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-12-20', '2023-12-28')
            where
                event_name in ('home_content_show_f_bd','home_content_clk_bd')
        )
        where
            case    when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='miniapp' or (`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='Banner' and `dataintegration-265403.func`.getParams(event_params,'内容类型').string_value='miniapp'))
                    else 1=1
                    end
        group by
            1,2,3,4,5,6,7,8,9
        ) e
        left join (select material_id,max(miniapp) miniapp from `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping` group by 1) m on e.miniapp_content_id=m.material_id
)

-- 漏写的materialid
-- select
--         e.event_date
--         ,miniapp_id
--         ,module_type
--         ,content_type
--         ,country
--         ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd') then e.user_pseudo_id end) exposure_uv
--         ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd') then e.user_pseudo_id end) click_uv
--         ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then e.user_pseudo_id end) exposure_miniapp_uv
--         ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='miniapp' then e.user_pseudo_id end) click_miniapp_uv
--         ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='Banner' then e.user_pseudo_id end) exposure_banner_uv
--         ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='Banner' then e.user_pseudo_id end) click_banner_uv
--     from
--         event_raw e
--     where miniapp is null
--     group by
--         1,2,3,4,5

select
        e.event_date
        ,miniapp
        ,case when version>='7.7.010' then 'new' else 'old' end version_type
        ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd') then e.user_pseudo_id end) click_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='miniapp' then e.user_pseudo_id end) exposure_miniapp_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='miniapp' then e.user_pseudo_id end) click_miniapp_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='Banner' then e.user_pseudo_id end) exposure_banner_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='Banner' then e.user_pseudo_id end) click_banner_uv
    from
        event_raw e
    where miniapp in ('B+ AI','AI Pet Portrait')
    group by
        1,2,3

;

SELECT case when country in ('South Korea','Thailand','Japan','United States') then country
          when country in ('Türkiye','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
    end as region,sum(exposure_uv)
-- select *
FROM `beauty-cam-new.temp.miniapp_material_null_temp_temp`
-- where miniapp_id='BP_cat_HPB_00002326'
group by 1



